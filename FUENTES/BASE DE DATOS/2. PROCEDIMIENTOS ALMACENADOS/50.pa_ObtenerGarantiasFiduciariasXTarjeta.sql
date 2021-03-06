USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasFiduciariasXTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerGarantiasFiduciariasXTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasFiduciariasXTarjeta]
	@psNumero_Tarjeta VARCHAR(16)
AS

/******************************************************************
<Nombre>pa_ObtenerGarantiasFiduciariasXTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener las garantías fiduciarias que posee una tarjeta.</Descripción>
<Entradas>
	@psNumero_Tarjeta = Número de la tarjeta a consultar.
</Entradas>
<Salidas></Salidas>
<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
<Fecha>07/05/2008</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>02/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
			</Descripción>
	</Cambio>
	<Cambio>
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/

BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	SELECT	DISTINCT 
			CE1.cat_descripcion AS tipo_persona, 
			TGF.cedula_fiador, 
			TGF.nombre_fiador, 
			COALESCE(TGF.cod_tipo_fiador,-1) AS cod_tipo_fiador, 
			COALESCE(GFT.cod_tipo_mitigador,-1) AS cod_tipo_mitigador, 
			COALESCE(GFT.cod_tipo_documento_legal,-1) AS cod_tipo_documento_legal, 
			GFT.monto_mitigador, 
			COALESCE(GFT.porcentaje_responsabilidad, -1) AS porcentaje_responsabilidad, 
			COALESCE(GFT.cod_operacion_especial,0) AS cod_operacion_especial, 
			CASE GFT.cod_tipo_acreedor 
				WHEN NULL THEN 2 
				WHEN -1 THEN 2 
				ELSE GFT.cod_tipo_acreedor 
			END AS cod_tipo_acreedor, 
			COALESCE(GFT.cedula_acreedor,'') AS cedula_acreedor, 
			GFT.cod_tarjeta AS cod_operacion, 
			GFT.cod_garantia_fiduciaria,
			COALESCE(GFT.fecha_expiracion,'1900-01-01') AS fecha_expiracion, 
			COALESCE(GFT.monto_cobertura, 0) AS monto_cobertura,
			1 AS cod_estado,
			COALESCE(GFT.des_observacion,'') AS des_observacion,
			COALESCE(GFT.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.TAR_TARJETA TTA
		INNER JOIN dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA GFT
		ON TTA.cod_tarjeta = GFT.cod_tarjeta
		INNER JOIN dbo.TAR_GARANTIA_FIDUCIARIA TGF
		ON GFT.cod_garantia_fiduciaria = TGF.cod_garantia_fiduciaria
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = TGF.cod_tipo_fiador
	WHERE	TTA.num_tarjeta = @psNumero_Tarjeta
		AND CE1.cat_catalogo= 1 

END
