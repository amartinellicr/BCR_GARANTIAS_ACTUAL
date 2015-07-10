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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene las inconsistencias referentes al campo del indicador de inscripci�n.
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
	<Requerimiento>Indicador de Inscripci�n, Sibel: 1 - 21317031</Requerimiento>
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
			<Autor>Arnoldo Martinelli Mar�n, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfaum�ricas</Requerimiento>
			<Fecha>06/07/2015</Fecha>
			<Descripci�n>
				El cambio es referente a la implementaci�n de placas alfanum�ricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garant�a es 
				11, 38 o 43. 
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
											Tipo_Bien					smallint		,
											Tipo_Mitigador				smallint		,
											Tipo_Documento_Legal		smallint		,
											Tipo_Garantia				tinyint			,
											Tipo_Instrumento			smallint		,
											Usuario						varchar(30)		collate database_default, 
											Codigo_Bien					varchar(30)		collate database_default ,
											Tipo_Inconsistencia			varchar(100)	collate database_default ,
											Descripcion_Tipo_Garantia	varchar(15)		collate database_default ,
											Numero_Seguridad			varchar(25)		collate database_default 
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
														fecha_constitucion			varchar (10)	collate database_default,
														cod_usuario					varchar (30)	collate database_default,
														cod_inscripcion				smallint,
														fecha_presentacion			varchar (10)	collate database_default
														PRIMARY KEY (cod_llave)
													)
	

	DECLARE @vdFechaActualSinHora	DATETIME  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones

	SET @vdFechaActualSinHora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	
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
			WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
			WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
			WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
			WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		COALESCE(GGR.cod_grado,'') AS cod_grado,
		COALESCE(GGR.numero_finca,'') AS numero_finca,
		COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
		COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
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
			WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
			WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
			WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
			WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		COALESCE(GGR.cod_grado,'') AS cod_grado,
		COALESCE(GGR.numero_finca,'') AS numero_finca,
		COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
		COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
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
					 AND GSP.prmgt_pco_grado	= COALESCE(GGR.cod_grado, GSP.prmgt_pco_grado)
					 AND GSP.prmgt_estado		= 'A'
					 AND GSP.prmgt_pnu_oper		= ROV.num_contrato
					 AND GSP.prmgt_pco_ofici	= ROV.cod_oficina_contrato
					 AND GSP.prmgt_pco_moned	= ROV.cod_moneda_contrato
					 AND GSP.prmgt_pco_produ	= 10
					 AND GSP.prmgt_pco_conta	= 1
					 AND COALESCE(GSP.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					 AND COALESCE(GSP.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, ''))

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

	/*Se obtienen las garant�as reales de prenda duplicadas*/
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
					AND COALESCE(TGR.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
					AND TGR.cod_llave					<> TOD.cod_garantia
					AND TGR.cod_tipo_garantia_real		= 3
					AND COALESCE(TGR.cod_usuario, '')	= COALESCE(TOD.cod_usuario, '')
					AND TOD.cod_tipo_garantia			= 2
					AND TGR.cod_tipo_operacion			IN (1, 2))
	AND TGR.cod_tipo_garantia_real	= 3
	AND TGR.cod_usuario				= @psCedula_Usuario
	AND TGR.cod_tipo_operacion		IN (1, 2)


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
	 monto_mitigador, cod_bien, fecha_constitucion, cod_usuario, cod_inscripcion, 
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
			WHEN GR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + COALESCE(GR.numero_finca,'')  
			WHEN GR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GR.cod_partido),'') + COALESCE(GR.numero_finca,'')
			WHEN ((GR.cod_tipo_garantia_real = 3) AND (GR.cod_clase_garantia <> 38) AND (GR.cod_clase_garantia <> 43)) THEN COALESCE(GR.cod_clase_bien,'') + COALESCE(GR.num_placa_bien,'') 
			WHEN ((GR.cod_tipo_garantia_real = 3) AND ((GR.cod_clase_garantia = 38) OR (GR.cod_clase_garantia = 43))) THEN COALESCE(GR.num_placa_bien,'') 
		END	AS cod_bien, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		TGR.cod_usuario,
		COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion
		
	FROM @TMP_GARANTIAS_REALES_OPERACIONES TGR
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
	ON GRO.cod_operacion		= TGR.cod_operacion
	AND GRO.cod_garantia_real	= TGR.cod_garantia_real
	INNER JOIN GAR_GARANTIA_REAL GR
	ON GR.cod_garantia_real		= TGR.cod_garantia_real
	WHERE TGR.cod_usuario = @psCedula_Usuario

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

	/*Se actualiza a NULL todas las fechas de presentaci�n que sea igual a 01/01/1900*/
	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET fecha_presentacion		= NULL
	WHERE fecha_presentacion	= '19000101'

	/*Se actualiza a NULL los indicadores de inscripci�n iguales a -1*/
	UPDATE @TMP_GARANTIAS_REALES_X_OPERACION
	SET cod_inscripcion		= NULL
	WHERE cod_inscripcion	= -1


/*INCONSISTENCIAS DEL CAMPO: FECHA DE PRESENTACION*/
	
	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignada una fecha de presentaci�n menor a la fecha de constituci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrFechapresentaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NOT NULL 
		AND fecha_presentacion	< fecha_constitucion


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que no poseen asignada una fecha de presentaci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrFechapresentaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NULL


/*INCONSISTENCIAS DEL CAMPO: INDICADOR DE INSCRIPCION*/
	
	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que no poseen asignado el indicador de inscripci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NOT NULL
		AND cod_inscripcion		IS NULL
	

	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 d�as a la fecha de constituci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_constitucion	IS NOT NULL
		AND cod_inscripcion		IS NOT NULL
		AND cod_inscripcion		= 2 
		AND @vdFechaActualSinHora > DATEADD(DAY, 60, fecha_constitucion)


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", pero cuya fecha de proceso 
    --(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 d�as a la fecha de constituci�n.  
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 1 
		AND @vdFechaActualSinHora	>= DATEADD(DAY, 30, fecha_constitucion)


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Aplica", pero que poseen un tipo de bien
    --diferente a "Otros tipos de bienes". 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrIndicadorInscrip',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND cod_inscripcion		IS NOT NULL
		AND cod_inscripcion		= 0 
		AND cod_tipo_bien		<> 14



/*INCONSISTENCIAS DEL CAMPO: MONTO MITIGADOR*/
	
	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 d�as a la fecha de constituci�n y adem�s posee
    --un monto mitigador diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 2
		AND @vdFechaActualSinHora	> DATEADD(DAY, 60, fecha_constitucion) 
		AND monto_mitigador			<> 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Inscrita", pero adem�s posee un monto mitigador igual o menor a cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 3 
		AND monto_mitigador			<= 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Aplica" y que posee
    --un monto mitigador diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND cod_inscripcion		IS NOT NULL
		AND cod_inscripcion		= 0 
		AND monto_mitigador		<> 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", adem�s de que la fecha de 
    --proceso (fecha actual) sea mayor o igual a la fecha resultante de sumarle 30 d�as a la fecha de constituci�n y 
    --que posee un monto mitigador diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrMontomitiga',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 1 
		AND @vdFechaActualSinHora	>= DATEADD(DAY, 30, fecha_constitucion)
		AND monto_mitigador			<> 0
	
/*INCONSISTENCIAS DEL CAMPO: PORCENTAJE DE ACEPTACION*/
	
	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 d�as a la fecha de constituci�n y adem�s posee
    --un porcentaje de aceptaci�n diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND fecha_constitucion			IS NOT NULL
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 2
		AND @vdFechaActualSinHora		> DATEADD(DAY, 60, fecha_constitucion)
		AND porcentaje_responsabilidad	<> 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Inscrita" y un porcentaje de aceptaci�n igual o menor a cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND fecha_constitucion			IS NOT NULL
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 3
		AND porcentaje_responsabilidad	<= 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Aplica" y que posee
    --un porcentaje de aceptaci�n diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 0
		AND porcentaje_responsabilidad	<> 0


	--Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", adem�s de que la fecha de 
    --proceso (fecha actual) sea mayor o igual a la fecha resultante de sumarle 30 d�as a la fecha de constituci�n y 
    --que posee un porcentaje de aceptaci�n diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
										 Tipo_Mitigador, Tipo_Documento_Legal, Tipo_Garantia, 
										 Tipo_Instrumento, Usuario, Codigo_Bien, Tipo_Inconsistencia, 
                                         Descripcion_Tipo_Garantia, Numero_Seguridad)

	SELECT	1,
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_bien,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			2,
			NULL,
			@psCedula_Usuario,
			cod_bien AS Codigo_Bien, 
			'ErrAceptaci�n',
			'Real',
			NULL
			
	FROM @TMP_GARANTIAS_REALES_X_OPERACION
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 1 
		AND @vdFechaActualSinHora		>= DATEADD(DAY, 30, fecha_constitucion)
		AND porcentaje_responsabilidad	<> 0


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
				'pa_Inconsistencias_Indicador_Inscripcion' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
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
                 (CASE WHEN  Tipo_Bien = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Bien) END) + CHAR(9) +
				 COALESCE(Codigo_Bien, '') + CHAR(9) + 
                 (CASE WHEN  Tipo_Mitigador = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Mitigador) END) + CHAR(9) + 
                 (CASE WHEN  Tipo_Documento_Legal = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Documento_Legal) END) + CHAR(9) +
				 Tipo_Inconsistencia + CHAR(9) + 
				 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 COALESCE(CONVERT(VARCHAR(5), Tipo_Instrumento), '') + CHAR(9) + 
				 COALESCE(Numero_Seguridad, ''))	AS [Inconsistencia!3!DATOS!element],
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	@TMP_INCONSISTENCIAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Indicador_Inscripcion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END