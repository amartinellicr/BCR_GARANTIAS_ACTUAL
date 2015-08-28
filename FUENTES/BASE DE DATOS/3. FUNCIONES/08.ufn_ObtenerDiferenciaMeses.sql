USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('ObtenerDiferenciaMeses') IS NOT NULL 
    DROP FUNCTION ObtenerDiferenciaMeses;
GO

CREATE FUNCTION dbo.ObtenerDiferenciaMeses 
(
    @pdtFechaInicial DATETIME,
    @pdtFechaFinal DATETIME
)
RETURNS INT
AS
/*****************************************************************************************************************************************************
	<Nombre>ObtenerDiferenciaMeses</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Función que permite obtener la diferencia en meses entre dos fechas dadas.
	</Descripción>
	<Entradas>
			@pdtFecha_Inicial	= Fecha inicial.

  			@pdtFecha_Final		= Fecha final.
  			
 	</Entradas>
	<Salidas>
			Número entero con la cantidad de meses de diferencia.
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
	<Fecha>18/08/2015</Fecha>
	<Requerimiento>
			2015081410448079 - Problemas en la acualización de campo calculados en el sistema BCRGarantías.
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

BEGIN
    DECLARE @Result INT

    DECLARE @DateX DATETIME
    DECLARE @DateY DATETIME

    IF(@pdtFechaInicial < @pdtFechaFinal)
    BEGIN
    	SET @DateX = @pdtFechaInicial
    	SET @DateY = @pdtFechaFinal
    END
    ELSE
    BEGIN
    	SET @DateX = @pdtFechaFinal
    	SET @DateY = @pdtFechaInicial
    END

    SET @Result = (
    				SELECT 
    				CASE 
    					WHEN DATEPART(DAY, @DateX) > DATEPART(DAY, @DateY)
    					THEN DATEDIFF(MONTH, @DateX, @DateY) - 1
    					ELSE DATEDIFF(MONTH, @DateX, @DateY)
    				END
    				)

    RETURN @Result
END
GO
