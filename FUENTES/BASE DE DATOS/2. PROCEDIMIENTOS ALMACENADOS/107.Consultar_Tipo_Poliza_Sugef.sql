USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Tipo_Poliza_Sugef', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Tipo_Poliza_Sugef;
GO

CREATE PROCEDURE [dbo].[Consultar_Tipo_Poliza_Sugef]
	@piConsecutivo_Registro				INT = NULL,
	@pbRegistro_Blanco					BIT = 0,
	@piConsecutivo_Proximo_Registro		INT	OUTPUT,
	@psRespuesta						VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Tipo_Poliza_Sugef</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de consultar la información del tipo de póliza SUGEF.
	</Descripción>
	<Entradas>
		@piConsecutivo_Registro	= Consecutivo del registro, en caso de que sea nulo se retornan todos los registros.
		@pbRegistro_Blanco		= Indicador que determina si se reqiere la opción -1 con texto vacío.
	</Entradas>
	<Salidas>
			@piConsecutivo_Proximo_Registro	= Próximo consecutivo a insertar.
			@psRespuesta					= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
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
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish
	
	BEGIN TRY
		SELECT	DISTINCT 	
					1											AS Tag,
					NULL										AS Parent,
					'0'											AS [RESPUESTA!1!CODIGO!element], 
					NULL										AS [RESPUESTA!1!NIVEL!element], 
					NULL										AS [RESPUESTA!1!ESTADO!element], 
					'Consultar_Tipo_Poliza_Sugef'				AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					NULL										AS [DATO!3!Codigo_Tipo_Poliza_Sugef!element],
					NULL										AS [DATO!3!Nombre_Tipo_Poliza!element], 
					NULL										AS [DATO!3!Descripcion_Tipo_Poliza!element]

			UNION ALL 
			
			SELECT	DISTINCT 	
					2											AS Tag,
					1											AS Parent,
					NULL										AS [RESPUESTA!1!CODIGO!element], 
					NULL										AS [RESPUESTA!1!NIVEL!element], 
					NULL										AS [RESPUESTA!1!ESTADO!element], 
					NULL										AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					NULL										AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					NULL										AS [DATO!3!Codigo_Tipo_Poliza_Sugef!element],
					NULL										AS [DATO!3!Nombre_Tipo_Poliza!element], 
					NULL										AS [DATO!3!Descripcion_Tipo_Poliza!element]

			UNION ALL 
			
			SELECT	DISTINCT 	
					3											AS Tag,
					2											AS Parent,
					NULL										AS [RESPUESTA!1!CODIGO!element], 
					NULL										AS [RESPUESTA!1!NIVEL!element], 
					NULL										AS [RESPUESTA!1!ESTADO!element], 
					NULL										AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					NULL										AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					Codigo_Tipo_Poliza_Sugef					AS [DATO!3!Codigo_Tipo_Poliza_Sugef!element],
					Nombre_Tipo_Poliza							AS [DATO!3!Nombre_Tipo_Poliza!element], 
					ISNULL(Descripcion_Tipo_Poliza, '')			AS [DATO!3!Descripcion_Tipo_Poliza!element]
			FROM	dbo.CAT_TIPOS_POLIZAS_SUGEF
			WHERE	Codigo_Tipo_Poliza_Sugef = ISNULL(@piConsecutivo_Registro, Codigo_Tipo_Poliza_Sugef)

			UNION ALL 
			
			SELECT	DISTINCT 	
					3											AS Tag,
					2											AS Parent,
					NULL										AS [RESPUESTA!1!CODIGO!element], 
					NULL										AS [RESPUESTA!1!NIVEL!element], 
					NULL										AS [RESPUESTA!1!ESTADO!element], 
					NULL										AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					NULL										AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					-1											AS [DATO!3!Codigo_Tipo_Poliza_Sugef!element],
					''											AS [DATO!3!Nombre_Tipo_Poliza!element], 
					''											AS [DATO!3!Descripcion_Tipo_Poliza!element]
			WHERE	@pbRegistro_Blanco = 1

			FOR		XML EXPLICIT
	
	END TRY
	BEGIN CATCH
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Consultar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al obtener el registro.</MENSAJE><DETALLE>Se produjo un error al obtener los datos del tipo de póliza SUGEF. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 
	END CATCH
	
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Consultar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SET	@piConsecutivo_Proximo_Registro = (	SELECT	(MAX(Codigo_Tipo_Poliza_Sugef) + 1)
											FROM	dbo.CAT_TIPOS_POLIZAS_SUGEF)

	RETURN 0
END