SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerCatalogos', 'P') IS NOT NULL
	DROP PROCEDURE pa_ObtenerCatalogos;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerCatalogos]
	@psListaCatalogos	VARCHAR(150)
AS

/******************************************************************
	<Nombre>pa_ObtenerCatalogos</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene los datos de los catálogos especificados en la lista suministrada.
	</Descripción>
	<Entradas>
			@psListaCatalogos	= Lista de los catálogos de los cuales se obtendrá la data. La lista debe iniciar
                                  y terminar con el caracter '|', así mismo este caracter debe separar los valores
                                  de la misma.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>17/08/2012</Fecha>
	<Requerimiento>
		008 Req_Garantías Reales Partido y Finca, Siebel No. 1-21317220.
		009 Req_Validaciones Indicador Inscripción, Siebel No. 1-21317176.
		012 Req_Garantías Real Tipo de bien, Sibel No. 1-21410161.
	</Requerimiento>
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

	SELECT DISTINCT	
			1											AS Tag,
			NULL										AS Parent,
			NULL										AS [CATALOGOS!1!],
			NULL										AS [CATALAGO!2!cat_catalogo!element],
			NULL										AS [CATALAGO!2!cat_campo!element], 
			NULL										AS [CATALAGO!2!cat_descripcion!element] 

	UNION ALL

	SELECT DISTINCT	
			2											AS Tag,
			1											AS Parent,
			NULL										AS [CATALOGOS!1!],
			A.cat_catalogo								AS [CATALAGO!2!cat_catalogo!element],
			A.cat_campo									AS [CATALAGO!2!cat_campo!element], 
			RTRIM(LTRIM(A.cat_descripcion))				AS [CATALAGO!2!cat_descripcion!element]

	FROM 
		dbo.CAT_ELEMENTO A

	WHERE
		@psListaCatalogos LIKE '%|' + CONVERT(VARCHAR(5), A.cat_catalogo) + '|%'

	UNION ALL

	SELECT DISTINCT	
			2											AS Tag,
			1											AS Parent,
			NULL										AS [CATALOGOS!1!],
			A.cat_catalogo								AS [CATALAGO!2!cat_catalogo!element],
			-1											AS [CATALAGO!2!cat_campo!element], 
			''											AS [CATALAGO!2!cat_descripcion!element]

	FROM 
		dbo.CAT_ELEMENTO A

	WHERE
		@psListaCatalogos LIKE '%|' + CONVERT(VARCHAR(5), A.cat_catalogo) + '|%'

	FOR		XML EXPLICIT


END