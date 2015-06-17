USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.pa_Modificar_Tipo_Garantia_Tarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Modificar_Tipo_Garantia_Tarjeta;
GO

CREATE PROCEDURE [dbo].[pa_Modificar_Tipo_Garantia_Tarjeta]

	@codigo_catalogo		INT,
	@numero_tarjeta			NUMERIC(16),
	@codigo_tipo_garantia	INT,
	@observaciones			VARCHAR(250),
	@cedula_deudor			VARCHAR(30),
	@cod_bin				INT,
	@cod_interno_sistar		INT,
	@cod_moneda				TINYINT,
	@cod_oficina_registra	SMALLINT

AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>pa_Modificar_Tipo_Garantia_Tarjeta</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que inserta y asocia la información de una garantía fiduciaria a una tarjeta.
	</Descripción>
	<Entradas>
			@codigo_catalogo		= Código del catálogo de garantías por perfil.
			@numero_tarjeta			= Número de la tarjeta
			@codigo_tipo_garantia	= Código del tipo de garantía.
			@observaciones			= Observación.
			@cedula_deudor			= Identificación del deudor.
			@cod_bin				= Código del bin.
			@cod_interno_sistar		= Código interno dentro del sistema de tarjetas
			@cod_moneda				= Código de la moneda.
			@cod_oficina_registra	= Código de la oficina que registra.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
	<Fecha>10/02/2008</Fecha>
	<Requerimiento>
			No aplica.
	</Requerimiento>
	<Versión>1.1</Versión>
	<Historial>
		<Cambio>
			<Autor>RArnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req Bcr Garantias Migración, Siebel No.1-24015441
			</Requerimiento>
			<Fecha>13/02/2014</Fecha>
			<Descripción>
				Se eliminan las referencias al BNX.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

/*Variable que almacena el código de la tarjeta*/
DECLARE	@codigo_tarjeta INT;

SET		@codigo_tarjeta = (	SELECT	cod_tarjeta
							FROM	dbo.TAR_TARJETA
							 WHERE	num_tarjeta = @numero_tarjeta)

/*Variable para el manejo de mensajes de error*/
DECLARE		@mensaje NUMERIC(1);

/*Variable para el manejo del error en la transacción*/
DECLARE		@error INT;

/*Inicio de la transacción*/
BEGIN TRAN

	/*Evalua que el código de la tarjeta exista*/
	IF(@codigo_tarjeta IS NULL OR @codigo_tarjeta = '')	
	BEGIN
		INSERT	INTO dbo.TAR_TARJETA (
			cedula_deudor, 
			num_tarjeta, 
			cod_bin, 
			cod_interno_sistar,
			cod_moneda,
			cod_oficina_registra,
			cod_tipo_garantia,
			cod_estado_tarjeta)
		VALUES (
			@cedula_deudor,
			@numero_tarjeta,
			@cod_bin,
			@cod_interno_sistar,
			@cod_moneda,
			@cod_oficina_registra,
			@codigo_tipo_garantia,
			'N')

		/*Evalua si se produjo un error*/
		SET		@error = @@Error
		IF(@error <> 0) 
		BEGIN
			GOTO	TratarError
		END

		/*obtiene el código de tarjeta generado para el registro*/
		SET		@codigo_tarjeta = SCOPE_IDENTITY();

		/*Inserta la información en la tabla TAR_GARANTIAS_x_PERFIL_X_TARJETA*/
		INSERT	INTO dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA (
			cod_tarjeta,
			observaciones)
		VALUES(
			@codigo_tarjeta,
			@observaciones)
		
		/*Evalua si se produjo un error*/
		SET		@error = @@Error
		IF(@error <> 0) 
		BEGIN
			GOTO	TratarError
		END

		SET		@mensaje = 1
	END
	ELSE
	BEGIN
		
		/*Modifica el código de tipo de garantía en la Tabla Tar_Tarjeta*/
		UPDATE	dbo.TAR_TARJETA 
		SET		cod_tipo_garantia = @codigo_tipo_garantia 
		WHERE	cod_tarjeta = @codigo_tarjeta
		
		/*Evalua si se produjo un error*/
		SET		@error = @@Error
		
		IF(@error <> 0) 
		BEGIN
			GOTO	TratarError
		END
		
		SET		@mensaje = 3

		/*Evalua que el código tipo de garantía sea por perfil*/
		IF EXISTS (	SELECT	1
			FROM	dbo.CAT_ELEMENTO
			WHERE	cat_catalogo = @codigo_catalogo
				AND cat_campo = @codigo_tipo_garantia)
		BEGIN

			/*Evalua si existe el código de la tarjeta en la tabla, si existe
			 *realiza una modificación y si no existe realiza el registro en 
			 *la tabla*/
			IF NOT EXISTS(	SELECT	1
							FROM	dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA
							WHERE	cod_tarjeta = @codigo_tarjeta)
			BEGIN

				/*Inserta la información en la tabla TAR_GARANTIAS_x_PERFIL_X_TARJETA*/
				INSERT	INTO dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA 
				(
					cod_tarjeta,
					observaciones
				)
				VALUES
				(
					@codigo_tarjeta,
					@observaciones
				)
				
				/*Evalua si se produjo un error*/
				SET		@error = @@Error
				
				IF(@error <> 0) 
				BEGIN
					GOTO	TratarError
				END

				/*elimina la información de la garantía fiduciaría que se encuentra
				 *en la tabla TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA*/
				DELETE	dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA 
				WHERE	cod_tarjeta = @codigo_tarjeta

				/*Evalua si se produjo un error*/
				SET		@error = @@Error
				
				IF(@error <> 0) 
				BEGIN
					GOTO	TratarError
				END
				
				SET		@mensaje = 2

			END
			ELSE
			BEGIN

				/*Modifica la información en la tabla TAR_GARANTIAS_x_PERFIL_X_TARJETA*/
				UPDATE	dbo.TAR_GARANTIAS_x_PERFIL_X_TARJETA 
				SET		observaciones = @observaciones 
				WHERE	cod_tarjeta = @codigo_tarjeta

				/*Evalua si se produjo un error*/
				SET		@error = @@Error
				
				IF(@error <> 0) 
				BEGIN
					GOTO	TratarError
				END
				
				SET		@mensaje = 3

			END
		END
		ELSE
		BEGIN

			/*elimina la información de la garantía por perfil que se encuentra
			 *en la tabla TAR_GARANTIAS_X_PERFIL_X_TARJETA*/
			DELETE	dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA 
			WHERE	cod_tarjeta = @codigo_tarjeta
			
			SET		@mensaje = 4
		
			/*Evalua si se produjo un error*/
			SET		@error = @@Error
			IF(@error <> 0) 
			BEGIN
				GOTO	TratarError
			END

		END
	END

/*Finaliza la transacciòn*/
COMMIT TRAN

/*acción que se ejcuta cuando se produce un error en la transacción*/
TratarError:
IF @error <> 0
BEGIN
	SET		@mensaje = 0
	ROLLBACK TRAN
END

SELECT	@mensaje mensaje

END
GO


