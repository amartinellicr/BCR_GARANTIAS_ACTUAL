USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Indice_Actualizacion_Avaluo', 'P') IS NOT NULL
	DROP PROCEDURE Consultar_Indice_Actualizacion_Avaluo;
GO

CREATE PROCEDURE [dbo].[Consultar_Indice_Actualizacion_Avaluo]
	@piAnno					INT,
	@piMes					TINYINT,
	@piTipo_Conculta		TINYINT
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Indice_Actualizacion_Avaluo</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a los índices de actualización de avalúos.
	</Descripción>
	<Entradas>
		@piAnno					= Año para el cual se requiere extraer la información.
		@piMes					= Mes para el cual se requiere extraer la información.
		@piTipo_Conculta		= Indica el tipo de consulta del a que se trata, a saber: 
										0 = Si se debe extraer el más reciente. 
										1 = Si se debe extraer el histórico.
										2 = Si se debe extraer la lista de años registrados.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>04/11/2013</Fecha>
	<Requerimiento>Req_Calculo de Campo Terreno Actualizado, Siebel No. 1-24077731</Requerimiento>
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

	IF(@piTipo_Conculta = 0) --Se extrae el más reciente.
	BEGIN
		SELECT	DISTINCT 	
				1											AS Tag,
				NULL										AS Parent,
				'0'											AS [RESPUESTA!1!CODIGO!element], 
				NULL										AS [RESPUESTA!1!NIVEL!element], 
				NULL										AS [RESPUESTA!1!ESTADO!element], 
				'Consultar_Indice_Actualizacion_Avaluo'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL										AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
				NULL										AS [DETALLE!2!], 
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				Fecha_Hora									AS [INDICE!4!Fecha_Hora!element],
				Tipo_Cambio									AS [INDICE!4!Tipo_Cambio!element], 
				Indice_Precios_Consumidor					AS [INDICE!4!Indice_Precios_Consumidor!element]
		FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO WITH (NOLOCK)
		WHERE	Fecha_Hora = (	SELECT	MAX(Fecha_Hora)
								FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO WITH (NOLOCK))
		FOR		XML EXPLICIT	
	END
	ELSE IF(@piTipo_Conculta = 1) --Se extrae el histórico
	BEGIN
		SELECT	DISTINCT 	
				1											AS Tag,
				NULL										AS Parent,
				'0'											AS [RESPUESTA!1!CODIGO!element], 
				NULL										AS [RESPUESTA!1!NIVEL!element], 
				NULL										AS [RESPUESTA!1!ESTADO!element], 
				'Consultar_Indice_Actualizacion_Avaluo'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL										AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
				NULL										AS [DETALLE!2!], 
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Fecha_Hora!element],
				NULL										AS [INDICE!4!Tipo_Cambio!element], 
				NULL										AS [INDICE!4!Indice_Precios_Consumidor!element]

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
				NULL										AS [INDICES!3!],
				Fecha_Hora									AS [INDICE!4!Fecha_Hora!element],
				Tipo_Cambio									AS [INDICE!4!Tipo_Cambio!element], 
				Indice_Precios_Consumidor					AS [INDICE!4!Indice_Precios_Consumidor!element]
		FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO WITH (NOLOCK)
		WHERE	DATEPART(YEAR, Fecha_Hora)	= @piAnno
			AND	DATEPART(MONTH, Fecha_Hora) = @piMes
		ORDER BY	[INDICE!4!Fecha_Hora!element]
		FOR		XML EXPLICIT
	END
	ELSE IF(@piTipo_Conculta = 2) --Se extrae la lista de años registrados
	BEGIN
		SELECT	DISTINCT 	
				1											AS Tag,
				NULL										AS Parent,
				'0'											AS [RESPUESTA!1!CODIGO!element], 
				NULL										AS [RESPUESTA!1!NIVEL!element], 
				NULL										AS [RESPUESTA!1!ESTADO!element], 
				'Consultar_Indice_Actualizacion_Avaluo'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL										AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
				NULL										AS [DETALLE!2!], 
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Anno!element]
				
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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Anno!element]

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
				NULL										AS [INDICES!3!],
				NULL										AS [INDICE!4!Anno!element]

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
				NULL										AS [INDICES!3!],
				DATEPART(YEAR, Fecha_Hora)					AS [INDICE!4!Anno!element]
		FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO WITH (NOLOCK)
		ORDER BY	[INDICE!4!Anno!element]
		FOR		XML EXPLICIT
	END 
END