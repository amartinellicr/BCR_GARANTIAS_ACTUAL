USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaReal]
	--Garantia real
	@nGarantiaReal BIGINT,
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

BEGIN TRANSACTION	

	UPDATE 
		GAR_GARANTIA_REAL
	SET 
		cod_tipo_garantia_real = @nTipoGarantiaReal,
		cod_partido = @nPartido,
        numero_finca = @strNumFinca,
       	cod_grado = @nGrado,
       	cedula_hipotecaria = @nCedulaFiduciaria,
       	cod_clase_bien = @strClaseBien,
       	num_placa_bien = @strNumPlaca,
       	cod_tipo_bien = @nTipoBien,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE()
	WHERE
		cod_garantia_real = @nGarantiaReal
		
	

	UPDATE 
		GAR_GARANTIAS_REALES_X_OPERACION
	SET
		cod_tipo_mitigador = @nTipoMitigador,
		cod_tipo_documento_legal = @nTipoDocumentoLegal,
		monto_mitigador = @nMontoMitigador,
		cod_inscripcion = @nInscripcion,
		fecha_presentacion = @dFechaPresentacion,
		porcentaje_responsabilidad = @nPorcentaje,
		cod_grado_gravamen = @nGradoGravamen,
		cod_operacion_especial = @nOperacionEspecial,
		fecha_constitucion = @dFechaConstitucion,
		fecha_vencimiento = @dFechaVencimiento,
		cod_tipo_acreedor = @nTipoAcreedor,
		cedula_acreedor = @strCedulaAcreedor,
		cod_liquidez = @nLiquidez,
		cod_tenencia = @nTenencia,
		fecha_prescripcion = @dFechaPrescripcion,
		cod_moneda = @nMoneda,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE()

	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_real = @nGarantiaReal	
	
COMMIT TRANSACTION
RETURN 0
