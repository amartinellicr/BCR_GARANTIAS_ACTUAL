USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasRealesOperaciones', 'P') IS NOT NULL
	DROP PROCEDURE pa_ObtenerGarantiasRealesOperaciones;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasRealesOperaciones]
	@nCodOperacion BIGINT = NULL,
	@nContabilidad TINYINT,
	@nOficina SMALLINT,
	@nMoneda TINYINT,
	@nProducto TINYINT,
	@nOperacion DECIMAL(7),
	@nObtenerSoloCodigo BIT = 0,
	@IDUsuario VARCHAR(30) = NULL
AS
BEGIN
/******************************************************************
	<Nombre>pa_ObtenerGarantiasRealesOperaciones</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a las garantías reales relacionadas a las operaciones y giros activos.
	</Descripción>
	<Entradas>
		@nCodOperacion	= Conseutivo de la operación, del cual se obtendrán las garantías reales asociadas. 
		@nContabilidad	= Código de la contabilidad de la operación.
		@nOficina		= Número de la oficina de la operación.
		@nMoneda		= Código de la moneda de la operación.
		@nProducto		= Código del producto de la operación.
		@nContrato		= Número de la operación.
		@nObtenerSoloCodigo	= Indica si se obtiene sólo la inforación referente al código del a garantía o la información completa.
		@IDUsuario		= Identificación del usuario que realzia la consulta de la operación.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>N/A</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.4</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>17/11/2010</Fecha>
			<Descripción>
				Se modifica radicalmente la forma en como se obtiene la información, se adapta a la lógica seguida 
				para generar el archivo de garantías reales ligadas a contratos.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Luis Diego Morera Cordero, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Mantenimiento Valuaciones, Sibel: 1-21537427</Requerimiento>
			<Fecha>27/06/2013</Fecha>
			<Descripción>
				Se agrega el campo que permite obtener la lista de garantías utilizadas por la consulta del histórico de valuaciones.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios de almacenado, búsqueda y extracción de datos, Sibel: 1 - 23923921</Requerimiento>
			<Fecha>01/10/2013</Fecha>
			<Descripción>
				Se ajusta la forma en que se compara la identificación de la garantía entre el SICC y el
				sistema de garantías, se cambia de una comparación numperica a una de texto.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>07/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
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

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
	DECLARE @bEsGiro BIT,
			@nCodigoOperacion BIGINT

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_garantia = 2 AND cod_usuario = @IDUsuario

	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	DECLARE @TMP_GARANTIAS_REALES_OPERACIONES TABLE (	cod_contabilidad			tinyint,
														cod_oficina					smallint,
														cod_moneda					tinyint,
														cod_producto				tinyint,
														operacion					decimal (7,0),
														cod_tipo_bien				smallint,
														cod_bien					varchar (25)	collate database_default,
														cod_tipo_mitigador			smallint,
														cod_tipo_documento_legal	smallint,
														monto_mitigador				decimal (18,2),
														fecha_presentacion			varchar (10)	collate database_default,
														cod_inscripcion				smallint,
														porcentaje_responsabilidad	decimal (5,2),
														fecha_constitucion			varchar (10)	collate database_default,
														cod_grado_gravamen			smallint,
														cod_tipo_acreedor			smallint,
														cedula_acreedor				varchar (30)	collate database_default,
														fecha_vencimiento			varchar (10)	collate database_default,
														cod_operacion_especial		smallint,
														cod_grado					varchar (2)		collate database_default,
														cedula_hipotecaria			varchar (2)		collate database_default,
														cod_clase_garantia			smallint,
														cod_operacion				bigint,
														cod_garantia_real			bigint,
														cod_tipo_garantia_real		tinyint,
														numero_finca				varchar (25)	collate database_default,
														num_placa_bien				varchar (25)	collate database_default,
														cod_clase_bien				varchar (3)		collate database_default,
														cod_estado					smallint,
														cod_liquidez				smallint,
														cod_tenencia				smallint,
														cod_moneda_garantia			smallint,
														cod_partido					smallint,
														cod_tipo_garantia			smallint,
														cod_garantias_listado       varchar (50)	collate database_default,
														Garantia_Real				varchar (150)	collate database_default,
														fecha_prescripcion			varchar (10)	collate database_default,
														cod_tipo_operacion			tinyint,
														ind_duplicidad				tinyint			DEFAULT (1)	,
														cod_usuario					varchar (30)	collate database_default,
														cod_llave					bigint			IDENTITY(1,1)
														PRIMARY KEY (cod_llave)
													)


	/*Se determina si se ha enviado el consecutivo de la operación*/
	IF(@nCodOperacion IS NULL)
	BEGIN
		SET @nCodOperacion = (SELECT cod_operacion 
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
	SET @bEsGiro = CASE WHEN (SELECT num_contrato FROM dbo.GAR_OPERACION WHERE cod_operacion = @nCodOperacion AND num_operacion IS NOT NULL AND num_contrato > 0) > 0 THEN 1
				       ELSE 0
				  END

	IF(@bEsGiro = 1)
	BEGIN
		SET @nCodigoOperacion = (SELECT DISTINCT b.cod_operacion
								 FROM 
								(SELECT prmca_pco_conta, prmca_pco_ofici, prmca_pco_moned, 
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

	/*Se selecciona la información de la garantía real asociada a la operación*/
	INSERT INTO @TMP_GARANTIAS_REALES_OPERACIONES
	SELECT DISTINCT 
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_operacion AS operacion, 
		ISNULL(c.cod_tipo_bien, -1) AS cod_tipo_bien, 
		CASE 
			WHEN c.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + COALESCE(c.numero_finca,'')  
			WHEN c.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + COALESCE(c.numero_finca,'')
			WHEN ((c.cod_tipo_garantia_real = 3) AND (c.cod_clase_garantia <> 38) AND (c.cod_clase_garantia <> 43)) THEN COALESCE(c.cod_clase_bien,'') + COALESCE(c.num_placa_bien,'') 
			WHEN ((c.cod_tipo_garantia_real = 3) AND ((c.cod_clase_garantia = 38) OR (c.cod_clase_garantia = 43))) THEN COALESCE(c.num_placa_bien,'') 
		END	AS cod_bien, 
		ISNULL(b.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(b.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(b.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(b.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(b.cod_inscripcion, -1) AS cod_inscripcion, 
		ISNULL(b.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(b.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		CASE 
			WHEN b.cod_grado_gravamen IS NULL THEN -1 
			WHEN b.cod_grado_gravamen > 3 THEN 4 
			WHEN b.cod_grado_gravamen < 1 THEN -1 
			ELSE b.cod_grado_gravamen 
		END AS cod_grado_gravamen,  
		CASE b.cod_tipo_acreedor 
			WHEN null THEN 2 
			WHEN -1 THEN 2 
			ELSE b.cod_tipo_acreedor 
		END AS cod_tipo_acreedor,  
		ISNULL(b.cedula_acreedor,'') AS cedula_acreedor,  
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(b.fecha_vencimiento, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_vencimiento, 
		ISNULL(b.cod_operacion_especial,0) AS cod_operacion_especial, 
		ISNULL(c.cod_grado,'') AS cod_grado,
		ISNULL(c.cedula_hipotecaria,'') AS cedula_hipotecaria,
		c.cod_clase_garantia,
		a.cod_operacion,
		c.cod_garantia_real,
		c.cod_tipo_garantia_real,
		ISNULL(c.numero_finca,'') AS numero_finca,
		ISNULL(c.num_placa_bien,'') AS num_placa_bien,
		ISNULL(c.cod_clase_bien,'') AS cod_clase_bien,
		1 AS cod_estado,
		CASE b.cod_liquidez 
			WHEN null THEN -1 
			WHEN 0 THEN -1 
			ELSE b.cod_liquidez 
		END AS cod_liquidez, 
		ISNULL(b.cod_tenencia,-1) AS cod_tenencia, 
		ISNULL(b.cod_moneda,-1) AS cod_moneda_garantia, 
		c.cod_partido,
		c.cod_tipo_garantia,
		CASE 
			WHEN c.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + COALESCE(c.numero_finca,'')  
			WHEN c.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + COALESCE(c.numero_finca,'')
			WHEN ((c.cod_tipo_garantia_real = 3) AND (c.cod_clase_garantia <> 38) AND (c.cod_clase_garantia <> 43)) THEN COALESCE(c.cod_clase_bien,'') + COALESCE(c.num_placa_bien,'') 
			WHEN ((c.cod_tipo_garantia_real = 3) AND ((c.cod_clase_garantia = 38) OR (c.cod_clase_garantia = 43))) THEN COALESCE(c.num_placa_bien,'') 
		END AS cod_garantias_listado,
		CASE 
			WHEN c.cod_tipo_garantia_real = 1 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + ' - Finca: ' + COALESCE(c.numero_finca,'')  
			WHEN c.cod_tipo_garantia_real = 2 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), c.cod_partido),'') + ' - Finca: ' + COALESCE(c.numero_finca,'') + ' - Grado: ' + COALESCE(CONVERT(VARCHAR(2),c.cod_grado),'') + ' - Cédula Hipotecaria: ' + COALESCE(CONVERT(VARCHAR(2),c.cedula_hipotecaria),'') 
			WHEN ((c.cod_tipo_garantia_real = 3) AND (c.cod_clase_garantia <> 38) AND (c.cod_clase_garantia <> 43)) THEN 'Clase Bien: ' + COALESCE(c.cod_clase_bien,'') + ' - Número Placa: ' + COALESCE(c.num_placa_bien,'') 
			WHEN ((c.cod_tipo_garantia_real = 3) AND ((c.cod_clase_garantia = 38) OR (c.cod_clase_garantia = 43))) THEN 'Número Placa: ' + COALESCE(c.num_placa_bien,'') 
		END	AS Garantia_Real,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(b.fecha_prescripcion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_prescripcion,
		CASE WHEN @bEsGiro = 1 THEN 3
			 ELSE 1
		END AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario

	FROM 
		dbo.GAR_OPERACION a 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION b 
		 ON a.cod_operacion = b.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL c 
		 ON b.cod_garantia_real = c.cod_garantia_real 

	WHERE a.cod_operacion = @nCodigoOperacion
		AND b.cod_estado = CASE	WHEN @bEsGiro = 1 THEN b.cod_estado
								ELSE 1
							END

	ORDER BY
		a.cod_operacion,
		c.numero_finca,
		c.cod_grado,
		c.cod_clase_bien,
		c.num_placa_bien,
		b.cod_tipo_documento_legal DESC


	/*Se obtienen las operaciones duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
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

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	GROUP BY cod_oficina, cod_moneda,cod_producto, operacion, cod_bien, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES GR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
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
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)

	/*Se obtienen las garantías reales de hipoteca común duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
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

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_tipo_garantia_real = 1 
		AND cod_tipo_operacion IN (1, 3)
		AND cod_usuario = @IDUsuario

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES T
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
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES GR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
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
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)

	/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
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

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)
		AND cod_tipo_garantia_real = 2

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.numero_finca, '') = ISNULL(D.cod_garantia_sicc, '')
	AND TT.cod_grado = D.cod_grado
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES T
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
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES GR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
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
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @IDUsuario AND cod_tipo_operacion IN (1, 3)

	/*Se obtienen las garantías reales de prenda duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
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

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)
		AND cod_tipo_garantia_real = 3

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.num_placa_bien, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES T
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
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES GR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
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
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion IN (1, 3) AND ind_duplicidad = 2 AND cod_usuario = @IDUsuario

	IF(@nObtenerSoloCodigo = 1)
	BEGIN
		SELECT DISTINCT CASE a.cod_tipo_garantia_real  
							WHEN 1 THEN '[Hipoteca] ' + ISNULL(Garantia_Real,'') 
							WHEN 2 THEN '[Cédula Hipotecaria] ' + ISNULL(Garantia_Real,'')
							WHEN 3 THEN '[Prenda] ' + ISNULL(Garantia_Real,'') 
						END AS garantia
		FROM 
			@TMP_GARANTIAS_REALES_OPERACIONES a
			INNER JOIN CAT_ELEMENTO b
			 ON b.cat_campo = a.cod_tipo_garantia_real
		
		WHERE 
			a.cod_tipo_operacion IN (1, 3) 
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo= 23 

		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT
			@nCodOperacion AS cod_operacion, 
			a.cod_garantia_real, 
			a.cod_tipo_garantia, 
			a.cod_clase_garantia, 
			a.cod_tipo_garantia_real, 
			b.cat_descripcion AS tipo_garantia_real, 
			a.cod_garantias_listado,
			a.Garantia_Real, 
			a.cod_partido, 
			a.numero_finca, 
			a.cod_grado, 
			a.cedula_hipotecaria, 
			a.cod_clase_bien, 
			a.num_placa_bien, 
			a.cod_tipo_bien, 
			a.cod_tipo_mitigador, 
			a.cod_tipo_documento_legal, 
			a.monto_mitigador, 
			a.cod_inscripcion, 
			a.fecha_presentacion, 
			a.porcentaje_responsabilidad, 
			a.cod_grado_gravamen, 
			a.cod_operacion_especial, 
			a.fecha_constitucion, 
			a.fecha_vencimiento, 
			a.cod_tipo_acreedor, 
			a.cedula_acreedor,
			a.cod_liquidez, 
			a.cod_tenencia, 
			a.cod_moneda, 
			a.fecha_prescripcion, 
			a.cod_estado   
		FROM 
			@TMP_GARANTIAS_REALES_OPERACIONES a
			INNER JOIN CAT_ELEMENTO b
			 ON b.cat_campo = a.cod_tipo_garantia_real
		
		WHERE 
			a.cod_tipo_operacion IN (1, 3) 
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo= 23 

		ORDER BY
			a.cod_tipo_garantia_real,
			a.Garantia_Real
	END

	/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_garantia = 2 AND cod_usuario = @IDUsuario

END

GO


