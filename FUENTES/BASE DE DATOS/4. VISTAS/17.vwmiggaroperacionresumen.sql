USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmiggaroperacionresumen]
AS

/******************************************************************
<Nombre>vwmiggaroperacionresumen</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información del detalle de las operaciones que serán migradas</Descripción>
<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
<Fecha>28/08/2009</Fecha>
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

SELECT 
DISTINCT
	cocTipo,
	OperacionesGarantias_cod_idoperacion,
	Oficinas_cod_oficina,
	Operaciones_cod_contabilidad,
	1 AS Operaciones_ind_activa,
	Operaciones_num_operacion,
	Operaciones_num_contrato,
	DeudorCodeudor_cod_iddeudor,
	TiposPersonas_cod_tipo_persona,
	TiposProductos_cod_tipo_producto,
	TiposMonedas_cod_tipo_moneda,
	OperacionesGarantias_mon_original
FROM vwmiggaroperacion
