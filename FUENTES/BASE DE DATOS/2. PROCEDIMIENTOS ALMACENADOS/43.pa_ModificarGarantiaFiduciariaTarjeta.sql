SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaFiduciariaTarjeta]
	--Garantia fiduciaria
	@nGarantiaFiduciaria bigint,
	@nTarjeta int,
	@strCedulaFiador varchar(25),
	@strNombreFiador varchar(100),
	@nTipoFiador smallint,
	--Garantia fiduciaria X Operacion
	@nTipoMitigador smallint,
	@nTipoDocumentoLegal smallint,
	@nMontoMitigador decimal(18,2),
	@nPorcentaje decimal(5,2),
	@nOperacionEspecial smallint,
	@nTipoAcreedor smallint,
	@strCedulaAcreedor varchar(30),
	@dFechaExpiracion datetime,
	@nMontoCobertura money,
	@strObservacion varchar(150),
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_ModificarGarantiaFiduciariaTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite modificar la información de una garantía fiduciaria 
             para una tarjeta específica.
</Descripción>
<Entradas>
	@nGarantiaFiduciaria	= Código de la garantía fiduciaria
	@nTarjeta				= Consecutivo interno de la tarjeta
	@strCedulaFiador		= Cédula del fiador
	@strNombreFiador		= Nombre del fiador
	@nTipoFiador			= Código de tipo de persona del fiador
	@nTipoMitigador			= Código de tipo mitigador riesgo
	@nTipoDocumentoLegal	= Código de tipo de documento legal
	@nMontoMitigador		= Monto mitigador
	@nPorcentaje			= Porcentaje de responsabilidad
	@nOperacionEspecial		= Código de operación especial
	@nTipoAcreedor			= Código de persona del acreedor
	@strCedulaAcreedor		= Cédula del acreedor
	@dFechaExpiracion		= Fecha en que expira la tarjeta.
	@nMontoCobertura		= Monto que cubre el fiador.
	@strObservacion			= Cadena que almacena cualquier observación que el usuario registre.
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

BEGIN TRANSACTION	

	UPDATE 
		 TAR_GARANTIA_FIDUCIARIA
	SET 
		cod_tipo_fiador = @nTipoFiador
	WHERE
		cedula_fiador = @strCedulaFiador
	

	UPDATE 
		 TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA
	SET
		cod_tipo_mitigador = @nTipoMitigador,
		cod_tipo_documento_legal = @nTipoDocumentoLegal,
		monto_mitigador = @nMontoMitigador,
		porcentaje_responsabilidad = @nPorcentaje,
		cod_operacion_especial = @nOperacionEspecial,
		cod_tipo_acreedor = @nTipoAcreedor,
		cedula_acreedor = @strCedulaAcreedor,
		fecha_expiracion = @dFechaExpiracion,
		monto_cobertura = @nMontoCobertura,
		des_observacion = @strObservacion
	WHERE
		cod_tarjeta = @nTarjeta
		AND cod_garantia_fiduciaria = @nGarantiaFiduciaria

COMMIT TRANSACTION
RETURN 0


