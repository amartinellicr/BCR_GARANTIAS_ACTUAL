USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON 
GO

IF OBJECT_ID ('pa_Alertas_Indicador_Inscripcion_Garantias_Reales', 'P') IS NOT NULL
DROP PROCEDURE pa_Alertas_Indicador_Inscripcion_Garantias_Reales;
GO

CREATE PROCEDURE [dbo].[pa_Alertas_Indicador_Inscripcion_Garantias_Reales]

	@psCedula_Usuario		VARCHAR(30),
	@piCatalogo_Ind_Ins		INT,
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Alertas_Indicador_Inscripcion_Garantias_Reales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene las alertas referentes al campo del indicador de inscripción, es decir,
		se obtienen aquellas garantías cuyos monto mitigador y porcentaje de aceptación serán modificados debido a la 
		inconsistencia del indicador de inscripción.
	</Descripción>
	<Entradas>
			@psCedula_Usuario	= Identificación del usuario que realiza la consulta. 
                                  Este es dato llave usado para la búsqueda de los registros que deben 
                                  ser eliminados de la tabla temporal.

			@piCatalogo_Ind_Ins	= Código del catálogo del indicador de inscripción, parametrizado en el archivo de 
								  configuración del sistema.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>05/08/2013</Fecha>
	<Requerimiento>Indicador de Inscripción, Sibel: 1 - 23816691</Requerimiento>
	<Versión>1.1</Versión>
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
			<Fecha>03/07/2015</Fecha>
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

	SET NOCOUNT ON
	SET DATEFORMAT dmy

	/*Se declaran estas estrucutras debido con el fin de disminuir el tiempo de respuesta del procedimiento
    almacenado */
	CREATE TABLE #TMP_ALERTAS(
								Contabilidad				TINYINT			,
								Oficina						SMALLINT		,
								Moneda						TINYINT			,
								Producto					TINYINT			,
								Operacion					DECIMAL(7)		,
								Tipo_Bien					SMALLINT		,
								Tipo_Mitigador				SMALLINT		,
								Tipo_Documento_Legal		SMALLINT		,
								Tipo_Garantia				TINYINT			,
								Usuario						VARCHAR(30)		COLLATE database_default, 
								Codigo_Bien					VARCHAR(30)		COLLATE database_default ,
								Descripcion_Tipo_Garantia	VARCHAR(15)		COLLATE database_default ,
								Monto_Mitigador				DECIMAL(18,2)	,
								Porcentaje_Aceptacion		DECIMAL(5,2)	, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
								Indicador_Inscripcion		SMALLINT		,
								Des_Indicador_Inscripcion	VARCHAR(160)	COLLATE database_default ,
								Fecha_Constitucion			VARCHAR(10)		COLLATE database_default ,
								Dias_Acumulados				INT
							)


	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	CREATE TABLE #TMP_GARANTIAS_REALES_OPERACIONES (	cod_llave					BIGINT			IDENTITY(1,1),
														cod_contabilidad			TINYINT,
														cod_oficina					SMALLINT,
														cod_moneda					TINYINT,
														cod_producto				TINYINT,
														operacion					DECIMAL (7,0),
														cod_tipo_bien				SMALLINT,
														cod_tipo_mitigador			SMALLINT,
														cod_tipo_documento_legal	SMALLINT,
														cod_inscripcion				SMALLINT,
														cod_operacion				BIGINT,
														cod_garantia_real			BIGINT,
														cod_tipo_garantia_real		TINYINT,
														cod_tipo_operacion			TINYINT,
														ind_duplicidad				TINYINT			DEFAULT (1)	,
														porcentaje_responsabilidad	DECIMAL (5,2),
														monto_mitigador				DECIMAL (18,2),
														cod_bien					VARCHAR (25)	COLLATE database_default,
														fecha_presentacion			VARCHAR (10)	COLLATE database_default,
														fecha_constitucion			VARCHAR (10)	COLLATE database_default,
														cod_grado					VARCHAR (2)		COLLATE database_default,
														numero_finca				VARCHAR (25)	COLLATE database_default,
														num_placa_bien				VARCHAR (25)	COLLATE database_default,
														cod_clase_bien				VARCHAR (3)		COLLATE database_default,
														cod_usuario					VARCHAR (30)	COLLATE database_default,
														Porcentaje_Aceptacion		DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
														cod_clase_garantia			SMALLINT,
														cod_partido					SMALLINT
														PRIMARY KEY (cod_llave)
													)




	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	CREATE TABLE #TMP_GARANTIAS_REALES_X_OPERACION (	cod_llave					BIGINT			IDENTITY(1,1),
														cod_contabilidad			TINYINT,
														cod_oficina					SMALLINT,
														cod_moneda					TINYINT,
														cod_producto				TINYINT,
														operacion					DECIMAL (7,0),
														cod_tipo_bien				SMALLINT,
														cod_tipo_mitigador			SMALLINT,
														cod_tipo_documento_legal	SMALLINT,
														cod_operacion				BIGINT,
														cod_garantia_real			BIGINT,
														cod_tipo_garantia_real		TINYINT,
														cod_tipo_operacion			TINYINT,
														ind_duplicidad				TINYINT			DEFAULT (1)	,
														porcentaje_responsabilidad	DECIMAL (5,2),
														monto_mitigador				DECIMAL (18,2),
														cod_bien					VARCHAR (25)	COLLATE database_default,
														fecha_constitucion			VARCHAR (10)	COLLATE database_default,
														fec_constitucion			DATETIME,	
														cod_usuario					VARCHAR (30)	COLLATE database_default,
														cod_inscripcion				SMALLINT,
														fecha_presentacion			VARCHAR (10)	COLLATE database_default,
														Porcentaje_Aceptacion		DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
														PRIMARY KEY (cod_llave)
													)
	

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

	DECLARE @vdtFecha_Actual_Sin_Hora	DATETIME,  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones
			@viConsecutivo	BIGINT --Se usa para generar los códigos de la tabla temporal de números.

	SET @vdtFecha_Actual_Sin_Hora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET	@viConsecutivo = 1

	--Se carga la tabla temporal de consecutivos
	WHILE	@viConsecutivo <= 69
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
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
     cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion, cod_operacion, cod_garantia_real, 
     cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_presentacion, fecha_constitucion, cod_grado, numero_finca,
     num_placa_bien, cod_clase_bien, cod_usuario, Porcentaje_Aceptacion, cod_clase_garantia, cod_partido)

	SELECT	DISTINCT 
			1 AS cod_contabilidad, 
			ROV.cod_oficina, 
			ROV.cod_moneda, 
			ROV.cod_producto, 
			ROV.num_operacion AS operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			1 AS cod_tipo_operacion,
			1 AS ind_duplicidad,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
			COALESCE(GGR.cod_grado,'') AS cod_grado,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
			@psCedula_Usuario AS cod_usuario,
			GRO.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			GGR.cod_clase_garantia,
			GGR.cod_partido 
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
	WHERE	ROV.cod_tipo_operacion = 1
		AND MGT.prmgt_pco_grado = COALESCE(GGR.cod_grado, MGT.prmgt_pco_grado)
		AND MGT.prmgt_pnu_part =	CASE	
										WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
										ELSE GGR.cod_partido
									END
	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GGR.cod_clase_bien,
		GGR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se selecciona la información de la garantía real asociada a los contratos*/
	INSERT INTO #TMP_GARANTIAS_REALES_OPERACIONES 
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
     cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion, cod_operacion, cod_garantia_real, 
     cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_presentacion, fecha_constitucion, cod_grado, numero_finca,
     num_placa_bien, cod_clase_bien, cod_usuario, Porcentaje_Aceptacion, cod_clase_garantia, cod_partido)

	SELECT	DISTINCT 
			1 AS cod_contabilidad, 
			ROV.cod_oficina_contrato, 
			ROV.cod_moneda_contrato, 
			ROV.cod_producto_contrato, 
			ROV.num_contrato AS operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			2 AS cod_tipo_operacion,
			1 AS ind_duplicidad,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
			COALESCE(GGR.cod_grado,'') AS cod_grado,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
			@psCedula_Usuario AS cod_usuario,
			GRO.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			GGR.cod_clase_garantia,
			GGR.cod_partido 
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		ON ROV.cod_operacion = GRO.cod_operacion 
		AND ROV.cod_garantia = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		ON GGR.cod_garantia_real	= ROV.cod_garantia
		INNER JOIN #TEMP_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc COLLATE DATABASE_DEFAULT
		AND MGT.prmgt_pco_produ = 10
	WHERE	ROV.cod_tipo_operacion = 2	
		AND MGT.prmgt_pco_grado = COALESCE(GGR.cod_grado, MGT.prmgt_pco_grado)
		AND MGT.prmgt_pnu_part =	CASE	
										WHEN GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
										ELSE GGR.cod_partido
									END
	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GGR.cod_clase_bien,
		GGR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se eliminan los registros incompletos*/
	DELETE	FROM #TMP_GARANTIAS_REALES_OPERACIONES
	WHERE	cod_usuario =  @psCedula_Usuario
		AND cod_tipo_documento_legal = -1
		AND fecha_presentacion = '19000101'
		AND cod_tipo_mitigador = -1
		AND cod_inscripcion = -1 

	/*Se eliminan los registros de hipotecas comunes duplicadas*/
	WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_clase_garantia, cod_partido, numero_finca, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca, cod_tipo_operacion  ORDER BY cod_clase_garantia, cod_partido, numero_finca, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
			AND cod_clase_garantia BETWEEN 10 AND 17
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se eliminan los registros de cédulas hipotecarias con clase 18 duplicadas*/
	WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion  ORDER BY cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
			AND cod_clase_garantia = 18
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


	/*Se eliminan los registros de cédulas hipotecarias con clase diferente 18 duplicadas*/
	WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion  ORDER BY cod_clase_garantia, cod_partido, numero_finca, cod_grado, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
			AND cod_clase_garantia BETWEEN 20 AND 29
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se eliminan los registros de prendas duplicadas*/
	WITH CTE (cod_clase_garantia, num_placa_bien, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_clase_garantia, num_placa_bien, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, num_placa_bien, cod_tipo_operacion  ORDER BY cod_clase_garantia, num_placa_bien, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	cod_usuario =  @psCedula_Usuario
			AND cod_clase_garantia BETWEEN 30 AND 69
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
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
	 cod_tipo_mitigador, cod_tipo_documento_legal, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_constitucion, fec_constitucion, cod_usuario, cod_inscripcion, 
	 fecha_presentacion, Porcentaje_Aceptacion)


	SELECT	DISTINCT
			TGR.cod_contabilidad, 
			TGR.cod_oficina, 
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			TGR.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			TGR.cod_tipo_operacion,
			TGR.ind_duplicidad,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
			COALESCE(GRO.fecha_constitucion, '19000101') AS fec_constitucion,
			TGR.cod_usuario,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			TGR.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	#TMP_GARANTIAS_REALES_OPERACIONES TGR
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TGR.cod_operacion
		AND GRO.cod_garantia_real = TGR.cod_garantia_real
		INNER JOIN GAR_GARANTIA_REAL GGR
		ON GGR.cod_garantia_real = TGR.cod_garantia_real

/************************************************************************************************
 *                                                                                              * 
 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                            INICIO DE LA SELECCIÓN DE ALERTAS                                 *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	--Se escogen los registros en alerta
	INSERT INTO #TMP_ALERTAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
							  Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
							  Usuario, Codigo_Bien, Descripcion_Tipo_Garantia, Monto_Mitigador,
							  Porcentaje_Aceptacion, Indicador_Inscripcion, Des_Indicador_Inscripcion, 
							  Fecha_Constitucion, Dias_Acumulados)
	SELECT	DISTINCT 
			1,
			TMP.cod_oficina,
			TMP.cod_moneda,
			TMP.cod_producto,
			TMP.operacion,
			TMP.cod_tipo_bien,
			TMP.cod_tipo_mitigador,
			TMP.cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			TMP.cod_bien AS Codigo_Bien, 
			'Real',
			TMP.monto_mitigador,
			TMP.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			TMP.cod_inscripcion,
			CE1.cat_descripcion AS Des_Indicador_Inscripcion,
			TMP.fecha_constitucion,
			DATEDIFF(DAY, TMP.fec_constitucion, GETDATE()) AS Dias_Acumulados	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TMP
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = TMP.cod_inscripcion
	WHERE	TMP.cod_usuario = @psCedula_Usuario
		AND TMP.cod_tipo_operacion IN (1, 2)
		AND TMP.cod_inscripcion	= 1
		AND CE1.cat_catalogo = @piCatalogo_Ind_Ins

	UNION ALL

	SELECT	DISTINCT
			1,
			TMP.cod_oficina,
			TMP.cod_moneda,
			TMP.cod_producto,
			TMP.operacion,
			TMP.cod_tipo_bien,
			TMP.cod_tipo_mitigador,
			TMP.cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			TMP.cod_bien AS Codigo_Bien, 
			'Real',
			TMP.monto_mitigador,
			TMP.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			TMP.cod_inscripcion,
			CE1.cat_descripcion AS Des_Indicador_Inscripcion,
			TMP.fecha_constitucion,
			DATEDIFF(DAY, TMP.fec_constitucion, GETDATE()) AS Dias_Acumulados		
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION TMP
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = TMP.cod_inscripcion
	WHERE	TMP.cod_usuario = @psCedula_Usuario
		AND TMP.cod_tipo_operacion IN (1, 2)
		AND TMP.cod_inscripcion = 2 
		AND CE1.cat_catalogo = @piCatalogo_Ind_Ins

/************************************************************************************************
 *                                                                                              * 
 *                              FIN DE LA SELECCIÓN DE ALERTAS                                  *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'pa_Alertas_Indicador_Inscripcion_Garantias_Reales' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Alerta!3!DATOS!element], 
				NULL						AS [Alerta!3!Usuario!hide]
		FROM	#TMP_ALERTAS 
		WHERE	Usuario						=  @psCedula_Usuario
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
				NULL						AS [Alerta!3!DATOS!element], 
				NULL						AS [Alerta!3!Usuario!hide]
		FROM	#TMP_ALERTAS 
		WHERE	Usuario						=  @psCedula_Usuario
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
                 (CASE WHEN  Tipo_Bien = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Bien) END) + CHAR(9) +
				 COALESCE(Codigo_Bien, '') + CHAR(9) + 
                 (CASE WHEN  Tipo_Mitigador = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Mitigador) END) + CHAR(9) + 
                 (CASE WHEN  Tipo_Documento_Legal = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Documento_Legal) END) + CHAR(9) +
				 COALESCE(CONVERT(VARCHAR(100), Monto_Mitigador), '') + CHAR(9) + 
				 COALESCE(CONVERT(VARCHAR(20), Porcentaje_Aceptacion), '') + CHAR(9) +  --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 COALESCE(Des_Indicador_Inscripcion, '') + CHAR(9) + 
				 COALESCE(CONVERT(VARCHAR(50), Dias_Acumulados), ''))	AS [Alerta!3!DATOS!element],
				Usuario							AS [Alerta!3!Usuario!hide]
		FROM	#TMP_ALERTAS 
		WHERE	Usuario	 =  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Alertas_Indicador_Inscripcion_Garantias_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END