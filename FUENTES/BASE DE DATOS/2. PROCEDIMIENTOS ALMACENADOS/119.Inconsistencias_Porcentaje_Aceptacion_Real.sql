USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Inconsistencias_Porcentaje_Aceptacion_Real', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Inconsistencias_Porcentaje_Aceptacion_Real;
GO


CREATE PROCEDURE [dbo].[Inconsistencias_Porcentaje_Aceptacion_Real]

	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>Inconsistencias_Porcentaje_Aceptacion_Real</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las inconsistencias referentes al campo porcentaje de aceptacion.
	</Descripción>
	<Entradas>
			@psCedula_Usuario	= Identificación del usuario que realiza la consulta. 
                                  Este es dato llave usado para la búsqueda de los registros que deben 
                                  ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>11/12/2014</Fecha>
	<Requerimiento>Req_Porce_Aceptacion, Siebel No. 1-24613011</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>		
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>08/12/2015</Fecha>
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
    
 
	CREATE TABLE #TMP_INCONSISTENCIAS	(
											Contabilidad							TINYINT			,
											Oficina									SMALLINT		,
											Moneda									TINYINT			,
											Producto								TINYINT			,
											Operacion								DECIMAL(7)		,
											Contrato								DECIMAL(7)		,
											Codigo_Garantia							VARCHAR (25)	COLLATE DATABASE_DEFAULT,
											Monto_Mitigador							DECIMAL (18,2)		,											
											Porcentaje_Aceptacion					DECIMAL (5,2),
											Porcentaje_Aceptacion_Calculado			DECIMAL(5,2),									 
											Condicion								VARCHAR(50) COLLATE DATABASE_DEFAULT ,
											Tipo_Inconsistencia						VARCHAR(30)	COLLATE DATABASE_DEFAULT, 
											Usuario									VARCHAR(30) COLLATE DATABASE_DEFAULT
											
										)



	/*Se declara la variable temporal tipo tabla que será utilizada como tabla final en la que se guardará los datos de las garantías
	  que se obtienen de igual forma en como se obtienen desde la aplicación 
	*/
	CREATE TABLE #TMP_GARANTIAS_REALES_X_OPERACION  (	cod_llave					BIGINT			IDENTITY(1,1),
														cod_contabilidad			TINYINT,
														cod_oficina					SMALLINT,
														cod_moneda					TINYINT,
														cod_producto				TINYINT,
														operacion					DECIMAL (7,0),
														contrato					DECIMAL (7,0),
														cod_tipo_bien				SMALLINT,
														cod_tipo_mitigador			SMALLINT,
														cod_tipo_documento_legal	SMALLINT,
														cod_operacion				BIGINT,
														cod_garantia_real			BIGINT,
														cod_tipo_garantia_real		TINYINT,
														cod_tipo_operacion			TINYINT,
														Porcentaje_Aceptacion		DECIMAL (5,2),
														monto_mitigador				DECIMAL (18,2),
														cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
														fecha_constitucion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
														cod_inscripcion				SMALLINT,
														fecha_presentacion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
														Indicador_Inconsistencia_Inscripcion		BIT	
														PRIMARY KEY (cod_llave)
													)
	

	DECLARE @vdtFecha_Actual_Sin_Hora	DATETIME,  -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones
			@viEjecucion_Exitosa INT, --Valor de retorno producto de la ejecución de un procedimiento almacenado.
			@vsIdentificacion_Usuario VARCHAR(30) --Identificación del usuario que ejecuta el proceso.

	SET @vdtFecha_Actual_Sin_Hora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET @vsIdentificacion_Usuario = @psCedula_Usuario
	

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
						'<PROCEDIMIENTO>Inconsistencias_Porcentaje_Aceptacion_Real</PROCEDIMIENTO>' +
						'<LINEA></LINEA>' + 
						'<MENSAJE>Se produjo un error al obtener las inconsistencias de los porcentajes de aceptación calculados.</MENSAJE>' +
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
 *                         INICIO DE LA SELECCIÓN DE GARANTÍAS                                  *
 *                   (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                          *
 *                                                                                              *
 ************************************************************************************************/

	INSERT INTO #TMP_GARANTIAS_REALES_X_OPERACION 
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, contrato, cod_tipo_bien, 
	 cod_tipo_mitigador, cod_tipo_documento_legal, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_tipo_operacion, Porcentaje_Aceptacion, 
	 monto_mitigador, cod_bien, fecha_constitucion, cod_usuario, cod_inscripcion,fecha_presentacion, Indicador_Inconsistencia_Inscripcion)


	SELECT	DISTINCT
			1 AS cod_contabilidad, 
			TGR.Codigo_Oficina, 
			TGR.Codigo_Moneda, 
			TGR.Codigo_Producto, 
			TGR.Operacion AS operacion, 
			NULL AS contrato,
			COALESCE(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			TGR.Codigo_Operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			TGR.Codigo_Tipo_Operacion,
			COALESCE(GRO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion,
			COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END AS cod_bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
			TGR.Codigo_Usuario,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			0
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TGR.Codigo_Operacion
		AND GRO.cod_garantia_real = TGR.Codigo_Garantia_Real
		INNER JOIN GAR_GARANTIA_REAL GGR
		ON GGR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 1


	INSERT INTO #TMP_GARANTIAS_REALES_X_OPERACION 
	(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, contrato, cod_tipo_bien, 
	 cod_tipo_mitigador, cod_tipo_documento_legal, cod_operacion, cod_garantia_real, 
	 cod_tipo_garantia_real, cod_tipo_operacion, Porcentaje_Aceptacion, 
	 monto_mitigador, cod_bien, fecha_constitucion, cod_usuario, cod_inscripcion,fecha_presentacion, Indicador_Inconsistencia_Inscripcion)


	SELECT	DISTINCT
			1 AS cod_contabilidad, 
			TGR.Codigo_Oficina, 
			TGR.Codigo_Moneda, 
			TGR.Codigo_Producto, 
			NULL AS operacion, 
			TGR.Operacion AS contrato,
			COALESCE(GGR.cod_tipo_bien, -1) AS cod_tipo_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			TGR.Codigo_Operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			TGR.Codigo_Tipo_Operacion,
			COALESCE(GRO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion,
			COALESCE(GRO.monto_mitigador, 0) AS monto_mitigador,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END AS cod_bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_constitucion, 
			TGR.Codigo_Usuario,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			0
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION TGR
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
		ON GRO.cod_operacion = TGR.Codigo_Operacion
		AND GRO.cod_garantia_real = TGR.Codigo_Garantia_Real
		INNER JOIN GAR_GARANTIA_REAL GGR
		ON GGR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TGR.Codigo_Tipo_Operacion = 2





	---------------------------------------------------------
	
	/*ACTUALIZACION INDICADOR_INCONSISTENCIA_INSCRIPCION*/
	
	-----------------------------------------------------------
	
	--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
	--que no poseen asignado el indicador de inscripción. 
	UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	SET		Indicador_Inconsistencia_Inscripcion = 1
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_presentacion > '19000101'
		AND cod_inscripcion = -1
	

	--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
    --supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
				
	UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	SET		Indicador_Inconsistencia_Inscripcion = 1
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 2 
		AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, fecha_constitucion)


	--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso 
    --(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 días a la fecha de constitución.  
    			
	UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	SET		Indicador_Inconsistencia_Inscripcion = 1
	WHERE	cod_usuario = @psCedula_Usuario
		AND fecha_constitucion > '19000101'
		AND cod_inscripcion = 1 
		AND @vdtFecha_Actual_Sin_Hora >= DATEADD(DAY, 30, fecha_constitucion)


	--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
	--que poseen asignado el indicador de inscripción "No Aplica", pero que poseen un tipo de bien
    --diferente a "Otros tipos de bienes". 

	UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION
	SET		Indicador_Inconsistencia_Inscripcion = 1
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_inscripcion = 0 
		AND cod_tipo_bien <> 14

-----------------------------------------------------------------

	/* FIN ACTUALIZACION INDICADOR_INCONSISTENCIA_INSCRIPCION*/
	
-----------------------------------------------------------------	
	

/************************************************************************************************
 *                                                                                              * 
 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
 *                                                                                              *
 ************************************************************************************************/


/************************************************************************************************
 *                                                                                              * 
 *                         INICIO DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/
	
		
	--En GAR_GARANTIAS_REALEZ_X_OPERACIN en cod_tipo_mitigador tiene -1 y NULL, por lo que se actualiza en al temporal todo en -1
	UPDATE	#TMP_GARANTIAS_REALES_X_OPERACION 
	SET		cod_tipo_mitigador = -1
	WHERE	cod_usuario	= @psCedula_Usuario
		AND cod_tipo_mitigador IS NULL		
		

-------------------------------------------------------

/*INCONSISTENCIAS DE "ERROR TIPO GARANTIA INMUEBLE" */ 

-------------------------------------------------------


--1.--Se escoge la información de las garantías reales cuando el porcentaje de aceptacion es mayor 
	--al campo de porcentaje de aceptacion solicitado en el mantenimiento, para el tipo de garantia.

	
		INSERT INTO #TMP_INCONSISTENCIAS (
												Contabilidad,
												Oficina,
												Moneda,
												Producto,
												Operacion,
												Contrato,
												Codigo_Garantia,
												Monto_Mitigador,											
												Porcentaje_Aceptacion,
												Porcentaje_Aceptacion_Calculado,									 
												Condicion,
												Tipo_Inconsistencia,
												Usuario 	
										 )
		SELECT	DISTINCT
				1,
				GRO.cod_oficina,
				GRO.cod_moneda,
				GRO.cod_producto,		
				GRO.operacion AS Operacion,		
				GRO.contrato AS Contrato,		
				GRO.cod_bien AS Codigo_Garantia,
				GRO.monto_mitigador,
				GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				CPA.Porcentaje_Aceptacion AS Porcentaje_Aceptacion_Calculado,		
				CASE 
					WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
					WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
					ELSE   NULL
				END AS Condicion,
				'Error Tipo Garantía Inmueble',
				@psCedula_Usuario 	
		FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO
			INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
		WHERE	GRO.cod_usuario = @psCedula_Usuario 
			AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA, ver catálogo tipo de garantia real
			AND GRO.cod_tipo_bien IN (1,2)		-- 1:TERRENO 2:Edificio  --ver catalogo tipo de bien
			AND GRO.Porcentaje_Aceptacion > CPA.Porcentaje_Aceptacion							 
	  
	
	
--2.--Se escoge la información de las garantías reales cuando tenga castigos por seguimiento,
	--valuación o poliza, y su porcentaje debe ser reducido a la mitad del  campo de porcentaje de aceptacion 
	--solicitado en el mantenimiento, para el tipo de garantia.

	-------------------
	--TIPO DE BIEN: 1
	-------------------

	   ---------------
		--SEGUIMIENTO
	   ---------------	
	   
			--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
	
			INSERT INTO #TMP_INCONSISTENCIAS (
								Contabilidad,
								Oficina,
								Moneda,
								Producto,
								Operacion,
								Contrato,
								Codigo_Garantia,
								Monto_Mitigador,											
								Porcentaje_Aceptacion,
								Porcentaje_Aceptacion_Calculado,									 
								Condicion,
								Tipo_Inconsistencia ,
								Usuario 		
							)
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 	
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 1		-- 1:TERRENO 2:Edificio  --ver catalogo tipo de bien
				AND GVR.Indicador_Tipo_Registro = 1 --PREGUNTAR					
				AND DATEDIFF(YEAR, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) > 1 
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
            
				
		--------------
		--VALUACION
		--------------
		
			--FECHA VALUACION MAYOR A 5 AÑOS		
			INSERT INTO #TMP_INCONSISTENCIAS (
													Contabilidad,
													Oficina,
													Moneda,
													Producto,
													Operacion,
													Contrato,
													Codigo_Garantia,
													Monto_Mitigador,											
													Porcentaje_Aceptacion,
													Porcentaje_Aceptacion_Calculado,									 
													Condicion,
													Tipo_Inconsistencia,
													Usuario 	 	
												)
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 	
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO		
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador	   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real		
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 1		-- 1:TERRENO 2:Edificio 
				AND GVR.Indicador_Tipo_Registro = 1				   
				AND  DATEDIFF(YEAR, GVR.fecha_valuacion, @vdtFecha_Actual_Sin_Hora) > 5		
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
	
		--------------
		--POLIZA
		--------------	
		
			--POLIZA ASOCIADA			
			INSERT INTO #TMP_INCONSISTENCIAS (
														Contabilidad,
														Oficina,
														Moneda,
														Producto,
														Operacion,
														Contrato,
														Codigo_Garantia,
														Monto_Mitigador,											
														Porcentaje_Aceptacion,
														Porcentaje_Aceptacion_Calculado,									 
														Condicion,
														Tipo_Inconsistencia,
														Usuario 			
													)	
			

							
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					0 AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 	
					
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador		 
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real		
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion	   					
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 1	-- 1:TERRENO 2:Edificio					
				AND GPO.Estado_Registro = 1
				AND GPR.Estado_Registro = 1
				AND GRO.Porcentaje_Aceptacion > 0
	
	-------------------
	--TIPO DE BIEN: 2
	-------------------
		--------------
		--VALUACION
		--------------
		
			--FECHA VALUACION MAYOR A 18 MESES FECHA SISTEMA, MIENTAS NO EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA 		
			INSERT INTO #TMP_INCONSISTENCIAS (
															Contabilidad,
															Oficina,
															Moneda,
															Producto,
															Operacion,
															Contrato,
															Codigo_Garantia,
															Monto_Mitigador,											
															Porcentaje_Aceptacion,
															Porcentaje_Aceptacion_Calculado,									 
															Condicion,
															Tipo_Inconsistencia,
															Usuario 				
				
														)
														 
																	 
														 
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 			
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO		
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = GRO.cod_garantia_real			   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real				
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 
				AND GVR.Indicador_Tipo_Registro = 1
				AND GGR.Indicador_Vivienda_Habitada_Deudor = 0			
				AND  DATEDIFF(MONTH, GVR.fecha_valuacion, @vdtFecha_Actual_Sin_Hora) > 18
				AND DATEDIFF(MONTH, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) > 3
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
						
			UNION ALL
						
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 			
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO		
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = GRO.cod_garantia_real							   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real							
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 
				AND GVR.Indicador_Tipo_Registro = 1
				AND GGR.Indicador_Vivienda_Habitada_Deudor = 1			
				AND DATEDIFF(MONTH, GVR.fecha_valuacion, @vdtFecha_Actual_Sin_Hora) > 18
				AND DATEDIFF(MONTH, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) <= 3
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
	
		---------------
		--SEGUIMIENTO
		---------------
		
			--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
			INSERT INTO #TMP_INCONSISTENCIAS (
															Contabilidad,
															Oficina,
															Moneda,
															Producto,
															Operacion,
															Contrato,
															Codigo_Garantia,
															Monto_Mitigador,											
															Porcentaje_Aceptacion,
															Porcentaje_Aceptacion_Calculado,									 
															Condicion,
															Tipo_Inconsistencia,
															Usuario 				
				
														)
														 
				
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 		
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real					
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 
				AND GVR.Indicador_Tipo_Registro = 1					
				AND DATEDIFF(YEAR, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) > 1 	  
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
					
		--------------
		--POLIZA
		--------------
		INSERT INTO #TMP_INCONSISTENCIAS (
												Contabilidad,
												Oficina,
												Moneda,
												Producto,
												Operacion,
												Contrato,
												Codigo_Garantia,
												Monto_Mitigador,											
												Porcentaje_Aceptacion,
												Porcentaje_Aceptacion_Calculado,									 
												Condicion,
												Tipo_Inconsistencia,
												Usuario 				
	
											)	
					
			
			--NO TIENE POLIZA ASOCIADA
			
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 						
			FROM #TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador			   											
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 									   			
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
								WHERE	GPR.cod_operacion = GRO.cod_operacion
									AND GPR.cod_garantia_real = GRO.cod_garantia_real
									AND GPR.Estado_Registro = 1)
			
			
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador								   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real						
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion	   											
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
			
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO		
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador									   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real							
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion							
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real		   												
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien = 2		-- 1:TERRENO 2:Edificio 	
				AND GVR.Indicador_Tipo_Registro = 1
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
				AND GPO.Monto_Poliza_Colonizado < GVR.monto_ultima_tasacion_no_terreno
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)

--3.-- Se escoge la información de las garantías reales cuando el campo indicador de inscripcion no cumpla con las reglas
	-- y el porcentaje de aceptacion es mayor a cero	

		INSERT INTO #TMP_INCONSISTENCIAS (
													Contabilidad,
													Oficina,
													Moneda,
													Producto,
													Operacion,
													Contrato,
													Codigo_Garantia,
													Monto_Mitigador,											
													Porcentaje_Aceptacion,
													Porcentaje_Aceptacion_Calculado,									 
													Condicion,
													Tipo_Inconsistencia,
													Usuario 				
	
											 )	
		
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					0 AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Inmueble',
					@psCedula_Usuario 					
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador			   						   									
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real IN (1,2)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA,
				AND GRO.cod_tipo_bien IN (1,2)		-- 1:TERRENO 2:Edificio 	          --PREGUNTAR
				AND GRO.Indicador_Inconsistencia_Inscripcion = 1
				AND GRO.Porcentaje_Aceptacion > 0

-------------------------------------------------------

/*INCONSISTENCIAS DE "ERROR TIPO GARANTIA MUEBLE" */ 

-------------------------------------------------------

--1.--Se escoge la información de las garantías reales cuando el porcentaje de aceptacion es mayor 
	--al campo de porcentaje de aceptacion solicitado en el mantenimiento, para el tipo de garantia.

		INSERT INTO #TMP_INCONSISTENCIAS (
												Contabilidad,
												Oficina,
												Moneda,
												Producto,
												Operacion,
												Contrato,
												Codigo_Garantia,
												Monto_Mitigador,											
												Porcentaje_Aceptacion,
												Porcentaje_Aceptacion_Calculado,									 
												Condicion,
												Tipo_Inconsistencia,
												Usuario 	 	
										 )
		SELECT	DISTINCT
				1,
				GRO.cod_oficina,
				GRO.cod_moneda,
				GRO.cod_producto,		
				GRO.operacion AS Operacion,		
				GRO.contrato AS Contrato,		
				GRO.cod_bien AS Codigo_Garantia,
				GRO.monto_mitigador,
				GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				CPA.Porcentaje_Aceptacion AS Porcentaje_Aceptacion_Calculado,		
				CASE 
					WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
					WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
					ELSE   NULL
				END AS Condicion,
				'Error Tipo Garantía Mueble',
				@psCedula_Usuario 			
		FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO
			INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
		WHERE	GRO.cod_usuario = @psCedula_Usuario 
			AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
			AND GRO.cod_tipo_bien IN (3,4)		--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien
			AND GRO.Porcentaje_Aceptacion > CPA.Porcentaje_Aceptacion		
	

--2.--Se escoge la información de las garantías reales cuando tenga castigos por seguimiento,
	--valuación o poliza, y su porcentaje debe ser reducido a la mitad del  campo de porcentaje de aceptacion 
	--solicitado en el mantenimiento, para el tipo de garantia.	
	
	
	-------------------
	--TIPO DE BIEN: 3
	-------------------
	    ---------------
		--SEGUIMIENTO
		---------------	
		--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
				--INSERT INTO #TMP_INCONSISTENCIAS (
				--												Contabilidad,
				--												Oficina,
				--												Moneda,
				--												Producto,
				--												Operacion,
				--												Contrato,
				--												Codigo_Garantia,
				--												Monto_Mitigador,											
				--												Porcentaje_Aceptacion,
				--												Porcentaje_Aceptacion_Calculado,									 
				--												Condicion,
				--												Tipo_Inconsistencia,
				--												Usuario 				
				
				--										 )
														 
				
				
				--SELECT DISTINCT
				--	1,
				--	GRO.cod_oficina,
				--	GRO.cod_moneda,
				--	GRO.cod_producto,		
				--	CASE
				--		WHEN GRO.cod_tipo_operacion = 1 THEN GRO.operacion 
				--		ELSE NULL
				--	END AS Operacion,		
				--	CASE
				--		WHEN GRO.cod_tipo_operacion = 2 THEN GRO.operacion 
				--		ELSE NULL
				--	END AS Contrato,		
				--	GRO.cod_bien AS Codigo_Garantia,
				--	GRO.monto_mitigador,
				--	GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				--	0 AS Porcentaje_Aceptacion_Calculado,		
				--	CASE 
				--		WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
				--		WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
				--		ELSE   NULL
				--	END AS Condicion,
				--	'Error Tipo Garantía Mueble',
				--	@psCedula_Usuario 	
					
				--	FROM #TMP_GARANTIAS_REALES_X_OPERACION GRO
					
				--	INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				--		ON CPA.Codigo_Tipo_Garantia = 2 
				--		   AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
						   
				--	INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				--		ON GVR.cod_garantia_real = GRO.cod_garantia_real
						
				--	WHERE GRO.cod_usuario = @psCedula_Usuario 
				--	AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				--	AND GRO.cod_tipo_bien = 3		--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien
				--	AND GVR.Indicador_Tipo_Registro = 1					
				--	AND DATEDIFF(YEAR, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) > 1 	  
				--	AND GRO.Porcentaje_Aceptacion > 0
		
		--------------
		--VALUACION
		--------------
		
		--FECHA VALUACION MAYOR A 5 AÑOS		
		INSERT INTO #TMP_INCONSISTENCIAS (
													Contabilidad,
													Oficina,
													Moneda,
													Producto,
													Operacion,
													Contrato,
													Codigo_Garantia,
													Monto_Mitigador,											
													Porcentaje_Aceptacion,
													Porcentaje_Aceptacion_Calculado,									 
													Condicion,
													Tipo_Inconsistencia,
													Usuario 	 	
												)
		SELECT	DISTINCT
				1,
				GRO.cod_oficina,
				GRO.cod_moneda,
				GRO.cod_producto,		
				GRO.operacion AS Operacion,		
				GRO.contrato AS Contrato,		
				GRO.cod_bien AS Codigo_Garantia,
				GRO.monto_mitigador,
				GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				0 AS Porcentaje_Aceptacion_Calculado,		
				CASE 
					WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
					WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
					ELSE   NULL
				END AS Condicion,
				'Error Tipo Garantía Mueble',
				@psCedula_Usuario 						
		FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
			INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						   
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
			ON GVR.cod_garantia_real = GRO.cod_garantia_real						
		WHERE	GRO.cod_usuario = @psCedula_Usuario 
			AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
			AND GRO.cod_tipo_bien = 3		--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien
			AND GVR.Indicador_Tipo_Registro = 1				   
			AND DATEDIFF(YEAR, GVR.fecha_valuacion, @vdtFecha_Actual_Sin_Hora) > 5					    
			AND GRO.Porcentaje_Aceptacion > 0
		
		--------------
		--POLIZA
		--------------
		
		INSERT INTO #TMP_INCONSISTENCIAS (
													Contabilidad,
													Oficina,
													Moneda,
													Producto,
													Operacion,
													Contrato,
													Codigo_Garantia,
													Monto_Mitigador,											
													Porcentaje_Aceptacion,
													Porcentaje_Aceptacion_Calculado,									 
													Condicion,
													Tipo_Inconsistencia	,
													Usuario 			
			
												)	
					
			
		--NO TIENE POLIZA ASOCIADA
			
		SELECT	DISTINCT
				1,
				GRO.cod_oficina,
				GRO.cod_moneda,
				GRO.cod_producto,		
				GRO.operacion AS Operacion,		
				GRO.contrato AS Contrato,		
				GRO.cod_bien AS Codigo_Garantia,
				GRO.monto_mitigador,
				GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
				CASE 
					WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
					WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
					ELSE   NULL
				END AS Condicion,
				'Error Tipo Garantía Mueble',
				@psCedula_Usuario 					
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO				
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador			   										
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 3	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien			   			
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
								WHERE	GPR.cod_operacion = GRO.cod_operacion
									AND GPR.cod_garantia_real = GRO.cod_garantia_real
									AND GPR.Estado_Registro = 1)
								
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble',
					@psCedula_Usuario 	
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador								   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real					
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion	   											
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 3	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien	
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
					
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO		
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble',
					@psCedula_Usuario 							
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO						
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador									   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real						
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion							
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real		   												
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 3	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien	
				AND GVR.Indicador_Tipo_Registro = 1
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
				AND GPO.Monto_Poliza_Colonizado < GVR.monto_ultima_tasacion_no_terreno
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
		
	-------------------
	--TIPO DE BIEN: 4
	-------------------
	    ---------------
		--SEGUIMIENTO
		---------------			
			--FECHA SEGUIMIENTO MAYOR A 6 MESES CONTRA SISTEMA
			INSERT INTO #TMP_INCONSISTENCIAS (
															Contabilidad,
															Oficina,
															Moneda,
															Producto,
															Operacion,
															Contrato,
															Codigo_Garantia,
															Monto_Mitigador,											
															Porcentaje_Aceptacion,
															Porcentaje_Aceptacion_Calculado,									 
															Condicion,
															Tipo_Inconsistencia,
															Usuario 				
				
														)
														 
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble' ,
					@psCedula_Usuario					
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO				
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real					
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 4		--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien
				AND GVR.Indicador_Tipo_Registro = 1					
				AND  DATEDIFF(MONTH, GVR.fecha_ultimo_seguimiento, @vdtFecha_Actual_Sin_Hora) > 6 	  
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
					
		--------------
		--VALUACION
		--------------	
		
			--FECHA VALUACION MAYOR A 5 AÑOS		
			INSERT INTO #TMP_INCONSISTENCIAS (
														Contabilidad,
														Oficina,
														Moneda,
														Producto,
														Operacion,
														Contrato,
														Codigo_Garantia,
														Monto_Mitigador,											
														Porcentaje_Aceptacion,
														Porcentaje_Aceptacion_Calculado,									 
														Condicion,
														Tipo_Inconsistencia,
														Usuario 	 	
													)
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble' ,
					@psCedula_Usuario					
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						   
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real						
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 4		--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien
				AND GVR.Indicador_Tipo_Registro = 1				    
				AND  DATEDIFF(YEAR, GVR.fecha_valuacion, @vdtFecha_Actual_Sin_Hora) > 5			    
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
				    	
		--------------
		--POLIZA
		--------------
		
			INSERT INTO #TMP_INCONSISTENCIAS (
														Contabilidad,
														Oficina,
														Moneda,
														Producto,
														Operacion,
														Contrato,
														Codigo_Garantia,
														Monto_Mitigador,											
														Porcentaje_Aceptacion,
														Porcentaje_Aceptacion_Calculado,									 
														Condicion,
														Tipo_Inconsistencia,
														Usuario 				
			
													)	

			--NO TIENE POLIZA ASOCIADA
			
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble' ,
					@psCedula_Usuario						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador			   											
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 4	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien			   			
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
								WHERE	GPR.cod_operacion = GRO.cod_operacion
									AND GPR.cod_garantia_real = GRO.cod_garantia_real
									AND GPR.Estado_Registro = 1)
								
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador								   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
				ON GPR.cod_operacion = GRO.cod_operacion
				AND GPR.cod_garantia_real = GRO.cod_garantia_real						
				INNER JOIN dbo.GAR_POLIZAS GPO
				ON GPO.Codigo_SAP = GPR.Codigo_SAP
				AND GPO.cod_operacion = GPR.cod_operacion	   											
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 4	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien	
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
					
			--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO		
			UNION ALL
				
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					(CPA.Porcentaje_Aceptacion/2) AS Porcentaje_Aceptacion_Calculado,		
					CASE 
						WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
						WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
						ELSE   NULL
					END AS Condicion,
					'Error Tipo Garantía Mueble' ,
					@psCedula_Usuario							
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO						
				INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
					ON CPA.Codigo_Tipo_Garantia = 2 
						AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador									   
				INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					ON GPR.cod_operacion = GRO.cod_operacion
					AND GPR.cod_garantia_real = GRO.cod_garantia_real							
				INNER JOIN dbo.GAR_POLIZAS GPO
					ON GPO.Codigo_SAP = GPR.Codigo_SAP
					AND GPO.cod_operacion = GPR.cod_operacion							
				INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
					ON GVR.cod_garantia_real = GRO.cod_garantia_real		   												
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
				AND GRO.cod_tipo_bien = 4	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien	
				AND GVR.Indicador_Tipo_Registro = 1
				AND GPO.Estado_Registro = 1	
				AND GPR.Estado_Registro = 1	
				AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
				AND GPO.Monto_Poliza_Colonizado < GVR.monto_ultima_tasacion_no_terreno
				AND GRO.Porcentaje_Aceptacion > (CPA.Porcentaje_Aceptacion/2)
						
	
--3.-- Se escoge la información de las garantías reales cuando el campo indicador de inscripcion no cumpla con las reglas
	-- y el porcentaje de aceptacion es mayor a cero

		--NO SE DEBE SEGMENTAR PORQUE SI NO CUMPLE SE REDUCE A 0
	
		INSERT INTO #TMP_INCONSISTENCIAS (
														Contabilidad,
														Oficina,
														Moneda,
														Producto,
														Operacion,
														Contrato,
														Codigo_Garantia,
														Monto_Mitigador,											
														Porcentaje_Aceptacion,
														Porcentaje_Aceptacion_Calculado,									 
														Condicion,
														Tipo_Inconsistencia,
														Usuario 				
			
													)	
		
		SELECT	DISTINCT
				1,
				GRO.cod_oficina,
				GRO.cod_moneda,
				GRO.cod_producto,		
				GRO.operacion AS Operacion,		
				GRO.contrato AS Contrato,		
				GRO.cod_bien AS Codigo_Garantia,
				GRO.monto_mitigador,
				GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
				0 AS Porcentaje_Aceptacion_Calculado,		
				CASE 
					WHEN CPA.Indicador_Sin_Calificacion = 0 THEN  'No Aplica Calificación '
					WHEN CPA.Indicador_Sin_Calificacion = 1 THEN 'Sin Calificación'
					ELSE   NULL
				END AS Condicion,
				'Error Tipo Garantía Mueble',
				@psCedula_Usuario 					
		FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
			INNER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador					   						   									
		WHERE	GRO.cod_usuario = @psCedula_Usuario 
			AND GRO.cod_tipo_garantia_real = 3  -- 3: PRENDA, ver catálogo tipo de garantia real
			AND GRO.cod_tipo_bien IN (3,4)	--3: VEHICULO 4:MAQUINARIA  --ver catalogo tipo de bien	
			AND GRO.Indicador_Inconsistencia_Inscripcion = 1
			AND GRO.Porcentaje_Aceptacion > 0
					
-------------------------------------------------------

/*INCONSISTENCIAS DE "ERROR SIN DATOS" */ 

-------------------------------------------------------
--ESTE TIPO DE INCONSISTENCIA NO DEBE MOSTRAR NINGUN CAMPO DEL CAT_PORCENTAJE_ACEPTACION ES DECIR, RETORNA DATOS NULL

--TIPO BIEN: -1, NULL : SON REGISTROS NUEVOS

	--Se escoge la información de las garantías reales que no  cumplen las reglas, no tiene relacionado un tipo mitigador, 
	--no presente valor en el campo porcentaje de aceptación o porcentaje de aceptación calculado	
	
	-----------------------------------------------------------------------------------------------------------------
	--NO RELACION EN TIPO BIEN 
	-----------------------------------------------------------------------------------------------------------------

			INSERT INTO #TMP_INCONSISTENCIAS (
											Contabilidad,
											Oficina,
											Moneda,
											Producto,
											Operacion,
											Contrato,
											Codigo_Garantia,
											Monto_Mitigador,											
											Porcentaje_Aceptacion,
											Porcentaje_Aceptacion_Calculado,									 
											Condicion,
											Tipo_Inconsistencia ,
											Usuario 		
										)
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					NULL AS Porcentaje_Aceptacion_Calculado,		
					NULL AS Condicion,
					'Error Sin Datos',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO													
				LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real						
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GVR.Indicador_Tipo_Registro = 1	
				AND GRO.cod_tipo_bien = -1					
					
	-----------------------------------------------------------------------------------------------------------------
	--NO RELACION EN TIPO MITIGADOR, -1 = NULL, CON EL NULL SE HACE UN UPDATE AL INICIO DE LA SELECCION DE LOS DATOS 
	-----------------------------------------------------------------------------------------------------------------		
			UNION ALL
					
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					NULL AS Porcentaje_Aceptacion_Calculado,		
					NULL AS Condicion,
					'Error Sin Datos',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO													
				LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real						
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GVR.Indicador_Tipo_Registro = 1	
				AND ((GRO.cod_tipo_bien >= 1) AND (GRO.cod_tipo_bien <= 4))   --Hay registros que tienen tipo bien, pero no tiene tipo mitigador
				AND GRO.cod_tipo_mitigador = -1		
					
	--------------------------------------------------------------------------------------------------------------
	--NO PRESENTE PORCENTAJE DE ACEPTACION, 0 
	-----------------------------------------------------------------------------------------------------------------	
			UNION ALL
					
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
					NULL AS Porcentaje_Aceptacion_Calculado,		
					NULL AS Condicion,
					'Error Sin Datos',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO													
				LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real						
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GVR.Indicador_Tipo_Registro = 1	--
				AND ((GRO.cod_tipo_bien >= 1) AND (GRO.cod_tipo_bien <= 4))
				AND GRO.cod_tipo_mitigador > 1	
				AND GRO.Porcentaje_Aceptacion = 0
							
	-----------------------------------------------------------------------------------------------------------------
	--NO PRESENTE PORCENTAJE DE ACEPTACION CALCULADO, 0 , NO ESTÉ RELACIONADO EN EL CATALOGO 
	-----------------------------------------------------------------------------------------------------------------
			UNION ALL
					
			SELECT	DISTINCT
					1,
					GRO.cod_oficina,
					GRO.cod_moneda,
					GRO.cod_producto,		
					GRO.operacion AS Operacion,		
					GRO.contrato AS Contrato,		
					GRO.cod_bien AS Codigo_Garantia,
					GRO.monto_mitigador,
					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,  --ISNULL
					NULL AS Porcentaje_Aceptacion_Calculado,		
					NULL AS Condicion,
					'Error Sin Datos',
					@psCedula_Usuario 						
			FROM	#TMP_GARANTIAS_REALES_X_OPERACION GRO					
				LEFT OUTER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador						   
				LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
				ON GVR.cod_garantia_real = GRO.cod_garantia_real						
			WHERE	GRO.cod_usuario = @psCedula_Usuario 
				AND GVR.Indicador_Tipo_Registro = 1					
				AND ((GRO.cod_tipo_bien >= 1) AND (GRO.cod_tipo_bien <= 4))
				AND GRO.cod_tipo_mitigador > -1	
				AND GRO.Porcentaje_Aceptacion > 0	 
				AND COALESCE(CPA.Porcentaje_Aceptacion,0) = 0 
	
--tipo bien : -1 o NULL, SON REGISTROS NUEVOS					

--SE COMENTAN ESTOS DATOS YA QUE SE TIENEN QUE OPTIMIZAR DEBIDO A QUE CON ELLOS SE TIENE UNA DURACION MAYOR A 5 MINUTOS
--CON LO QUE SE DEBE VER LA FORMA EN QUE SEA MAS RAPIDO, DENTRO DEL REQUERIMIENTO NO VIENE ESTOS CONTEMPLADOS
--PERO ES IMPORTANTE TENER LOS MISMOS YA QUE SI NO TIENEN LA INFORMACION NO SE VA A REALIZAR LOS CALCULOS RESPECTIVOS
--AL PORCENTAJE DE ACEPTACION CALCULADO 										
-------------------------------------------------------------------------------------------------------------------
----NO PRESENTE FECHA ULTIMO SEGUIMIENTO, NULL
-------------------------------------------------------------------------------------------------------------------			
			
--			---------------------
--			--TIPO BIEN: 1,2,3,4	
--			--------------------   
				
			
--							INSERT INTO #TMP_INCONSISTENCIAS (
--												Contabilidad,
--												Oficina,
--												Moneda,
--												Producto,
--												Operacion,
--												Contrato,
--												Codigo_Garantia,
--												Monto_Mitigador,											
--												Porcentaje_Aceptacion,
--												Porcentaje_Aceptacion_Calculado,									 
--												Condicion,
--												Tipo_Inconsistencia ,
--												Usuario 		
--										 )
--					SELECT DISTINCT
--					1,
--					GRO.cod_oficina,
--					GRO.cod_moneda,
--					GRO.cod_producto,		
--					CASE
--						WHEN GRO.cod_tipo_operacion = 1 THEN GRO.operacion 
--						ELSE NULL
--					END AS Operacion,		
--					CASE
--						WHEN GRO.cod_tipo_operacion = 2 THEN GRO.operacion 
--						ELSE NULL
--					END AS Contrato,		
--					GRO.cod_bien AS Codigo_Garantia,
--					GRO.monto_mitigador,
--					GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,  --ISNULL
--					NULL  AS Porcentaje_Aceptacion_Calculado,		
--					NULL AS Condicion,
--					'Error Sin Datos',
--					@psCedula_Usuario 	
					
--					FROM #TMP_GARANTIAS_REALES_X_OPERACION GRO
					
--					LEFT OUTER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
--						ON CPA.Codigo_Tipo_Garantia = 2 
--						   AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador
						   
--					LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
--						ON GVR.cod_garantia_real = GRO.cod_garantia_real
						
--					WHERE 
--					GRO.cod_tipo_garantia_real IN (1,2,3)  -- 1: HIPOTECA	2: CEDULA HIPOTECARIA, ver catálogo tipo de garantia real	
--					AND GVR.Indicador_Tipo_Registro = 1	-- 1: Es igual registrado en el SICC, registro válida., se actualiza cada vez replica 												
--					AND GRO.cod_tipo_bien IN (1,2,3,4)
--					AND GRO.cod_tipo_mitigador > -1	
--					AND GRO.Porcentaje_Aceptacion > 0	 
--					AND  COALESCE(CPA.Porcentaje_Aceptacion,0) > 0 
--		 			AND GVR.fecha_ultimo_seguimiento IS NULL	
					
-------------------------------------------------------------------------------------------------------------------
----NO PRESENTE FECHA VENCIMIENTO POLIZA, NULL
-------------------------------------------------------------------------------------------------------------------			
			
--			--------------------
--			--TIPO BIEN: 2-3-4
--			--------------------
--			INSERT INTO #TMP_INCONSISTENCIAS (
--												Contabilidad,
--												Oficina,
--												Moneda,
--												Producto,
--												Operacion,
--												Contrato,
--												Codigo_Garantia,
--												Monto_Mitigador,											
--												Porcentaje_Aceptacion,
--												Porcentaje_Aceptacion_Calculado,									 
--												Condicion,
--												Tipo_Inconsistencia ,
--												Usuario 		
--										 )
			
--			SELECT DISTINCT
--							1,
--							GRO.cod_oficina,
--							GRO.cod_moneda,
--							GRO.cod_producto,		
--							CASE
--								WHEN GRO.cod_tipo_operacion = 1 THEN GRO.operacion 
--								ELSE NULL
--							END AS Operacion,		
--							CASE
--								WHEN GRO.cod_tipo_operacion = 2 THEN GRO.operacion 
--								ELSE NULL
--							END AS Contrato,		
--							GRO.cod_bien AS Codigo_Garantia,
--							GRO.monto_mitigador,
--							GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
--							NULL AS Porcentaje_Aceptacion_Calculado,		
--							NULL AS Condicion,
--							'Error Sin Datos',
--							@psCedula_Usuario 	
							
--							FROM #TMP_GARANTIAS_REALES_X_OPERACION GRO
							
--							LEFT OUTER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
--								ON CPA.Codigo_Tipo_Garantia = 2 
--								   AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador		
								   
--							INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
--								ON GPR.cod_operacion = GRO.cod_operacion
--								AND GPR.cod_garantia_real = GRO.cod_garantia_real
								
--							INNER JOIN dbo.GAR_POLIZAS GPO
--								ON GPO.Codigo_SAP = GPR.Codigo_SAP
--								AND GPO.cod_operacion = GPR.cod_operacion
								
--							LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
--								ON GVR.cod_garantia_real = GRO.cod_garantia_real		   					
								
--							WHERE 
--							GRO.cod_tipo_garantia_real IN (1,2,3)  -- 3: PRENDA, ver catálogo tipo de garantia real
--							AND GVR.Indicador_Tipo_Registro = 1
--							AND GRO.cod_tipo_bien IN (2,3,4)       --SOLO TIPO BIEN 2,3,4, EL 1 NO TIENE RELACION 
--							AND GRO.cod_tipo_mitigador > -1	
--							AND GRO.Porcentaje_Aceptacion > 0	 
--							AND  COALESCE(CPA.Porcentaje_Aceptacion,0) > 0 
-- 							AND GVR.fecha_ultimo_seguimiento IS NOT NULL
-- 							AND GPO.Fecha_Vencimiento IS NULL	
							
							
-------------------------------------------------------------------------------------------------------------------
----NO PRESENTE monto_ultima_tasacion_no_terreno, NULL o 0
-------------------------------------------------------------------------------------------------------------------


--					INSERT INTO #TMP_INCONSISTENCIAS (
--																	Contabilidad,
--																	Oficina,
--																	Moneda,
--																	Producto,
--																	Operacion,
--																	Contrato,
--																	Codigo_Garantia,
--																	Monto_Mitigador,											
--																	Porcentaje_Aceptacion,
--																	Porcentaje_Aceptacion_Calculado,									 
--																	Condicion,
--																	Tipo_Inconsistencia ,
--																	Usuario 		
--															 )

--						SELECT DISTINCT
--								1,
--								GRO.cod_oficina,
--								GRO.cod_moneda,
--								GRO.cod_producto,		
--								CASE
--									WHEN GRO.cod_tipo_operacion = 1 THEN GRO.operacion 
--									ELSE NULL
--								END AS Operacion,		
--								CASE
--									WHEN GRO.cod_tipo_operacion = 2 THEN GRO.operacion 
--									ELSE NULL
--								END AS Contrato,		
--								GRO.cod_bien AS Codigo_Garantia,
--								GRO.monto_mitigador,
--								GRO.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,
--								NULL AS Porcentaje_Aceptacion_Calculado,		
--								NULL AS Condicion,
--								'Error Sin Datos' ,
--								@psCedula_Usuario	
								
--								FROM #TMP_GARANTIAS_REALES_X_OPERACION GRO
								
--								LEFT OUTER JOIN dbo.CAT_PORCENTAJE_ACEPTACION CPA
--									ON CPA.Codigo_Tipo_Garantia = 2 
--									   AND CPA.Codigo_Tipo_Mitigador = GRO.cod_tipo_mitigador		
									   
--								INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
--									ON GPR.cod_operacion = GRO.cod_operacion
--									AND GPR.cod_garantia_real = GRO.cod_garantia_real
									
--								INNER JOIN dbo.GAR_POLIZAS GPO
--									ON GPO.Codigo_SAP = GPR.Codigo_SAP
--									AND GPO.cod_operacion = GPR.cod_operacion
									
--								LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR
--									ON GVR.cod_garantia_real = GRO.cod_garantia_real		   					
									
--								WHERE 
--								GRO.cod_tipo_garantia_real IN (1,2,3)  -- 3: PRENDA, ver catálogo tipo de garantia real								
--								AND GVR.Indicador_Tipo_Registro = 1
--								AND GRO.cod_tipo_bien IN (2,3,4)
--								AND GRO.cod_tipo_mitigador > -1	
--								AND GRO.Porcentaje_Aceptacion > 0	 
--								AND  COALESCE(CPA.Porcentaje_Aceptacion,0) > 0 
--								AND GVR.fecha_ultimo_seguimiento IS NOT NULL
--								AND GPO.Fecha_Vencimiento IS NOT NULL	
--								AND  ( (GVR.monto_ultima_tasacion_no_terreno IS NULL) OR (GVR.monto_ultima_tasacion_no_terreno = 0) )
														
	
	
/************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCIÓN DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

		--Se establece como NULL el valor del porcentaje de aceptación que es igual a -1
		UPDATE	#TMP_INCONSISTENCIAS 
		SET		Porcentaje_Aceptacion = NULL
		WHERE	Porcentaje_Aceptacion = -1


		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'Inconsistencias_Porcentaje_Aceptacion_Real' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
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
		WHERE	Usuario = @psCedula_Usuario
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
                 COALESCE(CONVERT(VARCHAR(20), Operacion),'') + CHAR(9) +  
                 COALESCE(CONVERT(VARCHAR(20), Contrato),'') + CHAR(9) +   
                 COALESCE(CONVERT(VARCHAR(50),Codigo_Garantia),'')+ CHAR(9) + 
                 COALESCE(CONVERT(VARCHAR(50), Monto_Mitigador),'') + CHAR(9) + 
                 COALESCE(CONVERT(VARCHAR(50), Porcentaje_Aceptacion),'') + CHAR(9) + 
                 COALESCE(CONVERT(VARCHAR(50), Porcentaje_Aceptacion_Calculado),'') + CHAR(9) + 
                 COALESCE(Condicion,'') + CHAR(9) + 
                 COALESCE(Tipo_Inconsistencia,'')            
				  )	AS [Inconsistencia!3!DATOS!element],
				
				Usuario							AS [Inconsistencia!3!Usuario!hide]
		FROM	#TMP_INCONSISTENCIAS 
		WHERE	Usuario = @psCedula_Usuario
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Inconsistencias_Porcentaje_Aceptacion_Real</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
END
