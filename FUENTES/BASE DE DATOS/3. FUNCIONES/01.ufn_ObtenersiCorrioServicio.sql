
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_ObtenersiCorrioServicio]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[ufn_ObtenersiCorrioServicio]

GO

CREATE FUNCTION [dbo].[ufn_ObtenersiCorrioServicio] 
(
	@tcocProceso VARCHAR(20),
	@tfecCorrida DateTime
) RETURNS BIT
AS

/******************************************************************
<Nombre>ufn_ObtenersiCorrioServicio</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Determina si un proceso fue corrido en un día especifico.</Descripción>
<Entradas>
	@tcocProceso = Código del proceso.
	@tfecCorrida = Fecha en que se ejecutó el proceso.
</Entradas>
<Salidas>
	@lindCorrio = Indica si el proceso fue ejecutado (1) o no (0). 
</Salidas>
<Autor>Norberto Mesén López, LiderSoft Internacional S.A.</Autor>
<Fecha>17/11/2010</Fecha>
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

BEGIN
DECLARE
	@lindCorrio BIT
DECLARE
	@lfecInicial DATETIME,
	@lfecFinal DATETIME
BEGIN
	SET @lindCorrio = 0

	SET @lfecInicial = CONVERT(DATETIME, CONVERT(VARCHAR(8), @tfecCorrida, 112))
	SET @lfecFinal = DATEADD(second, -2, DATEADD(day, 1, @lfecInicial))

	IF EXISTS(
		SELECT 1
		FROM GAR_EJECUCION_PROCESO EP
		WHERE cocProceso = @tcocProceso
		AND fecEjecucion BETWEEN @lfecInicial AND @lfecFinal)
	BEGIN
		SET @lindCorrio = 1
	END

	RETURN @lindCorrio
END
END --[ufn_ObtenersiCorrioServicio]