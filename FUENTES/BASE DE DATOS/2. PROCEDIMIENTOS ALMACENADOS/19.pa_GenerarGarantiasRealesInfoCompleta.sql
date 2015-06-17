USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pa_GenerarGarantiasRealesInfoCompleta] 
	@IDUsuario varchar(30),
	@piEjecutarParte bit
	
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

	--SELECT GETDATE(), 'Control Inicio'

	IF @piEjecutarParte = 0
	BEGIN

		--SELECT GETDATE(), 'Control Inicio Borrado'
		/*Se eliminan los registros que puedieron ser cargados por el usuario en algún procesamiento anterior*/
		DELETE FROM TMP_GARANTIAS_REALES 
		WHERE cod_tipo_operacion IN (1, 3) 
		AND cod_usuario = @IDUsuario 

		DELETE FROM TMP_OPERACIONES 
		WHERE cod_usuario = @IDUsuario 
		AND cod_tipo_garantia = 2 
		AND cod_tipo_operacion IN (1, 3)

		DELETE FROM TMP_OPERACIONES_DUPLICADAS 
		WHERE cod_usuario = @IDUsuario
		AND cod_tipo_garantia = 2  
		AND cod_tipo_operacion IN (1, 3)
		
		DELETE FROM TMP_VALUACIONES_REALES 
		WHERE cod_usuario = @IDUsuario 

		--SELECT GETDATE(), 'Control Final Borrado'

		/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
		DECLARE
			@lfecHoySinHora DATETIME,
			@lintFechaEntero INT

		/*Variable que servirá para almacenar los datos de la estructura PRMOC*/
		DECLARE	@ptPRMOC TABLE(	prmoc_pco_conta  tinyint,
								prmoc_pco_ofici  smallint,
								prmoc_pco_moned  tinyint,
								prmoc_pco_produ  tinyint,
								prmoc_pnu_oper   int,
								prmoc_pnu_contr  int,
								prmoc_pco_oficon smallint,
								prmoc_pcomonint  smallint,
								cod_operacion    bigint
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
		DECLARE	@ptPRMCA TABLE(	prmca_pco_ofici  smallint,
								prmca_pco_moned  tinyint,
								prmca_pco_produc tinyint,
								prmca_pnu_contr  int,
								cod_operacion    bigint
								PRIMARY KEY (prmca_pco_ofici, 
											 prmca_pco_moned, 
											 prmca_pco_produc, 
											 prmca_pnu_contr, 
											 cod_operacion)
							  )


		/*Variable que servirá para almacenar los datos de la estructura BSMPC*/
--		DECLARE	@ptBSMPC TABLE(	bsmpc_sco_ident  varchar(30),
--								bsmpc_dco_ofici  smallint,
--								cod_operacion    bigint
--								PRIMARY KEY (bsmpc_sco_ident, 
--											 cod_operacion)
--							  )

		SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		SET @lintFechaEntero =  CONVERT(int, CONVERT(varchar(8), @lfecHoySinHora, 112))

		----SELECT GETDATE(), 'Control Inicio PRMOC'
		/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
		INSERT @ptPRMOC
		SELECT	DISTINCT P.prmoc_pco_conta, 
						 P.prmoc_pco_ofici, 
						 P.prmoc_pco_moned, 
						 P.prmoc_pco_produ, 
						 P.prmoc_pnu_oper, 
						 P.prmoc_pnu_contr,
						 P.prmoc_pco_oficon,
						 P.prmoc_pcomonint,
						 O.cod_operacion
		FROM GAR_OPERACION O 
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRA	ON O.cod_operacion = GRA.cod_operacion 
		/*
			GAR_SICC_PRMOC = Maestro de operaciones desde el SICC
		*/
		INNER JOIN GAR_SICC_PRMOC P ON P.prmoc_pco_conta = O.cod_contabilidad
			AND P.prmoc_pco_ofici = O.cod_oficina
		AND P.prmoc_pco_moned = O.cod_moneda
		AND P.prmoc_pco_produ = O.cod_producto
		AND P.prmoc_pnu_oper = O.num_operacion
		
		WHERE	P.prmoc_pcoctamay <> 815 
			AND P.prmoc_pse_proces = 1 
			AND P.prmoc_estado = 'A'
			AND O.num_operacion IS NOT NULL 
			AND O.cod_estado = 1 

		----SELECT GETDATE(), 'Control FINAL PRMOC'

		/*Se obtienen los contratos que poseen giros activos*/
		INSERT @ptPRMCA
		SELECT	DISTINCT C.prmca_pco_ofici,
						 C.prmca_pco_moned,
						 C.prmca_pco_produc,
						 C.prmca_pnu_contr,
						 O.cod_operacion
		FROM	@ptPRMOC T
		/*
			GAR_SICC_PRMCA = Maestro de contratos desde el SICC
		*/
		INNER JOIN GAR_SICC_PRMCA C
			 ON C.prmca_pco_ofici = T.prmoc_pco_oficon
			 AND C.prmca_pco_moned = T.prmoc_pcomonint
			 AND C.prmca_pnu_contr = T.prmoc_pnu_contr
		INNER JOIN dbo.GAR_OPERACION O
			 ON O.cod_oficina = C.prmca_pco_ofici
			 AND O.cod_moneda = C.prmca_pco_moned
			 AND O.cod_producto = C.prmca_pco_produc
			 AND O.num_contrato = C.prmca_pnu_contr
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRA
			 ON O.cod_operacion = GRA.cod_operacion 
		WHERE T.prmoc_pnu_oper IS NOT NULL 
		 AND T.prmoc_pnu_contr > 0
		 AND C.prmca_estado = 'A'
		 AND O.num_operacion IS NULL
		 AND O.num_contrato > 0
	   
		/*Se obtienen las operaciones activas que posean una garantía real asociada*/	
		INSERT INTO TMP_OPERACIONES (
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia,
		cod_tipo_operacion,
		ind_contrato_vencido,
		ind_contrato_vencido_giros_activos,
		cod_oficina,
		cod_moneda,
		cod_producto,
		num_operacion,
		num_contrato,
		cod_usuario)
		SELECT DISTINCT P.cod_operacion, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			CASE WHEN P.prmoc_pnu_contr > 0 THEN 3
				 ELSE 1
			END AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			P.prmoc_pco_ofici,
			P.prmoc_pco_moned,
			P.prmoc_pco_produ,
			P.prmoc_pnu_oper,
			P.prmoc_pnu_contr,
			@IDUsuario AS cod_usuario

		FROM @ptPRMOC P
			INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON P.cod_operacion = GRA.cod_operacion

		WHERE P.prmoc_pnu_contr = 0
			AND GRA.cod_estado = 1 

		/*Se obtienen los contratos y las garantías relacionadas a estos*/
		INSERT INTO TMP_OPERACIONES(
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia,
		cod_tipo_operacion,
		ind_contrato_vencido,
		ind_contrato_vencido_giros_activos,
		cod_oficina,
		cod_moneda,
		cod_producto,
		num_operacion,
		num_contrato,
		cod_usuario)
		SELECT DISTINCT P.cod_operacion, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			2 AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			P.prmca_pco_ofici,
			P.prmca_pco_moned,
			P.prmca_pco_produc,
			NULL AS num_operacion,
			P.prmca_pnu_contr,
			@IDUsuario AS cod_usuario


		FROM @ptPRMCA P
		 INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRA
		 ON GRA.cod_operacion = P.cod_operacion


--		/*Se carga la variable tabla con los datos requeridos sobre los deudores*/
--		INSERT	@ptBSMPC
--		SELECT	DISTINCT O.cedula_deudor,
--						 B.bsmpc_dco_ofici,
--						 O.cod_operacion
--		FROM	@ptPRMOC P
--			INNER JOIN GAR_OPERACION O
--			ON O.cod_contabilidad = P.prmoc_pco_conta
--			AND O.cod_oficina = P.prmoc_pco_ofici
--			AND O.cod_moneda = P.prmoc_pco_moned
--			AND O.cod_producto = P.prmoc_pco_produ
--			AND O.num_operacion = P.prmoc_pnu_oper
--			INNER JOIN dbo.GAR_SICC_BSMPC B
--			ON (CONVERT(varchar(30), B.bsmpc_sco_ident)) = O.cedula_deudor 
--			INNER JOIN GAR_DEUDOR D
--			ON D.cedula_deudor = O.cedula_deudor
--		WHERE	P.prmoc_pnu_oper IS NOT NULL 
--			AND O.num_operacion IS NOT NULL 
--			AND O.cod_estado = 1 
--			AND B.bsmpc_estado = 'A'

		/*Se obtienen los giros asociados a los contratos y se les asigna las garantías relacionadas a este último*/
		----SELECT GETDATE(), 'Control giros'
		
		INSERT INTO TMP_OPERACIONES(
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia,
		cod_tipo_operacion,
		ind_contrato_vencido,
		ind_contrato_vencido_giros_activos,
		cod_oficina,
		cod_moneda,
		cod_producto,
		num_operacion,
		num_contrato,
		cod_oficina_contrato, 
		cod_moneda_contrato, 
		cod_producto_contrato,
		cod_usuario)
		SELECT DISTINCT 
			GO.cod_operacion, 
			T.cod_garantia,
			2 AS cod_tipo_garantia,
			CASE WHEN PRM.prmoc_pnu_contr > 0 THEN 3
				 ELSE 1
			END AS cod_tipo_operacion, 
			NULL AS ind_contrato_vencido,
			NULL AS ind_contrato_vencido_giros_activos,
			GO.cod_oficina,
			GO.cod_moneda,
			GO.cod_producto,
			GO.num_operacion,
			GO.num_contrato,
			T.cod_oficina AS cod_oficina_contrato,
			T.cod_moneda AS cod_moneda_contrato,
			T.cod_producto AS cod_producto_contrato,
			@IDUsuario AS cod_usuario

		FROM @ptPRMOC PRM
		INNER JOIN GAR_OPERACION GO ON GO.cod_contabilidad = PRM.prmoc_pco_conta
			AND GO.cod_oficina = PRM.prmoc_pco_ofici
			AND GO.cod_moneda = PRM.prmoc_pco_moned
			AND GO.cod_producto = PRM.prmoc_pco_produ
			AND GO.num_operacion = PRM.prmoc_pnu_oper
		INNER JOIN TMP_OPERACIONES T ON T.cod_oficina = PRM.prmoc_pco_oficon
		AND T.cod_moneda = PRM.prmoc_pcomonint
		AND T.num_contrato = PRM.prmoc_pnu_contr

		WHERE PRM.prmoc_pnu_contr > 0
		AND GO.cod_estado = 1 
		AND GO.num_contrato > 0
		AND T.cod_tipo_operacion = 2
		AND T.cod_usuario = @IDUsuario

		----SELECT GETDATE(), 'Control Final giros'

		/*Se eliminan los contratos que fueron cargados*/
		DELETE FROM TMP_OPERACIONES 
		WHERE cod_tipo_garantia = 2 
		AND cod_usuario = @IDUsuario 
		AND cod_tipo_operacion = 2

		--SELECT GETDATE(), 'Control valuaciones'
		/*Se cargan los valores de los avalúos en la tabla temporal respectiva*/
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		INSERT INTO TMP_VALUACIONES_REALES(
		cod_garantia_real,
		fecha_valuacion,
		cedula_empresa,
		cedula_perito,
		monto_ultima_tasacion_terreno,
		monto_ultima_tasacion_no_terreno,
		monto_tasacion_actualizada_terreno,
		monto_tasacion_actualizada_no_terreno,
		fecha_ultimo_seguimiento,
		monto_total_avaluo,
		cod_recomendacion_perito,
		cod_inspeccion_menor_tres_meses,
		fecha_construccion,
		cod_tipo_bien,
		ind_avaluo_completo,
		cod_usuario)
		SELECT DISTINCT a.cod_garantia_real, 
			a.fecha_valuacion, 
			a.cedula_empresa, 
			a.cedula_perito, 
			a.monto_ultima_tasacion_terreno, 
			a.monto_ultima_tasacion_no_terreno, 
			a.monto_tasacion_actualizada_terreno, 
			a.monto_tasacion_actualizada_no_terreno, 
			a.fecha_ultimo_seguimiento, 
			a.monto_total_avaluo, 
			a.cod_recomendacion_perito, 
			a.cod_inspeccion_menor_tres_meses, 
			a.fecha_construccion,
			d.cod_tipo_bien, 
			1 AS grado_completo,
			c.cod_usuario

		FROM GAR_VALUACIONES_REALES a
			INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION b
			ON b.cod_garantia_real = a.cod_garantia_real
			INNER JOIN TMP_OPERACIONES c 
			ON c.cod_garantia = b.cod_garantia_real
			AND c.cod_operacion = b.cod_operacion
			INNER JOIN GAR_GARANTIA_REAL d
			ON d.cod_garantia_real = c.cod_garantia

		WHERE c.cod_tipo_garantia = 2
			AND c.cod_tipo_operacion IN (1, 3)
			AND c.cod_usuario = @IDUsuario

	
		/*Se eliminan los registros de los avalúos considerados basura*/
		DELETE FROM TMP_VALUACIONES_REALES
		WHERE cedula_empresa IS NULL
			AND cedula_perito IS NULL
			AND (monto_ultima_tasacion_terreno IS NULL OR monto_ultima_tasacion_terreno = 0)
			AND (monto_ultima_tasacion_no_terreno IS NULL OR monto_ultima_tasacion_no_terreno = 0)
			AND (monto_tasacion_actualizada_terreno IS NULL OR monto_tasacion_actualizada_terreno = 0)
			AND (monto_tasacion_actualizada_no_terreno IS NULL OR monto_tasacion_actualizada_no_terreno = 0)
			AND fecha_ultimo_seguimiento IS NULL
			AND fecha_construccion IS NULL
			AND cod_usuario = @IDUsuario
		
		--SELECT GETDATE(), 'Control valuaciones fin'

		/*Se actualiza el campo grado_completo con el código igual a 0, indicando los registros completos, según el tipo de bien*/
		UPDATE TMP_VALUACIONES_REALES
		SET ind_avaluo_completo = 0 
		WHERE  cod_tipo_bien = 1
		--AND ((cedula_empresa IS NOT NULL AND cedula_perito IS NULL) OR (cedula_empresa IS NULL AND cedula_perito IS NOT NULL))
		AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
		AND monto_ultima_tasacion_terreno > 0
		AND (monto_ultima_tasacion_no_terreno IS NULL OR monto_ultima_tasacion_no_terreno = 0)
		AND monto_tasacion_actualizada_terreno > 0
		AND (monto_tasacion_actualizada_no_terreno IS NULL OR monto_tasacion_actualizada_no_terreno = 0)
		AND fecha_ultimo_seguimiento IS NOT NULL
		AND fecha_construccion IS NULL
		AND cod_usuario = @IDUsuario

		UPDATE TMP_VALUACIONES_REALES
		SET ind_avaluo_completo = 0
		WHERE cod_tipo_bien = 2
		--AND ((cedula_empresa IS NOT NULL AND cedula_perito IS NULL) OR (cedula_empresa IS NULL AND cedula_perito IS NOT NULL))
		AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
		--AND monto_ultima_tasacion_terreno >= 0
		--AND monto_tasacion_actualizada_terreno >= 0
		AND monto_ultima_tasacion_no_terreno > 0
		AND monto_tasacion_actualizada_no_terreno > 0
		AND fecha_ultimo_seguimiento IS NOT NULL
		AND fecha_construccion IS NOT NULL
		AND cod_usuario = @IDUsuario

		UPDATE TMP_VALUACIONES_REALES
		SET ind_avaluo_completo = 0
		WHERE cod_tipo_bien NOT IN (1,2)
		--AND ((cedula_empresa IS NOT NULL AND cedula_perito IS NULL) OR (cedula_empresa IS NULL AND cedula_perito IS NOT NULL))
		AND (cedula_perito IS NOT NULL OR cedula_empresa IS NOT NULL) 
		AND (monto_ultima_tasacion_terreno IS NULL OR monto_ultima_tasacion_terreno = 0)
		AND (monto_tasacion_actualizada_terreno IS NULL OR  monto_tasacion_actualizada_terreno = 0)
		AND monto_ultima_tasacion_no_terreno > 0
		AND monto_tasacion_actualizada_no_terreno > 0
		AND fecha_ultimo_seguimiento IS NOT NULL
		AND fecha_construccion IS NOT NULL
		AND cod_usuario = @IDUsuario


		/*Se eliminan los registros incompletos de los avalúos que posean almenos un avalúo completo*/
		DELETE FROM TMP_VALUACIONES_REALES
		FROM TMP_VALUACIONES_REALES TMP
		WHERE EXISTS (SELECT 1
						  FROM TMP_VALUACIONES_REALES VAL
						  WHERE VAL.cod_garantia_real = TMP.cod_garantia_real
						  AND VAL.cod_usuario = TMP.cod_usuario
						  AND VAL.ind_avaluo_completo = 0)
		AND TMP.ind_avaluo_completo = 1
		AND TMP.cod_usuario = @IDUsuario

		/*Se eliminan los registros cuya fecha de valuación sea menor a la más reciente, según el valor del campo ind_avaluo_completo*/
		DELETE FROM TMP_VALUACIONES_REALES
		FROM TMP_VALUACIONES_REALES TMP
		WHERE TMP.fecha_valuacion <> (SELECT MAX(VAL.fecha_valuacion)
						  FROM TMP_VALUACIONES_REALES VAL
						  WHERE VAL.cod_garantia_real = TMP.cod_garantia_real
							AND VAL.cod_usuario = TMP.cod_usuario
							AND VAL.ind_avaluo_completo = 0)
		AND TMP.ind_avaluo_completo = 0
		AND TMP.cod_usuario = @IDUsuario

		DELETE FROM TMP_VALUACIONES_REALES
		FROM TMP_VALUACIONES_REALES TMP
		WHERE TMP.fecha_valuacion <> (SELECT MAX(VAL.fecha_valuacion)
						  FROM TMP_VALUACIONES_REALES VAL
						  WHERE VAL.cod_garantia_real = TMP.cod_garantia_real
							AND VAL.cod_usuario = TMP.cod_usuario
							AND VAL.ind_avaluo_completo = 1)
		AND TMP.ind_avaluo_completo = 1
		AND TMP.cod_usuario = @IDUsuario

		/*Se selecciona la información de la garantía real asociada a los contratos*/
		INSERT INTO TMP_GARANTIAS_REALES
		SELECT DISTINCT 
			a.cod_contabilidad, 
			a.cod_oficina, 
			a.cod_moneda, 
			a.cod_producto, 
			a.num_operacion AS operacion, 
			c.cod_tipo_bien, 
			CASE c.cod_tipo_garantia_real  
				WHEN 1 THEN ISNULL((CONVERT(varchar(2),c.cod_partido)), '') + ISNULL(c.numero_finca, '')  
				WHEN 2 THEN ISNULL((CONVERT(varchar(2),c.cod_partido)), '') + ISNULL(c.numero_finca, '') 
				WHEN 3 THEN ISNULL(c.cod_clase_bien, '') + ISNULL(c.num_placa_bien, '')
			END AS cod_bien, 
			b.cod_tipo_mitigador, 
			b.cod_tipo_documento_legal, 
			b.monto_mitigador, 
			CASE WHEN CONVERT(varchar(10),b.fecha_presentacion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),b.fecha_presentacion,103)
			END AS fecha_presentacion,
			b.cod_inscripcion, 
			b.porcentaje_responsabilidad, 
			CASE WHEN CONVERT(varchar(10),b.fecha_constitucion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),b.fecha_constitucion,103)
			END AS fecha_constitucion, 
			b.cod_grado_gravamen, 
			b.cod_tipo_acreedor, 
			b.cedula_acreedor, 
			CASE WHEN CONVERT(varchar(10),b.fecha_vencimiento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),b.fecha_vencimiento,103)
			END AS fecha_vencimiento, 
			b.cod_operacion_especial, 
			CASE WHEN CONVERT(varchar(10),d.fecha_valuacion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),d.fecha_valuacion,103)
			END AS fecha_valuacion, 
			d.cedula_empresa, 
			CASE WHEN d.cedula_empresa IS NULL THEN NULL ELSE 2 end AS cod_tipo_empresa, 
			d.cedula_perito, 
			e.cod_tipo_persona AS cod_tipo_perito, 
			d.monto_ultima_tasacion_terreno, 
			d.monto_ultima_tasacion_no_terreno, 
			d.monto_tasacion_actualizada_terreno, 
			d.monto_tasacion_actualizada_no_terreno, 
			CASE WHEN CONVERT(varchar(10),d.fecha_ultimo_seguimiento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),d.fecha_ultimo_seguimiento,103)
			END AS fecha_ultimo_seguimiento, 
			ISNULL(d.monto_tasacion_actualizada_terreno,0) + ISNULL(d.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE WHEN CONVERT(varchar(10),d.fecha_construccion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(varchar(10),d.fecha_construccion,103)
			END AS fecha_construccion,
			c.cod_grado,
			c.cedula_hipotecaria,
			c.cod_clase_garantia,
			a.cod_operacion,
			c.cod_garantia_real,
			c.cod_tipo_garantia_real,
			ISNULL(c.numero_finca,'') AS numero_finca,
			ISNULL(c.num_placa_bien,'') AS num_placa_bien,
			ISNULL(c.cod_clase_bien,'') AS cod_clase_bien,
			a.cedula_deudor,
			1 AS cod_estado,
			NULL AS cod_liquidez,
			NULL AS cod_tenencia,
			NULL AS cod_moneda,
			NULL AS cod_partido,
			NULL AS cod_tipo_garantia,
			NULL AS Garantia_Real,
			NULL AS fecha_prescripcion,
			f.cod_tipo_operacion,
			f.ind_contrato_vencido,
			1 AS ind_duplicidad,
			f.cod_usuario

		FROM 
			GAR_OPERACION a 
			INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION b 
			ON a.cod_operacion = b.cod_operacion 
			INNER JOIN GAR_GARANTIA_REAL c 
			ON b.cod_garantia_real = c.cod_garantia_real 
			LEFT OUTER JOIN  TMP_VALUACIONES_REALES d
			ON c.cod_garantia_real = d.cod_garantia_real
			AND d.cod_usuario = @IDUsuario
			LEFT OUTER JOIN GAR_PERITO e 
			ON d.cedula_perito = e.cedula_perito 
			INNER JOIN TMP_OPERACIONES f
			ON f.cod_operacion = b.cod_operacion
			AND f.cod_garantia = b.cod_garantia_real

		WHERE b.cod_estado = 1
			AND f.cod_tipo_garantia = 2
			AND f.cod_usuario = @IDUsuario
			AND f.cod_tipo_operacion IN (1, 3)
--			AND EXISTS (SELECT 1
--						FROM dbo.GAR_SICC_PRMGT g
--						WHERE g.prmgt_pco_conta = a.cod_contabilidad
--						 AND g.prmgt_pco_ofici  = CASE	WHEN f.cod_tipo_operacion = 1 THEN f.cod_oficina 
--														ELSE f.cod_oficina_contrato
--												  END
--						 AND g.prmgt_pco_moned  = CASE	WHEN f.cod_tipo_operacion = 1 THEN f.cod_moneda 
--														ELSE f.cod_moneda_contrato
--												  END
--						 AND g.prmgt_pco_produ  = CASE	WHEN f.cod_tipo_operacion = 1 THEN f.cod_producto 
--														ELSE 10
--												  END
--						 AND g.prmgt_pnu_oper   = CASE	WHEN f.cod_tipo_operacion = 1 THEN f.num_operacion 
--														ELSE f.num_contrato
--												  END
--						 AND g.prmgt_pcoclagar  = c.cod_clase_garantia
--						 AND g.prmgt_pnu_part   = ISNULL(c.cod_partido, g.prmgt_pnu_part)
--						 AND g.prmgt_pco_grado  = ISNULL(c.cod_grado, g.prmgt_pco_grado)
--						 AND g.prmgt_pnuidegar  = CASE WHEN c.cod_tipo_garantia_real = 1 THEN dbo.ufn_ConvertirCodigoGarantia(c.numero_finca)
--													   WHEN c.cod_tipo_garantia_real = 2 THEN dbo.ufn_ConvertirCodigoGarantia(c.numero_finca)
--													   ELSE dbo.ufn_ConvertirCodigoGarantia(c.num_placa_bien)
--												  END
--						 AND g.prmgt_estado = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/
			

	--SELECT GETDATE(), 'Final proceso'

	END
	ELSE  
	/*Ejecuta parte 1 de acuerdo al valor del parametro
		@piEjecutarParte = 1
	*/
	BEGIN
		--SELECT GETDATE(), 'Control inicio devolucion'
		/*Se obtienen las operaciones duplicadas*/
		INSERT INTO TMP_OPERACIONES_DUPLICADAS
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

		FROM TMP_GARANTIAS_REALES

		WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

		GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, cod_bien, cod_tipo_operacion
		HAVING COUNT(1) > 1

		/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
		  Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
		UPDATE TMP_GARANTIAS_REALES SET 
		ind_duplicidad = 2
		FROM TMP_GARANTIAS_REALES GR
		WHERE EXISTS (SELECT 1 
					  FROM TMP_OPERACIONES_DUPLICADAS TGR
					  WHERE GR.cod_oficina = TGR.cod_oficina
						AND GR.cod_moneda = TGR.cod_moneda
						AND GR.cod_producto = TGR.cod_producto
						AND GR.operacion = TGR.operacion
						AND ISNULL(GR.cod_bien, '') = ISNULL(TGR.cod_garantia_sicc, '')
						AND ISNULL(GR.cod_usuario, '') = ISNULL(TGR.cod_usuario, '')
						AND TGR.cod_tipo_operacion IN (1, 3)
						AND TGR.cod_tipo_garantia = 2
						AND GR.cod_tipo_documento_legal IS NULL
						AND GR.fecha_presentacion IS NULL
						AND GR.cod_tipo_mitigador IS NULL
						AND GR.cod_inscripcion IS NULL)
		AND GR.cod_usuario = @IDUsuario
		AND GR.cod_tipo_operacion IN (1, 3)


		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE FROM TMP_GARANTIAS_REALES WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

		/*Se eliminan los duplicados obtenidos*/
		DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario  AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de hipoteca común duplicadas*/
		INSERT INTO TMP_OPERACIONES_DUPLICADAS
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

		FROM TMP_GARANTIAS_REALES

		WHERE cod_tipo_garantia_real = 1 
			AND cod_tipo_operacion IN (1, 3)
			AND cod_usuario = @IDUsuario

		GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
		HAVING COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE TMP_OPERACIONES_DUPLICADAS
		SET cod_garantia = TT.cod_llave
		FROM TMP_OPERACIONES_DUPLICADAS D
		INNER JOIN TMP_GARANTIAS_REALES TT
		ON TT.cod_oficina = D.cod_oficina
		AND TT.cod_moneda = D.cod_moneda
		AND TT.cod_producto = D.cod_producto
		AND TT.operacion = D.operacion
		AND ISNULL(TT.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
		WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
									FROM TMP_GARANTIAS_REALES T
									WHERE T.cod_oficina = D.cod_oficina
									AND T.cod_moneda = D.cod_moneda
									AND T.cod_producto = D.cod_producto
									AND T.operacion = D.operacion
									AND ISNULL(T.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
									AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
									AND T.cod_tipo_garantia_real = 1
									AND T.cod_tipo_operacion IN (1, 3)
									AND D.cod_tipo_garantia = 2)
		AND TT.cod_tipo_garantia_real = 1
		AND TT.cod_usuario = @IDUsuario
		AND TT.cod_tipo_operacion IN (1, 3)


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE TMP_GARANTIAS_REALES
		SET ind_duplicidad = 2
		FROM TMP_GARANTIAS_REALES GR
		WHERE EXISTS (SELECT 1 
					  FROM TMP_OPERACIONES_DUPLICADAS TGR
					  WHERE GR.cod_oficina = TGR.cod_oficina
						AND GR.cod_moneda = TGR.cod_moneda
						AND GR.cod_producto = TGR.cod_producto
						AND GR.operacion = TGR.operacion
						AND ISNULL(GR.numero_finca, '') = ISNULL(TGR.cod_garantia_sicc, '')
						AND GR.cod_llave <> TGR.cod_garantia
						AND ISNULL(GR.cod_usuario, '') = ISNULL(TGR.cod_usuario, '')
						AND GR.cod_tipo_garantia_real = 1
						AND GR.cod_tipo_operacion IN (1, 3)
						AND TGR.cod_tipo_garantia = 2)
		AND GR.cod_tipo_garantia_real = 1
		AND GR.cod_usuario = @IDUsuario
		AND GR.cod_tipo_operacion IN (1, 3)


		/*Se eliminan los duplicados obtenidos*/
		DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario  AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
		INSERT INTO TMP_OPERACIONES_DUPLICADAS
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

		FROM TMP_GARANTIAS_REALES

		WHERE cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia_real = 2

		GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
		HAVING COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE TMP_OPERACIONES_DUPLICADAS
		SET cod_garantia = TT.cod_llave
		FROM TMP_OPERACIONES_DUPLICADAS D
		INNER JOIN TMP_GARANTIAS_REALES TT
		ON TT.cod_oficina = D.cod_oficina
		AND TT.cod_moneda = D.cod_moneda
		AND TT.cod_producto = D.cod_producto
		AND TT.operacion = D.operacion
		AND ISNULL(TT.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
		AND TT.cod_grado = D.cod_grado
		WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
									FROM TMP_GARANTIAS_REALES T
									WHERE T.cod_oficina = D.cod_oficina
									AND T.cod_moneda = D.cod_moneda
									AND T.cod_producto = D.cod_producto
									AND T.operacion = D.operacion
									AND ISNULL(T.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
									AND T.cod_grado = D.cod_grado
									AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
									AND T.cod_tipo_garantia_real = 2
									AND T.cod_tipo_operacion IN (1, 3)
									AND D.cod_tipo_garantia = 2)
		AND TT.cod_tipo_garantia_real = 2
		AND TT.cod_usuario = @IDUsuario
		AND TT.cod_tipo_operacion IN (1, 3)


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE TMP_GARANTIAS_REALES
		SET ind_duplicidad = 2
		FROM TMP_GARANTIAS_REALES GR
		WHERE EXISTS (SELECT 1 
					  FROM TMP_OPERACIONES_DUPLICADAS TGR
					  WHERE GR.cod_oficina = TGR.cod_oficina
						AND GR.cod_moneda = TGR.cod_moneda
						AND GR.cod_producto = TGR.cod_producto
						AND GR.operacion = TGR.operacion
						AND ISNULL(GR.numero_finca, '') = ISNULL(TGR.cod_garantia_sicc, '')
						AND GR.cod_grado = TGR.cod_grado
						AND GR.cod_llave <> TGR.cod_garantia
						AND ISNULL(GR.cod_usuario, '') = ISNULL(TGR.cod_usuario, '')
						AND GR.cod_tipo_garantia_real = 2
						AND GR.cod_tipo_operacion IN (1, 3)
						AND TGR.cod_tipo_garantia = 2)
		AND GR.cod_tipo_garantia_real = 2
		AND GR.cod_usuario = @IDUsuario
		AND GR.cod_tipo_operacion IN (1, 3)

		/*Se eliminan los duplicados obtenidos*/
		DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario  AND cod_tipo_operacion IN (1, 3)

		/*Se obtienen las garantías reales de prenda duplicadas*/
		INSERT INTO TMP_OPERACIONES_DUPLICADAS
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

		FROM TMP_GARANTIAS_REALES

		WHERE cod_usuario = @IDUsuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia_real = 3

		GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
		HAVING COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE TMP_OPERACIONES_DUPLICADAS
		SET cod_garantia = TT.cod_llave
		FROM TMP_OPERACIONES_DUPLICADAS D
		INNER JOIN TMP_GARANTIAS_REALES TT
		ON TT.cod_oficina = D.cod_oficina
		AND TT.cod_moneda = D.cod_moneda
		AND TT.cod_producto = D.cod_producto
		AND TT.operacion = D.operacion
		AND ISNULL(TT.num_placa_bien, '') = ISNULL(D.cod_garantia_sicc, '')
		WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
									FROM TMP_GARANTIAS_REALES T
									WHERE T.cod_oficina = D.cod_oficina
									AND T.cod_moneda = D.cod_moneda
									AND T.cod_producto = D.cod_producto
									AND T.operacion = D.operacion
									AND ISNULL(T.num_placa_bien, '') = ISNULL(D.cod_garantia_sicc, '')
									AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
									AND T.cod_tipo_garantia_real = 3
									AND T.cod_tipo_operacion IN (1, 3)
									AND D.cod_tipo_garantia = 2)
		AND TT.cod_tipo_garantia_real = 3
		AND TT.cod_usuario = @IDUsuario
		AND TT.cod_tipo_operacion IN (1, 3)


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE TMP_GARANTIAS_REALES
		SET ind_duplicidad = 2
		FROM TMP_GARANTIAS_REALES GR
		WHERE EXISTS (SELECT 1 
					  FROM TMP_OPERACIONES_DUPLICADAS TGR
					  WHERE GR.cod_oficina = TGR.cod_oficina
						AND GR.cod_moneda = TGR.cod_moneda
						AND GR.cod_producto = TGR.cod_producto
						AND GR.operacion = TGR.operacion
						AND ISNULL(GR.num_placa_bien, '') = ISNULL(TGR.cod_garantia_sicc, '')
						AND GR.cod_llave <> TGR.cod_garantia
						AND ISNULL(GR.cod_usuario, '') = ISNULL(TGR.cod_usuario, '')
						AND GR.cod_tipo_garantia_real = 3
						AND GR.cod_tipo_operacion IN (1, 3)
						AND TGR.cod_tipo_garantia = 2)
		AND GR.cod_tipo_garantia_real = 3
		AND GR.cod_usuario = @IDUsuario
		AND GR.cod_tipo_operacion IN (1, 3)

		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE FROM TMP_GARANTIAS_REALES WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

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
			a.cod_contabilidad AS CONTABILIDAD,
			a.cod_oficina AS OFICINA,
			a.cod_moneda AS MONEDA,
			a.cod_producto AS PRODUCTO,
			a.operacion AS OPERACION,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_bien)), '') as TIPO_BIEN,
			ISNULL((CONVERT(VARCHAR(50), a.cod_bien)), '') as CODIGO_BIEN,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_mitigador)), '') as TIPO_MITIGADOR,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_documento_legal)), '') as TIPO_DOCUMENTO_LEGAL,
			ISNULL((CONVERT(VARCHAR(50),(max(a.monto_mitigador)))), '') as MONTO_MITIGADOR,
			ISNULL((CONVERT(VARCHAR(10), a.fecha_presentacion, 103)), '') as FECHA_PRESENTACION,
			ISNULL((CONVERT(VARCHAR(3), a.cod_inscripcion)), '') as INDICADOR_INSCRIPCION,
			ISNULL((CONVERT(VARCHAR(50), a.porcentaje_responsabilidad)), '') as PORCENTAJE_ACEPTACION,
			ISNULL((CONVERT(VARCHAR(10), a.fecha_constitucion, 103)), '') as FECHA_CONSTITUCION,
			ISNULL((CONVERT(VARCHAR(3), a.cod_grado_gravamen)), '') as GRADO_GRAVAMEN,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_acreedor)), '') as TIPO_PERSONA_ACREEDOR,
			ISNULL(a.cedula_acreedor, '') as CEDULA_ACREEDOR,
			ISNULL((CONVERT(VARCHAR(10), (max(a.fecha_vencimiento)), 103)), '') as FECHA_VENCIMIENTO,
			ISNULL((CONVERT(VARCHAR(3), a.cod_operacion_especial)), '') as OPERACION_ESPECIAL,
			ISNULL((CONVERT(VARCHAR(10), a.fecha_valuacion, 103)), '') as FECHA_VALUACION,
			ISNULL(a.cedula_empresa, '') as CEDULA_EMPRESA,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_empresa)), '') as TIPO_PERSONA_EMPRESA,
			ISNULL(a.cedula_perito, '') as CEDULA_PERITO,
			ISNULL((CONVERT(VARCHAR(3), a.cod_tipo_perito)), '')as TIPO_PERSONA_PERITO,
			ISNULL((CONVERT(VARCHAR(50), a.monto_ultima_tasacion_terreno)), '') as MONTO_ULTIMA_TASACION_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), a.monto_ultima_tasacion_no_terreno)), '') as MONTO_ULTIMA_TASACION_NO_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), a.monto_tasacion_actualizada_terreno)), '') as MONTO_TASACION_ACTUALIZADA_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), a.monto_tasacion_actualizada_no_terreno)), '') as MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
			ISNULL((CONVERT(VARCHAR(10), a.fecha_ultimo_seguimiento, 103)), '') as FECHA_ULTIMO_SEGUIMIENTO,
			ISNULL((CONVERT(VARCHAR(50), a.monto_total_avaluo)), '') as MONTO_TOTAL_AVALUO,
			ISNULL((CONVERT(VARCHAR(10), a.fecha_construccion, 103)), '') as FECHA_CONSTRUCCION,
			ISNULL((CONVERT(VARCHAR(3), a.cod_grado)), '') as COD_GRADO,
			ISNULL(a.cedula_hipotecaria, '') as CEDULA_HIPOTECARIA,
			ISNULL(a.cedula_deudor, '') as CEDULA_DEUDOR,
			ISNULL(c.nombre_deudor, '') as NOMBRE_DEUDOR,
			ISNULL((CONVERT(VARCHAR(5), b.bsmpc_dco_ofici)), '') as OFICINA_DEUDOR,
			ISNULL((CONVERT(VARCHAR(3), a.cod_clase_garantia)), '') as TIPO_GARANTIA

		FROM 
			TMP_GARANTIAS_REALES a 
			INNER JOIN dbo.GAR_SICC_BSMPC b
				ON b.bsmpc_sco_ident = CONVERT(DECIMAL, a.cedula_deudor)
				AND b.bsmpc_estado = 'A'		
			INNER JOIN GAR_DEUDOR c
				ON a.cedula_deudor = c.cedula_deudor
		
		WHERE a.cod_usuario = @IDUsuario
			AND a.cod_tipo_operacion IN (1, 3)

		GROUP BY
			a.cod_contabilidad, 
			a.cod_oficina,
			a.cod_moneda, 
			a.cod_producto, 
			a.operacion, 
			a.cod_tipo_bien, 
			a.cod_bien,
			a.cod_tipo_mitigador, 
			a.cod_tipo_documento_legal, 
			a.fecha_presentacion, 
			a.cod_inscripcion, 
			a.porcentaje_responsabilidad, 
			a.fecha_constitucion, 
			a.cod_grado_gravamen, 
			a.cod_tipo_acreedor, 
			a.cedula_acreedor,
			a.cod_operacion_especial, 
			a.fecha_valuacion, 
			a.cedula_empresa, 
			a.cod_tipo_empresa, 
			a.cedula_perito,
			a.cod_tipo_perito, 
			a.monto_ultima_tasacion_terreno, 
			a.monto_ultima_tasacion_no_terreno, 
			a.monto_tasacion_actualizada_terreno, 
			a.monto_tasacion_actualizada_no_terreno, 
			a.fecha_ultimo_seguimiento, 
			a.monto_total_avaluo, 
			a.fecha_construccion, 
			a.cod_grado, 
			a.cedula_hipotecaria, 
			a.cedula_deudor, 
			c.nombre_deudor,
			b.bsmpc_dco_ofici,
			a.cod_clase_garantia

		ORDER BY a.operacion

		--SELECT GETDATE(), 'Control FINAL devolucion'

		/*Se elimina el contenido trabajado por el usuario en las diferentes tablas utilizadas*/
		--DELETE FROM TMP_GARANTIAS_REALES WHERE cod_tipo_operacion IN (1, 3) AND cod_usuario = @IDUsuario
		--DELETE FROM TMP_OPERACIONES WHERE cod_tipo_garantia = 2 AND cod_usuario = @IDUsuario  AND cod_tipo_operacion IN (1, 3)
		--DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario  AND cod_tipo_operacion IN (1, 3)
		--DELETE FROM TMP_VALUACIONES_REALES WHERE cod_usuario = @IDUsuario 

	END

END
