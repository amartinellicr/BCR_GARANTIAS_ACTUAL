SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasValorOperaciones]
	@nCodOperacion BIGINT = NULL,
	@nContabilidad TINYINT,
	@nOficina SMALLINT,
	@nMoneda TINYINT,
	@nProducto TINYINT,
	@nOperacion DECIMAL(7),
	@nObtenerSoloCodigo BIT = 0,
	@IDUsuario VARCHAR(30) = NULL
AS

/******************************************************************
<Nombre>pa_ObtenerGarantiasValorOperaciones</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener las garantías de valor que posee una operación.</Descripción>
<Entradas>
	@nCodOperacion		= Código de la operación
	@nContabilidad		= Código de la contabilidad a la que pertenece el contrato
	@nOficina			= Oficina donde se realizó la transacción
	@nMoneda			= Código de la moneda en la que se encuentra el contrato
	@nProducto			= Código del producto.
	@nOperación			= Número de la operación a consultar
	@nObtenerSoloCodigo = Indicador (tipo bit) que determina la información de salida del procedimiento almacenado.
	@IDUsuario			= Identificación del usuario que realiza la consulta. Eso permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>17/11/2010</Fecha>
		<Descripción>Se modifica radicalmente la forma en como se obtiene la información, se adapta a la lógica seguida 
					 para generar el archivo de garantías de valor ligadas a operaciones y giros.
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
	DECLARE @bEsGiro BIT,
			@nCodigoOperacion BIGINT

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario

	/*Se declara la variable tipo tabla que funcionara como maestra*/
	DECLARE @TMP_GARANTIAS_VALOR TABLE (	cod_contabilidad				tinyint,
											cod_oficina						smallint,
											cod_moneda						tinyint,
											cod_producto					tinyint,
											operacion						decimal (7,0),
											numero_seguridad				varchar (25)	collate database_default,
											cod_tipo_mitigador				smallint,
											cod_tipo_documento_legal		smallint,
											monto_mitigador					decimal (18,2),
											fecha_presentacion				varchar (10)		collate database_default,
											cod_inscripcion					smallint,
											porcentaje_responsabilidad		decimal (5,2),
											fecha_constitucion				varchar (10)	collate database_default,
											cod_grado_gravamen				smallint,
											cod_grado_prioridades			smallint,
											monto_prioridades				decimal (18,2),
											cod_tipo_acreedor				smallint,
											cedula_acreedor					varchar (30)	collate database_default,
											fecha_vencimiento				varchar (10)	collate database_default,
											cod_operacion_especial			smallint,
											cod_clasificacion_instrumento	smallint,
											des_instrumento					varchar (25)	collate database_default,
											des_serie_instrumento			varchar (20)	collate database_default,
											cod_tipo_emisor					smallint,
											cedula_emisor					varchar (30)	collate database_default,
											premio							decimal (18,2),
											cod_isin						varchar (25)	collate database_default,
											valor_facial					decimal (18,2),
											cod_moneda_valor_facial			smallint,
											valor_mercado					decimal (18,2),
											cod_moneda_valor_mercado		smallint,
											cod_tipo_garantia				smallint,
											cod_clase_garantia				smallint,
											cod_tenencia					smallint,
											fecha_prescripcion				varchar (10)	collate database_default,
											cod_garantia_valor				bigint,
											cod_operacion					bigint,
											cod_estado						smallint,
											cod_tipo_operacion				tinyint,
											ind_duplicidad					tinyint			DEFAULT (1)	,
											cod_usuario						varchar (30)	collate database_default,
											cod_llave						bigint			IDENTITY(1,1)
											PRIMARY KEY (cod_llave)
										)

	/*Se determina si se ha enviado el consecutivo de la operación*/
	IF(@nCodOperacion IS NULL)
	BEGIN
		SET @nCodOperacion = (SELECT DISTINCT cod_operacion 
							  FROM dbo.GAR_OPERACION
							  WHERE cod_contabilidad = @nContabilidad
								AND cod_oficina = @nOficina
								AND cod_moneda = @nMoneda
								AND cod_producto = @nProducto
								AND num_operacion = @nOperacion
								AND cod_estado = 1)
	END

	/*Se determina si es un giro, ante lo cual, se procederá a obtener el consecutivo del contrato al cual está asociado dicho giro, esto con la
      la finalidad de obtener las garantías asociadas al mismo. En caso de no ser un giro, entonces se uitliza el consecutivo pasado o encontrado anteirormente*/
	SET @bEsGiro = CASE WHEN (SELECT DISTINCT num_contrato FROM dbo.GAR_OPERACION WHERE cod_operacion = @nCodOperacion AND num_operacion IS NOT NULL AND num_contrato > 0) > 0 THEN 1
				       ELSE 0
				  END

	IF(@bEsGiro = 1)
	BEGIN
		SET @nCodigoOperacion = (SELECT DISTINCT b.cod_operacion
								 FROM 
								(SELECT DISTINCT prmca_pco_conta, prmca_pco_ofici, prmca_pco_moned, 
										prmca_pco_produc, prmca_pnu_contr
								 FROM dbo.GAR_SICC_PRMOC d
								 INNER JOIN  dbo.GAR_SICC_PRMCA e
								  ON e.prmca_pco_ofici = d.prmoc_pco_oficon
								  AND e.prmca_pco_moned = d.prmoc_pcomonint
								  AND e.prmca_pnu_contr = d.prmoc_pnu_contr
								 WHERE d.prmoc_pco_conta = @nContabilidad
									AND d.prmoc_pco_ofici = @nOficina
									AND d.prmoc_pco_moned = @nMoneda
									AND d.prmoc_pco_produ = @nProducto
									AND d.prmoc_pnu_oper = @nOperacion) a
							 INNER JOIN dbo.GAR_OPERACION b
							  ON b.cod_contabilidad = a.prmca_pco_conta
							  AND b.cod_oficina = a.prmca_pco_ofici
							  AND b.cod_moneda = a.prmca_pco_moned
							  AND b.cod_producto = a.prmca_pco_produc
							  AND b.num_contrato = a.prmca_pnu_contr
							 WHERE b.num_operacion IS NULL)
	END
	ELSE
	BEGIN
		SET @nCodigoOperacion = @nCodOperacion
	END

	/*Se selecciona la información de la garantía de valor asociada a la operación*/
	INSERT INTO @TMP_GARANTIAS_VALOR
	SELECT DISTINCT 
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_operacion AS operacion, 
		c.numero_seguridad AS numero_seguridad, 
		ISNULL(b.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
		ISNULL(b.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(b.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(b.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(b.cod_inscripcion, -1) AS cod_inscripcion,
		ISNULL(b.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(c.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(b.cod_grado_gravamen, -1) AS cod_grado_gravamen,
		ISNULL(b.cod_grado_prioridades, -1) AS cod_grado_prioridades,
		ISNULL(b.monto_prioridades, 0) AS monto_prioridades,
		CASE b.cod_tipo_acreedor 
			WHEN NULL THEN 2 
			WHEN -1 THEN 2 
			ELSE b.cod_tipo_acreedor 
		END AS cod_tipo_acreedor,
		ISNULL(b.cedula_acreedor, '') AS cedula_acreedor,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(c.fecha_vencimiento_instrumento, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_vencimiento, 
		ISNULL(b.cod_operacion_especial, 0) AS cod_operacion_especial,
		ISNULL(c.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
		ISNULL(c.des_instrumento, '') AS des_instrumento,
		ISNULL(c.des_serie_instrumento, '') AS des_serie_instrumento,
		ISNULL(c.cod_tipo_emisor, -1) AS cod_tipo_emisor,
		ISNULL(c.cedula_emisor, '') AS cedula_emisor,
		ISNULL(c.premio, 0) AS premio,
		ISNULL(c.cod_isin, '') AS cod_isin,
		ISNULL(c.valor_facial, 0) AS valor_facial,
		ISNULL(c.cod_moneda_valor_facial, -1) AS cod_moneda_valor_facial,
		ISNULL(c.valor_mercado, 0) AS valor_mercado,
		ISNULL(c.cod_moneda_valor_mercado, -1) AS cod_moneda_valor_mercado,
		c.cod_tipo_garantia,
		c.cod_clase_garantia,
		ISNULL(c.cod_tenencia, -1) AS cod_tenencia,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(c.fecha_prescripcion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_prescripcion, 
		b.cod_garantia_valor,
		b.cod_operacion,
		b.cod_estado,
		CASE WHEN @bEsGiro = 1 THEN 3
			 ELSE 1
		END AS cod_tipo_operacion,	
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION b 
		ON a.cod_operacion = b.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR c
		ON c.cod_garantia_valor = b.cod_garantia_valor 

	WHERE a.cod_operacion = @nCodigoOperacion
		AND b.cod_estado = CASE	WHEN @bEsGiro = 1 THEN b.cod_estado
								ELSE 1
							END
--		AND EXISTS (SELECT 1
--					FROM dbo.GAR_SICC_PRMGT g
--					WHERE g.prmgt_pco_conta = a.cod_contabilidad
--					 AND g.prmgt_pco_ofici  = a.cod_oficina
--					 AND g.prmgt_pco_moned  = a.cod_moneda
--					 AND g.prmgt_pco_produ  = CASE	WHEN @bEsGiro = 0 THEN a.cod_producto 
--													ELSE 10
--											  END
--					 AND g.prmgt_pnu_oper   = CASE	WHEN @bEsGiro = 0 THEN a.num_operacion 
--													ELSE a.num_contrato
--											  END
--					 AND g.prmgt_pcoclagar  BETWEEN 20 AND 29
--					 AND g.prmgt_pcotengar  IN (2,3,4,6)
--					 AND g.prmgt_pnuidegar  = dbo.ufn_ConvertirCodigoGarantia(c.numero_seguridad)
--					 AND g.prmgt_estado = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/

	ORDER BY
		b.cod_operacion,
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

	FROM @TMP_GARANTIAS_VALOR

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE GV.cod_oficina = TGV.cod_oficina
					AND GV.cod_moneda = TGV.cod_moneda
					AND GV.cod_producto = TGV.cod_producto
					AND GV.operacion = TGV.operacion
					AND ISNULL(GV.numero_seguridad, '') = ISNULL(TGV.cod_garantia_sicc, '')
					AND ISNULL(GV.cod_usuario, '') = ISNULL(TGV.cod_usuario, '')
					AND TGV.cod_tipo_operacion IN (1, 3)
					AND TGV.cod_tipo_garantia = 3 
					AND GV.cod_tipo_documento_legal IS NULL
					AND GV.fecha_presentacion IS NULL
					AND GV.cod_tipo_mitigador IS NULL
					AND GV.cod_inscripcion IS NULL)

		AND GV.cod_usuario = @IDUsuario
		AND GV.cod_tipo_operacion IN (1, 3)
			 
	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
	  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN @TMP_GARANTIAS_VALOR TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.numero_seguridad, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM @TMP_GARANTIAS_VALOR T
								WHERE T.cod_oficina = D.cod_oficina
								AND T.cod_moneda = D.cod_moneda
								AND T.cod_producto = D.cod_producto
								AND T.operacion = D.operacion
								AND ISNULL(T.numero_seguridad, '') = ISNULL(D.cod_garantia_sicc, '')
								AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
								AND T.cod_tipo_operacion IN (1, 3)
								AND D.cod_tipo_garantia = 3)
	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion IN (1, 3)

	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_VALOR GV
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGV
				  WHERE GV.cod_oficina = TGV.cod_oficina
					AND GV.cod_moneda = TGV.cod_moneda
					AND GV.cod_producto = TGV.cod_producto
					AND GV.operacion = TGV.operacion
					AND ISNULL(GV.numero_seguridad, '') = ISNULL(TGV.cod_garantia_sicc, '')
					AND GV.cod_llave <> TGV.cod_garantia
					AND ISNULL(GV.cod_usuario, '') = ISNULL(TGV.cod_usuario, '')
					AND GV.cod_tipo_operacion IN (1, 3)
					AND TGV.cod_tipo_garantia = 3)

	AND GV.cod_usuario = @IDUsuario
	AND GV.cod_tipo_operacion IN (1, 3)

	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

	IF(@nObtenerSoloCodigo = 1)
	BEGIN
		SELECT DISTINCT '[Número de Seguridad] ' + a.numero_seguridad AS garantia
		FROM @TMP_GARANTIAS_VALOR a
			INNER JOIN CAT_ELEMENTO b
			 ON b.cat_campo = a.cod_clase_garantia 

		WHERE a.cod_tipo_operacion IN (1, 3) 
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo= 7 

		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT DISTINCT 
			a.cod_operacion, 
			a.cod_garantia_valor, 
			a.cod_tipo_garantia, 
			a.cod_clase_garantia, 
			CONVERT(VARCHAR(3),b.cat_campo) + ' - ' + b.cat_descripcion AS des_clase_garantia, 
			a.numero_seguridad, 
			a.fecha_constitucion, 
			a.fecha_vencimiento, 
			a.cod_clasificacion_instrumento,
			a.des_instrumento,
			a.des_serie_instrumento,
			a.cod_tipo_emisor,
			a.cedula_emisor,
			a.premio,
			a.cod_isin,
			a.valor_facial,
			a.cod_moneda_valor_facial,
			a.valor_mercado,
			a.cod_moneda_valor_mercado,
			a.cod_tenencia,
			a.fecha_prescripcion,
			a.cod_tipo_mitigador,
			a.cod_tipo_documento_legal,
			a.monto_mitigador,
			a.cod_inscripcion,
			a.fecha_presentacion,
			a.porcentaje_responsabilidad,
			a.cod_grado_gravamen,
			a.cod_grado_prioridades,
			a.monto_prioridades,
			a.cod_operacion_especial,
			a.cod_tipo_acreedor,
			a.cedula_acreedor,
			a.cod_estado

		FROM @TMP_GARANTIAS_VALOR a
			INNER JOIN CAT_ELEMENTO b
			 ON b.cat_campo = a.cod_clase_garantia 

		WHERE a.cod_tipo_operacion IN (1, 3) 
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo= 7 

		ORDER BY a.numero_seguridad
	END

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_garantia = 3 AND cod_usuario = @IDUsuario

END
