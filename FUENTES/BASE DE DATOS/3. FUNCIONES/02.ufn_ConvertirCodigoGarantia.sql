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
		<Autor>Arnoldo Martinelli Mar�n, GrupoMas S.A.</Autor>
		<Requerimiento>RQ_MANT_2015062410418218_00025 Segmentaci�n campos % aceptacion Terreno y No terreno</Requerimiento>
		<Fecha>21/09/2015</Fecha>
		<Descripci�n>
			Se optimiza la funci�n.
		</Descripci�n>
	</Cambio>
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
			@viEncontroNumero BIT,
			@viExpresion VARCHAR(50)
			
			
	SET @viCodigo = -1
	SET @vvCodigoObtenido = ''
	SET @viExpresion = '%[^0-9]%'
	SET @vvCodigoObtenido = @pvCodigo

	IF (dbo.ufn_EsNumero(@pvCodigo) = 1)
	BEGIN
		SET @viCodigo = CONVERT(DECIMAL(12,0), @pvCodigo)
	END
	ELSE
    BEGIN
    		
		WHILE PATINDEX(@viExpresion, @vvCodigoObtenido) > 0
		BEGIN
			SET @vvCodigoObtenido = Stuff(@vvCodigoObtenido, PatIndex(@viExpresion, @vvCodigoObtenido), 1, '')
		END	
	END
 
	IF(LEN(@vvCodigoObtenido) > 0)
	BEGIN
		SET @viCodigo = CONVERT(DECIMAL(12,0), @vvCodigoObtenido)
	END

	
    RETURN @viCodigo 
 
END