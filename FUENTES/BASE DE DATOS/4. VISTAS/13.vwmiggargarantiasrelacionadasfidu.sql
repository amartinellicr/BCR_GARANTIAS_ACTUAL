USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggargarantiasrelacionadasfidu]
AS

/******************************************************************
<Nombre>vwmiggargarantiasrelacionadasfidu</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las relaciones entre las garantías fiduciarias y las operaciones que serán migradas</Descripción>
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
	o.OperacionesGarantias_cod_idoperacion,
	GF.Garantias_cod_garantia,
	0 AS TiposIndicadoresInscripcion_cod_tipo_indicador,
	ISNULL(
		CASE f.cod_tipo_mitigador
			WHEN -1 THEN
				0
			ELSE
				f.cod_tipo_mitigador
		END
		, 1) AS TiposMitigadoresRiesgos_cod_tipo_mitigador,
	
	ISNULL(
		CASE f.cod_tipo_documento_legal
			WHEN -1 THEN
				0
			ELSE 
				cod_tipo_documento_legal
		END, 0) AS TiposDocumentosLegales_cod_tipo_documento,
	ISNULL(f.monto_mitigador, 0) AS GarantiasRelacionadas_mon_mitigador,
	f.porcentaje_responsabilidad AS GarantiasRelacionadas_por_responsabilidad,
	1 AS TiposMonedas_cod_tipo_moneda,
	GF.TiposInternosGarantias_cod_tipo_garantia,
	GF.TiposInternosGarantias_cod_tipo_garantia AS TiposGarantias_cod_tipo_garantia,

	100 AS GarantiasRelacionadas_por_aceptacion,
	0 AS GarantiasRelacionadas_mon_responsabilidad,
	1 AS GarantiasRelacionadas_mon_tipo_cambio,
	CASE f.cod_tipo_documento_legal
		WHEN 23 THEN
			0
		WHEN 24 THEN
			0
		WHEN 25 THEN
			0
		WHEN 26 THEN
			0
		ELSE
			1
	END AS GarantiasRelacionadas_ind_garantia_fideicometida,
	1 AS GarantiasRelacionadas_ind_calculo_automatico,
	1 AS GarantiasRelacionadas_ind_garantia_participa_calculo,
	GF.Garantias_fec_constitucion,
	GF.Garantias_fec_vencimiento,
	GF.Garantias_fec_prescripcion,
	ISNULL(
		(SELECT ingreso_neto
			FROM GAR_VALUACIONES_FIADOR VF1
			WHERE VF1.cod_garantia_fiduciaria = F.cod_garantia_fiduciaria
			AND VF1.fecha_valuacion = (
				SELECT MAX(VF2.FiduciariasAvales_fec_verificacion_asalariado)
				FROM vwvwmiggarmaxvaluacionesfiador VF2
				WHERE VF2.cod_garantia_fiduciaria = VF1.cod_garantia_fiduciaria)
			), 0)
		AS GarantiasRelacionadas_mon_valor_mercado

	
FROM GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION f
INNER JOIN vwmiggaroperacionesactivas o ON o.cod_operacion = f.cod_operacion
	AND o.cod_garantia = f.cod_garantia_fiduciaria
INNER JOIN vwmiggarantiafiduciara GF ON GF.cod_garantia_fiduciaria = f.cod_garantia_fiduciaria

