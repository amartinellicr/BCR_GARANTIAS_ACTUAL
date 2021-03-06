USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwvwmiggarmaxcapacidadpago]
AS

/******************************************************************
<Nombre>vwvwmiggarmaxcapacidadpago</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las capacidades de pago de los deudores que serán migradas</Descripción>
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
	CP.cedula_deudor AS DeudorCodeudor_cod_iddeudor,
	MAX(CP.fecha_capacidad_pago) AS DeudoresCodeudores_fec_certificacion_ingresos
FROM GAR_CAPACIDAD_PAGO CP
GROUP BY CP.cedula_deudor
