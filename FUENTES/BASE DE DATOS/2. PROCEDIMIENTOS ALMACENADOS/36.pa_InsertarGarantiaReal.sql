USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaReal]
	--Garantia real
	@nTipoGarantia SMALLINT,
	@nClaseGarantia SMALLINT,
	@nTipoGarantiaReal SMALLINT,
	@nPartido SMALLINT = NULL,
	@strNumFinca VARCHAR(20) = NULL,
	@nGrado SMALLINT = NULL,
	@nCedulaFiduciaria SMALLINT = NULL,
	@strClaseBien VARCHAR(3) = NULL,
	@strNumPlaca VARCHAR(12) = NULL,
	@nTipoBien SMALLINT = NULL,
	--Garantia real X Operacion
	@nOperacion BIGINT,
	@nTipoMitigador SMALLINT = NULL,
	@nTipoDocumentoLegal SMALLINT = NULL,
	@nMontoMitigador DECIMAL(18,2),
	@nInscripcion SMALLINT = NULL,
	@dFechaPresentacion DATETIME,
	@nPorcentaje DECIMAL(5,2),
	@nGradoGravamen SMALLINT,
	@nOperacionEspecial SMALLINT = NULL,
	@dFechaConstitucion DATETIME,
	@dFechaVencimiento DATETIME,
	@nTipoAcreedor SMALLINT = NULL,
	@strCedulaAcreedor VARCHAR(30) = NULL,
	@nLiquidez SMALLINT,
	@nTenencia SMALLINT,
	@dFechaPrescripcion DATETIME,
	@nMoneda SMALLINT,
	--Bitacora
	@strUsuario VARCHAR(30),
	@strIP VARCHAR(20),
	@nOficina SMALLINT = NULL
AS

DECLARE @nGarantiaReal BIGINT

BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_GARANTIA_REAL
			WHERE cod_clase_garantia = @nClaseGarantia
			AND cod_tipo_garantia_real = @nTipoGarantiaReal
			AND cod_partido = @nPartido
			AND numero_finca = @strNumFinca
			AND cod_grado = @nGrado
			AND cedula_hipotecaria = @nCedulaFiduciaria
			AND cod_clase_bien = @strClaseBien
			AND num_placa_bien = @strNumPlaca) BEGIN

		INSERT INTO GAR_GARANTIA_REAL
		(
			cod_tipo_garantia,
			cod_clase_garantia,
			cod_tipo_garantia_real,
			cod_partido,
			numero_finca,
			cod_grado,
			cedula_hipotecaria,
			cod_clase_bien,
			num_placa_bien,
			cod_tipo_bien,
			Fecha_Inserto
		)
		VALUES
		(
			@nTipoGarantia,
			@nClaseGarantia,
			@nTipoGarantiaReal,
			@nPartido,
			@strNumFinca,
			@nGrado,
			@nCedulaFiduciaria,
			@strClaseBien,
			@strNumPlaca,
			@nTipoBien,
			GETDATE()
		)
	
		SET @nGarantiaReal = Scope_Identity()
	END
	ELSE BEGIN

		SELECT @nGarantiaReal = cod_garantia_real
		FROM GAR_GARANTIA_REAL
		WHERE cod_clase_garantia = @nClaseGarantia
		AND cod_tipo_garantia_real = @nTipoGarantiaReal
		AND cod_partido = @nPartido
		AND numero_finca = @strNumFinca
		AND cod_grado = @nGrado
		AND cedula_hipotecaria = @nCedulaFiduciaria
		AND cod_clase_bien = @strClaseBien
		AND num_placa_bien = @strNumPlaca		
	END 

	INSERT INTO GAR_GARANTIAS_REALES_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_real,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		monto_mitigador,
		cod_inscripcion,
		fecha_presentacion,
		porcentaje_responsabilidad,
		cod_grado_gravamen,
		cod_operacion_especial,
		fecha_constitucion,
		fecha_vencimiento,
		cod_tipo_acreedor,
		cedula_acreedor,
		cod_liquidez,
		cod_tenencia,
		fecha_prescripcion,
		cod_moneda,
		Fecha_Inserto
	)
	VALUES
	(
		@nOperacion,
		@nGarantiaReal,
		@nTipoMitigador,
		@nTipoDocumentoLegal,
		@nMontoMitigador,
		@nInscripcion,
		@dFechaPresentacion,		
		@nPorcentaje,
		@nGradoGravamen,
		@nOperacionEspecial,
		@dFechaConstitucion,
		@dFechaVencimiento,
		@nTipoAcreedor,
		@strCedulaAcreedor,
		@nLiquidez,
		@nTenencia,
		@dFechaPrescripcion,
		@nMoneda,
		GETDATE()
	)

COMMIT TRANSACTION
RETURN 0
