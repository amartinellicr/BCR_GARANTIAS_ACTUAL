USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('Obtener_Operaciones_Comunes_FT') IS NOT NULL 
    DROP FUNCTION Obtener_Operaciones_Comunes_FT;
GO


CREATE FUNCTION [dbo].[Obtener_Operaciones_Comunes_FT] 
(
	@piOperacion			BIGINT,
	@piGarantia_Real		BIGINT,
	@psCodigo_Bien			VARCHAR(30),
	@pdtFecha_Actual		DATETIME
)
RETURNS @ptbOperaciones_Comunes TABLE(
			Codigo_Contabilidad TINYINT,
			Codigo_Oficina		SMALLINT,
			Codigo_Moneda		TINYINT,
			Codigo_Producto		TINYINT,
			Operacion			DECIMAL(7,0),
			Tipo_Operacion		TINYINT,
			Codigo_Operacion	BIGINT,
			Consecutivo_Garantia BIGINT,
			Monto_Acreencia		NUMERIC(16,2))
AS
/*****************************************************************************************************************************************************
	<Nombre>Obetener_Operaciones_Comunes_FT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Función que permite obtener la lista de operaciones que poseen una garantía real en común.
	</Descripción>
	<Entradas>
			@piOperacion			= Consecutivo de la operación al a que está asociada la garantía real consultada. 
                                      Este el dato llave usado para la búsqueda.

  			@piGarantia_Real		= Consecutivo de la garantía real consultada. Este el dato llave usado para la búsqueda.

			@psCodigo_Bien			= Código de la garantía sobre la cual se obtendrán las operaciones asociadas.
	
			@pdtFecha_Actual		= Fecha actual
	</Entradas>
	<Salidas>
			@ptbOperaciones_Comunes	= Tabla con las operaciones comunes recopiladas.
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>12/02/2013</Fecha>
	<Requerimiento>
			Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-21537427.
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
			<Fecha>19/06/2014</Fecha>
			<Descripción>
					Se agregan los campos referentes a la póliza asociada. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>24/06/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>	
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>28/09/2015</Fecha>
			<Descripción>
				Se realiza una optimización general, en donde se crean índices en estructuras y tablas nuevas. 
			</Descripción>
		</Cambio>		
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

BEGIN
	
	DECLARE		@vdtFecha_Hoy_Sin_Hora		DATETIME,
				@viFecha_Entero				INT,
				@vbEsta_Contrato_Vencido	BIT
				

	--Se convierte la fecha actual a número, para así poder determinar si un contrato está vencido o no.
	SET		@vdtFecha_Hoy_Sin_Hora	= CONVERT(DATETIME,CAST(@pdtFecha_Actual AS VARCHAR(11)),101)
	SET		@viFecha_Entero			= CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Hoy_Sin_Hora, 112))

	
	--Se obtien las operaciones comunes
	INSERT	INTO @ptbOperaciones_Comunes (
		Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda,
		Codigo_Producto, Operacion, Tipo_Operacion, Codigo_Operacion, Consecutivo_Garantia, Monto_Acreencia)
	SELECT	GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, GO1.cod_producto, 
			CASE 
				WHEN (GO1.num_contrato > 0 AND GO1.num_operacion IS NULL) THEN GO1.num_contrato
				ELSE GO1.num_operacion
			END AS Operacion,
			1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GR3.cod_garantia_real,
			ISNULL(GPR.Monto_Acreencia, 0) AS Monto_Acreencia
	FROM	(SELECT	cod_tipo_garantia_real, cod_partido, numero_finca, cod_clase_bien, num_placa_bien, cod_clase_garantia,
				CASE	cod_tipo_garantia_real
					WHEN 1 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '')  
					WHEN 2 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '') 
					WHEN 3 THEN ISNULL(GR1.cod_clase_bien, '') + '-' + ISNULL(GR1.num_placa_bien, '')
				END AS Codigo_Garantia
			FROM	dbo.GAR_GARANTIA_REAL GR1 
			WHERE	GR1.cod_garantia_real = @piGarantia_Real) GR2
		INNER JOIN dbo.GAR_GARANTIA_REAL GR3 
		ON GR3.cod_tipo_garantia_real = GR2.cod_tipo_garantia_real
		AND ISNULL(GR3.cod_partido, -1) = ISNULL(GR2.cod_partido, -1)
		AND ISNULL(GR3.numero_finca , '') = ISNULL(GR2.numero_finca, '')
		AND ISNULL(GR3.cod_clase_bien, '') = ISNULL(GR2.cod_clase_bien, '')
		AND ISNULL(GR3.num_placa_bien, '') = ISNULL(GR2.num_placa_bien, '')
		AND GR3.cod_clase_garantia = GR2.cod_clase_garantia
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_garantia_real = GR3.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC GSP
		ON GSP.prmoc_pnu_oper = GO1.num_operacion
		AND GSP.prmoc_pco_ofici = GO1.cod_oficina
		AND GSP.prmoc_pco_moned = GO1.cod_moneda 
		AND GSP.prmoc_pco_produ = GO1.cod_producto
		AND GSP.prmoc_pco_conta = GO1.cod_contabilidad
		LEFT OUTER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GO1.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		AND GPR.Estado_Registro = 1	
	WHERE GR2.Codigo_Garantia = @psCodigo_Bien
		AND GO1.num_contrato = 0
		AND GSP.prmoc_pse_proces = 1	--Operaciones activas
		AND ((GSP.prmoc_pcoctamay < 815)
			OR (GSP.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND GSP.prmoc_estado = 'A'
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_SICC_PRMGT MGT 
					WHERE	MGT.prmgt_pnu_oper = GSP.prmoc_pnu_oper
						AND MGT.prmgt_pco_ofici = GSP.prmoc_pco_ofici
						AND MGT.prmgt_pco_moned = GSP.prmoc_pco_moned
						AND MGT.prmgt_pco_produ = GSP.prmoc_pco_produ
						AND MGT.prmgt_pco_conta = GSP.prmoc_pco_conta
						AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GR3.Identificacion_Sicc, 0)
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GR3.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_pnu_part =	CASE
														WHEN MGT.prmgt_pcoclagar BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
														ELSE GR3.cod_partido
													END
						AND MGT.prmgt_pcoclagar = GR3.cod_clase_garantia)
						
	UNION ALL

	SELECT	GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, GO1.cod_producto, 
			CASE 
				WHEN (GO1.num_contrato > 0 AND GO1.num_operacion IS NULL) THEN GO1.num_contrato
				ELSE GO1.num_operacion
			END AS Operacion,
			2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GR3.cod_garantia_real,
			ISNULL(GPR.Monto_Acreencia, 0) AS Monto_Acreencia
	FROM	(SELECT	cod_tipo_garantia_real, cod_partido, numero_finca, cod_clase_bien, num_placa_bien, cod_clase_garantia,
				CASE	cod_tipo_garantia_real
					WHEN 1 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '')  
					WHEN 2 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '') 
					WHEN 3 THEN ISNULL(GR1.cod_clase_bien, '') + '-' + ISNULL(GR1.num_placa_bien, '')
				END AS Codigo_Garantia
			FROM	dbo.GAR_GARANTIA_REAL GR1 
			WHERE	GR1.cod_garantia_real = @piGarantia_Real) GR2
		INNER JOIN dbo.GAR_GARANTIA_REAL GR3 
		ON GR3.cod_tipo_garantia_real = GR2.cod_tipo_garantia_real
		AND ISNULL(GR3.cod_partido, -1) = ISNULL(GR2.cod_partido, -1)
		AND ISNULL(GR3.numero_finca , '') = ISNULL(GR2.numero_finca, '')
		AND ISNULL(GR3.cod_clase_bien, '') = ISNULL(GR2.cod_clase_bien, '')
		AND ISNULL(GR3.num_placa_bien, '') 	= ISNULL(GR2.num_placa_bien, '')
		AND GR3.cod_clase_garantia = GR2.cod_clase_garantia
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		ON GRO.cod_garantia_real	= GR3.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA GSP 
		ON GSP.prmca_pnu_contr = GO1.num_contrato
		AND GSP.prmca_pco_ofici = GO1.cod_oficina
		AND GSP.prmca_pco_moned = GO1.cod_moneda 
		AND GSP.prmca_pco_produc = GO1.cod_producto
		AND GSP.prmca_pco_conta = GO1.cod_contabilidad
		LEFT OUTER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GO1.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		AND GPR.Estado_Registro = 1	
	WHERE	GR2.Codigo_Garantia = @psCodigo_Bien
		AND GO1.num_contrato > 0
		AND GO1.num_operacion IS NULL
		AND GSP.prmca_estado = 'A'
		AND GSP.prmca_pfe_defin >= @viFecha_Entero
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_SICC_PRMGT MGT 
					WHERE	MGT.prmgt_pnu_oper = GSP.prmca_pnu_contr
						AND MGT.prmgt_pco_ofici = GSP.prmca_pco_ofici
						AND MGT.prmgt_pco_moned = GSP.prmca_pco_moned
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GSP.prmca_pco_conta
						AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GR3.Identificacion_Sicc, 0)
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GR3.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_pnu_part =	CASE
														WHEN MGT.prmgt_pcoclagar BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
														ELSE GR3.cod_partido
													END
						AND MGT.prmgt_pcoclagar = GR3.cod_clase_garantia)

	UNION ALL

	SELECT	GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, GO1.cod_producto, 
			CASE 
				WHEN (GO1.num_contrato > 0 AND GO1.num_operacion IS NULL) THEN GO1.num_contrato
				ELSE GO1.num_operacion
			END AS Operacion,
			2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GR3.cod_garantia_real,
			ISNULL(GPR.Monto_Acreencia, 0) AS Monto_Acreencia
	FROM	(SELECT	cod_tipo_garantia_real, cod_partido, numero_finca, cod_clase_bien, num_placa_bien, cod_clase_garantia,
				CASE	cod_tipo_garantia_real
					WHEN 1 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '')  
					WHEN 2 THEN ISNULL((CONVERT(varchar(2),GR1.cod_partido)), '') + '-' + ISNULL(GR1.numero_finca, '') 
					WHEN 3 THEN ISNULL(GR1.cod_clase_bien, '') + '-' + ISNULL(GR1.num_placa_bien, '')
				END AS Codigo_Garantia
			FROM	dbo.GAR_GARANTIA_REAL GR1 
			WHERE	GR1.cod_garantia_real = @piGarantia_Real) GR2
		INNER JOIN dbo.GAR_GARANTIA_REAL GR3 
		ON GR3.cod_tipo_garantia_real = GR2.cod_tipo_garantia_real
		AND ISNULL(GR3.cod_partido, -1) = ISNULL(GR2.cod_partido, -1)
		AND ISNULL(GR3.numero_finca , '') = ISNULL(GR2.numero_finca, '')
		AND ISNULL(GR3.cod_clase_bien, '') = ISNULL(GR2.cod_clase_bien, '')
		AND ISNULL(GR3.num_placa_bien, '') 	= ISNULL(GR2.num_placa_bien, '')
		AND GR3.cod_clase_garantia = GR2.cod_clase_garantia
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		ON GRO.cod_garantia_real	= GR3.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA GSP 
		ON GSP.prmca_pnu_contr = GO1.num_contrato
		AND GSP.prmca_pco_ofici = GO1.cod_oficina
		AND GSP.prmca_pco_moned = GO1.cod_moneda 
		AND GSP.prmca_pco_produc = GO1.cod_producto
		AND GSP.prmca_pco_conta = GO1.cod_contabilidad
		LEFT OUTER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GO1.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		AND GPR.Estado_Registro = 1	
	WHERE	GR2.Codigo_Garantia = @psCodigo_Bien
		AND GO1.num_contrato > 0
		AND GO1.num_operacion IS NULL
		AND GSP.prmca_estado = 'A'
		AND GSP.prmca_pfe_defin < @viFecha_Entero
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_SICC_PRMGT MGT 
					WHERE	MGT.prmgt_pnu_oper = GSP.prmca_pnu_contr
						AND MGT.prmgt_pco_ofici = GSP.prmca_pco_ofici
						AND MGT.prmgt_pco_moned = GSP.prmca_pco_moned
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GSP.prmca_pco_conta
						AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GR3.Identificacion_Sicc, 0)
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GR3.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_pnu_part =	CASE
														WHEN MGT.prmgt_pcoclagar BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
														ELSE GR3.cod_partido
													END
						AND MGT.prmgt_pcoclagar = GR3.cod_clase_garantia)
		AND EXISTS (	SELECT	1
						FROM	dbo.GAR_SICC_PRMOC SPM 
						WHERE	SPM.prmoc_pnu_contr > 0
							AND SPM.prmoc_pnu_oper IS NOT NULL
							AND SPM.prmoc_pse_proces = 1		--Operaciones activas
							AND ((SPM.prmoc_pcoctamay < 815)
								OR (SPM.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
							AND SPM.prmoc_estado = 'A'	
							AND SPM.prmoc_pco_oficon = GSP.prmca_pco_ofici
							AND SPM.prmoc_pcomonint = GSP.prmca_pco_moned
							AND SPM.prmoc_pnu_contr = GSP.prmca_pnu_contr)

	RETURN
END
GO

