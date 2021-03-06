SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('pa_ConsultarAvanceOperacionXOficina', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ConsultarAvanceOperacionXOficina;
GO

CREATE PROCEDURE [dbo].[pa_ConsultarAvanceOperacionXOficina] 
	@dFechaCorte varchar(10),
	@nOficina smallint,
	@nTipoRegistro smallint,
	@nTipoOperacion tinyint
AS

/******************************************************************
<Nombre>pa_ConsultarAvanceOperacionXOficina</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite realizar la consulta del avance de operaciones por oficina.</Descripción>
<Entradas>
	@dFechaCorte	= Fecha en la que se realiza el corte
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
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_operaciones_completas,
			a.porcentaje_total_operaciones_pendientes,
			a.total_operaciones,
			a.total_operaciones_completas,
			a.total_operaciones_pendientes,
			(select convert(decimal(18,2),sum(total_operaciones_completas)*100.00/sum(total_operaciones)) from RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_operaciones = total_operaciones) or (@nTipoRegistro = 1 and total_operaciones = total_operaciones_completas) or (@nTipoRegistro = 2 and total_operaciones_pendientes > 0))) as avance,
			(select convert(decimal(18,2),sum(total_operaciones_pendientes)*100.00/sum(total_operaciones)) from RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_operaciones = total_operaciones) or (@nTipoRegistro = 1 and total_operaciones = total_operaciones_completas) or (@nTipoRegistro = 2 and total_operaciones_pendientes > 0))) as pendiente
		from 
			RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND ((@nTipoRegistro = -1 and a.total_operaciones = a.total_operaciones) or 
			          (@nTipoRegistro = 1 and a.total_operaciones = a.total_operaciones_completas) or
			          (@nTipoRegistro = 2 and a.total_operaciones_pendientes > 0))
	else
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_operaciones_completas,
			a.porcentaje_total_operaciones_pendientes,
			a.total_operaciones,
			a.total_operaciones_completas,
			a.total_operaciones_pendientes,
			(select convert(decimal(18,2),sum(total_operaciones_completas)*100.00/sum(total_operaciones)) from RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND a.cod_oficina = @nOficina) as avance,
			(select convert(decimal(18,2),sum(total_operaciones_pendientes)*100.00/sum(total_operaciones)) from RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND a.cod_oficina = @nOficina) as pendiente
		from 
			RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND a.cod_oficina = @nOficina
end
--Contratos
else begin
	if (@nOficina = -1) 
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_contratos_completos,
			a.porcentaje_total_contratos_pendientes,
			a.total_contratos,
			a.total_contratos_completos,
			a.total_contratos_pendientes,
			(select convert(decimal(18,2),sum(total_contratos_completos)*100.00/sum(total_contratos)) from RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_contratos = total_contratos) or (@nTipoRegistro = 1 and total_contratos = total_contratos_completos) or (@nTipoRegistro = 2 and total_contratos_pendientes > 0))) as avance,
			(select convert(decimal(18,2),sum(total_contratos_pendientes)*100.00/sum(total_contratos)) from RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_contratos = total_contratos) or (@nTipoRegistro = 1 and total_contratos = total_contratos_completos) or (@nTipoRegistro = 2 and total_contratos_pendientes > 0))) as pendiente
		from 
			RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND ((@nTipoRegistro = -1 and a.total_contratos = a.total_contratos) or 
			          (@nTipoRegistro = 1 and a.total_contratos = a.total_contratos_completos) or
			          (@nTipoRegistro = 2 and a.total_contratos_pendientes > 0))
	else
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_contratos_completos,
			a.porcentaje_total_contratos_pendientes,
			a.total_contratos,
			a.total_contratos_completos,
			a.total_contratos_pendientes,
			(select convert(decimal(18,2),sum(total_contratos_completos)*100.00/sum(total_contratos)) from RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND a.cod_oficina = @nOficina) as avance,
			(select convert(decimal(18,2),sum(total_contratos_pendientes)*100.00/sum(total_contratos)) from RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND a.cod_oficina = @nOficina) as pendiente
		from 
			RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND a.cod_oficina = @nOficina
end
	
RETURN 0
