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
<Descripción>Función que convierte el código suministrado en número. También obtiene la porción númerica, 
             en caso de que el código tenga letras o espacios en blanco.</Descripción>
<Entradas>
	@pvCodigo = Dato que será convertido.
</Entradas>
<Salidas>
	@viCodigo = Valor númerico obtenido del valor de entrada. 
</Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>12/11/2010</Fecha>
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
