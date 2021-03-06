USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggartarjetas]
AS

/******************************************************************
<Nombre>vwmiggartarjetas</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las tarjetas que serán migradas</Descripción>
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
T.num_tarjeta AS OperacionesGarantias_cod_idoperacion,
'0' + CONVERT(VARCHAR(1), cod_tipo_garantia) AS TiposPerfiles_cod_perfil,
cod_estado_tarjeta AS TiposEstadosTarjetas_cod_estado_tarjeta,
D.DeudorCodeudor_cod_iddeudor AS DeudorCodeudor_cod_iddeudor,
cod_moneda AS TiposMonedas_cod_tipo_moneda,
D.TiposPersonas_cod_tipo_persona AS TiposPersonas_cod_tipo_persona,
7 AS TiposProductos_cod_tipo_producto,
0 AS OperacionesGarantias_mon_original
FROM TAR_TARJETA T
INNER JOIN vwmiggardeudorcodeudor D ON D.cedulaRelacion = T.cedula_deudor
