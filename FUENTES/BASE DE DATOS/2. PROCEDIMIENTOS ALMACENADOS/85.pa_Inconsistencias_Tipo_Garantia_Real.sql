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
			<Requerimiento>Req_Inconsistencias Cedula hipotecarias,  Siebel No. 1-21474091</Requerimiento>
			<Fecha>05/11/2012</Fecha>
			<Descripción>
				Se ajusta el procedimiento almacenado para que tome encuenta 
                las garantías reales de cédula hipotecaria, esto al momento de
                obtener las inconsistencias. 
				También se realiza un ajuste general, con le fin de aplicar el estándar de programación
				de base de datos.
            </Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>01/07/2015</Fecha>
			<Descripción>
				Se elimina la sentencia "WITH (NOLOCK)", esto porque permite extraer datos sucios. 
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

	--Declaración de variables locales
	DECLARE		@vsIdentificacion_Usuario	VARCHAR(30), --Identificación del usuario que ejecuta el proceso.
				@viEjecucion_Exitosa		INT --Valor de retorno producto de la ejecución de un procedimiento almacenado.

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
												) --Alamacenará la información requerida de los avalúos asociados a las garantías valoradas.




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


	--Inicialización de variables locales
	SET @vsIdentificacion_Usuario = @psCedula_Usuario

	/************************************************************************************************
	 *                                                                                              * 
	 *							INICIO DEL FILTRADO DE LAS GARANTIAS REALES							*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	--Se ejecuta el procedimiento almacenado que obtiene las garantías a ser valoradas
	EXEC	@viEjecucion_Exitosa = [dbo].[Obtener_Garantias_Reales_A_Validar]
								   @psCedula_Usuario = @vsIdentificacion_Usuario

	--Se evalúa el resultado obtenido de la ejecución del procedimiento almacenado
	IF(@viEjecucion_Exitosa <> 0)
	BEGIN
		SET		@psRespuesta = N'<RESPUESTA>' +
								'<CODIGO>-1</CODIGO>' + 
								'<NIVEL></NIVEL>' +
								'<ESTADO></ESTADO>' +
								'<PROCEDIMIENTO>Inconsistencias_Tipo_Garantia_Real</PROCEDIMIENTO>' +
								'<LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al obtener las inconsistencias de las garantías reales.</MENSAJE>' +
								'<DETALLE>El problema se produjo al ejecutar el procedimiento almacenado "Obtener_Garantias_Reales_A_Validar", que obtiene las garantías a ser valoradas.</DETALLE>' +
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

	/* Se obtienen todos los valúos que posee cada una de las garantías*/
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
	 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
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

	/************ HIPOTECA COMÚN ******************/
	
	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que no poseen asignada la clase garantía.*/ 
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
			'Clase de Garantía',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Clase_Garantia		IS NULL

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía inválida.*/
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
			'Clase de Garantía',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 1
		AND Codigo_Clase_Garantia		NOT BETWEEN 10 AND 17


	/************ CÉDULA HIPOTECARIA ******************/

	/*Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	  que no poseen asignada la clase garantía.*/
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
			'Clase de Garantía',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND Codigo_Clase_Garantia		IS NULL

	/*Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garantía inválida. */
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
			'Clase de Garantía',
			Codigo_Bien
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario				= @vsIdentificacion_Usuario
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
		AND Codigo_Tipo_Garantia_Real	= 2
		AND ((Codigo_Clase_Garantia		< 18)
			OR (Codigo_Clase_Garantia	> 18))


	/*INCONSISTENCIAS DEL CAMPO: TIPO DE BIEN*/
	
	/************ HIPOTECA COMÚN ******************/

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, pero el tipo de bien inválido. */
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


	/************ CÉDULA HIPOTECARIA ******************/

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, pero el tipo de bien inválido. */
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
	
	/************ HIPOTECA COMÚN ******************/

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien inválido y el tipo de mitigador 
      inválido. Los valores inválidos incluyen los nulos.*/
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


	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido y el tipo de mitigador 
      inválido, según el tipo de bien. Los valores inválidos incluyen los nulos.*/
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

	/************ CÉDULA HIPOTECARIA ******************/


	/*Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien inválido y el tipo de mitigador 
      inválido. Los valores inválidos incluyen los nulos.*/
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

	/*Se escoge la información de las garantías reales, de cédula hipotecaria, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido y el tipo de mitigador 
      inválido, según el tipo de bien. Los valores inválidos incluyen los nulos.*/
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
	
	/************ HIPOTECA COMÚN ******************/

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien inválido, el tipo de mitigador 
      inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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


	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
      inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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

	
	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
      válido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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


	/************ CÉDULA HIPOTECARIA ******************/

	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien inválido, el tipo de mitigador 
      inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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


	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
      inválido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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

	
	/*Se escoge la información de las garantías reales, de hipoteca común, asociadas a las operaciones 
	  que poseen asignada una clase garantía válida, el tipo de bien válido, el tipo de mitigador 
      válido y el tipo de documento legal inválido. Los valores inválidos incluyen los nulos.*/
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
	
	/************ HIPOTECA COMÚN ******************/

	/*Se escoge la información de las garantías reales asociadas a las operaciones 
	  que poseen el tipo de documento legal inválido y el grado de gravamen inválido, según el tipo 
      de documento legal (válido) que posea asociado la garantía. 
      Los valores inválidos incluyen los nulos.*/
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


	/************ CÉDULA HIPOTECARIA ******************/

	/*Se escoge la información de las garantías reales asociadas a las operaciones 
	  que poseen el tipo de documento legal inválido y el grado de gravamen inválido, según el tipo 
      de documento legal (válido) que posea asociado la garantía. 
      Los valores inválidos incluyen los nulos.*/
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

	/*Se escoge la información de las garantías reales asociadas a las operaciones 
	  que poseen los datos del avalúo, correspondientes a los montos del terreno mayores a cero y
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
	
	/*Se escoge la información de las garantías reales asociadas a las operaciones 
	  que poseen los datos del avalúo inválidos,según el tipo de bien que posea la garantía.*/
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
 *                            FIN DE LA SELECCIÓN DE INCONSISTENCIAS                            *
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
		'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
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
								'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE>' +
								'<DETALLE></DETALLE>' +
							'</RESPUESTA>'

	RETURN 0
END