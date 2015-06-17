SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Inconsistencias_Tipo_Garantia_Real', 'P') IS NOT NULL
	DROP PROCEDURE pa_Inconsistencias_Tipo_Garantia_Real;
GO

CREATE PROCEDURE [dbo].[pa_Inconsistencias_Tipo_Garantia_Real]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Inconsistencias_Tipo_Garantia_Real</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las inconsistencias referentes a diferentes campos de las garantías reales.
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
	<Requerimiento>Req_Inconsistencias Garantías Reales, Siebel No. 1-21378011</Requerimiento>
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
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
******************************************************************/

	SET NOCOUNT ON
	SET DATEFORMAT dmy


	/*Se declaran estas estructuras debido con el fin de disminuir el tiempo de respuesta del procedimiento
	    almacenado */

	DECLARE @TMP_VALUACIONES TABLE (
										cod_contabilidad						tinyint,
										cod_oficina								smallint,
										cod_moneda								tinyint,
										cod_producto							tinyint,
										operacion								decimal (7,0),
										cod_garantia_real						bigint	,
										monto_ultima_tasacion_terreno			money	,
										monto_ultima_tasacion_no_terreno		money	,
										monto_tasacion_actualizada_terreno		money	,
										monto_tasacion_actualizada_no_terreno	money	,
										cod_tipo_operacion						tinyint	,
										cod_tipo_bien							smallint,
										cod_bien								varchar (25)	collate database_default,
										cod_tipo_mitigador						smallint,
										cod_tipo_documento_legal				smallint,
										cod_tipo_garantia_real					tinyint,
										cod_clase_garantia						smallint,
										fecha_construccion						datetime,
										fecha_presentacion						datetime,
										fecha_constitucion						datetime,
										cod_usuario								varchar (30)	collate database_default
									)


	DECLARE @TMP_INCONSISTENCIAS TABLE (
											Contabilidad				tinyint			,
											Oficina						smallint		,
											Moneda						tinyint			,
											Producto					tinyint			,
											Operacion					decimal(7)		,
											Tipo_Garantia_Real			tinyint			,
											Clase_Garantia				smallint		,
											Tipo_Bien					smallint		,
											Tipo_Mitigador				smallint		,
											Tipo_Documento_Legal		smallint		,
											Usuario						varchar(30)		collate database_default, 
											Tipo_Inconsistencia			varchar(100)	collate database_default,
											Garantia_Real				varchar(30)		collate database_default 
										)


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
														cod_grado					varchar (2)		collate database_default,
														cedula_hipotecaria			varchar (2)		collate database_default,
														cod_operacion				bigint,
														cod_garantia_real			bigint,
														cod_tipo_garantia_real		tinyint,
														numero_finca				varchar (25)	collate database_default,
														num_placa_bien				varchar (25)	collate database_default,
														cod_clase_bien				varchar (3)		collate database_default,
														cod_estado					smallint,
														cod_partido					smallint,
														cod_tipo_garantia			smallint,
														cod_tipo_operacion			tinyint,
														ind_duplicidad				tinyint			DEFAULT (1)	,
														cod_usuario					varchar (30)	collate database_default,
														cod_clase_garantia          smallint,
														cod_grado_gravamen          smallint,
														cod_llave					bigint			IDENTITY(1,1)
														PRIMARY KEY (cod_llave)
													)


	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	DECLARE @TMP_GARANTIAS_REALES_X_OPERACION TABLE (	cod_contabilidad			tinyint,
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
														cod_grado					varchar (2)		collate database_default,
														cedula_hipotecaria			varchar (2)		collate database_default,
														cod_operacion				bigint,
														cod_garantia_real			bigint,
														cod_tipo_garantia_real		tinyint,
														numero_finca				varchar (25)	collate database_default,
														num_placa_bien				varchar (25)	collate database_default,
														cod_clase_bien				varchar (3)		collate database_default,
														cod_estado					smallint,
														cod_partido					smallint,
														cod_tipo_garantia			smallint,
														cod_tipo_operacion			tinyint,
														ind_duplicidad				tinyint			DEFAULT (1)	,
														cod_usuario					varchar (30)	collate database_default,
														cod_clase_garantia          smallint,
														cod_grado_gravamen          smallint,
														cod_llave					bigint			IDENTITY(1,1)
														PRIMARY KEY (cod_llave)
													)
	


	
	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario

/************************************************************************************************
 *                                                                                              * 
 *                       INICIO DEL FILTRADO DE LAS GARANTIAS REALES                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se selecciona la información de la garantía real asociada a las operaciones*/
	INSERT INTO @TMP_GARANTIAS_REALES_OPERACIONES (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
									  cod_tipo_bien, cod_bien, cod_tipo_mitigador, cod_tipo_documento_legal, 
                                      monto_mitigador, fecha_presentacion, cod_inscripcion, 
									  porcentaje_responsabilidad, fecha_constitucion, cod_grado, 
									  cedula_hipotecaria, cod_operacion, cod_garantia_real, 
									  cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, 
									  cod_estado, cod_partido, cod_tipo_garantia, cod_tipo_operacion, 
                                      ind_duplicidad, cod_usuario, cod_clase_garantia, cod_grado_gravamen)


	SELECT DISTINCT 
		1 AS cod_contabilidad, 
		ROV.cod_oficina, 
		ROV.cod_moneda, 
		ROV.cod_producto, 
		ROV.num_operacion AS operacion, 
		ISNULL(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
		END AS cod_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGR.cod_grado,'') AS cod_grado,
		ISNULL(GGR.cedula_hipotecaria,'') AS cedula_hipotecaria,
		ROV.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		ISNULL(GGR.numero_finca,'') AS numero_finca,
		ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
		ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
		1 AS cod_estado,
		GGR.cod_partido,
		GGR.cod_tipo_garantia,
		1 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario,
		GGR.cod_clase_garantia,
		ISNULL(GRO.cod_grado_gravamen, -1) AS cod_grado_gravamen

	FROM 
		dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		 ON GRO.cod_garantia_real	= GGR.cod_garantia_real 

	WHERE ROV.cod_tipo_operacion	= 1
		AND GRO.cod_estado			= 1

	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GGR.cod_clase_bien,
		GGR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se selecciona la información de la garantía real asociada a los contratos*/
	INSERT INTO @TMP_GARANTIAS_REALES_OPERACIONES (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
									  cod_tipo_bien, cod_bien, cod_tipo_mitigador, cod_tipo_documento_legal, 
                                      monto_mitigador, fecha_presentacion, cod_inscripcion, 
									  porcentaje_responsabilidad, fecha_constitucion, cod_grado, 
									  cedula_hipotecaria, cod_operacion, cod_garantia_real, 
									  cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, 
									  cod_estado, cod_partido, cod_tipo_garantia, cod_tipo_operacion, 
                                      ind_duplicidad, cod_usuario, cod_clase_garantia, cod_grado_gravamen)


	SELECT DISTINCT 
		1 AS cod_contabilidad, 
		ROV.cod_oficina_contrato, 
		ROV.cod_moneda_contrato, 
		ROV.cod_producto_contrato, 
		ROV.num_contrato AS operacion, 
		ISNULL(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
		END AS cod_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGR.cod_grado,'') AS cod_grado,
		ISNULL(GGR.cedula_hipotecaria,'') AS cedula_hipotecaria,
		ROV.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		ISNULL(GGR.numero_finca,'') AS numero_finca,
		ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
		ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
		1 AS cod_estado,
		GGR.cod_partido,
		GGR.cod_tipo_garantia,
		2 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario,
		GGR.cod_clase_garantia,
		ISNULL(GRO.cod_grado_gravamen, -1) AS cod_grado_gravamen

	FROM 
		 dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		 ON GRO.cod_garantia_real	= GGR.cod_garantia_real 

	WHERE ROV.cod_tipo_operacion = 2
		AND EXISTS (SELECT 1
					FROM dbo.GAR_SICC_PRMGT GSP
					WHERE GSP.prmgt_pco_conta = 1
					 AND GSP.prmgt_pco_ofici  = ROV.cod_oficina_contrato
					 AND GSP.prmgt_pco_moned  = ROV.cod_moneda_contrato
					 AND GSP.prmgt_pnu_oper   = ROV.num_contrato
					 AND GSP.prmgt_pcoclagar  = GGR.cod_clase_garantia
					 AND GSP.prmgt_pco_grado  = ISNULL(GGR.cod_grado, GSP.prmgt_pco_grado)
					 --RQ: 1-23923921. Se cambia el tipo de dato de la compración, pasando de numérica a texto.
					 AND CONVERT(VARCHAR(25), GSP.prmgt_pnuidegar)  = CASE WHEN GGR.cod_tipo_garantia_real = 1 THEN GGR.numero_finca
																		 WHEN GGR.cod_tipo_garantia_real = 2 THEN GGR.numero_finca
																		 ELSE GGR.num_placa_bien
																	END
					 AND GSP.prmgt_pco_produ  = 10
					 AND GSP.prmgt_estado     = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/

	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GGR.cod_clase_bien,
		GGR.num_placa_bien,
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
					AND ISNULL(TGR.cod_bien, '')		= ISNULL(TOD.cod_garantia_sicc, '')
					AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
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
	AND ISNULL(GR1.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND ISNULL(GR2.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
								AND ISNULL(GR2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
								AND GR2.cod_tipo_garantia_real		= 1
								AND GR2.cod_tipo_operacion			IN (1, 2)
								AND TOD.cod_tipo_garantia			= 2)
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
					AND ISNULL(TGR.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
					AND TGR.cod_tipo_garantia_real		= 1
					AND TGR.cod_tipo_operacion			IN (1, 2)
					AND TOD.cod_tipo_garantia			= 2)
	AND TGR.cod_tipo_garantia_real		= 1
	AND TGR.cod_usuario					= @psCedula_Usuario
	AND TGR.cod_tipo_operacion			IN (1, 2)


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
	AND ISNULL(GR1.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
	AND GR1.cod_grado					= TOD.cod_grado
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND ISNULL(GR2.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
								AND GR2.cod_grado					= TOD.cod_grado
								AND ISNULL(GR2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
								AND GR2.cod_tipo_garantia_real		= 2
								AND GR2.cod_tipo_operacion			IN (1, 2)
								AND TOD.cod_tipo_garantia			= 2)
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
					AND ISNULL(TGR.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
					AND TGR.cod_grado					= TOD.cod_grado
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
					AND TGR.cod_tipo_garantia_real		= 2
					AND TGR.cod_tipo_operacion			IN (1, 2)
					AND TOD.cod_tipo_garantia			= 2)
	AND TGR.cod_tipo_garantia_real	= 2
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_operacion IN (1, 2)

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
	AND ISNULL(GR1.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
	WHERE GR1.cod_llave = (SELECT MIN(GR2.cod_llave)
								FROM @TMP_GARANTIAS_REALES_OPERACIONES GR2
								WHERE GR2.cod_oficina				= TOD.cod_oficina
								AND GR2.cod_moneda					= TOD.cod_moneda
								AND GR2.cod_producto				= TOD.cod_producto
								AND GR2.operacion					= TOD.operacion
								AND ISNULL(GR2.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
								AND ISNULL(GR2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
								AND GR2.cod_tipo_garantia_real		= 3
								AND GR2.cod_tipo_operacion			IN (1, 2)
								AND TOD.cod_tipo_garantia			= 2)
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
					AND ISNULL(TGR.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
					AND TGR.cod_tipo_garantia_real		= 3
					AND TGR.cod_tipo_operacion			IN (1, 2)
					AND TOD.cod_tipo_garantia			= 2)
	AND TGR.cod_tipo_garantia_real	= 3
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario

/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE GARANTÍAS                                  *
 *                   (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                          *
 *                                                                                              *
 ************************************************************************************************/

	INSERT INTO @TMP_GARANTIAS_REALES_X_OPERACION (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
												   cod_tipo_bien, cod_bien, cod_tipo_mitigador, cod_tipo_documento_legal, 
												   monto_mitigador, fecha_presentacion, cod_inscripcion, 
												   porcentaje_responsabilidad, fecha_constitucion, cod_grado, 
												   cedula_hipotecaria, cod_operacion, cod_garantia_real, 
												   cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, 
												   cod_estado, cod_partido, cod_tipo_garantia, cod_tipo_operacion, 
												   ind_duplicidad, cod_usuario,	cod_clase_garantia, cod_grado_gravamen)



	SELECT DISTINCT
		TGR.cod_contabilidad, 
		TGR.cod_oficina, 
		TGR.cod_moneda, 
		TGR.cod_producto, 
		TGR.operacion, 
		ISNULL(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
		END AS cod_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGR.cod_grado,'') AS cod_grado,
		ISNULL(GGR.cedula_hipotecaria,'') AS cedula_hipotecaria,
		TGR.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		ISNULL(GGR.numero_finca,'') AS numero_finca,
		ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
		ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
		TGR.cod_estado,
		GGR.cod_partido,
		GGR.cod_tipo_garantia,
		TGR.cod_tipo_operacion,
		TGR.ind_duplicidad,
		TGR.cod_usuario,
		TGR.cod_clase_garantia,
		TGR.cod_grado_gravamen
		
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
	ON GRO.cod_operacion		= TGR.cod_operacion
	AND GRO.cod_garantia_real	= TGR.cod_garantia_real
	INNER JOIN GAR_GARANTIA_REAL GGR
	ON GGR.cod_garantia_real	= TGR.cod_garantia_real

/************************************************************************************************
 *                                                                                              * 
 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
 *                                                                                              *
 ************************************************************************************************/





/************************************************************************************************
 *                                                                                              * 
 *                        FIN DEL FILTRADO DE LAS GARANTIAS REALES                              *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/* Se obtienen todos los valúos que posee cada una de las garantías*/
	INSERT INTO @TMP_VALUACIONES (
									cod_contabilidad, 
									cod_oficina,
									cod_moneda,
									cod_producto,
									operacion,
									cod_garantia_real,	
									monto_ultima_tasacion_terreno,
									monto_ultima_tasacion_no_terreno,
									monto_tasacion_actualizada_terreno,
									monto_tasacion_actualizada_no_terreno,
									cod_tipo_operacion,
									cod_tipo_bien,
									cod_bien,
									cod_tipo_mitigador, 
									cod_tipo_documento_legal,
									cod_tipo_garantia_real,
									cod_clase_garantia,
									fecha_construccion,
									fecha_presentacion,
									fecha_constitucion,
									cod_usuario
								 )

	SELECT DISTINCT 
					TGR.cod_contabilidad,
					TGR.cod_oficina,
					TGR.cod_moneda,
					TGR.cod_producto,
					TGR.operacion,
					VRV.cod_garantia_real,
					VRV.monto_ultima_tasacion_terreno,
					VRV.monto_ultima_tasacion_no_terreno,
					VRV.monto_tasacion_actualizada_terreno,
					VRV.monto_tasacion_actualizada_no_terreno,
					TGR.cod_tipo_operacion,
					TGR.cod_tipo_bien,
					TGR.cod_bien,
					TGR.cod_tipo_mitigador, 
					TGR.cod_tipo_documento_legal,
					TGR.cod_tipo_garantia_real,
					TGR.cod_clase_garantia,
					VRV.fecha_construccion,
					CONVERT(DATETIME, TGR.fecha_presentacion),
					CONVERT(DATETIME, TGR.fecha_constitucion),
					TGR.cod_usuario

	FROM dbo.VALUACIONES_GARANTIAS_REALES_VW VRV
	INNER JOIN @TMP_GARANTIAS_REALES_X_OPERACION TGR
	ON TGR.cod_garantia_real = VRV.cod_garantia_real
			

/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se actualiza a -1 todas los mitigadores de riesgo, documentos legales y tipos de bien que sean nulas*/
	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET cod_tipo_bien		= -1
	WHERE cod_tipo_bien		IS NULL

	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET cod_tipo_mitigador		= -1
	WHERE cod_tipo_mitigador	IS NULL

	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET cod_tipo_documento_legal	= -1
	WHERE cod_tipo_documento_legal	IS NULL

	UPDATE @TMP_VALUACIONES
	SET cod_tipo_bien		= -1
	WHERE cod_tipo_bien		IS NULL

	UPDATE @TMP_VALUACIONES
	SET cod_tipo_mitigador		= -1
	WHERE cod_tipo_mitigador	IS NULL

	UPDATE @TMP_VALUACIONES
	SET cod_tipo_documento_legal	= -1
	WHERE cod_tipo_documento_legal	IS NULL

	UPDATE @TMP_VALUACIONES
	SET fecha_construccion		= NULL
	WHERE fecha_construccion	= '19000101'

	UPDATE @TMP_VALUACIONES
	SET fecha_presentacion		= NULL
	WHERE fecha_presentacion	= '19000101'

	UPDATE @TMP_VALUACIONES
	SET fecha_constitucion		= NULL
	WHERE fecha_constitucion	= '19000101'


/*INCONSISTENCIAS DEL CAMPO: CLASE DE GARANTIA*/
	
	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que no poseen asignada la clase garantía. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )
	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_garantia_real,
			cod_clase_garantia,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			@psCedula_Usuario,
			'Clase de garantía',
			cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		IS NULL

	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía inválida. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )
	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_garantia_real,
			cod_clase_garantia,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			@psCedula_Usuario,
			'Clase de garantía',
			cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		NOT BETWEEN 10 AND 17

/*INCONSISTENCIAS DEL CAMPO: TIPO DE BIEN*/
	
	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, pero el tipo de bien inválido. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo de bien',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		BETWEEN 10 AND 17
		AND cod_tipo_bien			NOT IN (1, 2)

/*INCONSISTENCIAS DEL CAMPO: TIPO DE MITIGADOR DE RIESGO*/

	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, el tipo de bien inválido y el tipo de mitigador 
    --inválido. Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Mitigador',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		BETWEEN 10 AND 17
		AND cod_tipo_bien			= -1
		AND cod_tipo_mitigador		= -1

	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, el tipo de bien válido y el tipo de mitigador 
    --inválido, según el tipo de bien. Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Mitigador',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		BETWEEN 10 AND 17
		AND cod_tipo_bien			= 1
		AND cod_tipo_mitigador		<> 1

	UNION ALL

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Mitigador',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_clase_garantia		BETWEEN 10 AND 17
		AND cod_tipo_bien			= 2
		AND cod_tipo_mitigador		NOT IN (2, 3)


/*INCONSISTENCIAS DEL CAMPO: TIPO DE DOCUMENTO LEGAL*/

	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, el tipo de bien inválido, el tipo de mitigador 
    --inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Documento Legal',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_clase_garantia			BETWEEN 10 AND 17
		AND cod_tipo_bien				= -1
		AND cod_tipo_mitigador			= -1
		AND cod_tipo_documento_legal	= -1


	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
    --inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Documento Legal',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_garantia_real		= 1
		AND cod_clase_garantia			BETWEEN 10 AND 17
		AND cod_tipo_bien				IN (1, 2)
		AND cod_tipo_mitigador			= -1
		AND cod_tipo_documento_legal	= -1

	
	--Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	--que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
    --válido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Tipo Documento Legal',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_clase_garantia			BETWEEN 10 AND 17
		AND cod_tipo_bien				IN (1, 2)
		AND cod_tipo_mitigador			BETWEEN 1 AND 3
		AND cod_tipo_documento_legal	NOT BETWEEN 1 AND 4

	

/*INCONSISTENCIAS DEL CAMPO: GRADO DEL GRAVAMEN*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen el tipo de documento legal inválido y el grado de gravamen inválido, según el tipo 
    --de documento legal (válido) que posea asociado la garantía. 
    --Los valores inválidos incluyen los nulos.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Grado Gravamen',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_documento_legal	NOT BETWEEN 1 AND 4

	UNION ALL

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Grado Gravamen',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_documento_legal	= 1
		AND cod_grado_gravamen			<> 1

	UNION ALL

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Grado Gravamen',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_documento_legal	= 2
		AND cod_grado_gravamen			<> 2

	UNION ALL

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Grado Gravamen',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_documento_legal	= 3
		AND cod_grado_gravamen			<> 3


	UNION ALL

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Grado Gravamen',
		cod_bien
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_garantia_real		= 1
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_tipo_documento_legal	= 4
		AND cod_grado_gravamen			<> 4


/*INCONSISTENCIAS DEL CAMPO: VALUACIONES TERRENO*/

	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo, correspondientes a los montos del terreno mayores a cero y
    --cuyo tipo de bien sea diferente a 1.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_tipo_bien			<> 1
		AND (ISNULL(monto_ultima_tasacion_no_terreno, 0 )		= 0)
		AND (ISNULL(monto_tasacion_actualizada_no_terreno , 0)	= 0)
		AND ((ISNULL(monto_ultima_tasacion_terreno, 0)			> 0)
			 OR (ISNULL(monto_tasacion_actualizada_terreno, 0)	> 0))
	
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo, correspondientes a los montos del no terreno mayores a cero y
    --cuyo tipo de bien sea igual a 1.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_tipo_bien			= 1
		AND ((ISNULL(monto_ultima_tasacion_no_terreno, 0)			> 0)
			 OR (ISNULL(monto_tasacion_actualizada_no_terreno, 0)	> 0))


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo, correspondiente a la fecha de construcción y
    --cuyo tipo de bien sea igual a 1.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_bien			= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_construccion		IS NOT NULL




/*INCONSISTENCIAS DEL CAMPO: VALUACIONES NO TERRENO*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo inválidos,según el tipo de bien que posea la garantía.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones No Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_tipo_bien			<> 2
		AND ISNULL(monto_ultima_tasacion_terreno, 0)			> 0
		AND ISNULL(monto_ultima_tasacion_no_terreno, 0)			> 0
		AND ISNULL(monto_tasacion_actualizada_terreno, 0)		> 0
		AND ISNULL(monto_tasacion_actualizada_no_terreno , 0)	> 0


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo inválidos, correspondientes al monto del terreno igual a cero y 
	--cuyo tipo de bien es igual a 2.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones No Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_bien			= 2
		AND cod_tipo_operacion		IN (1, 2)
		AND ((ISNULL(monto_ultima_tasacion_terreno, 0)			= 0)
			 OR (ISNULL(monto_tasacion_actualizada_terreno, 0)	= 0))



	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo inválidos, correspondiente a la fecha de construcción y 
	--cuyo tipo de bien es igual a 2. Se considera inconsistencia si la fecha es nula.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones No Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_bien			= 2
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_construccion		IS NULL


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo inválidos, correspondiente a la fecha de construcción y 
	--cuyo tipo de bien es igual a 2. Se considera inconsistencia si la fecha es mayor a la fecha 
	--de constitución.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones No Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_bien			= 2
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_construccion		IS NOT NULL
		AND fecha_constitucion		IS NOT NULL
		AND fecha_construccion		> fecha_constitucion


	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que poseen los datos del avalúo inválidos, correspondiente a la fecha de construcción y 
	--cuyo tipo de bien es igual a 2. Se considera inconsistencia si la fecha es mayor a la fecha 
	--de presentación.
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
									  Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien,
									  Tipo_Mitigador, Tipo_Documento_Legal, Usuario,
									  Tipo_Inconsistencia, Garantia_Real
									  )

	SELECT	1,
		cod_oficina,
		cod_moneda,
		cod_producto,
		operacion,
		cod_tipo_garantia_real,
		cod_clase_garantia,
		cod_tipo_bien,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		@psCedula_Usuario,
		'Valuaciones No Terreno',
		cod_bien
			
	FROM @TMP_VALUACIONES 
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_garantia_real	= 1
		AND cod_tipo_bien			= 2
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_construccion		IS NOT NULL
		AND fecha_presentacion		IS NOT NULL
		AND fecha_construccion		> fecha_presentacion


/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se actualiza a NULL todas los mitigadores de riesgo, documentos legales y tipos de bien que sea igual a -1*/
	UPDATE @TMP_INCONSISTENCIAS
	SET Tipo_Bien		= NULL
	WHERE Tipo_Bien		= -1

	UPDATE @TMP_INCONSISTENCIAS
	SET Tipo_Mitigador		= NULL
	WHERE Tipo_Mitigador	= -1

	UPDATE @TMP_INCONSISTENCIAS
	SET Tipo_Documento_Legal	= NULL
	WHERE Tipo_Documento_Legal	= -1



		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'pa_Inconsistencias_Tipo_Garantia_Real'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Inconsistencia!3!DATOS!element], 
				NULL						AS [Inconsistencia!3!Usuario!hide]
		FROM	@TMP_INCONSISTENCIAS 
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
		FROM	@TMP_INCONSISTENCIAS 
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
				 ISNULL(CONVERT(VARCHAR(5), Tipo_Garantia_Real), '') + CHAR(9) +
			     ISNULL(Garantia_Real, '') + CHAR(9) +
                 ISNULL(CONVERT(VARCHAR(5), Clase_Garantia), '') + CHAR(9) +
				 ISNULL(CONVERT(VARCHAR(5), Tipo_Bien), '') + CHAR(9) + 
                 ISNULL(CONVERT(VARCHAR(5), Tipo_Mitigador), '') + CHAR(9) +
				 ISNULL(CONVERT(VARCHAR(5), Tipo_Documento_Legal), '') + CHAR(9) + 
				 Tipo_Inconsistencia + CHAR(9))	AS [Inconsistencia!3!DATOS!element],
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	@TMP_INCONSISTENCIAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Tipo_Garantia_Real</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END