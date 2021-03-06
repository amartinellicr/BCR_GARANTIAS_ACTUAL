SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_EliminarBinTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_EliminarBinTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_EliminarBinTarjeta]
	@nNumeroBin int 
	
AS

/******************************************************************
<Nombre>pa_EliminarBinTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite eliminar un bin que se encuentra almacenado en la base 
			 de datos Garantías.
</Descripción>
<Entradas>
	@nNumeroBin = Número de bin que se desea eliminar
</Entradas>
<Salidas>
	@Mensaje	= Variable interna que utiliza para el manejo de mensajes que retorna el procedimiento de acuerdo a la operación realizada
	@Error		= Variable interna que se utiliza para el manejo de errores en caso que se produzcan, con el fin dejar la información en estado consistente.
</Salidas>
<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
<Fecha>07/05/2008</Fecha>
<Requerimiento>N/A</Requerimiento>
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

/*Variable para el manejo de mensajes de error*/
DECLARE @Mensaje NUMERIC(1);

/*Variable para el manejo del error en la transacción*/
DECLARE @Error INT;

BEGIN TRAN	

	IF EXISTS (SELECT 1
				   FROM TAR_BIN_SISTAR
				   WHERE bin = @nNumeroBin) 
	BEGIN
		SET @Mensaje = 0

		DELETE TAR_BIN_SISTAR WHERE bin = @nNumeroBin
		
		SET @Error = @@Error
		IF(@Error <> 0) 
			BEGIN
				GOTO TratarError
			END

	END
	ELSE
		BEGIN
			SET @Mensaje = 1	
		END

	
/*Finaliza la transacción*/
COMMIT TRAN

/*acción que se ejcuta cuando se produce un error en la transacción*/
TratarError:
IF (@Error <> 0)
BEGIN
	SET @Mensaje = 2
	ROLLBACK TRANSACTION
END
																																																																																																																	
SELECT @Mensaje Mensaje
