USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmiggarbin]
AS

/******************************************************************
<Nombre>vwmiggarbin</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de los bines que serán migrados</Descripción>
<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
<Fecha>28/08/2009</Fecha>
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

SELECT
	CONVERT(VARCHAR(6), V.bin) AS BinesTarjetasSistar_num_bin,
	V.fecingreso AS BinesTarjetasSistar_fec_ingreso
FROM TAR_BIN_SISTAR V

