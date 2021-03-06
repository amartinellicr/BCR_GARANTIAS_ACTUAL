USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Obtener_Valuaciones_Reales', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Obtener_Valuaciones_Reales;
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
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene el avalúo más reciente de una determinada garantía real.
	</Descripción>
	<Entradas>
			@piGarantia_Real		= Identificación de la garantía. Este es dato llave usado para la búsqueda del registro que es solicitado.

			@pbObtenerMasReciente	= Detemrina si se obtiene el avalúo más reciente de la garantía (igual a 1) o no (igual a 0).

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
			<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>
				Actualizacion de procedimientos almacenado, Siebel No. 1-24350791.			
			</Requerimiento>
			<Fecha>23/06/2014</Fecha>
			<Descripción>
					Se agregan los campos de Usuario_Modifico, Fecha_Modificacion, Fecha_Inserto,
					Fecha_Replica. 
			</Descripción>
		</Cambio>
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
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]
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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]
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
							NULL						AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]
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
							VWGR.cod_garantia_real													AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(varchar(10), VWGR.fecha_valuacion,103)							AS [AVALUO!4!fecha_valuacion!element], 
							ISNULL(VWGR.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							ISNULL(VWGR.cedula_perito, '')											AS [AVALUO!4!cedula_perito!element], 
							ISNULL(VWGR.monto_ultima_tasacion_terreno, 0)							AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							ISNULL(VWGR.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							ISNULL(VWGR.monto_tasacion_actualizada_terreno, 0)						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							ISNULL(VWGR.monto_tasacion_actualizada_no_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							ISNULL(CONVERT(varchar(10), VWGR.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							ISNULL(VWGR.monto_total_avaluo, 0)										AS [AVALUO!4!monto_total_avaluo!element], 
							ISNULL(VWGR.cod_recomendacion_perito, -1)								AS [AVALUO!4!cod_recomendacion_perito!element], 
							ISNULL(VWGR.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							ISNULL(CONVERT(varchar(10), VWGR.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE ISNULL(VWGR.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CAE.cat_campo + '-' + CAE.cat_descripcion 
									  FROM CAT_ELEMENTO CAE 
									  WHERE CAE.cat_campo = (CONVERT(VARCHAR(5), VWGR.cod_recomendacion_perito)) 
										     AND CAE.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE ISNULL(VWGR.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CAE1.cat_campo + '-' + CAE1.cat_descripcion 
										FROM CAT_ELEMENTO CAE1
										WHERE CAE1.cat_campo = (CONVERT(VARCHAR(5), VWGR.cod_inspeccion_menor_tres_meses)) 
										AND CAE1.cat_catalogo = @piCatalogoIMT) 
							END																	AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],
					
							ISNULL(GVR.Usuario_Modifico, '')									AS [AVALUO!4!Usuario_Modifico!element],							
							ISNULL (SGU.DES_USUARIO,'') 										AS [AVALUO!4!Nombre_Usuario_Modifico!element],							
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Modifico,111), '')			AS [AVALUO!4!Fecha_Modifico!element],
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Inserto,111), '')				AS [AVALUO!4!Fecha_Inserto!element],
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Replica,111), '')				AS [AVALUO!4!Fecha_Replica!element]


					FROM	VALUACIONES_GARANTIAS_REALES_VW VWGR
						INNER JOIN   GAR_VALUACIONES_REALES GVR 
							ON VWGR.cod_garantia_real = GVR.cod_garantia_real 
							AND VWGR.fecha_valuacion = GVR.fecha_valuacion
						LEFT JOIN SEG_USUARIO SGU
							ON SGU.COD_USUARIO  = GVR.Usuario_Modifico 
					WHERE	VWGR.cod_garantia_real	=  @piGarantia_Real

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
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]

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
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]

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
							NULL						AS [AVALUO!4!Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Nombre_Usuario_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Modifico!element],
							NULL						AS [AVALUO!4!Fecha_Inserto!element],
							NULL						AS [AVALUO!4!Fecha_Replica!element]

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
							VWGR.cod_garantia_real													AS [AVALUO!4!cod_garantia_real!element], 
							CONVERT(varchar(10), VWGR.fecha_valuacion,103)							AS [AVALUO!4!fecha_valuacion!element], 
							ISNULL(VWGR.cedula_empresa, '')										AS [AVALUO!4!cedula_empresa!element], 
							ISNULL(VWGR.cedula_perito, '')											AS [AVALUO!4!cedula_perito!element], 
							ISNULL(VWGR.monto_ultima_tasacion_terreno, 0)							AS [AVALUO!4!monto_ultima_tasacion_terreno!element], 
							ISNULL(VWGR.monto_ultima_tasacion_no_terreno, 0)						AS [AVALUO!4!monto_ultima_tasacion_no_terreno!element], 
							ISNULL(VWGR.monto_tasacion_actualizada_terreno, 0)						AS [AVALUO!4!monto_tasacion_actualizada_terreno!element], 
							ISNULL(VWGR.monto_tasacion_actualizada_no_terreno, 0)					AS [AVALUO!4!monto_tasacion_actualizada_no_terreno!element], 
							ISNULL(CONVERT(varchar(10), VWGR.fecha_ultimo_seguimiento,111), '')	AS [AVALUO!4!fecha_ultimo_seguimiento!element], 
							ISNULL(VWGR.monto_total_avaluo, 0)										AS [AVALUO!4!monto_total_avaluo!element], 
							ISNULL(VWGR.cod_recomendacion_perito, -1)								AS [AVALUO!4!cod_recomendacion_perito!element], 
							ISNULL(VWGR.cod_inspeccion_menor_tres_meses, -1)						AS [AVALUO!4!cod_inspeccion_menor_tres_mesesO!element], 
							ISNULL(CONVERT(varchar(10), VWGR.fecha_construccion,111),'')			AS [AVALUO!4!fecha_construccion!element],
							CASE ISNULL(VWGR.cod_recomendacion_perito, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CAE.cat_campo + '-' + CAE.cat_descripcion 
										FROM CAT_ELEMENTO CAE 
										WHERE CAE.cat_campo = (CONVERT(VARCHAR(5), VWGR.cod_recomendacion_perito)) 
										AND CAE.cat_catalogo = @piCatalogoRP) 
							END																	AS [AVALUO!4!des_recomendacion_perito!element],
							CASE ISNULL(VWGR.cod_inspeccion_menor_tres_meses, -1) 
								WHEN -1 THEN '-'  
								ELSE (SELECT CAE1.cat_campo + '-' + CAE1.cat_descripcion 
										FROM CAT_ELEMENTO CAE1 
										WHERE CAE1.cat_campo = (CONVERT(VARCHAR(5), VWGR.cod_inspeccion_menor_tres_meses)) 
										AND CAE1.cat_catalogo = @piCatalogoIMT) 
							END		
																								AS [AVALUO!4!des_inspeccion_menor_tres_meses!element],							
							ISNULL(GVR.Usuario_Modifico, '')									AS [AVALUO!4!Usuario_Modifico!element],
							ISNULL (SGU.DES_USUARIO,'') 											AS [AVALUO!4!Nombre_Usuario_Modifico!element],							
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Modifico,111), '')			AS [AVALUO!4!Fecha_Modifico!element],
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Inserto,111), '')				AS [AVALUO!4!Fecha_Inserto!element],
							ISNULL(CONVERT(VARCHAR(10), GVR.Fecha_Replica,111), '')				AS [AVALUO!4!Fecha_Replica!element]

					FROM	VALUACIONES_GARANTIAS_REALES_VW VWGR
						INNER JOIN   GAR_VALUACIONES_REALES GVR 
							ON VWGR.cod_garantia_real = GVR.cod_garantia_real 
							AND VWGR.fecha_valuacion = GVR.fecha_valuacion
						LEFT JOIN SEG_USUARIO SGU
							ON SGU.COD_USUARIO  = GVR.Usuario_Modifico 
					WHERE	VWGR.cod_garantia_real	=  @piGarantia_Real


					ORDER BY [AVALUO!4!fecha_valuacion!element] ASC
					FOR		XML EXPLICIT

					SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_Obtener_Valuaciones_Reales</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

					RETURN 0
				
				END
		END
END
