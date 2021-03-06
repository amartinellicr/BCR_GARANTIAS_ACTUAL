USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwmiggargarantia]
AS

/******************************************************************
<Nombre>vwmiggargarantia</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información básica de las garantías que serán migradas</Descripción>
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
	'REAL' AS cocGarantiaGeneral,
	cod_garantia_real AS codGarantiaAnt,
	Garantias_cod_garantia,
	TiposInternosGarantias_cod_tipo_garantia,
	ClasesGarantias_cod_clase_garantia,
	Garantias_cod_garantia_sc,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_vencimiento,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_prescripcion,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_constitucion
FROM vwmiggarantiareal
--UNION ALL
--SELECT
--	'VALOR' AS cocGarantiaGeneral,
--	cod_garantia_valor AS codGarantiaAnt,
--	Garantias_cod_garantia,
--	TiposInternosGarantias_cod_tipo_garantia,
--	ClasesGarantias_cod_clase_garantia,
--	Garantias_cod_garantia_sc,
--	Garantias_fec_vencimiento,
--	Garantias_fec_prescripcion,
--	Garantias_fec_constitucion
--FROM vwmiggarantiavalor
UNION ALL
SELECT
	'FIDUCIARIA' AS cocGarantiaGeneral,
	cod_garantia_fiduciaria AS codGarantiaAnt,
	Garantias_cod_garantia,
	TiposInternosGarantias_cod_tipo_garantia,
	ClasesGarantias_cod_clase_garantia,
	Garantias_cod_garantia_sc,
	Garantias_fec_vencimiento,
	Garantias_fec_prescripcion,
	Garantias_fec_constitucion
FROM vwmiggarantiafiduciara

