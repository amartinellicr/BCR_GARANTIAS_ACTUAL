USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwvwmiggarempresas]
AS

/******************************************************************
<Nombre>vwvwmiggarempresas</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las empresas valuadoras que serán migradas</Descripción>
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
E.cedula_empresa AS cedula_relacion,
E.tipo_id_sugef,
E.cedula_empresa_sugef,
E.ind_actualizo_cedulasugef,
ISNULL(E.tipo_id_sugef, 2) AS TiposPersonas_cod_tipo_persona,
ISNULL(E.cedula_empresa_sugef, E.cedula_empresa) AS Empresas_num_idempresa,
E.des_empresa AS Empresas_nom_empresa,
LEFT(E.des_direccion, 150) AS Empresas_des_direccion_empresa,
E.des_telefono AS Empresas_num_telefono_empresa,
E.des_email AS Empresas_des_email_empresa
FROM GAR_EMPRESA E

--select * from vwvwmiggarempresas
