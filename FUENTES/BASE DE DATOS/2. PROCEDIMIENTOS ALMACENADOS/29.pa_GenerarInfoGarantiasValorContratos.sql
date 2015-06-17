SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasValorContratos] 
	@IDUsuario varchar(30)
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasValorContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento almacenado que obtiene la información referente a las garantías de valor relacionadas a los contratos vigentes o
			 vencidos pero que poseen al menos un giro activo.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>17/11/2010</Fecha>
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
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario

	DECLARE
		@lfecHoySinHora DATETIME,
		@lintFechaEntero INT

	SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @lintFechaEntero =  CONVERT(int, CONVERT(varchar(8), @lfecHoySinHora, 112))

	/*Se carga la tabla temporal de contratos vigentes y vencidos (con giros activos) con la información de aquellos que posean una garantía real 
	  asociada*/	
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
	cod_estado_garantia,
	cod_usuario)
	
	SELECT A.*
	FROM (
			/*Se obtienen los contratos vencidos con giros activos*/
			SELECT DISTINCT GO.cod_operacion, 
				GVA.cod_garantia_valor, 
				3 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion, -- 1 = Operaciones, 2 = Contratos y 3 = Giros
				CASE
					WHEN (prmca_pfe_defin >= @lintFechaEntero) THEN 1
					ELSE 0
				END AS ind_contrato_vencido,
				1 AS ind_contrato_vencido_giros_activos,
				GO.cod_oficina,
				GO.cod_moneda,
				GO.cod_producto,
				GO.num_operacion,
				GO.num_contrato,
				0 AS cod_estado_garantia,
				@IDUsuario AS cod_usuario

			FROM GAR_OPERACION GO
			INNER JOIN GAR_SICC_PRMCA PRC
			ON GO.cod_contabilidad = PRC.prmca_pco_conta
				AND GO.cod_oficina = PRC.prmca_pco_ofici 
				AND GO.cod_moneda = PRC.prmca_pco_moned
				AND GO.num_contrato = CONVERT(decimal(7),PRC.prmca_pnu_contr)
			INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVA
			ON GO.cod_operacion = GVA.cod_operacion
			
			WHERE GO.num_operacion IS NULL 
			AND GO.num_contrato > 0
			AND PRC.prmca_estado = 'A'
			AND prmca_pfe_defin < @lintFechaEntero
			AND EXISTS (SELECT	1
						FROM	GAR_SICC_PRMOC P
						WHERE	P.prmoc_pco_oficon = PRC.prmca_pco_ofici 
						AND		P.prmoc_pcomonint = PRC.prmca_pco_moned
						AND		P.prmoc_pnu_contr = PRC.prmca_pnu_contr
						AND		P.prmoc_pcoctamay <> 815 
						AND		P.prmoc_pse_proces = 1 
						AND		P.prmoc_estado = 'A')

			UNION ALL
			/*Se carga la tabla temporal de contratos vigentes*/	
			SELECT DISTINCT GO.cod_operacion, 
				GVA.cod_garantia_valor,
				3 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
				CASE
					WHEN (prmca_pfe_defin >= @lintFechaEntero) THEN 1
					ELSE 0
				END AS ind_contrato_vencido,
				1 AS ind_contrato_vencido_giros_activos,
				GO.cod_oficina,
				GO.cod_moneda,
				GO.cod_producto,
				GO.num_operacion,
				GO.num_contrato,
				0 AS cod_estado_garantia,
				@IDUsuario AS cod_usuario

			FROM GAR_OPERACION GO
			INNER JOIN GAR_SICC_PRMCA PRC
			ON GO.cod_contabilidad = PRC.prmca_pco_conta
				AND GO.cod_oficina = PRC.prmca_pco_ofici 
				AND GO.cod_moneda = PRC.prmca_pco_moned
				AND GO.num_contrato = CONVERT(decimal(7),PRC.prmca_pnu_contr)
			INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVA
			ON GO.cod_operacion = GVA.cod_operacion

			WHERE GO.num_operacion IS NULL 
			AND GO.num_contrato > 0
			AND PRC.prmca_estado = 'A'
			AND prmca_pfe_defin >= @lintFechaEntero) AS A

	/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
	UPDATE TMP_OPERACIONES

	SET cod_estado_garantia = 1

	FROM TMP_OPERACIONES TMP
	INNER JOIN dbo.GAR_GARANTIA_VALOR G
	ON G.cod_garantia_valor = TMP.cod_garantia
	INNER JOIN dbo.GAR_SICC_PRMGT GT
	ON GT.prmgt_pco_ofici = TMP.cod_oficina
	AND GT.prmgt_pco_moned = TMP.cod_moneda
	AND GT.prmgt_pnu_oper = TMP.num_contrato

	WHERE TMP.cod_tipo_garantia = 3
	AND TMP.cod_tipo_operacion = 2
	AND TMP.num_operacion IS NULL
	AND TMP.num_contrato > 0
	AND GT.prmgt_estado = 'A'
	AND	GT.prmgt_pco_produ = 10
	AND GT.prmgt_pcotengar IN (2,3,4,6)
	AND GT.prmgt_pcoclagar BETWEEN 20 AND 29
	AND GT.prmgt_pcoclagar = G.cod_clase_garantia
	AND GT.prmgt_pnuidegar = dbo.ufn_ConvertirCodigoGarantia(G.numero_seguridad)

	/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
	DELETE 
	FROM TMP_OPERACIONES 
	WHERE cod_estado_garantia = 0 
	AND cod_tipo_operacion = 2 
	AND cod_tipo_garantia = 3 
	AND cod_usuario = @IDUsuario 


	/*Se selecciona la información de la garantía de valor asociada a los contratos*/
	INSERT INTO TMP_GARANTIAS_VALOR
	SELECT DISTINCT 
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_contrato AS operacion, 
		d.numero_seguridad, 
		b.cod_tipo_mitigador, 
		b.cod_tipo_documento_legal, 
		b.monto_mitigador, 
		CASE WHEN CONVERT(varchar(10),b.fecha_presentacion_registro,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),b.fecha_presentacion_registro,103)
		END AS fecha_presentacion, 
		b.cod_inscripcion, 
		b.porcentaje_responsabilidad, 
		CASE WHEN CONVERT(varchar(10),d.fecha_constitucion,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),d.fecha_constitucion,103)
		end AS fecha_constitucion, 
		b.cod_grado_gravamen, 
		b.cod_grado_prioridades, 
		b.monto_prioridades, 
		b.cod_tipo_acreedor, 
		b.cedula_acreedor, 
		CASE WHEN CONVERT(varchar(10),d.fecha_vencimiento_instrumento,103) = '01/01/1900' THEN ''
			 ELSE CONVERT(varchar(10),d.fecha_vencimiento_instrumento,103)
		END AS fecha_vencimiento, 
		b.cod_operacion_especial, 
		d.cod_clasificacion_instrumento, 
		d.des_instrumento, 
		d.des_serie_instrumento, 
		d.cod_tipo_emisor, 
		d.cedula_emisor, 
		d.premio, 
		d.cod_isin, 
		d.valor_facial, 
		d.cod_moneda_valor_facial, 
		d.valor_mercado, 
		d.cod_moneda_valor_mercado,
		e.prmgt_pmoresgar AS monto_responsabilidad,
		e.prmgt_pco_mongar AS cod_moneda_garantia,
		a.cedula_deudor,
		f.nombre_deudor,
		g.bsmpc_dco_ofici AS oficina_deudor,
		NULL AS cod_tipo_garantia,
		NULL AS cod_clase_garantia,
		NULL AS cod_tenencia,
		NULL AS fecha_prescripcion,
		b.cod_garantia_valor,
		b.cod_operacion,
		1 AS cod_estado,
		c.cod_tipo_operacion,	
		c.ind_contrato_vencido AS ind_operacion_vencida,
		1 AS ind_duplicidad,
		c.cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION b 
		ON a.cod_operacion = b.cod_operacion 
		INNER JOIN TMP_OPERACIONES c
		ON c.cod_operacion = b.cod_operacion
		AND c.cod_garantia = b.cod_garantia_valor
		INNER JOIN GAR_GARANTIA_VALOR d 
		ON d.cod_garantia_valor = c.cod_garantia 
		LEFT OUTER JOIN GAR_SICC_PRMGT e
		ON a.cod_contabilidad = e.prmgt_pco_conta
		AND a.cod_oficina = e.prmgt_pco_ofici
		AND a.cod_moneda = e.prmgt_pco_moned
		AND a.cod_producto = e.prmgt_pco_produ
		AND a.num_operacion = e.prmgt_pnu_oper
		AND d.numero_seguridad = convert(varchar(25),e.prmgt_pnuidegar)
		INNER JOIN GAR_DEUDOR f
		ON a.cedula_deudor = f.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC g
		ON f.cedula_deudor = CONVERT(varchar(30), g.bsmpc_sco_ident)

	WHERE c.cod_tipo_garantia = 3
		AND c.cod_usuario = @IDUsuario
		AND c.cod_tipo_operacion = 2
		AND ((d.cod_clase_garantia = 20 AND d.cod_tenencia <> 6) OR 
			 (d.cod_clase_garantia <> 20 AND d.cod_tenencia = 6) OR
			 (d.cod_clase_garantia <> 20 AND d.cod_tenencia <> 6))

	ORDER BY
		a.cod_contabilidad,
		a.cod_oficina,	
		a.cod_moneda,
		a.cod_producto,
		a.operacion,
		d.numero_seguridad,
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
		AND cod_tipo_operacion = 2

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_operacion
	HAVING COUNT(1) > 1


	/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE GV.cod_oficina = TGV.cod_oficina
					AND GV.cod_moneda = TGV.cod_moneda
					AND GV.cod_producto = TGV.cod_producto
					AND GV.operacion = TGV.operacion
					AND ISNULL(GV.numero_seguridad, '') = ISNULL(TGV.cod_garantia_sicc, '')
					AND ISNULL(GV.cod_usuario, '') = ISNULL(TGV.cod_usuario, '')
					AND TGV.cod_tipo_operacion = 2
					AND TGV.cod_tipo_garantia = 3 
					AND GV.cod_tipo_documento_legal IS NULL
					AND GV.fecha_presentacion IS NULL
					AND GV.cod_tipo_mitigador IS NULL
					AND GV.cod_inscripcion IS NULL)

		AND GV.cod_usuario = @IDUsuario
		AND GV.cod_tipo_operacion = 2
			 
	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

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
								WHERE T.cod_oficina = D.cod_oficina
								AND T.cod_moneda = D.cod_moneda
								AND T.cod_producto = D.cod_producto
								AND T.operacion = D.operacion
								AND ISNULL(T.numero_seguridad, '') = ISNULL(D.cod_garantia_sicc, '')
								AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
								AND T.cod_tipo_operacion = 2
								AND D.cod_tipo_garantia = 3)
	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion = 2

	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE GV.cod_oficina = TGV.cod_oficina
					AND GV.cod_moneda = TGV.cod_moneda
					AND GV.cod_producto = TGV.cod_producto
					AND GV.operacion = TGV.operacion
					AND ISNULL(GV.numero_seguridad, '') = ISNULL(TGV.cod_garantia_sicc, '')
					AND GV.cod_llave <> TGV.cod_garantia
					AND ISNULL(GV.cod_usuario, '') = ISNULL(TGV.cod_usuario, '')
					AND GV.cod_tipo_operacion = 2
					AND TGV.cod_tipo_garantia = 3)

	AND GV.cod_usuario = @IDUsuario
	AND GV.cod_tipo_operacion = 2

	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario
	
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
		AND cod_tipo_operacion = 2

	ORDER BY operacion

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario

END
