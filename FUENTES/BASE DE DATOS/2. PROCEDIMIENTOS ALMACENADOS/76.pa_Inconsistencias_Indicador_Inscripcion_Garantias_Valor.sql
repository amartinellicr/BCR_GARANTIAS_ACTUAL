USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Inconsistencias_Indicador_Inscripcion_Garantias_Valor', 'P') IS NOT NULL
DROP PROCEDURE pa_Inconsistencias_Indicador_Inscripcion_Garantias_Valor;
GO

CREATE PROCEDURE [dbo].[pa_Inconsistencias_Indicador_Inscripcion_Garantias_Valor]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Inconsistencias_Indicador_Inscripcion_Garantias_Valor</Nombre>
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
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>09/12/2015</Fecha>
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

	CREATE TABLE #TMP_INCONSISTENCIAS  (
											Contabilidad				TINYINT			,
											Oficina						SMALLINT		,
											Moneda						TINYINT			,
											Producto					TINYINT			,
											Operacion					DECIMAL(7)		,
											Tipo_Bien					SMALLINT		,
											Tipo_Mitigador				SMALLINT		,
											Tipo_Documento_Legal		SMALLINT		,
											Tipo_Garantia				TINYINT			,
											Tipo_Instrumento			SMALLINT		,
											Usuario						VARCHAR(30)		COLLATE DATABASE_DEFAULT, 
											Codigo_Bien					VARCHAR(30)		COLLATE DATABASE_DEFAULT ,
											Tipo_Inconsistencia			VARCHAR(100)	COLLATE DATABASE_DEFAULT ,
											Descripcion_Tipo_Garantia	VARCHAR(15)		COLLATE DATABASE_DEFAULT ,
											Numero_Seguridad			VARCHAR(25)		COLLATE DATABASE_DEFAULT 
										)



	/*Se declara la variable tipo tabla que funcionara como maestra*/
	CREATE TABLE #TMP_GARANTIAS_VALOR  (	cod_contabilidad				TINYINT,
											cod_oficina						SMALLINT,
											cod_moneda						TINYINT,
											cod_producto					TINYINT,
											operacion						DECIMAL (7,0),
											numero_seguridad				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
											cod_tipo_mitigador				SMALLINT,
											cod_tipo_documento_legal		SMALLINT,
											monto_mitigador					DECIMAL (18,2),
											fecha_presentacion				VARCHAR (10)	COLLATE DATABASE_DEFAULT,
											cod_inscripcion					SMALLINT,
											porcentaje_responsabilidad		DECIMAL (5,2),
											fecha_constitucion				VARCHAR (10)	COLLATE DATABASE_DEFAULT,
											cod_clasificacion_instrumento	SMALLINT,
											des_instrumento					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
											cod_tipo_garantia				SMALLINT,
											cod_garantia_valor				BIGINT,
											cod_operacion					BIGINT,
											cod_estado						SMALLINT,
											cod_tipo_operacion				TINYINT,
											ind_duplicidad					TINYINT			DEFAULT (1)	,
											cod_usuario						VARCHAR (30)	COLLATE DATABASE_DEFAULT,
											cod_clase_garantia				SMALLINT,
											Porcentaje_Aceptacion			DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
											cod_llave						BIGINT			IDENTITY(1,1)
											PRIMARY KEY (cod_llave)
										)

	/*Esta tabla almacenará las garantías registradas en el sistema*/
	CREATE TABLE #TEMP_PRMGT (	prmgt_pcoclagar TINYINT,
								prmgt_pnuidegar DECIMAL(12,0),
								prmgt_pcotengar TINYINT,
								prmgt_pco_produ TINYINT)
		 
	CREATE INDEX TEMP_PRMGT_IX_01 ON #TEMP_PRMGT (prmgt_pcoclagar, prmgt_pnuidegar)
	
	
	
	DECLARE @vdtFecha_Actual_Sin_Hora	DATETIME,  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones
			@viConsecutivo	INT --Se usa para generar los códigos de la tabla temporal de números.

	SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET	@viConsecutivo = 20

	DECLARE @CLASES_GARANTIAS_VALOR TABLE (Consecutivo TINYINT 
											PRIMARY KEY (Consecutivo)) --Se utilizará para generar los semestres a ser calculados

	
	--Se carga la tabla temporal de consecutivos
	WHILE	@viConsecutivo <= 29
	BEGIN
		INSERT INTO @CLASES_GARANTIAS_VALOR (Consecutivo) VALUES(@viConsecutivo)
		SET @viConsecutivo = @viConsecutivo + 1
	END


/************************************************************************************************
 *                                                                                              * 
 *                     INICIO DEL FILTRADO DE LAS GARANTIAS DE VALOR                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se obtienen las garantías relacionadas al contrato*/
	INSERT	INTO #TEMP_PRMGT(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pcotengar, prmgt_pco_produ)
	SELECT  MGT.prmgt_pcoclagar,
			MGT.prmgt_pnuidegar,
			MGT.prmgt_pcotengar,
			MGT.prmgt_pco_produ
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN @CLASES_GARANTIAS_VALOR CGR
			ON CGR.Consecutivo = MGT.prmgt_pcoclagar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcotengar	IN (2,3,4,6)


	/*Se selecciona la información de la garantías de valor asociadas a las operaciones*/
	INSERT INTO #TMP_GARANTIAS_VALOR (	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
										numero_seguridad, cod_tipo_mitigador, cod_tipo_documento_legal, 
										monto_mitigador, fecha_presentacion, cod_inscripcion, 
										porcentaje_responsabilidad, fecha_constitucion, 
										cod_clasificacion_instrumento, des_instrumento, 
										cod_tipo_garantia, cod_garantia_valor, cod_operacion, 
										cod_estado, cod_tipo_operacion, ind_duplicidad, cod_usuario, cod_clase_garantia, Porcentaje_Aceptacion)
	
		SELECT	DISTINCT 
				1 AS cod_contabilidad, 
				VOV.cod_oficina, 
				VOV.cod_moneda, 
				VOV.cod_producto, 
				VOV.num_operacion AS operacion, 
				GGV.numero_seguridad AS numero_seguridad, 
				COALESCE(GVO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
				COALESCE(GVO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
				COALESCE(GVO.monto_mitigador, 0) AS monto_mitigador,
				CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GVO.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
				COALESCE(GVO.cod_inscripcion, -1) AS cod_inscripcion,
				COALESCE(GVO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
				CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GGV.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
				COALESCE(GGV.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
				COALESCE(GGV.des_instrumento, '') AS des_instrumento,
				GGV.cod_tipo_garantia,
				GVO.cod_garantia_valor,
				GVO.cod_operacion,
				GVO.cod_estado,
				1 AS cod_tipo_operacion,	
				1 AS ind_duplicidad,
				@psCedula_Usuario AS cod_usuario,
				GGV.cod_clase_garantia,
				GVO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.	
		FROM	dbo.GARANTIAS_VALOR_X_OPERACION_VW VOV 
			INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
			 ON VOV.cod_operacion = GVO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
			ON GGV.cod_garantia_valor = GVO.cod_garantia_valor 
			INNER JOIN #TEMP_PRMGT MGT
			ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc 
			AND MGT.prmgt_pco_produ = VOV.cod_producto
		WHERE	VOV.cod_tipo_operacion = 1
		ORDER BY
			GVO.cod_operacion,
			GGV.numero_seguridad,
			GVO.cod_tipo_documento_legal DESC


	/*Se selecciona la información de las garantías de valor asociada a los contratos*/
	INSERT INTO #TMP_GARANTIAS_VALOR (	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
										numero_seguridad, cod_tipo_mitigador, cod_tipo_documento_legal, 
										monto_mitigador, fecha_presentacion, cod_inscripcion, 
										porcentaje_responsabilidad, fecha_constitucion, 
										cod_clasificacion_instrumento, des_instrumento, 
										cod_tipo_garantia, cod_garantia_valor, cod_operacion, 
										cod_estado, cod_tipo_operacion, ind_duplicidad, cod_usuario, cod_clase_garantia, Porcentaje_Aceptacion)
	
		SELECT	DISTINCT 
				1 AS cod_contabilidad, 
				VOV.cod_oficina_contrato, 
				VOV.cod_moneda_contrato, 
				VOV.cod_producto_contrato, 
				VOV.num_contrato AS operacion, 
				GGV.numero_seguridad AS numero_seguridad, 
				COALESCE(GVO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
				COALESCE(GVO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
				COALESCE(GVO.monto_mitigador, 0) AS monto_mitigador,
				CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GVO.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
				COALESCE(GVO.cod_inscripcion, -1) AS cod_inscripcion,
				COALESCE(GVO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
				CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GGV.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
				COALESCE(GGV.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
				COALESCE(GGV.des_instrumento, '') AS des_instrumento,
				GGV.cod_tipo_garantia,
				GVO.cod_garantia_valor,
				GVO.cod_operacion,
				GVO.cod_estado,
				2 AS cod_tipo_operacion,	
				1 AS ind_duplicidad,
				@psCedula_Usuario AS cod_usuario,
				GGV.cod_clase_garantia,
				GVO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.		
		FROM	dbo.GARANTIAS_VALOR_X_OPERACION_VW VOV 
			INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
			ON VOV.cod_operacion = GVO.cod_operacion 
			INNER JOIN GAR_GARANTIA_VALOR GGV
			ON GGV.cod_garantia_valor = GVO.cod_garantia_valor 
			INNER JOIN #TEMP_PRMGT MGT
			ON MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc 
			AND MGT.prmgt_pco_produ = 10
		WHERE	VOV.cod_tipo_operacion = 2		
		ORDER BY
			GVO.cod_operacion,
			GGV.numero_seguridad,
			GVO.cod_tipo_documento_legal DESC


	/*Se eliminan los registros incompletos*/
	DELETE	FROM #TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_documento_legal = -1
		AND fecha_presentacion = '19000101'
		AND cod_tipo_mitigador = -1
		AND cod_inscripcion = -1 

	/*Se eliminan los registros de hipotecas comunes duplicadas*/
	WITH CTE (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion,cod_clase_garantia, numero_seguridad, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, numero_seguridad, 
				ROW_NUMBER() OVER(PARTITION BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, numero_seguridad  ORDER BY cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_clase_garantia, numero_seguridad) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_VALOR
		WHERE	cod_usuario =  @psCedula_Usuario
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

/************************************************************************************************
 *                                                                                              * 
 *                      FIN DEL FILTRADO DE LAS GARANTIAS DE VALOR                              *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	--/*Se actualiza a NULL todas las fechas de presentación que sea igual a 01/01/1900*/
	--UPDATE #TMP_GARANTIAS_VALOR
	--SET fecha_presentacion		= NULL
	--WHERE fecha_presentacion	= '19000101'

	--/*Se actualiza a NULL todas los indicadores de inscripción que sean igual a -1*/
	--UPDATE #TMP_GARANTIAS_VALOR
	--SET cod_inscripcion			= NULL
	--WHERE cod_inscripcion		= -1


/*INCONSISTENCIAS DEL CAMPO: FECHA DE PRESENTACION*/
	
	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que no poseen asignada una fecha de presentación. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrFechapresentación',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion = '19000101'

	
	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignada una fecha de presentación menor a la fecha de constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrFechapresentación',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion > '19000101' 
		AND fecha_presentacion < fecha_constitucion


/*INCONSISTENCIAS DEL CAMPO: INDICADOR DE INSCRIPCION*/
	
	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrIndicadorInscrip',
			'Valor',
			numero_seguridad	
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2 
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion)



	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constitución y la fecha resultante de sumarle 30 días a la fecha de 
    --constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrIndicadorInscrip',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 3 
		AND @vdtFecha_Actual_Sin_Hora BETWEEN fecha_constitucion AND DATEADD(DAY, 30, fecha_constitucion)


	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso (fecha actual) 
    --es mayor a la fecha resultante de sumarle 30 días a la fecha de constitución. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrIndicadorInscrip',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 1 
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 30, fecha_constitucion)



	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que no poseen asignado el indicador de inscripción. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrIndicadorInscrip',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion > '19000101'
		AND cod_inscripcion IS NULL



/*INCONSISTENCIAS DEL CAMPO: MONTO MITIGADOR*/
	
	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución y además posee
    --un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrMontomitiga',
			'Valor',
			numero_seguridad	
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2 
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion) 
		AND monto_mitigador	<> 0
		

	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constitución y la fecha resultante de sumarle 30 días a la fecha de 
    --constitución y además posee un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrMontomitiga',
			'Valor',
			numero_seguridad	
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		 AND cod_inscripcion = 3 
		AND @vdtFecha_Actual_Sin_Hora BETWEEN fecha_constitucion AND DATEADD(DAY, 30, fecha_constitucion) 
		AND monto_mitigador	<> 0
		

	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica" y que posee
    --un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrMontomitiga',
			'Valor',
			numero_seguridad
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 0 
		AND monto_mitigador	<> 0


	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", además de que 
    --la fecha de proceso (fecha actual) sea mayor a la fecha resultante de sumarle 30 días a la 
    --fecha de constitución y que posee un monto mitigador diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrMontomitiga',
			'Valor',
			numero_seguridad			
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario	= @psCedula_Usuario
		AND cod_inscripcion = 1
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 30, fecha_constitucion)
		AND monto_mitigador <> 0



/*INCONSISTENCIAS DEL CAMPO: PORCENTAJE DE ACEPTACION*/
	
	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución y además posee
    --un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptación',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion)
		AND Porcentaje_Aceptacion <> 0 --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constitución y la fecha resultante de sumarle 30 días a la fecha de 
    --constitución y un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptación',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 3 
		AND @vdtFecha_Actual_Sin_Hora BETWEEN fecha_constitucion AND DATEADD(DAY, 30, fecha_constitucion) 
		AND Porcentaje_Aceptacion <> 0 --RQ_MANT_2015111010495738_00610: Se ajusta este campo.


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica" y que posee
    --un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptación',
			'Valor',
			numero_seguridad		
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario	= @psCedula_Usuario
		AND cod_inscripcion	= 0
		AND Porcentaje_Aceptacion <> 0 --RQ_MANT_2015111010495738_00610: Se ajusta este campo.



	--Se escoge la información de las garantías de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", además de que la fecha de 
    --proceso (fecha actual) sea mayor a la fecha resultante de sumarle 30 días a la fecha de constitución y 
    --que posee un porcentaje de aceptación diferente de cero. 
	INSERT INTO #TMP_INCONSISTENCIAS (	Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                        Descripcion_Tipo_Garantia, Numero_Seguridad)


	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptación',
			'Valor',
			numero_seguridad			
	FROM	#TMP_GARANTIAS_VALOR
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 1
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 30, fecha_constitucion)
		AND Porcentaje_Aceptacion <> 0 --RQ_MANT_2015111010495738_00610: Se ajusta este campo.

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
                 COALESCE(CONVERT(VARCHAR(5), Tipo_Bien), '') + CHAR(9) +
				 COALESCE(Codigo_Bien, '') + CHAR(9) + 
                 (CASE WHEN  Tipo_Mitigador = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Mitigador) END) + CHAR(9) + 
				 (CASE WHEN  Tipo_Documento_Legal = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Documento_Legal) END) + CHAR(9) +
				 Tipo_Inconsistencia + CHAR(9) + 
                 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 Numero_Seguridad + CHAR(9) +
				 (CASE WHEN  Tipo_Instrumento = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Instrumento) END))
											AS [Inconsistencia!3!DATOS!element],
				Usuario						AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Indicador_Inscripcion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END