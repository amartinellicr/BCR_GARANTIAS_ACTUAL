USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasFiduciariasContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasFiduciariasContratos;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasFiduciariasContratos]
	@psCedula_Usuario VARCHAR(30)
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasFiduciariasContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento almacenado que obtiene la información referente a las garantías fiduciarias 
             relacionadas a los contratos vigentes o vencidos pero que aún poseen giros activos.
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

	/*Se declaran las variables para utilizar la fecha actual como un entero*/
	DECLARE
		@vdtFecha_Actual_Sin_Hora DATETIME,
		@viFecha_Actual_Entera INT

	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Actual_Entera =  CONVERT(INT, CONVERT(varchar(8), @vdtFecha_Actual_Sin_Hora, 112))

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

	/*Esta tabla almacenará las garantías fiduciarias activas según el SICC*/
	CREATE TABLE #TEMP_GARANTIAS_FIDUCIARIAS (cod_garantia_fiduciaria BIGINT)
		 
	CREATE INDEX TEMP_GARANTIAS_FIDUCIARIAS_IX_01 ON #TEMP_GARANTIAS_FIDUCIARIAS (cod_garantia_fiduciaria)


	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS WHERE cod_tipo_operacion = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 1 AND cod_usuario = @psCedula_Usuario

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
	INSERT	#TEMP_GARANTIAS_FIDUCIARIAS (cod_garantia_fiduciaria)
	SELECT	DISTINCT GGF.cod_garantia_fiduciaria
	FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pco_produ = 10

	/*Se obtienen los contratos vencidos o no que poseen al menos un giro activo y que tenga relacionada al menos una garantía fiduciaria*/
	INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido,
									 ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
		GO1.cod_operacion, 
		GFO.cod_garantia_fiduciaria,
		1 AS cod_tipo_garantia,
		2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
		0 AS ind_contrato_vencido,
		0 AS ind_contrato_vencido_giros_activos,
		@psCedula_Usuario AS cod_usuario
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_CONTRATOS_VIGENTES TCV
		ON GO1.cod_operacion = TCV.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
		ON GO1.cod_operacion = GFO.cod_operacion
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		
		
	INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido,
									 ind_contrato_vencido_giros_activos, cod_usuario)
	SELECT	DISTINCT 
		GO1.cod_operacion, 
		GFO.cod_garantia_fiduciaria,
		1 AS cod_tipo_garantia,
		2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
		1 AS ind_contrato_vencido,
		1 AS ind_contrato_vencido_giros_activos,
		@psCedula_Usuario AS cod_usuario
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
		ON GO1.cod_operacion = TCV.cod_operacion
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
		ON GO1.cod_operacion = GFO.cod_operacion
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0

	/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
	UPDATE	dbo.TMP_OPERACIONES 
	SET		cod_estado_garantia = 1
	FROM	dbo.TMP_OPERACIONES TMP
		INNER JOIN #TEMP_GARANTIAS_FIDUCIARIAS TGF
		ON TGF.cod_garantia_fiduciaria = TMP.cod_garantia
	WHERE	TMP.cod_usuario = @psCedula_Usuario

	/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
	DELETE  FROM dbo.TMP_OPERACIONES 
	WHERE	cod_estado_garantia = 0 
		AND cod_tipo_operacion = 2 
		AND cod_tipo_garantia = 1 
		AND cod_usuario = @psCedula_Usuario 

	/*Se obtiene la información de las garantías fiduciarias ligadas al contrato y se insertan en la tabla temporal*/
	INSERT INTO dbo.TMP_GARANTIAS_FIDUCIARIAS(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador,
		fecha_valuacion, ingreso_neto, cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador, porcentaje_responsabilidad,
		cod_tipo_acreedor, cedula_acreedor, cod_operacion_especial, nombre_fiador, cedula_deudor, nombre_deudor, oficina_deudor,
		cod_estado_tarjeta, cod_garantia_fiduciaria, cod_operacion, cod_tipo_operacion, ind_operacion_vencida, ind_duplicidad,
		cod_usuario, Porcentaje_Aceptacion)
	SELECT DISTINCT
		GO1.cod_contabilidad, 
		GO1.cod_oficina, 
		GO1.cod_moneda, 
		GO1.cod_producto, 
		GO1.num_contrato AS operacion, 
		GGF.cedula_fiador, 
		GGF.cod_tipo_fiador,
		CONVERT(VARCHAR(10),GVF.fecha_valuacion,103) AS fecha_valuacion,
		GVF.ingreso_neto,
		GFO.cod_tipo_mitigador, 
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
		GFO.cod_garantia_fiduciaria,
		GO1.cod_operacion,
		TMP.cod_tipo_operacion,
		TMP.ind_contrato_vencido,
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario,
		GFO.Porcentaje_Aceptacion
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO 
		ON GO1.cod_operacion = GFO.cod_operacion 
		INNER JOIN dbo.TMP_OPERACIONES TMP
		ON TMP.cod_operacion = GFO.cod_operacion
		AND TMP.cod_garantia = GFO.cod_garantia_fiduciaria
		INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF 
		ON TMP.cod_garantia = GGF.cod_garantia_fiduciaria 
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_FIADOR GVF
		ON GVF.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
		AND GVF.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM dbo.GAR_VALUACIONES_FIADOR WHERE cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)  
		INNER JOIN dbo.GAR_DEUDOR GD1
		ON GO1.cedula_deudor = GD1.cedula_deudor
		INNER JOIN dbo.GAR_SICC_BSMPC MPC
		ON MPC.bsmpc_sco_ident = GD1.Identificacion_Sicc
		 AND MPC.bsmpc_estado = 'A'
	WHERE	TMP.cod_usuario = @psCedula_Usuario
		AND TMP.cod_tipo_garantia = 1
		AND TMP.cod_tipo_operacion = 2
	ORDER BY
		GO1.cod_contabilidad,
		GO1.cod_oficina,	
		GO1.cod_moneda,
		GO1.cod_producto,
		GO1.num_contrato,
		GGF.cedula_fiador,
		GFO.cod_tipo_documento_legal DESC


	/*Se eliminan los registros incompletos*/
	DELETE	FROM dbo.TMP_GARANTIAS_FIDUCIARIAS
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_operacion = 2
		AND COALESCE(cod_tipo_documento_legal, -1) = -1
		AND COALESCE(cod_tipo_mitigador, -1) = -1
		AND LEN(COALESCE(fecha_valuacion, '')) = 0


	/*Se eliminan los registros de duplicados*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, cod_tipo_documento_legal  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_documento_legal DESC) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_FIDUCIARIAS
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion = 2
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


	/*Se selecciona la información que contendrá el archivo*/
	SELECT	DISTINCT 
			cod_contabilidad AS CONTABILIDAD,
			cod_oficina AS OFICINA,
			cod_moneda AS MONEDA,
			cod_producto AS PRODUCTO,
			operacion AS OPERACION,
			cedula_fiador AS CEDULA_FIADOR,
			cod_tipo_fiador AS TIPO_PERSONA_FIADOR,
			COALESCE((CONVERT(VARCHAR(10),fecha_valuacion,103)), '') AS FECHA_VERIFICACION_ASALARIADO,
			COALESCE((CONVERT(VARCHAR(50),ingreso_neto)), '') AS SALARIO_NETO_FIADOR,
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_mitigador)), '') AS TIPO_MITIGADOR_RIESGO,
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
			COALESCE((CONVERT(VARCHAR(50), monto_mitigador)), '') AS MONTO_MITIGADOR,
			COALESCE((CONVERT(VARCHAR(50), porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD,
			COALESCE((CONVERT(VARCHAR(3),cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
			COALESCE(cedula_acreedor, '') AS CEDULA_ACREEDOR,
			COALESCE((CONVERT(VARCHAR(3),cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
			COALESCE(nombre_fiador, '') AS NOMBRE_FIADOR,
			COALESCE(cedula_deudor, '') AS CEDULA_DEUDOR,
			COALESCE(nombre_deudor, '') AS NOMBRE_DEUDOR,
			COALESCE((CONVERT(VARCHAR(5),oficina_deudor)), '') AS OFICINA_DEUDOR,
			'' AS BIN,
			COALESCE((CONVERT(VARCHAR(5),cod_estado_tarjeta)), '') AS CODIGO_INTERNO_SISTAR,
			ind_operacion_vencida AS ES_CONTRATO_VENCIDO
	FROM	dbo.TMP_GARANTIAS_FIDUCIARIAS 
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_operacion = 2
	ORDER BY operacion

END
