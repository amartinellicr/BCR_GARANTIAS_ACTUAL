USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Inconsistencias_Indicador_Inscripcion_Garantias_Reales', 'P') IS NOT NULL
DROP PROCEDURE pa_Inconsistencias_Indicador_Inscripcion_Garantias_Reales;
GO

CREATE PROCEDURE [dbo].[pa_Inconsistencias_Indicador_Inscripcion_Garantias_Reales]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Inconsistencias_Indicador_Inscripcion_Garantias_Reales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las inconsistencias referentes al campo del indicador de inscripción.
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
	<Requerimiento>Indicador de Inscripción, Sibel: 1 - 21317031</Requerimiento>
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
			<Fecha>06/07/2015</Fecha>
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
	CREATE TABLE #TMP_INCONSISTENCIAS	(
											Contabilidad				TINYINT			,
											Oficina						SMALLINT		,
											Moneda						TINYINT			,
											Producto					TINYINT			,
											Operacion					DECIMAL(7)		,
											Tipo_Bien					SMALLINT		,
											Tipo_Mitigador				SMALLINT		,
											Tipo_Documento_Legal		SMALLINT		,
											Tipo_Garantia				TINYINT			,
											Usuario						VARCHAR(30)		COLLATE DATABASE_DEFAULT, 
											Codigo_Bien					VARCHAR(30)		COLLATE DATABASE_DEFAULT ,
											Tipo_Inconsistencia			VARCHAR(100)	COLLATE DATABASE_DEFAULT ,
											Descripcion_Tipo_Garantia	VARCHAR(15)		COLLATE DATABASE_DEFAULT 
										)


	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	CREATE TABLE #TMP_GARANTIAS_REALES_OPERACIONES  (	cod_llave					BIGINT			IDENTITY(1,1),
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
														monto_mitigador				DECIMAL (18,2),
														cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														fecha_presentacion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														fecha_constitucion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														cod_grado					VARCHAR (2)		COLLATE DATABASE_DEFAULT,
														numero_finca				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														num_placa_bien				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														cod_clase_bien				VARCHAR (3)		COLLATE DATABASE_DEFAULT,
														cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														Porcentaje_Aceptacion		DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
														cod_clase_garantia			SMALLINT,
														cod_partido					SMALLINT
														PRIMARY KEY (cod_llave)
													)


	CREATE INDEX TMP_GARANTIAS_REALES_OPERACIONES_IX_01 ON #TMP_GARANTIAS_REALES_OPERACIONES (cod_usuario, cod_clase_garantia)

	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	CREATE TABLE #TMP_GARANTIAS_REALES_X_OPERACION	(	cod_llave					BIGINT			IDENTITY(1,1),
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
														monto_mitigador				DECIMAL (18,2),
														cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														fecha_constitucion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														cod_inscripcion				SMALLINT,
														fecha_presentacion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
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

	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

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

	/*Se eliminan los registros de prendas duplicadas*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, num_placa_bien) AS cantidadRegistrosDuplicados
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
	 monto_mitigador, cod_bien, fecha_constitucion, cod_usuario, cod_inscripcion, 
	 fecha_presentacion, Porcentaje_Aceptacion)

	SELECT	DISTINCT
			TGR.cod_contabilidad, 
			TGR.cod_oficina, 
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			TGR.cod_tipo_bien, 
			TGR.cod_tipo_mitigador, 
			TGR.cod_tipo_documento_legal,
			TGR.cod_operacion,
			TGR.cod_garantia_real,
			TGR.monto_mitigador,
			TGR.cod_bien, 
			TGR.fecha_constitucion, 
			TGR.cod_usuario,
			TGR.cod_inscripcion, 
			TGR.fecha_presentacion,
			TGR.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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

	--/*Se actualiza a NULL todas las fechas de presentación que sea igual a 01/01/1900*/
	--UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	--SET		fecha_presentacion = NULL
	--WHERE	fecha_presentacion = '19000101'

	--/*Se actualiza a NULL los indicadores de inscripción iguales a -1*/
	--UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	--SET		cod_inscripcion = NULL
	--WHERE	cod_inscripcion = -1


/*INCONSISTENCIAS DEL CAMPO: FECHA DE PRESENTACION*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignada una fecha de presentación menor a la fecha de constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrFechapresentación',
			'Real'	
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion > '19000101'
		AND fecha_presentacion < fecha_constitucion


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen asignada una fecha de presentación. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrFechapresentación',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion = '19000101'


/*INCONSISTENCIAS DEL CAMPO: INDICADOR DE INSCRIPCION*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen asignado el indicador de inscripción. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real'
	FROM #TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario = @psCedula_Usuario
		AND fecha_presentacion > '19000101'
		AND cod_inscripcion  = -1
	

	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario	= @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2 
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion)


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso 
    --(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 días a la fecha de constitución.  
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 1 
		AND @vdtFecha_Actual_Sin_Hora >= DATEADD(DAY, 30, fecha_constitucion)


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica", pero que poseen un tipo de bien
    --diferente a "Otros tipos de bienes". 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 0 
		AND cod_tipo_bien <> 14



/*INCONSISTENCIAS DEL CAMPO: MONTO MITIGADOR*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución y además posee
    --un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real'		
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion) 
		AND monto_mitigador <> 0


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Inscrita", pero además posee un monto mitigador igual o menor a cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 3 
		AND monto_mitigador <= 0


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica" y que posee
    --un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario	= @psCedula_Usuario
		AND cod_inscripcion = 0 
		AND monto_mitigador <> 0


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", además de que la fecha de 
    --proceso (fecha actual) sea mayor o igual a la fecha resultante de sumarle 30 días a la fecha de constitución y 
    --que posee un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 1 
		AND @vdtFecha_Actual_Sin_Hora >= DATEADD(DAY, 30, fecha_constitucion)
		AND monto_mitigador <> 0
	
/*INCONSISTENCIAS DEL CAMPO: PORCENTAJE DE ACEPTACION*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución y además posee
    --un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptación',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario	= @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion	= 2
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion)
		AND Porcentaje_Aceptacion <> 0  --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Inscrita" y un porcentaje de aceptación igual o menor a cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptación',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion	= 3
		AND Porcentaje_Aceptacion <= 0  --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica" y que posee
    --un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptación',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 0
		AND Porcentaje_Aceptacion <> 0  --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", además de que la fecha de 
    --proceso (fecha actual) sea mayor o igual a la fecha resultante de sumarle 30 días a la fecha de constitución y 
    --que posee un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Usuario, Codigo_Bien, Tipo_Inconsistencia, Descripcion_Tipo_Garantia)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptación',
			'Real'
	FROM	#TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 1 
		AND @vdtFecha_Actual_Sin_Hora >= DATEADD(DAY, 30, fecha_constitucion)
		AND Porcentaje_Aceptacion <> 0  --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


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
				'pa_Inconsistencias_Indicador_Inscripcion' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Inconsistencia!3!DATOS!element], 
				NULL						AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
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
                 (CASE WHEN  Tipo_Bien = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Bien) END) + CHAR(9) +
				 COALESCE(Codigo_Bien, '') + CHAR(9) + 
                 (CASE WHEN  Tipo_Mitigador = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Mitigador) END) + CHAR(9) + 
                 (CASE WHEN  Tipo_Documento_Legal = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Documento_Legal) END) + CHAR(9) +
				 Tipo_Inconsistencia + CHAR(9) + 
				 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 '' + CHAR(9) + 
				 '')	AS [Inconsistencia!3!DATOS!element],
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario	= @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Indicador_Inscripcion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END