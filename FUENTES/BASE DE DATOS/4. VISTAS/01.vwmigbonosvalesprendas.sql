USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmigbonosvalesprendas]
AS

/******************************************************************
<Nombre>vwmigbonosvalesprendas</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene las garantías reales de bonos y vales de prenda que serán migradas</Descripción>
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


SELECT *
FROM GAR_GARANTIA_REAL
WHERE cod_clase_garantia BETWEEN 61 AND 65

