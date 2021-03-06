USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggarantiarealduplicada]
AS

/******************************************************************
<Nombre>vwmiggarantiarealduplicada</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las garantías reales duplicadas</Descripción>
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

SELECT G.cod_garantia_real
FROM vwmiggarantiarealcontrol G
INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION R
	ON R.cod_garantia_real = G.cod_garantia_real
INNER JOIN GAR_OPERACION O ON O.cod_operacion = R.cod_operacion
WHERE G.Garantias_cod_garantia_sc IN (

SELECT Garantias_cod_garantia_sc
FROM vwmiggarantiarealcontrol
--WHERE cocTipo = 'CERTIFICADOS_CONTRATOS_PRENDAS'
GROUP BY Garantias_cod_garantia_sc
HAVING COUNT(*) > 1)

