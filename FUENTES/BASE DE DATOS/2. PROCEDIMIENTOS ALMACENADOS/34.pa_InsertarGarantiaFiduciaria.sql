USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaFiduciaria', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaFiduciaria;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaFiduciaria]
	--Garantia fiduciaria
	@nTipoGarantia SMALLINT,
	@nClaseGarantia SMALLINT,
	@strCedulaFiador VARCHAR(25),
	@strNombreFiador VARCHAR(100),
	@nTipoFiador SMALLINT,
	--Garantia fiduciaria X Operacion
	@nOperacion BIGINT,
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

DECLARE @nGarantiaFiduciaria BIGINT

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
			cod_tipo_fiador,
			Fecha_Inserto
		)
		VALUES
		(
			@nTipoGarantia,
			@nClaseGarantia,
			@strCedulaFiador,
			@strNombreFiador,
			@nTipoFiador,
			GETDATE()
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
		cedula_acreedor,
		Fecha_Inserto
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
		@strCedulaAcreedor,
		GETDATE()
	)

COMMIT TRANSACTION
RETURN 0
