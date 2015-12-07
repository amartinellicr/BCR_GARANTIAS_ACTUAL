USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasValorContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasValorContratos;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasValorContratos] 
	@psCedula_Usuario VARCHAR(30)
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasValorContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento almacenado que obtiene la información referente a las garantías de valor relacionadas a los contratos vigentes o
			 vencidos pero que poseen al menos un giro activo.
</Descripción>
<Entradas>
	@psCedula_Usuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>17/11/2010</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
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
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/

BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	
	DECLARE @vdtFecha_Actual_Sin_Hora DATETIME,
			@viFecha_Actual_Entera INT

	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Actual_Entera =  CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Actual_Sin_Hora, 112))

	/*Esta tabla almacenará los contratos vigentes según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VIGENTES (cod_operacion BIGINT)
		 
	CREATE INDEX TEMP_CONTRATOS_VIGENTES_IX_01 ON #TEMP_CONTRATOS_VIGENTES (cod_operacion)
	
	/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion BIGINT)
		 
	CREATE INDEX TEMP_CONTRATOS_VENCIDOS_GA_IX_01 ON #TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion)
				
	/*Esta tabla almacenará los giros activos según el SICC*/
	CREATE TABLE #TEMP_GIROS_ACTIVOS (	prmoc_pco_oficon SMALLINT,
										prmoc_pcomonint SMALLINT,
										prmoc_pnu_contr INT)
		 
	CREATE INDEX TEMP_GIROS_ACTIVOS_IX_01 ON #TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)

	/*Esta tabla almacenará las garantías de valor activas según el SICC*/
	CREATE TABLE #TEMP_GARANTIAS_VALOR (cod_operacion BIGINT, cod_garantia_valor BIGINT, prmgt_pmoresgar DECIMAL(14, 2), prmgt_pco_mongar TINYINT)
		 
	CREATE INDEX TEMP_GARANTIAS_VALOR_IX_01 ON #TEMP_GARANTIAS_VALOR (cod_operacion, cod_garantia_valor)

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 3 AND cod_usuario = @psCedula_Usuario

	--Se carga la tabla temporal de giros activos
	INSERT	#TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)
	SELECT	DISTINCT MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMOC MOC 
		ON	MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta	= GO1.cod_contabilidad
		AND MOC.prmoc_pnu_contr = GO1.num_contrato
	WHERE	MOC.prmoc_pse_proces = 1 
		AND MOC.prmoc_estado = 'A'
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))
		AND ((MOC.prmoc_psa_actual < 0)
			OR (MOC.prmoc_psa_actual > 0))
		AND GO1.num_operacion IS NOT NULL 
		AND GO1.num_contrato > 0
		

	--Se carga la tabla temporal de contratos vigentes
	INSERT	#TEMP_CONTRATOS_VIGENTES (cod_operacion)
	SELECT	DISTINCT GO1.cod_operacion
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON GO1.cod_contabilidad = MCA.prmca_pco_conta
		AND GO1.cod_oficina = MCA.prmca_pco_ofici 
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.num_contrato = MCA.prmca_pnu_contr
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera 

	--Se carga la tabla temporal de contratos vencidos (con giros activos)
	INSERT	#TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion)
	SELECT	DISTINCT GO1.cod_operacion
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON GO1.cod_contabilidad = MCA.prmca_pco_conta
		AND GO1.cod_oficina = MCA.prmca_pco_ofici 
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.num_contrato = MCA.prmca_pnu_contr
		INNER JOIN #TEMP_GIROS_ACTIVOS TGA
		ON MCA.prmca_pnu_contr = TGA.prmoc_pnu_contr
		AND MCA.prmca_pco_ofici = TGA.prmoc_pco_oficon
		AND MCA.prmca_pco_moned = TGA.prmoc_pcomonint
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera 

	--Se cargan las garantías fiduciaras activas asociadas a un contrato, según el SICC
	INSERT	#TEMP_GARANTIAS_VALOR (cod_operacion, cod_garantia_valor, prmgt_pmoresgar, prmgt_pco_mongar)
	SELECT	DISTINCT TCV.cod_operacion, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
		ON TCV.cod_operacion = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar IN (2,3,4,6)

	UNION ALL

	SELECT	DISTINCT TCV.cod_operacion, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_CONTRATOS_VIGENTES TCV
		ON TCV.cod_operacion = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar IN (2,3,4,6)


	/*Se obtienen los contratos vencidos o no que poseen al menos un giro activo y que tenga relacionada al menos una garantía de valor*/
	INSERT INTO TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido,
								ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
		GO1.cod_operacion, 
		GVO.cod_garantia_valor,
		3 AS cod_tipo_garantia,
		2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
		0 AS ind_contrato_vencido,
		0 AS ind_contrato_vencido_giros_activos,
		@psCedula_Usuario AS cod_usuario
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_CONTRATOS_VIGENTES TCV
		ON GO1.cod_operacion = TCV.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GO1.cod_operacion = GVO.cod_operacion
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		
		
	INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido,
									 ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
		GO1.cod_operacion, 
		GVO.cod_garantia_valor,
		3 AS cod_tipo_garantia,
		2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
		1 AS ind_contrato_vencido,
		1 AS ind_contrato_vencido_giros_activos,
		@psCedula_Usuario AS cod_usuario
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
		ON GO1.cod_operacion = TCV.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GO1.cod_operacion = GVO.cod_operacion
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0

	/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
	UPDATE	dbo.TMP_OPERACIONES 
	SET		cod_estado_garantia = 1
	FROM	dbo.TMP_OPERACIONES TMP
		INNER JOIN #TEMP_GARANTIAS_VALOR TGV
		ON TGV.cod_garantia_valor = TMP.cod_garantia
	WHERE	TMP.cod_tipo_operacion = 2
		AND TMP.cod_tipo_garantia = 3
		AND TMP.cod_usuario = @psCedula_Usuario

	/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
	DELETE  FROM dbo.TMP_OPERACIONES 
	WHERE	cod_estado_garantia = 0 
		AND cod_tipo_operacion = 2 
		AND cod_tipo_garantia = 3
		AND cod_usuario = @psCedula_Usuario 


	/*Se selecciona la información de la garantía de valor asociada a los contratos*/
	INSERT	INTO dbo.TMP_GARANTIAS_VALOR
	SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_contrato AS operacion, 
			GGV.numero_seguridad, 
			GVO.cod_tipo_mitigador, 
			GVO.cod_tipo_documento_legal, 
			GVO.monto_mitigador, 
			CASE WHEN CONVERT(VARCHAR(10),GVO.fecha_presentacion_registro,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GVO.fecha_presentacion_registro,103)
			END AS fecha_presentacion, 
			GVO.cod_inscripcion, 
			GVO.porcentaje_responsabilidad, 
			CASE WHEN CONVERT(VARCHAR(10),GGV.fecha_constitucion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GGV.fecha_constitucion,103)
			end AS fecha_constitucion, 
			GVO.cod_grado_gravamen, 
			GVO.cod_grado_prioridades, 
			GVO.monto_prioridades, 
			GVO.cod_tipo_acreedor, 
			GVO.cedula_acreedor, 
			CASE WHEN CONVERT(VARCHAR(10),GGV.fecha_vencimiento_instrumento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GGV.fecha_vencimiento_instrumento,103)
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
			NULL AS cod_tipo_garantia,
			NULL AS cod_clase_garantia,
			NULL AS cod_tenencia,
			NULL AS fecha_prescripcion,
			GVO.cod_garantia_valor,
			GO1.cod_operacion,
			1 AS cod_estado,
			TMP.cod_tipo_operacion,	
			TMP.ind_contrato_vencido AS ind_operacion_vencida,
			1 AS ind_duplicidad,
			TMP.cod_usuario,
			GVO.Porcentaje_Aceptacion
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
		ON GO1.cod_operacion = GO1.cod_operacion 
		INNER JOIN dbo.TMP_OPERACIONES TMP
		ON TMP.cod_operacion = GO1.cod_operacion
		AND TMP.cod_garantia = GVO.cod_garantia_valor
		INNER JOIN dbo.GAR_GARANTIA_VALOR GGV 
		ON GGV.cod_garantia_valor = TMP.cod_garantia 
		LEFT OUTER JOIN  #TEMP_GARANTIAS_VALOR TGV
		ON TGV.cod_operacion = GVO.cod_operacion
		AND TGV.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_DEUDOR GD1	
		ON GO1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC
		ON MPC.bsmpc_sco_ident = GD1.Identificacion_Sicc
	WHERE	TMP.cod_tipo_garantia = 3
		AND TMP.cod_usuario = @psCedula_Usuario
		AND TMP.cod_tipo_operacion = 2
		AND ((GGV.cod_clase_garantia = 20 AND GGV.cod_tenencia <> 6) OR 
			 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia = 6) OR
			 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia <> 6))
	ORDER	BY
			GO1.cod_contabilidad,
			GO1.cod_oficina,	
			GO1.cod_moneda,
			GO1.cod_producto,
			operacion,
			GGV.numero_seguridad,
			GVO.cod_tipo_documento_legal DESC



	/*Se eliminan los registros incompletos*/
	DELETE	FROM dbo.TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_operacion = 2
		AND COALESCE(cod_tipo_documento_legal, -1) = -1
		AND LEN(fecha_presentacion) = 0
		AND COALESCE(cod_tipo_mitigador, -1) = -1
		AND COALESCE(cod_inscripcion, -1) = -1

	/*Se eliminan los registros de seguridades duplicadas*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad,
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_VALOR
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion = 2
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1
	
	/*Se seleccionan los datos de salida para el usuario que genera la información*/
	SELECT	cod_contabilidad AS CONTABILIDAD, 
			cod_oficina AS OFICINA,  
			cod_moneda AS MONEDA, 
			cod_producto AS PRODUCTO, 
			operacion AS OPERACION, 
			COALESCE((CONVERT(VARCHAR(30),numero_seguridad)), '') AS NUMERO_SEGURIDAD, 
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_mitigador)), '') AS TIPO_MITIGADOR, 
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL, 
			COALESCE((CONVERT(VARCHAR(50), monto_mitigador)), '') AS MONTO_MITIGADOR,  
			COALESCE((CONVERT(VARCHAR(10),fecha_presentacion,103)), '') AS FECHA_PRESENTACION, 
			COALESCE((CONVERT(VARCHAR(3),cod_inscripcion)), '') AS INDICADOR_INSCRIPCION, 
			COALESCE((CONVERT(VARCHAR(50), porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD, 
			COALESCE((CONVERT(VARCHAR(10),fecha_constitucion,103)), '') AS FECHA_CONSTITUCION, 
			COALESCE((CONVERT(VARCHAR(3),cod_grado_gravamen)), '') AS GRADO_GRAVAMEN, 
			COALESCE((CONVERT(VARCHAR(3),cod_grado_prioridades)), '') AS GRADO_PRIORIDAD, 
			COALESCE((CONVERT(VARCHAR(50), monto_prioridades)), '') AS MONTO_PRIORIDAD, 
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR, 
			COALESCE(cedula_acreedor, '') AS CEDULA_ACREEDOR, 
			COALESCE((CONVERT(VARCHAR(10),fecha_vencimiento,103)), '') AS FECHA_VENCIMIENTO, 
			COALESCE((CONVERT(VARCHAR(3),cod_operacion_especial)), '') AS OPERACION_ESPECIAL, 
			COALESCE((CONVERT(VARCHAR(3),cod_clasificacion_instrumento)), '') AS CLASIFICACION_INSTRUMENTO,
			COALESCE(des_instrumento, '') AS INSTRUMENTO, 
			COALESCE(des_serie_instrumento, '') AS SERIE_INSTRUMENTO, 
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_emisor)), '') AS TIPO_PERSONA_EMISOR, 
			COALESCE(cedula_emisor, '') AS CEDULA_EMISOR, 
			COALESCE((CONVERT(VARCHAR(50), premio)), '') AS PREMIO, 
			COALESCE(cod_isin, '') AS ISIN, 
			COALESCE((CONVERT(VARCHAR(50), valor_facial)), '') AS VALOR_FACIAL,
			COALESCE((CONVERT(VARCHAR(3),cod_moneda_valor_facial)), '') AS MONEDA_VALOR_FACIAL, 
			COALESCE((CONVERT(VARCHAR(50), valor_mercado)), '') AS VALOR_MERCADO, 
			COALESCE((CONVERT(VARCHAR(3),cod_moneda_valor_mercado)), '') AS MONEDA_VALOR_MERCADO, 
			COALESCE((CONVERT(VARCHAR(50), monto_responsabilidad)), '') AS MONTO_RESPONSABILIDAD, 
			COALESCE((CONVERT(VARCHAR(3),cod_moneda_garantia)), '') AS MONEDA_GARANTIA, 
			COALESCE(cedula_deudor, '') AS CEDULA_DEUDOR, 
			COALESCE(nombre_deudor, '') AS NOMBRE_DEUDOR, 
			COALESCE((CONVERT(VARCHAR(5),oficina_deudor)), '') AS OFICINA_DEUDOR,
			ind_operacion_vencida AS ES_CONTRATO_VENCIDO
	FROM	dbo.TMP_GARANTIAS_VALOR 
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_operacion = 2
	ORDER BY operacion

END
