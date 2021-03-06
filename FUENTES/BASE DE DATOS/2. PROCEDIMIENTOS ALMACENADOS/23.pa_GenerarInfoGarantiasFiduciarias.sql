USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasFiduciarias', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasFiduciarias;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasFiduciarias] 
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasFiduciarias</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite generar la información a ser incluida en los archivos 
             SEGUI, sobre las garantías fiduciarias.
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
		<Requerimiento></Requerimiento>
		<Fecha>08/04/2008</Fecha>
		<Descripción>Permite obtener la información necesaria para generar el archivo SEGUI, se agrega el 
                     filtrado de las tarjetas que poseen garantías fiduciarias y cuyo estado sea diferente a 
                     los suministrados en el parámetro de entrada.
        </Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>04/11/2008</Fecha>
		<Descripción>Se modifica la forma en que se obtienen las garantías fiduciarias de los giros de los 
                     contratos.
		</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>24/03/2009</Fecha>
		<Descripción>Se modifica el uso de tablas temporales globales por tablas temporales locales.</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>17/11/2010</Fecha>
		<Descripción>Se realizan varios ajustes de optimización del proceso.</Descripción>
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

	SET NOCOUNT ON;

	DECLARE @viContabilidad TINYINT,
			@viOficina SMALLINT,
			@viMoneda TINYINT,
			@viProducto TINYINT,
			@viNumero_Operacion DECIMAL(7),
			@vsCedula_Fiador VARCHAR(30),
			@viTipo_Documento_Legal SMALLINT,
			@viNumero_Operacion_Anterior DECIMAL(7),
			@vsCedula_Fiador_Anterior BIGINT,
			@vbIndicador_Borrar_Registros BIT,
			@vdtFecha_Actual DATE

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

	/*Se elimina el contenido completo de la tabla*/	
	DELETE FROM dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS

	IF OBJECT_ID('tempdb..#TMP_GARANTIA_FIDUCIARIA') IS NOT NULL
		DROP TABLE #TMP_GARANTIA_FIDUCIARIA

	IF OBJECT_ID('tempdb..#TEMP_PRMOC') IS NOT NULL
		DROP TABLE #TEMP_PRMOC

	IF OBJECT_ID('tempdb..#TGIROSACTIVOS') IS NOT NULL
		DROP TABLE #TGIROSACTIVOS

	IF OBJECT_ID('tempdb..#TGARGIROSACTIVOS') IS NOT NULL
		DROP TABLE #TGARGIROSACTIVOS

	IF OBJECT_ID('tempdb..#TEMP_PRMOC_GIRO') IS NOT NULL
		DROP TABLE #TEMP_PRMOC_GIRO

	/*Esta tabla servirá para almacenar los datos de la estructura PRMOC correspondiente a operaciones activas*/
	CREATE TABLE #TEMP_PRMOC (cod_operacion BIGINT)

	CREATE INDEX TEMP_PRMOC_IX_01 ON #TEMP_PRMOC (cod_operacion)

	/*Esta tabla servirá para almacenar los datos de la estructura PRMOC correspondiente a giros*/
	CREATE TABLE #TEMP_PRMOC_GIRO (cod_operacion BIGINT)

	CREATE INDEX TEMP_PRMOC_GIRO_IX_01 ON #TEMP_PRMOC_GIRO (cod_operacion)

	/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
	INSERT	#TEMP_PRMOC (cod_operacion)
	SELECT	GO1.cod_operacion
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
		AND COALESCE(GO1.num_operacion, 0) > 0 
		AND GO1.num_contrato = 0 

	INSERT	#TEMP_PRMOC_GIRO (cod_operacion)
	SELECT	GO1.cod_operacion
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
		AND COALESCE(GO1.num_operacion, 0) > 0 
		AND GO1.num_contrato > 0 



	--Se insertan las garantias fiduciarias
	INSERT	INTO dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
	SELECT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
			GGF.cedula_fiador, 
			GGF.cod_tipo_fiador,
			NULL AS fecha_valuacion,
			0 AS ingreso_neto,
			0 AS cod_tipo_mitigador, 
			GFO.cod_tipo_documento_legal, 
			0 AS monto_mitigador, 
			GFO.porcentaje_responsabilidad, 
			GFO.cod_tipo_acreedor, 
			GFO.cedula_acreedor, 
			GFO.cod_operacion_especial,
			GGF.nombre_fiador,
			GO1.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici AS oficina_deudor,
			NULL AS cod_estado_tarjeta,
			GFO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN #TEMP_PRMOC MOC
		ON MOC.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO 
		ON GO1.cod_operacion = GFO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF 
		ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria 
		INNER JOIN dbo.GAR_DEUDOR GD1 ON GO1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC ON MPC.bsmpc_sco_ident = GD1.Identificacion_Sicc
	WHERE	GO1.cod_estado = 1 
		AND GFO.cod_estado = 1
		AND MPC.bsmpc_estado = 'A'
	GROUP BY GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion, 
			GGF.cedula_fiador, 
			GGF.cod_tipo_fiador,
			GFO.cod_tipo_documento_legal, 
			GFO.porcentaje_responsabilidad, 
			GFO.cod_tipo_acreedor, 
			GFO.cedula_acreedor, 
			GFO.cod_operacion_especial,
			GGF.nombre_fiador,
			GO1.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici,
            GFO.Porcentaje_Aceptacion
		

	--Se cargan los giros activos registrados en el sistema 
	SELECT  GO1.cod_contabilidad,
			GO1.cod_operacion, 
			GO1.cod_oficina, 
			GO1.cod_moneda,
			GO1.cod_producto, 
			GO1.num_operacion, 
			GO1.num_contrato,
			GO1.fecha_constitucion,
			GO1.fecha_vencimiento,
			GO1.cedula_deudor
	INTO	#TGIROSACTIVOS
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_PRMOC_GIRO MOC
		ON MOC.cod_operacion = GO1.cod_operacion
	WHERE	GO1.num_contrato > 0 
		AND COALESCE(GO1.num_operacion, 0) > 0 

	--Se cargan las garantías correspondientes a giros 
	SELECT	
			TGA.cod_contabilidad,
			TGA.cod_oficina,
			TGA.cod_moneda,
			TGA.cod_producto,
			TGA.num_operacion AS operacion,
			GGF.cedula_fiador,
			GGF.cod_tipo_fiador,
			0 AS ingreso_neto,
			GFO.cod_tipo_mitigador,
			GFO.cod_tipo_documento_legal,
			GFO.monto_mitigador,
			GFO.porcentaje_responsabilidad,
			GFO.cod_tipo_acreedor,
			GFO.cedula_acreedor,
			GFO.cod_operacion_especial,
			GGF.nombre_fiador,
			TGA.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici AS oficina_deudor
	INTO #TGARGIROSACTIVOS	
	FROM #TGIROSACTIVOS TGA
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO 
		ON GFO.cod_operacion = TGA.cod_operacion
		INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
		ON GGF.cod_garantia_fiduciaria = GFO.cod_garantia_fiduciaria
		INNER JOIN dbo.GAR_DEUDOR GD1
		ON GD1.cedula_deudor = TGA.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC 
		ON MPC.bsmpc_sco_ident = GD1.Identificacion_Sicc
	WHERE	GFO.cod_estado = 1
		AND MPC.bsmpc_estado = 'A'
	GROUP BY TGA.cod_contabilidad,
			TGA.cod_oficina,
			TGA.cod_moneda,
			TGA.cod_producto,
			TGA.num_operacion,
			GGF.cedula_fiador,
			GGF.cod_tipo_fiador,
			GFO.cod_tipo_mitigador,
			GFO.cod_tipo_documento_legal,
			GFO.monto_mitigador,
			GFO.porcentaje_responsabilidad,
			GFO.cod_tipo_acreedor,
			GFO.cedula_acreedor,
			GFO.cod_operacion_especial,
			GGF.nombre_fiador,
			TGA.cedula_deudor,
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici


	-- Se insertan las garantías de los giros de los contratos
	INSERT INTO dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
	SELECT 
		TGG.cod_contabilidad,
		TGG.cod_oficina,
		TGG.cod_moneda,
		TGG.cod_producto,
		TGG.operacion,
		TGG.cedula_fiador,
		TGG.cod_tipo_fiador,
		'' AS fecha_valuacion,
		TGG.ingreso_neto,
		TGG.cod_tipo_mitigador,
		TGG.cod_tipo_documento_legal,
		TGG.monto_mitigador,
		TGG.porcentaje_responsabilidad,
		TGG.cod_tipo_acreedor,
		TGG.cedula_acreedor,
		TGG.cod_operacion_especial,
		TGG.nombre_fiador,
		TGG.cedula_deudor,
		TGG.nombre_deudor,
		TGG.oficina_deudor,
		'' AS cod_estado_tarjeta,
		GGF.Porcentaje_Aceptacion
	FROM	#TGARGIROSACTIVOS TGG 
		LEFT OUTER JOIN dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS GGF 
		ON TGG.operacion = GGF.operacion
		AND TGG.cedula_fiador = GGF.cedula_fiador
	WHERE	GGF.operacion IS NULL
		AND GGF.cedula_fiador IS NULL
	GROUP BY TGG.cod_contabilidad,
		TGG.cod_oficina,
		TGG.cod_moneda,
		TGG.cod_producto,
		TGG.operacion,
		TGG.cedula_fiador,
		TGG.cod_tipo_fiador,
		TGG.ingreso_neto,
		TGG.cod_tipo_mitigador,
		TGG.cod_tipo_documento_legal,
		TGG.monto_mitigador,
		TGG.porcentaje_responsabilidad,
		TGG.cod_tipo_acreedor,
		TGG.cedula_acreedor,
		TGG.cod_operacion_especial,
		TGG.nombre_fiador,
		TGG.cedula_deudor,
		TGG.nombre_deudor,
		TGG.oficina_deudor,
		GGF.Porcentaje_Aceptacion;


	/*Se eliminan los registros de duplicados*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_documento_legal DESC) AS cantidadRegistrosDuplicados
		FROM	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


/**Código que genera la información relacionada con tarjeta**/

--Inserta las garantias fiduciarias de tarjetas de crédito MasterCard
INSERT	INTO dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
SELECT	
		1 AS cod_contabilidad,
		TT1.cod_oficina_registra AS cod_oficina,
		TT1.cod_moneda AS cod_moneda, 
		7 AS cod_producto, 
		TT1.num_tarjeta AS num_operacion, 
		TGF.cedula_fiador,
		TGF.cod_tipo_fiador,
		'' AS fecha_valuacion,
		0 AS ingreso_neto,
		TFT.cod_tipo_mitigador,
		TFT.cod_tipo_documento_legal, 
		TFT.monto_mitigador, 
		TFT.porcentaje_responsabilidad, 
		TFT.cod_tipo_acreedor, 
		TFT.cedula_acreedor, 
		TFT.cod_operacion_especial, 
		TGF.nombre_fiador,
		GD1.cedula_deudor,
		GD1.nombre_deudor,
		MPC.bsmpc_dco_ofici AS oficina_deudor,
		TT1.cod_estado_tarjeta,
		TFT.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA TFT
		INNER JOIN dbo.TAR_TARJETA TT1 
		ON TFT.cod_tarjeta = TT1.cod_tarjeta
		INNER JOIN dbo.TAR_GARANTIA_FIDUCIARIA TGF
		ON TFT.cod_garantia_fiduciaria = TGF.cod_garantia_fiduciaria
		INNER JOIN dbo.GAR_DEUDOR GD1 
		ON TT1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC 
		ON MPC.bsmpc_sco_ident = CONVERT(DECIMAL, TT1.cedula_deudor)
	WHERE	MPC.bsmpc_estado = 'A'
		AND TT1.cod_estado_tarjeta LIKE '[^LVH]%'
	GROUP BY TT1.cod_oficina_registra,
		TT1.cod_moneda, 
		TT1.num_tarjeta, 
		TGF.cedula_fiador,
		TGF.cod_tipo_fiador,
		TFT.cod_tipo_mitigador,
		TFT.cod_tipo_documento_legal, 
		TFT.monto_mitigador, 
		TFT.porcentaje_responsabilidad, 
		TFT.cod_tipo_acreedor, 
		TFT.cedula_acreedor, 
		TFT.cod_operacion_especial, 
		TGF.nombre_fiador,
		GD1.cedula_deudor,
		GD1.nombre_deudor,
		MPC.bsmpc_dco_ofici,
		TT1.cod_estado_tarjeta,
		TFT.Porcentaje_Aceptacion

	/*Se actualiza a NULL el valor del porcentaje de aceptación y el porcentaje de responsabilidad cuando este es menor o igual a -1*/
	UPDATE	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS 
	SET		porcentaje_responsabilidad = NULL
	WHERE	porcentaje_responsabilidad <= -1

    UPDATE	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS 
	SET		cod_tipo_documento_legal = -1
	WHERE	cod_tipo_documento_legal IS NULL

	UPDATE	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS 
	SET		Porcentaje_Aceptacion = 0
	WHERE	Porcentaje_Aceptacion <= -1

	/***************************************************************************************************************************************************/

	--INICIO RQ: 2016012710534870
	INSERT INTO dbo.SICAD_FIDUCIARIAS (ID_GARANTIA_FIDUCIARIA, TIPO_PERSONA, ID_FIADOR, SALARIO_NETO_FIADOR, FECHA_VERIFICACION_ASALARIADO)
	SELECT	GGF.cedula_fiador AS ID_GARANTIA_FIDUCIARIA, 
			GGF.cod_tipo_fiador AS TIPO_PERSONA, 
			GGF.cedula_fiador AS ID_FIADOR,
			GGF.ingreso_neto AS SALARIO_NETO_FIADOR,
			GGF.fecha_valuacion AS FECHA_VERIFICACION_ASALARIADO
	FROM	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS GGF
		LEFT OUTER JOIN dbo.SICAD_FIDUCIARIAS SF1
		ON SF1.ID_GARANTIA_FIDUCIARIA = GGF.cedula_fiador
		AND SF1.TIPO_PERSONA = GGF.cod_tipo_fiador
	WHERE	GGF.cod_tipo_documento_legal > -1 
		AND	SF1.ID_GARANTIA_FIDUCIARIA IS NULL
		AND SF1.TIPO_PERSONA IS NULL


	INSERT INTO dbo.SICAD_GAROPER (ID_OPERACION, CODIGO_EMPRESA, FECHA_PROCESO)
	SELECT  CAST(GGF.cod_oficina AS VARCHAR(5)) + CAST(GGF.cod_moneda AS VARCHAR(5)) + CAST(GGF.cod_producto AS VARCHAR(5)) + CAST(GGF.operacion AS VARCHAR(20)) AS ID_OPERACION,
			1 AS CODIGO_EMPRESA,
			GETDATE() AS FECHA_PROCESO
	FROM	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS GGF
		LEFT OUTER JOIN dbo.SICAD_GAROPER SG1
		ON SG1.ID_OPERACION = (CAST(GGF.cod_oficina AS VARCHAR(5)) + CAST(GGF.cod_moneda AS VARCHAR(5)) + CAST(GGF.cod_producto AS VARCHAR(5)) + CAST(GGF.operacion AS VARCHAR(20)))
	WHERE	GGF.cod_tipo_documento_legal > -1        
		AND SG1.ID_OPERACION IS NULL
			
	
	
	INSERT INTO dbo.SICAD_GAROPER_LISTA (ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, 
										 INDICADOR_INSCRIPCION_GARANTIA, FECHA_PRESENTACION_REGISTRO_GARANTIA, PORCENTAJE_RESPONSABILIDAD_GARANTIA, 
										 VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION, CODIGO_EMPRESA)

	SELECT  CAST(GGF.cod_oficina AS VARCHAR(5)) + CAST(GGF.cod_moneda AS VARCHAR(5)) + CAST(GGF.cod_producto AS VARCHAR(5)) + CAST(GGF.operacion AS VARCHAR(20)) AS ID_OPERACION,
			1 AS TIPO_GARANTIA,
			GGF.cedula_fiador AS ID_GARANTIA,
			COALESCE(GGF.cod_tipo_mitigador, -1) AS TIPO_MITIGADOR,
			COALESCE(GGF.cod_tipo_documento_legal, -1) AS TIPO_DOCUMENTO_LEGAL,
			COALESCE(GGF.monto_mitigador, 0) AS MONTO_MITIGADOR,
			-1 AS INDICADOR_INSCRIPCION_GARANTIA,
			'19000101' AS FECHA_PRESENTACION_REGISTRO_GARANTIA,
			COALESCE(GGF.porcentaje_responsabilidad, 0) AS PORCENTAJE_RESPONSABILIDAD_GARANTIA,
			COALESCE(GGF.ingreso_neto, 0) AS VALOR_NOMINAL_GARANTIA,
			1 AS TIPO_MONEDA_VALOR_NOMINAL_GARANTIA,
			COALESCE(GGF.Porcentaje_Aceptacion, 0) AS PORCENTAJE_ACEPTACION,
			1 AS CODIGO_EMPRESA
	FROM	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS GGF
		LEFT OUTER JOIN dbo.SICAD_GAROPER_LISTA SGL
		ON SGL.ID_OPERACION = (CAST(GGF.cod_oficina AS VARCHAR(5)) + CAST(GGF.cod_moneda AS VARCHAR(5)) + CAST(GGF.cod_producto AS VARCHAR(5)) + CAST(GGF.operacion AS VARCHAR(20)))
		AND SGL.ID_GARANTIA = GGF.cedula_fiador
		AND SGL.TIPO_GARANTIA = 1
	WHERE	GGF.cod_tipo_documento_legal > -1  
		AND SGL.ID_OPERACION IS NULL
		AND SGL.ID_GARANTIA IS NULL
		AND SGL.TIPO_GARANTIA IS NULL


	/*Se eliminan los registros de duplicados*/
	WITH GARANTIAS_FIDUCIARIAS (ID_GARANTIA_FIDUCIARIA, TIPO_PERSONA, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	ID_GARANTIA_FIDUCIARIA, TIPO_PERSONA, 
				ROW_NUMBER() OVER(PARTITION BY ID_GARANTIA_FIDUCIARIA, TIPO_PERSONA ORDER BY ID_GARANTIA_FIDUCIARIA, TIPO_PERSONA) AS cantidadRegistrosDuplicados
		FROM	dbo.SICAD_FIDUCIARIAS
	)
	DELETE
	FROM GARANTIAS_FIDUCIARIAS
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
		WHERE	TIPO_GARANTIA = 1
	)
	DELETE
	FROM GAROPER_LISTA
	WHERE cantidadRegistrosDuplicados > 1;

	--FIN RQ: 2016012710534870

	/***************************************************************************************************************************************************/

SELECT	cod_contabilidad AS CONTABILIDAD,
		cod_oficina AS OFICINA,
		cod_moneda AS MONEDA,
		cod_producto AS PRODUCTO,
		operacion AS OPERACION,
		cedula_fiador AS CEDULA_FIADOR,
		cod_tipo_fiador AS TIPO_PERSONA_FIADOR,
		fecha_valuacion AS FECHA_VERIFICACION_ASALARIADO,
		ingreso_neto AS SALARIO_NETO_FIADOR,
		cod_tipo_mitigador AS TIPO_MITIGADOR_RIESGO,
		cod_tipo_documento_legal AS TIPO_DOCUMENTO_LEGAL,
		monto_mitigador AS MONTO_MITIGADOR,
		Porcentaje_Aceptacion AS PORCENTAJE_ACEPTACION, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		cod_tipo_acreedor AS TIPO_PERSONA_ACREEDOR,
		cedula_acreedor AS CEDULA_ACREEDOR,
		cod_operacion_especial AS OPERACION_ESPECIAL,
		nombre_fiador AS NOMBRE_FIADOR,
		cedula_deudor AS CEDULA_DEUDOR,
		nombre_deudor AS NOMBRE_DEUDOR,
		oficina_deudor AS OFICINA_DEUDOR,
		cod_estado_tarjeta AS CODIGO_INTERNO_SISTAR,
		porcentaje_responsabilidad AS PORCENTAJE_RESPONSABILIDAD	
FROM	dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS 
WHERE	cod_tipo_documento_legal > -1 

END
