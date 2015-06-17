set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

IF OBJECT_ID ('pa_Obtener_Valuaciones_Reales', 'P') IS NOT NULL
DROP PROCEDURE pa_Obtener_Valuaciones_Reales;
GO

CREATE PROCEDURE [dbo].[pa_Obtener_Valuaciones_Reales]

	@piGarantia_Real		BIGINT,
	@pbObtenerMasReciente	BIT,
	@piCatalogoRP			INT,
	@piCatalogoIMT			INT,
	@psRespuesta			VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/******************************************************************
	<Nombre>pa_Obtener_Valuaciones_Reales</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene el aval�o m�s reciente de una determinada garant�a real.
	</Descripci�n>
	<Entradas>
			@piGarantia_Real		= Identificaci�n de la garant�a. Este es dato llave usado para la b�squeda del registro que es solicitado.

			@pbObtenerMasReciente	= Detemrina si se obtiene el aval�o m�s reciente de la garant�a (igual a 1) o no (igual a 0).

			@piCatalogoRP			= Se espec�fica el c�digo del catalogo que posee la descripci�n del indicador de recomendaci�n del perito.

			@piCatalogoIMT			= Se espec�fica el c�digo del catalogo que posee la descripci�n del indicador de la inspecci�n menor a 3 meses.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/07/2012</Fecha>
	<Requerimiento>Validaciones Indicador Inscripci�n, Siebel No. 1-21317176</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
******************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

		IF NOT EXISTS (	SELECT	1 
						FROM	dbo.GAR_VALUACIONES_REALES
						WHERE	cod_garantia_real	= @piGarantia_Real
					  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La garant�a no posee aval�os</MENSAJE><DETALLE>La garant�a no posee aval�os registrados en este sistema.</DETALLE></RESPUESTA>'
		

		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'1'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'pa_Obtener_Valuaciones_Reales'			AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La garant�a no posee aval�os'		AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!] 
				UNION ALL
		SELECT	DISTINCT
				2							AS Tag,
				1							AS Parent,
				NULL						AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				NULL						AS [RESPUESTA!1!MENSAJE!element], 
				'La garant�a no posee aval�os registrados en este sistema.'	AS [DETALLE!2!] 
				FOR		XML EXPLICIT
		RETURN 1
	END
	ELSE
		BEGIN
			IF(@pbObtenerMasReciente = 1)
				BEGIN
					SELECT DISTINCT	
							1							AS Tag,
							NULL						AS Parent,
							'0'							AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							'pa_Obtener_Valuaciones_Reales' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							'La obtenci�n de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]
					FROM	VALUACIONES_GARANTIAS_REALES_VW A
					WHERE	A.cod_garantia_real			=  @piGarantia_Real

					UNION ALL

					SELECT	DISTINCT
							2							AS Tag,
							1							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]
					FROM	VALUACIONES_GARANTIAS_REALES_VW A
					WHERE	A.cod_garantia_real			=  @piGarantia_Real

					UNION ALL

					SELECT	DISTINCT
							3							AS Tag,
							2							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]
					FROM	VALUACIONES_GARANTIAS_REALES_VW A
					WHERE	A.cod_garantia_real			=  @piGarantia_Real

					UNION ALL

					SELECT	DISTINCT
							4							AS Tag,
							3							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							A.cod_garantia_real													AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(varchar(10), A.fecha_valuacion,103)							AS [AVALUO!4!fecha_valuacion!element], 
							ISNULL(A.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							ISNULL(A.cedula_perito, '')											AS [AVALUO!4!cedula_perito!element], 
							ISNULL(A.monto_ultima_tasacion_terreno, 0)							AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							ISNULL(A.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							ISNULL(A.monto_tasacion_actualizada_terreno, 0)						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							ISNULL(A.monto_tasacion_actualizada_no_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							ISNULL(CONVERT(varchar(10), A.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							ISNULL(A.monto_total_avaluo, 0)										AS [AVALUO!4!monto_total_avaluo!element], 
							ISNULL(A.cod_recomendacion_perito, -1)								AS [AVALUO!4!cod_recomendacion_perito!element], 
							ISNULL(A.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							ISNULL(CONVERT(varchar(10), A.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE ISNULL(A.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT B.cat_campo + '-' + B.cat_descripcion FROM CAT_ELEMENTO B WHERE B.cat_campo = (CONVERT(VARCHAR(5), A.cod_recomendacion_perito)) AND B.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE ISNULL(A.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT C.cat_campo + '-' + C.cat_descripcion FROM CAT_ELEMENTO C WHERE C.cat_campo = (CONVERT(VARCHAR(5), A.cod_inspeccion_menor_tres_meses)) AND C.cat_catalogo = @piCatalogoIMT) 
							END																	AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]
					FROM	VALUACIONES_GARANTIAS_REALES_VW A
					WHERE	A.cod_garantia_real	=  @piGarantia_Real
					FOR		XML EXPLICIT

					SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

					RETURN 0
				END
			ELSE
				BEGIN
					SELECT DISTINCT	
							1							AS Tag,
							NULL						AS Parent,
							'0'							AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							'pa_Obtener_Valuaciones_Reales' AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							'La obtenci�n de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]

					UNION ALL

					SELECT	DISTINCT
							2							AS Tag,
							1							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]

					UNION ALL

					SELECT	DISTINCT
							3							AS Tag,
							2							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							NULL						AS [AVALUO!4!cod_garantia_real!element], 
							NULL						AS [AVALUO!4!fecha_valuacion!element], 
							NULL						AS [AVALUO!4!cedula_empresa!element], 
							NULL						AS [AVALUO!4!cedula_perito!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							NULL						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							NULL						AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							NULL						AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							NULL						AS [AVALUO!4!monto_total_avaluo!element], 
							NULL						AS [AVALUO!4!cod_recomendacion_perito!element], 
							NULL						AS [AVALUO!4!cod_inspeccion_menor_tres_meses!element], 
							NULL						AS [AVALUO!4!fecha_construccion!element],
							NULL						AS [AVALUO!4!des_recomendacion_perito!element],
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]

					UNION ALL

					SELECT	DISTINCT
							4							AS Tag,
							3							AS Parent,
							NULL						AS [RESPUESTA!1!CODIGO!element], 
							NULL						AS [RESPUESTA!1!NIVEL!element], 
							NULL						AS [RESPUESTA!1!ESTADO!element], 
							NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
							NULL						AS [RESPUESTA!1!LINEA!element], 
							NULL						AS [RESPUESTA!1!MENSAJE!element], 
							NULL						AS [DETALLE!2!], 
							NULL						AS [AVALUOS!3!],
							A.cod_garantia_real													AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(varchar(10), A.fecha_valuacion,103)							AS [AVALUO!4!fecha_valuacion!element], 
							ISNULL(A.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							ISNULL(A.cedula_perito, '')											AS [AVALUO!4!cedula_perito!element], 
							ISNULL(A.monto_ultima_tasacion_terreno, 0)							AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							ISNULL(A.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							ISNULL(A.monto_tasacion_actualizada_terreno, 0)						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							ISNULL(A.monto_tasacion_actualizada_no_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							ISNULL(CONVERT(varchar(10), A.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							ISNULL(A.monto_total_avaluo, 0)										AS [AVALUO!4!monto_total_avaluo!element], 
							ISNULL(A.cod_recomendacion_perito, -1)								AS [AVALUO!4!cod_recomendacion_perito!element], 
							ISNULL(A.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							ISNULL(CONVERT(varchar(10), A.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE ISNULL(A.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT B.cat_campo + '-' + B.cat_descripcion FROM CAT_ELEMENTO B WHERE B.cat_campo = (CONVERT(VARCHAR(5), A.cod_recomendacion_perito)) AND B.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE ISNULL(A.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT C.cat_campo + '-' + C.cat_descripcion FROM CAT_ELEMENTO C WHERE C.cat_campo = (CONVERT(VARCHAR(5), A.cod_inspeccion_menor_tres_meses)) AND C.cat_catalogo = @piCatalogoIMT) 
							END																	AS [AVALUO!4!des_inspeccion_menor_tres_meses!element]
					FROM	dbo.GAR_VALUACIONES_REALES A
					WHERE	A.cod_garantia_real	=  @piGarantia_Real
					ORDER BY [AVALUO!4!fecha_valuacion!element] ASC
					FOR		XML EXPLICIT

					SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

					RETURN 0
				
				END
		END
END