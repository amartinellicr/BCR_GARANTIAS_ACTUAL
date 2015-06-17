USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Inconsistencias_Clase_Garantia_Real', 'P') IS NOT NULL
	DROP PROCEDURE Inconsistencias_Clase_Garantia_Real;
GO

CREATE PROCEDURE [dbo].[Inconsistencias_Clase_Garantia_Real]
	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Inconsistencias_Clase_Garantia_Real</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene las inconsistencias referente a la diferencia de código 
		de clase de garantía entre una misma garantía real.
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
	<Fecha>14/03/2014</Fecha>
	<Requerimiento>
		Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
		Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
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

	DECLARE	@TMP_INCONSISTENCIAS TABLE (
											Codigo_Partido							SMALLINT,
											Numero_Finca							VARCHAR (25)	COLLATE database_default,
											Clase_Bien								VARCHAR (3)		COLLATE database_default,
											Numero_Placa_Bien						VARCHAR (25)	COLLATE database_default,
											Clase_Garantia							SMALLINT		,
											Oficina									SMALLINT		,
											Moneda									TINYINT			,
											Producto								TINYINT			,
											Operacion								DECIMAL(7, 0)	,
											Contrato								DECIMAL(7, 0)	,
											Fecha_Valuacion_SICC					DATETIME		,
											Fecha_Valuacion							DATETIME		,
											Monto_Total_Avaluo						MONEY			,
											Monto_Mitigador_Riesgo					DECIMAL(18, 2)	,
											Tipo_Bien								SMALLINT		,
											Tipo_Mitigador_Riesgo					SMALLINT		,	
											Indicador_Inconsistencia				BIT				,		
											Usuario									VARCHAR(30)		COLLATE database_default 
										) --Almacenará la información de las inconsistencias obtenidas.


	DECLARE	@TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS TABLE (
															Codigo_Partido		SMALLINT,
															Numero_Finca		VARCHAR (25)	COLLATE database_default
														 )


	DECLARE	@TMP_GARANTIAS_PRENDARIAS_DUPLICADAS TABLE (
															Numero_Placa_Bien	VARCHAR (25)	COLLATE database_default
													   )



	DECLARE	@TMP_HIPOTECAS_DUPLICADAS TABLE (
												Consecutivo_Garantia_Real BIGINT
											)


	DECLARE	@TMP_PRENDAS_DUPLICADAS TABLE (
												Consecutivo_Garantia_Real BIGINT
										   )


	DECLARE @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS TABLE (
														Codigo_Partido							SMALLINT,
														Numero_Finca							VARCHAR (25)	COLLATE database_default,
														Clase_Garantia							SMALLINT		,
														Fecha_Valuacion							DATETIME		,
														Fecha_Avaluo_Igual_SICC					DATETIME		,
														Monto_Total_Avaluo						MONEY			,
														Consecutivo_Garantia_Real				BIGINT			,
														Usuario									VARCHAR(30)		COLLATE database_default 
													   ) --Almacenará la información de las garantías hipotecarias.


	DECLARE @TMP_GARANTIAS_PRENDARIAS_AVALUOS TABLE (
														Numero_Placa_Bien						VARCHAR (25)	COLLATE database_default,
														Clase_Garantia							SMALLINT		,
														Fecha_Valuacion							DATETIME		,
														Fecha_Avaluo_Igual_SICC					DATETIME		,
														Monto_Total_Avaluo						MONEY			,
														Consecutivo_Garantia_Real				BIGINT			,
														Usuario									VARCHAR(30)		COLLATE database_default 
													) --Almacenará la información de las garantías prendarias.




	DECLARE	@TMP_AVALUOS_COMUNES_HC TABLE (
											Codigo_Partido							SMALLINT,
											Numero_Finca							VARCHAR (25)	COLLATE database_default,
											Clase_Garantia							SMALLINT		,
											Fecha_Valuacion							DATETIME		,
											Monto_Total_Avaluo						MONEY			
										   ) --Almacenará la información de los avalúos de las garantías hipotecarias.
										   
										   
	DECLARE	@TMP_AVALUOS_COMUNES_P TABLE (
											Numero_Placa_Bien						VARCHAR (25)	COLLATE database_default,
											Clase_Garantia							SMALLINT		,
											Fecha_Valuacion							DATETIME		,
											Monto_Total_Avaluo						MONEY			
										   ) --Almacenará la información de los avalúos de las garantías prendarias.
									   	

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
	 *                        INICIO DEL FILTRADO DE LAS GARANTIAS REALES                           *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	--Se obtienen las garantías reales hipotecarias que se encuentran duplicadas
	INSERT INTO @TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS (
		Codigo_Partido,
		Numero_Finca)
	SELECT	DISTINCT
		cod_partido, 
		numero_finca
	FROM	dbo.GAR_GARANTIA_REAL
	GROUP BY cod_partido, numero_finca
	HAVING COUNT(*) > 1
	
	DELETE FROM @TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS
	WHERE Codigo_Partido IS NULL OR Numero_Finca IS NULL

	--Se obtienen las garantías reales prendarias que se encuentran duplicadas
	INSERT INTO @TMP_GARANTIAS_PRENDARIAS_DUPLICADAS (
		Numero_Placa_Bien)
	SELECT	DISTINCT 
		num_placa_bien
	FROM	dbo.GAR_GARANTIA_REAL
	GROUP BY num_placa_bien
	HAVING COUNT(*) > 1

	DELETE FROM @TMP_GARANTIAS_PRENDARIAS_DUPLICADAS
	WHERE Numero_Placa_Bien IS NULL

	--Se selecciona el consecutivo de aquellas fincas que se encuentran duplicadas y que poseen la clase de garantía diferente
	INSERT INTO @TMP_HIPOTECAS_DUPLICADAS (
		Consecutivo_Garantia_Real)
	SELECT	DISTINCT
		GGR.Codigo_Garantia_Real
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GGR
		INNER JOIN @TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS TMP
		ON TMP.Codigo_Partido = GGR.Codigo_Partido
		AND TMP.Numero_Finca  = GGR.Numero_Finca
	WHERE	EXISTS (SELECT	1
					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GG1
					WHERE	GG1.Codigo_Partido = TMP.Codigo_Partido
						AND	GG1.Numero_Finca = TMP.Numero_Finca
						AND (GG1.Codigo_Clase_Garantia < GGR.Codigo_Clase_Garantia
							OR GG1.Codigo_Clase_Garantia > GGR.Codigo_Clase_Garantia))


	--Se selecciona el consecutivo de aquellas prendas que se encuentran duplicadas y que poseen la clase de garantía diferente
	INSERT INTO @TMP_PRENDAS_DUPLICADAS (
		Consecutivo_Garantia_Real)
	SELECT	DISTINCT
		GGR.Codigo_Garantia_Real
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GGR
		INNER JOIN @TMP_GARANTIAS_PRENDARIAS_DUPLICADAS TMP
		ON TMP.Numero_Placa_Bien = GGR.Numero_Placa_Bien
	WHERE	EXISTS (SELECT	1
					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GG1
					WHERE	GG1.Numero_Placa_Bien = TMP.Numero_Placa_Bien
						AND (GG1.Codigo_Clase_Garantia < GGR.Codigo_Clase_Garantia
							OR GG1.Codigo_Clase_Garantia > GGR.Codigo_Clase_Garantia))


	/*Se obtienen todos los valúos que posee cada una de las garantías*/
	INSERT INTO @TMP_INCONSISTENCIAS (
		Codigo_Partido,
		Numero_Finca,
		Clase_Bien,
		Numero_Placa_Bien,
		Clase_Garantia,
		Oficina,
		Moneda,
		Producto,
		Operacion,
		Contrato,
		Fecha_Valuacion_SICC,
		Fecha_Valuacion,
		Monto_Total_Avaluo,
		Monto_Mitigador_Riesgo,
		Tipo_Bien,
		Tipo_Mitigador_Riesgo,
		Indicador_Inconsistencia,
		Usuario	
								 )
	SELECT	DISTINCT 
			TGR.Codigo_Partido,
			TGR.Numero_Finca,
			TGR.Codigo_Clase_Bien,
			TGR.Numero_Placa_Bien,
			TGR.Codigo_Clase_Garantia,
			TGR.Codigo_Oficina,
			TGR.Codigo_Moneda,
			TGR.Codigo_Producto,
			TGR.Operacion,
			NULL AS Contrato,
			NULL AS Fecha_Valuacion_SICC,
			NULL AS Fecha_Valuacion,
			NULL AS Monto_Total_Avaluo,
			TGR.Monto_Mitigador,
			ISNULL(TGR.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien,
			ISNULL(TGR.Codigo_Tipo_Mitigador, -1) AS Codigo_Tipo_Mitigador, 
			0 AS Indicador_Inconsistencia,
			TGR.Codigo_Usuario
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN @TMP_HIPOTECAS_DUPLICADAS GHD
		ON GHD.Consecutivo_Garantia_Real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario		= @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 1
		AND ((TGR.Codigo_Tipo_Garantia_Real = 1) 
			OR (TGR.Codigo_Tipo_Garantia_Real = 2))
	
	UNION ALL
	
	SELECT	DISTINCT 
			TGR.Codigo_Partido,
			TGR.Numero_Finca,
			TGR.Codigo_Clase_Bien,
			TGR.Numero_Placa_Bien,
			TGR.Codigo_Clase_Garantia,
			TGR.Codigo_Oficina,
			TGR.Codigo_Moneda,
			TGR.Codigo_Producto,
			NULL AS Operacion,
			TGR.Operacion AS Contrato,
			NULL AS Fecha_Valuacion_SICC,
			NULL AS Fecha_Valuacion,
			NULL AS Monto_Total_Avaluo,
			TGR.Monto_Mitigador,
			ISNULL(TGR.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien,
			ISNULL(TGR.Codigo_Tipo_Mitigador, -1) AS Codigo_Tipo_Mitigador, 
			0 AS Indicador_Inconsistencia,
			TGR.Codigo_Usuario
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN @TMP_HIPOTECAS_DUPLICADAS GHD
		ON GHD.Consecutivo_Garantia_Real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario		= @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 2
		AND ((TGR.Codigo_Tipo_Garantia_Real = 1) 
			OR (TGR.Codigo_Tipo_Garantia_Real = 2))

	UNION ALL
	
	SELECT	DISTINCT 
			TGR.Codigo_Partido,
			TGR.Numero_Finca,
			TGR.Codigo_Clase_Bien,
			TGR.Numero_Placa_Bien,
			TGR.Codigo_Clase_Garantia,
			TGR.Codigo_Oficina,
			TGR.Codigo_Moneda,
			TGR.Codigo_Producto,
			TGR.Operacion AS Operacion,
			NULL AS Contrato,
			NULL AS Fecha_Valuacion_SICC,
			NULL AS Fecha_Valuacion,
			NULL AS Monto_Total_Avaluo,
			TGR.Monto_Mitigador,
			ISNULL(TGR.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien,
			ISNULL(TGR.Codigo_Tipo_Mitigador, -1) AS Codigo_Tipo_Mitigador, 
			0 AS Indicador_Inconsistencia,
			TGR.Codigo_Usuario
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN @TMP_PRENDAS_DUPLICADAS GPD
		ON GPD.Consecutivo_Garantia_Real		= TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario		= @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 1
		AND TGR.Codigo_Tipo_Garantia_Real = 3 
	
	UNION ALL
	
	SELECT	DISTINCT 
			TGR.Codigo_Partido,
			TGR.Numero_Finca,
			TGR.Codigo_Clase_Bien,
			TGR.Numero_Placa_Bien,
			TGR.Codigo_Clase_Garantia,
			TGR.Codigo_Oficina,
			TGR.Codigo_Moneda,
			TGR.Codigo_Producto,
			NULL AS Operacion,
			TGR.Operacion AS Contrato,
			NULL AS Fecha_Valuacion_SICC,
			NULL AS Fecha_Valuacion,
			NULL AS Monto_Total_Avaluo,
			TGR.Monto_Mitigador,
			ISNULL(TGR.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien,
			ISNULL(TGR.Codigo_Tipo_Mitigador, -1) AS Codigo_Tipo_Mitigador, 
			0 AS Indicador_Inconsistencia,
			TGR.Codigo_Usuario
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN @TMP_PRENDAS_DUPLICADAS GPD
		ON GPD.Consecutivo_Garantia_Real		= TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario		= @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 2
		AND TGR.Codigo_Tipo_Garantia_Real = 3 
	ORDER BY TGR.Codigo_Partido, TGR.Numero_Finca, TGR.Numero_Placa_Bien



	--Se establece el indicador de inconsistencia en 1 si la una misma finca posee clases diferentes
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Indicador_Inconsistencia = 1
	FROM	@TMP_INCONSISTENCIAS TM1
	WHERE	EXISTS (SELECT	1
					FROM	@TMP_INCONSISTENCIAS TM2
					WHERE	TM2.Codigo_Partido	= TM1.Codigo_Partido
						AND TM2.Numero_Finca	= TM1.Numero_Finca
						AND (TM2.Clase_Garantia	< TM1.Clase_Garantia
							OR TM2.Clase_Garantia > TM1.Clase_Garantia))
	
	--Se establece el indicador de inconsistencia en 1 si la una misma prenda posee clases diferentes
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Indicador_Inconsistencia = 1
	FROM	@TMP_INCONSISTENCIAS TM1
	WHERE	EXISTS (SELECT	1
					FROM	@TMP_INCONSISTENCIAS TM2
					WHERE	TM2.Numero_Placa_Bien	= TM1.Numero_Placa_Bien
						AND (TM2.Clase_Garantia	< TM1.Clase_Garantia
							OR TM2.Clase_Garantia > TM1.Clase_Garantia))
	
	--Se eliminan aquellos registros que no presnetan inconsistencias
	DELETE	FROM @TMP_INCONSISTENCIAS
	WHERE	Indicador_Inconsistencia = 0
	
								   
	--Se obtiene la información de los avalúos asociados a una misma finca
	INSERT INTO @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS (
		Codigo_Partido,
		Numero_Finca,
		Clase_Garantia,
		Fecha_Valuacion,
		Fecha_Avaluo_Igual_SICC,
		Monto_Total_Avaluo,
		Consecutivo_Garantia_Real,
		Usuario)
	SELECT	DISTINCT 
		TMP.Codigo_Partido,
		TMP.Numero_Finca,
		TMP.Clase_Garantia,
		NULL AS Fecha_Valuacion,
		NULL AS Fecha_Avaluo_Igual_SICC,
		NULL AS Monto_Total_Avaluo,
		GR2.cod_garantia_real,
		TMP.Usuario
	FROM	@TMP_INCONSISTENCIAS TMP
	INNER JOIN (SELECT	GR1.cod_clase_garantia, 
						GR1.cod_partido, 
						GR1.numero_finca, 
						GGR.cod_garantia_real
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN	(	SELECT	cod_clase_garantia, 
										cod_partido, 
										numero_finca
									FROM	dbo.GAR_GARANTIA_REAL 
									WHERE	cod_clase_garantia BETWEEN 10 AND 29
									GROUP	BY cod_clase_garantia, cod_partido, numero_finca) GR1
					ON	GR1.cod_clase_garantia = GGR.cod_clase_garantia
					AND GR1.cod_partido = GGR.cod_partido
					AND GR1.numero_finca = GGR.numero_finca) GR2
	ON GR2.cod_clase_garantia	= TMP.Clase_Garantia
	AND GR2.cod_partido			= TMP.Codigo_Partido
	AND GR2.numero_finca		= TMP.Numero_Finca
	
	
	--Se obtienen los avalúos que poseen registradas las fincas
	INSERT INTO @TMP_AVALUOS_COMUNES_HC (
		Codigo_Partido,
		Numero_Finca,
		Clase_Garantia,
		Fecha_Valuacion,
		Monto_Total_Avaluo)
	SELECT	DISTINCT 
		GHA.Codigo_Partido, 
		GHA.Numero_Finca,
		GHA.Clase_Garantia, 
		ISNULL(GVR.fecha_valuacion, '19000101') AS Fecha_Valuacion,
		ISNULL(GVR.monto_total_avaluo, 0) AS Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GHA.Consecutivo_Garantia_Real
		
	--Se obtiene la fecha de valuación más reicente para una misma finca
	UPDATE	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS
	SET		Fecha_Valuacion = ACH.Fecha_Valuacion
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		INNER JOIN (SELECT	MAX(Fecha_Valuacion) AS Fecha_Valuacion,
						Codigo_Partido, 
						Numero_Finca,
						Clase_Garantia
					FROM	@TMP_AVALUOS_COMUNES_HC 
					GROUP	BY Codigo_Partido, Numero_Finca, Clase_Garantia) ACH
		ON ACH.Codigo_Partido	= GHA.Codigo_Partido
		AND ACH.Numero_Finca	= GHA.Numero_Finca
		AND ACH.Clase_Garantia	= GHA.Clase_Garantia
	
	--Se obtiene la fecha de avalúo que sea igual a la registrada en el SICC, esto para uina misma finca
	UPDATE	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS
	SET		Fecha_Avaluo_Igual_SICC = GVR.Fecha_Valuacion
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		INNER JOIN	@TMP_AVALUOS_COMUNES_HC GVR
		ON GVR.Clase_Garantia	= GHA.Clase_Garantia
		AND GVR.Codigo_Partido	= GHA.Codigo_Partido
		AND GVR.Numero_Finca	= GHA.Numero_Finca
	WHERE	EXISTS (SELECT	1
					FROM	dbo.VALUACIONES_GARANTIAS_REALES_SICC_VW VGR
					WHERE	VGR.cod_clase_garantia BETWEEN 10 AND 29
						AND VGR.cod_partido IS NOT NULL
						AND VGR.cod_clase_garantia		= GHA.Clase_Garantia
						AND VGR.cod_partido				= GHA.Codigo_Partido
						AND VGR.Identificacion_Garantia = GHA.Numero_Finca
						AND CONVERT(DATETIME, VGR.fecha_valuacion) = GVR.Fecha_Valuacion)
	
	--Se obtiene el monto total del avalúo registrado para una misma finca
	UPDATE	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS
	SET		Monto_Total_Avaluo = GVR.Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		INNER JOIN	@TMP_AVALUOS_COMUNES_HC GVR
		ON GVR.Clase_Garantia	= GHA.Clase_Garantia
		AND GVR.Codigo_Partido	= GHA.Codigo_Partido
		AND GVR.Numero_Finca	= GHA.Numero_Finca
	WHERE	GHA.Fecha_Valuacion = GVR.Fecha_Valuacion
	
	--Se obtiene el monto total del avalúo registrado para una misma finca, cuando la fecha de valuación es igual a la del SICC
	UPDATE	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS
	SET		Monto_Total_Avaluo = GVR.Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		INNER JOIN	@TMP_AVALUOS_COMUNES_HC GVR
		ON GVR.Clase_Garantia			= GHA.Clase_Garantia
		AND GVR.Codigo_Partido			= GHA.Codigo_Partido
		AND GVR.Numero_Finca			= GHA.Numero_Finca
	WHERE	GHA.Fecha_Avaluo_Igual_SICC = GVR.Fecha_Valuacion
	
	--Se obtiene la información de los avalúos asociados a una misma prenda
	INSERT INTO @TMP_GARANTIAS_PRENDARIAS_AVALUOS (
		Numero_Placa_Bien,
		Clase_Garantia,
		Fecha_Valuacion,
		Fecha_Avaluo_Igual_SICC,
		Monto_Total_Avaluo,
		Consecutivo_Garantia_Real,
		Usuario)
	SELECT	DISTINCT 
		TMP.Numero_Placa_Bien,
		TMP.Clase_Garantia,
		NULL AS Fecha_Valuacion,
		NULL AS Fecha_Avaluo_Igual_SICC,
		NULL AS Monto_Total_Avaluo,
		GR2.cod_garantia_real,
		TMP.Usuario
	FROM	@TMP_INCONSISTENCIAS TMP
		INNER JOIN (SELECT	GR1.cod_clase_garantia, 
						GR1.num_placa_bien, 
						GGR.cod_garantia_real
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN	(	SELECT	cod_clase_garantia, 
											num_placa_bien
										FROM	dbo.GAR_GARANTIA_REAL 
										WHERE	cod_clase_garantia BETWEEN 30 AND 69
										GROUP	BY cod_clase_garantia, num_placa_bien) GR1
						ON	GR1.cod_clase_garantia = GGR.cod_clase_garantia
						AND GR1.num_placa_bien = GGR.num_placa_bien) GR2
		ON GR2.cod_clase_garantia	= TMP.Clase_Garantia
		AND GR2.num_placa_bien		= TMP.Numero_Placa_Bien
	
	--Se obtienen todos los avalúos registrados para las prendas
	INSERT INTO @TMP_AVALUOS_COMUNES_P (
		Numero_Placa_Bien,
		Clase_Garantia,
		Fecha_Valuacion,
		Monto_Total_Avaluo)
	SELECT	DISTINCT 
		GPA.Numero_Placa_Bien, 
		GPA.Clase_Garantia, 
		ISNULL(GVR.fecha_valuacion, '19000101') AS Fecha_Valuacion,
		ISNULL(GVR.monto_total_avaluo, 0) AS Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GPA.Consecutivo_Garantia_Real
	
	--Se obtiene la fecha de valuación más reicente registrada para una misma prenda
	UPDATE	@TMP_GARANTIAS_PRENDARIAS_AVALUOS
	SET		Fecha_Valuacion = ACH.Fecha_Valuacion
	FROM	@TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		INNER JOIN (SELECT	MAX(Fecha_Valuacion) AS Fecha_Valuacion,
						Numero_Placa_Bien,
						Clase_Garantia
					FROM	@TMP_AVALUOS_COMUNES_P 
					GROUP	BY Numero_Placa_Bien, Clase_Garantia) ACH
		ON ACH.Numero_Placa_Bien	= GPA.Numero_Placa_Bien
		AND ACH.Clase_Garantia		= GPA.Clase_Garantia

	--Se obtiene la fecha de valuación que es igual a la registrada en el SICC, esto para una misma prenda
	UPDATE	@TMP_GARANTIAS_PRENDARIAS_AVALUOS
	SET		Fecha_Avaluo_Igual_SICC = GVR.Fecha_Valuacion
	FROM	@TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		INNER JOIN	@TMP_AVALUOS_COMUNES_P GVR
		ON GVR.Clase_Garantia		= GPA.Clase_Garantia
		AND GVR.Numero_Placa_Bien	= GPA.Numero_Placa_Bien
	WHERE	EXISTS (SELECT	1
					FROM	dbo.VALUACIONES_GARANTIAS_REALES_SICC_VW VGR
					WHERE	VGR.cod_clase_garantia BETWEEN 30 AND 69
						AND VGR.cod_clase_garantia		= GPA.Clase_Garantia
						AND VGR.Identificacion_Garantia = GPA.Numero_Placa_Bien	
						AND CONVERT(DATETIME, VGR.fecha_valuacion) = GVR.Fecha_Valuacion)

	--Se obtiene el monto total del avalúo registrado para la fecha más reciente, esto para una misma prenda
	UPDATE	@TMP_GARANTIAS_PRENDARIAS_AVALUOS
	SET		Monto_Total_Avaluo = GVR.Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		INNER JOIN	@TMP_AVALUOS_COMUNES_P GVR
		ON GVR.Clase_Garantia		= GPA.Clase_Garantia
		AND GVR.Numero_Placa_Bien	= GPA.Numero_Placa_Bien
	WHERE	GPA.Fecha_Valuacion		= GVR.Fecha_Valuacion

	--Se obtiene el monto total del avalúo de la fecha registrada en el SICC, esto para una misma prenda
	UPDATE	@TMP_GARANTIAS_PRENDARIAS_AVALUOS
	SET		Monto_Total_Avaluo = GVR.Monto_Total_Avaluo
	FROM	@TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		INNER JOIN	@TMP_AVALUOS_COMUNES_P GVR
		ON GVR.Clase_Garantia				= GPA.Clase_Garantia
		AND GVR.Numero_Placa_Bien			= GPA.Numero_Placa_Bien
	WHERE	GPA.Fecha_Avaluo_Igual_SICC		= GVR.Fecha_Valuacion

	--Se actualizan los datos de la estructura de las inconsistencias, esto para las fincas
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion			= CASE 
										WHEN GHA.Fecha_Avaluo_Igual_SICC = '19000101' THEN GHA.Fecha_Valuacion
										ELSE GHA.Fecha_Avaluo_Igual_SICC
									  END,
			Monto_Total_Avaluo		= GHA.Monto_Total_Avaluo
	FROM	@TMP_INCONSISTENCIAS TMP
		INNER JOIN @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS GHA
		ON GHA.Clase_Garantia	= TMP.Clase_Garantia
		AND GHA.Codigo_Partido	= TMP.Codigo_Partido
		AND GHA.Numero_Finca	= TMP.Numero_Finca
	WHERE	TMP.Clase_Garantia BETWEEN 10 AND 29
	
	--Se actualizan los datos de la estructura de las inconsistencias, esto para las prendas
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion			= CASE 
										WHEN GPA.Fecha_Avaluo_Igual_SICC = '19000101' THEN GPA.Fecha_Valuacion
										ELSE GPA.Fecha_Avaluo_Igual_SICC
									  END,
			Monto_Total_Avaluo		= GPA.Monto_Total_Avaluo
	FROM	@TMP_INCONSISTENCIAS TMP
		INNER JOIN @TMP_GARANTIAS_PRENDARIAS_AVALUOS GPA
		ON GPA.Clase_Garantia		= TMP.Clase_Garantia
		AND GPA.Numero_Placa_Bien	= TMP.Numero_Placa_Bien
	WHERE	TMP.Clase_Garantia BETWEEN 30 AND 69
		
	--Se actualizan los datos de la estructura de las inconsistencias
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion_SICC = CONVERT(DATETIME, VGR.fecha_valuacion)
	FROM	@TMP_INCONSISTENCIAS TMP
		INNER JOIN dbo.VALUACIONES_GARANTIAS_REALES_SICC_VW VGR
		ON VGR.cod_clase_garantia		= TMP.Clase_Garantia
		AND VGR.cod_partido				= TMP.Codigo_Partido
		AND VGR.Identificacion_Garantia = TMP.Numero_Finca
	WHERE	TMP.Clase_Garantia BETWEEN 10 AND 29
		AND VGR.cod_clase_garantia BETWEEN 10 AND 29
		AND VGR.cod_partido IS NOT NULL
	
	--Se actualizan los datos de la estructura de las inconsistencias
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion_SICC = CONVERT(DATETIME, VGR.fecha_valuacion)
	FROM	@TMP_INCONSISTENCIAS TMP
		INNER JOIN dbo.VALUACIONES_GARANTIAS_REALES_SICC_VW VGR
		ON VGR.cod_clase_garantia		= TMP.Clase_Garantia
		AND VGR.cod_clase_bien			= ISNULL(TMP.Clase_Bien, '')
		AND VGR.Identificacion_Garantia = TMP.Numero_Placa_Bien
	WHERE	TMP.Clase_Garantia BETWEEN 30 AND 69
		AND VGR.cod_clase_garantia BETWEEN 30 AND 69

	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion_SICC = NULL
	WHERE	Fecha_Valuacion_SICC = '19000101'
	
	UPDATE	@TMP_INCONSISTENCIAS
	SET		Fecha_Valuacion = NULL
	WHERE	Fecha_Valuacion = '19000101'
	
	/************************************************************************************************
	 *                                                                                              * 
	 *						FIN DEL FILTRADO DE LAS GARANTIAS REALES                                *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/


	SELECT 	DISTINCT	
		1							AS Tag,
		NULL						AS Parent,
		'0'							AS [RESPUESTA!1!CODIGO!element], 
		NULL						AS [RESPUESTA!1!NIVEL!element], 
		NULL						AS [RESPUESTA!1!ESTADO!element], 
		'Inconsistencias_Clase_Garantia_Real'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
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
		(
		Numero_Finca 													+ CHAR(9) + 
		CONVERT(VARCHAR(5), Codigo_Partido) 							+ CHAR(9) + 
		Clase_Bien 														+ CHAR(9) + 
		Numero_Placa_Bien 												+ CHAR(9) + 
		ISNULL(CONVERT(VARCHAR(5), Clase_Garantia), '')					+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(5), Oficina), '')      					+ CHAR(9) + 
 		ISNULL(CONVERT(VARCHAR(5), Moneda), '')	   						+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(5), Producto), '')	   					+ CHAR(9) + 
 		ISNULL(CONVERT(VARCHAR(20), Operacion), '')   					+ CHAR(9) + 
 		ISNULL(CONVERT(VARCHAR(20), Contrato), '')  					+ CHAR(9) + 
		ISNULL(CONVERT(VARCHAR(10), Fecha_Valuacion_SICC, 105), '')		+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(10), Fecha_Valuacion, 105), '')			+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(100), Monto_Total_Avaluo), '')			+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(100), Monto_Mitigador_Riesgo), '')		+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(5), Tipo_Bien), '')						+ CHAR(9) +
		ISNULL(CONVERT(VARCHAR(5), Tipo_Mitigador_Riesgo), '')			+ CHAR(9)) AS [Inconsistencia!3!DATOS!element],
		Usuario									AS [Inconsistencia!3!Usuario!hide]
	FROM	@TMP_INCONSISTENCIAS 
	WHERE	Usuario	=  @vsIdentificacion_Usuario
	FOR	XML EXPLICIT

	SET	@psRespuesta = N'<RESPUESTA>' +
					'<CODIGO>0</CODIGO>' + 
					'<NIVEL></NIVEL>' +
					'<ESTADO></ESTADO>' +
					'<PROCEDIMIENTO>Inconsistencias_Clase_Garantia_Real</PROCEDIMIENTO>' +
					'<LINEA></LINEA>' + 
				       '<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE>' +
					'<DETALLE></DETALLE>' +
				'</RESPUESTA>'
	RETURN 0
END