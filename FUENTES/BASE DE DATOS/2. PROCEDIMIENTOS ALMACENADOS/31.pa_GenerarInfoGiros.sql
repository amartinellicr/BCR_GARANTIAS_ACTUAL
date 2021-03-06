SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGiros', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGiros;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGiros]
	@IDUsuario VARCHAR(30) = NULL
AS

/******************************************************************
<Nombre>pa_GenerarInfoGiros</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento que se encarga de obtener la información de los giros, utilizada para la generación 
             del archivo que requiere SEGUI. La base de este procedimiento fue proporcionado por el Ing. Javier Chaves Alvarado.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>30/05/2010</Fecha>
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
	SET NOCOUNT ON
	SET XACT_ABORT ON

	
	/*Se declaran las variables para utilizar la fecha actual como un entero y para almacenar el tipo de cambio obtenido*/
	DECLARE
		@montoTipoCambio	MONEY

	/*Se obtiene el tipo de cambio a la fecha actual*/
	SET @montoTipoCambio = dbo.ufn_ObtenerTipoCambioSICC (GETDATE())

	/*Extrae la información de los giros*/
	SELECT 
		prmca_pco_ofici,
		prmca_pco_moned,
		prmca_pco_produc,
		prmca_pnu_contr,
		prmoc_pco_ofici,
		prmoc_pco_moned,
		prmoc_pco_produ,
		prmoc_pnu_oper,
		CASE prmoc_pco_moned
			WHEN 1 THEN prmoc_psa_actual
			WHEN 2 THEN prmoc_psa_actual * @montoTipoCambio
		END AS prmoc_psa_actual

	FROM
		gar_sicc_prmca
		INNER JOIN gar_sicc_prmoc
		ON prmca_pco_ofici = prmoc_pco_oficon --prmoc_pco_ofici
		AND prmca_pco_moned = prmoc_pcomonint --prmoc_pco_moned
		AND prmca_pnu_contr = prmoc_pnu_contr

	WHERE 
		prmca_estado = 'A'
		AND prmoc_estado = 'A'
		AND prmoc_pcoctamay <> 815 
		AND prmoc_pse_proces = 1

	ORDER BY prmca_pnu_contr
END

