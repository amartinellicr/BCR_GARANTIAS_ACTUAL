IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_RedondearValor_FV]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[ufn_RedondearValor_FV]
GO


CREATE FUNCTION dbo.ufn_RedondearValor_FV
(	
	@pnValor				NUMERIC(30,15)
) 
RETURNS MONEY
AS
BEGIN
	DECLARE @factor		INT
	DECLARE @temp		AS DOUBLE PRECISION, 
			@fix_temp	AS DOUBLE PRECISION 

	SET @factor		= 100
	SET @temp		= @pnValor * @factor 
	SET @fix_temp	= FLOOR(@temp + 0.5 * SIGN(@pnValor)) 

	IF (@temp - CAST(@temp AS BIGINT) = 0.5) 
	BEGIN 
		IF ((@fix_temp / 2) <> CAST(@fix_temp / 2 AS BIGINT)) 
		BEGIN 
			SET @fix_temp = @fix_temp - SIGN(@pnValor) 
		END 
	END 

	RETURN @fix_temp / @factor 
END
GO 

