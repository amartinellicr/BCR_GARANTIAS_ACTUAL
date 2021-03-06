USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_EsNumero]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[ufn_EsNumero]
GO


CREATE FUNCTION [dbo].[ufn_EsNumero] 
(
	@num VARCHAR(64)
)
RETURNS BIT    
AS

-- =============================================
-- Autor:		Arnoldo Martinelli Marín, LiderSoft Internacional S.A.
-- Fecha Creación: 12/11/2010
-- Descripción:	Función que determina si un dato es un valor numérico.
-- =============================================
--				HISTORIAL DE CAMBIOS
-- =============================================
-- Autor:		
-- Fecha Modificación: 
-- Descripción:	
-- =============================================
BEGIN    
    IF LEFT(@num, 1) = '-'    
        SET @num = SUBSTRING(@num, 2, LEN(@num))    
 
    DECLARE @IsInt BIT 
 
    SELECT @IsInt = CASE    
    WHEN PATINDEX('%[^0-9-]%', @num) = 0    
        AND CHARINDEX('-', @num) <= 1    
        AND @num NOT IN ('.', '-', '+', '^')   
        AND LEN(@num)>0    
        AND @num NOT LIKE '%-%'   
    THEN    
         1 
    ELSE    
         0 
    END    
 
    IF @IsInt = 1 
        BEGIN 
 
            IF LEN(@num) <= 19 
                BEGIN 
                    DECLARE @test bigint 
                    SELECT @test = convert(bigint, @num) 
                    IF @test <= 9223372036854775807 AND @test >= -9223372036854775807 
                        BEGIN 
                            set @IsInt = 1 
                        END 
                    ELSE 
                        BEGIN 
                            set @IsInt = 0 
                        END 
                END 
            ELSE 
                BEGIN 
                    set @IsInt = 0 
                END 
        END 
 
 
    RETURN @IsInt 
 
END  
