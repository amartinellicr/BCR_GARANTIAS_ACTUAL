SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaFiduciaria]
	--Garantia fiduciaria
	@nGarantiaFiduciaria bigint,
	@nOperacion bigint,
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
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_ModificarGarantiaFiduciaria</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite modificar la información de una garantía fiduciaria.</Descripción>
<Entradas>
	@nGarantiaFiduciaria	= Código de la garantía fiduciaria
	@nOperacion				= Consecutivo interno de la operación crediticia o del contrato
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
		 GAR_GARANTIA_FIDUCIARIA
	SET 
		cod_tipo_fiador = @nTipoFiador
	WHERE
		cedula_fiador = @strCedulaFiador
	

	UPDATE 
		 GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
	SET
		cod_tipo_mitigador = @nTipoMitigador,
		cod_tipo_documento_legal = @nTipoDocumentoLegal,
		monto_mitigador = @nMontoMitigador,
		porcentaje_responsabilidad = @nPorcentaje,
		cod_operacion_especial = @nOperacionEspecial,
		cod_tipo_acreedor = @nTipoAcreedor,
		cedula_acreedor = @strCedulaAcreedor
	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_fiduciaria = @nGarantiaFiduciaria

COMMIT TRANSACTION
RETURN 0


