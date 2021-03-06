USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarValuacionReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarValuacionReal;
GO

CREATE PROCEDURE [dbo].[pa_ModificarValuacionReal]
	--Garantia Real
	@nGarantiaReal BIGINT,
	@dFechaValuacion DATETIME,
	@strCedulaEmpresa varchar(25) = NULL,
	@strCedulaPerito varchar(25) = NULL,
	@nMontoUltimaTasacionTerreno MONEY = NULL,
	@nMontoUltimaTasacionNoTerreno MONEY = NULL,
	@nMontoTasacionActualizadaTerreno MONEY = NULL,
	@nMontoTasacionActualizadaNoTerreno MONEY = NULL,
	@dFechaUltimoSeguimiento DATETIME = NULL,
	@nMontoTotalAvaluo MONEY = NULL,
	@nRecomendacion SMALLINT = NULL,
	@nInspeccion SMALLINT = NULL,
	@dFechaConstruccion DATETIME = NULL,
	--Bitacora
	@strUsuario VARCHAR(30),
	@strIP VARCHAR(20),
	@nOficina SMALLINT = NULL
AS


BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_VALUACIONES_REALES
			WHERE cod_garantia_real = @nGarantiaReal
			AND convert(varchar(10),fecha_valuacion,111) = convert(varchar(10),@dFechaValuacion,111)) BEGIN

		UPDATE 
			GAR_VALUACIONES_REALES
		SET 
			cedula_empresa = @strCedulaEmpresa,
			cedula_perito = @strCedulaPerito,
			monto_ultima_tasacion_terreno = @nMontoUltimaTasacionTerreno,
			monto_ultima_tasacion_no_terreno = @nMontoUltimaTasacionNoTerreno,
			monto_tasacion_actualizada_terreno = @nMontoTasacionActualizadaTerreno,
			monto_tasacion_actualizada_no_terreno = @nMontoTasacionActualizadaNoTerreno,
			fecha_ultimo_seguimiento = @dFechaUltimoSeguimiento,
			monto_total_avaluo = @nMontoTotalAvaluo,
			cod_recomendacion_perito = @nRecomendacion,
			cod_inspeccion_menor_tres_meses = @nInspeccion,
			fecha_construccion = @dFechaConstruccion,
			Usuario_Modifico = @strUsuario,
			Fecha_Modifico = GETDATE()

		WHERE
			cod_garantia_real = @nGarantiaReal
			AND convert(varchar(10),fecha_valuacion,111) = convert(varchar(10),@dFechaValuacion,111)
	END	

COMMIT TRANSACTION
RETURN 0
