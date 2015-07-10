USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('[VALUACIONES_GARANTIAS_REALES_SICC_VW]', 'V') IS NOT NULL
	DROP VIEW VALUACIONES_GARANTIAS_REALES_SICC_VW;
GO


CREATE VIEW [dbo].[VALUACIONES_GARANTIAS_REALES_SICC_VW]
AS

/******************************************************************
	<Nombre>VALUACIONES_GARANTIAS_REALES_SICC_VW</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Vista que obtiene el avalúo registrado en el SICC y en el sistema de garantías.
	</Descripción>
	<Entradas>
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>12/03/2014</Fecha>
	<Requerimiento>
		Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
	    Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>03/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
	</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
******************************************************************/


	SELECT	DISTINCT 
		GHC.cod_clase_garantia,
		GHC.cod_partido,
		GHC.cod_clase_bien,
		GHC.Identificacion_Garantia, 
		GHC.fecha_valuacion,
		GHC.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				'' AS cod_clase_bien,
				GGR.numero_finca AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + COALESCE(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GHC
		
	UNION ALL
	
	SELECT	DISTINCT 
		GHC11.cod_clase_garantia,
		GHC11.cod_partido,
		GHC11.cod_clase_bien,
		GHC11.Identificacion_Garantia, 
		GHC11.fecha_valuacion,
		GHC11.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				'' AS cod_clase_bien,
				GGR.numero_finca AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + COALESCE(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuide_alf,
							prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND prmgt_pcoclagar = 11
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
			WHERE	GGR.cod_clase_garantia = 11
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GHC11
		
	UNION ALL
	
	SELECT	DISTINCT 
		GCH18.cod_clase_garantia,
		GCH18.cod_partido,
		GCH18.cod_clase_bien,
		GCH18.Identificacion_Garantia, 
		GCH18.fecha_valuacion,
		GCH18.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				'' AS cod_clase_bien,
				GGR.numero_finca AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + COALESCE(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND prmgt_pcoclagar = 18
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	GGR.cod_clase_garantia = 18
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GCH18
		
	UNION ALL
	
	SELECT	DISTINCT 
		GCH.cod_clase_garantia,
		GCH.cod_partido,
		GCH.cod_clase_bien,
		GCH.Identificacion_Garantia, 
		GCH.fecha_valuacion,
		GCH.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				'' AS cod_clase_bien,
				GGR.numero_finca AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + COALESCE(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND prmgt_pcotengar = 1
							AND prmgt_pcoclagar BETWEEN 20 AND 29
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GCH
		
	UNION ALL

	SELECT	DISTINCT 
		GPR.cod_clase_garantia,
		GPR.cod_partido,
		GPR.cod_clase_bien,
		GPR.Identificacion_Garantia, 
		GPR.fecha_valuacion,
		GPR.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				COALESCE(GGR.cod_clase_bien, '') AS cod_clase_bien,
				GGR.num_placa_bien AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE(GGR.cod_clase_bien, '') + COALESCE(GGR.num_placa_bien, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND ((prmgt_pcoclagar BETWEEN 30 AND 37)
								OR (prmgt_pcoclagar BETWEEN 39 AND 42)
								OR (prmgt_pcoclagar BETWEEN 44 AND 69))
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
						OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
						OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
		) GPR
		
		UNION ALL

	SELECT	DISTINCT 
		GP3.cod_clase_garantia,
		GP3.cod_partido,
		GP3.cod_clase_bien,
		GP3.Identificacion_Garantia, 
		GP3.fecha_valuacion,
		GP3.Codigo_Bien
	FROM
		(	SELECT	TOP 100 PERCENT 
				GGR.cod_clase_garantia,
				GGR.cod_partido,
				COALESCE(GGR.cod_clase_bien, '') AS cod_clase_bien,
				GGR.num_placa_bien AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				COALESCE(GGR.num_placa_bien, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							prmgt_pnuidegar,
							prmgt_pnuide_alf,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT 
						WHERE	prmgt_estado = 'A'
							AND ((prmgt_pcoclagar = 38)
								OR (prmgt_pcoclagar = 43))
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
			WHERE	((GGR.cod_clase_garantia = 38)
						OR (GGR.cod_clase_garantia = 43))
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
		) GP3


		


