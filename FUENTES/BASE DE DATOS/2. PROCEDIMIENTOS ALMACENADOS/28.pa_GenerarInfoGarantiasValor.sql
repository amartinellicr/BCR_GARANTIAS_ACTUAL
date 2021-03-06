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
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>09/12/2015</Fecha>
		<Descripción>
			El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
			crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
			cualquier lógica existente. 
		</Descripción>
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

	DECLARE @viContabilidad TINYINT,
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
	
	--SE ELIMINAN LAS GARANTIAS FIDUCIARIAS
	DELETE FROM dbo.SICAD_FIDUCIARIAS WHERE @vbIndicador_Borrar_Registros = 1
	
	--SE ELIMINAN LAS GARANTIAS REALES
	DELETE FROM dbo.SICAD_REALES WHERE @vbIndicador_Borrar_Registros = 1
	DELETE FROM dbo.SICAD_REALES_POLIZA WHERE @vbIndicador_Borrar_Registros = 1
	DELETE FROM dbo.SICAD_GAROPER_GRAVAMEN WHERE @vbIndicador_Borrar_Registros = 1

	--SE ELIMINAN LAS GARANTIAS VALOR
	DELETE FROM dbo.SICAD_VALORES WHERE @vbIndicador_Borrar_Registros = 1
	
	--SE ELIMINAN LOS DATOS COMUNES
	DELETE FROM dbo.SICAD_GAROPER WHERE  @vbIndicador_Borrar_Registros = 1
	DELETE FROM dbo.SICAD_GAROPER_LISTA WHERE @vbIndicador_Borrar_Registros = 1

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

	IF OBJECT_ID('tempdb..#TEMP_MOC_OPERACIONES') IS NOT NULL
		DROP TABLE #TEMP_MOC_OPERACIONES

	IF OBJECT_ID('tempdb..#TEMP_MCA_CONTRATOS') IS NOT NULL
		DROP TABLE #TEMP_MCA_CONTRATOS

	IF OBJECT_ID('tempdb..#TEMP_MCA_GIROS') IS NOT NULL
		DROP TABLE #TEMP_MCA_GIROS

	IF OBJECT_ID('tempdb..#TEMP_GARANTIAS_VALOR') IS NOT NULL
		DROP TABLE #TEMP_GARANTIAS_VALOR

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
						
		/*Se obtienen todos los contratos vigentes con giros activos*/
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


	--Se cargan las garantías de valor activas asociadas a una operación, según el SICC
	INSERT	#TEMP_GARANTIAS_VALOR (cod_operacion, cod_contrato, cod_garantia_valor, prmgt_pmoresgar, prmgt_pco_mongar)
	SELECT	TMP.cod_operacion, -1 AS cod_contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		INNER JOIN #TEMP_MOC_OPERACIONES TMP
		ON TMP.cod_operacion = GVO.cod_operacion
	WHERE	(((GGV.cod_clase_garantia = 20) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))) OR 
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29))) OR
			 (((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		AND MGT.prmgt_estado = 'A'
		AND ((MGT.prmgt_pco_produ < 10)
			OR (MGT.prmgt_pco_produ > 10))
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
		INNER JOIN #TEMP_MCA_CONTRATOS TMC
		ON TMC.cod_contrato = GVO.cod_operacion
	WHERE	(((GGV.cod_clase_garantia = 20) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))) OR 
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29))) OR
			 (((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		AND MGT.prmgt_estado = 'A'
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
		INNER JOIN #TEMP_MCA_GIROS TMC
		ON TMC.cod_contrato = GVO.cod_operacion
	WHERE	(((GGV.cod_clase_garantia = 20) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))) OR 
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29))) OR
			 (((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		AND MGT.prmgt_estado = 'A'
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
			MPC.bsmpc_dco_ofici AS oficina_deudor,
			GVO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29))) OR
			 (((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
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
			MPC.bsmpc_dco_ofici,
            GVO.Porcentaje_Aceptacion



	INSERT INTO dbo.GAR_GIROS_GARANTIAS_VALOR
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
			MPC.bsmpc_dco_ofici AS oficina_deudor,
			GVO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
			 ((GGV.cod_tenencia = 6) AND ((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29))) OR
			 (((GGV.cod_clase_garantia > 20) OR (GGV.cod_clase_garantia <= 29)) AND ((GGV.cod_tenencia < 6) OR (GGV.cod_tenencia > 6))))
		--AND  ((GGV.cod_clase_garantia = 20 AND GGV.cod_tenencia <> 6) OR 
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
			MPC.bsmpc_dco_ofici,
            GVO.Porcentaje_Aceptacion;


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

	UPDATE	dbo.GAR_GIROS_GARANTIAS_VALOR 
	SET		Porcentaje_Aceptacion = 0
	WHERE	Porcentaje_Aceptacion <= -1

	UPDATE	dbo.GAR_GIROS_GARANTIAS_VALOR 
	SET		cod_tipo_documento_legal = -1
	WHERE	cod_tipo_documento_legal IS NULL

	/***************************************************************************************************************************************************/

	--INICIO RQ: 2016012710534870
	INSERT INTO dbo.SICAD_VALORES (	 ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, 
									 PREMIO, COD_ISIN, TIPO_ASIGNACION_CALIFICACION, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, 
									 TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, FECHA_VENCIMIENTO)
	SELECT	GGV.cod_isin AS ID_GARANTIA_VALOR,
			GGV.cod_clasificacion_instrumento AS CLASIFICACION_INSTRUMENTO,
			GGV.cod_tipo_emisor AS TIPO_PERSONA,
			GGV.cedula_emisor AS ID_EMISOR,
			GGV.des_instrumento AS ID_INSTRUMENTO,
			GGV.des_serie_instrumento AS SERIE_INSTRUMENTO,
			GGV.premio AS PREMIO,
			GGV.cod_isin AS COD_ISIN,
			0 AS TIPO_ASIGNACION_CALIFICACION,
			COALESCE(GGV.valor_facial, 0) AS VALOR_FACIAL,
			COALESCE(GGV.cod_moneda_valor_facial, -1) AS TIPO_MONEDA_VALOR_FACIAL,
			GGV.valor_mercado AS VALOR_MERCADO,
			GGV.cod_moneda_valor_mercado AS TIPO_MONEDA_VALOR_MERCADO,
			GGV.fecha_constitucion AS FECHA_CONSTITUCION,
			GGV.fecha_vencimiento AS FECHA_VENCIMIENTO
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_VALORES SV1
		ON SV1.ID_GARANTIA_VALOR = GGV.cod_isin
		AND SV1.CLASIFICACION_INSTRUMENTO = GGV.cod_clasificacion_instrumento
		AND SV1.TIPO_PERSONA = GGV.cod_tipo_emisor
		AND SV1.ID_EMISOR = GGV.cedula_emisor
		AND SV1.ID_INSTRUMENTO = GGV.des_instrumento 
		AND SV1.SERIE_INSTRUMENTO = GGV.des_serie_instrumento 
		AND SV1.PREMIO = GGV.premio
		AND SV1.VALOR_FACIAL = GGV.valor_facial
		AND SV1.TIPO_MONEDA_VALOR_FACIAL = GGV.cod_moneda_valor_facial
		AND SV1.VALOR_MERCADO = GGV.valor_mercado
		AND SV1.TIPO_MONEDA_VALOR_MERCADO = GGV.cod_moneda_valor_mercado
		AND SV1.FECHA_CONSTITUCION = GGV.fecha_constitucion
		AND SV1.FECHA_VENCIMIENTO = GGV.fecha_vencimiento
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND GGV.cod_isin NOT LIKE 'NO'
		AND GGV.cod_tipo_documento_legal > -1
		AND	SV1.ID_GARANTIA_VALOR IS NULL
		AND SV1.CLASIFICACION_INSTRUMENTO IS NULL
		AND SV1.TIPO_PERSONA IS NULL
		AND SV1.ID_EMISOR IS NULL
		AND SV1.ID_INSTRUMENTO IS NULL
		AND SV1.SERIE_INSTRUMENTO IS NULL 
		AND SV1.PREMIO IS NULL
		AND SV1.VALOR_FACIAL IS NULL
		AND SV1.TIPO_MONEDA_VALOR_FACIAL IS NULL
		AND SV1.VALOR_MERCADO IS NULL
		AND SV1.TIPO_MONEDA_VALOR_MERCADO IS NULL
		AND SV1.FECHA_CONSTITUCION IS NULL
		AND SV1.FECHA_VENCIMIENTO IS NULL

	INSERT INTO dbo.SICAD_GAROPER (ID_OPERACION, CODIGO_EMPRESA, FECHA_PROCESO)
	SELECT  CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)) AS ID_OPERACION,
			1 AS CODIGO_EMPRESA,
			GETDATE() AS FECHA_PROCESO
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_GAROPER SG1
		ON SG1.ID_OPERACION = (CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)))
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND GGV.cod_isin NOT LIKE 'NO'
		AND GGV.cod_tipo_documento_legal > -1      
		AND SG1.ID_OPERACION IS NULL
	
      
	INSERT INTO dbo.SICAD_GAROPER_LISTA ( ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, 
										  INDICADOR_INSCRIPCION_GARANTIA, FECHA_PRESENTACION_REGISTRO_GARANTIA, PORCENTAJE_RESPONSABILIDAD_GARANTIA, 
										  VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION, FECHA_CONSTITUCION_GARANTIA, 
										  FECHA_VENCIMIENTO_GARANTIA, CODIGO_EMPRESA)
	SELECT  CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)) AS ID_OPERACION,
			3 AS TIPO_GARANTIA,
			GGV.cod_isin AS ID_GARANTIA,
			COALESCE(GGV.cod_tipo_mitigador, -1) AS TIPO_MITIGADOR,
			COALESCE(GGV.cod_tipo_documento_legal, -1) AS TIPO_DOCUMENTO_LEGAL,
			COALESCE(GGV.monto_mitigador, 0) AS MONTO_MITIGADOR,
			0 AS INDICADOR_INSCRIPCION_GARANTIA,
			COALESCE(GGV.fecha_presentacion, '19000101') AS FECHA_PRESENTACION_REGISTRO_GARANTIA,
			COALESCE(GGV.porcentaje_responsabilidad, 0) AS PORCENTAJE_RESPONSABILIDAD_GARANTIA, 
			COALESCE(GGV.valor_facial, 0) AS VALOR_NOMINAL_GARANTIA,
			COALESCE(GGV.cod_moneda_valor_facial, -1) AS TIPO_MONEDA_VALOR_NOMINAL_GARANTIA,
			COALESCE(GGV.Porcentaje_Aceptacion, 0) AS PORCENTAJE_ACEPTACION,
			COALESCE(GGV.fecha_constitucion, '19000101') AS FECHA_CONSTITUCION_GARANTIA,
			COALESCE(GGV.fecha_vencimiento, '19000101') AS FECHA_VENCIMIENTO_GARANTIA,
			1 AS CODIGO_EMPRESA
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR GGV
		LEFT OUTER JOIN dbo.SICAD_GAROPER_LISTA SGL
		ON SGL.ID_OPERACION = (CAST(GGV.cod_oficina AS VARCHAR(5)) + CAST(GGV.cod_moneda AS VARCHAR(5)) + CAST(GGV.cod_producto AS VARCHAR(5)) + CAST(GGV.operacion AS VARCHAR(20)))
		AND SGL.ID_GARANTIA = GGV.cod_isin
		AND SGL.TIPO_GARANTIA = 3
		AND SGL.TIPO_MITIGADOR = GGV.cod_tipo_mitigador
		AND SGL.TIPO_DOCUMENTO_LEGAL = GGV.cod_tipo_documento_legal
		AND SGL.MONTO_MITIGADOR = GGV.monto_mitigador
		AND SGL.FECHA_PRESENTACION_REGISTRO_GARANTIA = GGV.fecha_presentacion
		AND SGL.VALOR_NOMINAL_GARANTIA = GGV.valor_facial
		AND SGL.TIPO_MONEDA_VALOR_NOMINAL_GARANTIA = GGV.cod_moneda_valor_facial
		AND SGL.PORCENTAJE_ACEPTACION = GGV.Porcentaje_Aceptacion
		AND SGL.FECHA_CONSTITUCION_GARANTIA = GGV.fecha_constitucion
		AND SGL.FECHA_VENCIMIENTO_GARANTIA = GGV.fecha_vencimiento
	WHERE	LEN(COALESCE(GGV.cod_isin, '')) > 0 
		AND GGV.cod_isin NOT LIKE 'NO'
		AND GGV.cod_tipo_documento_legal > -1 
		AND SGL.ID_OPERACION IS NULL
		AND SGL.ID_GARANTIA IS NULL
		AND SGL.TIPO_GARANTIA IS NULL
		AND SGL.TIPO_MITIGADOR IS NULL
		AND SGL.TIPO_DOCUMENTO_LEGAL IS NULL
		AND SGL.MONTO_MITIGADOR IS NULL
		AND SGL.FECHA_PRESENTACION_REGISTRO_GARANTIA IS NULL
		AND SGL.VALOR_NOMINAL_GARANTIA IS NULL
		AND SGL.TIPO_MONEDA_VALOR_NOMINAL_GARANTIA IS NULL
		AND SGL.PORCENTAJE_ACEPTACION IS NULL
		AND SGL.FECHA_CONSTITUCION_GARANTIA IS NULL
		AND SGL.FECHA_VENCIMIENTO_GARANTIA IS NULL


	/*Se eliminan los registros de duplicados*/
	WITH GARANTIAS_VALOR (ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, 
						  PREMIO, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, FECHA_VENCIMIENTO, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, 
				PREMIO, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, FECHA_VENCIMIENTO, 
				ROW_NUMBER() OVER(PARTITION BY ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, 
						  PREMIO, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, FECHA_VENCIMIENTO
				ORDER BY ID_GARANTIA_VALOR, CLASIFICACION_INSTRUMENTO, TIPO_PERSONA, ID_EMISOR, ID_INSTRUMENTO, SERIE_INSTRUMENTO, 
						  PREMIO, VALOR_FACIAL, TIPO_MONEDA_VALOR_FACIAL, VALOR_MERCADO, TIPO_MONEDA_VALOR_MERCADO, FECHA_CONSTITUCION, FECHA_VENCIMIENTO) AS cantidadRegistrosDuplicados
		FROM	dbo.SICAD_VALORES
	)
	DELETE
	FROM GARANTIAS_VALOR
	WHERE cantidadRegistrosDuplicados > 1;

	WITH GAROPER (ID_OPERACION, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	ID_OPERACION, 
				ROW_NUMBER() OVER(PARTITION BY ID_OPERACION  ORDER BY ID_OPERACION) AS cantidadRegistrosDuplicados
		FROM	dbo.SICAD_GAROPER
	)
	DELETE
	FROM GAROPER
	WHERE cantidadRegistrosDuplicados > 1;

	WITH GAROPER_LISTA (ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, 
						VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION,
				ROW_NUMBER() OVER(PARTITION BY ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION  ORDER BY ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION) AS cantidadRegistrosDuplicados
		FROM	dbo.SICAD_GAROPER_LISTA
		WHERE	TIPO_GARANTIA = 3
	)
	DELETE
	FROM GAROPER_LISTA
	WHERE cantidadRegistrosDuplicados > 1;

 
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
			Porcentaje_Aceptacion AS PORCENTAJE_ACEPTACION, --RQ_MANT_2015111010495738_00610: Se agrega este campo. 
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
			oficina_deudor AS OFICINA_DEUDOR, 
			porcentaje_responsabilidad AS PORCENTAJE_RESPONSABILIDAD
	FROM	dbo.GAR_GIROS_GARANTIAS_VALOR 
	WHERE	cod_tipo_documento_legal > -1

END
