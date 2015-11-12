USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarGarantiasRealesInfoCompleta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarGarantiasRealesInfoCompleta;
GO

CREATE PROCEDURE [dbo].[pa_GenerarGarantiasRealesInfoCompleta] 
	@IDUsuario VARCHAR(30),
	@piEjecutarParte BIT
	
AS

/******************************************************************
<Nombre>pa_GenerarGarantiasRealesInfoCompleta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la información necesaria, sobre las garantías reales asociadas a operaciones y giros, para generar el 
			 archivo SEGUI. Se implementan nuevos criterios de selección de la información.
			 La ejecución de este procedimiento almacenado se divide en dos partes, controladas por el parámetro "@piEjecutarParte",
			 donde un valor igual a 0 equivale a la ejecución de la primera parte, un valor diferente de 0 equivale a la 
			 ejecución de la segunda parte.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
	@piEjecutarParte = Indicador (tipo bit), que permite determinar si se ejecuta la primera parte del 
                       procedimiento almacenado (un valor igual a 0) o bien la segunda parte (un valor igual 
                       a 1), esto para poder dismunir los tiempos de ejecución del procedimiento almacenado.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
<Fecha>18/11/2010</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento>
			Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
		    Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841</Requerimiento>
		<Fecha>12/03/2014</Fecha>
		<Descripción>
			Se ajusta el procedimiento almacenado para sustituir el nombre de la columna "PORCENTAJE_RESPONSABILIDAD" por "PORCENTAJE_ACEPTACION".
		</Descripción>
	</Cambio>
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
			<Fecha>03/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
	</Cambio>
	<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00090 Creación Campos Archivos GaRea y GaReaCo</Requerimiento>
			<Fecha>11/10/2015</Fecha>
			<Descripción>
				Debido al cambio dado en varias tablas se deben agregar los siguientes campos: Porcentaje_Aceptacion_Terreno, Porcentaje_Aceptacion_No_Terreno, 
				Porcentaje_Aceptacion_Terreno_Calculado, Porcentaje_Aceptacion_No_Terreno_Calculado, Coberturas de bienes.
			</Descripción>
		</Cambio>
		<Cambio>
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

	IF @piEjecutarParte = 0
	BEGIN

		/*Se eliminan los registros que puedieron ser cargados por el usuario en algún procesamiento anterior*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_tipo_operacion IN (1, 3) 
			AND cod_usuario = @IDUsuario 

		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_usuario = @IDUsuario 
			AND cod_tipo_garantia = 2 
			AND cod_tipo_operacion IN (1, 3)

		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @IDUsuario
			AND cod_tipo_garantia = 2  
			AND cod_tipo_operacion IN (1, 3)
		
		DELETE	FROM dbo.TMP_VALUACIONES_REALES 
		WHERE	cod_usuario = @IDUsuario 

		/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
		DECLARE
			@lfecHoySinHora DATETIME,
			@lintFechaEntero INT

		/*Variable que servirá para almacenar los datos de la estructura PRMOC*/
		DECLARE	@ptPRMOC TABLE(	prmoc_pco_conta  TINYINT,
								prmoc_pco_ofici  SMALLINT,
								prmoc_pco_moned  TINYINT,
								prmoc_pco_produ  TINYINT,
								prmoc_pnu_oper   INT,
								prmoc_pnu_contr  INT,
								prmoc_pco_oficon SMALLINT,
								prmoc_pcomonint  SMALLINT,
								cod_operacion    BIGINT
								PRIMARY KEY (prmoc_pco_conta, 
											 prmoc_pco_ofici, 
											 prmoc_pco_moned, 
											 prmoc_pco_produ, 
											 prmoc_pnu_oper, 
											 prmoc_pnu_contr,
											 prmoc_pco_oficon,
											 prmoc_pcomonint,
											 cod_operacion)
							  )


		/*Variable que servirá para almacenar los datos de la estructura PRMCA*/
		DECLARE	@ptPRMCA TABLE(	prmca_pco_ofici  SMALLINT,
								prmca_pco_moned  TINYINT,
								prmca_pco_produc TINYINT,
								prmca_pnu_contr  INT,
								cod_operacion    BIGINT
								PRIMARY KEY (prmca_pco_ofici, 
											 prmca_pco_moned, 
											 prmca_pco_produc, 
											 prmca_pnu_contr, 
											 cod_operacion)
							  )


		SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		SET @lintFechaEntero =  CONVERT(int, CONVERT(VARCHAR(8), @lfecHoySinHora, 112))

		/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
		INSERT	@ptPRMOC
		SELECT	DISTINCT MOC.prmoc_pco_conta, 
						 MOC.prmoc_pco_ofici, 
						 MOC.prmoc_pco_moned, 
						 MOC.prmoc_pco_produ, 
						 MOC.prmoc_pnu_oper, 
						 MOC.prmoc_pnu_contr,
						 MOC.prmoc_pco_oficon,
						 MOC.prmoc_pcomonint,
						 GO1.cod_operacion
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_SICC_PRMOC MOC --GAR_SICC_PRMOC = Maestro de operaciones desde el SICC
			ON MOC.prmoc_pco_conta = GO1.cod_contabilidad
			AND MOC.prmoc_pco_ofici = GO1.cod_oficina
			AND MOC.prmoc_pco_moned = GO1.cod_moneda
			AND MOC.prmoc_pco_produ = GO1.cod_producto
			AND MOC.prmoc_pnu_oper = GO1.num_operacion
		WHERE	MOC.prmoc_pse_proces = 1 
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
				OR (MOC.prmoc_pcoctamay > 815))
			AND GO1.cod_estado = 1 
			AND GO1.num_operacion IS NOT NULL
			AND EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
						WHERE	GRA.cod_operacion = GO1.cod_operacion)

		/*Se obtienen los contratos que poseen giros activos*/
		INSERT	@ptPRMCA
		SELECT	DISTINCT MCA.prmca_pco_ofici,
						 MCA.prmca_pco_moned,
						 MCA.prmca_pco_produc,
						 MCA.prmca_pnu_contr,
						 GO1.cod_operacion
		FROM	dbo.GAR_SICC_PRMCA MCA --GAR_SICC_PRMCA = Maestro de contratos desde el SICC
			INNER JOIN dbo.GAR_OPERACION GO1
			ON GO1.cod_oficina = MCA.prmca_pco_ofici
			AND GO1.cod_moneda = MCA.prmca_pco_moned
			AND GO1.cod_producto = MCA.prmca_pco_produc
			AND GO1.num_contrato = MCA.prmca_pnu_contr
		WHERE	MCA.prmca_estado = 'A'
			AND GO1.num_contrato > 0
			AND GO1.num_operacion IS NULL
			AND EXISTS (SELECT	1
						FROM	@ptPRMOC MOC
						WHERE	MOC.prmoc_pnu_contr > 0
							AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
							AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
							AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
							AND MOC.prmoc_pnu_oper IS NOT NULL)
			AND EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
						WHERE	GRA.cod_operacion = GO1.cod_operacion)
	   
		/*Se obtienen las operaciones activas que posean una garantía real asociada*/	
		INSERT	INTO dbo.TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia,
										  cod_tipo_operacion, ind_contrato_vencido,
										  ind_contrato_vencido_giros_activos, cod_oficina,
										  cod_moneda, cod_producto, num_operacion, num_contrato,
										  cod_usuario)
		SELECT	DISTINCT 
			GRA.cod_operacion, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			CASE WHEN MOC.prmoc_pnu_contr > 0 THEN 3
				 ELSE 1
			END AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			MOC.prmoc_pco_ofici,
			MOC.prmoc_pco_moned,
			MOC.prmoc_pco_produ,
			MOC.prmoc_pnu_oper,
			MOC.prmoc_pnu_contr,
			@IDUsuario AS cod_usuario
		FROM	@ptPRMOC MOC
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON MOC.cod_operacion = GRA.cod_operacion
		WHERE MOC.prmoc_pnu_contr = 0
			AND GRA.cod_estado = 1 

		/*Se obtienen los contratos y las garantías relacionadas a estos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos,
										 cod_oficina, cod_moneda, cod_producto, num_operacion,
										 num_contrato, cod_usuario)
		SELECT	DISTINCT 
			GRA.cod_operacion, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			2 AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			MCA.prmca_pco_ofici,
			MCA.prmca_pco_moned,
			MCA.prmca_pco_produc,
			NULL AS num_operacion,
			MCA.prmca_pnu_contr,
			@IDUsuario AS cod_usuario
		FROM	@ptPRMCA MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.cod_operacion

		/*Se obtienen los giros asociados a los contratos y se les asigna las garantías relacionadas a este último*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_oficina,
										 cod_moneda, cod_producto, num_operacion, num_contrato,
										 cod_oficina_contrato, cod_moneda_contrato, 
										 cod_producto_contrato, cod_usuario)
		SELECT	DISTINCT 
			GO1.cod_operacion, 
			TOR.cod_garantia,
			2 AS cod_tipo_garantia,
			CASE WHEN PRM.prmoc_pnu_contr > 0 THEN 3
				 ELSE 1
			END AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			GO1.cod_oficina,
			GO1.cod_moneda,
			GO1.cod_producto,
			GO1.num_operacion,
			GO1.num_contrato,
			TOR.cod_oficina AS cod_oficina_contrato,
			TOR.cod_moneda AS cod_moneda_contrato,
			TOR.cod_producto AS cod_producto_contrato,
			@IDUsuario AS cod_usuario
		FROM	@ptPRMOC PRM
			INNER JOIN dbo.GAR_OPERACION GO1 
			ON GO1.cod_contabilidad = PRM.prmoc_pco_conta
			AND GO1.cod_oficina = PRM.prmoc_pco_ofici
			AND GO1.cod_moneda = PRM.prmoc_pco_moned
			AND GO1.cod_producto = PRM.prmoc_pco_produ
			AND GO1.num_operacion = PRM.prmoc_pnu_oper
			INNER JOIN dbo.TMP_OPERACIONES TOR 
			ON TOR.cod_oficina = PRM.prmoc_pco_oficon
			AND TOR.cod_moneda = PRM.prmoc_pcomonint
			AND TOR.num_contrato = PRM.prmoc_pnu_contr
		WHERE	PRM.prmoc_pnu_contr > 0
			AND GO1.cod_estado = 1 
			AND GO1.num_contrato > 0
			AND TOR.cod_tipo_operacion = 2
			AND TOR.cod_usuario = @IDUsuario

		/*Se eliminan los contratos que fueron cargados*/
		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_tipo_garantia = 2 
			AND cod_usuario = @IDUsuario 
			AND cod_tipo_operacion = 2

		/*Se cargan los valores de los avalúos en la tabla temporal respectiva*/
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		INSERT	INTO dbo.TMP_VALUACIONES_REALES(cod_garantia_real, fecha_valuacion, cedula_empresa,
												cedula_perito, monto_ultima_tasacion_terreno,
												monto_ultima_tasacion_no_terreno,
												monto_tasacion_actualizada_terreno,
												monto_tasacion_actualizada_no_terreno,
												fecha_ultimo_seguimiento, monto_total_avaluo,
												cod_recomendacion_perito,
												cod_inspeccion_menor_tres_meses,
												fecha_construccion, cod_tipo_bien, ind_avaluo_completo,
												cod_usuario)
		SELECT	DISTINCT 
			GVR.cod_garantia_real, 
			GVR.fecha_valuacion, 
			GVR.cedula_empresa, 
			GVR.cedula_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			GVR.fecha_ultimo_seguimiento, 
			GVR.monto_total_avaluo, 
			GVR.cod_recomendacion_perito, 
			GVR.cod_inspeccion_menor_tres_meses, 
			GVR.fecha_construccion,
			GGR.cod_tipo_bien, 
			1 AS grado_completo,
			TOR.cod_usuario
		FROM dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TOR 
			ON TOR.cod_garantia = GRO.cod_garantia_real
			AND TOR.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TOR.cod_garantia
		WHERE	TOR.cod_tipo_garantia = 2
			AND TOR.cod_tipo_operacion IN (1, 3)
			AND TOR.cod_usuario = @IDUsuario

		/*Se eliminan los registros de los avalúos considerados basura*/
		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		WHERE	cedula_empresa IS NULL
			AND cedula_perito IS NULL
			AND (monto_ultima_tasacion_terreno IS NULL OR monto_ultima_tasacion_terreno = 0)
			AND (monto_ultima_tasacion_no_terreno IS NULL OR monto_ultima_tasacion_no_terreno = 0)
			AND (monto_tasacion_actualizada_terreno IS NULL OR monto_tasacion_actualizada_terreno = 0)
			AND (monto_tasacion_actualizada_no_terreno IS NULL OR monto_tasacion_actualizada_no_terreno = 0)
			AND fecha_ultimo_seguimiento IS NULL
			AND fecha_construccion IS NULL
			AND cod_usuario = @IDUsuario
		
		/*Se actualiza el campo grado_completo con el código igual a 0, indicando los registros completos, según el tipo de bien*/
		UPDATE	dbo.TMP_VALUACIONES_REALES
		SET		ind_avaluo_completo = 0 
		WHERE	 cod_tipo_bien = 1
			AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
			AND monto_ultima_tasacion_terreno > 0
			AND (monto_ultima_tasacion_no_terreno IS NULL OR monto_ultima_tasacion_no_terreno = 0)
			AND monto_tasacion_actualizada_terreno > 0
			AND (monto_tasacion_actualizada_no_terreno IS NULL OR monto_tasacion_actualizada_no_terreno = 0)
			AND fecha_ultimo_seguimiento IS NOT NULL
			AND fecha_construccion IS NULL
			AND cod_usuario = @IDUsuario

		UPDATE	dbo.TMP_VALUACIONES_REALES
		SET		ind_avaluo_completo = 0
		WHERE	cod_tipo_bien = 2
			AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
			AND monto_ultima_tasacion_no_terreno > 0
			AND monto_tasacion_actualizada_no_terreno > 0
			AND fecha_ultimo_seguimiento IS NOT NULL
			AND fecha_construccion IS NOT NULL
			AND cod_usuario = @IDUsuario

		UPDATE	dbo.TMP_VALUACIONES_REALES
		SET		ind_avaluo_completo = 0
		WHERE	cod_tipo_bien NOT IN (1,2)
			AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
			AND (monto_ultima_tasacion_terreno IS NULL OR monto_ultima_tasacion_terreno = 0)
			AND (monto_tasacion_actualizada_terreno IS NULL OR  monto_tasacion_actualizada_terreno = 0)
			AND monto_ultima_tasacion_no_terreno > 0
			AND monto_tasacion_actualizada_no_terreno > 0
			AND fecha_ultimo_seguimiento IS NOT NULL
			AND fecha_construccion IS NOT NULL
			AND cod_usuario = @IDUsuario

		/*Se eliminan los registros incompletos de los avalúos que posean almenos un avalúo completo*/
		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 1
			AND TMP.cod_usuario = @IDUsuario
			AND EXISTS (SELECT	1
						FROM	dbo.TMP_VALUACIONES_REALES VAL
						WHERE	VAL.cod_garantia_real = TMP.cod_garantia_real
							AND VAL.cod_usuario = TMP.cod_usuario
							AND VAL.ind_avaluo_completo = 0)

		/*Se eliminan los registros cuya fecha de valuación sea menor a la más reciente, según el valor del campo ind_avaluo_completo*/
		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 0
			AND TMP.cod_usuario = @IDUsuario
			AND TMP.fecha_valuacion <> (SELECT	MAX(VAL.fecha_valuacion)
										FROM	dbo.TMP_VALUACIONES_REALES VAL
										WHERE	VAL.cod_garantia_real = TMP.cod_garantia_real
											AND VAL.cod_usuario = TMP.cod_usuario
											AND VAL.ind_avaluo_completo = 0)

		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 1
			AND TMP.cod_usuario = @IDUsuario
			AND TMP.fecha_valuacion <> (SELECT	MAX(VAL.fecha_valuacion)
										FROM	dbo.TMP_VALUACIONES_REALES VAL
										WHERE	VAL.cod_garantia_real = TMP.cod_garantia_real
											AND VAL.cod_usuario = TMP.cod_usuario
											AND VAL.ind_avaluo_completo = 1)

		/*Se selecciona la información de la garantía real asociada a los contratos*/
		INSERT	INTO dbo.TMP_GARANTIAS_REALES
		SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
			GGR.cod_tipo_bien, 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
			GRO.cod_tipo_mitigador, 
			GRO.cod_tipo_documento_legal, 
			GRO.monto_mitigador, 
			CASE WHEN CONVERT(VARCHAR(10), GRO.fecha_presentacion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10), GRO.fecha_presentacion,103)
			END AS fecha_presentacion,
			GRO.cod_inscripcion, 
			GRO.porcentaje_responsabilidad, 
			CASE WHEN CONVERT(VARCHAR(10), GRO.fecha_constitucion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10), GRO.fecha_constitucion,103)
			END AS fecha_constitucion, 
			GRO.cod_grado_gravamen, 
			GRO.cod_tipo_acreedor, 
			GRO.cedula_acreedor, 
			CASE WHEN CONVERT(VARCHAR(10), GRO.fecha_vencimiento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10), GRO.fecha_vencimiento,103)
			END AS fecha_vencimiento, 
			GRO.cod_operacion_especial, 
			CASE WHEN CONVERT(VARCHAR(10), TVR.fecha_valuacion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10), TVR.fecha_valuacion,103)
			END AS fecha_valuacion, 
			TVR.cedula_empresa, 
			CASE WHEN TVR.cedula_empresa IS NULL THEN NULL ELSE 2 END AS cod_tipo_empresa, 
			TVR.cedula_perito, 
			GPE.cod_tipo_persona AS cod_tipo_perito, 
			TVR.monto_ultima_tasacion_terreno, 
			TVR.monto_ultima_tasacion_no_terreno, 
			TVR.monto_tasacion_actualizada_terreno, 
			TVR.monto_tasacion_actualizada_no_terreno, 
			CASE WHEN CONVERT(VARCHAR(10),TVR.fecha_ultimo_seguimiento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),TVR.fecha_ultimo_seguimiento,103)
			END AS fecha_ultimo_seguimiento, 
			COALESCE(TVR.monto_tasacion_actualizada_terreno,0) + COALESCE(TVR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE WHEN CONVERT(VARCHAR(10),TVR.fecha_construccion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),TVR.fecha_construccion,103)
			END AS fecha_construccion,
			GGR.cod_grado,
			GGR.cedula_hipotecaria,
			GGR.cod_clase_garantia,
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
			GO1.cedula_deudor,
			1 AS cod_estado,
			NULL AS cod_liquidez,
			NULL AS cod_tenencia,
			NULL AS cod_moneda,
			NULL AS cod_partido,
			NULL AS cod_tipo_garantia,
			NULL AS Garantia_Real,
			NULL AS fecha_prescripcion,
			TOR.cod_tipo_operacion,
			TOR.ind_contrato_vencido,
			1 AS ind_duplicidad,
			TOR.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			NULL AS Porcentaje_Aceptacion_Terreno,
			NULL AS Porcentaje_Aceptacion_No_Terreno,
			NULL AS Porcentaje_Aceptacion_Terreno_Calculado,
			NULL AS Porcentaje_Aceptacion_No_Terreno_Calculado,
			NULL AS Codigo_SAP,
			NULL AS Monto_Poliza_Colonizado,
			NULL AS Fecha_Vencimiento_Poliza,
			NULL AS Codigo_Tipo_Poliza_Sugef,
			NULL AS Indicador_Poliza,
			NULL AS Indicador_Coberturas_Obligatorias
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GO1.cod_operacion = GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GRO.cod_garantia_real = GGR.cod_garantia_real 
			LEFT OUTER JOIN  dbo.TMP_VALUACIONES_REALES TVR
			ON GGR.cod_garantia_real = TVR.cod_garantia_real
			AND TVR.cod_usuario = @IDUsuario
			LEFT OUTER JOIN dbo.GAR_PERITO GPE
			ON TVR.cedula_perito = GPE.cedula_perito 
			INNER JOIN dbo.TMP_OPERACIONES TOR
			ON TOR.cod_operacion = GRO.cod_operacion
			AND TOR.cod_garantia = GRO.cod_garantia_real
		WHERE	GRO.cod_estado = 1
			AND TOR.cod_tipo_garantia = 2
			AND TOR.cod_usuario = @IDUsuario
			AND TOR.cod_tipo_operacion IN (1, 3)
	END
	ELSE  
	/*Ejecuta parte 1 de acuerdo al valor del parametro
		@piEjecutarParte = 1
	*/
	BEGIN
		/*Se obtienen las operaciones duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
				cod_moneda, 
				cod_producto, 
				operacion,
				cod_tipo_operacion, 
				cod_bien AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@IDUsuario AS cod_usuario,
				MAX(cod_garantia_real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, cod_bien, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
		  Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
		UPDATE	dbo.TMP_GARANTIAS_REALES 
		SET 	ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES GGR
		WHERE GGR.cod_usuario = @IDUsuario
			AND GGR.cod_tipo_operacion IN (1, 3)
			AND EXISTS (SELECT 1 
					  FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
					  WHERE GGR.cod_oficina = TGR.cod_oficina
						AND GGR.cod_moneda = TGR.cod_moneda
						AND GGR.cod_producto = TGR.cod_producto
						AND GGR.operacion = TGR.operacion
						AND COALESCE(GGR.cod_bien, '') = COALESCE(TGR.cod_garantia_sicc, '')
						AND COALESCE(GGR.cod_usuario, '') = COALESCE(TGR.cod_usuario, '')
						AND TGR.cod_tipo_operacion IN (1, 3)
						AND TGR.cod_tipo_garantia = 2
						AND GGR.cod_tipo_documento_legal IS NULL
						AND GGR.fecha_presentacion IS NULL
						AND GGR.cod_tipo_mitigador IS NULL
						AND GGR.cod_inscripcion IS NULL)
		
		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	ind_duplicidad = 2 
			AND cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3) 

		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @IDUsuario  
			AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de hipoteca común duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
				cod_moneda, 
				cod_producto, 
				operacion,
				cod_tipo_operacion, 
				numero_finca AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@IDUsuario AS cod_usuario,
				MAX(cod_garantia_real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_tipo_garantia_real = 1 
			AND cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TT1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TT1
			ON TT1.cod_oficina = TOD.cod_oficina
			AND TT1.cod_moneda = TOD.cod_moneda
			AND TT1.cod_producto = TOD.cod_producto
			AND TT1.operacion = TOD.operacion
			AND COALESCE(TT1.numero_finca, '') = COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	TT1.cod_tipo_garantia_real = 1
			AND TT1.cod_usuario = @IDUsuario
			AND TT1.cod_tipo_operacion IN (1, 3)
			AND TT1.cod_llave = (SELECT	MIN(TT2.cod_llave)
								FROM	dbo.TMP_GARANTIAS_REALES TT2
								WHERE	TT2.cod_oficina = TOD.cod_oficina
									AND TT2.cod_moneda = TOD.cod_moneda
									AND TT2.cod_producto = TOD.cod_producto
									AND TT2.operacion = TOD.operacion
									AND COALESCE(TT2.numero_finca, '') = COALESCE(TOD.cod_garantia_sicc, '')
									AND COALESCE(TT2.cod_usuario, '') = COALESCE(TOD.cod_usuario, '')
									AND TT2.cod_tipo_garantia_real = 1
									AND TT2.cod_tipo_operacion IN (1, 3)
									AND TOD.cod_tipo_garantia = 2)

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES GGR
		WHERE	GGR.cod_tipo_garantia_real = 1
			AND GGR.cod_usuario = @IDUsuario
			AND GGR.cod_tipo_operacion IN (1, 3)
			AND EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TGR
						WHERE	GGR.cod_oficina = TGR.cod_oficina
							AND GGR.cod_moneda = TGR.cod_moneda
							AND GGR.cod_producto = TGR.cod_producto
							AND GGR.operacion = TGR.operacion
							AND COALESCE(GGR.numero_finca, '') = COALESCE(TGR.cod_garantia_sicc, '')
							AND GGR.cod_llave <> TGR.cod_garantia
							AND COALESCE(GGR.cod_usuario, '') = COALESCE(TGR.cod_usuario, '')
							AND GGR.cod_tipo_garantia_real = 1
							AND GGR.cod_tipo_operacion IN (1, 3)
							AND TGR.cod_tipo_garantia = 2)


		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @IDUsuario  
			AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
				cod_moneda, 
				cod_producto, 
				operacion,
				cod_tipo_operacion, 
				numero_finca AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@IDUsuario AS cod_usuario,
				MAX(cod_garantia_real) AS cod_garantia,
				cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia_real = 2
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TT1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TT1
			ON TT1.cod_oficina = TOD.cod_oficina
			AND TT1.cod_moneda = TOD.cod_moneda
			AND TT1.cod_producto = TOD.cod_producto
			AND TT1.operacion = TOD.operacion
			AND COALESCE(TT1.numero_finca, '') = COALESCE(TOD.cod_garantia_sicc, '')
			AND TT1.cod_grado = TOD.cod_grado
		WHERE	TT1.cod_tipo_garantia_real = 2
			AND TT1.cod_usuario = @IDUsuario
			AND TT1.cod_tipo_operacion IN (1, 3)
			AND TT1.cod_llave = (SELECT	MIN(TT2.cod_llave)
								 FROM	dbo.TMP_GARANTIAS_REALES TT2
								 WHERE	TT2.cod_oficina = TOD.cod_oficina
									AND TT2.cod_moneda = TOD.cod_moneda
									AND TT2.cod_producto = TOD.cod_producto
									AND TT2.operacion = TOD.operacion
									AND COALESCE(TT2.numero_finca, '') = COALESCE(TOD.cod_garantia_sicc, '')
									AND TT2.cod_grado = TOD.cod_grado
									AND COALESCE(TT2.cod_usuario, '') = COALESCE(TOD.cod_usuario, '')
									AND TT2.cod_tipo_garantia_real = 2
									AND TT2.cod_tipo_operacion IN (1, 3)
									AND TOD.cod_tipo_garantia = 2)

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES GGR
		WHERE	GGR.cod_tipo_garantia_real = 2
			AND GGR.cod_usuario = @IDUsuario
			AND GGR.cod_tipo_operacion IN (1, 3)
			AND EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TGR
						WHERE	GGR.cod_oficina = TGR.cod_oficina
							AND GGR.cod_moneda = TGR.cod_moneda
							AND GGR.cod_producto = TGR.cod_producto
							AND GGR.operacion = TGR.operacion
							AND COALESCE(GGR.numero_finca, '') = COALESCE(TGR.cod_garantia_sicc, '')
							AND GGR.cod_grado = TGR.cod_grado
							AND GGR.cod_llave <> TGR.cod_garantia
							AND COALESCE(GGR.cod_usuario, '') = COALESCE(TGR.cod_usuario, '')
							AND GGR.cod_tipo_garantia_real = 2
							AND GGR.cod_tipo_operacion IN (1, 3)
							AND TGR.cod_tipo_garantia = 2)

		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @IDUsuario  
			AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de prenda duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
				cod_moneda, 
				cod_producto, 
				operacion,
				cod_tipo_operacion, 
				num_placa_bien AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@IDUsuario AS cod_usuario,
				MAX(cod_garantia_real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia_real = 3
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TT1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TT1
			ON TT1.cod_oficina = TOD.cod_oficina
			AND TT1.cod_moneda = TOD.cod_moneda
			AND TT1.cod_producto = TOD.cod_producto
			AND TT1.operacion = TOD.operacion
			AND COALESCE(TT1.num_placa_bien, '') = COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	TT1.cod_tipo_garantia_real = 3
			AND TT1.cod_usuario = @IDUsuario
			AND TT1.cod_tipo_operacion IN (1, 3)
			AND TT1.cod_llave = (SELECT	MIN(TT1.cod_llave)
								 FROM	dbo.TMP_GARANTIAS_REALES TT1
								WHERE	TT1.cod_oficina = TOD.cod_oficina
									AND TT1.cod_moneda = TOD.cod_moneda
									AND TT1.cod_producto = TOD.cod_producto
									AND TT1.operacion = TOD.operacion
									AND COALESCE(TT1.num_placa_bien, '') = COALESCE(TOD.cod_garantia_sicc, '')
									AND COALESCE(TT1.cod_usuario, '') = COALESCE(TOD.cod_usuario, '')
									AND TT1.cod_tipo_garantia_real = 3
									AND TT1.cod_tipo_operacion IN (1, 3)
									AND TOD.cod_tipo_garantia = 2)

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES GGR
		WHERE	GGR.cod_tipo_garantia_real = 3
			AND GGR.cod_usuario = @IDUsuario
			AND GGR.cod_tipo_operacion IN (1, 3)
			AND EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TGR
						WHERE	GGR.cod_oficina = TGR.cod_oficina
							AND GGR.cod_moneda = TGR.cod_moneda
							AND GGR.cod_producto = TGR.cod_producto
							AND GGR.operacion = TGR.operacion
							AND COALESCE(GGR.num_placa_bien, '') = COALESCE(TGR.cod_garantia_sicc, '')
							AND GGR.cod_llave <> TGR.cod_garantia
							AND COALESCE(GGR.cod_usuario, '') = COALESCE(TGR.cod_usuario, '')
							AND GGR.cod_tipo_garantia_real = 3
							AND GGR.cod_tipo_operacion IN (1, 3)
							AND TGR.cod_tipo_garantia = 2)

		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_tipo_operacion IN (1, 3) 
			AND ind_duplicidad = 2 
			AND cod_usuario = @IDUsuario

		/*Se verfica que la fecha de la valuación sea la misma a la registrada en el sistema de garantías,
		  caso contrario se asigna la fecha del avalúo registrada en el SICC*/
		UPDATE	TMP
		SET		TMP.fecha_valuacion =	CASE
											WHEN GRO.Fecha_Valuacion_SICC IS NULL THEN NULL
											WHEN GRO.Fecha_Valuacion_SICC = '19000101' THEN NULL
											ELSE CONVERT(VARCHAR(10), GRO.Fecha_Valuacion_SICC, 103)
										END
		FROM	dbo.TMP_GARANTIAS_REALES TMP
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real	= TMP.cod_garantia_real
		WHERE	TMP.cod_usuario			= @IDUsuario
			AND TMP.cod_tipo_operacion	IN (1, 3)
			
			
		UPDATE	TMP
		SET		TMP.fecha_valuacion		= NULL
		FROM	dbo.TMP_GARANTIAS_REALES TMP
		WHERE	TMP.cod_usuario			= @IDUsuario
			AND TMP.cod_tipo_operacion	IN (1, 3)
			AND TMP.fecha_valuacion		= '01/01/1900'

		/*Se seleccionan los datos de salida para el usuario que genera la información*/
		SELECT DISTINCT
			TGR.cod_contabilidad AS CONTABILIDAD,
			TGR.cod_oficina AS OFICINA,
			TGR.cod_moneda AS MONEDA,
			TGR.cod_producto AS PRODUCTO,
			TGR.operacion AS OPERACION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_bien)), '') AS TIPO_BIEN,
			COALESCE((CONVERT(VARCHAR(50), TGR.cod_bien)), '') AS CODIGO_BIEN,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_mitigador)), '') AS TIPO_MITIGADOR,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
			COALESCE((CONVERT(VARCHAR(50),(MAX(TGR.monto_mitigador)))), '') AS MONTO_MITIGADOR,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_presentacion, 103)), '') AS FECHA_PRESENTACION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_inscripcion)), '') AS INDICADOR_INSCRIPCION,
			COALESCE((CONVERT(VARCHAR(50), TGR.porcentaje_responsabilidad)), '') AS PORCENTAJE_ACEPTACION,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_constitucion, 103)), '') AS FECHA_CONSTITUCION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_grado_gravamen)), '') AS GRADO_GRAVAMEN,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
			COALESCE(TGR.cedula_acreedor, '') AS CEDULA_ACREEDOR,
			COALESCE((CONVERT(VARCHAR(10), (MAX(TGR.fecha_vencimiento)), 103)), '') AS FECHA_VENCIMIENTO,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_valuacion, 103)), '') AS FECHA_VALUACION,
			COALESCE(TGR.cedula_empresa, '') AS CEDULA_EMPRESA,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_empresa)), '') AS TIPO_PERSONA_EMPRESA,
			COALESCE(TGR.cedula_perito, '') AS CEDULA_PERITO,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_perito)), '')AS TIPO_PERSONA_PERITO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_terreno)), '') AS MONTO_ULTIMA_TASACION_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_no_terreno)), '') AS MONTO_ULTIMA_TASACION_NO_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_no_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_ultimo_seguimiento, 103)), '') AS FECHA_ULTIMO_SEGUIMIENTO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_total_avaluo)), '') AS MONTO_TOTAL_AVALUO,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_construccion, 103)), '') AS FECHA_CONSTRUCCION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_grado)), '') AS COD_GRADO,
			COALESCE(TGR.cedula_hipotecaria, '') AS CEDULA_HIPOTECARIA,
			COALESCE(TGR.cedula_deudor, '') AS CEDULA_DEUDOR,
			COALESCE(GDE.nombre_deudor, '') AS NOMBRE_DEUDOR,
			COALESCE((CONVERT(VARCHAR(5), MPC.bsmpc_dco_ofici)), '') AS OFICINA_DEUDOR,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_clase_garantia)), '') AS TIPO_GARANTIA,
			COALESCE((CONVERT(VARCHAR(100), TMP.Codigo_SAP)), '') AS CODIGO_SAP,
			COALESCE((CONVERT(VARCHAR(100), TMP.Monto_Poliza_Colonizado)), '') AS MONTO_POLIZA,
			COALESCE((CONVERT(VARCHAR(10), TMP.Fecha_Vencimiento, 103)), '') AS FECHA_VENCIMIENTO_POLIZA,
			COALESCE((CONVERT(VARCHAR(5), TMP.Codigo_Tipo_Poliza_Sugef)), '') AS TIPO_POLIZA_SUGEF,
			CASE
				WHEN TMP.Codigo_SAP IS NOT NULL THEN 'S'
				ELSE 'N'
			END AS INDICADOR_POLIZA
		FROM	dbo.TMP_GARANTIAS_REALES TGR
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON MPC.bsmpc_sco_ident = CONVERT(DECIMAL, TGR.cedula_deudor)
			AND MPC.bsmpc_estado = 'A'		
			INNER JOIN dbo.GAR_DEUDOR GDE
			ON TGR.cedula_deudor = GDE.cedula_deudor
			LEFT OUTER JOIN (SELECT	GPO.Codigo_SAP, GPO.cod_operacion, GPR.cod_garantia_real,
									GPO.Monto_Poliza_Colonizado, GPO.Fecha_Vencimiento, 
									TPB.Codigo_Tipo_Poliza_Sugef, TPB.Codigo_Tipo_Bien
							 FROM	dbo.GAR_POLIZAS GPO
								INNER JOIN	dbo.GAR_POLIZAS_RELACIONADAS GPR
								ON GPR.Codigo_SAP = GPR.Codigo_SAP
								AND GPR.cod_operacion = GPR.cod_operacion
								LEFT OUTER JOIN dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
								ON TPB.Codigo_Tipo_Poliza_Sap = GPO.Tipo_Poliza
							WHERE	GPO.Estado_Registro = 1) TMP
			ON TMP.cod_operacion = TGR.cod_operacion
			AND TMP.cod_garantia_real = TGR.cod_garantia_real
			AND TMP.Codigo_Tipo_Bien = TGR.cod_tipo_bien
		WHERE	TGR.cod_usuario = @IDUsuario
			AND TGR.cod_tipo_operacion IN (1, 3)
		GROUP	BY
			TGR.cod_contabilidad, 
			TGR.cod_oficina,
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			TGR.cod_tipo_bien, 
			TGR.cod_bien,
			TGR.cod_tipo_mitigador, 
			TGR.cod_tipo_documento_legal, 
			TGR.fecha_presentacion, 
			TGR.cod_inscripcion, 
			TGR.porcentaje_responsabilidad, 
			TGR.fecha_constitucion, 
			TGR.cod_grado_gravamen, 
			TGR.cod_tipo_acreedor, 
			TGR.cedula_acreedor,
			TGR.cod_operacion_especial, 
			TGR.fecha_valuacion, 
			TGR.cedula_empresa, 
			TGR.cod_tipo_empresa, 
			TGR.cedula_perito,
			TGR.cod_tipo_perito, 
			TGR.monto_ultima_tasacion_terreno, 
			TGR.monto_ultima_tasacion_no_terreno, 
			TGR.monto_tasacion_actualizada_terreno, 
			TGR.monto_tasacion_actualizada_no_terreno, 
			TGR.fecha_ultimo_seguimiento, 
			TGR.monto_total_avaluo, 
			TGR.fecha_construccion, 
			TGR.cod_grado, 
			TGR.cedula_hipotecaria, 
			TGR.cedula_deudor, 
			GDE.nombre_deudor,
			MPC.bsmpc_dco_ofici,
			TGR.cod_clase_garantia,
			TMP.Codigo_SAP,
			TMP.Monto_Poliza_Colonizado,
			TMP.Fecha_Vencimiento,
			TMP.Codigo_Tipo_Poliza_Sugef
		ORDER	BY TGR.operacion

	END

END
