SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarEstadoTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarEstadoTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_ModificarEstadoTarjeta] 
	@strNumeroTarjeta varchar(16),
	@strEstadoTarjeta varchar(1)
AS

/******************************************************************
<Nombre>pa_ModificarEstadoTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite modificar el estado de una tarjeta dentro de la base de 
             datos Garantías.
</Descripción>
<Entradas>
	@strNumeroTarjeta = Número de tarjeta a la que se le cambiará el estado.
	@strEstadoTarjeta = Nuevo estado que tendrá la tarjeta.
</Entradas>
<Salidas>
	@Mensaje = Variable interna que utiliza para el manejo de mensajes que retorna el procedimiento de acuerdo a la operación realizada
	@Error	 = Variable interna que se utiliza para el manejo de errores en caso que se produzcan, con el fin dejar la información en estado consistente.
</Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
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
			   FROM TAR_TARJETA
			   WHERE num_tarjeta = @strNumeroTarjeta) 
		BEGIN
			UPDATE 
				 TAR_TARJETA
			SET 
				cod_estado_tarjeta = @strEstadoTarjeta
			WHERE
				num_tarjeta = @strNumeroTarjeta 
			
			SET @Mensaje = 0
			/*Evalua si se produjo un error*/
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

