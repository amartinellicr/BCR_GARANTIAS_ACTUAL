set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

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
											cod_clasificacion_instrumento	smallint,
											des_instrumento					varchar (25)	collate database_default,
											cod_tipo_garantia				smallint,
											cod_garantia_valor				bigint,
											cod_operacion					bigint,
											cod_estado						smallint,
											cod_tipo_operacion				tinyint,
											ind_duplicidad					tinyint			DEFAULT (1)	,
											cod_usuario						varchar (30)	collate database_default,
											cod_llave						bigint			IDENTITY(1,1)
											PRIMARY KEY (cod_llave)
										)

	DECLARE @vdFechaActualSinHora	DATETIME  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones

	SET @vdFechaActualSinHora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)



	/*Se elimina la informaci�n de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion = 1
	DELETE FROM dbo.TMP_OPERACIONES_DUPLICADAS WHERE cod_usuario = @psCedula_Usuario AND cod_tipo_garantia = 3 AND cod_tipo_operacion = 2


/************************************************************************************************
 *                                                                                              * 
 *                     INICIO DEL FILTRADO DE LAS GARANTIAS DE VALOR                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/


	/*Se selecciona la informaci�n de la garant�as de valor asociadas a las operaciones*/
	INSERT INTO @TMP_GARANTIAS_VALOR (	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
										numero_seguridad, cod_tipo_mitigador, cod_tipo_documento_legal, 
										monto_mitigador, fecha_presentacion, cod_inscripcion, 
										porcentaje_responsabilidad, fecha_constitucion, 
										cod_clasificacion_instrumento, des_instrumento, 
										cod_tipo_garantia, cod_garantia_valor, cod_operacion, 
										cod_estado, cod_tipo_operacion, ind_duplicidad, cod_usuario)
	
		SELECT DISTINCT 
		1 AS cod_contabilidad, 
		VOV.cod_oficina, 
		VOV.cod_moneda, 
		VOV.cod_producto, 
		VOV.num_operacion AS operacion, 
		GGV.numero_seguridad AS numero_seguridad, 
		ISNULL(GVO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
		ISNULL(GVO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GVO.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GVO.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(GVO.cod_inscripcion, -1) AS cod_inscripcion,
		ISNULL(GVO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GGV.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGV.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
		ISNULL(GGV.des_instrumento, '') AS des_instrumento,
		GGV.cod_tipo_garantia,
		GVO.cod_garantia_valor,
		GVO.cod_operacion,
		GVO.cod_estado,
		1 AS cod_tipo_operacion,	
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario
		
	FROM 
		dbo.GARANTIAS_VALOR_X_OPERACION_VW VOV 
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
		 ON VOV.cod_operacion		= GVO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
		ON GGV.cod_garantia_valor	= GVO.cod_garantia_valor 

	WHERE VOV.cod_tipo_operacion	= 1
		AND GVO.cod_estado			= 1

	ORDER BY
		GVO.cod_operacion,
		GGV.numero_seguridad,
		GVO.cod_tipo_documento_legal DESC


	/*Se selecciona la informaci�n de las garant�as de valor asociada a los contratos*/
	INSERT INTO @TMP_GARANTIAS_VALOR (	cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, 
										numero_seguridad, cod_tipo_mitigador, cod_tipo_documento_legal, 
										monto_mitigador, fecha_presentacion, cod_inscripcion, 
										porcentaje_responsabilidad, fecha_constitucion, 
										cod_clasificacion_instrumento, des_instrumento, 
										cod_tipo_garantia, cod_garantia_valor, cod_operacion, 
										cod_estado, cod_tipo_operacion, ind_duplicidad, cod_usuario)
	
		SELECT DISTINCT 
		1 AS cod_contabilidad, 
		VOV.cod_oficina_contrato, 
		VOV.cod_moneda_contrato, 
		VOV.cod_producto_contrato, 
		VOV.num_contrato AS operacion, 
		GGV.numero_seguridad AS numero_seguridad, 
		ISNULL(GVO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
		ISNULL(GVO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GVO.monto_mitigador, 0) AS monto_mitigador,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GVO.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
		ISNULL(GVO.cod_inscripcion, -1) AS cod_inscripcion,
		ISNULL(GVO.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((ISNULL(GGV.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
		ISNULL(GGV.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
		ISNULL(GGV.des_instrumento, '') AS des_instrumento,
		GGV.cod_tipo_garantia,
		GVO.cod_garantia_valor,
		GVO.cod_operacion,
		GVO.cod_estado,
		2 AS cod_tipo_operacion,	
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario
		
	FROM 
		dbo.GARANTIAS_VALOR_X_OPERACION_VW VOV 
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
		 ON VOV.cod_operacion		= GVO.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR GGV
		ON GGV.cod_garantia_valor	= GVO.cod_garantia_valor 

	WHERE VOV.cod_tipo_operacion = 2
		AND EXISTS (SELECT 1
					FROM dbo.GAR_SICC_PRMGT PMT
					WHERE PMT.prmgt_pco_conta	= 1
					 AND PMT.prmgt_pco_ofici	= VOV.cod_oficina_contrato
					 AND PMT.prmgt_pco_moned	= VOV.cod_moneda_contrato
					 AND PMT.prmgt_pnu_oper		= VOV.num_contrato
					 AND PMT.prmgt_pcoclagar	BETWEEN 20 AND 29
					 AND PMT.prmgt_pcotengar	IN (2,3,4,6)
					--RQ: 1-23923921. Se cambia el tipo de dato de la compraci�n, pasando de num�rica a texto.
					 AND CONVERT(VARCHAR(25), PMT.prmgt_pnuidegar)	= GGV.numero_seguridad
					 AND PMT.prmgt_pco_produ	= 10
					 AND PMT.prmgt_estado		= 'A') /*Aqu� se ha determinado si la garant�a existente en BCRGarant�as est� activa en la estructura del SICC*/

	ORDER BY
		GVO.cod_operacion,
		GGV.numero_seguridad,
		GVO.cod_tipo_documento_legal DESC


	/*Se obtienen las operaciones duplicadas*/
	INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_seguridad AS cod_garantia_sicc,
			3 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_valor) AS cod_garantia,
			NULL AS cod_grado

	FROM @TMP_GARANTIAS_VALOR

	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)

	GROUP BY cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Se cambia el c�digo del campo ind_duplicidad a 2, indicando con esto que la operaci�n se encuentra duplicada.
      Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_VALOR TGV
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGV.cod_oficina						= TOD.cod_oficina
					AND TGV.cod_moneda						= TOD.cod_moneda
					AND TGV.cod_producto					= TOD.cod_producto
					AND TGV.operacion						= TOD.operacion
					AND ISNULL(TGV.numero_seguridad, '')	= ISNULL(TOD.cod_garantia_sicc, '')
					AND ISNULL(TGV.cod_usuario, '')			= ISNULL(TOD.cod_usuario, '')
					AND TOD.cod_tipo_operacion				IN (1, 2)
					AND TOD.cod_tipo_garantia				= 3 
					AND TGV.cod_tipo_documento_legal		IS NULL
					AND TGV.fecha_presentacion				IS NULL
					AND TGV.cod_tipo_mitigador				IS NULL
					AND TGV.cod_inscripcion					IS NULL)

		AND TGV.cod_usuario			= @psCedula_Usuario
		AND TGV.cod_tipo_operacion	IN (1, 2)
			 
	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la informaci�n*/
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que har�a el 
	  cursor, tomar�a el primer registro que encuentre y los dem�s los descarta.*/
	UPDATE dbo.TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = GV1.cod_llave
	FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
	INNER JOIN @TMP_GARANTIAS_VALOR GV1
	ON GV1.cod_oficina						= TOD.cod_oficina
	AND GV1.cod_moneda						= TOD.cod_moneda
	AND GV1.cod_producto					= TOD.cod_producto
	AND GV1.operacion						= TOD.operacion
	AND ISNULL(GV1.numero_seguridad, '')	= ISNULL(TOD.cod_garantia_sicc, '')
	WHERE GV1.cod_llave	= (	SELECT MIN(GV2.cod_llave)
							FROM @TMP_GARANTIAS_VALOR GV2
							WHERE GV2.cod_oficina					= TOD.cod_oficina
							AND GV2.cod_moneda						= TOD.cod_moneda
							AND GV2.cod_producto					= TOD.cod_producto
							AND GV2.operacion						= TOD.operacion
							AND ISNULL(GV2.numero_seguridad, '')	= ISNULL(TOD.cod_garantia_sicc, '')
							AND ISNULL(GV2.cod_usuario, '')			= ISNULL(TOD.cod_usuario, '')
							AND GV2.cod_tipo_operacion				IN (1, 2)
							AND TOD.cod_tipo_garantia				= 3)
	AND GV1.cod_usuario			= @psCedula_Usuario
	AND GV1.cod_tipo_operacion	IN (1, 2)

	/*Se eliminan los dupplicados que sean diferentes al c�digo de garant�a actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_VALOR TGV
	WHERE EXISTS (SELECT 1 
				  FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
				  WHERE TGV.cod_oficina						= TOD.cod_oficina
					AND TGV.cod_moneda						= TOD.cod_moneda
					AND TGV.cod_producto					= TOD.cod_producto
					AND TGV.operacion						= TOD.operacion
					AND ISNULL(TGV.numero_seguridad, '')	= ISNULL(TOD.cod_garantia_sicc, '')
					AND TGV.cod_llave						<> TOD.cod_garantia
					AND ISNULL(TGV.cod_usuario, '')			= ISNULL(TOD.cod_usuario, '')
					AND TGV.cod_tipo_operacion				IN (1, 2)
					AND TOD.cod_tipo_garantia				= 3)

	AND TGV.cod_usuario			= @psCedula_Usuario
	AND TGV.cod_tipo_operacion	IN (1, 2)

	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la informaci�n*/
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 1 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario
	DELETE FROM @TMP_GARANTIAS_VALOR WHERE cod_tipo_operacion = 2 AND ind_duplicidad = 2 AND cod_usuario = @psCedula_Usuario


/************************************************************************************************
 *                                                                                              * 
 *                      FIN DEL FILTRADO DE LAS GARANTIAS DE VALOR                              *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCI�N DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se actualiza a NULL todas las fechas de presentaci�n que sea igual a 01/01/1900*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET fecha_presentacion		= NULL
	WHERE fecha_presentacion	= '19000101'

	/*Se actualiza a NULL todas los indicadores de inscripci�n que sean igual a -1*/
	UPDATE @TMP_GARANTIAS_VALOR
	SET cod_inscripcion			= NULL
	WHERE cod_inscripcion		= -1


/*INCONSISTENCIAS DEL CAMPO: FECHA DE PRESENTACION*/
	
	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrFechapresentaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NULL

	
	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrFechapresentaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NOT NULL 
		AND fecha_presentacion	< fecha_constitucion


/*INCONSISTENCIAS DEL CAMPO: INDICADOR DE INSCRIPCION*/
	
	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 2 
		AND @vdFechaActualSinHora	> DATEADD(day, 60, fecha_constitucion)



	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constituci�n y la fecha resultante de sumarle 30 d�as a la fecha de 
    --constituci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 3 
		AND @vdFechaActualSinHora	BETWEEN fecha_constitucion AND DATEADD(day, 30, fecha_constitucion)



	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", pero cuya fecha de proceso (fecha actual) 
    --es mayor a la fecha resultante de sumarle 30 d�as a la fecha de constituci�n. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 1 
		AND @vdFechaActualSinHora	> DATEADD(day, 30, fecha_constitucion)



	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND fecha_presentacion	IS NOT NULL
		AND cod_inscripcion		IS NULL



/*INCONSISTENCIAS DEL CAMPO: MONTO MITIGADOR*/
	
	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 2 
		AND @vdFechaActualSinHora	> DATEADD(day, 60, fecha_constitucion) 
		AND monto_mitigador			<> 0
		

	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constituci�n y la fecha resultante de sumarle 30 d�as a la fecha de 
    --constituci�n y adem�s posee un monto mitigador diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND fecha_constitucion		IS NOT NULL
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 3 
		AND @vdFechaActualSinHora	BETWEEN fecha_constitucion AND DATEADD(day, 30, fecha_constitucion) 
		AND monto_mitigador			<> 0
		

	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario			= @psCedula_Usuario
		AND cod_tipo_operacion	IN (1, 2)
		AND cod_inscripcion		IS NOT NULL
		AND cod_inscripcion		= 0 
		AND monto_mitigador		<> 0


	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", adem�s de que 
    --la fecha de proceso (fecha actual) sea mayor a la fecha resultante de sumarle 30 d�as a la 
    --fecha de constituci�n y que posee un monto mitigador diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario				= @psCedula_Usuario
		AND cod_tipo_operacion		IN (1, 2)
		AND cod_inscripcion			IS NOT NULL
		AND cod_inscripcion			= 1
		AND @vdFechaActualSinHora	> DATEADD(day, 30, fecha_constitucion)
		AND monto_mitigador			<> 0



/*INCONSISTENCIAS DEL CAMPO: PORCENTAJE DE ACEPTACION*/
	
	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
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
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND fecha_constitucion			IS NOT NULL
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 2
		AND @vdFechaActualSinHora		> DATEADD(day, 60, fecha_constitucion)
		AND porcentaje_responsabilidad	<> 0


	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "Inscrita", pero cuya fecha de proceso (fecha actual) 
    --se encuentra entre la fecha de constituci�n y la fecha resultante de sumarle 30 d�as a la fecha de 
    --constituci�n y un porcentaje de aceptaci�n diferente de cero. 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Tipo_Bien, 
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
			'ErrAceptaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND fecha_constitucion			IS NOT NULL
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 3 
		AND @vdFechaActualSinHora		BETWEEN fecha_constitucion AND DATEADD(day, 30, fecha_constitucion) 
		AND porcentaje_responsabilidad	<> 0


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
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 0
		AND porcentaje_responsabilidad	<> 0



	--Se escoge la informaci�n de las garant�as de valor asociadas a las operaciones 
	--que poseen asignado el indicador de inscripci�n "No Anotada/No Inscrita", adem�s de que la fecha de 
    --proceso (fecha actual) sea mayor a la fecha resultante de sumarle 30 d�as a la fecha de constituci�n y 
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
			NULL,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			3,
			cod_clasificacion_instrumento,
			@psCedula_Usuario,
			NULL, 
			'ErrAceptaci�n',
			'Valor',
			numero_seguridad
			
	FROM @TMP_GARANTIAS_VALOR
	WHERE cod_usuario					= @psCedula_Usuario
		AND cod_tipo_operacion			IN (1, 2)
		AND cod_inscripcion				IS NOT NULL
		AND cod_inscripcion				= 1
		AND @vdFechaActualSinHora		> DATEADD(day, 30, fecha_constitucion)
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
                 ISNULL(CONVERT(VARCHAR(5), Tipo_Bien), '') + CHAR(9) +
				 ISNULL(Codigo_Bien, '') + CHAR(9) + 
                 (CASE WHEN  Tipo_Mitigador = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Mitigador) END) + CHAR(9) + 
				 (CASE WHEN  Tipo_Documento_Legal = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Documento_Legal) END) + CHAR(9) +
				 Tipo_Inconsistencia + CHAR(9) + 
                 CONVERT(VARCHAR(5), Tipo_Garantia) + CHAR(9) + 
				 Descripcion_Tipo_Garantia + CHAR(9) +
				 Numero_Seguridad + CHAR(9) +
				 (CASE WHEN  Tipo_Instrumento = -1 THEN '' ELSE CONVERT(VARCHAR(5), Tipo_Instrumento) END))
											AS [Inconsistencia!3!DATOS!element],
				Usuario						AS [Inconsistencia!3!Usuario!hide]
		FROM	@TMP_INCONSISTENCIAS 
		WHERE	Usuario						=  @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Inconsistencias_Indicador_Inscripcion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END