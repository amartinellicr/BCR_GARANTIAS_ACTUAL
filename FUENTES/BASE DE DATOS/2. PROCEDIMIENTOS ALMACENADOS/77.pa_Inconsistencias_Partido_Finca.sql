USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Inconsistencias_Partido_Finca', 'P') IS NOT NULL
	DROP PROCEDURE pa_Inconsistencias_Partido_Finca;
GO

CREATE PROCEDURE [dbo].[pa_Inconsistencias_Partido_Finca]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Inconsistencias_Partido_Finca</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las inconsistencias referentes a los campos del partido y la finca.
	</Descripción>
	<Entradas>
			@psCedula_Usuario	= Identificación del usuario que realiza la consulta. 
                                  Este es dato llave usado para la búsqueda de los registros que deben 
                                  ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>06/06/2012</Fecha>
	<Requerimiento>Req_Garantías Reales Partido y Finca, Siebel No. 1-21317198</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>08/12/2015</Fecha>
			<Descripción>
				Se optimiza el proceso completo, donde se eliminan campos que no son necesarios, dentro de los cuales se encontraba el 
				porcentaje de responsabilidad mismo que sería sustiuido por el porcentaje de aceptación. 
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
	SET DATEFORMAT dmy

	/*Se declaran estas estrucutras debido con el fin de disminuir el tiempo de respuesta del procedimiento
	    almacenado */

	CREATE TABLE #TMP_INCONSISTENCIAS  (
											Contabilidad				TINYINT,
											Oficina						SMALLINT,
											Moneda						TINYINT,
											Producto					TINYINT,
											Operacion					DECIMAL(7),
											Tipo_Garantia_Real			TINYINT,
											Clase_Garantia				SMALLINT,
											Usuario						VARCHAR(30)		COLLATE DATABASE_DEFAULT, 
											Tipo_Inconsistencia			VARCHAR(100)	COLLATE DATABASE_DEFAULT ,
											Garantia_Real				VARCHAR(30)		COLLATE DATABASE_DEFAULT ,
											Deudor						VARCHAR(30)		COLLATE DATABASE_DEFAULT ,
											Nombre_Deudor				VARCHAR(50)		COLLATE DATABASE_DEFAULT 
										)


	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	CREATE TABLE #TMP_GARANTIAS_REALES_OPERACIONES (	cod_llave					BIGINT			IDENTITY(1,1),
														cod_contabilidad			TINYINT,
														cod_oficina					SMALLINT,
														cod_moneda					TINYINT,
														cod_producto				TINYINT,
														operacion					DECIMAL (7,0),
														cod_tipo_mitigador			SMALLINT,
														cod_tipo_documento_legal	SMALLINT,
														cod_inscripcion				SMALLINT,
														fecha_presentacion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														cod_operacion				BIGINT,
														cod_garantia_real			BIGINT,
														cod_tipo_garantia_real		TINYINT,
														cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														cod_grado					VARCHAR (2)		COLLATE DATABASE_DEFAULT,
														numero_finca				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														cod_partido					SMALLINT,
														cod_clase_garantia			SMALLINT,
														cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														cedula_deudor				VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														nombre_deudor				VARCHAR (50)	COLLATE DATABASE_DEFAULT
														PRIMARY KEY (cod_llave)
													)


	CREATE INDEX TMP_GARANTIAS_REALES_OPERACIONES_IX_01 ON #TMP_GARANTIAS_REALES_OPERACIONES (cod_usuario, cod_clase_garantia)

	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	CREATE TABLE #TMP_GARANTIAS_REALES_X_OPERACION  (	cod_llave					BIGINT			IDENTITY(1,1),
														cod_contabilidad			TINYINT,
														cod_oficina					SMALLINT,
														cod_moneda					TINYINT,
														cod_producto				TINYINT,
														operacion					DECIMAL (7,0),
														cod_operacion				BIGINT,
														cod_garantia_real			BIGINT,
														cod_tipo_garantia_real		TINYINT,
														cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														cod_clase_garantia			SMALLINT,
														cod_partido					SMALLINT,
														numero_finca				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														cedula_deudor				VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														nombre_deudor				VARCHAR (50)	COLLATE DATABASE_DEFAULT
														PRIMARY KEY (cod_llave)
													)
	
	CREATE INDEX TMP_GARANTIAS_REALES_X_OPERACION_IX_01 ON #TMP_GARANTIAS_REALES_X_OPERACION (cod_usuario, cod_tipo_garantia_real)

	/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
	CREATE TABLE #TEMP_PRMGT (	prmgt_pcoclagar TINYINT,
								prmgt_pnu_part TINYINT,
								prmgt_pco_grado TINYINT,
								prmgt_pnuidegar DECIMAL(12,0),
								prmgt_pnuide_alf CHAR(12),
								prmgt_pcotengar TINYINT,
								prmgt_pco_produ TINYINT)
		 
	CREATE INDEX TEMP_PRMGT_IX_01 ON #TEMP_PRMGT (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf)
	
	DECLARE @CLASES_GARANTIAS_REALES TABLE (Consecutivo TINYINT 
											PRIMARY KEY (Consecutivo)) --Se utilizará para generar los semestres a ser calculados

	DECLARE @viConsecutivo	BIGINT --Se usa para generar los códigos de la tabla temporal de números.

	SET	@viConsecutivo = 1

	--Se carga la tabla temporal de consecutivos
	WHILE	@viConsecutivo <= 29
	BEGIN
		INSERT INTO @CLASES_GARANTIAS_REALES (Consecutivo) VALUES(@viConsecutivo)
		SET @viConsecutivo = @viConsecutivo + 1
	END



/************************************************************************************************
 *                                                                                              * 
 *                       INICIO DEL FILTRADO DE LAS GARANTIAS REALES                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

  	/*Se obtienen las garantías relacionadas al contrato*/
	INSERT	INTO #TEMP_PRMGT(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pco_grado, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pcotengar, prmgt_pco_produ)
	SELECT  MGT.prmgt_pcoclagar,
			MGT.prmgt_pnu_part,
			MGT.prmgt_pco_grado,
			MGT.prmgt_pnuidegar,
			MGT.prmgt_pnuide_alf,
			MGT.prmgt_pcotengar,
			MGT.prmgt_pco_produ
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN @CLASES_GARANTIAS_REALES CGR
			ON CGR.Consecutivo = MGT.prmgt_pcoclagar
		WHERE	MGT.prmgt_estado = 'A'

	/*Se eliminan los registros con clase de garantía entre 20 y 29, pero con código de tenencia distinto de 1*/
	DELETE	FROM #TEMP_PRMGT
	WHERE	prmgt_pcoclagar BETWEEN 20 AND 29
		AND prmgt_pcotengar <> 1

	/*Se selecciona la información de la garantía real asociada a las operaciones*/
	INSERT INTO #TMP_GARANTIAS_REALES_OPERACIONES 
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion,
	 fecha_presentacion, cod_operacion, cod_garantia_real, cod_tipo_garantia_real, cod_bien, cod_grado, numero_finca, cod_partido, 
	 cod_clase_garantia, cod_usuario, cedula_deudor, nombre_deudor)

	SELECT	DISTINCT 
			1 AS cod_contabilidad, 
			ROV.cod_oficina, 
			ROV.cod_moneda, 
			ROV.cod_producto, 
			ROV.num_operacion AS operacion, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')	AS cod_bien, 
			COALESCE(GGR.cod_grado,'') AS cod_grado,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.cod_partido, -1) AS cod_partido, 
			COALESCE(GGR.cod_clase_garantia, -1) AS cod_clase_garantia,
			@psCedula_Usuario AS cod_usuario,
			GO1.cedula_deudor,
			GD1.nombre_deudor
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		ON ROV.cod_operacion = GRO.cod_operacion 
		AND ROV.cod_garantia = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		ON GGR.cod_garantia_real = ROV.cod_garantia
		INNER JOIN #TEMP_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc 
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc COLLATE DATABASE_DEFAULT
		AND MGT.prmgt_pco_produ = ROV.cod_producto
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GO1.cod_operacion = GRO.cod_operacion
		LEFT OUTER JOIN dbo.GAR_DEUDOR GD1
		ON GO1.cedula_deudor = GD1.cedula_deudor
	WHERE	ROV.cod_tipo_operacion = 1
		AND MGT.prmgt_pco_grado = COALESCE(GGR.cod_grado, MGT.prmgt_pco_grado)
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GRO.cod_tipo_documento_legal DESC


	/*Se selecciona la información de la garantía real asociada a los contratos*/
	INSERT INTO #TMP_GARANTIAS_REALES_OPERACIONES 
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion,
	 fecha_presentacion, cod_operacion, cod_garantia_real, cod_tipo_garantia_real, cod_bien, cod_grado, numero_finca, cod_partido, 
	 cod_clase_garantia, cod_usuario, cedula_deudor, nombre_deudor)

	SELECT	DISTINCT 
			1 AS cod_contabilidad, 
			ROV.cod_oficina_contrato, 
			ROV.cod_moneda_contrato, 
			ROV.cod_producto_contrato, 
			ROV.num_contrato AS operacion, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')	AS cod_bien, 
			COALESCE(GGR.cod_grado,'') AS cod_grado,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.cod_partido, -1) AS cod_partido, 
			COALESCE(GGR.cod_clase_garantia, -1) AS cod_clase_garantia,
			@psCedula_Usuario AS cod_usuario,
			GO1.cedula_deudor,
			GD1.nombre_deudor
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		ON ROV.cod_operacion = GRO.cod_operacion 
		AND ROV.cod_garantia = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		ON GGR.cod_garantia_real = ROV.cod_garantia
		INNER JOIN #TEMP_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc 
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc COLLATE DATABASE_DEFAULT
		AND MGT.prmgt_pco_produ = 10
		INNER JOIN dbo.GAR_OPERACION GO1
		ON GO1.cod_operacion = GRO.cod_operacion
		LEFT OUTER JOIN dbo.GAR_DEUDOR GD1
		ON GO1.cedula_deudor = GD1.cedula_deudor
	WHERE	ROV.cod_tipo_operacion = 2
		AND MGT.prmgt_pco_grado = COALESCE(GGR.cod_grado, MGT.prmgt_pco_grado)
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GRO.cod_tipo_documento_legal DESC


	/*Se eliminan los registros incompletos*/
	DELETE	FROM #TMP_GARANTIAS_REALES_OPERACIONES
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_documento_legal = -1
		AND fecha_presentacion = '19000101'
		AND cod_tipo_mitigador = -1
		AND cod_inscripcion = -1 

	/*Se eliminan los registros de hipotecas comunes duplicadas*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion,cod_clase_garantia, cod_partido, numero_finca, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, cod_partido, numero_finca) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
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
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
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
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
			AND cod_clase_garantia BETWEEN 20 AND 29
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


/************************************************************************************************
 *                                                                                              * 
 *                        FIN DEL FILTRADO DE LAS GARANTIAS REALES                              *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE GARANTÍAS                                  *
 *                   (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                          *
 *                                                                                              *
 ************************************************************************************************/

	INSERT INTO #TMP_GARANTIAS_REALES_X_OPERACION 
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_bien, cod_clase_garantia, cod_partido, numero_finca, cod_usuario, cedula_deudor, nombre_deudor)

	SELECT	DISTINCT
			TGR.cod_contabilidad, 
			TGR.cod_oficina, 
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			TGR.cod_operacion,
			TGR.cod_garantia_real,
			TGR.cod_tipo_garantia_real,
			TGR.cod_bien, 
			TGR.cod_clase_garantia,
			TGR.cod_partido, 
			TGR.numero_finca,
			TGR.cod_usuario,
			TGR.cedula_deudor,
			TGR.nombre_deudor
	FROM	#TMP_GARANTIAS_REALES_OPERACIONES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario

/************************************************************************************************
 *                                                                                              * 
 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/
 	/*INCONSISTENCIAS DEL CAMPO: PARTIDO*/
	
	/*HIPOTECA COMUN*/
	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que no poseen asignado el código de partido. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Partido',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 1
		AND TOR.cod_partido	= -1


	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignado el código de partido, pero este se encuentra fuera del rango entre
	--1 y 7 (incluyéndolos). 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Partido',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 1
		AND TOR.cod_partido <> -1
		AND TOR.cod_partido NOT BETWEEN 1 AND 7


	/*CEDULA HIPOTECARIA*/
	--Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	--que no poseen asignado el código de partido. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Partido',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 2
		AND TOR.cod_partido	= -1


	--Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	--que poseen asignado el código de partido, pero este se encuentra fuera del rango entre
	--1 y 7 (incluyéndolos). 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Partido',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor			
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 2
		AND TOR.cod_partido = -1
		AND TOR.cod_partido	NOT BETWEEN 1 AND 7


	/*INCONSISTENCIAS DEL CAMPO: FINCA*/
	
	/*HIPOTECA COMUN*/

	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignado un número de finca cuyo tamaño, en caracteres, supera las 6 posiciones. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )

	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 1
		AND TOR.cod_clase_garantia <> 11
		AND LEN(TOR.numero_finca) > 6



	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignado un número de finca cuyas dos primeras posiciones son iguales a 0 (cero). 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 1
		AND LEFT(TOR.numero_finca, 2) = '00'
	

	/*CEDULA HIPOTECARIA*/

	--Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	--que poseen asignado un número de finca cuyo tamaño, en caracteres, supera las 6 posiciones. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )

	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 2
		AND LEN(TOR.numero_finca) > 6



	--Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	--que poseen asignado un número de finca cuyas dos primeras posiciones son iguales a 0 (cero). 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			TOR.cod_oficina,
			TOR.cod_moneda,
			TOR.cod_producto,
			TOR.operacion,
			TOR.cod_tipo_garantia_real,
			TOR.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			TOR.cod_bien,
			TOR.cedula_deudor,
			TOR.nombre_deudor	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TOR
	WHERE	TOR.cod_usuario = @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real = 2
		AND LEFT(TOR.numero_finca, 2) = '00'

	

/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/



		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'pa_Inconsistencias_Partido_Finca' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Inconsistencia!3!DATOS!element], 
				NULL						AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario	= @psCedula_Usuario
		UNION ALL
		SELECT	DISTINCT
				2							AS Tag,
				1							AS Parent,
				NULL						AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				NULL						AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Inconsistencia!3!DATOS!element], 
				NULL						AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario =  @psCedula_Usuario
		UNION ALL
		SELECT	DISTINCT
				3							AS Tag,
				2							AS Parent,
				NULL						AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				NULL						AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				(CONVERT(VARCHAR(5), Contabilidad) + CHAR(9) + 
				 CONVERT(VARCHAR(5), Oficina) + CHAR(9) + 
                 CONVERT(VARCHAR(5), Moneda) + CHAR(9) +
				 CONVERT(VARCHAR(5), Producto) + CHAR(9) + 
                 CONVERT(VARCHAR(20), Operacion) + CHAR(9) + 
				 Deudor + CHAR(9) +
			     Nombre_Deudor + CHAR(9) +
                 CONVERT(VARCHAR(5), Tipo_Garantia_Real) + CHAR(9) +
				 (CASE WHEN  Clase_Garantia = -1 THEN '' ELSE CONVERT(VARCHAR(5), Clase_Garantia) END) + CHAR(9) + 
				 Garantia_Real + CHAR(9) + 
				 Tipo_Inconsistencia + CHAR(9))	AS [Inconsistencia!3!DATOS!element],
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario = @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Partido_Finca</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END