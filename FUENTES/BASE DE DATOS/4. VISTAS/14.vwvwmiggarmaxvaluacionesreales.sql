USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwvwmiggarmaxvaluacionesreales]
AS

/******************************************************************
<Nombre>vwvwmiggarmaxvaluacionesreales</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las valuacioes de las garantías reales que serán migradas</Descripción>
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
	VF.cod_garantia_real AS cod_garantia_real,
	MAX(VF.fecha_valuacion) AS fecha_valuacion
FROM GAR_VALUACIONES_REALES VF
GROUP BY VF.cod_garantia_real
