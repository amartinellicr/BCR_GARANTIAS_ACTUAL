USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Inconsistencias_Polizas_Garantias_Reales', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Inconsistencias_Polizas_Garantias_Reales;
GO

CREATE PROCEDURE [dbo].[Inconsistencias_Polizas_Garantias_Reales]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>Inconsistencias_Polizas_Garantias_Reales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las inconsistencias referentes a las pólizas.
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
	<Fecha>18/06/2014</Fecha>
	<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
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

		-- Declaración de variables
	DECLARE		@vdtFecha_Actual DATETIME, --Fecha actual del sistema
				@viEjecucion_Exitosa INT, --Valor de retorno producto de la ejecución de un procedimiento almacenado.
				@vsIdentificacion_Usuario VARCHAR(30) --Identificación del usuario que ejecuta el proceso.

	--Inicialización de variables
	SET	@vdtFecha_Actual = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET @vsIdentificacion_Usuario = @psCedula_Usuario

	/*Se declaran estas estrucutras debido con el fin de disminuir el tiempo de respuesta del procedimiento
	    almacenado */

	DECLARE @TMP_INCONSISTENCIAS TABLE (
											Contabilidad				TINYINT			,
											Oficina						SMALLINT		,
											Moneda						TINYINT			,
											Producto					TINYINT			,
											Operacion					DECIMAL(7)		,
											Contrato					DECIMAL(7)		,
											Tipo_Garantia_Real			TINYINT			,
											Tipo_Bien					SMALLINT		,
											Garantia_Real				VARCHAR(30)		COLLATE database_default ,
											Clase_Garantia				SMALLINT		,
											Monto_Total_Avaluo			MONEY    		,
											Codigo_Sap					NUMERIC(8,0)	,
											Cedula_Acreedor				VARCHAR(30)		COLLATE database_default, 
											Nombre_Acreedor				VARCHAR(60)		COLLATE database_default, 
											Monto_Poliza				NUMERIC(16,2)	,
											Fecha_Vencimiento			DATETIME		,
											Tipo_Inconsistencia			VARCHAR(100)	COLLATE database_default 
										)


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


	DECLARE	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TABLE (
																	Consecutivo_Garantia_Real	BIGINT,
																	Clase_Garantia				SMALLINT,
																	Codigo_Partido				SMALLINT,
																	Numero_Finca				VARCHAR (25) COLLATE database_default,
																	Monto_Tasacion_No_Terreno MONEY
															   )


	DECLARE	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TABLE (
																Consecutivo_Garantia_Real	BIGINT,
																Clase_Garantia				SMALLINT,
																Numero_Placa_Bien			VARCHAR (25) COLLATE database_default,
																Monto_Tasacion_No_Terreno MONEY
															   )


	/************************************************************************************************
	 *                                                                                              * 
	 *		     INICIO DEL FILTRADO DE LAS GARANTIAS REALES										*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	--Se ejecuta el procedimiento almacenado que obtiene las garantías a ser valoradas
	EXEC	@viEjecucion_Exitosa = [dbo].[Obtener_Garantias_Reales_A_Validar]
					@psCedula_Usuario = @vsIdentificacion_Usuario

	--Se evalúa el resultado obtenido de la ejecución del procedimiento almacenado
	IF(@viEjecucion_Exitosa <> 0)
	BEGIN
		SET	@psRespuesta = N'<RESPUESTA>' +
						'<CODIGO>-1</CODIGO>' + 
						'<NIVEL></NIVEL>' +
						'<ESTADO></ESTADO>' +
						'<PROCEDIMIENTO>Inconsistencias_Polizas_Garantias_Reales</PROCEDIMIENTO>' +
						'<LINEA></LINEA>' + 
						'<MENSAJE>Se produjo un error al obtener las inconsistencias de las pólizas.</MENSAJE>' +
						'<DETALLE>El problema se produjo al ejecutar el procedimiento almacenado "Obtener_Garantias_Reales_A_Validar",' + 
                        ' que obtiene las garantías a ser valoradas.' +
   						'</DETALLE>' +
					'</RESPUESTA>'

		RETURN -1
	END
	/************************************************************************************************
	 *                                                                                              * 
	 *		      FIN DEL FILTRADO DE LAS GARANTIAS REALES 					                        *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *		     INICIO DEL FILTRADO DE LAS GARANTIAS REALES DUPLICADAS CON CLASE DIFERENTE         *
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
	GROUP	BY cod_partido, numero_finca
	HAVING	COUNT(*) > 1
	
	DELETE FROM @TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS
	WHERE Codigo_Partido IS NULL OR Numero_Finca IS NULL

	--Se obtienen las garantías reales prendarias que se encuentran duplicadas
	INSERT INTO @TMP_GARANTIAS_PRENDARIAS_DUPLICADAS (
		Numero_Placa_Bien)
	SELECT	DISTINCT 
		num_placa_bien
	FROM	dbo.GAR_GARANTIA_REAL
	GROUP	BY num_placa_bien
	HAVING	COUNT(*) > 1

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
	WHERE	GGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GGR.Codigo_Tipo_Operacion IN (1, 2)
		AND GGR.Codigo_Tipo_Garantia_Real IN (1 ,2)
		AND EXISTS (SELECT	1
					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GG1
					WHERE	GG1.Codigo_Usuario = GGR.Codigo_Usuario
						AND GG1.Codigo_Tipo_Operacion IN (1, 2)
						AND GG1.Codigo_Tipo_Garantia_Real IN (1 ,2)
						AND GG1.Codigo_Partido = TMP.Codigo_Partido
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
	WHERE	GGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GGR.Codigo_Tipo_Operacion IN (1, 2)
		AND GGR.Codigo_Tipo_Garantia_Real = 3
		AND EXISTS (SELECT	1
					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GG1
					WHERE	GG1.Codigo_Usuario = GGR.Codigo_Usuario
						AND GG1.Codigo_Tipo_Operacion IN (1, 2)
						AND GG1.Codigo_Tipo_Garantia_Real = 3
						AND GG1.Numero_Placa_Bien = TMP.Numero_Placa_Bien
						AND (GG1.Codigo_Clase_Garantia < GGR.Codigo_Clase_Garantia
							OR GG1.Codigo_Clase_Garantia > GGR.Codigo_Clase_Garantia))

	/************************************************************************************************
	 *                                                                                              * 
	 *		     FIN DEL FILTRADO DE LAS GARANTIAS REALES DUPLICADAS CON CLASE DIFERENTE            *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *		     INICIO DEL FILTRADO DE LAS GARANTIAS REALES DUPLICADAS CON AVALUO DIFERENTE        *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
	--Se evalúan las garantías hipotecarias
	INSERT	INTO @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES (Consecutivo_Garantia_Real, Clase_Garantia, Codigo_Partido, Numero_Finca, Monto_Tasacion_No_Terreno)
	SELECT	DISTINCT
		TGR.Codigo_Garantia_Real, 
		TGR.Codigo_Clase_Garantia, 
		TGR.Codigo_Partido, 
		TGR.Numero_Finca, 
		ISNULL(GVR.monto_ultima_tasacion_no_terreno, 0) AS Monto_Tasacion_No_Terreno
	FROM (
			SELECT	DISTINCT
				cod_partido, 
				numero_finca,
				cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_REAL
			WHERE	cod_clase_garantia BETWEEN 10 AND 29
			GROUP	BY cod_partido, numero_finca, cod_clase_garantia
			HAVING	COUNT(*) > 1
		) TMP
		INNER JOIN dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		ON TGR.Codigo_Partido = TMP.cod_partido
		AND TGR.Numero_Finca = TMP.numero_finca
		AND TGR.Codigo_Clase_Garantia = TMP.cod_clase_garantia
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GVR.Indicador_Tipo_Registro = 1

	UNION ALL
	
	SELECT	DISTINCT
		TGR.Codigo_Garantia_Real, 
		TGR.Codigo_Clase_Garantia, 
		TGR.Codigo_Partido, 
		TGR.Numero_Finca, 
		ISNULL(GVR.monto_ultima_tasacion_no_terreno, 0) AS Monto_Tasacion_No_Terreno
	FROM (
			SELECT	DISTINCT
				cod_partido, 
				numero_finca,
				cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_REAL
			WHERE	cod_clase_garantia BETWEEN 10 AND 29
			GROUP	BY cod_partido, numero_finca, cod_clase_garantia
			HAVING	COUNT(*) > 1
		) TMP
		INNER JOIN dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		ON TGR.Codigo_Partido = TMP.cod_partido
		AND TGR.Numero_Finca = TMP.numero_finca
		AND TGR.Codigo_Clase_Garantia = TMP.cod_clase_garantia
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GVR.Indicador_Tipo_Registro = 2
		AND GVR.Indicador_Tipo_Registro = (	SELECT	MIN(GV1.Indicador_Tipo_Registro)
											FROM	dbo.GAR_VALUACIONES_REALES GV1
											WHERE	GV1.cod_garantia_real = GVR.cod_garantia_real
												AND GV1.Indicador_Tipo_Registro BETWEEN 1 AND 2)


	
	--DELETE	FROM @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES
	--FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TMP
	--WHERE NOT EXISTS (	SELECT	1
	--					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
	--					WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
	--						AND TGR.Codigo_Tipo_Operacion IN (1, 2)
	--						AND TGR.Codigo_Tipo_Garantia_Real IN (1 ,2)
	--						AND TGR.Codigo_Clase_Garantia = TMP.Clase_Garantia
	--						AND TGR.Codigo_Partido = TMP.Codigo_Partido
	--						AND TGR.Numero_Finca = TMP.Numero_Finca)
	--						--AND TGR.Codigo_Garantia_Real = TMP.Consecutivo_Garantia_Real)
	
	
	DELETE	FROM @TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES
	FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TM1
	WHERE	NOT EXISTS (SELECT	1
						FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TM2
						WHERE	TM2.Clase_Garantia = TM1.Clase_Garantia
							AND TM2.Codigo_Partido = TM1.Codigo_Partido
							AND TM2.Numero_Finca = TM1.Numero_Finca
							AND ((TM2.Monto_Tasacion_No_Terreno < TM1.Monto_Tasacion_No_Terreno)
								OR (TM2.Monto_Tasacion_No_Terreno > TM1.Monto_Tasacion_No_Terreno)))
						

	--Se evalúan las garantías prendarias
	INSERT	INTO @TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES (Consecutivo_Garantia_Real, Clase_Garantia, Numero_Placa_Bien, Monto_Tasacion_No_Terreno)
	SELECT	DISTINCT
		TGR.Codigo_Garantia_Real, 
		TGR.Codigo_Clase_Garantia, 
		TGR.Numero_Placa_Bien, 
		ISNULL(GVR.monto_ultima_tasacion_no_terreno, 0) AS Monto_Tasacion_No_Terreno
	FROM (
			SELECT	DISTINCT
				num_placa_bien,
				cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_REAL
			WHERE	cod_clase_garantia BETWEEN 30 AND 69
			GROUP	BY num_placa_bien, cod_clase_garantia
			HAVING	COUNT(*) > 1
		) TMP
		INNER JOIN dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		ON TGR.Numero_Placa_Bien = TMP.num_placa_bien
		AND TGR.Codigo_Clase_Garantia = TMP.cod_clase_garantia
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GVR.Indicador_Tipo_Registro = 1

	UNION ALL
	
	SELECT	DISTINCT
		TGR.Codigo_Garantia_Real, 
		TGR.Codigo_Clase_Garantia, 
		TGR.Numero_Placa_Bien, 
		ISNULL(GVR.monto_ultima_tasacion_no_terreno, 0) AS Monto_Tasacion_No_Terreno
	FROM (
			SELECT	DISTINCT
				num_placa_bien,
				cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_REAL
			WHERE	cod_clase_garantia BETWEEN 30 AND 69
			GROUP	BY num_placa_bien, cod_clase_garantia
			HAVING	COUNT(*) > 1
		) TMP
		INNER JOIN dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		ON TGR.Numero_Placa_Bien = TMP.num_placa_bien
		AND TGR.Codigo_Clase_Garantia = TMP.cod_clase_garantia
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND GVR.Indicador_Tipo_Registro = 2
		AND GVR.Indicador_Tipo_Registro = (	SELECT	MIN(GV1.Indicador_Tipo_Registro)
											FROM	dbo.GAR_VALUACIONES_REALES GV1
											WHERE	GV1.cod_garantia_real = GVR.cod_garantia_real
												AND GV1.Indicador_Tipo_Registro BETWEEN 1 AND 2)


	
	--DELETE	FROM @TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES
	--FROM	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TMP
	--WHERE NOT EXISTS (	SELECT	1
	--					FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
	--					WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
	--						AND TGR.Codigo_Tipo_Operacion IN (1, 2)
	--						AND TGR.Codigo_Tipo_Garantia_Real = 3
	--						AND TGR.Codigo_Clase_Garantia = TMP.Clase_Garantia
	--						AND TGR.Numero_Placa_Bien = TMP.Numero_Placa_Bien)
	--						--AND TGR.Codigo_Garantia_Real = TMP.Consecutivo_Garantia_Real)
	
	
	DELETE	FROM @TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES
	FROM	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TM1
	WHERE	NOT EXISTS (SELECT	1
						FROM	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TM2
						WHERE	TM2.Clase_Garantia = TM1.Clase_Garantia
							AND TM2.Numero_Placa_Bien = TM1.Numero_Placa_Bien
							AND ((TM2.Monto_Tasacion_No_Terreno < TM1.Monto_Tasacion_No_Terreno)
								OR (TM2.Monto_Tasacion_No_Terreno > TM1.Monto_Tasacion_No_Terreno)))
						

	/************************************************************************************************
	 *                                                                                              * 
	 *		     FIN DEL FILTRADO DE LAS GARANTIAS REALES DUPLICADAS CON AVALUO DIFERENTE           *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/*INCONSISTENCIAS DE GARANTIAS SIN SEGURO*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen asignado un seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantía sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.cod_operacion = GRO.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 1
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)


	--Se escoge la información de las garantías reales asociadas a los contratos 
	--que no poseen asignado un seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantía sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.cod_operacion = GRO.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 1
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)



	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen asignado un seguro debido a que el mismo posee un estado inválido. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantía sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 0
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)


	--Se escoge la información de las garantías reales asociadas a los contratos 
	--que no poseen asignado un seguro debido a que el mismo posee un estado inválido. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real,
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantía sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 0
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)


	/*INCONSISTENCIAS DE LAS GARANTIAS SIN COBERTURA EN VALOR REAL EFECTIVO*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen una cobertura real. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías sin cobertura en valor real efectivo'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND GVR.monto_ultima_tasacion_no_terreno > CONVERT(MONEY, GPO.Monto_Poliza_Colonizado)


	--Se escoge la información de las garantías reales asociadas a los contratos 
	--que no poseen una cobertura real. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías sin cobertura en valor real efectivo'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND GVR.monto_ultima_tasacion_no_terreno > CONVERT(MONEY, GPO.Monto_Poliza_Colonizado)
	


	/*INCONSISTENCIAS DE LAS GARANTIAS CON SEGURO VENCIDO*/
	
	--Se escoge la información de las garantías reales asociadas a las operaciones 
	--que no poseen un seguro vigente. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías con SAP vencido'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND COALESCE(GPO.Fecha_Vencimiento, '19000101') < @vdtFecha_Actual


	--Se escoge la información de las garantías reales asociadas a los contratos 
	--que no poseen un seguro vigente. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías con SAP vencido'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND COALESCE(GPO.Fecha_Vencimiento, '19000101') < @vdtFecha_Actual



	/*INCONSISTENCIAS DE LAS POLIZAS CON ACREEDOR INVALIDO*/
	
	--Se escoge la información de las pólizas que poseen el acreedor inválido. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías con Acreedor incorrecto'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND GPO.Cedula_Acreedor <> '4000000019'


	--Se escoge la información de las pólizas que poseen el acreedor inválido. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Garantías con Acreedor incorrecto'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND GPO.Cedula_Acreedor <> '4000000019'


	/*INCONSISTENCIAS DE LAS GARANTIAS SIMILARES SIN RELACION DE SAP*/

	--Se escoge la información de las garantías hipotecarias similares, con diferente código 
	--clase de garantía, pero que no poseen seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantías similares sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN @TMP_HIPOTECAS_DUPLICADAS THD
		ON THD.Consecutivo_Garantia_Real = GRO.cod_garantia_real
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)

	--Se escoge la información de las garantías prendarias similares, con diferente código 
	--clase de garantía, pero que no poseen seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantías similares sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN @TMP_PRENDAS_DUPLICADAS TPD
		ON TPD.Consecutivo_Garantia_Real = GRO.cod_garantia_real
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)

	--Se escoge la información de las garantías hipotecarias similares, con diferente código 
	--clase de garantía, pero que no poseen seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantías similares sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN @TMP_HIPOTECAS_DUPLICADAS THD
		ON THD.Consecutivo_Garantia_Real = GRO.cod_garantia_real
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)
		
	--Se escoge la información de las garantías prendarias similares, con diferente código 
	--clase de garantía, pero que no poseen seguro. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			NULL AS Codigo_Sap,
			NULL AS Cedula_Acreedor,
			NULL AS Nombre_Acreedor,
			NULL AS Monto_Poliza,
			NULL AS Fecha_Vencimiento,			
			'Garantías similares sin relación de SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN @TMP_PRENDAS_DUPLICADAS TPD
		ON TPD.Consecutivo_Garantia_Real = GRO.cod_garantia_real
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.cod_operacion = GRO.cod_operacion
							AND GPR.cod_garantia_real = GRO.cod_garantia_real
							AND GPR.Estado_Registro = 1)

	/*INCONSISTENCIAS DE DIFERENCIAN ENTRE LOS MONTOS DE LA ULTIMA TASACION DEL NO TERRENO ENTRE UNA MISMA GARANTIA*/
	
	--Se escoge la información de las garantías hipotecarias, asociadas a operaciones, que poseen diferente monto de la última tasación del no terreno. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real, Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Diferencias Mto No Terreno'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real IN (1, 2)
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND EXISTS (SELECT	1
					FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TMP
					WHERE	TMP.Clase_Garantia = TOR.Codigo_Clase_Garantia
						AND TMP.Codigo_Partido = TOR.Codigo_Partido
						AND TMP.Numero_Finca = TOR.Numero_Finca)


	--Se escoge la información de las garantías prendarias, asociadas a operaciones, que poseen diferente monto de la última tasación del no terreno. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Diferencias Mto No Terreno'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real = 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND EXISTS (SELECT	1
					FROM	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TMP
					WHERE	TMP.Clase_Garantia = TOR.Codigo_Clase_Garantia
						AND TMP.Numero_Placa_Bien = TOR.Numero_Placa_Bien)


	--Se escoge la información de las garantías hipotecarias, asociadas a contratos, que poseen diferente monto de la última tasación del no terreno. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Diferencias Mto No Terreno'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real IN (1, 2)
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND EXISTS (SELECT	1
					FROM	@TMP_GARANTIAS_HIPOTECARIAS_AVALUOS_DIFERENTES TMP
					WHERE	TMP.Clase_Garantia = TOR.Codigo_Clase_Garantia
						AND TMP.Codigo_Partido = TOR.Codigo_Partido
						AND TMP.Numero_Finca = TOR.Numero_Finca)


	--Se escoge la información de las garantías prendarias, asociadas a contratos, que poseen diferente monto de la última tasación del no terreno. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Diferencias Mto No Terreno'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real = 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND EXISTS (SELECT	1
					FROM	@TMP_GARANTIAS_PRENDAS_AVALUOS_DIFERENTES TMP
					WHERE	TMP.Clase_Garantia = TOR.Codigo_Clase_Garantia
						AND TMP.Numero_Placa_Bien = TOR.Numero_Placa_Bien)


	/*INCONSISTENCIAS DE LAS POLIZAS ELIMINADAS EN EL SAP O QUE CAMBIARON DE ESTADO*/
	
	--Se escoge la información de las pólizas, asociadas a operaciones, que dejaron de existir en el SAP. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion AS Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambio en SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 0
		AND GPR.Estado_Registro = 0
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GP1
						WHERE	GP1.cod_operacion = GPR.cod_operacion
							AND GP1.cod_garantia_real = GPR.cod_garantia_real
							AND GP1.Codigo_SAP = GPR.Codigo_SAP
							AND GP1.Estado_Registro = 1)

	--Se escoge la información de las pólizas, asociadas a contratos, que dejaron de existir en el SAP. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambio en SAP'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPO.Estado_Registro = 0
		AND GPR.Estado_Registro = 0
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GP1
						WHERE	GP1.cod_operacion = GPR.cod_operacion
							AND GP1.cod_garantia_real = GPR.cod_garantia_real
							AND GP1.Codigo_SAP = GPR.Codigo_SAP
							AND GP1.Estado_Registro = 1)


	/*INCONSISTENCIAS DE LAS POLIZAS CUYO MONTO FUE MODIFICADO*/
	
	--Se escoge la información de las pólizas asociadas a operaciones.
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion AS Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambios en Montos de Pólizas'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND ((GPO.Monto_Poliza < GPO.Monto_Poliza_Anterior)
			OR (GPO.Monto_Poliza > GPO.Monto_Poliza_Anterior))

	--Se escoge la información de las pólizas asociadas a contratos. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambios en Montos de Pólizas'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND ((GPO.Monto_Poliza < GPO.Monto_Poliza_Anterior)
			OR (GPO.Monto_Poliza > GPO.Monto_Poliza_Anterior))


	/*INCONSISTENCIAS DE LAS POLIZAS CUYA FECHA DE VENCIMIENTO FUE MODIFICADA Y LA MÁS ES MENOR A LA ANTERIOR*/
	
	--Se escoge la información de las pólizas asociadas a operaciones.
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			TOR.Operacion AS Operacion,
			NULL AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambios Fecha de Vencimiento'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 1
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1
		AND GPO.Fecha_Vencimiento < GPO.Fecha_Vencimiento_Anterior

	--Se escoge la información de las pólizas asociadas a contratos. 
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, Tipo_Garantia_Real,  Tipo_Bien, Garantia_Real, 
									   Clase_Garantia, Monto_Total_Avaluo, Codigo_Sap, Cedula_Acreedor, Nombre_Acreedor, Monto_Poliza,
                                       Fecha_Vencimiento, Tipo_Inconsistencia)
	SELECT	1,
			TOR.Codigo_Oficina,
			TOR.Codigo_Moneda,
			TOR.Codigo_Producto,
			NULL AS Operacion,
			TOR.Operacion AS Contrato,
			TOR.Codigo_Tipo_Garantia_Real,
			TOR.Codigo_Tipo_Bien,
			TOR.Codigo_Bien,
			TOR.Codigo_Clase_Garantia,
			GVR.monto_total_avaluo,
			GPO.Codigo_SAP,
			GPO.Cedula_Acreedor,
			GPO.Nombre_Acreedor,
			GPO.Monto_Poliza_Colonizado,
			GPO.Fecha_Vencimiento,			
			'Cambios Fecha de Vencimiento'
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TOR
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TOR.Codigo_Operacion
		AND GRO.cod_garantia_real = TOR.Codigo_Garantia_Real
		LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = GRO.cod_garantia_real
		AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_operacion = GRO.cod_operacion
		AND GPR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
	WHERE	TOR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TOR.Codigo_Tipo_Operacion = 2
		AND TOR.Codigo_Tipo_Garantia_Real BETWEEN 1 AND 3
		AND GPR.Estado_Registro = 1
		AND GPO.Estado_Registro = 1	
		AND GPO.Fecha_Vencimiento < GPO.Fecha_Vencimiento_Anterior

	
/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

		--Se actualiza la tabla temporal para eliminar los códigos inválidos
		UPDATE	@TMP_INCONSISTENCIAS
		SET		Tipo_Bien = NULL
		WHERE	Tipo_Bien = -1


		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'Inconsistencias_Polizas_Garantias_Reales' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Inconsistencia!3!DATOS!element]
		FROM	@TMP_INCONSISTENCIAS 
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
				NULL						AS [Inconsistencia!3!DATOS!element]
		FROM	@TMP_INCONSISTENCIAS 
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
                 ISNULL(CONVERT(VARCHAR(20), Operacion), '') + CHAR(9) +
                 ISNULL(CONVERT(VARCHAR(20), Contrato), '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(5), Tipo_Garantia_Real), '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(5), Tipo_Bien), '') + CHAR(9) + 
				 CASE
					WHEN Garantia_Real IS NULL THEN ''
					ELSE '''' + Garantia_Real + ''''
				 END + CHAR(9) +
				 ISNULL((CASE WHEN  Clase_Garantia = -1 THEN '' ELSE CONVERT(VARCHAR(5), Clase_Garantia) END), '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(100), Monto_Total_Avaluo), '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(100), Codigo_Sap), '') + CHAR(9) + 
				 ISNULL(Cedula_Acreedor, '') + CHAR(9) + 
				 ISNULL(Nombre_Acreedor, '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(100), Monto_Poliza), '') + CHAR(9) + 
				 ISNULL(CONVERT(VARCHAR(10), Fecha_Vencimiento, 105), '') + CHAR(9) + 
				 Tipo_Inconsistencia + CHAR(9))	AS [Inconsistencia!3!DATOS!element]
		FROM	@TMP_INCONSISTENCIAS 
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Inconsistencias_Polizas_Garantias_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END