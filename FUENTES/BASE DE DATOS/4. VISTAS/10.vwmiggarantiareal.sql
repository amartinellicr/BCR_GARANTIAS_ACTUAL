USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggarantiareal]
AS

/******************************************************************
<Nombre>vwmiggarantiareal</Nombre>
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

SELECT a.*,
	CASE cod_tipo_garantia_real
		WHEN 1 THEN
			2
		WHEN 2 THEN
			3
		WHEN 3 THEN
			CASE ClasesGarantias_cod_clase_garantia
				WHEN 30 THEN
					4
				WHEN 35 THEN
					4
				WHEN 40 THEN
					4
				WHEN 45 THEN
					4
				WHEN 50 THEN
					4
				WHEN 60 THEN
					4
				WHEN 61 THEN
					5
				WHEN 62 THEN
					5
				WHEN 63 THEN
					5
				WHEN 64 THEN
					5
				WHEN 65 THEN
					5
			END
	END AS TiposInternosGarantias_cod_tipo_garantia
	/*Cuando cod_tipo_garantia_real = 1 entonces TiposInternosGarantias_cod_tipo_garantia = 2.
Cuando cod_tipo_garantia_real = 2 entonces TiposInternosGarantias_cod_tipo_garantia = 3.
Cuando cod_tipo_garantia_real = 3 y cod_clase_garantia = 30 | 35 | 40 | 45 | 50 | 60  entonces TiposInternosGarantias_cod_tipo_garantia = 4.
Cuando cod_tipo_garantia_real = 3  y cod_clase_garantia = 61 | 62 | 63 | 64 | 65  entonces TiposInternosGarantias_cod_tipo_garantia = 5."*/
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
	LEFT(RTRIM(LTRIM(CONVERT(VARCHAR(25), GF.cod_garantia_real))), 25) AS Garantias_cod_garantia_sc,
	CONVERT(NUMERIC(8), cod_tipo_bien) AS TiposBienes_cod_tipo_bien,
	CONVERT(NUMERIC(8), cod_clase_garantia) AS ClasesGarantias_cod_clase_garantia,
	CONVERT(NUMERIC(8), cod_partido) AS CedulasHipotecarias_cod_partido,
	LEFT(numero_finca, 6) AS CedulasHipotecarias_num_finca,
	CONVERT(NUMERIC(5), cedula_hipotecaria) AS CedulasHipotecarias_num_cedula,
	num_placa_bien AS CertificadosContratosPrendas_num_placa,
	CONVERT(NUMERIC(8), cod_partido) AS HipotecasComunes_cod_partido,
	LEFT(numero_finca, 6) AS HipotecasComunes_num_finca,
	CONVERT(NUMERIC(8), NULL) AS ClasesVehiculos_con_clase_vehiculo,
	1 AS TenenciasGarantias_cod_tenenciaprt17_garantia,
	1 AS Reales_ind_inspeccion_menor_6_meses,
	NULL AS Horizontalidades_cod_horizontalidad,
	NULL AS Duplicados_cod_duplicado,
	NULL AS TiposMonedas_cod_tipo_moneda,
	NULL AS CedulasHipotecarias_num_seguridad,
	NULL AS CedulasHipotecarias_mon_facial,
	NULL AS SeguridadesGarantias_cod_tenencia_prt15
FROM GAR_GARANTIA_REAL GF
WHERE cod_clase_garantia BETWEEN 61 AND 65
UNION ALL
SELECT
	'CEDULAS_HIPOTECARIAS' AS cocTipo,
	cod_garantia_real,
	cod_tipo_garantia_real,
--	cod_inspeccion_menor_tres_meses	AS Reales_ind_inspeccion_menor_6_meses,

	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	CASE
		WHEN LEN(numero_finca) < 6 THEN
			RIGHT('000000' + LTRIM(RTRIM(numero_finca)), 6)
	ELSE
		LTRIM(RTRIM(numero_finca))
	END + 
	'M' + 'A'
	
	AS Garantias_cod_garantia,
	
	LEFT(
	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	CASE
		WHEN LEN(numero_finca) < 6 THEN
			RIGHT('000000' + LTRIM(RTRIM(numero_finca)), 6)
	ELSE
		LTRIM(RTRIM(numero_finca))
	END
	, 25) AS Garantias_cod_garantia_sc,
	
	CONVERT(NUMERIC(8), ISNULL(cod_tipo_bien, 1)) AS TiposBienes_cod_tipo_bien,
	CONVERT(NUMERIC(8), cod_clase_garantia) AS ClasesGarantias_cod_clase_garantia,
	
	CONVERT(NUMERIC(8), cod_partido) AS CedulasHipotecarias_cod_partido,
	LEFT(numero_finca, 6) AS CedulasHipotecarias_num_finca,
	CONVERT(NUMERIC(5), cedula_hipotecaria) AS CedulasHipotecarias_num_cedula,
	num_placa_bien AS CertificadosContratosPrendas_num_placa,
	CONVERT(NUMERIC(8), cod_partido) AS HipotecasComunes_cod_partido,
	LEFT(numero_finca, 6) AS HipotecasComunes_num_finca,
	CONVERT(NUMERIC(8), NULL) AS ClasesVehiculos_con_clase_vehiculo,
	1 AS TenenciasGarantias_cod_tenenciaprt17_garantia,
	1 AS Reales_ind_inspeccion_menor_6_meses,
	'M' AS Horizontalidades_cod_horizontalidad,
	'A' AS Duplicados_cod_duplicado,
	2 AS TiposMonedas_cod_tipo_moneda,
	LEFT(LTRIM(RTRIM(numero_finca)) + LTRIM(RTRIM(cedula_hipotecaria)), 12) AS CedulasHipotecarias_num_seguridad,
	2 AS CedulasHipotecarias_mon_facial,
	1 AS SeguridadesGarantias_cod_tenencia_prt15

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

	CASE 
			WHEN LEN(num_placa_bien) < 6 THEN
				CASE ISNULL(cod_tipo_bien, 3)
					WHEN 3 THEN RIGHT('000000' + LTRIM(RTRIM(num_placa_bien)), 6)
					WHEN 4 THEN RIGHT('000000' + LTRIM(RTRIM(num_placa_bien)), 6)
					ELSE
						LTRIM(RTRIM(num_placa_bien))
				END
			ELSE
						LTRIM(RTRIM(num_placa_bien))
		END
	AS Garantias_cod_garantia,
	LEFT(
		LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_clase_bien))) + 
		
		CASE 
			WHEN LEN(num_placa_bien) < 6 THEN
				CASE ISNULL(cod_tipo_bien, 3)
					WHEN 3 THEN RIGHT('000000' + LTRIM(RTRIM(num_placa_bien)), 6)
					WHEN 4 THEN RIGHT('000000' + LTRIM(RTRIM(num_placa_bien)), 6)
					ELSE
						LTRIM(RTRIM(num_placa_bien))
				END
			ELSE
						LTRIM(RTRIM(num_placa_bien))
		END
	, 25) AS Garantias_cod_garantia_sc,

	CONVERT(NUMERIC(8), ISNULL(cod_tipo_bien, 3)) AS TiposBienes_cod_tipo_bien,
	CONVERT(NUMERIC(8), cod_clase_garantia) AS ClasesGarantias_cod_clase_garantia,
	CONVERT(NUMERIC(8), cod_partido) AS CedulasHipotecarias_cod_partido,
	LEFT(numero_finca, 6) AS CedulasHipotecarias_num_finca,
	CONVERT(NUMERIC(5), cedula_hipotecaria) AS CedulasHipotecarias_num_cedula,
	num_placa_bien AS CertificadosContratosPrendas_num_placa,
	CONVERT(NUMERIC(8), cod_partido) AS HipotecasComunes_cod_partido,
	LEFT(numero_finca, 6) AS HipotecasComunes_num_finca,
	--CONVERT(NUMERIC(8), cod_clase_bien) AS ClasesVehiculos_con_clase_vehiculo,
	1 AS ClasesVehiculos_con_clase_vehiculo,
	1 AS TenenciasGarantias_cod_tenenciaprt17_garantia,
	1 AS Reales_ind_inspeccion_menor_6_meses,
	NULL AS Horizontalidades_cod_horizontalidad,
	NULL AS Duplicados_cod_duplicado,
	NULL AS TiposMonedas_cod_tipo_moneda,
	NULL AS CedulasHipotecarias_num_seguridad,
	NULL AS CedulasHipotecarias_mon_facial,
	NULL AS SeguridadesGarantias_cod_tenencia_prt15
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
	CASE
		WHEN LEN(numero_finca) < 6 THEN
			RIGHT('000000' + LTRIM(RTRIM(numero_finca)), 6)
	ELSE
		LTRIM(RTRIM(numero_finca))
	END + 
	 'M' + 'A'

	AS Garantias_cod_garantia,

	LEFT(
	LTRIM(RTRIM(CONVERT(VARCHAR(5), cod_partido))) + 
	CASE
		WHEN LEN(numero_finca) < 6 THEN
			RIGHT('000000' + LTRIM(RTRIM(numero_finca)), 6)
	ELSE
		LTRIM(RTRIM(numero_finca))
	END
	, 25) AS Garantias_cod_garantia_sc,

	CONVERT(NUMERIC(8), ISNULL(cod_tipo_bien, 1)) AS TiposBienes_cod_tipo_bien,
	CONVERT(NUMERIC(8), cod_clase_garantia) AS ClasesGarantias_cod_clase_garantia,
	CONVERT(NUMERIC(8), cod_partido) AS CedulasHipotecarias_cod_partido,
	LEFT(numero_finca, 6) AS CedulasHipotecarias_num_finca,
	CONVERT(NUMERIC(5), cedula_hipotecaria) AS CedulasHipotecarias_num_cedula,
	num_placa_bien AS CertificadosContratosPrendas_num_placa,
	CONVERT(NUMERIC(8), cod_partido) AS HipotecasComunes_cod_partido,
	LEFT(numero_finca, 6) AS HipotecasComunes_num_finca,
	CONVERT(NUMERIC(8), NULL) AS ClasesVehiculos_con_clase_vehiculo,
	1 AS TenenciasGarantias_cod_tenenciaprt17_garantia,
	1 AS Reales_ind_inspeccion_menor_6_meses,
	'M' AS Horizontalidades_cod_horizontalidad,
	'A' AS Duplicados_cod_duplicado,
	NULL AS TiposMonedas_cod_tipo_moneda,
	NULL AS CedulasHipotecarias_num_seguridad,
	NULL AS CedulasHipotecarias_mon_facial,
	NULL AS SeguridadesGarantias_cod_tenencia_prt15
FROM GAR_GARANTIA_REAL GF
WHERE cod_tipo_garantia_real = 1
AND NOT cod_partido IN (0, 10)

) a

WHERE EXISTS(
	SELECT 1
	FROM vwmiggaroperacionesactivas ACT
	WHERE ACT.cod_garantia = a.cod_garantia_real
	AND ACT.coctipo = 'REALES')
AND NOT cod_garantia_real IN (
	SELECT cod_garantia_real
	FROM vwmiggarantiarealduplicada)
