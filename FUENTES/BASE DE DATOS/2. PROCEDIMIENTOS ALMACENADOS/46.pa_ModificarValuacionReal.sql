SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ModificarValuacionReal]
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
<Nombre>pa_ModificarValuacionReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite modificar la información de una valuación de una 
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
			fecha_construccion = @dFechaConstruccion
		WHERE
			cod_garantia_real = @nGarantiaReal
			AND convert(varchar(10),fecha_valuacion,111) = convert(varchar(10),@dFechaValuacion,111)
	END	

COMMIT TRANSACTION
RETURN 0

