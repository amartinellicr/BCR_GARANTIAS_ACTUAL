USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Tipo_Poliza_Sugef', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Insertar_Tipo_Poliza_Sugef;
GO

CREATE PROCEDURE [dbo].[Insertar_Tipo_Poliza_Sugef]
	@piConsecutivo_Registro		INT	,
	@psNombre_Tipo_Poliza		VARCHAR(50),
	@psDescripcion_Tipo_Poliza	VARCHAR(500),
	@psRespuesta				VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Insertar_Tipo_Poliza_Sugef</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de insertar la informaci�n del tipo de p�liza SUGEF.
	</Descripci�n>
	<Entradas>
		@piConsecutivo_Registro			= Consecutivo del registro.
		@psNombre_Tipo_Poliza			= Nombre del tipo de p�liza SUGEF.
		@psDescripcion_Tipo_Poliza		= Descripci�n del tipo de p�liza, este texto aparecer� por medio de tooltip en la interfaz de usuario.
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>18/06/2014</Fecha>
	<Requerimiento>Req_P�lizas, Siebel No. 1-24342731</Requerimiento>
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
	
	IF EXISTS (	SELECT	1
				FROM	dbo.CAT_TIPOS_POLIZAS_SUGEF
				WHERE	Codigo_Tipo_Poliza_Sugef = @piConsecutivo_Registro
			   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>El registro ya existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos del tipo de p�liza SUGEF. El registro ya existe.</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Tipo_Pol_Sugef --Inicio
			BEGIN TRY
		
				INSERT	INTO dbo.CAT_TIPOS_POLIZAS_SUGEF (Codigo_Tipo_Poliza_Sugef, Nombre_Tipo_Poliza, Descripcion_Tipo_Poliza)
				VALUES	(@piConsecutivo_Registro, @psNombre_Tipo_Poliza, @psDescripcion_Tipo_Poliza)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Tipo_Pol_Sugef

				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
								    '<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos del tipo de p�liza SUGEF. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 2

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Tipo_Pol_Sugef --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La inserci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END