USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarValuacionReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarValuacionReal;
GO

CREATE PROCEDURE [dbo].[pa_InsertarValuacionReal]
	--Garantia Real
	@nGarantiaReal BIGINT,
	@dFechaValuacion DATETIME,
	@strCedulaEmpresa VARCHAR(25) = NULL,
	@strCedulaPerito VARCHAR(25) = NULL,
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
			AND fecha_valuacion = @dFechaValuacion) BEGIN

		INSERT INTO GAR_VALUACIONES_REALES
		(
			cod_garantia_real,
			fecha_valuacion,
			cedula_empresa,
			cedula_perito,
			monto_ultima_tasacion_terreno,
			monto_ultima_tasacion_no_terreno,
			monto_tasacion_actualizada_terreno,
			monto_tasacion_actualizada_no_terreno,
			fecha_ultimo_seguimiento,
			monto_total_avaluo,
			cod_recomendacion_perito,
			cod_inspeccion_menor_tres_meses,
			fecha_construccion,
			Fecha_Inserto
		)
		VALUES
		(
			@nGarantiaReal,
			@dFechaValuacion,
			@strCedulaEmpresa,
			@strCedulaPerito,
			@nMontoUltimaTasacionTerreno,
			@nMontoUltimaTasacionNoTerreno,
			@nMontoTasacionActualizadaTerreno,
			@nMontoTasacionActualizadaNoTerreno,
			@dFechaUltimoSeguimiento,
			@nMontoTotalAvaluo,
			@nRecomendacion,
			@nInspeccion,
			@dFechaConstruccion,
			GETDATE()
		)
	END	

COMMIT TRANSACTION
RETURN 0
