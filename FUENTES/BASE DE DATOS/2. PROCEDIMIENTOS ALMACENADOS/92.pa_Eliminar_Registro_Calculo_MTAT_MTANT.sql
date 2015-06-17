USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Eliminar_Registro_Calculo_MTAT_MTANT', 'P') IS NOT NULL
	DROP PROCEDURE Eliminar_Registro_Calculo_MTAT_MTANT;
GO

CREATE PROCEDURE [dbo].[Eliminar_Registro_Calculo_MTAT_MTANT]
	@psRespuesta		VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Registro_Calculo_MTAT_MTANT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de eliminar la información generada por la aplicación del cálculo de los montos de tasación 
		actualizada de terrenos y no terrenos, una vez que se han generado los archivos de respaldo.
	</Descripción>
	<Entradas>
		@pbTablaEliminar	= Indica la tabla temporal, usada por el proceso de cálculo de los montos de las tasaciones del terreno y no terreno, 
		                      que será limpiada. Siendo el valor 0 (cero) el indicador para limpiar la tabla "TMP_CALCULO_MTAT" y el valor
		                      1 para limpiar la tabla "TMP_CALCULO_MTANT".
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada.  
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

	BEGIN TRANSACTION TRA_Eli_Cal_MTAT_MTANT --Inicio
	
		DELETE FROM dbo.TMP_CALCULO_MTAT_MTANT       
		
		IF (@@ERROR <> 0) 
		BEGIN 
			ROLLBACK TRANSACTION TRA_Eli_Cal_MTAT_MTANT -- Error
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Registro_Calculo_MTAT_MTANT</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al limpiar la tabla TRA_Eli_Cal_MTAT_MTANT.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos del cálculo de los montos de la tasación actualizada del terreno y no terreno. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

			RETURN 1 
		END
	
	COMMIT TRANSACTION TRA_Eli_Cal_MTAT_MTANT --Fin
	
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Registro_Calculo_MTAT_MTANT</PROCEDIMIENTO><LINEA></LINEA>' + 
					'<MENSAJE>La eliminación de los datos, del cálculo de los montos de la tasación actualizada del terreno y no terreno, ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SELECT @psRespuesta

	RETURN 0
END