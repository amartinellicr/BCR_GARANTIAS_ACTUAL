USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarGarantiasValorInfoCompleta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarGarantiasValorInfoCompleta;
GO

CREATE PROCEDURE [dbo].[pa_GenerarGarantiasValorInfoCompleta] 
	@psCedula_Usuario VARCHAR(30)
AS

/******************************************************************
<Nombre>pa_GenerarGarantiasValorInfoCompleta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la información necesaria para generar el archivo SEGUI. 
			 Se implementan nuevos criterios de selección de la información.
</Descripción>
<Entradas>
	@psCedula_Usuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>18/11/2010</Fecha>
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

	/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
	DECLARE	@vdtFecha_Actual_Sin_Hora DATETIME,
			@viFecha_Actual_Entera INT


	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Actual_Entera =  CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Actual_Sin_Hora, 112))
	
	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM dbo.TMP_GARANTIAS_VALOR WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_operacion IN (1, 3)
	DELETE FROM dbo.TMP_OPERACIONES WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion IN (1, 3) 


	/*Esta tabla servirá para almacenar los datos de la estructura PRMOC*/
	CREATE TABLE #TEMP_PRMOC (cod_operacion BIGINT, Indicador_Es_Giro BIT)

	CREATE INDEX TEMP_PRMOC_IX_01 ON #TEMP_PRMOC (cod_operacion, Indicador_Es_Giro)

	/*Esta tabla almacenará los contratos vigentes según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato BIGINT, Cod_Operacion_Giro BIGINT)
		 
	CREATE INDEX TEMP_CONTRATOS_VIGENTES_IX_01 ON #TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato, Cod_Operacion_Giro)
	
	/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato BIGINT, Cod_Operacion_Giro BIGINT)
		 
	CREATE INDEX TEMP_CONTRATOS_VENCIDOS_GA_IX_01 ON #TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato, Cod_Operacion_Giro)
				
	/*Esta tabla almacenará los giros activos según el SICC*/
	CREATE TABLE #TEMP_GIROS_ACTIVOS (	prmoc_pco_oficon SMALLINT,
										prmoc_pcomonint SMALLINT,
										prmoc_pnu_contr INT,
										cod_operacion BIGINT)
		 
	CREATE INDEX TEMP_GIROS_ACTIVOS_IX_01 ON #TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)

	/*Esta tabla almacenará las garantías de valor activas según el SICC*/
	CREATE TABLE #TEMP_GARANTIAS_VALOR (cod_operacion BIGINT, cod_garantia_valor BIGINT, prmgt_pmoresgar DECIMAL(14, 2), prmgt_pco_mongar TINYINT)
		 
	CREATE INDEX TEMP_GARANTIAS_VALOR_IX_01 ON #TEMP_GARANTIAS_VALOR (cod_operacion, cod_garantia_valor)

	/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
	INSERT	#TEMP_PRMOC (cod_operacion, Indicador_Es_Giro)
	SELECT	DISTINCT GO1.cod_operacion,
			CASE 
				WHEN GO1.num_contrato = 0 THEN 0
				ELSE 1
			END AS Indicador_Es_Giro
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


	--Se carga la tabla temporal de giros activos
	INSERT	#TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr, cod_operacion)
	SELECT	DISTINCT MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr, GO1.cod_operacion
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
		

	--Se carga la tabla temporal de contratos vigentes con giros activos
	INSERT	#TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato, Cod_Operacion_Giro)
	SELECT	DISTINCT GO1.cod_operacion AS Cod_Operacion_Contrato, TGA.cod_operacion AS Cod_Operacion_Giro
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON GO1.cod_contabilidad = MCA.prmca_pco_conta
		AND GO1.cod_oficina = MCA.prmca_pco_ofici 
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.num_contrato = MCA.prmca_pnu_contr
		INNER JOIN #TEMP_GIROS_ACTIVOS TGA
		ON TGA.prmoc_pnu_contr = MCA.prmca_pnu_contr
		AND TGA.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND TGA.prmoc_pcomonint = MCA.prmca_pco_moned
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera 

	--Se carga la tabla temporal de contratos vencidos (con giros activos)
	INSERT	#TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato, Cod_Operacion_Giro)
	SELECT	DISTINCT GO1.cod_operacion AS Cod_Operacion_Contrato, TGA.cod_operacion AS Cod_Operacion_Giro
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

	--Se cargan las garantías de valor activas asociadas a un contrato, según el SICC
	INSERT	#TEMP_GARANTIAS_VALOR (cod_operacion, cod_garantia_valor, prmgt_pmoresgar, prmgt_pco_mongar)
	SELECT	DISTINCT MOC.cod_operacion, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar

	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_PRMOC MOC
		ON MOC.cod_operacion = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar IN (2,3,4,6)
		AND MOC.Indicador_Es_Giro = 0

	UNION ALL

	SELECT	DISTINCT TCV.Cod_Operacion_Contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
		ON TCV.Cod_Operacion_Contrato = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar IN (2,3,4,6)

	UNION ALL

	SELECT	DISTINCT TCV.Cod_Operacion_Contrato, GGV.cod_garantia_valor, MGT.prmgt_pmoresgar, MGT.prmgt_pco_mongar
	FROM	dbo.GAR_GARANTIA_VALOR GGV
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcotengar = GGV.cod_tenencia
		INNER JOIN #TEMP_CONTRATOS_VIGENTES TCV
		ON TCV.Cod_Operacion_Contrato = GVO.cod_operacion
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar IN (2,3,4,6)


	/*Se carga la tabla temporal la información de aquellas operaciones que posean una garantía de valor asociada*/	
	INSERT INTO dbo.TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido,
									 ind_contrato_vencido_giros_activos, cod_usuario)

	SELECT	DISTINCT 
			GVA.cod_operacion, 
			GVA.cod_garantia_valor,
			3 AS cod_tipo_garantia,
			1 AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_PRMOC MOC
		ON MOC.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVA
		ON MOC.cod_operacion = GVA.cod_operacion
	WHERE	MOC.Indicador_Es_Giro = 0
		AND GVA.cod_estado = 1 

	
	/*Se obtienen los giros activos de contratos vigentes y las garantías relacionadas a estos*/
	INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										cod_tipo_operacion, ind_contrato_vencido,
										ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
			MCA.Cod_Operacion_Giro, 
			GVA.cod_garantia_valor,
			3 AS cod_tipo_garantia,
			3 AS cod_tipo_operacion, 
			0 AS ind_contrato_vencido,
			0 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
	FROM	#TEMP_CONTRATOS_VIGENTES MCA
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVA
		ON GVA.cod_operacion = MCA.Cod_Operacion_Contrato

	/*Se obtienen las garantías de los contratos vencidos con giros activos y se les asignan a estos giros las garantías reales de sus contratos*/
	INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										cod_tipo_operacion, ind_contrato_vencido,
										ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
			MCA.Cod_Operacion_Giro, 
			GVA.cod_garantia_valor,
			3 AS cod_tipo_garantia,
			3 AS cod_tipo_operacion, 
			1 AS ind_contrato_vencido,
			1 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
	FROM	#TEMP_CONTRATOS_VENCIDOS_GA MCA
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVA
		ON GVA.cod_operacion = MCA.Cod_Operacion_Contrato

	/*Se selecciona la información de la garantía de valor asociada a las operaciones*/
	INSERT INTO dbo.TMP_GARANTIAS_VALOR (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_mitigador,
									 cod_tipo_documento_legal, monto_mitigador, fecha_presentacion, cod_inscripcion, porcentaje_responsabilidad,
									 fecha_constitucion,  cod_grado_gravamen, cod_grado_prioridades, monto_prioridades, cod_tipo_acreedor,
									 cedula_acreedor, fecha_vencimiento, cod_operacion_especial, cod_clasificacion_instrumento, des_instrumento,
									 des_serie_instrumento, cod_tipo_emisor, cedula_emisor, premio, cod_isin, valor_facial, cod_moneda_valor_facial,
								     valor_mercado, cod_moneda_valor_mercado, monto_responsabilidad, cod_moneda_garantia, cedula_deudor, nombre_deudor,
									 oficina_deudor, cod_tipo_garantia, cod_clase_garantia, cod_tenencia, fecha_prescripcion, cod_garantia_valor,
									 cod_operacion, cod_estado, cod_tipo_operacion, ind_operacion_vencida, ind_duplicidad, cod_usuario,
									 Porcentaje_Aceptacion)

	SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
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
			GD1.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici AS oficina_deudor,
			NULL AS cod_tipo_garantia,
			NULL AS cod_clase_garantia,
			NULL AS cod_tenencia,
			NULL AS fecha_prescripcion,
			GVO.cod_garantia_valor,
			GVO.cod_operacion,
			1 AS cod_estado,
			TMP.cod_tipo_operacion,	
			NULL AS ind_operacion_vencida,
			1 AS ind_duplicidad,
			@psCedula_Usuario AS cod_usuario,
			GVO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.		
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
		ON GO1.cod_operacion = GVO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_VALOR GGV 
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor 
		INNER JOIN dbo.TMP_OPERACIONES TMP
		ON TMP.cod_operacion = GVO.cod_operacion
		AND TMP.cod_garantia = GVO.cod_garantia_valor
		LEFT OUTER JOIN #TEMP_GARANTIAS_VALOR TGV
		ON TGV.cod_operacion = GVO.cod_operacion
		AND TGV.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_DEUDOR GD1
		ON GO1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC
		ON MPC.bsmpc_sco_ident = GD1.Identificacion_Sicc
		AND MPC.bsmpc_estado = 'A'
	WHERE	GVO.cod_estado = 1
		AND ((GGV.cod_clase_garantia = 20 AND GGV.cod_tenencia <> 6) OR 
			 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia = 6) OR
			 (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia <> 6))
		AND TMP.cod_tipo_garantia = 3
		AND TMP.cod_usuario = @psCedula_Usuario 
		AND TMP.cod_tipo_operacion IN (1, 3)
	ORDER BY
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
		AND cod_tipo_operacion IN (1, 3)
		AND cod_tipo_garantia = 3
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
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia = 3
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se actualiza a NULL el valor del porcentaje de aceptación y el porcentaje de responsabilidad cuando este es menor o igual a -1*/
	UPDATE	dbo.TMP_GARANTIAS_VALOR 
	SET		porcentaje_responsabilidad = NULL
	WHERE	porcentaje_responsabilidad <= -1

	UPDATE	dbo.TMP_GARANTIAS_VALOR 
	SET		Porcentaje_Aceptacion = NULL
	WHERE	Porcentaje_Aceptacion <= -1

		
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
			COALESCE((CONVERT(VARCHAR(50), Porcentaje_Aceptacion)), '') AS PORCENTAJE_ACEPTACION, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
			ind_operacion_vencida AS ES_CONTRATO_VENCIDO, 
			COALESCE((CONVERT(VARCHAR(50), porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD
	FROM	dbo.TMP_GARANTIAS_VALOR 
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_operacion IN (1, 3)
	ORDER BY operacion

END
