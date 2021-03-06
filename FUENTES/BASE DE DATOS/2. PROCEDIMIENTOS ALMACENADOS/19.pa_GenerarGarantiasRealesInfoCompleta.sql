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
	@psCedula_Usuario VARCHAR(30),
	@pbEjecutar_Parte BIT
	
AS

/******************************************************************
<Nombre>pa_GenerarGarantiasRealesInfoCompleta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la información necesaria, sobre las garantías reales asociadas a operaciones y giros, para generar el 
			 archivo SEGUI. Se implementan nuevos criterios de selección de la información.
			 La ejecución de este procedimiento almacenado se divide en dos partes, controladas por el parámetro "@pbEjecutar_Parte",
			 donde un valor igual a 0 equivale a la ejecución de la primera parte, un valor diferente de 0 equivale a la 
			 ejecución de la segunda parte.
</Descripción>
<Entradas>
	@psCedula_Usuario		= Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
	@pbEjecutar_Parte	= Indicador (tipo bit), que permite determinar si se ejecuta la primera parte del 
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
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>07/12/2015</Fecha>
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
	

	IF (@pbEjecutar_Parte = 0)
	BEGIN

		/*Se eliminan los registros que puedieron ser cargados por el usuario en algún procesamiento anterior*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_usuario = @psCedula_Usuario 

		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_usuario = @psCedula_Usuario 

		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @psCedula_Usuario
		
		DELETE	FROM dbo.TMP_VALUACIONES_REALES 
		WHERE	cod_usuario = @psCedula_Usuario 


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
	   
		/*Se obtienen las operaciones activas que posean una garantía real asociada*/	
		INSERT	INTO dbo.TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia,
										  cod_tipo_operacion, ind_contrato_vencido,
										  ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
			GRA.cod_operacion, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			1 AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_PRMOC MOC
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON MOC.cod_operacion = GRA.cod_operacion
		WHERE	MOC.Indicador_Es_Giro = 0
			AND GRA.cod_estado = 1 

		/*Se obtienen los giros activos de contratos vigentes y las garantías relacionadas a estos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
			MCA.Cod_Operacion_Giro, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			3 AS cod_tipo_operacion, 
			0 AS ind_contrato_vencido,
			0 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VIGENTES MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato

		/*Se obtienen las garantías de los contratos vencidos con giros activos y se les asignan a estos giros las garantías reales de sus contratos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
			MCA.Cod_Operacion_Giro, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			3 AS cod_tipo_operacion, 
			1 AS ind_contrato_vencido,
			1 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VENCIDOS_GA MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato

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
			1 AS ind_avaluo_completo,
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
			AND TOR.cod_usuario = @psCedula_Usuario

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
			AND cod_usuario = @psCedula_Usuario
		
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
			AND cod_usuario = @psCedula_Usuario

		UPDATE	dbo.TMP_VALUACIONES_REALES
		SET		ind_avaluo_completo = 0
		WHERE	cod_tipo_bien = 2
			AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
			AND monto_ultima_tasacion_no_terreno > 0
			AND monto_tasacion_actualizada_no_terreno > 0
			AND fecha_ultimo_seguimiento IS NOT NULL
			AND fecha_construccion IS NOT NULL
			AND cod_usuario = @psCedula_Usuario

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
			AND cod_usuario = @psCedula_Usuario

		/*Se eliminan los registros incompletos de los avalúos que posean almenos un avalúo completo*/
		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND EXISTS (SELECT	1
						FROM	dbo.TMP_VALUACIONES_REALES VAL
						WHERE	VAL.cod_garantia_real = TMP.cod_garantia_real
							AND VAL.cod_usuario = TMP.cod_usuario
							AND VAL.ind_avaluo_completo = 0)

		/*Se eliminan los registros cuya fecha de valuación sea menor a la más reciente, según el valor del campo ind_avaluo_completo*/
		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 0
			AND TMP.cod_usuario = @psCedula_Usuario
			AND TMP.fecha_valuacion <> (SELECT	MAX(VAL.fecha_valuacion)
										FROM	dbo.TMP_VALUACIONES_REALES VAL
										WHERE	VAL.cod_garantia_real = TMP.cod_garantia_real
											AND VAL.cod_usuario = TMP.cod_usuario
											AND VAL.ind_avaluo_completo = 0)

		DELETE	FROM dbo.TMP_VALUACIONES_REALES
		FROM	dbo.TMP_VALUACIONES_REALES TMP
		WHERE	TMP.ind_avaluo_completo = 1
			AND TMP.cod_usuario = @psCedula_Usuario
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
			2 AS cod_tipo_garantia,
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
			NULL AS Indicador_Coberturas_Obligatorias,
			--FIN RQ: RQ_MANT_2015062410418218_00090,
			GRO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se garega este campo.
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GO1.cod_operacion = GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GRO.cod_garantia_real = GGR.cod_garantia_real 
			LEFT OUTER JOIN  dbo.TMP_VALUACIONES_REALES TVR
			ON GGR.cod_garantia_real = TVR.cod_garantia_real
			AND TVR.cod_usuario = @psCedula_Usuario
			LEFT OUTER JOIN dbo.GAR_PERITO GPE
			ON TVR.cedula_perito = GPE.cedula_perito 
			INNER JOIN dbo.TMP_OPERACIONES TOR
			ON TOR.cod_operacion = GRO.cod_operacion
			AND TOR.cod_garantia = GRO.cod_garantia_real
		WHERE	GRO.cod_estado = 1
			AND TOR.cod_tipo_garantia = 2
			AND TOR.cod_usuario = @psCedula_Usuario
			AND TOR.cod_tipo_operacion IN (1, 3)
	END
	ELSE  
	/*Ejecuta parte 1 de acuerdo al valor del parametro
		@pbEjecutar_Parte >= 1
	*/
	BEGIN

		/*Se eliminan los registros incompletos*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia = 2
			AND COALESCE(cod_tipo_documento_legal, -1) = -1
			AND LEN(fecha_presentacion) = 0
			AND COALESCE(cod_tipo_mitigador, -1) = -1
			AND COALESCE(cod_inscripcion, -1) = -1

		/*Se eliminan los registros de hipotecas comunes duplicadas*/
		WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca,
					ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 10 AND 17
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1

		/*Se eliminan los registros de cédulas hipotecarias con clase 18 duplicadas*/
		WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado,
					ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia = 18
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1


		/*Se eliminan los registros de cédulas hipotecarias con clase diferente 18 duplicadas*/
		WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado,
					ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, cod_grado) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 20 AND 29
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1

		/*Se eliminan los registros de prendas duplicadas*/
		WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien,
					ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 30 AND 69
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1

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
			ON GRO.cod_garantia_real = TMP.cod_garantia_real
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia = 2
			
			
		UPDATE	TMP
		SET		TMP.fecha_valuacion = NULL
		FROM	dbo.TMP_GARANTIAS_REALES TMP
		WHERE	TMP.cod_usuario	 = @psCedula_Usuario
			AND TMP.cod_tipo_operacion IN (1, 3)
			AND TMP.cod_tipo_garantia = 2
			AND TMP.fecha_valuacion = '01/01/1900'

		/*Se actualiza a NULL el valor del porcentaje de aceptación y el porcentaje de responsabilidad cuando este es menor o igual a -1*/
		UPDATE	TMP
		SET		TMP.porcentaje_responsabilidad = NULL
		FROM	dbo.TMP_GARANTIAS_REALES TMP
		WHERE	TMP.cod_usuario	 = @psCedula_Usuario
			AND TMP.cod_tipo_operacion IN (1, 3)
			AND TMP.cod_tipo_garantia = 2
			AND TMP.porcentaje_responsabilidad <= -1

		UPDATE	TMP
		SET		TMP.Porcentaje_Aceptacion = 0
		FROM	dbo.TMP_GARANTIAS_REALES TMP
		WHERE	TMP.cod_usuario	 = @psCedula_Usuario
			AND TMP.cod_tipo_operacion IN (1, 3)
			AND TMP.cod_tipo_garantia = 2
			AND TMP.Porcentaje_Aceptacion <= -1



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
			COALESCE((CONVERT(VARCHAR(50), TGR.Porcentaje_Aceptacion)), '') AS PORCENTAJE_ACEPTACION, --RQ_MANT_2015111010495738_00610: Se cambia la referencia a este campo.
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
			END AS INDICADOR_POLIZA,
			COALESCE((CONVERT(VARCHAR(50), TGR.porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
		WHERE	TGR.cod_usuario = @psCedula_Usuario
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
			TMP.Codigo_Tipo_Poliza_Sugef,
			TGR.Porcentaje_Aceptacion
		ORDER	BY TGR.operacion

	END

END
