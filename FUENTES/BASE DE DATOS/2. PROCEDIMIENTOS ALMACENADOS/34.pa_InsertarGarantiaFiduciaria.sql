SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaFiduciaria]
	--Garantia fiduciaria
	@nTipoGarantia smallint,
	@nClaseGarantia smallint,
	@strCedulaFiador varchar(25),
	@strNombreFiador varchar(100),
	@nTipoFiador smallint,
	--Garantia fiduciaria X Operacion
	@nOperacion bigint,
	@nTipoMitigador smallint,
	@nTipoDocumentoLegal smallint,
	@nMontoMitigador decimal(18,2),
	@nPorcentaje decimal(5,2),
	@nOperacionEspecial smallint,
	@nTipoAcreedor smallint,
	@strCedulaAcreedor varchar(30),
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_InsertarGarantiaFiduciaria</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite insertar la información de una garantía fiduciaria.</Descripción>
<Entradas>
	@nTipoGarantia			= Código de tipo de garantía
	@nClaseGarantia			= Código de la clase de garantía
	@strCedulaFiador		= Cédula del fiador
	@strNombreFiador		= Nombre del fiador
	@nTipoFiador			= Código de tipo de persona del fiador
	@nOperacion				= Consecutivo interno de la operación crediticia o del contrato
	@nTipoMitigador			= Código de tipo mitigador riesgo
	@nTipoDocumentoLegal	= Código de tipo de documento legal
	@nMontoMitigador		= Monto mitigador
	@nPorcentaje			= Porcentaje de responsabilidad
	@nOperacionEspecial		= Código de operación especial
	@nTipoAcreedor			= Código de persona del acreedor
	@strCedulaAcreedor		= Cédula del acreedor
	@strUsuario				= Usuario que realiza la transacción
	@strIP					= IP de la máquina donde se realiza la transacción
	@nOficina				= Oficina donde se realiza la transacción
</Entradas>
<Salidas></Salidas>
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

DECLARE @nGarantiaFiduciaria bigint

BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_GARANTIA_FIDUCIARIA
			WHERE cedula_fiador = @strCedulaFiador) BEGIN

		INSERT INTO GAR_GARANTIA_FIDUCIARIA
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
	
		SET @nGarantiaFiduciaria = Scope_Identity()
	END
	ELSE BEGIN

		SELECT @nGarantiaFiduciaria = cod_garantia_fiduciaria
		FROM GAR_GARANTIA_FIDUCIARIA
		WHERE cedula_fiador = @strCedulaFiador		

	END 

	INSERT INTO GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_fiduciaria,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		monto_mitigador,
		porcentaje_responsabilidad,
		cod_operacion_especial,
		cod_tipo_acreedor,
		cedula_acreedor
	)
	VALUES
	(
		@nOperacion,
		@nGarantiaFiduciaria,
		@nTipoMitigador,
		@nTipoDocumentoLegal,
		@nMontoMitigador,
		@nPorcentaje,
		@nOperacionEspecial,
		@nTipoAcreedor,
		@strCedulaAcreedor
	)

COMMIT TRANSACTION
RETURN 0


