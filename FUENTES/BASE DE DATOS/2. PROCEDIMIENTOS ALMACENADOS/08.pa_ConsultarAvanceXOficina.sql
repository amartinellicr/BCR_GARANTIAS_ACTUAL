SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ConsultarDetalleAvanceXGarantia', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ConsultarDetalleAvanceXGarantia;
GO

CREATE PROCEDURE [dbo].[pa_ConsultarDetalleAvanceXGarantia]
	@nOficina smallint,
	@nTipoRegistro smallint,
	@nTipoOperacion tinyint
AS

/******************************************************************
<Nombre>pa_ConsultarAvanceXOficina</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar el detalle del avance por garantía.</Descripción>
<Entradas>
	@nOficina		= Oficina de la que se requiere genrar el reporte
	@nTipoRegistro	= Tipo de reporte a ser generado
	@nTipoOperacion = Código del tipo de operación a consultar
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

--Operaciones crediticias
if (@nTipoOperacion = 1) begin
	if (@nOficina = -1) 
		select distinct
			oficina,
			operacion,
			tipo_garantia,
			garantia,
			pendiente
		
		from 
			RPT_DETALLE_X_GARANTIA
		
		where 
			((@nTipoRegistro = -1 and pendiente = pendiente) or 
			(@nTipoRegistro = 1 and pendiente = 'NO') or
			(@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina, tipo_garantia, operacion
	
	else
		select distinct
			oficina,
			operacion,
			tipo_garantia,
			garantia,
			pendiente
		
		from 
			RPT_DETALLE_X_GARANTIA
		
		where 
			cod_oficina_cliente = @nOficina
			AND ((@nTipoRegistro = -1 and pendiente = pendiente) or 
			          (@nTipoRegistro = 1 and pendiente = 'NO') or
			          (@nTipoRegistro = 2 and pendiente = 'SI'))
		order by
			oficina, tipo_garantia, operacion
end
--Contratos
else begin
	if (@nOficina = -1) 
		select distinct
			oficina,
			contrato,
			tipo_garantia,
			garantia,
			pendiente
		
		from 
			RPT_CONTRATOS_DETALLE_X_GARANTIA
		
		where 
			((@nTipoRegistro = -1 and pendiente = pendiente) or 
			(@nTipoRegistro = 1 and pendiente = 'NO') or
			(@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina, tipo_garantia, contrato
	
	else
		select distinct
			oficina,
			contrato,
			tipo_garantia,
			garantia,
			pendiente
		
		from 
			RPT_CONTRATOS_DETALLE_X_GARANTIA
		
		where 
			cod_oficina_cliente = @nOficina
			AND ((@nTipoRegistro = -1 and pendiente = pendiente) or 
			          (@nTipoRegistro = 1 and pendiente = 'NO') or
			          (@nTipoRegistro = 2 and pendiente = 'SI'))
		order by
			oficina, tipo_garantia, contrato
end
