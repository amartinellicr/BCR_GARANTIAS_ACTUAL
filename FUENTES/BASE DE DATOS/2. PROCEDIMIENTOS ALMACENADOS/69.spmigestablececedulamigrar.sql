SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('spmigestablececedulamigrar', 'P') IS NOT NULL
	DROP PROCEDURE dbo.spmigestablececedulamigrar;
GO

CREATE PROCEDURE [dbo].[spmigestablececedulamigrar]
AS

/******************************************************************
<Nombre>spmigestablececedulamigrar</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado realiza la homologación de las cédulas de los deudores, entre la SICC y la SUGEF.
</Descripción>
<Entradas></Entradas>
<Salidas></Salidas>
<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
<Fecha>14/10/2009</Fecha>
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

DECLARE cursor_deudor CURSOR 
     FORWARD_ONLY FOR 
		SELECT 
			D.cedula_deudor,
			ISNULL(D.cedula_deudor_sugef, D.cedula_deudor) AS DeudorCodeudor_cod_iddeudor
		FROM GAR_DEUDOR D
		WHERE EXISTS(
			SELECT 1
			FROM vwmiggaroperacion O
			WHERE O.cedulaRelacionDeudor = D.cedula_deudor)
DECLARE
	@lcedula_deudor VARCHAR(30),
	@lDeudorCodeudor_cod_iddeudor VARCHAR(30)
BEGIN
	SET XACT_ABORT ON
	
	OPEN cursor_deudor

	FETCH NEXT FROM cursor_deudor INTO @lcedula_deudor, @lDeudorCodeudor_cod_iddeudor
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS(
			SELECT 1
			FROM GAR_MIG_DEUDORES
			WHERE DeudorCodeudor_cod_iddeudor = @lDeudorCodeudor_cod_iddeudor)
		BEGIN
			INSERT INTO GAR_MIG_DEUDORES(
				 cedula_deudor, DeudorCodeudor_cod_iddeudor)
			VALUES(
				 @lcedula_deudor, @lDeudorCodeudor_cod_iddeudor)
		END

		FETCH NEXT FROM cursor_deudor INTO @lcedula_deudor, @lDeudorCodeudor_cod_iddeudor
	END

	CLOSE cursor_deudor
	DEALLOCATE cursor_deudor
END
