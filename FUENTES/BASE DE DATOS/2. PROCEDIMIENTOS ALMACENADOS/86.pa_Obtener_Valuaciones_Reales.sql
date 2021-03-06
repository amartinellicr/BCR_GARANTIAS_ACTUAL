USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Valuaciones_Reales', 'P') IS NOT NULL
	DROP PROCEDURE Obtener_Valuaciones_Reales;
GO

CREATE PROCEDURE [dbo].[Obtener_Valuaciones_Reales]

	@piGarantia_Real		BIGINT,
	@pbObtenerMasReciente	BIT,
	@piCatalogoRP			INT,
	@piCatalogoIMT			INT,
	@psRespuesta			VARCHAR(1000) OUTPUT
AS
BEGIN

/******************************************************************
	<Nombre>pa_Obtener_Valuaciones_Reales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene el avalúo más reciente de una determinada garantía real.
	</Descripción>
	<Entradas>
			@piGarantia_Real		= Identificación de la garantía. Este es dato llave usado para la búsqueda del registro que es solicitado.

			@pbObtenerMasReciente	= Determina si se obtiene el avalúo más reciente de la garantía (igual a 1) o no (igual a 0).

			@piCatalogoRP			= Se específica el código del catalogo que posee la descripción del indicador de recomendación del perito.

			@piCatalogoIMT			= Se específica el código del catalogo que posee la descripción del indicador de la inspección menor a 3 meses.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/07/2012</Fecha>
	<Requerimiento>Validaciones Indicador Inscripción, Siebel No. 1-21317176</Requerimiento>
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

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

		IF NOT EXISTS (	SELECT	1 
						FROM	dbo.GAR_VALUACIONES_REALES
						WHERE	cod_garantia_real	= @piGarantia_Real
					  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La garantía no posee avalúos</MENSAJE><DETALLE>La garantía no posee avalúos registrados en este sistema.</DETALLE></RESPUESTA>'
		

		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'1'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'pa_Obtener_Valuaciones_Reales'			AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La garantía no posee avalúos'		AS [RESPUESTA!1!MENSAJE!element], 
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
				'La garantía no posee avalúos registrados en este sistema.'	AS [DETALLE!2!] 
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
							'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							VVW.cod_garantia_real												AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(VARCHAR(10), VVW.fecha_valuacion,103)						AS [AVALUO!4!fecha_valuacion!element], 
							COALESCE(VVW.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							COALESCE(VVW.cedula_perito, '')										AS [AVALUO!4!cedula_perito!element], 
							COALESCE(VVW.monto_ultima_tasacion_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							COALESCE(VVW.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							COALESCE(VVW.monto_tasacion_actualizada_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							COALESCE(VVW.monto_tasacion_actualizada_no_terreno, 0)				AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							COALESCE(CONVERT(VARCHAR(10), VVW.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							COALESCE(VVW.monto_total_avaluo, 0)									AS [AVALUO!4!monto_total_avaluo!element], 
							COALESCE(VVW.cod_recomendacion_perito, -1)							AS [AVALUO!4!cod_recomendacion_perito!element], 
							COALESCE(VVW.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							COALESCE(CONVERT(VARCHAR(10), VVW.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE COALESCE(VVW.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CE1.cat_campo + '-' + CE1.cat_descripcion FROM CAT_ELEMENTO CE1 WHERE CE1.cat_campo = (CONVERT(VARCHAR(5), VVW.cod_recomendacion_perito)) AND CE1.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE COALESCE(VVW.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2 WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), VVW.cod_inspeccion_menor_tres_meses)) AND CE2.cat_catalogo = @piCatalogoIMT) 
							END	
																								AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							COALESCE(CONVERT(VARCHAR(100), GP1.des_perito,110),'')				AS [AVALUO!4!nombre_cliente_perito!element],
							COALESCE(CONVERT(VARCHAR(100), GE1.des_empresa,110),'')				AS [AVALUO!4!nombre_cliente_empresa!element]
					FROM	VALUACIONES_GARANTIAS_REALES_VW VVW
						LEFT OUTER JOIN GAR_EMPRESA GE1 
						ON VVW.cedula_empresa = GE1.cedula_empresa
						LEFT OUTER JOIN GAR_PERITO GP1 
						ON VVW.cedula_perito = GP1.cedula_perito
					WHERE	VVW.cod_garantia_real	=  @piGarantia_Real
					FOR		XML EXPLICIT

					SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

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
							'La obtención de datos fue satisfactoria'  AS [RESPUESTA!1!MENSAJE!element], 
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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!nombre_cliente_perito!element],
							NULL						AS [AVALUO!4!nombre_cliente_empresa!element]

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
							GVR.cod_garantia_real													AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(VARCHAR(10), GVR.fecha_valuacion,103)							AS [AVALUO!4!fecha_valuacion!element], 
							COALESCE(GVR.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							COALESCE(GVR.cedula_perito, '')											AS [AVALUO!4!cedula_perito!element], 
							COALESCE(GVR.monto_ultima_tasacion_terreno, 0)							AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							COALESCE(GVR.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							COALESCE(GVR.monto_tasacion_actualizada_terreno, 0)						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							COALESCE(GVR.monto_tasacion_actualizada_no_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							COALESCE(CONVERT(VARCHAR(10), GVR.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							COALESCE(GVR.monto_total_avaluo, 0)										AS [AVALUO!4!monto_total_avaluo!element], 
							COALESCE(GVR.cod_recomendacion_perito, -1)								AS [AVALUO!4!cod_recomendacion_perito!element], 
							COALESCE(GVR.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							COALESCE(CONVERT(VARCHAR(10), GVR.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE COALESCE(GVR.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CE1.cat_campo + '-' + CE1.cat_descripcion FROM CAT_ELEMENTO CE1 WHERE CE1.cat_campo = (CONVERT(VARCHAR(5), GVR.cod_recomendacion_perito)) AND CE1.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE COALESCE(GVR.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2 WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), GVR.cod_inspeccion_menor_tres_meses)) AND CE2.cat_catalogo = @piCatalogoIMT) 
							END																	AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],

							COALESCE(CONVERT(VARCHAR(100), GP1.des_perito,110),'')					AS [AVALUO!4!nombre_cliente_perito!element],
							COALESCE(CONVERT(VARCHAR(100), GE1.des_empresa,110),'')					AS [AVALUO!4!nombre_cliente_empresa!element]
					FROM	dbo.GAR_VALUACIONES_REALES GVR
						LEFT OUTER JOIN GAR_EMPRESA GE1 
						ON GVR.cedula_empresa = GE1.cedula_empresa
						LEFT OUTER JOIN GAR_PERITO GP1 
						ON GVR.cedula_perito = GP1.cedula_perito
					WHERE	GVR.cod_garantia_real	=  @piGarantia_Real
					FOR		XML EXPLICIT

					SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

					RETURN 0
				
				END
		END
END