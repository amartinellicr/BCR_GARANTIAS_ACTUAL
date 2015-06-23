USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaValor;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaValor]
	--Garantia valor
	@nTipoGarantia SMALLINT,
	@nClaseGarantia SMALLINT,
	@strNumeroSeguridad VARCHAR(30),
	@dFechaConstitucion DATETIME = NULL,
	@dFechaVencimiento DATETIME = NULL,
	@nClasificacion SMALLINT = NULL,
	@strInstrumento VARCHAR(25) = NULL,
	@strSerie VARCHAR(25) = NULL,
	@nTipoEmisor SMALLINT = NULL,
	@strCedulaEmisor VARCHAR(30) = NULL,
	@nPremio DECIMAL(5,2) = NULL,
	@strISIN VARCHAR(25) = NULL,
	@nValorFacial DECIMAL(18,2) = NULL,
	@nMonedaValorFacial SMALLINT = NULL,
	@nValorMercado DECIMAL(18,2) = NULL,
	@nMonedaValorMercado SMALLINT = NULL,
	@nTenencia SMALLINT = NULL,
	@dFechaPrescripcion DATETIME = NULL,
	--Garantia valor X Operacion
	@nOperacion BIGINT,
	@nTipoMitigador SMALLINT = NULL,
	@nTipoDocumentoLegal SMALLINT = NULL,
	@nMontoMitigador DECIMAL(18,2) = NULL,
	@nInscripcion SMALLINT = NULL,
	--@dFechaPresentacion datetime = NULL,
	@nPorcentaje DECIMAL(5,2) = NULL,
	@nGradoGravamen SMALLINT = NULL,
	@nGradoPrioridades SMALLINT = NULL,
	@nMontoPrioridades decimal(18,2) = NULL,
	@nOperacionEspecial SMALLINT = NULL,
	@nTipoAcreedor SMALLINT = NULL,
	@strCedulaAcreedor VARCHAR(30) = NULL,
	--Bitacora
	@strUsuario VARCHAR(30),
	@strIP VARCHAR(20),
	@nOficina SMALLINT = NULL
AS

DECLARE @nGarantiaValor BIGINT

BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_GARANTIA_VALOR
			WHERE cod_clase_garantia = @nClaseGarantia
			AND numero_seguridad = @strNumeroSeguridad) BEGIN

		INSERT INTO GAR_GARANTIA_VALOR
		(
			cod_tipo_garantia,
			cod_clase_garantia,
			numero_seguridad,
			fecha_constitucion,
			fecha_vencimiento_instrumento,
			cod_clasificacion_instrumento,
			des_instrumento,
			des_serie_instrumento,
			cod_tipo_emisor,
			cedula_emisor,
			premio,
			cod_isin,
			valor_facial,
			cod_moneda_valor_facial,
			valor_mercado,
			cod_moneda_valor_mercado,
			cod_tenencia,
			fecha_prescripcion,
			Fecha_Inserto
		)
		VALUES
		(
			@nTipoGarantia,
			@nClaseGarantia,
			@strNumeroSeguridad,
			@dFechaConstitucion,
			@dFechaVencimiento,
			@nClasificacion,
			@strInstrumento,
			@strSerie,
			@nTipoEmisor,
			@strCedulaEmisor,
			@nPremio,
			@strISIN,
			@nValorFacial,
			@nMonedaValorFacial,
			@nValorMercado,
			@nMonedaValorMercado,
			@nTenencia,
			@dFechaPrescripcion,
			GETDATE()
		)
	
		SET @nGarantiaValor = Scope_Identity()
	END
	ELSE BEGIN

		SELECT @nGarantiaValor = cod_garantia_valor
		FROM GAR_GARANTIA_VALOR
		WHERE cod_clase_garantia = @nClaseGarantia
		AND numero_seguridad = @strNumeroSeguridad
	END 

	INSERT INTO GAR_GARANTIAS_VALOR_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_valor,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		monto_mitigador,
		cod_inscripcion,
		--fecha_presentacion_registro,
		porcentaje_responsabilidad,
		cod_grado_gravamen,
		cod_grado_prioridades,
		monto_prioridades,
		cod_operacion_especial,
		cod_tipo_acreedor,
		cedula_acreedor,
		Fecha_Inserto
	)
	VALUES
	(
		@nOperacion,
		@nGarantiaValor,
		@nTipoMitigador,
		@nTipoDocumentoLegal,
		@nMontoMitigador,
		@nInscripcion,
		--@dFechaPresentacion,		
		@nPorcentaje,
		@nGradoGravamen,
		@nGradoPrioridades,
		@nMontoPrioridades,
		@nOperacionEspecial,
		@nTipoAcreedor,
		@strCedulaAcreedor,
		GETDATE()
	)

COMMIT TRANSACTION
RETURN 0
