USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggarantiarealcontrol]
AS

/******************************************************************
<Nombre>vwmiggarantiarealcontrol</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las garantías reales que serán migradas</Descripción>
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

SELECT a.*
FROM 
(
SELECT
	'BONOS_VALES_PRENDAS' AS cocTipo,
	cod_garantia_real,
	cod_tipo_garantia_real,
	--cod_inspeccion_menor_tres_meses	AS Reales_ind_inspeccion_menor_6_meses,
	--Este campo esa en la tabla de valuaciones reales
	LEFT(RTRIM(LTRIM(CONVERT(VARCHAR(50), GF.cod_garantia_real))), 50)
		AS Garantias_cod_garantia,
	LEFT(RTRIM(LTRIM(CONVERT(VARCHAR(50), GF.cod_garantia_real))), 50) AS Garantias_cod_garantia_sc
	
FROM GAR_GARANTIA_REAL GF
WHERE cod_clase_garantia BETWEEN 61 AND 65
UNION ALL
SELECT
	'CEDULAS_HIPOTECARIAS' AS cocTipo,
	cod_garantia_real,
	cod_tipo_garantia_real,
--	cod_inspeccion_menor_tres_meses	AS Reales_ind_inspeccion_menor_6_meses,

	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	LTRIM(RTRIM(numero_finca))  +
	'M' + 'A'
	--+ LTRIM(RTRIM(CONVERT(VARCHAR(10), cod_garantia_real))) 
	AS Garantias_cod_garantia,

	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	LTRIM(RTRIM(numero_finca)) AS Garantias_cod_garantia_sc

FROM GAR_GARANTIA_REAL GF
WHERE cod_tipo_garantia_real = 2
AND ISNULL(cod_grado, 0) <> 0
AND NOT numero_finca IS NULL
/*
	Estas condiciones hay que revisarlas, se pusieron solo para evitar
	basura
*/
AND cedula_hipotecaria IS NOT NULL
AND NOT cod_partido IN (0, 20)
UNION ALL
SELECT
	'CERTIFICADOS_CONTRATOS_PRENDAS' AS cocTipo,
	cod_garantia_real,
	cod_tipo_garantia_real,
--	cod_inspeccion_menor_tres_meses	AS Reales_ind_inspeccion_menor_6_meses,
	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_clase_bien))) + 
	LTRIM(RTRIM(num_placa_bien))  
	-- + LTRIM(RTRIM(CONVERT(VARCHAR(10), cod_garantia_real)))
		AS Garantias_cod_garantia,
	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_clase_bien))) + 
	LTRIM(RTRIM(num_placa_bien)) AS Garantias_cod_garantia_sc
FROM GAR_GARANTIA_REAL GF
WHERE cod_tipo_garantia_real = 3 
AND cod_clase_garantia IN (30, 35, 40, 45, 50, 60)
AND cod_clase_bien IS NOT NULL
UNION ALL
SELECT
	'HIPOTECAS_COMUNES' AS cocTipo,
	cod_garantia_real,
	cod_tipo_garantia_real,
--	cod_inspeccion_menor_tres_meses	AS Reales_ind_inspeccion_menor_6_meses,

	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	LTRIM(RTRIM(numero_finca)) +
	 'M' + 'A'
	-- + LTRIM(RTRIM(CONVERT(VARCHAR(10), cod_garantia_real)))
	AS Garantias_cod_garantia,

	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	LTRIM(RTRIM(numero_finca)) AS Garantias_cod_garantia_sc
FROM GAR_GARANTIA_REAL GF
WHERE cod_tipo_garantia_real = 1
AND NOT cod_partido IN (0, 10)

) a

WHERE EXISTS(
	SELECT 1
	FROM vwmiggaroperacionesactivas ACT
	WHERE ACT.cod_garantia = a.cod_garantia_real
	AND ACT.coctipo = 'REALES')
