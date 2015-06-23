USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Eliminar_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Eliminar_Porcentaje_Aceptacion;
GO

CREATE PROCEDURE [dbo].[Eliminar_Porcentaje_Aceptacion]
	@piCodigo_Porcentaje_Aceptacion		INT,
	@psRespuesta				         VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Porcentaje_Aceptacion</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de eliminar la información del Porcentaje de Aceptacion.
	</Descripción>
	<Entradas>
		@@piCodigo_Porcentaje_Aceptacion			= Consecutivo del registro.
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>08/12/2014</Fecha>
	<Requerimiento>Req_Porce_Aceptacion, Siebel No. 1-24613011</Requerimiento>
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
	
	IF NOT EXISTS (	SELECT	1
				FROM	dbo.CAT_PORCENTAJE_ACEPTACION
				WHERE	Codigo_Porcentaje_Aceptacion = @piCodigo_Porcentaje_Aceptacion
			   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al eliminar el registro.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos del Porcentaje de Aceptación. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION TRA_Eli_Porcentaje_Aceptacion --Inicio
			BEGIN TRY
			
				DELETE	FROM dbo.CAT_PORCENTAJE_ACEPTACION
				WHERE	Codigo_Porcentaje_Aceptacion = @piCodigo_Porcentaje_Aceptacion

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Porcentaje_Aceptacion -- Error
					SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>Problema al eliminar el registro.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos del Porcentaje de Aceptación. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

					RETURN 2 
			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Porcentaje_Aceptacion --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La eliminación de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END