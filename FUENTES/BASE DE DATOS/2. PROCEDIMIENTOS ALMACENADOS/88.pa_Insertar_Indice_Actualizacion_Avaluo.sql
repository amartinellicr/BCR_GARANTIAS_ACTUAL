USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Indice_Actualizacion_Avaluo', 'P') IS NOT NULL
	DROP PROCEDURE Insertar_Indice_Actualizacion_Avaluo;
GO

CREATE PROCEDURE [dbo].[Insertar_Indice_Actualizacion_Avaluo]
	@pdFechaHora					DATETIME,
	@pmTipo_Cambio					DECIMAL(18, 2),
	@pmIndice_Precios_Consumidor	DECIMAL(18, 2),
	@psCedula_Usuario				VARCHAR(30),
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Insertar_Indice_Actualizacion_Avaluo</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de insertar la informaci�n de los �ndices de actualizaci�n de aval�os.
	</Descripci�n>
	<Entradas>
		@pdFechaHora					= Fecha y hora del registro.
		@pmTipo_Cambio					= Tipo de cambio a ser registrado.
		@pmIndice_Precios_Consumidor	= Indece de precios al consumidor a ser registrado.
		@psCedula_Usuario				= Identificaci�n del usuario que realiza la consulta. 
                                  			Este es dato llave usado para la b�squeda de los registros que deben 
                                  			ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>04/11/2013</Fecha>
	<Requerimiento>Req_Calculo de Campo Terreno Actualizado, Siebel No. 1-24077731</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish

	DECLARE		
		@vdFechaInsertar	DATETIME, --Fecha que ser� insertada
		@vdFechaMaxima		DATETIME  --Fecha m�xima registrada en la tabla, para un mismo d�a.
		
	--Se obtiene la parte de la fecha del dato que fue proporcionado
	SET	@vdFechaInsertar = CONVERT(DATETIME,CAST(@pdFechaHora AS VARCHAR(11)),101)
		
	SET @vdFechaMaxima = (	SELECT	MAX(Fecha_Hora)
							FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO WITH (NOLOCK)
							WHERE	CONVERT(DATETIME,CAST(Fecha_Hora AS VARCHAR(11)),101) = @vdFechaInsertar)
	
	--Se verifica si existe o no la fecha registrada, si existe a la nueva fecha se le suma una hora.
	IF(@vdFechaMaxima IS NULL)
	BEGIN
		SET	@vdFechaInsertar = @pdFechaHora
	END
	ELSE
	BEGIN
		SET @vdFechaInsertar = DATEADD(HOUR, 1, @vdFechaMaxima)
	END

	BEGIN TRANSACTION TRA_Ins_Indice_Act_Avaluo --Inicio
	
	INSERT INTO dbo.CAT_INDICES_ACTUALIZACION_AVALUO (
		Fecha_Hora, 
		Tipo_Cambio, 
		Indice_Precios_Consumidor)
	VALUES (
		@vdFechaInsertar,
		@pmTipo_Cambio,
		@pmIndice_Precios_Consumidor)
	
	IF (@@ERROR <> 0) 
	BEGIN 
		ROLLBACK TRANSACTION TRA_Ins_Indice_Act_Avaluo -- Error
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Indice_Actualizacion_Avaluo</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de los �ndices de actualizaci�n de aval�os. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 
	END
	
	COMMIT TRANSACTION TRA_Ins_Indice_Act_Avaluo --Fin
	
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Indice_Actualizacion_Avaluo</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La inserci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SELECT @psRespuesta

	RETURN 0
END