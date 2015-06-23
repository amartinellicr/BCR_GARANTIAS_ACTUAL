USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Eliminar_Tipo_Poliza_Sugef', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Eliminar_Tipo_Poliza_Sugef;
GO

CREATE PROCEDURE [dbo].[Eliminar_Tipo_Poliza_Sugef]
	@piConsecutivo_Registro		INT,
	@psRespuesta				VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Tipo_Poliza_Sugef</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de eliminar la informaci�n del tipo de p�liza SUGEF.
	</Descripci�n>
	<Entradas>
		@piConsecutivo_Registro			= Consecutivo del registro.
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
				FROM	dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN
				WHERE	Codigo_Tipo_Poliza_Sugef = @piConsecutivo_Registro
			   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al eliminar el registro. Est� asociado relacionado a un tipo de bien y a un tipo de p�liza SAP.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos del tipo de p�liza SUGEF. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION TRA_Eli_Tipo_Pol_Sugef --Inicio
			BEGIN TRY
			
				DELETE	FROM dbo.CAT_TIPOS_POLIZAS_SUGEF
				WHERE	Codigo_Tipo_Poliza_Sugef = @piConsecutivo_Registro

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Tipo_Pol_Sugef -- Error
				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Problema al eliminar el registro.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos del tipo de p�liza SUGEF. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 2 
			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Tipo_Pol_Sugef --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Poliza_Sugef</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La eliminaci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END