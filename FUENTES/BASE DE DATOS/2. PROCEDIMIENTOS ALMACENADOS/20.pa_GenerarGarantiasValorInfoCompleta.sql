SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_GenerarGarantiasValorInfoCompleta] 
	@IDUsuario varchar(30)
AS

/******************************************************************
<Nombre>pa_GenerarGarantiasValorInfoCompleta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la información necesaria para generar el archivo SEGUI. 
			 Se implementan nuevos criterios de selección de la información.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
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

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion IN (1, 3) 
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion IN (1, 3) 

	/*Se carga la tabla temporal la información de aquellas operaciones que posean una garantía real asociada*/	
	INSERT INTO TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		GVA.cod_garantia_valor,
		3 AS cod_tipo_garantia,
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
	INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVA
	ON GVA.cod_operacion = GO.cod_operacion
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

	
	/*Se obtienen los contratos y las garantías relaconadas a estos*/
	INSERT INTO TMP_OPERACIONES	(cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		GVA.cod_garantia_valor,
		3 AS cod_tipo_garantia,
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
	INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVA
	ON GVA.cod_operacion = GO.cod_operacion

	WHERE GO.num_operacion IS NULL 
	AND EXISTS (	SELECT 1
					FROM GAR_SICC_PRMCA PRC	
					WHERE PRC.prmca_pnu_contr = CONVERT(DECIMAL, GO.num_contrato)
					AND PRC.prmca_pco_ofici   = CONVERT(SMALLINT, GO.cod_oficina)
					AND PRC.prmca_pco_moned   = CONVERT(TINYINT, GO.cod_moneda)
					AND PRC.prmca_estado      = 'A')

	/*Se obtienen los giros asociados a los contratos y se les asigana las garantías relacionadas a este último*/
	INSERT INTO TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia, cod_tipo_operacion, ind_contrato_vencido, 
								 ind_contrato_vencido_giros_activos, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, 
								 cod_oficina_contrato, cod_moneda_contrato, cod_producto_contrato, cod_usuario)

	SELECT DISTINCT GO.cod_operacion, 
		T.cod_garantia,
		3 AS cod_tipo_garantia,
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
		AND T.cod_tipo_garantia = 3
		AND T.cod_tipo_operacion = 2


	/*Se eliminan los contratos que fueron cargados*/
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion = 2

	/*Se selecciona la información de la garantía de valor asociada a las operaciones*/
	INSERT INTO TMP_GARANTIAS_VALOR (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_mitigador,
									 cod_tipo_documento_legal, monto_mitigador, fecha_presentacion, cod_inscripcion, porcentaje_responsabilidad,
									 fecha_constitucion,  cod_grado_gravamen, cod_grado_prioridades, monto_prioridades, cod_tipo_acreedor,
									 cedula_acreedor, fecha_vencimiento, cod_operacion_especial, cod_clasificacion_instrumento, des_instrumento,
									 des_serie_instrumento, cod_tipo_emisor, cedula_emisor, premio, cod_isin, valor_facial, cod_moneda_valor_facial,
								     valor_mercado, cod_moneda_valor_mercado, monto_responsabilidad, cod_moneda_garantia, cedula_deudor, nombre_deudor,
									 oficina_deudor, cod_tipo_garantia, cod_clase_garantia, cod_tenencia, fecha_prescripcion, cod_garantia_valor,
									 cod_operacion, cod_estado, cod_tipo_operacion, ind_operacion_vencida, ind_duplicidad, cod_usuario)

	SELECT DISTINCT 
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_operacion AS operacion, 
		c.numero_seguridad, 
		b.cod_tipo_mitigador, 
		b.cod_tipo_documento_legal, 
		b.monto_mitigador, 
		CASE WHEN CONVERT(varchar(10),b.fecha_presentacion_registro,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),b.fecha_presentacion_registro,103)
		END AS fecha_presentacion, 
		b.cod_inscripcion, 
		b.porcentaje_responsabilidad, 
		CASE WHEN CONVERT(varchar(10),c.fecha_constitucion,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),c.fecha_constitucion,103)
		end AS fecha_constitucion, 
		b.cod_grado_gravamen, 
		b.cod_grado_prioridades, 
		b.monto_prioridades, 
		b.cod_tipo_acreedor, 
		b.cedula_acreedor, 
		CASE WHEN CONVERT(varchar(10),c.fecha_vencimiento_instrumento,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),c.fecha_vencimiento_instrumento,103)
		END AS fecha_vencimiento, 
		b.cod_operacion_especial, 
		c.cod_clasificacion_instrumento, 
		c.des_instrumento, 
		c.des_serie_instrumento, 
		c.cod_tipo_emisor, 
		c.cedula_emisor, 
		c.premio, 
		c.cod_isin, 
		c.valor_facial, 
		c.cod_moneda_valor_facial, 
		c.valor_mercado, 
		c.cod_moneda_valor_mercado,
		e.prmgt_pmoresgar AS monto_responsabilidad,
		e.prmgt_pco_mongar AS cod_moneda_garantia,
		f.cedula_deudor,
		f.nombre_deudor,
		g.bsmpc_dco_ofici AS oficina_deudor,
		NULL AS cod_tipo_garantia,
		NULL AS cod_clase_garantia,
		NULL AS cod_tenencia,
		NULL AS fecha_prescripcion,
		b.cod_garantia_valor,
		b.cod_operacion,
		1 AS cod_estado,
		d.cod_tipo_operacion,	
		NULL AS ind_operacion_vencida,
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION b 
		ON a.cod_operacion = b.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR c 
		ON b.cod_garantia_valor = c.cod_garantia_valor 
		INNER JOIN TMP_OPERACIONES d
		on d.cod_operacion = b.cod_operacion
		and d.cod_garantia = b.cod_garantia_valor
		LEFT OUTER JOIN GAR_SICC_PRMGT e
		ON e.prmgt_pnu_oper = a.num_operacion
		AND e.prmgt_pco_ofici = a.cod_oficina
		AND e.prmgt_pco_moned = a.cod_moneda 
		AND e.prmgt_pco_produ = a.cod_producto
		AND e.prmgt_pco_conta = a.cod_contabilidad
		AND e.prmgt_pnuidegar = CONVERT(DECIMAL,c.numero_seguridad)
		and e.prmgt_estado = 'A'
		INNER JOIN GAR_DEUDOR f
		on a.cedula_deudor = f.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC g
		on g.bsmpc_sco_ident  = convert(DECIMAL, f.cedula_deudor)
		AND g.bsmpc_estado = 'A'

	WHERE b.cod_estado = 1
		AND ((c.cod_clase_garantia = 20 AND c.cod_tenencia <> 6) OR 
			 (c.cod_clase_garantia <> 20 AND c.cod_tenencia = 6) OR
			 (c.cod_clase_garantia <> 20 AND c.cod_tenencia <> 6))
		AND d.cod_tipo_garantia = 3
		AND d.cod_usuario = @IDUsuario 
		AND d.cod_tipo_operacion IN (1, 3)
--		AND EXISTS (SELECT 1
--					FROM dbo.GAR_SICC_PRMGT g
--					WHERE g.prmgt_pco_conta = a.cod_contabilidad
--					AND g.prmgt_pco_ofici  = CASE	WHEN d.cod_tipo_operacion = 1 THEN d.cod_oficina 
--													ELSE d.cod_oficina_contrato
--											 END
--					AND g.prmgt_pco_moned  = CASE	WHEN d.cod_tipo_operacion = 1 THEN d.cod_moneda 
--													ELSE d.cod_moneda_contrato
--											 END
--					AND g.prmgt_pco_produ  = CASE	WHEN d.cod_tipo_operacion = 1 THEN d.cod_producto 
--													ELSE 10
--											 END
--					AND g.prmgt_pnu_oper   = CASE	WHEN d.cod_tipo_operacion = 1 THEN d.num_operacion 
--													ELSE d.num_contrato
--											 END
--					 AND g.prmgt_pcoclagar  BETWEEN 20 AND 29
--					 AND g.prmgt_pcotengar  IN (2,3,4,6)
--					 AND g.prmgt_pnuidegar  = dbo.ufn_ConvertirCodigoGarantia(c.numero_seguridad)
--					 AND g.prmgt_estado = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/

	ORDER BY
		a.cod_contabilidad,
		a.cod_oficina,	
		a.cod_moneda,
		a.cod_producto,
		a.operacion,
		c.numero_seguridad,
		b.cod_tipo_documento_legal DESC

	/*Se obtienen las operaciones duplicadas*/
	INSERT INTO TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_seguridad AS cod_garantia_sicc,
			3 AS cod_tipo_garantia,
			@IDUsuario AS cod_usuario,
			MAX(cod_garantia_valor) AS cod_garantia,
			NULL AS cod_grado

	FROM TMP_GARANTIAS_VALOR

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	GROUP BY cod_oficina, cod_moneda,cod_producto, operacion, numero_seguridad, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE TGV.cod_usuario = GV.cod_usuario
					AND TGV.cod_tipo_garantia = 3 
					AND TGV.cod_tipo_operacion IN (1, 3)
					AND TGV.cod_oficina = GV.cod_oficina
					AND TGV.cod_moneda = GV.cod_moneda
					AND TGV.cod_producto = GV.cod_producto
					AND TGV.operacion = GV.operacion
					AND ISNULL(TGV.cod_garantia_sicc, '') = ISNULL(GV.numero_seguridad, '')
					AND GV.cod_tipo_documento_legal IS NULL
					AND GV.fecha_presentacion IS NULL
					AND GV.cod_tipo_mitigador IS NULL
					AND GV.cod_inscripcion IS NULL)

		AND GV.cod_usuario = @IDUsuario
		AND GV.cod_tipo_operacion IN (1, 3)

			 
	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
	  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN TMP_GARANTIAS_VALOR TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.numero_seguridad, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM TMP_GARANTIAS_VALOR T
								WHERE T.cod_usuario = D.cod_usuario
								AND T.cod_tipo_operacion IN (1, 3)
								AND T.cod_oficina = D.cod_oficina
								AND T.cod_moneda = D.cod_moneda
								AND T.cod_producto = D.cod_producto
								AND T.operacion = D.operacion
								AND ISNULL(T.numero_seguridad, '') = ISNULL(D.cod_garantia_sicc, '')
								AND D.cod_tipo_garantia = 3)

	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion IN (1, 3)

	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE TGV.cod_usuario = GV.cod_usuario
					AND TGV.cod_tipo_operacion IN (1, 3)
					AND TGV.cod_tipo_garantia = 3
					AND TGV.cod_oficina = GV.cod_oficina
					AND TGV.cod_moneda = GV.cod_moneda
					AND TGV.cod_producto = GV.cod_producto
					AND TGV.operacion = GV.operacion
					AND ISNULL(TGV.cod_garantia_sicc, '') = ISNULL(GV.numero_seguridad, '') 
					AND TGV.cod_garantia <> GV.cod_llave)

	AND GV.cod_usuario = @IDUsuario
	AND GV.cod_tipo_operacion IN (1, 3)


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 

	/*Se seleccionan los datos de salida para el usuario que genera la información*/
	SELECT
	cod_contabilidad AS CONTABILIDAD, 
	cod_oficina AS OFICINA,  
	cod_moneda AS MONEDA, 
	cod_producto AS PRODUCTO, 
	operacion AS OPERACION, 
	ISNULL((CONVERT(varchar(30),numero_seguridad)), '') as NUMERO_SEGURIDAD, 
	ISNULL((CONVERT(varchar(3),cod_tipo_mitigador)), '') as TIPO_MITIGADOR, 
	ISNULL((CONVERT(varchar(3),cod_tipo_documento_legal)), '') as TIPO_DOCUMENTO_LEGAL, 
	ISNULL((CONVERT(varchar(50), monto_mitigador)), '') as MONTO_MITIGADOR,  
	ISNULL((CONVERT(varchar(10),fecha_presentacion,103)), '') as FECHA_PRESENTACION, 
	ISNULL((CONVERT(varchar(3),cod_inscripcion)), '') as INDICADOR_INSCRIPCION, 
	ISNULL((CONVERT(varchar(50), porcentaje_responsabilidad)), '') as PORCENTAJE_RESPONSABILIDAD, 
	ISNULL((CONVERT(varchar(10),fecha_constitucion,103)), '') as FECHA_CONSTITUCION, 
	ISNULL((CONVERT(varchar(3),cod_grado_gravamen)), '') as GRADO_GRAVAMEN, 
	ISNULL((CONVERT(varchar(3),cod_grado_prioridades)), '') as GRADO_PRIORIDAD, 
	ISNULL((CONVERT(varchar(50), monto_prioridades)), '') as MONTO_PRIORIDAD, 
	ISNULL((CONVERT(varchar(3),cod_tipo_acreedor)), '') as TIPO_PERSONA_ACREEDOR, 
	ISNULL(cedula_acreedor, '') as CEDULA_ACREEDOR, 
	ISNULL((CONVERT(varchar(10),fecha_vencimiento,103)), '') as FECHA_VENCIMIENTO, 
	ISNULL((CONVERT(varchar(3),cod_operacion_especial)), '') as OPERACION_ESPECIAL, 
	ISNULL((CONVERT(varchar(3),cod_clasificacion_instrumento)), '') as CLASIFICACION_INSTRUMENTO,
	ISNULL(des_instrumento, '') as INSTRUMENTO, 
	ISNULL(des_serie_instrumento, '') as SERIE_INSTRUMENTO, 
	ISNULL((CONVERT(varchar(3),cod_tipo_emisor)), '') as TIPO_PERSONA_EMISOR, 
	ISNULL(cedula_emisor, '') as CEDULA_EMISOR, 
	ISNULL((CONVERT(varchar(50), premio)), '') as PREMIO, 
	ISNULL(cod_isin, '') as ISIN, 
	ISNULL((CONVERT(varchar(50), valor_facial)), '') as VALOR_FACIAL,
	ISNULL((CONVERT(varchar(3),cod_moneda_valor_facial)), '') as MONEDA_VALOR_FACIAL, 
	ISNULL((CONVERT(varchar(50), valor_mercado)), '') as VALOR_MERCADO, 
	ISNULL((CONVERT(varchar(3),cod_moneda_valor_mercado)), '') as MONEDA_VALOR_MERCADO, 
	ISNULL((CONVERT(varchar(50), monto_responsabilidad)), '') as MONTO_RESPONSABILIDAD, 
	ISNULL((CONVERT(varchar(3),cod_moneda_garantia)), '') as MONEDA_GARANTIA, 
	ISNULL(cedula_deudor, '') as CEDULA_DEUDOR, 
	ISNULL(nombre_deudor, '') as NOMBRE_DEUDOR, 
	ISNULL((CONVERT(varchar(5),oficina_deudor)), '') as OFICINA_DEUDOR,
	ind_operacion_vencida AS ES_CONTRATO_VENCIDO

	FROM TMP_GARANTIAS_VALOR 

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	ORDER BY operacion

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)
	DELETE FROM TMP_OPERACIONES WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion IN (1, 3) 
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion IN (1, 3) 

END
