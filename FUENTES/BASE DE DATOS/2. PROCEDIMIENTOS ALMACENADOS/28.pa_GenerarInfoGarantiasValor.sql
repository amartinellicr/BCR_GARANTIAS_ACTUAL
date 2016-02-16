USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasValor;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasValor] AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasValor</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite generar la información a ser incluida en los archivos SEGUI,
             sobre las garantías de valor.
</Descripción>
<Entradas></Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>05/11/2008</Fecha>
		<Descripción>Se modifica la forma en que se obtienen las garantías de valor de los giros de los contratos.</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>26/03/2009</Fecha>
		<Descripción>Se modifica la forma en que se descartan las garantías duplicadas, esto dentro del cursor.</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>Creación de Tablas para SICAD, No. 2016012710534870</Requerimiento>
		<Fecha>16/02/2016</Fecha>
		<Descripción>
			Se realiza un ajuste con el fin de contemplar la carga de algunas de las estructuras creadas para SICAD. 
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

BEGIN

SET NOCOUNT ON

	DECLARE 
			@viContabilidad TINYINT,
			@viOficina SMALLINT,
			@viMoneda TINYINT,
			@viProducto TINYINT,
			@vdNumero_Operacion DECIMAL(7),
			@vsSeguridad VARCHAR(25),
			@viTipo_Documento_Legal SMALLINT,
			@vdNumero_Operacion_Anterior DECIMAL(7),
			@vsSeguridad_Anterior VARCHAR(25),
			@vdtFecha_Actual_Sin_Hora DATETIME,
			@viFecha_Actual_Entera	INT,
			@vbIndicador_Borrar_Registros BIT,
			@vdtFecha_Actual DATE

	/*Se inicializan las variables globales*/
	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Actual_Sin_Hora, 112))

	--INICIO RQ: 2016012710534870

	SET	@vdtFecha_Actual = GETDATE()

	--Se define si se debe eliminar el contenido de las estructuras para SICAD involucradas
	SET	@vbIndicador_Borrar_Registros = (SELECT	CASE	
													WHEN FECHA_PROCESO IS NULL THEN 1
													WHEN FECHA_PROCESO < @vdtFecha_Actual THEN 1
													ELSE 0
												END
										 FROM	dbo.SICAD_GAROPER
										 GROUP BY FECHA_PROCESO)
	
	DELETE FROM dbo.SICAD_VALORES WHERE @vbIndicador_Borrar_Registros = 1
	DELETE FROM dbo.SICAD_GAROPER WHERE  @vbIndicador_Borrar_Registros = 1
	DELETE FROM dbo.SICAD_GAROPER_LISTA WHERE TIPO_GARANTIA = 3 AND @vbIndicador_Borrar_Registros = 1

	--FIN RQ: 2016012710534870

	DELETE FROM dbo.GAR_GIROS_GARANTIAS_VALOR

	IF OBJECT_ID('tempdb..#TMP_GAR_VALOR') IS NOT NULL
	DROP TABLE #TMP_GAR_VALOR

		IF OBJECT_ID('tempdb..#TEMP_PRMOC') IS NOT NULL
			DROP TABLE #TEMP_PRMOC

	IF OBJECT_ID('tempdb..#TGIROSACTIVOS') IS NOT NULL
	DROP TABLE #TGIROSACTIVOS

	IF OBJECT_ID('tempdb..#TGARGIROSACTIVOS') IS NOT NULL
		DROP TABLE #TGARGIROSACTIVOS


	/*Esta tabla almacenará las operaciones activas según el SICC*/
	CREATE TABLE #TEMP_MOC_OPERACIONES (prmoc_pco_ofici	SMALLINT,
										prmoc_pco_moned	TINYINT,
										prmoc_pco_produ TINYINT,
										prmoc_pnu_oper	INT,
										prmoc_pnu_contr INT,
										cod_operacion BIGINT)
		 
	CREATE INDEX TEMP_MOC_OPERACIONES_IX_01 ON #TEMP_MOC_OPERACIONES (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper, prmoc_pnu_contr)
		
		
	/*Esta tabla almacenará los contratos vigentes según el SICC*/
	CREATE TABLE #TEMP_MCA_CONTRATOS (	prmca_pco_ofici		SMALLINT,
										prmca_pco_moned		TINYINT,
										prmca_pco_produc	TINYINT,
										prmca_pnu_contr		INT,
										cod_operacion BIGINT,
										cod_contrato BIGINT)
		 
	CREATE INDEX TEMP_MCA_CONTRATOS_IX_01 ON #TEMP_MCA_CONTRATOS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
	
	/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
	CREATE TABLE #TEMP_MCA_GIROS (	prmca_pco_ofici		SMALLINT,
									prmca_pco_moned		TINYINT,
									prmca_pco_produc	TINYINT,
									prmca_pnu_contr		INT,
									cod_operacion BIGINT,
									cod_contrato BIGINT)
		 
	CREATE INDEX TEMP_MCA_GIROS_IX_01 ON #TEMP_MCA_GIROS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)


	/*Esta tabla almacenará las garantías de valor activas según el SICC*/
	CREATE TABLE #TEMP_GARANTIAS_VALOR (cod_operacion BIGINT, cod_contrato BIGINT,cod_garantia_valor BIGINT, prmgt_pmoresgar DECIMAL(14, 2), prmgt_pco_mongar TINYINT)
		 
	CREATE INDEX TEMP_GARANTIAS_VALOR_IX_01 ON #TEMP_GARANTIAS_VALOR (cod_operacion, cod_garantia_valor)


	/*Se obtienen todas las operaciones activas*/

	INSERT	INTO #TEMP_MOC_OPERACIONES (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper, prmoc_pnu_contr, cod_operacion)
	SELECT	MOC.prmoc_pco_ofici, MOC.prmoc_pco_moned, MOC.prmoc_pco_produ, MOC.prmoc_pnu_oper, MOC.prmoc_pnu_contr, GO1.cod_operacion
	FROM	dbo.GAR_SICC_PRMOC MOC
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GO1.cod_oficina = MOC.prmoc_pco_ofici
		AND GO1.cod_moneda = MOC.prmoc_pco_moned
		AND GO1.cod_producto = MOC.prmoc_pco_produ
		AND GO1.num_operacion = MOC.prmoc_pnu_oper
		AND GO1.num_contrato = MOC.prmoc_pnu_contr
	WHERE	MOC.prmoc_pse_proces = 1
		AND MOC.prmoc_estado = 'A'
		AND ((MOC.prmoc_pcoctamay > 815)
			OR (MOC.prmoc_pcoctamay < 815))
		AND ((MOC.prmoc_psa_actual > 0)
			OR (MOC.prmoc_psa_actual < 0))

	/*Se obtienen todos los contratos vigentes*/
	INSERT	INTO #TEMP_MCA_CONTRATOS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, cod_operacion, cod_contrato)
	SELECT	MCA.prmca_pco_ofici, MCA.prmca_pco_moned, 10 AS prmca_pco_produc, MCA.prmca_pnu_contr, TMP.cod_operacion, GO1.cod_operacion
	FROM	dbo.GAR_SICC_PRMCA MCA
		INNER JOIN dbo.GAR_SICC_PRMOC MOC
		ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN #TEMP_MOC_OPERACIONES TMP
		ON TMP.prmoc_pco_ofici = MOC.prmoc_pco_oficon
		AND TMP.prmoc_pco_moned = MOC.prmoc_pcomonint
		AND TMP.prmoc_pnu_contr = MOC.prmoc_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GO1.cod_oficina = MCA.prmca_pco_ofici
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.cod_producto = MCA.prmca_pco_produc
		AND GO1.num_contrato = MCA.prmca_pnu_contr
	WHERE	MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera
		AND MOC.prmoc_pse_proces = 1
		AND MOC.prmoc_estado = 'A'
		AND MOC.prmoc_pnu_contr > 0
		AND ((MOC.prmoc_pcoctamay > 815)
			OR (MOC.prmoc_pcoctamay < 815))
		AND ((MOC.prmoc_psa_actual > 0)
			OR (MOC.prmoc_psa_actual < 0))
		AND TMP.prmoc_pnu_oper IS NULL
		AND GO1.num_operacion IS NULL
	
	/*Se obtienen todos los contratos vencidos con giros activos*/
		
	INSERT	INTO #TEMP_MCA_GIROS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, cod_operacion, cod_contrato)
	SELECT	MCA.prmca_pco_ofici, MCA.prmca_pco_moned, 10 AS prmca_pco_produc, MCA.prmca_pnu_contr, TMP.cod_operacion, GO1.cod_operacion
	FROM	dbo.GAR_SICC_PRMCA MCA
		INNER JOIN dbo.GAR_SICC_PRMOC MOC
		ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN #TEMP_MOC_OPERACIONES TMP
		ON TMP.prmoc_pco_ofici = MOC.prmoc_pco_oficon
		AND TMP.prmoc_pco_moned = MOC.prmoc_pcomonint
		AND TMP.prmoc_pnu_contr = MOC.prmoc_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GO1.cod_oficina = MCA.prmca_pco_ofici
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.cod_producto = MCA.prmca_pco_produc
		AND GO1.num_contrato = MCA.prmca_pnu_contr
	WHERE	MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
		AND MOC.prmoc_pse_proces = 1
		AND MOC.prmoc_estado = 'A'
		AND MOC.prmoc_pnu_contr > 0
		AND ((MOC.prmoc_pcoctamay > 815)
			OR (MOC.prmoc_pcoctamay < 815))
		AND ((MOC.prmoc_psa_actual > 0)
			OR (MOC.prmoc_psa_actual < 0))
		AND TMP.prmoc_pnu_oper IS NULL
		AND GO1.num_operacion IS NULL


	--Se cargan las garantías fiduciaras activas asociadas a un contrato, según el SICC
	INSERT	#TEMP_GARANTIAS_VALOR (cod_operacion, cod_contrato, cod_garantia_valor, prmgt_pmoresgar, prmgt_pco_mongar)
	SELECT	TMP.cod_operacion, -1 AS cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_MOC_OPERACIONES TMP
		ON TMP.cod_operacion = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ < 10
		AND MGT.prmgt_pco_produ > 10
		AND MGT.prmgt_pcoclagar >= 20 
		AND MGT.prmgt_pcoclagar <= 29
		AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
	GROUP BY TMP.cod_operacion, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar

	UNION ALL

	SELECT	TMC.cod_operacion, TMC.cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_MCA_CONTRATOS TMC
		ON TMC.cod_contrato = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar >= 20 
		AND MGT.prmgt_pcoclagar <= 29
		AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
	GROUP BY TMC.cod_operacion, TMC.cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar

	UNION ALL
	
	SELECT	TMC.cod_operacion, TMC.cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_MCA_GIROS TMC
		ON TMC.cod_contrato = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar >= 20 
		AND MGT.prmgt_pcoclagar <= 29
		AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
	GROUP BY TMC.cod_operacion, TMC.cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar

	--Se insertan las garantias de valor
	INSERT INTO dbo.GAR_GIROS_GARANTIAS_VALOR
	SELECT	GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
			GGV.numero_seguridad, 
			GVO.cod_tipo_mitigador, 
			GVO.cod_tipo_documento_legal, 
			GVO.monto_mitigador, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GVO.fecha_presentacion_registro, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GVO.fecha_presentacion_registro AS DATE),103), '')
			END AS fecha_presentacion, 
			GVO.cod_inscripcion, 
			GVO.porcentaje_responsabilidad, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GGV.fecha_constitucion, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GGV.fecha_constitucion AS DATE),103), '')
			END AS fecha_constitucion, 
			GVO.cod_grado_gravamen, 
			GVO.cod_grado_prioridades, 
			GVO.monto_prioridades, 
			GVO.cod_tipo_acreedor, 
			GVO.cedula_acreedor, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GGV.fecha_vencimiento_instrumento, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GGV.fecha_vencimiento_instrumento AS DATE),103), '')
			END AS fecha_vencimiento, 
			GVO.cod_operacion_especial, 
			GGV.cod_clasificacion_instrumento, 
			GGV.des_instrumento, 
			GGV.des_serie_instrumento, 
			GGV.cod_tipo_emisor, 
			GGV.cedula_emisor, 
			GGV.premio, 
			GGV.cod_isin, 
			GGV.valor_facial, 
			GGV.cod_moneda_valor_facial, 
			GGV.valor_mercado, 
			GGV.cod_moneda_valor_mercado,
			TGV.prmgt_pmoresgar AS monto_responsabilidad,
			TGV.prmgt_pco_mongar AS cod_moneda_garantia,
			GO1.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici AS oficina_deudor
	FROM	GAR_OPERACION GO1 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GO1.cod_operacion = GVO.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR GGV
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor 
		INNER JOIN #TEMP_GARANTIAS_VALOR TGV
		ON TGV.cod_operacion = GVO.cod_operacion
		AND TGV.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN GAR_DEUDOR GD1
		ON GO1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC MPC	
		ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident
		AND MPC.bsmpc_estado = 'A'
	WHERE	COALESCE(GO1.num_operacion, 0) > 0  
		AND GO1.cod_estado = 1 
		AND GVO.cod_estado = 1
		AND COALESCE(GVO.cod_tipo_documento_legal, -1) > -1
		AND (((GGV.cod_clase_garantia = 20) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))) OR 
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia < 20) OR (GGV.cod_clase_garantia > 20))) OR
			 (((GGV.cod_clase_garantia < 20) OR (GGV.cod_clase_garantia > 20)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		AND TGV.cod_contrato = -1
	GROUP BY GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion, 
			GGV.numero_seguridad, 
			GVO.cod_tipo_mitigador, 
			GVO.cod_tipo_documento_legal, 
			GVO.monto_mitigador, 
			GVO.fecha_presentacion_registro, 
			GVO.cod_inscripcion, 
			GVO.porcentaje_responsabilidad, 
			GGV.fecha_constitucion,  
			GVO.cod_grado_gravamen, 
			GVO.cod_grado_prioridades, 
			GVO.monto_prioridades, 
			GVO.cod_tipo_acreedor, 
			GVO.cedula_acreedor, 
			GGV.fecha_vencimiento_instrumento, 
			GVO.cod_operacion_especial, 
			GGV.cod_clasificacion_instrumento, 
			GGV.des_instrumento, 
			GGV.des_serie_instrumento, 
			GGV.cod_tipo_emisor, 
			GGV.cedula_emisor, 
			GGV.premio, 
			GGV.cod_isin, 
			GGV.valor_facial, 
			GGV.cod_moneda_valor_facial, 
			GGV.valor_mercado, 
			GGV.cod_moneda_valor_mercado,
			TGV.prmgt_pmoresgar,
			TGV.prmgt_pco_mongar,
			GO1.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici



	INSERT	INTO dbo.GAR_GIROS_GARANTIAS_VALOR
	SELECT	GO2.cod_contabilidad, 
			GO2.cod_oficina, 
			GO2.cod_moneda, 
			GO2.cod_producto, 
			GO2.num_operacion AS operacion, 
			GGV.numero_seguridad, 
			GVO.cod_tipo_mitigador, 
			GVO.cod_tipo_documento_legal, 
			GVO.monto_mitigador, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GVO.fecha_presentacion_registro, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GVO.fecha_presentacion_registro AS DATE),103), '')
			END AS fecha_presentacion, 
			GVO.cod_inscripcion, 
			GVO.porcentaje_responsabilidad, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GGV.fecha_constitucion, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GGV.fecha_constitucion AS DATE),103), '')
			END AS fecha_constitucion, 
			GVO.cod_grado_gravamen, 
			GVO.cod_grado_prioridades, 
			GVO.monto_prioridades, 
			GVO.cod_tipo_acreedor, 
			GVO.cedula_acreedor, 
			CASE
				WHEN  CONVERT(VARCHAR, CAST(COALESCE(GGV.fecha_vencimiento_instrumento, '19000101') AS DATE), 103) = '01/01/1900' THEN ''
				ELSE  COALESCE(CONVERT(VARCHAR,CAST(GGV.fecha_vencimiento_instrumento AS DATE),103), '')
			END AS fecha_vencimiento, 
			GVO.cod_operacion_especial, 
			GGV.cod_clasificacion_instrumento, 
			GGV.des_instrumento, 
			GGV.des_serie_instrumento, 
			GGV.cod_tipo_emisor, 
			GGV.cedula_emisor, 
			GGV.premio, 
			GGV.cod_isin, 
			GGV.valor_facial, 
			GGV.cod_moneda_valor_facial, 
			GGV.valor_mercado, 
			GGV.cod_moneda_valor_mercado,
			TGV.prmgt_pmoresgar AS monto_responsabilidad,
			TGV.prmgt_pco_mongar AS cod_moneda_garantia,
			GO2.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici AS oficina_deudor
	FROM	GAR_OPERACION GO1 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GO1.cod_operacion = GVO.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR GGV
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor 
		INNER JOIN #TEMP_GARANTIAS_VALOR TGV
		ON TGV.cod_contrato = GVO.cod_operacion
		AND TGV.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_OPERACION GO2
		ON GO2.cod_operacion = TGV.cod_operacion
		INNER JOIN GAR_DEUDOR GD1
		ON GO2.cedula_deudor = GD1.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC MPC	
		ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident
	WHERE	COALESCE(GO1.num_operacion, 0) > 0  
		AND GO1.cod_estado = 1 
		AND GVO.cod_estado = 1
		AND COALESCE(GVO.cod_tipo_documento_legal, -1) > -1
		AND (((GGV.cod_clase_garantia = 20) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))) OR 
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia < 20) OR (GGV.cod_clase_garantia > 20))) OR
			 (((GGV.cod_clase_garantia < 20) OR (GGV.cod_clase_garantia > 20)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		--AND ((GGV.cod_clase_garantia = 20 AND GGV.cod_tenencia <> 6) OR 
		--	 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia = 6) OR
		--	 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia <> 6))
		AND TGV.cod_contrato > -1
		AND MPC.bsmpc_estado = 'A'
	GROUP BY GO2.cod_contabilidad, 
			GO2.cod_oficina, 
			GO2.cod_moneda, 
			GO2.cod_producto, 
			GO2.num_operacion, 
			GGV.numero_seguridad, 
			GVO.cod_tipo_mitigador, 
			GVO.cod_tipo_documento_legal, 
			GVO.monto_mitigador, 
			GVO.fecha_presentacion_registro, 
			GVO.cod_inscripcion, 
			GVO.porcentaje_responsabilidad, 
			GGV.fecha_constitucion, 
			GVO.cod_grado_gravamen, 
			GVO.cod_grado_prioridades, 
			GVO.monto_prioridades, 
			GVO.cod_tipo_acreedor, 
			GVO.cedula_acreedor, 
			GGV.fecha_vencimiento_instrumento, 
			GVO.cod_operacion_especial, 
			GGV.cod_clasificacion_instrumento, 
			GGV.des_instrumento, 
			GGV.des_serie_instrumento, 
			GGV.cod_tipo_emisor, 
			GGV.cedula_emisor, 
			GGV.premio, 
			GGV.cod_isin, 
			GGV.valor_facial, 
			GGV.cod_moneda_valor_facial, 
			GGV.valor_mercado, 
			GGV.cod_moneda_valor_mercado,
			TGV.prmgt_pmoresgar,
			TGV.prmgt_pco_mongar,
			GO2.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici;


	/*Se eliminan los registros de duplicados*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_documento_legal, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_documento_legal, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_documento_legal  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_documento_legal DESC) AS cantidadRegistrosDuplicados
		FROM	dbo.GAR_GIROS_GARANTIAS_VALOR
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


	/*Se actualiza a NULL el valor del porcentaje de aceptación y el porcentaje de responsabilidad cuando este es menor o igual a -1*/
	UPDATE	dbo.GAR_GIROS_GARANTIAS_VALOR 
	SET		porcentaje_responsabilidad = NULL
	WHERE	porcentaje_responsabilidad <= -1

	/***************************************************************************************************************************************************/

	--INICIO RQ: 2016012710534870
	INSERT INTO dbo.SICAD_VALORES (	ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, PREMIO, 
									COD_ISIN, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, 
									FECHA_VENCIMIENTO)
	SELECT	GGV.cod_isin,
			GGV.cod_clasificacion_instrumento,
			GGV.cod_tipo_emisor,
			GGV.cedula_emisor,
			GGV.des_instrumento,
			GGV.des_serie_instrumento,
			GGV.premio,
			GGV.cod_isin,
			GGV.valor_facial,
			GGV.cod_moneda_valor_facial,
			GGV.valor_mercado,
			GGV.cod_moneda_valor_mercado,
			GGV.fecha_constitucion,
			GGV.fecha_vencimiento
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_VALORES SV1
		ON SV1.ID_GARANTIA_VALOR = GGV.cod_isin
		AND SV1.CLASIFICACION_INSTRUMENTO = GGV.cod_clasificacion_instrumento
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND COALESCE(GGV.cod_tipo_documento_legal, -1) > -1
		AND	SV1.ID_GARANTIA_VALOR IS NULL
		AND SV1.CLASIFICACION_INSTRUMENTO IS NULL


	INSERT INTO dbo.SICAD_GAROPER (ID_OPERACION, FECHA_PROCESO)
	SELECT  CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)),
			GETDATE() 
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_GAROPER SG1
		ON SG1.ID_OPERACION = (CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)))
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND COALESCE(GGV.cod_tipo_documento_legal, -1) > -1      
		AND SG1.ID_OPERACION IS NULL

	
	INSERT INTO dbo.SICAD_GAROPER_LISTA (ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR,  
										 VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION)
	SELECT  CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)),
			3,
			GGV.cod_isin,
			GGV.cod_tipo_mitigador,
			GGV.cod_tipo_documento_legal, 
			GGV.monto_mitigador,
			GGV.valor_facial,
			GGV.cod_moneda_valor_facial,
			GGV.porcentaje_responsabilidad
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_GAROPER_LISTA SGL
		ON SGL.ID_OPERACION = (CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)))
		AND SGL.ID_GARANTIA = GGV.cod_isin
		AND SGL.TIPO_GARANTIA = 3
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND COALESCE(GGV.cod_tipo_documento_legal, -1) > -1 
		AND SGL.ID_OPERACION IS NULL
		AND SGL.ID_GARANTIA IS NULL
		AND SGL.TIPO_GARANTIA IS NULL

	--FIN RQ: 2016012710534870

	/***************************************************************************************************************************************************/
	
	SELECT
			cod_contabilidad AS CONTABILIDAD, 
			cod_oficina AS OFICINA, 
			cod_moneda AS MONEDA, 
			cod_producto AS PRODUCTO, 
			operacion AS OPERACION, 
			numero_seguridad AS NUMERO_SEGURIDAD, 
			cod_tipo_mitigador AS TIPO_MITIGADOR, 
			cod_tipo_documento_legal AS TIPO_DOCUMENTO_LEGAL, 
			monto_mitigador AS MONTO_MITIGADOR,  
			fecha_presentacion AS FECHA_PRESENTACION, 
			cod_inscripcion AS INDICADOR_INSCRIPCION, 
			porcentaje_responsabilidad as PORCENTAJE_RESPONSABILIDAD, 
			fecha_constitucion AS FECHA_CONSTITUCION, 
			cod_grado_gravamen AS GRADO_GRAVAMEN, 
			cod_grado_prioridades AS GRADO_PRIORIDAD, 
			monto_prioridades AS MONTO_PRIORIDAD, 
			cod_tipo_acreedor AS TIPO_PERSONA_ACREEDOR, 
			cedula_acreedor AS CEDULA_ACREEDOR, 
			fecha_vencimiento AS FECHA_VENCIMIENTO, 
			cod_operacion_especial AS OPERACION_ESPECIAL, 
			cod_clasificacion_instrumento AS CLASIFICACION_INSTRUMENTO,
			des_instrumento AS INSTRUMENTO, 
			des_serie_instrumento AS SERIE_INSTRUMENTO, 
			cod_tipo_emisor AS TIPO_PERSONA_EMISOR, 
			cedula_emisor AS CEDULA_EMISOR, 
			premio AS PREMIO, 
			cod_isin AS ISIN, 
			valor_facial AS VALOR_FACIAL,
			cod_moneda_valor_facial AS MONEDA_VALOR_FACIAL, 
			valor_mercado AS VALOR_MERCADO, 
			cod_moneda_valor_mercado AS MONEDA_VALOR_MERCADO, 
			monto_responsabilidad AS MONTO_RESPONSABILIDAD, 
			cod_moneda_garantia AS MONEDA_GARANTIA, 
			cedula_deudor AS CEDULA_DEUDOR, 
			nombre_deudor AS NOMBRE_DEUDOR, 
			oficina_deudor AS OFICINA_DEUDOR
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR 
	WHERE	COALESCE(cod_tipo_documento_legal, -1) > -1
	
END
