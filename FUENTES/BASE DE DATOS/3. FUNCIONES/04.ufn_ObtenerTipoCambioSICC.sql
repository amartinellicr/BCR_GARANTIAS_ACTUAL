USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_ObtenerTipoCambioSICC]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[ufn_ObtenerTipoCambioSICC]
GO


CREATE FUNCTION [dbo].[ufn_ObtenerTipoCambioSICC] 
(
	@Fecha DateTime
)
RETURNS numeric(9,4)
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>ufn_ObtenerTipoCambioSICC</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Funci�n que obtiene el tipo de cambio del SICC, a la fecha especificada.
	</Descripci�n>
	<Entradas>
			@Fecha	= Fecha en la que se requiere el tipo de cambio.
	</Entradas>
	<Salidas>
			@nTipoCambio = Tipo de cambio en la fecha dada.
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, LiderSoft Internacional S.A.</Autor>
	<Fecha>12/11/2010</Fecha>
	<Requerimiento>
			No aplica.
	</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req Bcr Garantias Migraci�n, Siebel No.1-24015441
			</Requerimiento>
			<Fecha>13/02/2014</Fecha>
			<Descripci�n>
				Se eliminan las referencias al BNX.
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/


	DECLARE @strAnno varchar(2),
		    @strMes varchar(2),
		    @strDia	varchar(2), 
		    @nFecha int,
			@nTipoCambio numeric(9,4),
			@nFechaValida int,
			@nHora	int

	IF ISDATE(@Fecha) = 1
	BEGIN
		SET @strAnno = SUBSTRING((CONVERT(varchar(4), DATEPART(yy, @Fecha))), 3,4)
		SET @strMes = RIGHT('00' + CONVERT(varchar(2), DATEPART(mm, @Fecha)), 2)
		SET @strDia = CONVERT(varchar(2), DATEPART(dd, @Fecha))
		SET @nFecha = CONVERT(int, (@strDia + @strMes + @strAnno))

		/*SE OBTIENE UNA FECHA VALIDA, EN CASO DE NO SER EXACTAMENTE LA QUE SE SOLICITA. 
		  LA FECHA OBTENIDA SER� LA SOLICITADA O BIEN LA PR�XIMA M�S INMEDIATA*/
		SET @nFechaValida = (	SELECT TOP 1 damht_dfe_inic  
								FROM	dbo.GAR_SICC_DAMHT
								WHERE	damht_aco_estado = 'A'
									AND damht_dcotipcam = 1
									AND damht_dco_moned = 4
									AND damht_dfe_inic <= @nFecha
									AND RIGHT(damht_dfe_inic, 4) = (SELECT	MAX(RIGHT(damht_dfe_inic, 4)) 
																	FROM dbo.GAR_SICC_DAMHT
																	WHERE damht_aco_estado = 'A'
																	AND damht_dcotipcam = 1
																	AND damht_dco_moned = 4
																	AND damht_dfe_inic <= @nFecha
																	AND RIGHT(damht_dfe_inic, 2) = @strAnno)
																	ORDER BY damht_dfe_inic DESC)

		/*SE OBTIENE LA HORA M�S RECIENTE*/
		SET @nHora = (	SELECT	MAX(damht_dho_inic)
						FROM	dbo.GAR_SICC_DAMHT
						WHERE	damht_aco_estado = 'A'
							AND damht_dcotipcam = 1
							AND damht_dco_moned = 4
							AND damht_dfe_inic = @nFechaValida)


		/*SE OBTIENE EL TIPO DE CAMBIO*/
		SET @nTipoCambio = (SELECT	damht_dva_camb
							FROM	dbo.GAR_SICC_DAMHT
							WHERE	damht_aco_estado = 'A'
								AND damht_dcotipcam = 1
								AND damht_dco_moned = 4
								AND damht_dfe_inic = @nFechaValida
								AND damht_dho_inic = @nHora)

	END
	ELSE
	BEGIN
		SET @nTipoCambio = 0
	END

	RETURN @nTipoCambio
END
GO


