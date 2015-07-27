USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.Obtener_Resultado_Ejecucion_Procesos_Replica', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Obtener_Resultado_Ejecucion_Procesos_Replica;
GO

CREATE PROCEDURE [dbo].[Obtener_Resultado_Ejecucion_Procesos_Replica]
	@pdFechaInicial			DATETIME,
	@pdFechaFinal			DATETIME,
	@psCodigoProceso		VARCHAR(20) = NULL,
	@piIndicador			BIT			= NULL,
	@psRespuesta			VARCHAR(1000) OUTPUT
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Obtener_Resultado_Ejcucion_Procesos_Replica</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que extrae la información requerida para generar la consulta sobre la ejecución del os procesos de réplica.
	</Descripción>
	<Entradas>
			@pdFechaInicial			= Fecha a partir de la cual se inicia la extracción de información.
			
			@pdFechaFinal			= Fecha hasta la cual se extrae la información.

			@psCodigoProceso		= Código del proceso que ejecuta este procedimiento almacenado.
			
			@piIndicador			= Indicador del resultado, donde: 0 = Existoso, 1 = Fallido.
	</Entradas>
	<Salidas>
			@psRespuesta			= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada.  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>13/02/2014</Fecha>
	<Requerimiento>
			Req Bcr Garantias Migración, Siebel No.1-24015441
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
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	BEGIN TRY

		SELECT	DISTINCT	
			1							AS Tag,
			NULL						AS Parent,
			'0'							AS [RESPUESTA!1!CODIGO!element], 
			NULL						AS [RESPUESTA!1!NIVEL!element], 
			NULL						AS [RESPUESTA!1!ESTADO!element], 
			'Obtener_Resultado_Ejecucion_Procesos_Replica'	AS [RESPUESTA!1!PROCEDIMIENTO!element], 
			NULL						AS [RESPUESTA!1!LINEA!element], 
			'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
			NULL						AS [RESULTADOS!2!], 
			NULL						AS [RESULTADO!3!cocProceso!element], 
			NULL						AS [RESULTADO!3!fecIngreso!element], 
			NULL						AS [RESULTADO!3!Resultado!element], 
			NULL						AS [RESULTADO!3!desObservacion!element]

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
			NULL						AS [RESULTADOS!2!], 
			NULL						AS [RESULTADO!3!cocProceso!element], 
			NULL						AS [RESULTADO!3!fecIngreso!element], 
			NULL						AS [RESULTADO!3!Resultado!element], 
			NULL						AS [RESULTADO!3!desObservacion!element]

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
			NULL						AS [RESULTADOS!2!], 
			CASE
				WHEN GEP.cocProceso = 'MIGRARGARANTIAS' THEN 'MIGRAR GARANTIAS'
				WHEN GEP.cocProceso = 'ACTUALIZARGARANTIAS' THEN 'ACTUALIZAR GARANTIAS'
				WHEN GEP.cocProceso = 'CARGARCONTRATVENCID' THEN 'CARGAR CONTRATOS VENCIDOS'
				WHEN GEP.cocProceso = 'GENERAARCHIVOSUGEF' THEN 'GENERAR ARCHIVOS SUGEF'
				WHEN GEP.cocProceso = 'CALCULAR_MTAT_MTANT' THEN 'CALCULO AVALUOS'
				ELSE ''
			END							AS [RESULTADO!3!cocProceso!element], 
			EPD.fecIngreso				AS [RESULTADO!3!fecIngreso!element], 
			CASE
				WHEN EPD.indError = 1 THEN 'Fallido'
				ELSE 'Exitoso'
			END 						AS [RESULTADO!3!Resultado!element], 
			EPD.desObservacion			AS [RESULTADO!3!desObservacion!element]

		FROM	dbo.GAR_EJECUCION_PROCESO GEP
			INNER JOIN dbo.GAR_EJECUCION_PROCESO_DETALLE EPD
			ON EPD.conEjecucionProceso = GEP.conEjecucionProceso
		WHERE	GEP.fecEjecucion BETWEEN @pdFechaInicial AND @pdFechaFinal
			AND GEP.cocProceso = ISNULL(@psCodigoProceso, GEP.cocProceso)
			AND EPD.indError = ISNULL(@piIndicador, EPD.indError)
			AND GEP.cocProceso IN ('MIGRARGARANTIAS', 'ACTUALIZARGARANTIAS', 'CARGARCONTRATVENCID', 'GENERAARCHIVOSUGEF', 'CALCULAR_MTAT_MTANT', 'MIGRARPOLIZAS')
		ORDER BY [RESULTADO!3!fecIngreso!element]
		FOR XML EXPLICIT
	 
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Resultado_Ejcucion_Procesos_Replica</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
	END TRY
	BEGIN CATCH
	
		DECLARE @vsMensajeError	NVARCHAR(4000),
				@viNumeroError	INT
				
		SELECT 
			@vsMensajeError = ERROR_MESSAGE(),
			@viNumeroError = ERROR_NUMBER()

		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Resultado_Ejcucion_Procesos_Replica</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>' + CAST(@vsMensajeError AS VARCHAR(4000)) + '. Código de Error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 1

	END CATCH
END