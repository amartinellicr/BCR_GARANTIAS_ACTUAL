USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Tipo_Bien_Relacionado', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Tipo_Bien_Relacionado;
GO

CREATE PROCEDURE [dbo].[Consultar_Tipo_Bien_Relacionado]
	@piCodigo_Tipo_Bien					INT = NULL,
	@piCodigo_Tipo_Poliza_Sap			INT = NULL,
	@piCodigo_Tipo_Poliza_Sugef			INT = NULL,
	@piCatalogo_Tipo_Poliza				INT,
	@piCatalogo_Tipo_Bien				INT,
	@psRespuesta						VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Tipo_Bien_Relacionado</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de consultar la información de la relación existente entre tipos de bien, tipos de pólizas SUGEF y
		tipo de pólizas SAP. En caso de que los filtros de entrada sean nulos, se retornan todos los datos.
	</Descripción>
	<Entradas>
		@piCodigo_Tipo_Bien				= Código del tipo de bien.
		@piCodigo_Tipo_Poliza_Sap		= Código del tipo de póliza SAP.
		@piCodigo_Tipo_Poliza_Sugef		= Código del tipo de póliza SUGEF.
		@piCatalogo_Tipo_Poliza			= Código del catálogo de los tipos de póliza SAP.
		@piCatalogo_Tipo_Bien			= Código del catálogo de los tipos de bien.
	</Entradas>
	<Salidas>
			@psRespuesta						= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
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
					'Consultar_Tipo_Bien_Relacionado'			AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					NULL										AS [RELACIONES!3!],
					NULL										AS [RELACION!4!Consecutivo_Relacion!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sap!element], 
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Bien!element],
					NULL										AS [RELACION!4!Nombre_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sap!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Bien!element]

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
					NULL										AS [RELACIONES!3!],
					NULL										AS [RELACION!4!Consecutivo_Relacion!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sap!element], 
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Bien!element],
					NULL										AS [RELACION!4!Nombre_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sap!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Bien!element]

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
					NULL										AS [RELACIONES!3!],
					NULL										AS [RELACION!4!Consecutivo_Relacion!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sap!element], 
					NULL										AS [RELACION!4!Codigo_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Codigo_Tipo_Bien!element],
					NULL										AS [RELACION!4!Nombre_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sugef!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Poliza_Sap!element],
					NULL										AS [RELACION!4!Descripcion_Tipo_Bien!element]

			UNION ALL 
			
			SELECT	DISTINCT	
					4											AS Tag,
					3											AS Parent,
					NULL										AS [RESPUESTA!1!CODIGO!element], 
					NULL										AS [RESPUESTA!1!NIVEL!element], 
					NULL										AS [RESPUESTA!1!ESTADO!element], 
					NULL										AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL										AS [RESPUESTA!1!LINEA!element], 
					NULL										AS [RESPUESTA!1!MENSAJE!element], 
					NULL										AS [DETALLE!2!], 
					NULL										AS [RELACIONES!3!],
					TPB.Consecutivo_Relacion					AS [RELACION!4!Consecutivo_Relacion!element],
					TPB.Codigo_Tipo_Poliza_Sap					AS [RELACION!4!Codigo_Tipo_Poliza_Sap!element], 
					TPB.Codigo_Tipo_Poliza_Sugef				AS [RELACION!4!Codigo_Tipo_Poliza_Sugef!element],
					TPB.Codigo_Tipo_Bien						AS [RELACION!4!Codigo_Tipo_Bien!element],
					TPS.Nombre_Tipo_Poliza						AS [RELACION!4!Nombre_Tipo_Poliza_Sugef!element],
					TPS.Descripcion_Tipo_Poliza					AS [RELACION!4!Descripcion_Tipo_Poliza_Sugef!element],
					CE1.cat_descripcion							AS [RELACION!4!Descripcion_Tipo_Poliza_Sap!element],
					CE2.cat_descripcion							AS [RELACION!4!Descripcion_Tipo_Bien!element]
			FROM	dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
				INNER JOIN dbo.CAT_TIPOS_POLIZAS_SUGEF TPS
				ON TPS.Codigo_Tipo_Poliza_Sugef = TPB.Codigo_Tipo_Poliza_Sugef
				INNER JOIN dbo.CAT_ELEMENTO CE1
				ON CE1.cat_campo = CONVERT(VARCHAR(5), TPB.Codigo_Tipo_Poliza_Sap)
				INNER JOIN dbo.CAT_ELEMENTO CE2
				ON CE2.cat_campo = CONVERT(VARCHAR(5), TPB.Codigo_Tipo_Bien)
			WHERE	CE1.cat_catalogo = @piCatalogo_Tipo_Poliza
				AND CE2.cat_catalogo = @piCatalogo_Tipo_Bien
				AND TPB.Codigo_Tipo_Poliza_Sugef = ISNULL(@piCodigo_Tipo_Poliza_Sugef, TPB.Codigo_Tipo_Poliza_Sugef)
				AND TPB.Codigo_Tipo_Poliza_Sap = ISNULL(@piCodigo_Tipo_Poliza_Sap, TPB.Codigo_Tipo_Poliza_Sap)
				AND TPB.Codigo_Tipo_Bien = ISNULL(@piCodigo_Tipo_Bien, TPB.Codigo_Tipo_Bien)
			FOR		XML EXPLICIT	
	
	END TRY
	BEGIN CATCH
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Consultar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al obtener el registro.</MENSAJE><DETALLE>Se produjo un error al obtener los datos del tipo de póliza SUGEF. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 
	END CATCH
	
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Consultar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	RETURN 0
END