SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Consultar_Garantias_x_Perfil', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Consultar_Garantias_x_Perfil;
GO

CREATE PROCEDURE [dbo].[pa_Consultar_Garantias_x_Perfil]

@codigo_catalogo int

AS

/******************************************************************
<Nombre>pa_Consultar_Garantias_x_Perfil</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar información de acuerdo al número de catálogo 
             proporcionado.
</Descripción>
<Entradas>
	@codigo_catalogo = Número del catálogo donde se encuentran almacenados los tipo de garantía por perfil
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
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


    SELECT cat_campo, cat_descripcion
	FROM   dbo.CAT_ELEMENTO
	WHERE  cat_catalogo = @codigo_catalogo
	
