set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

IF OBJECT_ID ('ufn_ConvertirCodigoGarantia', 'FN') IS NOT NULL
    DROP FUNCTION ufn_ConvertirCodigoGarantia;
GO

CREATE FUNCTION [dbo].[ufn_ConvertirCodigoGarantia] 
(
	@pvCodigo VARCHAR(64)
)
RETURNS DECIMAL(12,0)    
AS

/******************************************************************
<Nombre>ufn_ConvertirCodigoGarantia</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripci�n>Funci�n que convierte el c�digo suministrado en n�mero. Tambi�n obtiene la porci�n n�merica, 
             en caso de que el c�digo tenga letras o espacios en blanco.</Descripci�n>
<Entradas>
	@pvCodigo = Dato que ser� convertido.
</Entradas>
<Salidas>
	@viCodigo = Valor n�merico obtenido del valor de entrada. 
</Salidas>
<Autor>Arnoldo Martinelli Mar�n, LiderSoft Internacional S.A.</Autor>
<Fecha>12/11/2010</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versi�n>1.0</Versi�n>
<Historial>
	<Cambio>
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripci�n></Descripci�n>
	</Cambio>
</Historial>
******************************************************************/

BEGIN    
 
    DECLARE @viCodigo DECIMAL(12,0),
			@viContador INT,
			@vvCodigoObtenido VARCHAR(64),
			@viEncontroNumero BIT
 
	SET @viCodigo = -1
	SET @vvCodigoObtenido = ''

	IF (dbo.ufn_EsNumero(@pvCodigo) = 1)
	BEGIN
		SET @viCodigo = CONVERT(DECIMAL(12,0), @pvCodigo)
	END
	ELSE
    BEGIN
		SET @viContador = 0
		SET @viEncontroNumero = 0

		WHILE (@viContador <= (LEN(@pvCodigo)))
		BEGIN
			IF(dbo.ufn_EsNumero((SELECT SUBSTRING(@pvCodigo,@viContador,1))) = 1) 
			BEGIN
				IF(((SELECT SUBSTRING(@pvCodigo,@viContador,1)) = ' ') OR ((SELECT SUBSTRING(@pvCodigo,@viContador,1)) = '-'))
				BEGIN
					IF(@viEncontroNumero = 1) 
					BEGIN
						BREAK
					END
				END
				ELSE
				BEGIN
					SET @vvCodigoObtenido = @vvCodigoObtenido + (SELECT SUBSTRING(@pvCodigo,@viContador,1))
					SET @viEncontroNumero = 1
				END
			END
			ELSE
			BEGIN
				IF(@viEncontroNumero = 1) 
				BEGIN
					BREAK
				END
			END
			SET @viContador = @viContador + 1
		END

		
	END
 
	IF(LEN(@vvCodigoObtenido) > 0)
	BEGIN
		SET @viCodigo = CONVERT(DECIMAL(12,0), @vvCodigoObtenido)
	END

	
    RETURN @viCodigo 
 
END  
