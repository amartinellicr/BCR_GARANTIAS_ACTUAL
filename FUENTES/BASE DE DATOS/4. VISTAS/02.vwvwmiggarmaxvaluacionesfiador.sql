USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwvwmiggarmaxvaluacionesfiador]
AS

/******************************************************************
<Nombre>vwvwmiggarmaxvaluacionesfiador</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información los avalúos de los fiadores que serán migrados</Descripción>
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
	VF.cod_garantia_fiduciaria AS cod_garantia_fiduciaria,
	MAX(VF.fecha_valuacion) AS FiduciariasAvales_fec_verificacion_asalariado
FROM GAR_VALUACIONES_FIADOR VF
GROUP BY VF.cod_garantia_fiduciaria
