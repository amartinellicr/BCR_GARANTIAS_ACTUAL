SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerConsecutivoOperacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerConsecutivoOperacion;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerConsecutivoOperacion]
	@nContabilidad smallint,
	@nOficina smallint,
	@nMoneda smallint,
	@nProducto smallint,
	@nOperacion decimal(7),
	@strDeudor varchar(30)
AS

/******************************************************************
<Nombre>pa_ObtenerConsecutivoOperacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento retorna el código de operación (cod_operacion) de una operación crediticia 
             o de un contrato de la tabla GAR_OPERACION.
</Descripción>
<Entradas>
	@nContabilidad	= Código de contabilidad
	@nOficina		= Código de la oficina
	@nMoneda		= Código de la moneda
	@nProducto		= Código del producto
	@nOperacion		= Número de operación
	@strDeudor		= Cédula del deudor
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

declare @nConsecutivo bigint
set @nConsecutivo = null;

select @nConsecutivo = cod_operacion
from GAR_OPERACION
where cod_contabilidad = @nContabilidad
and cod_oficina = @nOficina
and cod_moneda = @nMoneda
and cod_producto = @nProducto
and num_operacion = @nOperacion

if (@nConsecutivo is null) begin
	insert into GAR_OPERACION (cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_operacion, cedula_deudor)
	values (@nContabilidad,@nOficina,@nMoneda,@nProducto,@nOperacion,@strDeudor)

	set @nConsecutivo = @@identity
end

select @nConsecutivo

RETURN 0