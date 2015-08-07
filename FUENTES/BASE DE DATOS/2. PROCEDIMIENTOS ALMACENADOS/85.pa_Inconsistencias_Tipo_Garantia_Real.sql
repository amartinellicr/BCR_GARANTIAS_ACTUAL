USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Inconsistencias_Tipo_Garantia_Real', 'P') IS NOT NULL
DROP PROCEDURE Inconsistencias_Tipo_Garantia_Real;
GO

CREATE PROCEDURE [dbo].[Inconsistencias_Tipo_Garantia_Real]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Inconsistencias_Tipo_Garantia_Real</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene las inconsistencias referentes a diferentes campos de las garant�as reales.
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
	<Requerimiento>Req_Inconsistencias Garant�as Reales, Siebel No. 1-21378011</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Inconsistencias Cedula hipotecarias,  Siebel No. 1-21474091</Requerimiento>
			<Fecha>05/11/2012</Fecha>
			<Descripci�n>
				Se ajusta el procedimiento almacenado para que tome encuenta 
                las garant�as reales de c�dula hipotecaria, esto al momento de
                obtener las inconsistencias. 
				Tambi�n se realiza un ajuste general, con le fin de aplicar el est�ndar de programaci�n
				de base de datos.
            </Descripci�n>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfaum�ricas</Requerimiento>
			<Fecha>01/07/2015</Fecha>
			<Descripci�n>
				Se elimina la sentencia "WITH (NOLOCK)", esto porque permite extraer datos sucios. 
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

	--Declaraci�n de variables locales
	DECLARE		@vsIdentificacion_Usuario	VARCHAR(30), --Identificaci�n del usuario que ejecuta el proceso.
				@viEjecucion_Exitosa		INT --Valor de retorno producto de la ejecuci�n de un procedimiento almacenado.

    /*Se declaran estas estructuras debido con el fin de disminuir el tiempo de respuesta del procedimiento
	  almacenado */
	DECLARE		@TMP_VALUACIONES TABLE (
					Codigo_Contabilidad						TINYINT,
					Codigo_Oficina							SMALLINT,
					Codigo_Moneda							TINYINT,
					Codigo_Producto							TINYINT,
					Operacion								DECIMAL (7,0),
					Codigo_Garantia_Real					BIGINT	,
					Monto_Ultima_Tasacion_Terreno			MONEY	,
					Monto_Ultima_Tasacion_No_Terreno		MONEY	,
					Monto_Tasacion_Actualizada_Terreno		MONEY	,
					Monto_Tasacion_Actualizada_No_Terreno	MONEY	,
					Fecha_Construccion						DATETIME,
					Fecha_Constitucion						DATETIME,
					Fecha_Presentacion						DATETIME,
					Codigo_Tipo_Operacion					TINYINT	,
					Codigo_Bien								VARCHAR (25)	COLLATE database_default,
					Codigo_Tipo_Bien						SMALLINT,
					Codigo_Tipo_Garantia_Real				TINYINT,
					Codigo_Clase_Garantia					SMALLINT,
					Codigo_Tipo_Mitigador					SMALLINT,
					Codigo_Tipo_Documento_Legal				SMALLINT,
					Codigo_Grado_Gravamen					SMALLINT,
					Codigo_Usuario							VARCHAR (30)	COLLATE database_default
												) --Alamacenar� la informaci�n requerida de los aval�os asociados a las garant�as valoradas.




	DECLARE		@TMP_INCONSISTENCIAS TABLE (
					Contabilidad				TINYINT			,
					Oficina						SMALLINT		,
					Moneda						TINYINT			,
					Producto					TINYINT			,
					Operacion					DECIMAL(7, 0)	,
					Tipo_Garantia_Real			TINYINT			,
					Clase_Garantia				SMALLINT		,
					Tipo_Bien					SMALLINT		,
					Tipo_Mitigador				SMALLINT		,
					Tipo_Documento_Legal		SMALLINT		,
					Grado_Gravamen				SMALLINT		,
					Usuario						VARCHAR(30)		COLLATE database_default, 
					Tipo_Inconsistencia			VARCHAR(100)	COLLATE database_default,
					Garantia_Real				VARCHAR(30)		COLLATE database_default 
													)


	--Inicializaci�n de variables locales
	SET @vsIdentificacion_Usuario = @psCedula_Usuario

	/************************************************************************************************
	 *                                                                                              * 
	 *							INICIO DEL FILTRADO DE LAS GARANTIAS REALES							*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	--Se ejecuta el procedimiento almacenado que obtiene las garant�as a ser valoradas
	EXEC	@viEjecucion_Exitosa = [dbo].[Obtener_Garantias_Reales_A_Validar]
								   @psCedula_Usuario = @vsIdentificacion_Usuario

	--Se eval�a el resultado obtenido de la ejecuci�n del procedimiento almacenado
	IF(@viEjecucion_Exitosa <> 0)
	BEGIN
		SET		@psRespuesta = N'<RESPUESTA>' +
								'<CODIGO>-1</CODIGO>' + 
								'<NIVEL></NIVEL>' +
								'<ESTADO></ESTADO>' +
								'<PROCEDIMIENTO>Inconsistencias_Tipo_Garantia_Real</PROCEDIMIENTO>' +
								'<LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al obtener las inconsistencias de las garant�as reales.</MENSAJE>' +
								'<DETALLE>El problema se produjo al ejecutar el procedimiento almacenado "Obtener_Garantias_Reales_A_Validar", que obtiene las garant�as a ser valoradas.</DETALLE>' +
							'</RESPUESTA>'

		RETURN -1

	END
	/************************************************************************************************
	 *                                                                                              * 
	 *							FIN DEL FILTRADO DE LAS GARANTIAS REALES 							*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/


	/************************************************************************************************
	 *                                                                                              * 
	 *              INICIO DEL FILTRADO DE LAS VALUACIONES DE LAS GARANTIAS REALES                  *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/* Se obtienen todos los val�os que posee cada una de las garant�as*/
	INSERT INTO @TMP_VALUACIONES (
		Codigo_Contabilidad,
		Codigo_Oficina,
		Codigo_Moneda,
		Codigo_Producto,
		Operacion,
		Codigo_Garantia_Real,
		Monto_Ultima_Tasacion_Terreno,
		Monto_Ultima_Tasacion_No_Terreno,
		Monto_Tasacion_Actualizada_Terreno,
		Monto_Tasacion_Actualizada_No_Terreno,
		Fecha_Construccion,
		Fecha_Constitucion,
		Fecha_Presentacion,
		Codigo_Tipo_Operacion,
		Codigo_Bien,
		Codigo_Tipo_Bien,
		Codigo_Tipo_Garantia_Real,
		Codigo_Clase_Garantia,
		Codigo_Tipo_Mitigador,
		Codigo_Tipo_Documento_Legal,
		Codigo_Grado_Gravamen,
		Codigo_Usuario	
								 )
	SELECT	DISTINCT 
			TGR.Codigo_Contabilidad,
			TGR.Codigo_Oficina,
			TGR.Codigo_Moneda,
			TGR.Codigo_Producto,
			TGR.Operacion,
			VRV.cod_garantia_real,
			VRV.Monto_Ultima_Tasacion_Terreno,
			VRV.Monto_Ultima_Tasacion_No_Terreno,
			VRV.Monto_Tasacion_Actualizada_Terreno,
			VRV.Monto_Tasacion_Actualizada_No_Terreno,
			VRV.Fecha_Construccion,
			CONVERT(DATETIME, TGR.Fecha_Constitucion),
			CONVERT(DATETIME, TGR.Fecha_Presentacion),
			TGR.Codigo_Tipo_Operacion,
			TGR.Codigo_Bien,
			COALESCE(TGR.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien,
			TGR.Codigo_Tipo_Garantia_Real,
			TGR.Codigo_Clase_Garantia,
			COALESCE(TGR.Codigo_Tipo_Mitigador, -1) AS Codigo_Tipo_Mitigador, 
			COALESCE(TGR.Codigo_Tipo_Documento_Legal, -1) AS Codigo_Tipo_Documento_Legal,
			COALESCE(TGR.Codigo_Grado_Gravamen, -1) AS Codigo_Grado_Gravamen,
			TGR.Codigo_Usuario
	FROM	dbo.VALUACIONES_GARANTIAS_REALES_VW VRV
		INNER JOIN dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		ON TGR.Codigo_Garantia_Real = VRV.cod_garantia_real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
			
	/************************************************************************************************
	 *                                                                                              * 
	 *                 FIN DEL FILTRADO DE LAS VALUACIONES DE LAS GARANTIAS REALES                  *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *                         INICIO DE LA SELECCI�N DE INCONSISTENCIAS                            *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	UPDATE	@TMP_VALUACIONES
	SET		Fecha_Construccion	= NULL
	WHERE	Fecha_Construccion	= '19000101'

	UPDATE	@TMP_VALUACIONES
	SET		Fecha_Presentacion	= NULL
	WHERE	Fecha_Presentacion	= '19000101'

	UPDATE	@TMP_VALUACIONES
	SET		Fecha_Constitucion	= NULL
	WHERE	Fecha_Constitucion	= '19000101'


	/*INCONSISTENCIAS DEL CAMPO: CLASE DE GARANTIA*/

	/************ HIPOTECA COM�N ******************/
	
	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que no poseen asignada la clase garant�a.*/ 
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Clase de Garant�a',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Clase_Garantia		IS NULL

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a inv�lida.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Clase de Garant�a',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Clase_Garantia		NOT BETWEEN 10 AND 17


	/************ C�DULA HIPOTECARIA ******************/

	/*Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	  que no poseen asignada la clase garant�a.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Clase de Garant�a',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		IS NULL

	/*Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garant�a inv�lida. */
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Clase de Garant�a',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND ((Codigo_Clase_Garantia		< 18)
			OR (Codigo_Clase_Garantia	> 18))


	/*INCONSISTENCIAS DEL CAMPO: TIPO DE BIEN*/
	
	/************ HIPOTECA COM�N ******************/

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, pero el tipo de bien inv�lido. */
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo de Bien',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Clase_Garantia		BETWEEN 10 AND 17
		AND ((Codigo_Tipo_Bien			< 1)
			OR (Codigo_Tipo_Bien		> 2))


	/************ C�DULA HIPOTECARIA ******************/

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, pero el tipo de bien inv�lido. */
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo de Bien',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		= 18
		AND ((Codigo_Tipo_Bien			< 1)
			OR (Codigo_Tipo_Bien		> 2))



	/*INCONSISTENCIAS DEL CAMPO: TIPO DE MITIGADOR DE RIESGO*/
	
	/************ HIPOTECA COM�N ******************/

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien inv�lido y el tipo de mitigador 
      inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Tipo_Bien			= -1
		AND Codigo_Tipo_Mitigador		= -1
		AND Codigo_Clase_Garantia		BETWEEN 10 AND 17


	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido y el tipo de mitigador 
      inv�lido, seg�n el tipo de bien. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Tipo_Bien			= 1
		AND Codigo_Clase_Garantia		BETWEEN 10 AND 17
		AND ((Codigo_Tipo_Mitigador		< 1)
			OR (Codigo_Tipo_Mitigador	> 1))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Tipo_Bien			= 2
		AND Codigo_Clase_Garantia		BETWEEN 10 AND 17
		AND ((Codigo_Tipo_Mitigador		< 2)
			OR (Codigo_Tipo_Mitigador	> 3))

	/************ C�DULA HIPOTECARIA ******************/


	/*Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien inv�lido y el tipo de mitigador 
      inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		= 18
		AND Codigo_Tipo_Bien			= -1
		AND Codigo_Tipo_Mitigador		= -1

	/*Se escoge la informaci�n de las garant�as reales, de c�dula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido y el tipo de mitigador 
      inv�lido, seg�n el tipo de bien. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		= 18
		AND Codigo_Tipo_Bien			= 1
		AND ((Codigo_Tipo_Mitigador		< 4)
			OR (Codigo_Tipo_Mitigador	> 4))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Mitigador',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		= 18
		AND Codigo_Tipo_Bien			= 2
		AND ((Codigo_Tipo_Mitigador		< 5)
			OR (Codigo_Tipo_Mitigador	> 6))



	/*INCONSISTENCIAS DEL CAMPO: TIPO DE DOCUMENTO LEGAL*/
	
	/************ HIPOTECA COM�N ******************/

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien inv�lido, el tipo de mitigador 
      inv�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 1
		AND Codigo_Tipo_Bien				= -1
		AND Codigo_Tipo_Mitigador			= -1
		AND Codigo_Tipo_Documento_Legal		= -1
		AND Codigo_Clase_Garantia			BETWEEN 10 AND 17


	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido, el tipo de mitigador 
      inv�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 1
		AND Codigo_Tipo_Mitigador			= -1
		AND Codigo_Tipo_Documento_Legal		= -1
		AND Codigo_Clase_Garantia			BETWEEN 10 AND 17
		AND ((Codigo_Tipo_Bien				= 1)
			OR (Codigo_Tipo_Bien			= 2))

	
	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido, el tipo de mitigador 
      v�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 1
		AND Codigo_Clase_Garantia			BETWEEN 10 AND 17
		AND Codigo_Tipo_Mitigador			BETWEEN 1 AND 3
		AND ((Codigo_Tipo_Documento_Legal	< 1)
			OR (Codigo_Tipo_Documento_Legal	> 4))
		AND ((Codigo_Tipo_Bien				= 1)
			OR (Codigo_Tipo_Bien			= 2))


	/************ C�DULA HIPOTECARIA ******************/

	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien inv�lido, el tipo de mitigador 
      inv�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 2
		AND Codigo_Clase_Garantia			= 18
		AND Codigo_Tipo_Bien				= -1
		AND Codigo_Tipo_Mitigador			= -1
		AND Codigo_Tipo_Documento_Legal		= -1


	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido, el tipo de mitigador 
      inv�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 2
		AND Codigo_Clase_Garantia			= 18
		AND Codigo_Tipo_Mitigador			= -1
		AND Codigo_Tipo_Documento_Legal		= -1
		AND ((Codigo_Tipo_Bien				= 1)
			OR (Codigo_Tipo_Bien			= 2))

	
	/*Se escoge la informaci�n de las garant�as reales, de hipoteca com�n, asociadas a las operaciones 
	  que poseen asignada una clase garant�a v�lida, el tipo de bien v�lido, el tipo de mitigador 
      v�lido y el tipo de documento legal inv�lido. Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Tipo Documento Legal',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 2
		AND Codigo_Clase_Garantia			= 18
		AND Codigo_Tipo_Mitigador			BETWEEN 4 AND 6
		AND ((Codigo_Tipo_Documento_Legal	< 5)
			OR (Codigo_Tipo_Documento_Legal	> 8))
		AND ((Codigo_Tipo_Bien				= 1)
			OR (Codigo_Tipo_Bien			= 2))


	/*INCONSISTENCIAS DEL CAMPO: GRADO DEL GRAVAMEN*/
	
	/************ HIPOTECA COM�N ******************/

	/*Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	  que poseen el tipo de documento legal inv�lido y el grado de gravamen inv�lido, seg�n el tipo 
      de documento legal (v�lido) que posea asociado la garant�a. 
      Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 1
		AND ((Codigo_Tipo_Documento_Legal	< 1)
			OR (Codigo_Tipo_Documento_Legal	> 4))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 1
		AND ((Codigo_Grado_Gravamen			< 1)
			OR (Codigo_Grado_Gravamen		> 1))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 2
		AND ((Codigo_Grado_Gravamen			< 2)
			OR (Codigo_Grado_Gravamen		> 2))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 3
		AND ((Codigo_Grado_Gravamen			< 3)
			OR (Codigo_Grado_Gravamen		> 3))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 4
		AND ((Codigo_Grado_Gravamen			< 4)
			OR (Codigo_Grado_Gravamen		> 4))


	/************ C�DULA HIPOTECARIA ******************/

	/*Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	  que poseen el tipo de documento legal inv�lido y el grado de gravamen inv�lido, seg�n el tipo 
      de documento legal (v�lido) que posea asociado la garant�a. 
      Los valores inv�lidos incluyen los nulos.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Garantia_Real		= 2
		AND ((Codigo_Tipo_Documento_Legal	< 5)
			OR (Codigo_Tipo_Documento_Legal	> 8))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 5
		AND ((Codigo_Grado_Gravamen			< 1)
			OR (Codigo_Grado_Gravamen		> 1))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 6
		AND ((Codigo_Grado_Gravamen			< 2)
			OR (Codigo_Grado_Gravamen		> 2))

	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 7
		AND ((Codigo_Grado_Gravamen			< 3)
			OR (Codigo_Grado_Gravamen		> 3))


	UNION ALL

	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Grado Gravamen',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario					= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion			= 1)
			OR (Codigo_Tipo_Operacion		= 2))
		AND Codigo_Tipo_Documento_Legal		= 8
		AND ((Codigo_Grado_Gravamen			< 4)
			OR (Codigo_Grado_Gravamen		> 4))



	/*INCONSISTENCIAS DEL CAMPO: VALUACIONES TERRENO*/

	/*Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	  que poseen los datos del aval�o, correspondientes a los montos del terreno mayores a cero y
      cuyo tipo de bien sea diferente a 1.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Valuaciones Terreno',
			Codigo_Bien
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Bien			= 1
		AND ((COALESCE(Monto_Ultima_Tasacion_Terreno, 0)		= 0)
		 OR (COALESCE(Monto_Tasacion_Actualizada_Terreno, 0)	= 0))


	/*INCONSISTENCIAS DEL CAMPO: VALUACIONES NO TERRENO*/
	
	/*Se escoge la informaci�n de las garant�as reales asociadas a las operaciones 
	  que poseen los datos del aval�o inv�lidos,seg�n el tipo de bien que posea la garant�a.*/
	INSERT INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, 
		Tipo_Garantia_Real, Clase_Garantia, Tipo_Bien, Tipo_Mitigador, Tipo_Documento_Legal, 
		Grado_Gravamen, Usuario, Tipo_Inconsistencia, Garantia_Real)
	SELECT	1,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Mitigador,
			Codigo_Tipo_Documento_Legal,
			Codigo_Grado_Gravamen,
			@vsIdentificacion_Usuario,
			'Valuaciones No Terreno',
			Codigo_Bien
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Bien			= 2
		AND ((COALESCE(Monto_Ultima_Tasacion_Terreno, 0)			 = 0)
			 OR (COALESCE(Monto_Ultima_Tasacion_No_Terreno, 0 )		 = 0)
			 OR (COALESCE(Monto_Tasacion_Actualizada_Terreno, 0)	 = 0)
			 OR (COALESCE(Monto_Tasacion_Actualizada_No_Terreno , 0) = 0))

/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCI�N DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	/*Se actualiza a NULL todas los mitigadores de riesgo, documentos legales y tipos de bien que sea igual a -1*/
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Tipo_Bien		= NULL
	WHERE	Tipo_Bien		= -1

	UPDATE	@TMP_INCONSISTENCIAS
	SET		Tipo_Mitigador	= NULL
	WHERE	Tipo_Mitigador	= -1

	UPDATE	@TMP_INCONSISTENCIAS
	SET		Tipo_Documento_Legal	= NULL
	WHERE	Tipo_Documento_Legal	= -1


	SELECT	DISTINCT	
		1							AS Tag,
		NULL						AS Parent,
		'0'							AS [RESPUESTA!1!CODIGO!element], 
		NULL						AS [RESPUESTA!1!NIVEL!element], 
		NULL						AS [RESPUESTA!1!ESTADO!element], 
		'Inconsistencias_Tipo_Garantia_Real'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
		NULL						AS [RESPUESTA!1!LINEA!element], 
		'La obtenci�n de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
		NULL						AS [DETALLE!2!], 
		NULL						AS [Inconsistencia!3!DATOS!element], 
		NULL						AS [Inconsistencia!3!Usuario!hide]
	
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
		(CONVERT(VARCHAR(5), Contabilidad)						+ CHAR(9) + 
		 CONVERT(VARCHAR(5), Oficina)							+ CHAR(9) + 
         CONVERT(VARCHAR(5), Moneda)							+ CHAR(9) +
		 CONVERT(VARCHAR(5), Producto)							+ CHAR(9) + 
         CONVERT(VARCHAR(20), Operacion)						+ CHAR(9) + 
		 COALESCE(CONVERT(VARCHAR(5), Tipo_Garantia_Real), '')	+ CHAR(9) +
	     COALESCE(Garantia_Real, '')								+ CHAR(9) +
         COALESCE(CONVERT(VARCHAR(5), Clase_Garantia), '')		+ CHAR(9) +
		 COALESCE(CONVERT(VARCHAR(5), Tipo_Bien), '')				+ CHAR(9) + 
         COALESCE(CONVERT(VARCHAR(5), Tipo_Mitigador), '')		+ CHAR(9) +
		 COALESCE(CONVERT(VARCHAR(5), Tipo_Documento_Legal), '')	+ CHAR(9) + 
		 COALESCE(CONVERT(VARCHAR(5), Grado_Gravamen), '')		+ CHAR(9) + 
		 Tipo_Inconsistencia + CHAR(9))	AS [Inconsistencia!3!DATOS!element],
		Usuario							AS [Inconsistencia!3!Usuario!hide]
	FROM	@TMP_INCONSISTENCIAS 
	WHERE	Usuario						=  @vsIdentificacion_Usuario
	FOR		XML EXPLICIT

	SET @psRespuesta = N'	<RESPUESTA>' +
								'<CODIGO>0</CODIGO>' +
								'<NIVEL></NIVEL>' +
								'<ESTADO></ESTADO>' +
								'<PROCEDIMIENTO>Inconsistencias_Tipo_Garantia_Real</PROCEDIMIENTO>' +
								'<LINEA></LINEA>' + 
								'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE>' +
								'<DETALLE></DETALLE>' +
							'</RESPUESTA>'

	RETURN 0
END