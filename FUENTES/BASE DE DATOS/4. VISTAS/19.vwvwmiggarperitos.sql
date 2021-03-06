USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwvwmiggarperitos]
AS

/******************************************************************
<Nombre>vwvwmiggarperitos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de los peritos que serán migrados</Descripción>
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
	E.cedula_perito AS cedula_relacion,
	E.tipo_id_sugef,
	E.cedula_perito_sugef,
	ISNULL(E.cedula_perito_sugef, E.cedula_perito) AS Peritos_num_idperito,
	ISNULL(E.tipo_id_sugef, E.cod_tipo_persona) AS TiposPersonas_cod_tipo_persona,
	E.des_perito AS Peritos_nom_perito,
	E.des_direccion AS Peritos_des_direccion_perito,
	E.des_telefono AS Peritos_num_telefono_perito,
	E.des_email AS Peritos_des_email_perito,
	E.ind_actualizo_cedulasugef
FROM GAR_PERITO E
WHERE cedula_perito = (
	SELECT TOP 1 cedula_perito
	FROM GAR_PERITO P
	WHERE P.cedula_perito_sugef = E.cedula_perito_sugef)
