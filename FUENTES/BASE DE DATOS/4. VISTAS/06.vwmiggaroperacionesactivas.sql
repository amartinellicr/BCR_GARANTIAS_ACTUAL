USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggaroperacionesactivas]
AS

/******************************************************************
<Nombre>vwmiggaroperacionesactivas</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las operaciones activas</Descripción>
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
	'FIDUCIARIA' AS coctipo,
	f.cod_garantia_fiduciaria AS cod_garantia, f.cod_operacion,
	o.OperacionesGarantias_cod_idoperacion
	FROM GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION f
	INNER JOIN vwmiggaroperacion o ON o.cod_operacion = f.cod_operacion
	WHERE f.cod_estado = 1
	AND f.cod_tipo_mitigador >= 0 
	AND f.cod_tipo_documento_legal >= 0 
	UNION ALL
	SELECT 
	'REALES' AS coctipo,
	f.cod_garantia_real AS cod_garantia, f.cod_operacion,
	o.OperacionesGarantias_cod_idoperacion
	FROM GAR_GARANTIAS_REALES_X_OPERACION f
	INNER JOIN vwmiggaroperacion o ON o.cod_operacion = f.cod_operacion
	WHERE f.cod_estado = 1
	AND f.cod_tipo_mitigador >= 0
	AND f.cod_tipo_documento_legal >= 0
