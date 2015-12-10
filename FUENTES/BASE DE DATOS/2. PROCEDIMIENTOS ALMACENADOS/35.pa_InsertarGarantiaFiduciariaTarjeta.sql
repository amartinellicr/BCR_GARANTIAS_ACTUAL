USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.pa_InsertarGarantiaFiduciariaTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaFiduciariaTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaFiduciariaTarjeta]
	--Garantia fiduciaria
	@piTipo_Garantia			SMALLINT,
	@piClase_Garantia			SMALLINT,
	@psCedula_Fiador			VARCHAR(25),
	@psNombre_Fiador			VARCHAR(100),
	@piTipo_Fiador				SMALLINT,
	--Garantia fiduciaria X Tarjeta
	@psTarjeta					VARCHAR(16),
	@piTipo_Mitigador			SMALLINT,
	@piTipo_Documento_Legal		SMALLINT,
	@pdMonto_Mitigador			DECIMAL(18,2),
	@pdPorcentaje_Responsabilidad DECIMAL(5,2),
	@piOperacion_Especial		SMALLINT,
	@piTipo_Acreedor			SMALLINT,
	@psCedula_Acreedor			VARCHAR(30),
	@pdtFecha_Expiracion		DATETIME,
	@pmMonto_Cobertura			MONEY,
	@psCedula_Deudor			VARCHAR(30),
	@piBIN						INT,
	@piCodigo_Interno_SISTAR	INT,
	@piMoneda					TINYINT,
	@piOficina_Registra			SMALLINT,
	@psObservacion				VARCHAR(150),
	@pdPorcentaje_Aceptacion	DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	--Catálogo
	@piCodigo_Catalogo			INT

AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>pa_InsertarGarantiaFiduciariaTarjeta</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que inserta y asocia la información de una garantía fiduciaria a una tarjeta.
	</Descripción>
	<Entradas>
			--Garantia fiduciaria
			@piTipo_Garantia			= Código del tipo de garantía.
			@piClase_Garantia			= Código de la clase de garantía.
			@psCedula_Fiador			= Identificación del fiador.
			@psNombre_Fiador			= Nombre del fiador.
			@piTipo_Fiador				= Código del tipo de personadel fiador
			--Garantia fiduciaria X Tarjeta
			@psTarjeta					= Número de la tarjeta
			@piTipo_Mitigador			= Código del tipo de mitigador de riesgo.
			@piTipo_Documento_Legal		= Código del tipo de documento legal.
			@pdMonto_Mitigador			= Monto mitigador de riesgo.
			@pdPorcentaje_Responsabilidad = Porcentaje de responsabilidad.
			@piOperacion_Especial		= Código del tipo de operación especial.
			@piTipo_Acreedor			= Código del tipo de persona del acreedor.
			@psCedula_Acreedor			= Indentificación del acreedor.
			@pdtFecha_Expiracion		= Fehca de expiración de la garantía.
			@pmMonto_Cobertura			= Monto de cobertura de la garantía.
			@psCedula_Deudor			= Identificación del deudor.
			@piBIN						= Código del bin.
			@piCodigo_Interno_SISTAR	= Código interno dentro del sistema de tarjetas
			@piMoneda					= Código de la moneda.
			@piOficina_Registra			= Código de la oficina que registra.
			@psObservacion				= Observación.
			@pdPorcentaje_Aceptacion	= Porcentaje de aceptación de la garantía.
			--Catálogo
			@piCodigo_Catalogo			= Código del catálogo de garantías por perfil.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
	<Fecha>05/02/2008</Fecha>
	<Requerimiento>
			No aplica.
	</Requerimiento>
	<Versión>1.1</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req Bcr Garantias Migración, Siebel No.1-24015441
			</Requerimiento>
			<Fecha>13/02/2014</Fecha>
			<Descripción>
				Se eliminan las referencias al BNX.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>04/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
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

/*Variable para el manejo de la llave de la tupla de la tarjeta*/
DECLARE		@nTarjeta INT

/*Variable para el manejo de la llave de la tupla de la garantía fiduciaria*/
DECLARE		@nGarantiaFiduciaria BIGINT

/*Variable para el manejo del código del tipo de garantía de la tarjeta*/
DECLARE		@nCodigoTipoGarantia INT

/*Variable para el manejo de mensajes de error*/
DECLARE		@mensaje NUMERIC(1);

/*Variable para el manejo del error en la transacción*/
DECLARE		@error INT;

/*Variable que controla si se inserta la garantía fiduciaria en la relación*/
DECLARE		@nInsertaGarFidu INT

BEGIN TRANSACTION	

	SET		@mensaje = 0

	IF NOT EXISTS (	SELECT	1
					FROM	dbo.TAR_TARJETA
					WHERE	num_tarjeta = @psTarjeta) 
	BEGIN

		INSERT	INTO dbo.TAR_TARJETA
		(
			num_tarjeta,
			cedula_deudor,
			cod_bin,
			cod_interno_sistar,
			cod_moneda,
			cod_oficina_registra,
			cod_tipo_garantia,
			cod_estado_tarjeta
		)
		VALUES
		(
			@psTarjeta,
			@psCedula_Deudor,
			@piBIN,
			@piCodigo_Interno_SISTAR,
			@piMoneda,
			@piOficina_Registra,
			1,
			'N'
		)

		/*Evalua si se produjo un error*/
		SET		@error = @@Error
		IF(@error <> 0)
		BEGIN
			SET		@mensaje = 1
			GOTO	TratarError
		END

		SET		@nTarjeta = Scope_Identity()
	END
	ELSE BEGIN

		SELECT	@nTarjeta = cod_tarjeta, 
				@nCodigoTipoGarantia = cod_tipo_garantia
		FROM	dbo.TAR_TARJETA
		WHERE	num_tarjeta = @psTarjeta		

	END

	IF NOT EXISTS (	SELECT	1
					FROM	dbo.TAR_GARANTIA_FIDUCIARIA
					WHERE	cedula_fiador = @psCedula_Fiador) 
	BEGIN

		INSERT INTO dbo.TAR_GARANTIA_FIDUCIARIA
		(
			cod_tipo_garantia,
			cod_clase_garantia,
			cedula_fiador,
			nombre_fiador,
			cod_tipo_fiador
		)
		VALUES
		(
			@piTipo_Garantia,
			@piClase_Garantia,
			@psCedula_Fiador,
			@psNombre_Fiador,
			@piTipo_Fiador
		)
		
		/*Evalua si se produjo un error*/
		SET		@error = @@Error
		IF(@error <> 0)
		BEGIN
			SET		@mensaje = 2
			GOTO	TratarError
		END

		SET		@nGarantiaFiduciaria = Scope_Identity()
	END
	ELSE BEGIN

		SELECT	@nGarantiaFiduciaria = cod_garantia_fiduciaria
		FROM	dbo.TAR_GARANTIA_FIDUCIARIA
		WHERE	cedula_fiador = @psCedula_Fiador		

	END 

	SET		@nInsertaGarFidu = 0

    IF (@nCodigoTipoGarantia <> 1)
	BEGIN
		/*Evalua que el código tipo de garantía sea por perfil*/
		IF EXISTS (	SELECT	1
					FROM	dbo.CAT_ELEMENTO
					WHERE	cat_catalogo = @piCodigo_Catalogo
						AND cat_campo = @nCodigoTipoGarantia)
		BEGIN
			/*Elimina la información de la garantía por perfil que se encuentra
			 *en la tabla TAR_GARANTIAS_X_PERFIL_X_TARJETA*/
			DELETE	dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA 
			WHERE	cod_tarjeta = @nTarjeta
			
			/*Evalua si se produjo un error*/
			SET		@error = @@Error
			IF(@error <> 0)
			BEGIN
				SET		@mensaje = 3
				GOTO	TratarError
			END

			/*Se actualiza el tipo de la tarjeta en la tabla Tar_Tarjeta, 
             *pasando de una garantía por perfil a la garantía fiduciaria*/
			UPDATE	dbo.TAR_TARJETA
			SET		cod_tipo_garantia = 1
			WHERE	cod_tarjeta = @nTarjeta

			/*Evalua si se produjo un error*/
			SET		@error = @@Error
			IF(@error <> 0)
			BEGIN
				SET		@mensaje = 4
				GOTO	TratarError
			END
		END
		ELSE
		BEGIN
			SET		@nInsertaGarFidu = 1
			SET		@mensaje = 5
			SET		@error = 1
			GOTO	TratarError
		END
	END

	IF(@nInsertaGarFidu = 0)
	BEGIN
		INSERT INTO dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA
		(
			cod_tarjeta, 
			cod_garantia_fiduciaria,
			cod_tipo_mitigador,
			cod_tipo_documento_legal,
			monto_mitigador,
			porcentaje_responsabilidad,
			cod_operacion_especial,
			cod_tipo_acreedor,
			cedula_acreedor,
			fecha_expiracion,	
			monto_cobertura,
			des_observacion,
			Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		)
		VALUES
		(
			@nTarjeta,
			@nGarantiaFiduciaria,
			@piTipo_Mitigador,
			@piTipo_Documento_Legal,
			@pdMonto_Mitigador,
			@pdPorcentaje_Responsabilidad,
			@piOperacion_Especial,
			@piTipo_Acreedor,
			@psCedula_Acreedor,
			@pdtFecha_Expiracion,
			@pmMonto_Cobertura,
			@psObservacion,
			@pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		)
		
		/*Evalua si se produjo un error*/
			SET		@error = @@Error
			IF(@error <> 0)
			BEGIN
				SET		@mensaje = 6
				GOTO	TratarError
			END
	END

/*Finaliza la transacción*/
COMMIT TRANSACTION


/*acción que se ejcuta cuando se produce un error en la transacción*/
TratarError:
IF (@error <> 0)
BEGIN
	ROLLBACK TRANSACTION
END

SELECT	@mensaje mensaje

END

GO


