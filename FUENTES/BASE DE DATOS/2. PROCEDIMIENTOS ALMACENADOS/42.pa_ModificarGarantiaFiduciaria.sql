USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaFiduciaria', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaFiduciaria;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaFiduciaria]
	--Garantia fiduciaria
	@nGarantiaFiduciaria BIGINT,
	@nOperacion BIGINT,
	@strCedulaFiador VARCHAR(25),
	@strNombreFiador VARCHAR(100),
	@nTipoFiador SMALLINT,
	--Garantia fiduciaria X Operacion
	@nTipoMitigador SMALLINT,
	@nTipoDocumentoLegal SMALLINT,
	@nMontoMitigador DECIMAL(18,2),
	@nPorcentaje DECIMAL(5,2),
	@nOperacionEspecial SMALLINT,
	@nTipoAcreedor SMALLINT,
	@strCedulaAcreedor VARCHAR(30),
	--Bitacora
	@strUsuario VARCHAR(30),
	@strIP VARCHAR(20),
	@nOficina SMALLINT = NULL
AS

BEGIN TRANSACTION	

	UPDATE 
		 GAR_GARANTIA_FIDUCIARIA
	SET 
		cod_tipo_fiador = @nTipoFiador,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE()
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
		cedula_acreedor = @strCedulaAcreedor,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE()

	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_fiduciaria = @nGarantiaFiduciaria

COMMIT TRANSACTION
RETURN 0
