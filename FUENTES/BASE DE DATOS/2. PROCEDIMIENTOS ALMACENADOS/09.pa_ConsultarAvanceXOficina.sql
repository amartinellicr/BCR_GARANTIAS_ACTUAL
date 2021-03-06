SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ConsultarDetalleAvanceXOperacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ConsultarDetalleAvanceXOperacion;
GO

CREATE PROCEDURE [dbo].[pa_ConsultarDetalleAvanceXOperacion]
	@nOficina smallint,
	@nTipoRegistro smallint,
	@nTipoOperacion tinyint
AS

/******************************************************************
<Nombre>pa_ConsultarAvanceXOficina</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar el detalle del avance por operación.</Descripción>
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

--Operaciones Crediticias
if (@nTipoOperacion = 1) begin
	if (@nOficina = -1) 
		select distinct
			oficina,
			convert(varchar(1),cod_contabilidad) + '-' + 
			convert(varchar(3),cod_oficina) + '-' + 
			convert(varchar(1),cod_moneda) + '-' +
			convert(varchar(1),cod_producto) + '-' + 
			convert(varchar(7),num_operacion) as operacion,
			prmoc_psa_actual as saldo_actual,
			prmoc_pfe_const as fecha_constitucion,
			prmoc_pfe_conta as fecha_contabilizacion,
			pendiente
		from 
			RPT_DETALLE_X_OPERACION
		
		where 
			((@nTipoRegistro = -1 and pendiente = pendiente) or 
			(@nTipoRegistro = 1 and pendiente = 'NO') or
			(@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina,
			operacion
	else
		select distinct
			oficina,
			convert(varchar(1),cod_contabilidad) + '-' + 
			convert(varchar(3),cod_oficina) + '-' + 
			convert(varchar(1),cod_moneda) + '-' +
			convert(varchar(1),cod_producto) + '-' + 
			convert(varchar(7),num_operacion) as operacion,
			prmoc_psa_actual as saldo_actual,
			prmoc_pfe_const as fecha_constitucion,
			prmoc_pfe_conta as fecha_contabilizacion,
			pendiente
		from 
			RPT_DETALLE_X_OPERACION
		
		where
			cod_oficina_cliente = @nOficina
			AND ((@nTipoRegistro = -1 and pendiente = pendiente) or 
			     (@nTipoRegistro = 1 and pendiente = 'NO') or
			     (@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina,
			operacion

end
--Contratos
else begin
	if (@nOficina = -1) 
		select distinct
			oficina,
			convert(varchar(1),cod_contabilidad) + '-' + 
			convert(varchar(3),cod_oficina) + '-' + 
			convert(varchar(1),cod_moneda) + '-' +
			--convert(varchar(1),cod_producto) + '-' + 
			convert(varchar(7),num_contrato) as contrato,
			prmca_pfe_const as fecha_constitucion,
			pendiente
		from 
			RPT_DETALLE_X_CONTRATO
		
		where 
			((@nTipoRegistro = -1 and pendiente = pendiente) or 
			(@nTipoRegistro = 1 and pendiente = 'NO') or
			(@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina,
			contrato
	else
		select distinct
			oficina,
			convert(varchar(1),cod_contabilidad) + '-' + 
			convert(varchar(3),cod_oficina) + '-' + 
			convert(varchar(1),cod_moneda) + '-' +
			--convert(varchar(1),cod_producto) + '-' + 
			convert(varchar(7),num_contrato) as contrato,
			prmca_pfe_const as fecha_constitucion,
			pendiente
		from 
			RPT_DETALLE_X_CONTRATO
		
		where
			cod_oficina_cliente = @nOficina
			AND ((@nTipoRegistro = -1 and pendiente = pendiente) or 
			     (@nTipoRegistro = 1 and pendiente = 'NO') or
			     (@nTipoRegistro = 2 and pendiente = 'SI'))
			
		order by
			oficina,
			contrato

end