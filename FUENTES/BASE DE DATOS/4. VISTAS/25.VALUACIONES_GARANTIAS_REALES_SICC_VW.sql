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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Vista que obtiene el aval�o registrado en el SICC y en el sistema de garant�as.
	</Descripci�n>
	<Entradas>
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>12/03/2014</Fecha>
	<Requerimiento>
		Req_Cmabios en la Extracci�n de los campo % de Aceptaci�n,Indicador de Inscripci�n y  
	    Actualizaci�n de Fecha de Valuaci�n en Garant�as Relacionadas, Siebel No. 1-24206841
	</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
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
				ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR WITH (NOLOCK)
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR WITH (NOLOCK)
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							CONVERT(VARCHAR(25), prmgt_pnuidegar) AS prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT WITH (NOLOCK)
						WHERE	prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.numero_finca
			WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GHC
		
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
				ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR WITH (NOLOCK)
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR WITH (NOLOCK)
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							CONVERT(VARCHAR(25), prmgt_pnuidegar) AS prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT WITH (NOLOCK)
						WHERE	prmgt_pcoclagar = 18
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.numero_finca
			WHERE	GGR.cod_clase_garantia = 18
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca
		) GCH
		
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
				ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR WITH (NOLOCK)
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR WITH (NOLOCK)
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							CONVERT(VARCHAR(25), prmgt_pnuidegar) AS prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT WITH (NOLOCK)
						WHERE	prmgt_pcotengar = 1
							AND prmgt_pcoclagar BETWEEN 20 AND 29
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND MGT.prmgt_pnuidegar = GGR.numero_finca
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
				ISNULL(GGR.cod_clase_bien, '') AS cod_clase_bien,
				GGR.num_placa_bien AS Identificacion_Garantia,
				MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
				ISNULL(GGR.cod_clase_bien, '') + ISNULL(GGR.num_placa_bien, '') AS Codigo_Bien
			FROM	dbo.GAR_GARANTIA_REAL GGR WITH (NOLOCK)
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR WITH (NOLOCK)
			ON GVR.cod_garantia_real = GGR.cod_garantia_real
			INNER JOIN (SELECT	TOP 100 PERCENT prmgt_pcoclagar,
							prmgt_pnu_part,
							CONVERT(VARCHAR(25), prmgt_pnuidegar) AS prmgt_pnuidegar,
							CASE 
									WHEN prmgt_pfeavaing = 0 THEN '19000101' 
									WHEN ISDATE(CONVERT(VARCHAR(10), prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MAX(prmgt_pfeavaing),103)
									ELSE '19000101'
							END AS prmgt_pfeavaing
						FROM	dbo.GAR_SICC_PRMGT WITH (NOLOCK)
						WHERE	prmgt_pcoclagar BETWEEN 30 AND 69
						GROUP BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing
						ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) MGT
			ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.num_placa_bien
			WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
			GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
			ORDER BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.cod_clase_bien, GGR.num_placa_bien
		) GPR


		


