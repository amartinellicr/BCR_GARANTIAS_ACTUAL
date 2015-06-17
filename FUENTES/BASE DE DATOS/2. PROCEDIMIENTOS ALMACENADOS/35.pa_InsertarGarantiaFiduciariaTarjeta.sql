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
	@nTipoGarantia			SMALLINT,
	@nClaseGarantia			SMALLINT,
	@strCedulaFiador		VARCHAR(25),
	@strNombreFiador		VARCHAR(100),
	@nTipoFiador			SMALLINT,
	--Garantia fiduciaria X Tarjeta
	@strTarjeta				VARCHAR(16),
	@nTipoMitigador			SMALLINT,
	@nTipoDocumentoLegal	SMALLINT,
	@nMontoMitigador		DECIMAL(18,2),
	@nPorcentaje			DECIMAL(5,2),
	@nOperacionEspecial		SMALLINT,
	@nTipoAcreedor			SMALLINT,
	@strCedulaAcreedor		VARCHAR(30),
	@dFechaExpiracion		DATETIME,
	@nMontoCobertura		MONEY,
	@strCedulaDeudor		VARCHAR(30),
	@nBIN					INT,
	@nCodigoInternoSISTAR	INT,
	@nMoneda				TINYINT,
	@nOficinaRegistra		SMALLINT,
	@strObservacion			VARCHAR(150),
	--Catálogo
	@codigo_catalogo		INT,
	--Bitacora
	@strUsuario				VARCHAR(30),
	@strIP					VARCHAR(20),
	@nOficina				SMALLINT = NULL

AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>pa_InsertarGarantiaFiduciariaTarjeta</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que inserta y asocia la información de una garantía fiduciaria a una tarjeta.
	</Descripción>
	<Entradas>
			--Garantia fiduciaria
			@nTipoGarantia			= Código del tipo de garantía.
			@nClaseGarantia			= Código de la clase de garantía.
			@strCedulaFiador		= Identificación del fiador.
			@strNombreFiador		= Nombre del fiador.
			@nTipoFiador			= Código del tipo de personadel fiador
			--Garantia fiduciaria X Tarjeta
			@strTarjeta				= Número de la tarjeta
			@nTipoMitigador			= Código del tipo de mitigador de riesgo.
			@nTipoDocumentoLegal	= Código del tipo de documento legal.
			@nMontoMitigador		= Monto mitigador de riesgo.
			@nPorcentaje			= Porcentaje de aceptación.
			@nOperacionEspecial		= Código del tipo de operación especial.
			@nTipoAcreedor			= Código del tipo de persona del acreedor.
			@strCedulaAcreedor		= Indentificación del acreedor.
			@dFechaExpiracion		= Fehca de expiración de la garantía.
			@nMontoCobertura		= Monto de cobertura de la garantía.
			@strCedulaDeudor		= Identificación del deudor.
			@nBIN					= Código del bin.
			@nCodigoInternoSISTAR	= Código interno dentro del sistema de tarjetas
			@nMoneda				= Código de la moneda.
			@nOficinaRegistra		= Código de la oficina que registra.
			@strObservacion			= Observación.
			--Catálogo
			@codigo_catalogo		= Código del catálogo de garantías por perfil.
			--Bitacora
			@strUsuario				= Identificación del usuario que realiza la inserción.
			@strIP					= Dirección IP de la máquina desde donde se realiza la inserción.
			@nOficina				= Códigode la oficina desde donde se realiza la inserción.
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

	SET @mensaje = 0

	IF NOT EXISTS (	SELECT	1
					FROM	dbo.TAR_TARJETA
					WHERE	num_tarjeta =	@strTarjeta) BEGIN

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
			@strTarjeta,
			@strCedulaDeudor,
			@nBIN,
			@nCodigoInternoSISTAR,
			@nMoneda,
			@nOficinaRegistra,
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
		WHERE	num_tarjeta = @strTarjeta		

	END

	IF NOT EXISTS (	SELECT	1
					FROM	dbo.TAR_GARANTIA_FIDUCIARIA
					WHERE	cedula_fiador = @strCedulaFiador) BEGIN

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
			@nTipoGarantia,
			@nClaseGarantia,
			@strCedulaFiador,
			@strNombreFiador,
			@nTipoFiador
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
		WHERE	cedula_fiador = @strCedulaFiador		

	END 

	SET		@nInsertaGarFidu = 0

    IF (@nCodigoTipoGarantia <> 1)
	BEGIN
		/*Evalua que el código tipo de garantía sea por perfil*/
		IF EXISTS (	SELECT	1
					FROM	dbo.CAT_ELEMENTO
					WHERE	cat_catalogo = @codigo_catalogo
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
			des_observacion
		)
		VALUES
		(
			@nTarjeta,
			@nGarantiaFiduciaria,
			@nTipoMitigador,
			@nTipoDocumentoLegal,
			@nMontoMitigador,
			@nPorcentaje,
			@nOperacionEspecial,
			@nTipoAcreedor,
			@strCedulaAcreedor,
			@dFechaExpiracion,
			@nMontoCobertura,
			@strObservacion
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


