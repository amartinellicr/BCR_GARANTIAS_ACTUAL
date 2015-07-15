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
	DECLARE @TMP_ALERTAS TABLE (
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
								Porcentaje_Aceptacion		DECIMAL(5,2)	,
								Indicador_Inscripcion		SMALLINT		,
								Des_Indicador_Inscripcion	VARCHAR(160)	COLLATE database_default ,
								Fecha_Constitucion			VARCHAR(10)		COLLATE database_default ,
								Dias_Acumulados				INT
							)


	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	DECLARE @TMP_GARANTIAS_REALES_OPERACIONES TABLE (	cod_llave					BIGINT			IDENTITY(1,1),
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
														cod_usuario					VARCHAR (30)	COLLATE database_default
														PRIMARY KEY (cod_llave)
													)




	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	DECLARE @TMP_GARANTIAS_REALES_X_OPERACION TABLE (	cod_llave					BIGINT			IDENTITY(1,1),
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
														fecha_presentacion			VARCHAR (10)	COLLATE database_default
														PRIMARY KEY (cod_llave)
													)
	

	DECLARE @vdFechaActualSinHora	DATETIME  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones

	SET @vdFechaActualSinHora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	
	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2


/************************************************************************************************
 *                                                                                              * 
 *                       INICIO DEL FILTRADO DE LAS GARANTIAS REALES                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se selecciona la información de la garantía real asociada a las operaciones*/
	INSERT INTO @TMP_GARANTIAS_REALES_OPERACIONES 
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
     cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion, cod_operacion, cod_garantia_real, 
     cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_presentacion, fecha_constitucion, cod_grado, numero_finca,
     num_placa_bien, cod_clase_bien, cod_usuario)

	SELECT DISTINCT 
		1 AS cod_contabilidad, 
		ROV.cod_oficina, 
		ROV.cod_moneda, 
		ROV.cod_producto, 
		ROV.num_operacion AS operacion, 
		COALESCE(GR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ROV.cod_operacion,
		GR.cod_garantia_real,
		GR.cod_tipo_garantia_real,
		1 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE 
			WHEN GR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')  
			WHEN GR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')
			WHEN ((GR.cod_tipo_garantia_real = 3) AND (GR.cod_clase_garantia <> 38) AND (GR.cod_clase_garantia <> 43)) THEN COALESCE(GR.cod_clase_bien,'') + '-' + COALESCE(GR.num_placa_bien,'') 
			WHEN ((GR.cod_tipo_garantia_real = 3) AND ((GR.cod_clase_garantia = 38) OR (GR.cod_clase_garantia = 43))) THEN COALESCE(GR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		COALESCE(GR.cod_grado,'') AS cod_grado,
		COALESCE(GR.numero_finca,'') AS numero_finca,
		COALESCE(GR.num_placa_bien,'') AS num_placa_bien,
		COALESCE(GR.cod_clase_bien,'') AS cod_clase_bien,
		@psCedula_Usuario AS cod_usuario

	FROM 
		dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		 AND ROV.cod_garantia		= GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GR 
		 ON GR.cod_garantia_real	= ROV.cod_garantia

	WHERE GRO.cod_estado			= 1
		AND ROV.cod_tipo_operacion	= 1

	ORDER BY
		ROV.cod_operacion,
		GR.numero_finca,
		GR.cod_grado,
		GR.cod_clase_bien,
		GR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se selecciona la información de la garantía real asociada a los contratos*/
	INSERT INTO @TMP_GARANTIAS_REALES_OPERACIONES 
    (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
     cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion, cod_operacion, cod_garantia_real, 
     cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_presentacion, fecha_constitucion, cod_grado, numero_finca,
     num_placa_bien, cod_clase_bien, cod_usuario)

	SELECT DISTINCT 
		1 AS cod_contabilidad, 
		ROV.cod_oficina_contrato, 
		ROV.cod_moneda_contrato, 
		ROV.cod_producto_contrato, 
		ROV.num_contrato AS operacion, 
		COALESCE(GR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ROV.cod_operacion,
		GR.cod_garantia_real,
		GR.cod_tipo_garantia_real,
		2 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE 
			WHEN GR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')  
			WHEN GR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')
			WHEN ((GR.cod_tipo_garantia_real = 3) AND (GR.cod_clase_garantia <> 38) AND (GR.cod_clase_garantia <> 43)) THEN COALESCE(GR.cod_clase_bien,'') + '-' + COALESCE(GR.num_placa_bien,'') 
			WHEN ((GR.cod_tipo_garantia_real = 3) AND ((GR.cod_clase_garantia = 38) OR (GR.cod_clase_garantia = 43))) THEN COALESCE(GR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		COALESCE(GR.cod_grado,'') AS cod_grado,
		COALESCE(GR.numero_finca,'') AS numero_finca,
		COALESCE(GR.num_placa_bien,'') AS num_placa_bien,
		COALESCE(GR.cod_clase_bien,'') AS cod_clase_bien,
		@psCedula_Usuario AS cod_usuario
		
	FROM dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		 INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		 AND ROV.cod_garantia		= GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GR 
		 ON GR.cod_garantia_real	= ROV.cod_garantia

	WHERE ROV.cod_tipo_operacion = 2
		AND EXISTS (SELECT 1
					FROM dbo.GAR_SICC_PRMGT GSP
					WHERE GSP.prmgt_pcoclagar	= GR.cod_clase_garantia
					 AND GSP.prmgt_pco_grado	= COALESCE(GR.cod_grado, GSP.prmgt_pco_grado)
					 AND GSP.prmgt_estado		= 'A'
					 AND GSP.prmgt_pnu_oper		= ROV.num_contrato
					 AND GSP.prmgt_pco_ofici	= ROV.cod_oficina_contrato
					 AND GSP.prmgt_pco_moned	= ROV.cod_moneda_contrato
					 AND GSP.prmgt_pco_produ	= 10
					 AND GSP.prmgt_pco_conta	= 1
					 AND COALESCE(GSP.prmgt_pnuidegar, 0) = COALESCE(GR.Identificacion_Sicc, 0)
					 AND COALESCE(GSP.prmgt_pnuide_alf, '') = COALESCE(GR.Identificacion_Alfanumerica_Sicc, ''))

	ORDER BY
		ROV.cod_operacion,
		GR.numero_finca,
		GR.cod_grado,
		GR.cod_clase_bien,
		GR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se obtienen las operaciones duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			cod_bien AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			NULL AS cod_grado

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)

	GROUP BY cod_oficina, cod_moneda,cod_producto, operacion, cod_bien, cod_tipo_operacion
	HAVING COUNT(1) > 1


	/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGR.cod_oficina					= TOD.cod_oficina
					AND TGR.cod_moneda					= TOD.cod_moneda
					AND TGR.cod_producto				= TOD.cod_producto
					AND TGR.operacion					= TOD.operacion
					AND COALESCE(TGR.cod_bien, '')		= COALESCE(TOD.cod_garantia_sicc, '')
					AND COALESCE(TGR.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
					AND TOD.cod_tipo_operacion			IN (1, 2)
					AND TOD.cod_tipo_garantia			= 2
					AND TGR.cod_tipo_documento_legal	IS NULL
					AND TGR.fecha_presentacion			IS NULL
					AND TGR.cod_tipo_mitigador			IS NULL
					AND TGR.cod_inscripcion				IS NULL)
	AND TGR.cod_usuario			= @psCedula_Usuario
	AND TGR.cod_tipo_operacion	IN (1, 2)


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se obtienen las garantías reales de hipoteca común duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_finca AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			NULL AS cod_grado

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_tipo_garantia_real	= 1 
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_usuario				= @psCedula_Usuario

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = GR1.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES GR1
	ON GR1.cod_oficina					= TOD.cod_oficina
	AND GR1.cod_moneda					= TOD.cod_moneda
	AND GR1.cod_producto				= TOD.cod_producto
	AND GR1.operacion					= TOD.operacion
	AND COALESCE(GR1.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND COALESCE(GR2.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
								AND GR2.cod_tipo_garantia_real		= 1
								AND COALESCE(GR2.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND GR2.cod_tipo_operacion			IN (1, 2))
	AND GR1.cod_tipo_garantia_real	= 1
	AND GR1.cod_usuario				= @psCedula_Usuario
	AND GR1.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGR.cod_oficina					= TOD.cod_oficina
					AND TGR.cod_moneda					= TOD.cod_moneda
					AND TGR.cod_producto				= TOD.cod_producto
					AND TGR.operacion					= TOD.operacion
					AND COALESCE(TGR.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND COALESCE(TGR.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
					AND TGR.cod_tipo_garantia_real		= 1
					AND TGR.cod_tipo_operacion			IN (1, 2)
					AND TOD.cod_tipo_garantia			= 2)
	AND TGR.cod_tipo_garantia_real	= 1
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_finca AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			cod_grado

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_tipo_garantia_real	= 2

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = GR1.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES GR1
	ON GR1.cod_oficina					= TOD.cod_oficina
	AND GR1.cod_moneda					= TOD.cod_moneda
	AND GR1.cod_producto				= TOD.cod_producto
	AND GR1.operacion					= TOD.operacion
	AND COALESCE(GR1.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
	AND GR1.cod_grado					= TOD.cod_grado
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND COALESCE(GR2.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
								AND GR2.cod_grado					= TOD.cod_grado
								AND GR2.cod_tipo_garantia_real		= 2
								AND COALESCE(GR2.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND GR2.cod_tipo_operacion			IN (1, 2))
	AND GR1.cod_tipo_garantia_real	= 2
	AND GR1.cod_usuario				= @psCedula_Usuario
	AND GR1.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGR.cod_oficina					= TOD.cod_oficina
					AND TGR.cod_moneda					= TOD.cod_moneda
					AND TGR.cod_producto				= TOD.cod_producto
					AND TGR.operacion					= TOD.operacion
					AND COALESCE(TGR.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
					AND TGR.cod_grado					= TOD.cod_grado
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND TGR.cod_tipo_garantia_real		= 2
					AND COALESCE(TGR.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
					AND TOD.cod_tipo_garantia			= 2
					AND TGR.cod_tipo_operacion			IN (1, 2))
	AND TGR.cod_tipo_garantia_real	= 2
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se obtienen las garantías reales de prenda duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			num_placa_bien AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			NULL AS cod_grado

	FROM @TMP_GARANTIAS_REALES_OPERACIONES

	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_tipo_garantia_real	= 3

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = GR1.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
	INNER JOIN @TMP_GARANTIAS_REALES_OPERACIONES GR1
	ON GR1.cod_oficina					= TOD.cod_oficina
	AND GR1.cod_moneda					= TOD.cod_moneda
	AND GR1.cod_producto				= TOD.cod_producto
	AND GR1.operacion					= TOD.operacion
	AND COALESCE(GR1.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND COALESCE(GR2.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
								AND GR2.cod_tipo_garantia_real		= 3
								AND COALESCE(GR2.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND GR2.cod_tipo_operacion			IN (1, 2))
	AND GR1.cod_tipo_garantia_real	= 3
	AND GR1.cod_usuario				= @psCedula_Usuario
	AND GR1.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_REALES_OPERACIONES
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGR.cod_oficina					= TOD.cod_oficina
					AND TGR.cod_moneda					= TOD.cod_moneda
					AND TGR.cod_producto				= TOD.cod_producto
					AND TGR.operacion					= TOD.operacion
					AND COALESCE(TGR.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND TGR.cod_tipo_garantia_real		= 3
					AND COALESCE(TGR.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
					AND TOD.cod_tipo_garantia			= 2
					AND TGR.cod_tipo_operacion			IN (1, 2))
	AND TGR.cod_tipo_garantia_real	= 3
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario

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

	INSERT INTO @TMP_GARANTIAS_REALES_X_OPERACION 
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
	 cod_tipo_mitigador, cod_tipo_documento_legal, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, fecha_constitucion, fec_constitucion, cod_usuario, cod_inscripcion, 
	 fecha_presentacion)


	SELECT DISTINCT
		TGR.cod_contabilidad, 
		TGR.cod_oficina, 
		TGR.cod_moneda, 
		TGR.cod_producto, 
		TGR.operacion, 
		COALESCE(GR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		TGR.cod_operacion,
		GR.cod_garantia_real,
		GR.cod_tipo_garantia_real,
		TGR.cod_tipo_operacion,
		TGR.ind_duplicidad,
		COALESCE(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE 
			WHEN GR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')  
			WHEN GR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + '-' + COALESCE(GR.numero_finca,'')
			WHEN ((GR.cod_tipo_garantia_real = 3) AND (GR.cod_clase_garantia <> 38) AND (GR.cod_clase_garantia <> 43)) THEN COALESCE(GR.cod_clase_bien,'') + '-' + COALESCE(GR.num_placa_bien,'') 
			WHEN ((GR.cod_tipo_garantia_real = 3) AND ((GR.cod_clase_garantia = 38) OR (GR.cod_clase_garantia = 43))) THEN COALESCE(GR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		COALESCE(GRO.fecha_constitucion, '19000101') AS fec_constitucion,
		TGR.cod_usuario,
		COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion
		
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
	ON GRO.cod_operacion		= TGR.cod_operacion
	AND GRO.cod_garantia_real	= TGR.cod_garantia_real
	INNER JOIN GAR_GARANTIA_REAL GR
	ON GR.cod_garantia_real		= TGR.cod_garantia_real

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
	INSERT INTO @TMP_ALERTAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			TMP.porcentaje_responsabilidad,
			TMP.cod_inscripcion,
			CE1.cat_descripcion AS Des_Indicador_Inscripcion,
			TMP.fecha_constitucion,
			DATEDIFF(DAY, TMP.fec_constitucion, GETDATE()) AS Dias_Acumulados
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TMP
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = TMP.cod_inscripcion
	WHERE TMP.cod_usuario			= @psCedula_Usuario
		AND TMP.cod_tipo_operacion	IN (1, 2)
		AND TMP.cod_inscripcion		= 1
		AND CE1.cat_catalogo		= @piCatalogo_Ind_Ins

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
			TMP.porcentaje_responsabilidad,
			TMP.cod_inscripcion,
			CE1.cat_descripcion AS Des_Indicador_Inscripcion,
			TMP.fecha_constitucion,
			DATEDIFF(DAY, TMP.fec_constitucion, GETDATE()) AS Dias_Acumulados
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TMP
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = TMP.cod_inscripcion
	WHERE TMP.cod_usuario			= @psCedula_Usuario
		AND TMP.cod_tipo_operacion	IN (1, 2)
		AND TMP.cod_inscripcion		= 2 
		AND CE1.cat_catalogo		= @piCatalogo_Ind_Ins

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
		FROM	@TMP_ALERTAS 
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
		FROM	@TMP_ALERTAS 
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
				 COALESCE(CONVERT(VARCHAR(20), Porcentaje_Aceptacion), '') + CHAR(9) + 
				 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 COALESCE(Des_Indicador_Inscripcion, '') + CHAR(9) + 
				 /*COALESCE(Fecha_Constitucion, '') + CHAR(9) + */
				 COALESCE(CONVERT(VARCHAR(50), Dias_Acumulados), ''))	AS [Alerta!3!DATOS!element],
				Usuario							AS [Alerta!3!Usuario!hide]
		FROM	@TMP_ALERTAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Alertas_Indicador_Inscripcion_Garantias_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END