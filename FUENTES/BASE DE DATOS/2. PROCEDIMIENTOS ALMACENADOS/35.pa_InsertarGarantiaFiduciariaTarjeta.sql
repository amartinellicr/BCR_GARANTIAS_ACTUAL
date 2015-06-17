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
	--Cat�logo
	@codigo_catalogo		INT,
	--Bitacora
	@strUsuario				VARCHAR(30),
	@strIP					VARCHAR(20),
	@nOficina				SMALLINT = NULL

AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>pa_InsertarGarantiaFiduciariaTarjeta</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que inserta y asocia la informaci�n de una garant�a fiduciaria a una tarjeta.
	</Descripci�n>
	<Entradas>
			--Garantia fiduciaria
			@nTipoGarantia			= C�digo del tipo de garant�a.
			@nClaseGarantia			= C�digo de la clase de garant�a.
			@strCedulaFiador		= Identificaci�n del fiador.
			@strNombreFiador		= Nombre del fiador.
			@nTipoFiador			= C�digo del tipo de personadel fiador
			--Garantia fiduciaria X Tarjeta
			@strTarjeta				= N�mero de la tarjeta
			@nTipoMitigador			= C�digo del tipo de mitigador de riesgo.
			@nTipoDocumentoLegal	= C�digo del tipo de documento legal.
			@nMontoMitigador		= Monto mitigador de riesgo.
			@nPorcentaje			= Porcentaje de aceptaci�n.
			@nOperacionEspecial		= C�digo del tipo de operaci�n especial.
			@nTipoAcreedor			= C�digo del tipo de persona del acreedor.
			@strCedulaAcreedor		= Indentificaci�n del acreedor.
			@dFechaExpiracion		= Fehca de expiraci�n de la garant�a.
			@nMontoCobertura		= Monto de cobertura de la garant�a.
			@strCedulaDeudor		= Identificaci�n del deudor.
			@nBIN					= C�digo del bin.
			@nCodigoInternoSISTAR	= C�digo interno dentro del sistema de tarjetas
			@nMoneda				= C�digo de la moneda.
			@nOficinaRegistra		= C�digo de la oficina que registra.
			@strObservacion			= Observaci�n.
			--Cat�logo
			@codigo_catalogo		= C�digo del cat�logo de garant�as por perfil.
			--Bitacora
			@strUsuario				= Identificaci�n del usuario que realiza la inserci�n.
			@strIP					= Direcci�n IP de la m�quina desde donde se realiza la inserci�n.
			@nOficina				= C�digode la oficina desde donde se realiza la inserci�n.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Roger Rodr�guez, Lidersoft Internacional S.A.</Autor>
	<Fecha>05/02/2008</Fecha>
	<Requerimiento>
			No aplica.
	</Requerimiento>
	<Versi�n>1.1</Versi�n>
	<Historial>
		<Cambio>
			<Autor>RArnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req Bcr Garantias Migraci�n, Siebel No.1-24015441
			</Requerimiento>
			<Fecha>13/02/2014</Fecha>
			<Descripci�n>
				Se eliminan las referencias al BNX.
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

/*Variable para el manejo de la llave de la tupla de la tarjeta*/
DECLARE		@nTarjeta INT

/*Variable para el manejo de la llave de la tupla de la garant�a fiduciaria*/
DECLARE		@nGarantiaFiduciaria BIGINT

/*Variable para el manejo del c�digo del tipo de garant�a de la tarjeta*/
DECLARE		@nCodigoTipoGarantia INT

/*Variable para el manejo de mensajes de error*/
DECLARE		@mensaje NUMERIC(1);

/*Variable para el manejo del error en la transacci�n*/
DECLARE		@error INT;

/*Variable que controla si se inserta la garant�a fiduciaria en la relaci�n*/
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
		/*Evalua que el c�digo tipo de garant�a sea por perfil*/
		IF EXISTS (	SELECT	1
					FROM	dbo.CAT_ELEMENTO
					WHERE	cat_catalogo = @codigo_catalogo
						AND cat_campo = @nCodigoTipoGarantia)
		BEGIN
			/*Elimina la informaci�n de la garant�a por perfil que se encuentra
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
             *pasando de una garant�a por perfil a la garant�a fiduciaria*/
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

/*Finaliza la transacci�n*/
COMMIT TRANSACTION


/*acci�n que se ejcuta cuando se produce un error en la transacci�n*/
TratarError:
IF (@error <> 0)
BEGIN
	ROLLBACK TRANSACTION
END

SELECT	@mensaje mensaje

END

GO


