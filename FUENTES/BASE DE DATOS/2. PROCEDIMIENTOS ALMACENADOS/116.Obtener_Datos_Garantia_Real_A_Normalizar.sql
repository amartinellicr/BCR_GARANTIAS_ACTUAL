USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Datos_Garantia_Real_A_Normalizar', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Obtener_Datos_Garantia_Real_A_Normalizar;
GO


CREATE PROCEDURE [dbo].[Obtener_Datos_Garantia_Real_A_Normalizar]
	@piOperacion		BIGINT,
	@piGarantia			BIGINT,
	@psFecha_Valuacion	VARCHAR(10),
	@pbObtenerAvaluo	BIT,
	@psRespuesta		VARCHAR(1000) OUTPUT
AS

/*****************************************************************************************************************************************************
	<Nombre>Obtener_Datos_Garantia_Real_A_Normalizar</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene los datos de la garant�a real que ser� normalizada.
	</Descripci�n>
	<Entradas>
			@piOperacion			= Consecutivo de la operaci�n al a que est� asociada la garant�a real consultada. Este el dato llave usado para la b�squeda.
  			@piGarantia				= Consecutivo de la garant�a real consultada. Este el dato llave usado para la b�squeda.
			@psFecha_Valuacion		= Fecha del aval�o a ser normalizado.
			@pbObtenerAvaluo		= Indica con uno (1) si el aval�o debe ser obtenido o no (0, cero).
	</Entradas>
	<Salidas>
		@psRespuesta				= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/06/2014</Fecha>
	<Requerimiento>Req_P�lizas, Siebel No. 1-24342731</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/
BEGIN 

	-- Declaraci�n de variables
	DECLARE @viCat_Tipo_Bien				SMALLINT, -- Cat�logo de tipos de bien = 12
			@viCat_Tipo_Mitigador			SMALLINT, -- Cat�logo de tipos de mitigadores de riesgo = 22
			@viCat_Tipos_Polizas_Sap		SMALLINT, -- Cat�logo de los tipos de p�lizas SAP.
			@vsCodigo_Bien				VARCHAR(30), -- C�digo del bien que ser� usado para obtener las operaciones en la cuales participa.
			@vdtFecha_Actual			DATETIME, --Fecha actual del sistema
			@viTipo_Bien					SMALLINT,  -- C�digo del tipo de bien asignado a la garant�a
			@viFecha_Actual_Entera		INT, --Corresponde al a fecha actual en formato num�rico.
			@vdtFecha_Avaluo				DATETIME --Fecha de la valuaci�n a normalizar.

	--Inicializaci�n de variables
	--Se asignan los c�digos de los cat�logos  
	SET @viCat_Tipo_Bien				= 12		
	SET @viCat_Tipo_Mitigador			= 22
	SET	@viCat_Tipos_Polizas_Sap		= 29

	SET @vsCodigo_Bien	= (SELECT	CASE GGR.cod_tipo_garantia_real  
										WHEN 1 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '')  
										WHEN 2 THEN ISNULL((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + ISNULL(GGR.numero_finca, '') 
										WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + '-' + ISNULL(GGR.num_placa_bien, '')
									END
							   FROM		dbo.GAR_GARANTIA_REAL GGR 
							   WHERE	GGR.cod_garantia_real = @piGarantia)

	SET	@vdtFecha_Actual = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	

	SET	@viTipo_Bien =  (SELECT	ISNULL(GGR.cod_tipo_bien, -1)
						FROM	dbo.GAR_GARANTIA_REAL GGR 
						WHERE	GGR.cod_garantia_real = @piGarantia)

	SET @vdtFecha_Avaluo = CONVERT(DATETIME, @psFecha_Valuacion)																

	/************************************************************************************************
	 *                                                                                              * 
	 *								INICIO DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
	
	SELECT DISTINCT	
			1											AS Tag,
			NULL										AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [POLIZAS!4!],
			NULL										AS [POLIZA!5!Codigo_SAP!element],
			NULL										AS [POLIZA!5!Tipo_Poliza!element],
			NULL										AS [POLIZA!5!Monto_Poliza!element],
			NULL										AS [POLIZA!5!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!5!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!5!Cedula_Acreedor!element],
			NULL										AS [POLIZA!5!Nombre_Acreedor!element],
			NULL										AS [POLIZA!5!Monto_Acreencia!element],
			NULL										AS [POLIZA!5!Detalle_Poliza!element],
			NULL										AS [POLIZA!5!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!5!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!5!Monto_Poliza_Colonizado!element]

	UNION ALL

	SELECT DISTINCT	
			2											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			GRO.cod_operacion							AS [GARANTIA!2!cod_operacion!element],
			GRO.cod_garantia_real						AS [GARANTIA!2!cod_garantia_real!element], 
			ISNULL(GGR.cod_tipo_bien,-1)				AS [GARANTIA!2!cod_tipo_bien!element], 
			ISNULL(GRO.cod_tipo_mitigador,-1)			AS [GARANTIA!2!cod_tipo_mitigador!element], 
		    CASE GGR.cod_tipo_bien
				 WHEN NULL THEN '-'                                                                                                                                                                      
				 ELSE (SELECT CE2.cat_campo + '-' + CE2.cat_descripcion FROM CAT_ELEMENTO CE2  WHERE CE2.cat_campo = (CONVERT(VARCHAR(5), GGR.cod_tipo_bien))   AND CE2.cat_catalogo = @viCat_Tipo_Bien )  
			END											AS [GARANTIA!2!des_tipo_bien!element],

			CASE GRO.cod_tipo_mitigador
				 WHEN NULL THEN '-'                                                                                                                                                                          
				 ELSE (SELECT CE3.cat_campo + '-' + CE3.cat_descripcion FROM CAT_ELEMENTO CE3  WHERE CE3.cat_campo = (CONVERT(VARCHAR(5), GRO.cod_tipo_mitigador))  AND CE3.cat_catalogo = @viCat_Tipo_Mitigador )
			END											AS [GARANTIA!2!des_tipo_mitigador!element],
			ISNULL(GGR.Usuario_Modifico,'')				AS [GARANTIA!2!Usuario_Modifico!element],
			CONVERT(VARCHAR(10), (ISNULL(GGR.Fecha_Modifico,'1900-01-01')), 103)  AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [POLIZAS!4!],
			NULL										AS [POLIZA!5!Codigo_SAP!element],
			NULL										AS [POLIZA!5!Tipo_Poliza!element],
			NULL										AS [POLIZA!5!Monto_Poliza!element],
			NULL										AS [POLIZA!5!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!5!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!5!Cedula_Acreedor!element],
			NULL										AS [POLIZA!5!Nombre_Acreedor!element],
			NULL										AS [POLIZA!5!Monto_Acreencia!element],
			NULL										AS [POLIZA!5!Detalle_Poliza!element],
			NULL										AS [POLIZA!5!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!5!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!5!Monto_Poliza_Colonizado!element]
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
	WHERE	GRO.cod_operacion = @piOperacion
		AND GRO.cod_garantia_real = @piGarantia

	UNION ALL

	SELECT DISTINCT	
			3											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			CONVERT(VARCHAR(10), (ISNULL(GRV.fecha_valuacion,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			ISNULL(GRV.cedula_empresa, '')				AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			ISNULL(GRV.cedula_perito, '')				AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			ISNULL(GRV.monto_ultima_tasacion_terreno, 0)			AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			ISNULL(GRV.monto_ultima_tasacion_no_terreno, 0)			AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			ISNULL(GRV.monto_tasacion_actualizada_terreno, 0)		AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			ISNULL(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			CONVERT(VARCHAR(10), (ISNULL(GRV.fecha_ultimo_seguimiento,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			CASE 
				WHEN (ISNULL(GRV.monto_ultima_tasacion_terreno, 0) = 0)
					AND  (ISNULL(GRV.monto_ultima_tasacion_no_terreno, 0) = 0) THEN GRV.monto_total_avaluo
				ELSE (ISNULL(GRV.monto_ultima_tasacion_terreno, 0) + ISNULL(GRV.monto_ultima_tasacion_no_terreno, 0))
			END
														AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			CONVERT(VARCHAR(10), (ISNULL(GRV.fecha_construccion,'1900-01-01')), 103) AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],			
			NULL										AS [POLIZAS!4!],
			NULL										AS [POLIZA!5!Codigo_SAP!element],
			NULL										AS [POLIZA!5!Tipo_Poliza!element],
			NULL										AS [POLIZA!5!Monto_Poliza!element],
			NULL										AS [POLIZA!5!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!5!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!5!Cedula_Acreedor!element],
			NULL										AS [POLIZA!5!Nombre_Acreedor!element],
			NULL										AS [POLIZA!5!Monto_Acreencia!element],
			NULL										AS [POLIZA!5!Detalle_Poliza!element],
			NULL										AS [POLIZA!5!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!5!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!5!Monto_Poliza_Colonizado!element]
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
		ON GRV.cod_garantia_real = GRO.cod_garantia_real
		AND GRV.fecha_valuacion  = @vdtFecha_Avaluo
	WHERE	GRO.cod_operacion = @piOperacion
		AND GRO.cod_garantia_real = @piGarantia
		AND GRV.Indicador_Tipo_Registro = 1
		AND @pbObtenerAvaluo = 1
	
	UNION ALL

	SELECT DISTINCT	
			4											AS Tag,
			1											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [POLIZAS!4!],
			NULL										AS [POLIZA!5!Codigo_SAP!element],
			NULL										AS [POLIZA!5!Tipo_Poliza!element],
			NULL										AS [POLIZA!5!Monto_Poliza!element],
			NULL										AS [POLIZA!5!Moneda_Monto_Poliza!element],
			NULL										AS [POLIZA!5!Fecha_Vencimiento!element],
			NULL										AS [POLIZA!5!Cedula_Acreedor!element],
			NULL										AS [POLIZA!5!Nombre_Acreedor!element],
			NULL										AS [POLIZA!5!Monto_Acreencia!element],
			NULL										AS [POLIZA!5!Detalle_Poliza!element],
			NULL										AS [POLIZA!5!Poliza_Seleccionada!element],
			NULL										AS [POLIZA!5!Descripcion_Tipo_Poliza_Sap!element],
			NULL										AS [POLIZA!5!Monto_Poliza_Colonizado!element]

	UNION ALL
	
	SELECT DISTINCT	
			5											AS Tag,
			4											AS Parent,
			NULL										AS [DATOS!1!],
			NULL										AS [GARANTIA!2!cod_operacion!element],
			NULL										AS [GARANTIA!2!cod_garantia_real!element], 
			NULL										AS [GARANTIA!2!cod_tipo_bien!element], 
			NULL										AS [GARANTIA!2!cod_tipo_mitigador!element], 
			NULL										AS [GARANTIA!2!des_tipo_bien!element],
			NULL										AS [GARANTIA!2!des_tipo_mitigador!element],
			NULL										AS [GARANTIA!2!Usuario_Modifico!element],
			NULL										AS [GARANTIA!2!Fecha_Modifico!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_valuacion!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_empresa!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!cedula_perito!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_ultima_tasacion_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_tasacion_actualizada_no_terreno!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_ultimo_seguimiento!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!monto_total_avaluo!element],
			NULL										AS [AVALUO_MAS_RECIENTE!3!fecha_construccion!element],
			NULL										AS [POLIZAS!4!],
			GPO.Codigo_SAP								AS [POLIZA!5!Codigo_SAP!element],
			GPO.Tipo_Poliza								AS [POLIZA!5!Tipo_Poliza!element],
			GPO.Monto_Poliza							AS [POLIZA!5!Monto_Poliza!element],
			GPO.Moneda_Monto_Poliza						AS [POLIZA!5!Moneda_Monto_Poliza!element],
			ISNULL((CONVERT(VARCHAR(10), GPO.Fecha_Vencimiento, 103)), '')	
														AS [POLIZA!5!Fecha_Vencimiento!element],
			GPO.Cedula_Acreedor							AS [POLIZA!5!Cedula_Acreedor!element],
			GPO.Nombre_Acreedor							AS [POLIZA!5!Nombre_Acreedor!element],
			GPR.Monto_Acreencia							AS [POLIZA!5!Monto_Acreencia!element],
			ISNULL(GPO.Detalle_Poliza, '')				AS [POLIZA!5!Detalle_Poliza!element],
			1											AS [POLIZA!5!Poliza_Seleccionada!element],
			ISNULL(CE1.cat_descripcion, '')				AS [POLIZA!5!Descripcion_Tipo_Poliza_Sap!element],
			GPO.Monto_Poliza_Colonizado					AS [POLIZA!5!Monto_Poliza_Colonizado!element]
	FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
		INNER JOIN	dbo.GAR_POLIZAS GPO 
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
		LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.cat_campo = GPO.Tipo_Poliza
	WHERE	GPR.cod_garantia_real = @piGarantia
		AND GPR.cod_operacion = @piOperacion
		AND CE1.cat_catalogo = @viCat_Tipos_Polizas_Sap
		AND EXISTS (SELECT	1
					FROM	dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
					WHERE	TPB.Codigo_Tipo_Poliza_Sap = GPO.Tipo_Poliza
						AND TPB.Codigo_Tipo_Bien = @viTipo_Bien)
	FOR		XML EXPLICIT

	SET @psRespuesta = N'<RESPUESTA>' +
							'<CODIGO>0</CODIGO>' +
							'<NIVEL></NIVEL>' +
							'<ESTADO></ESTADO>' +
							'<PROCEDIMIENTO>Consultar_Garantia_Real</PROCEDIMIENTO>' +
							'<LINEA></LINEA>' + 
							'<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE>' +
							'<DETALLE></DETALLE>' +
						'</RESPUESTA>'

	RETURN 0

	/************************************************************************************************
	 *                                                                                              * 
	 *								 FIN DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

END

