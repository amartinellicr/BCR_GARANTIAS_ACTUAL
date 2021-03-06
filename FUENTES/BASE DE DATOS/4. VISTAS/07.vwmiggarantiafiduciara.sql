USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggarantiafiduciara]
AS

/******************************************************************
<Nombre>vwmiggarantiafiduciara</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las garantías fiduciarias que serán migradas</Descripción>
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

SELECT t.*,
	CASE t.TiposPersonas_cod_tipo_persona
		WHEN 4 THEN 2
		WHEN 6 THEN 2
		ELSE 0
	END AS TiposAsignacionesCalificaciones_cod_tipo_asignacion,
	LEFT(RTRIM(LTRIM(CONVERT(VARCHAR(10), t.TiposPersonas_cod_tipo_persona)))
		+ RTRIM(LTRIM(CONVERT(VARCHAR(50), t.coccedulafiador))), 50) AS Garantias_cod_garantia,
	coccedulafiador AS Garantias_cod_garantia_sc
FROM
(
SELECT
	
	GF.cedula_fiador AS cedula_relacion,
	GF.tipo_id_sugef,
	GF.cedula_fiador_sugef,
	GF.ind_actualizo_cedulasugef,
	GF.cod_garantia_fiduciaria,
	1 AS TiposInternosGarantias_cod_tipo_garantia,
	CONVERT(NUMERIC(8), GF.cod_clase_garantia) AS ClasesGarantias_cod_clase_garantia,
	CASE 
		WHEN ISNULL(GF.cod_tipo_fiador, 0) = 0 THEN
			1
		ELSE
			ISNULL(GF.tipo_id_sugef, GF.cod_tipo_fiador)
	END AS TiposPersonas_cod_tipo_persona,	

	CONVERT(VARCHAR(25), ISNULL(GF.cedula_fiador_sugef, GF.cedula_fiador)) AS coccedulafiador,

	ISNULL(VF.fecha_valuacion, '19900101') AS FiduciariasAvales_fec_verificacion_asalariado,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_vencimiento,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_prescripcion,
	CONVERT(DATETIME, '19000101') AS Garantias_fec_constitucion,
	CONVERT(NUMERIC(20, 2), VF.ingreso_neto) AS FiduciariasAvales_mon_salario_neto_fiador

FROM GAR_GARANTIA_FIDUCIARIA GF
LEFT OUTER JOIN vwvwmiggarmaxvaluacionesfiador MVF ON
	MVF.cod_garantia_fiduciaria = GF.cod_garantia_fiduciaria
LEFT OUTER JOIN GAR_VALUACIONES_FIADOR VF ON
	VF.cod_garantia_fiduciaria = MVF.cod_garantia_fiduciaria
	AND VF.fecha_valuacion = MVF.FiduciariasAvales_fec_verificacion_asalariado
WHERE EXISTS(
	SELECT 1
	FROM vwmiggaroperacionesactivas ACT
	WHERE ACT.cod_garantia = GF.cod_garantia_fiduciaria
	AND ACT.coctipo = 'FIDUCIARIA')
) AS t
WHERE t.cedula_relacion =
	(	SELECT TOP 1 GFC.cedula_fiador
		FROM GAR_GARANTIA_FIDUCIARIA GFC
		WHERE ISNULL(GFC.cedula_fiador_sugef, GFC.cedula_fiador) = t.coccedulafiador)


--select * from vwvwmiggarmaxvaluacionesfiador
