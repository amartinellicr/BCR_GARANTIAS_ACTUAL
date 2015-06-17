USE [GARANTIAS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Valuadores', 'P') IS NOT NULL
	DROP PROCEDURE Obtener_Valuadores;
GO

CREATE PROCEDURE [dbo].[Obtener_Valuadores]

	@piTipoValuador			TINYINT,
	@piDatosCompletos		BIT,
	@psRespuesta			VARCHAR(1000) OUTPUT
	
AS
BEGIN

/******************************************************************
	<Nombre>Obtener_Valuadores</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene la lista de valuadores registrados en el sistema.
	</Descripción>
	<Entradas>
			@piTipoValuador		= Tipo de valuador que debe ser obtenido, se usará 1 para los peritos y 2 para las empresas.
			@piDatosCompletos	= Indica si se deben obtener todos los datos del valuador (1) o sólo la lista bajo el formato identificación - nombre completo.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>05/04/2013</Fecha>
	<Requerimiento>Mantenimiento Valuaciones, Siebel No. 1-21537427</Requerimiento>
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
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	IF(@piDatosCompletos = 1)
	BEGIN
		IF(@piTipoValuador = 1)
		BEGIN
			
			SELECT	DISTINCT	
					1							AS Tag,
					NULL						AS Parent,
					'0'							AS [RESPUESTA!1!CODIGO!element], 
					NULL						AS [RESPUESTA!1!NIVEL!element], 
					NULL						AS [RESPUESTA!1!ESTADO!element], 
					'Obtener_Valuadores'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL						AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element], 
					NULL						AS [VALUADOR!3!nombre_valuador!element], 
					NULL						AS [VALUADOR!3!tipo_persona_valuador!element], 
					NULL						AS [VALUADOR!3!direccion_valuador!element], 
					NULL						AS [VALUADOR!3!telefono_valuador!element], 
					NULL						AS [VALUADOR!3!email_valuador!element]

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
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element], 
					NULL						AS [VALUADOR!3!nombre_valuador!element], 
					NULL						AS [VALUADOR!3!tipo_persona_valuador!element], 
					NULL						AS [VALUADOR!3!direccion_valuador!element], 
					NULL						AS [VALUADOR!3!telefono_valuador!element], 
					NULL						AS [VALUADOR!3!email_valuador!element]

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
					NULL						AS [VALUADORES!2!], 
					cedula_perito				AS [VALUADOR!3!cedula_valuador!element], 
					des_perito					AS [VALUADOR!3!nombre_valuador!element], 
					cod_tipo_persona			AS [VALUADOR!3!tipo_persona_valuador!element], 
					des_direccion				AS [VALUADOR!3!direccion_valuador!element], 
					des_telefono				AS [VALUADOR!3!telefono_valuador!element], 
					des_email					AS [VALUADOR!3!email_valuador!element]
			FROM	dbo.GAR_PERITO WITH (NOLOCK)
			ORDER BY	[VALUADOR!3!cedula_valuador!element]
			FOR		XML EXPLICIT

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Valuadores</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

			RETURN 0
		END
		ELSE
		BEGIN

			SELECT	DISTINCT	
					1							AS Tag,
					NULL						AS Parent,
					'0'							AS [RESPUESTA!1!CODIGO!element], 
					NULL						AS [RESPUESTA!1!NIVEL!element], 
					NULL						AS [RESPUESTA!1!ESTADO!element], 
					'Obtener_Valuadores'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL						AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element], 
					NULL						AS [VALUADOR!3!nombre_valuador!element], 
					NULL						AS [VALUADOR!3!tipo_persona_valuador!element], 
					NULL						AS [VALUADOR!3!direccion_valuador!element], 
					NULL						AS [VALUADOR!3!telefono_valuador!element], 
					NULL						AS [VALUADOR!3!email_valuador!element]

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
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element], 
					NULL						AS [VALUADOR!3!nombre_valuador!element], 
					NULL						AS [VALUADOR!3!tipo_persona_valuador!element], 
					NULL						AS [VALUADOR!3!direccion_valuador!element], 
					NULL						AS [VALUADOR!3!telefono_valuador!element], 
					NULL						AS [VALUADOR!3!email_valuador!element]

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
					NULL						AS [VALUADORES!2!], 
					cedula_empresa				AS [VALUADOR!3!cedula_valuador!element], 
					des_empresa					AS [VALUADOR!3!nombre_valuador!element], 
					NULL						AS [VALUADOR!3!tipo_persona_valuador!element], 
					des_direccion				AS [VALUADOR!3!direccion_valuador!element], 
					des_telefono				AS [VALUADOR!3!telefono_valuador!element], 
					des_email					AS [VALUADOR!3!email_valuador!element]
			FROM	dbo.GAR_EMPRESA WITH (NOLOCK)
			ORDER BY	[VALUADOR!3!cedula_valuador!element]
			FOR		XML EXPLICIT

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Valuadores</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

			RETURN 0
		END
	END
	ELSE
	BEGIN
		IF(@piTipoValuador = 1)
		BEGIN
			SELECT	DISTINCT	
					1							AS Tag,
					NULL						AS Parent,
					'0'							AS [RESPUESTA!1!CODIGO!element], 
					NULL						AS [RESPUESTA!1!NIVEL!element], 
					NULL						AS [RESPUESTA!1!ESTADO!element], 
					'Obtener_Valuadores'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL						AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element],
					NULL						AS [VALUADOR!3!datos_valuador!element] 

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
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element],
					NULL						AS [VALUADOR!3!datos_valuador!element] 


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
					NULL						AS [VALUADORES!2!], 
					'-1'						AS [VALUADOR!3!cedula_valuador!element],
					''							AS [VALUADOR!3!datos_valuador!element] 

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
					NULL						AS [VALUADORES!2!], 
					cedula_perito				AS [VALUADOR!3!cedula_valuador!element],
					cedula_perito + ' - ' +				
					des_perito					AS [VALUADOR!3!datos_valuador!element] 
			FROM	dbo.GAR_PERITO WITH (NOLOCK)
			ORDER BY	[VALUADOR!3!cedula_valuador!element]
			FOR		XML EXPLICIT

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Valuadores</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

			RETURN 0
		END
		ELSE
		BEGIN
			SELECT	DISTINCT	
					1							AS Tag,
					NULL						AS Parent,
					'0'							AS [RESPUESTA!1!CODIGO!element], 
					NULL						AS [RESPUESTA!1!NIVEL!element], 
					NULL						AS [RESPUESTA!1!ESTADO!element], 
					'Obtener_Valuadores'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
					NULL						AS [RESPUESTA!1!LINEA!element], 
					'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element],
					NULL						AS [VALUADOR!3!datos_valuador!element] 

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
					NULL						AS [VALUADORES!2!], 
					NULL						AS [VALUADOR!3!cedula_valuador!element],
					NULL						AS [VALUADOR!3!datos_valuador!element] 

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
					NULL						AS [VALUADORES!2!], 
					'-1'						AS [VALUADOR!3!cedula_valuador!element],
					''							AS [VALUADOR!3!datos_valuador!element] 
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
					NULL						AS [VALUADORES!2!], 
					cedula_empresa				AS [VALUADOR!3!cedula_valuador!element],
					cedula_empresa + ' - ' +				
					des_empresa					AS [VALUADOR!3!datos_valuador!element]

			FROM	dbo.GAR_EMPRESA WITH (NOLOCK)
			ORDER BY	[VALUADOR!3!cedula_valuador!element]
			FOR		XML EXPLICIT

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Valuadores</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

			RETURN 0
		END
	END
END