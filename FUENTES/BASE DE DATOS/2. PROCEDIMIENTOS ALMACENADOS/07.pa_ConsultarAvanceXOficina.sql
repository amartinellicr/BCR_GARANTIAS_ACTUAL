SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ConsultarAvanceXOficina', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ConsultarAvanceXOficina;
GO

CREATE PROCEDURE [dbo].[pa_ConsultarAvanceXOficina] 
	@dFechaCorte varchar(10),
	@nOficina smallint,
	@nTipoRegistro smallint,
	@nTipoOperacion tinyint
AS

/******************************************************************
<Nombre>pa_ConsultarAvanceXOficina</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite realizar la consulta del avance por oficina.</Descripción>
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
			a.porcentaje_total_garantias_completas,
			a.porcentaje_total_garantias_pendientes,
			a.total_garantias,
			a.total_garantias_completas,
			a.total_garantias_pendientes,
			(select convert(decimal(18,2),sum(total_garantias_completas)*100.00/sum(total_garantias)) from RPT_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_garantias = total_garantias) or (@nTipoRegistro = 1 and total_garantias = total_garantias_completas) or (@nTipoRegistro = 2 and total_garantias_pendientes > 0)) ) as avance,
			(select convert(decimal(18,2),sum(total_garantias_pendientes)*100.00/sum(total_garantias)) from RPT_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_garantias = total_garantias) or (@nTipoRegistro = 1 and total_garantias = total_garantias_completas) or (@nTipoRegistro = 2 and total_garantias_pendientes > 0))) as pendiente
		from 
			RPT_AVANCE_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND ((@nTipoRegistro = -1 and a.total_garantias = a.total_garantias) or 
			          (@nTipoRegistro = 1 and a.total_garantias = a.total_garantias_completas) or
			          (@nTipoRegistro = 2 and a.total_garantias_pendientes > 0))
	else
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_garantias_completas,
			a.porcentaje_total_garantias_pendientes,
			a.total_garantias,
			a.total_garantias_completas,
			a.total_garantias_pendientes,
			(select convert(decimal(18,2),sum(total_garantias_completas)*100.00/sum(total_garantias)) from RPT_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND cod_oficina = @nOficina) as avance,
			(select convert(decimal(18,2),sum(total_garantias_pendientes)*100.00/sum(total_garantias)) from RPT_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND cod_oficina = @nOficina) as pendiente
		from 
			RPT_AVANCE_X_OFICINA_CLIENTE a
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
			a.porcentaje_total_garantias_completas,
			a.porcentaje_total_garantias_pendientes,
			a.total_garantias,
			a.total_garantias_completas,
			a.total_garantias_pendientes,
			(select convert(decimal(18,2),sum(total_garantias_completas)*100.00/sum(total_garantias)) from RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_garantias = total_garantias) or (@nTipoRegistro = 1 and total_garantias = total_garantias_completas) or (@nTipoRegistro = 2 and total_garantias_pendientes > 0)) ) as avance,
			(select convert(decimal(18,2),sum(total_garantias_pendientes)*100.00/sum(total_garantias)) from RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND ((@nTipoRegistro = -1 and total_garantias = total_garantias) or (@nTipoRegistro = 1 and total_garantias = total_garantias_completas) or (@nTipoRegistro = 2 and total_garantias_pendientes > 0))) as pendiente
		from 
			RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND ((@nTipoRegistro = -1 and a.total_garantias = a.total_garantias) or 
			          (@nTipoRegistro = 1 and a.total_garantias = a.total_garantias_completas) or
			          (@nTipoRegistro = 2 and a.total_garantias_pendientes > 0))
	else
		select 
			convert(varchar(10),a.fecha_corte,103) as fecha_corte,
			a.cod_oficina,
			a.des_oficina,
			convert(varchar(3), a.cod_oficina) + ' - ' + a.des_oficina as oficina,
			a.porcentaje_total_garantias_completas,
			a.porcentaje_total_garantias_pendientes,
			a.total_garantias,
			a.total_garantias_completas,
			a.total_garantias_pendientes,
			(select convert(decimal(18,2),sum(total_garantias_completas)*100.00/sum(total_garantias)) from RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND cod_oficina = @nOficina) as avance,
			(select convert(decimal(18,2),sum(total_garantias_pendientes)*100.00/sum(total_garantias)) from RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = @dFechaCorte AND cod_oficina = @nOficina) as pendiente
		from 
			RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE a
		where 
			a.fecha_corte = @dFechaCorte
			AND a.cod_oficina = @nOficina
end
