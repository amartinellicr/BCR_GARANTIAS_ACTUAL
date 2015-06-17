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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene las inconsistencias referentes a los campos del partido y la finca.
	</Descripci�n>
	<Entradas>
			@psCedula_Usuario	= Identificaci�n del usuario que realiza la consulta. 
                                  Este es dato llave usado para la b�squeda de los registros que deben 
                                  ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>06/06/2012</Fecha>
	<Requerimiento>Req_Garant�as Reales Partido y Finca, Siebel No. 1-21317198</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios de almacenado, b�squeda y extracci�n de datos, Sibel: 1 - 23923921</Requerimiento>
			<Fecha>01/10/2013</Fecha>
			<Descripci�n>
				Se ajusta la forma en que se compara la identificaci�n de la garant�a entre el SICC y el
				sistema de garant�as, se cambia de una comparaci�n numperica a una de texto.
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
******************************************************************/

	SET NOCOUNT ON
	SET DATEFORMAT dmy

	/*Se declaran estas estrucutras debido con el fin de disminuir el tiempo de respuesta del procedimiento
	    almacenado */

	DECLARE @TMP_INCONSISTENCIAS TABLE (
											Contabilidad				tinyint			,
											Oficina						smallint		,
											Moneda						tinyint			,
											Producto					tinyint			,
											Operacion					decimal(7)		,
											Tipo_Garantia_Real			tinyint			,
											Clase_Garantia				smallint		,
											Usuario						varchar(30)		collate database_default, 
											Tipo_Inconsistencia			varchar(100)	collate database_default ,
											Garantia_Real				varchar(30)		collate database_default ,
											Deudor						varchar(30)		collate database_default ,
											Nombre_Deudor				varchar(50)		collate database_default 
										)


	/*Se declara la variable temporal tipo tabla que ser� utilizada como tabla maestra*/
	DECLARE @TMP_GARANTIAS_REALES_OPERACIONES TABLE (	cod_llave					bigint			IDENTITY(1,1),
														cod_contabilidad			tinyint,
														cod_oficina					smallint,
														cod_moneda					tinyint,
														cod_producto				tinyint,
														operacion					decimal (7,0),
														cod_tipo_bien				smallint,
														cod_tipo_mitigador			smallint,
														cod_tipo_documento_legal	smallint,
														cod_inscripcion				smallint,
														cod_operacion				bigint,
														cod_garantia_real			bigint,
														cod_tipo_garantia_real		tinyint,
														cod_tipo_operacion			tinyint,
														ind_duplicidad				tinyint			DEFAULT (1)	,
														porcentaje_responsabilidad	decimal (5,2),
														monto_mitigador				decimal (18,2),
														cod_bien					varchar (25)	collate database_default,
														fecha_presentacion			varchar (10)	collate database_default,
														fecha_constitucion			varchar (10)	collate database_default,
														cod_grado					varchar (2)		collate database_default,
														numero_finca				varchar (25)	collate database_default,
														cod_partido					smallint,
														cod_clase_garantia			smallint,
														num_placa_bien				varchar (25)	collate database_default,
														cod_clase_bien				varchar (3)		collate database_default,
														cod_usuario					varchar (30)	collate database_default
														PRIMARY KEY (cod_llave)
													)



	/*Se declara la variable temporal tipo tabla que ser� utilizada como tabla final en la que se guardar� los datos de las garant�as
	  que se obtienen de igual forma en como se obtienen desde la aplicaci�n 
	*/
	DECLARE @TMP_GARANTIAS_REALES_X_OPERACION TABLE (	cod_llave					bigint			IDENTITY(1,1),
														cod_contabilidad			tinyint,
														cod_oficina					smallint,
														cod_moneda					tinyint,
														cod_producto				tinyint,
														operacion					decimal (7,0),
														cod_tipo_bien				smallint,
														cod_tipo_mitigador			smallint,
														cod_tipo_documento_legal	smallint,
														cod_operacion				bigint,
														cod_garantia_real			bigint,
														cod_tipo_garantia_real		tinyint,
														cod_tipo_operacion			tinyint,
														ind_duplicidad				tinyint			DEFAULT (1)	,
														porcentaje_responsabilidad	decimal (5,2),
														monto_mitigador				decimal (18,2),
														cod_bien					varchar (25)	collate database_default,
														cod_clase_garantia			smallint,
														cod_partido					smallint,
														numero_finca				varchar (25)	collate database_default,
														fecha_constitucion			varchar (10)	collate database_default,
														cod_usuario					varchar (30)	collate database_default,
														cod_inscripcion				smallint,
														fecha_presentacion			varchar (10)	collate database_default
														PRIMARY KEY (cod_llave)
													)
	

	/*Se elimina la informaci�n de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2


/************************************************************************************************
 *                                                                                              * 
 *                       INICIO DEL FILTRADO DE LAS GARANTIAS REALES                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se selecciona la informaci�n de la garant�a real asociada a las operaciones*/
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
		ISNULL(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ROV.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		1 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
		END AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGR.cod_grado,'') AS cod_grado,
		ISNULL(GGR.numero_finca,'') AS numero_finca,
		ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
		ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
		@psCedula_Usuario AS cod_usuario

	FROM 
		dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		 AND ROV.cod_garantia		= GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		 ON GGR.cod_garantia_real	= ROV.cod_garantia

	WHERE GRO.cod_estado			= 1
		AND ROV.cod_tipo_operacion	= 1

	ORDER BY
		ROV.cod_operacion,
		GGR.numero_finca,
		GGR.cod_grado,
		GGR.cod_clase_bien,
		GGR.num_placa_bien,
		GRO.cod_tipo_documento_legal DESC


	/*Se selecciona la informaci�n de la garant�a real asociada a los contratos*/
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
		ISNULL(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		ROV.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		2 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
		END AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGR.cod_grado,'') AS cod_grado,
		ISNULL(GGR.numero_finca,'') AS numero_finca,
		ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
		ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
		@psCedula_Usuario AS cod_usuario
		
	FROM dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		 INNER JOIN dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		 ON ROV.cod_operacion		= GRO.cod_operacion 
		 AND ROV.cod_garantia		= GRO.cod_garantia_real
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		 ON GGR.cod_garantia_real	= ROV.cod_garantia

	WHERE ROV.cod_tipo_operacion = 2
		AND EXISTS (SELECT 1
					FROM dbo.GAR_SICC_PRMGT GSP
					WHERE GSP.prmgt_pcoclagar	= GGR.cod_clase_garantia
					 AND GSP.prmgt_pco_grado	= ISNULL(GGR.cod_grado, GSP.prmgt_pco_grado)
					 AND GSP.prmgt_estado		= 'A'
					 AND GSP.prmgt_pnu_oper		= ROV.num_contrato
					 AND GSP.prmgt_pco_ofici	= ROV.cod_oficina_contrato
					 AND GSP.prmgt_pco_moned	= ROV.cod_moneda_contrato
					 AND GSP.prmgt_pco_produ	= 10
					 AND GSP.prmgt_pco_conta	= 1
					 --RQ: 1-23923921. Se cambia el tipo de dato de la compraci�n, pasando de num�rica a texto.
					 AND CONVERT(VARCHAR(25), GSP.prmgt_pnuidegar)	= CASE WHEN GGR.cod_tipo_garantia_real = 1 THEN GGR.numero_finca
																		   WHEN GGR.cod_tipo_garantia_real = 2 THEN GGR.numero_finca
																		   ELSE GGR.num_placa_bien
																	  END) /*Aqu� se ha determinado si la garant�a existente en BCRGarant�as est� activa en la estructura del SICC*/

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


	/*Se cambia el c�digo del campo ind_duplicidad a 2, indicando con esto que la operaci�n se encuentra duplicada.
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


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la informaci�n*/
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_REALES_OPERACIONES WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se obtienen las garant�as reales de hipoteca com�n duplicadas*/
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

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que har�a el 
		cursor, tomar�a el primer registro que encuentre y los dem�s los descarta.*/
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
								AND GR2.cod_tipo_garantia_real		= 1
								AND ISNULL(GR2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND GR2.cod_tipo_operacion			IN (1, 2))
	AND GR1.cod_tipo_garantia_real	= 1
	AND GR1.cod_usuario				= @psCedula_Usuario
	AND GR1.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados que sean diferentes al c�digo de garant�a actualizado anteriormente*/
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
	AND TGR.cod_tipo_garantia_real	= 1
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se obtienen las garant�as reales de c�dulas hipotecarias duplicadas*/
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

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que har�a el 
		cursor, tomar�a el primer registro que encuentre y los dem�s los descarta.*/
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
								AND GR2.cod_tipo_garantia_real		= 2
								AND ISNULL(GR2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND GR2.cod_tipo_operacion			IN (1, 2))
	AND GR1.cod_tipo_garantia_real	= 2
	AND GR1.cod_usuario				= @psCedula_Usuario
	AND GR1.cod_tipo_operacion		IN (1, 2)


	/*Se eliminan los duplicados que sean diferentes al c�digo de garant�a actualizado anteriormente*/
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
					AND TGR.cod_tipo_garantia_real		= 2
					AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
					AND TOD.cod_tipo_garantia			= 2
					AND TGR.cod_tipo_operacion			IN (1, 2))
	AND TGR.cod_tipo_garantia_real	= 2
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)

	/*Se eliminan los duplicados obtenidos*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 2 AND cod_tipo_operacion = 2

	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la informaci�n*/
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
 *                         INICIO DE LA SELECCI�N DE GARANT�AS                                  *
 *                   (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                          *
 *                                                                                              *
 ************************************************************************************************/

	INSERT INTO @TMP_GARANTIAS_REALES_X_OPERACION 
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, 
	 cod_tipo_mitigador, cod_tipo_documento_legal, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_tipo_operacion, ind_duplicidad, porcentaje_responsabilidad, 
	 monto_mitigador, cod_bien, cod_clase_garantia, cod_partido, numero_finca, fecha_constitucion, cod_usuario, 
	 cod_inscripcion, fecha_presentacion)


	SELECT DISTINCT
		TGR.cod_contabilidad, 
		TGR.cod_oficina, 
		TGR.cod_moneda, 
		TGR.cod_producto, 
		TGR.operacion, 
		ISNULL(GR.cod_tipo_bien, -1) AS cod_tipo_bien, 
		ISNULL(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		TGR.cod_operacion,
		GR.cod_garantia_real,
		GR.cod_tipo_garantia_real,
		TGR.cod_tipo_operacion,
		TGR.ind_duplicidad,
		ISNULL(GRO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		ISNULL(GRO.monto_mitigador, 0) AS monto_mitigador,
		CASE GR.cod_tipo_garantia_real  
			WHEN 1 THEN ISNULL((CONVERT(varchar(2),GR.cod_partido)), '') + '-' + ISNULL(GR.numero_finca, '')  
			WHEN 2 THEN ISNULL((CONVERT(varchar(2),GR.cod_partido)), '') + '-' + ISNULL(GR.numero_finca, '') 
			WHEN 3 THEN ISNULL(GR.cod_clase_bien, '') + '-' + ISNULL(GR.num_placa_bien, '')
		END AS cod_bien, 
		GR.cod_clase_garantia,
		GR.cod_partido, 
		GR.numero_finca,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		TGR.cod_usuario,
		ISNULL(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion
		
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
	ON GRO.cod_operacion		= TGR.cod_operacion
	AND GRO.cod_garantia_real	= TGR.cod_garantia_real
	INNER JOIN GAR_GARANTIA_REAL GR
	ON GR.cod_garantia_real		= TGR.cod_garantia_real

/************************************************************************************************
 *                                                                                              * 
 *                        FIN DE LA SELECCI�N DE GARANT�AS                                      *
 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCI�N DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se actualiza el c�digo de partido a NULL, cuando el c�digo es igual a -1*/
	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET cod_partido		= NULL
	WHERE cod_partido	= -1


	/*INCONSISTENCIAS DEL CAMPO: PARTIDO*/
	
	/*HIPOTECA COMUN*/
	--Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	--que no poseen asignado el c�digo de partido. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
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
			OPE.cedula_deudor,
			DEU.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TOR
	INNER JOIN dbo.GAR_OPERACION OPE
	ON OPE.cod_operacion = TOR.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR DEU
	ON OPE.cedula_deudor = DEU.cedula_deudor
	WHERE TOR.cod_usuario				= @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real	= 1
		AND TOR.cod_tipo_operacion		IN (1, 2)
		AND TOR.cod_partido				IS NULL


	--Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	--que poseen asignado el c�digo de partido, pero este se encuentra fuera del rango entre
	--1 y 7 (incluy�ndolos). 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
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
			OPE.cedula_deudor,
			DEU.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TOR
	INNER JOIN dbo.GAR_OPERACION OPE
	ON OPE.cod_operacion = TOR.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR DEU
	ON OPE.cedula_deudor = DEU.cedula_deudor
	WHERE TOR.cod_usuario				= @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real	= 1
		AND TOR.cod_tipo_operacion		IN (1, 2)
		AND TOR.cod_partido				NOT BETWEEN 1 AND 7


	/*CEDULA HIPOTECARIA*/
	--Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	--que no poseen asignado el c�digo de partido. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
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
			OPE.cedula_deudor,
			DEU.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TOR
	INNER JOIN dbo.GAR_OPERACION OPE
	ON OPE.cod_operacion = TOR.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR DEU
	ON OPE.cedula_deudor = DEU.cedula_deudor
	WHERE TOR.cod_usuario				= @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real	= 2
		AND TOR.cod_tipo_operacion		IN (1, 2)
		AND TOR.cod_partido				IS NULL


	--Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	--que poseen asignado el c�digo de partido, pero este se encuentra fuera del rango entre
	--1 y 7 (incluy�ndolos). 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
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
			OPE.cedula_deudor,
			DEU.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION TOR
	INNER JOIN dbo.GAR_OPERACION OPE
	ON OPE.cod_operacion = TOR.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR DEU
	ON OPE.cedula_deudor = DEU.cedula_deudor
	WHERE TOR.cod_usuario				= @psCedula_Usuario
		AND TOR.cod_tipo_garantia_real	= 2
		AND TOR.cod_tipo_operacion		IN (1, 2)
		AND TOR.cod_partido				NOT BETWEEN 1 AND 7




	/*INCONSISTENCIAS DEL CAMPO: FINCA*/
	
	/*HIPOTECA COMUN*/

	--Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	--que poseen asignado un n�mero de finca cuyo tama�o, en caracteres, supera las 6 posiciones. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )

		SELECT	1,
			A.cod_oficina,
			A.cod_moneda,
			A.cod_producto,
			A.operacion,
			A.cod_tipo_garantia_real,
			A.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			A.cod_bien,
			B.cedula_deudor,
			C.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION A
	INNER JOIN dbo.GAR_OPERACION B
	ON B.cod_operacion = A.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR C
	ON B.cedula_deudor = C.cedula_deudor
	WHERE A.cod_usuario					= @psCedula_Usuario
		AND A.cod_tipo_operacion		IN (1, 2)
		AND A.cod_tipo_garantia_real	= 1
		AND LEN(A.numero_finca)			> 6



	--Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	--que poseen asignado un n�mero de finca cuyas dos primeras posiciones son iguales a 0 (cero). 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			A.cod_oficina,
			A.cod_moneda,
			A.cod_producto,
			A.operacion,
			A.cod_tipo_garantia_real,
			A.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			A.cod_bien,
			B.cedula_deudor,
			C.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION A
	INNER JOIN dbo.GAR_OPERACION B
	ON B.cod_operacion = A.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR C
	ON B.cedula_deudor = C.cedula_deudor
	WHERE A.cod_usuario					= @psCedula_Usuario
		AND A.cod_tipo_operacion		IN (1, 2)
		AND A.cod_tipo_garantia_real	= 1
		AND LEFT(A.numero_finca, 2)		= '00'
	

	/*CEDULA HIPOTECARIA*/

	--Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	--que poseen asignado un n�mero de finca cuyo tama�o, en caracteres, supera las 6 posiciones. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )

		SELECT	1,
			A.cod_oficina,
			A.cod_moneda,
			A.cod_producto,
			A.operacion,
			A.cod_tipo_garantia_real,
			A.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			A.cod_bien,
			B.cedula_deudor,
			C.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION A
	INNER JOIN dbo.GAR_OPERACION B
	ON B.cod_operacion = A.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR C
	ON B.cedula_deudor = C.cedula_deudor
	WHERE A.cod_usuario					= @psCedula_Usuario
		AND A.cod_tipo_operacion		IN (1, 2)
		AND A.cod_tipo_garantia_real	= 2
		AND LEN(A.numero_finca)			> 6



	--Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	--que poseen asignado un n�mero de finca cuyas dos primeras posiciones son iguales a 0 (cero). 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
                                      Tipo_Garantia_Real, Clase_Garantia, Usuario, 
                                      Tipo_Inconsistencia, Garantia_Real, Deudor, Nombre_Deudor	
									  )
		
	SELECT	1,
			A.cod_oficina,
			A.cod_moneda,
			A.cod_producto,
			A.operacion,
			A.cod_tipo_garantia_real,
			A.cod_clase_garantia,
			@psCedula_Usuario,
			'Finca',
			A.cod_bien,
			B.cedula_deudor,
			C.nombre_deudor
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION A
	INNER JOIN dbo.GAR_OPERACION B
	ON B.cod_operacion = A.cod_operacion
	LEFT OUTER JOIN dbo.GAR_DEUDOR C
	ON B.cedula_deudor = C.cedula_deudor
	WHERE A.cod_usuario					= @psCedula_Usuario
		AND A.cod_tipo_operacion		IN (1, 2)
		AND A.cod_tipo_garantia_real	= 2
		AND LEFT(A.numero_finca, 2)		= '00'

	

/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCI�N DE INCONSISTENCIAS                            *
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
				'La obtenci�n de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
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
				 Deudor + CHAR(9) +
			     Nombre_Deudor + CHAR(9) +
                 CONVERT(VARCHAR(5), Tipo_Garantia_Real) + CHAR(9) +
				 (CASE WHEN  Clase_Garantia = -1 THEN '' ELSE CONVERT(VARCHAR(5), Clase_Garantia) END) + CHAR(9) + 
				 Garantia_Real + CHAR(9) + 
				 Tipo_Inconsistencia + CHAR(9))	AS [Inconsistencia!3!DATOS!element],
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	@TMP_INCONSISTENCIAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Partido_Finca</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END