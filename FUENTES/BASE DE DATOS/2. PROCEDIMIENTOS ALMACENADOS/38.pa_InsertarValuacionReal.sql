SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_InsertarValuacionReal]
	--Garantia Real
	@nGarantiaReal bigint,
	@dFechaValuacion datetime,
	@strCedulaEmpresa varchar(25) = NULL,
	@strCedulaPerito varchar(25) = NULL,
	@nMontoUltimaTasacionTerreno money = NULL,
	@nMontoUltimaTasacionNoTerreno money = NULL,
	@nMontoTasacionActualizadaTerreno money = NULL,
	@nMontoTasacionActualizadaNoTerreno money = NULL,
	@dFechaUltimoSeguimiento datetime = NULL,
	@nMontoTotalAvaluo money = NULL,
	@nRecomendacion smallint = NULL,
	@nInspeccion smallint = NULL,
	@dFechaConstruccion datetime = NULL,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_InsertarValuacionReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite insertar la información de una valuación para una 
             garantía real.
</Descripción>
<Entradas>
	@nGarantiaReal						= Código de la garantía real
	@dFechaValuacion					= Fecha de la valuación
	@strCedulaEmpresa					= Cédula de empresa
	@strCedulaPerito					= Cédula del perito
	@nMontoUltimaTasacionTerreno		= Monto de la última tasación terreno
	@nMontoUltimaTasacionNoTerreno		= Monto de la última tasación no terreno
	@nMontoTasacionActualizadaTerreno	= Monto de la tasación actualizada terreno
	@nMontoTasacionActualizadaNoTerreno = Monto de la tasación actualizada no terreno
	@dFechaUltimoSeguimiento			= Fecha del último seguimiento
	@nMontoTotalAvaluo					= Monto total del avaluo
	@nRecomendacion						= Código de recomendación del perito
	@nInspeccion						= Indicador de inspección menor a tres meses
	@dFechaConstruccion					= Fecha construcción
	@strUsuario							= Usuario que realiza la transacción
	@strIP								= IP de la máquina donde se realiza la transacción
	@nOficina							= Oficina donde se realiza la transacción
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
			fecha_construccion
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
			@dFechaConstruccion
		)
	END	

COMMIT TRANSACTION
RETURN 0


