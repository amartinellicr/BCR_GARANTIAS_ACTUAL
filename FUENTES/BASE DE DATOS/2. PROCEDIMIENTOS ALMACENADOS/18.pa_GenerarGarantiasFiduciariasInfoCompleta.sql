SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_GenerarGarantiasFiduciariasInfoCompleta]
	@IDUsuario varchar(30)
AS

/******************************************************************
<Nombre>pa_GenerarGarantiasFiduciariasInfoCompleta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la información necesaria para generar el archivo SEGUI, tanto de operaciones 
             como de tarjetas. Se implementan nuevos criterios de selección de la información.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
<Fecha>18/11/2010</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
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

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 1 AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 1 AND cod_tipo_operacion IN (1, 3) 

	/*Se obtienen las operaciones*/
	INSERT INTO TMP_OPERACIONES	(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		GFA.cod_garantia_fiduciaria,
		1 AS cod_tipo_garantia,
		1 AS cod_tipo_operacion, 
		NULL AS ind_contrato_vencido,
		NULL AS ind_contrato_vencido_giros_activos,
		GO.cod_oficina,
		GO.cod_moneda,
		GO.cod_producto,
		GO.num_operacion,
		GO.num_contrato,
		@IDUsuario AS cod_usuario

	FROM GAR_OPERACION GO
	INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFA
	ON GFA.cod_operacion = GO.cod_operacion
	WHERE GO.num_operacion IS NOT NULL 
		AND GO.cod_estado = 1
		AND GO.num_contrato = 0 
		AND EXISTS (	SELECT 1
						FROM GAR_SICC_PRMOC PRM
						WHERE PRM.prmoc_pnu_oper =  CONVERT(INT, GO.num_operacion)
						AND	PRM.prmoc_pco_ofici  =  CONVERT(SMALLINT, GO.cod_oficina)
						AND PRM.prmoc_pco_moned  =  CONVERT(TINYINT, GO.cod_moneda)
						AND PRM.prmoc_pco_produ  =  CONVERT(TINYINT, GO.cod_producto)
						AND PRM.prmoc_pco_conta  =  CONVERT(TINYINT, GO.cod_contabilidad)
						AND PRM.prmoc_pnu_contr  =  0
						AND PRM.prmoc_pcoctamay  <> 815 
						AND PRM.prmoc_pse_proces =  1 
						AND PRM.prmoc_estado     =  'A')

	/*Se obtienen los contratos y las garantías relacionadas a estos*/
	INSERT INTO TMP_OPERACIONES	(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		GFA.cod_garantia_fiduciaria,
		1 AS cod_tipo_garantia,
		2 AS cod_tipo_operacion, 
		NULL AS ind_contrato_vencido,
		NULL AS ind_contrato_vencido_giros_activos,
		GO.cod_oficina,
		GO.cod_moneda,
		GO.cod_producto,
		GO.num_operacion,
		GO.num_contrato,
		@IDUsuario AS cod_usuario

	FROM GAR_OPERACION GO
	INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFA
	ON GFA.cod_operacion = GO.cod_operacion

	WHERE GO.num_operacion IS NULL 
	AND EXISTS (	SELECT 1
					FROM GAR_SICC_PRMCA PRC	
					WHERE PRC.prmca_pnu_contr = CONVERT(DECIMAL, GO.num_contrato)
					AND PRC.prmca_pco_ofici   = CONVERT(SMALLINT, GO.cod_oficina)
					AND PRC.prmca_pco_moned   = CONVERT(TINYINT, GO.cod_moneda)
					AND PRC.prmca_estado      = 'A')

	/*Se obtienen los giros asociados a los contratos y se les asigna las garantías relacionadas a este último*/
	INSERT INTO TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_oficina_contrato, cod_moneda_contrato, cod_producto_contrato, cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		T.cod_garantia,
		1 AS cod_tipo_garantia,
		3 AS cod_tipo_operacion, 
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


	FROM GAR_OPERACION GO
	INNER JOIN dbo.GAR_SICC_PRMOC PRM
	ON PRM.prmoc_pnu_oper    =  CONVERT(INT, GO.num_operacion)
	AND	PRM.prmoc_pco_ofici  =  CONVERT(SMALLINT, GO.cod_oficina)
	AND PRM.prmoc_pco_moned  =  CONVERT(TINYINT, GO.cod_moneda)
	AND PRM.prmoc_pco_produ  =  CONVERT(TINYINT, GO.cod_producto)
	AND PRM.prmoc_pco_conta  =  CONVERT(TINYINT, GO.cod_contabilidad)
	INNER JOIN TMP_OPERACIONES T
	ON PRM.prmoc_pco_oficon = CONVERT(SMALLINT, T.cod_oficina)
	AND PRM.prmoc_pcomonint = CONVERT(SMALLINT, T.cod_moneda) 
	AND PRM.prmoc_pnu_contr = CONVERT(INT, T.num_contrato) 

	WHERE GO.num_operacion IS NOT NULL 
		AND GO.cod_estado = 1 
		AND GO.num_contrato > 0
		AND PRM.prmoc_pcoctamay <> 815 
		AND PRM.prmoc_pse_proces = 1 
		AND PRM.prmoc_estado = 'A'
		AND PRM.prmoc_pnu_contr > 0
		AND T.cod_usuario = @IDUsuario
		AND T.cod_tipo_garantia = 1
		AND T.cod_tipo_operacion = 2


	/*Se eliminan los contratos que fueron cargados*/
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 1 AND cod_tipo_operacion = 2

	/*Se obtiene la información de las garantías fiduciarias ligadas al contrato y se insertan en la tabla temporal*/
	INSERT INTO TMP_GARANTIAS_FIDUCIARIAS (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, 
										   fecha_valuacion, ingreso_neto, cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador, 
										   porcentaje_responsabilidad, cod_tipo_acreedor, cedula_acreedor, cod_operacion_especial, nombre_fiador, 
										   cedula_deudor, nombre_deudor, oficina_deudor, cod_estado_tarjeta, cod_garantia_fiduciaria, cod_operacion, 
										   cod_tipo_operacion, ind_operacion_vencida, ind_duplicidad, cod_usuario)
	SELECT DISTINCT
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_operacion AS operacion, 
		c.cedula_fiador, 
		c.cod_tipo_fiador,
		CONVERT(varchar(10),vf.fecha_valuacion,103) AS fecha_valuacion,
		vf.ingreso_neto,
		0 AS cod_tipo_mitigador, 
		b.cod_tipo_documento_legal, 
		0 AS monto_mitigador, 
		b.porcentaje_responsabilidad, 
		b.cod_tipo_acreedor, 
		b.cedula_acreedor, 
		b.cod_operacion_especial,
		c.nombre_fiador,
		a.cedula_deudor,
		e.nombre_deudor,
		f.bsmpc_dco_ofici AS oficina_deudor,
		NULL AS cod_estado_tarjeta,
		b.cod_garantia_fiduciaria,
		a.cod_operacion,
		TMP.cod_tipo_operacion,
		NULL ind_contrato_vencido,
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b 
		ON b.cod_operacion = a.cod_operacion 
		INNER JOIN TMP_OPERACIONES TMP
		ON b.cod_operacion = TMP.cod_operacion
		AND b.cod_garantia_fiduciaria = TMP.cod_garantia
		INNER JOIN GAR_GARANTIA_FIDUCIARIA c 
		ON c.cod_garantia_fiduciaria = TMP.cod_garantia
		LEFT OUTER JOIN GAR_VALUACIONES_FIADOR vf
		ON c.cod_garantia_fiduciaria = vf.cod_garantia_fiduciaria
		AND vf.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_FIADOR WHERE cod_garantia_fiduciaria = c.cod_garantia_fiduciaria)  
		INNER JOIN GAR_DEUDOR e
		ON e.cedula_deudor = a.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC f
		ON f.bsmpc_sco_ident = CONVERT(DECIMAL, e.cedula_deudor)
		AND f.bsmpc_estado = 'A'

	WHERE b.cod_estado = 1
		AND TMP.cod_usuario = @IDUsuario
		AND TMP.cod_tipo_garantia = 1
		AND TMP.cod_tipo_operacion IN (1, 3)
--		AND EXISTS (SELECT 1
--					FROM dbo.GAR_SICC_PRMGT g
--					WHERE g.prmgt_pco_conta = a.cod_contabilidad
--					 AND g.prmgt_pco_ofici  = CASE	WHEN TMP.cod_tipo_operacion = 1 THEN TMP.cod_oficina 
--													ELSE TMP.cod_oficina_contrato
--											  END
--					 AND g.prmgt_pco_moned  = CASE	WHEN TMP.cod_tipo_operacion = 1 THEN TMP.cod_moneda 
--													ELSE TMP.cod_moneda_contrato
--											  END
--					 AND g.prmgt_pco_produ  = CASE	WHEN TMP.cod_tipo_operacion = 1 THEN TMP.cod_producto 
--													ELSE 10
--											  END
--					 AND g.prmgt_pnu_oper   = CASE	WHEN TMP.cod_tipo_operacion = 1 THEN TMP.num_operacion 
--													ELSE TMP.num_contrato
--											  END
--					 AND g.prmgt_pcoclagar  = c.cod_clase_garantia
--					 AND g.prmgt_pnuidegar  = dbo.ufn_ConvertirCodigoGarantia(c.cedula_fiador)
--					 AND g.prmgt_estado = 'A')/*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/

	ORDER BY
		a.cod_contabilidad,
		a.cod_oficina,	
		a.cod_moneda,
		a.cod_producto,
		a.num_operacion,
		c.cedula_fiador,
		b.cod_tipo_documento_legal DESC   


	/*Se inserta la información de las tarjetas*/
	INSERT INTO TMP_GARANTIAS_FIDUCIARIAS (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, 
										   fecha_valuacion, ingreso_neto, cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador, 
										   porcentaje_responsabilidad, cod_tipo_acreedor, cedula_acreedor, cod_operacion_especial, nombre_fiador, 
										   cedula_deudor, nombre_deudor, oficina_deudor, cod_estado_tarjeta, cod_garantia_fiduciaria, cod_operacion, 
										   cod_tipo_operacion, ind_operacion_vencida, ind_duplicidad, cod_usuario)
	SELECT DISTINCT
		1 AS cod_contabilidad,
		b.cod_oficina_registra AS cod_oficina,
		b.cod_moneda AS cod_moneda, 
		7 AS cod_producto, 
		b.num_tarjeta AS num_operacion, 
		c.cedula_fiador,
		c.cod_tipo_fiador,
		'' AS fecha_valuacion,
		0 AS ingreso_neto,
		0 AS cod_tipo_mitigador,
		a.cod_tipo_documento_legal, 
		0 AS monto_mitigador, 
		a.porcentaje_responsabilidad, 
		a.cod_tipo_acreedor, 
		a.cedula_acreedor, 
		a.cod_operacion_especial, 
		c.nombre_fiador,
		d.cedula_deudor,
		d.nombre_deudor,
		e.bsmpc_dco_ofici AS oficina_deudor,
		b.cod_estado_tarjeta,
		a.cod_garantia_fiduciaria,
		a.cod_tarjeta AS cod_operacion,
		1 AS cod_tipo_operacion,
		NULL AS ind_operacion_vencida,
		1 AS ind_duplicidad,
		@IDUsuario

	FROM 
		TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA a
		INNER JOIN TAR_TARJETA b
		ON b.cod_tarjeta = a.cod_tarjeta
		INNER JOIN TAR_GARANTIA_FIDUCIARIA c
		ON c.cod_garantia_fiduciaria = a.cod_garantia_fiduciaria
		INNER JOIN GAR_DEUDOR d
		ON d.cedula_deudor = b.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC e
		ON e.bsmpc_sco_ident = CONVERT(DECIMAL, b.cedula_deudor)
		AND e.bsmpc_estado = 'A'

	WHERE b.cod_estado_tarjeta NOT IN ('L', 'V', 'H')

	ORDER BY
		b.cod_oficina_registra,	
		b.cod_moneda,
		b.num_tarjeta,
		c.cedula_fiador,
		a.cod_tipo_documento_legal DESC

	/*Se obtienen las operaciones que se encuentran duplicadas*/
	/*Se toma el consecutivo de la garantía más reciente, ya que se supone que es si este así es debido a alguna actualización en los datos del SICC*/
	INSERT INTO TMP_OPERACIONES_DUPLICADAS (cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion, cod_garantia_sicc, 
											cod_tipo_garantia, cod_usuario, cod_garantia, cod_grado)

	SELECT	cod_oficina, 
			cod_moneda,	
			cod_producto, 
			operacion, 
			cod_tipo_operacion,
			cedula_fiador AS cod_garantia_sicc,
			1 AS cod_tipo_garantia,
			@IDUsuario AS cod_usuario,
			MAX(cod_garantia_fiduciaria) AS cod_garantia,
			NULL AS cod_grado

	FROM TMP_GARANTIAS_FIDUCIARIAS
	
	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1,3)

	GROUP BY cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion 
	HAVING COUNT(1) > 1


	/*Se actualiza el indicador de duplicidad a 2, estas son las garantías que se encuentran duplicadas
	  y tienen alguos de los datos claves nulos o vacíos*/
	UPDATE TMP_GARANTIAS_FIDUCIARIAS
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_FIDUCIARIAS GF
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGF
				  WHERE TGF.cod_usuario = GF.cod_usuario
					AND TGF.cod_tipo_garantia = 1
					AND TGF.cod_tipo_operacion IN (1, 3)
					AND TGF.cod_oficina = GF.cod_oficina
					AND TGF.cod_moneda = GF.cod_moneda
					AND TGF.cod_producto = GF.cod_producto
					AND TGF.operacion = GF.operacion
					AND ISNULL(TGF.cod_garantia_sicc, '') = ISNULL(GF.cedula_fiador, '')
					AND GF.cod_tipo_documento_legal IS NULL
					AND GF.fecha_valuacion IS NULL
					AND ((GF.cod_tipo_mitigador IS NULL) OR (GF.cod_tipo_mitigador = 0)))
					--AND GF.cod_garantia_fiduciaria <> TGF.cod_garantia)

	AND GF.cod_usuario = @IDUsuario 
	AND GF.cod_tipo_operacion IN (1, 3)

			 

	/*Se eliminan aquellas garantías que se encuentran con tienen un indicador de duplicidad igual a 2 de un mismo usuario*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS 
		WHERE cod_usuario = @IDUsuario 
			AND cod_tipo_operacion  IN (1, 3) 
			AND ind_duplicidad = 2 


	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
	  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN TMP_GARANTIAS_FIDUCIARIAS TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (	SELECT MIN(T.cod_llave) 
							FROM TMP_GARANTIAS_FIDUCIARIAS T
							WHERE T.cod_usuario = D.cod_usuario
							AND T.cod_tipo_operacion IN (1,3)
							AND T.cod_oficina = D.cod_oficina
							AND T.cod_moneda = D.cod_moneda
							AND T.cod_producto = D.cod_producto
							AND T.operacion = D.operacion
							AND ISNULL(T.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
							AND D.cod_tipo_garantia = 1)
	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion IN (1, 3)


	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE TMP_GARANTIAS_FIDUCIARIAS
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_FIDUCIARIAS GF
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGF
				  WHERE TGF.cod_usuario = GF.cod_usuario
					AND TGF.cod_tipo_garantia = 1
					AND TGF.cod_tipo_operacion IN (1, 3)
					AND TGF.cod_oficina = GF.cod_oficina
					AND TGF.cod_moneda = GF.cod_moneda
					AND TGF.cod_producto = GF.cod_producto
					AND TGF.operacion = GF.operacion
					AND ISNULL(TGF.cod_garantia_sicc, '') = ISNULL(GF.cedula_fiador, '')
					AND TGF.cod_garantia <> GF.cod_llave)
	AND GF.cod_usuario = @IDUsuario
	AND GF.cod_tipo_operacion IN (1, 3)
	

	/*Se eliminan aquellas garantías que se encuentran con tienen un indicador de duplicidad igual a 2 de un mismo usuario*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS 
		WHERE cod_usuario = @IDUsuario 
			AND cod_tipo_operacion  IN (1, 3) 
			AND ind_duplicidad = 2 
			

	/*Se selecciona la información que contendrá el archivo*/
	SELECT DISTINCT cod_contabilidad AS CONTABILIDAD,
		cod_oficina AS OFICINA,
		cod_moneda AS MONEDA,
		cod_producto AS PRODUCTO,
		operacion AS OPERACION,
		cedula_fiador AS CEDULA_FIADOR,
		cod_tipo_fiador AS TIPO_PERSONA_FIADOR,
		ISNULL((CONVERT(varchar(10),fecha_valuacion,103)), '') AS FECHA_VERIFICACION_ASALARIADO,
		ISNULL((CONVERT(varchar(50),ingreso_neto)), '') AS SALARIO_NETO_FIADOR,
		ISNULL((CONVERT(varchar(3),cod_tipo_mitigador)), '') AS TIPO_MITIGADOR_RIESGO,
		ISNULL((CONVERT(varchar(3),cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
		ISNULL((CONVERT(varchar(50), monto_mitigador)), '') AS MONTO_MITIGADOR,
		ISNULL((CONVERT(varchar(50), porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD,
		ISNULL((CONVERT(varchar(3),cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
		ISNULL(cedula_acreedor, '') AS CEDULA_ACREEDOR,
		ISNULL((CONVERT(varchar(3),cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
		ISNULL(nombre_fiador, '') AS NOMBRE_FIADOR,
		ISNULL(cedula_deudor, '') AS CEDULA_DEUDOR,
		ISNULL(nombre_deudor, '') AS NOMBRE_DEUDOR,
		ISNULL((CONVERT(varchar(5),oficina_deudor)), '') AS OFICINA_DEUDOR,
		'' AS BIN,
		ISNULL((CONVERT(varchar(5),cod_estado_tarjeta)), '') AS CODIGO_INTERNO_SISTAR

	FROM TMP_GARANTIAS_FIDUCIARIAS 

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	ORDER BY operacion

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 1 AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 1 AND cod_tipo_operacion IN (1, 3) 

END
