USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaRealXML', 'P') IS NOT NULL
	DROP PROCEDURE pa_ModificarGarantiaRealXML;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaRealXML]

	@psTrama		NTEXT,
	@psRespuesta	VARCHAR(1000) OUTPUT
AS
BEGIN

/******************************************************************
	<Nombre>pa_ModificarGarantiaRealXML</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que guarda los datos que han sido modificados por el usuario.
	</Descripción>
	<Entradas>
			@psTrama		= Trama que posee los datos que serán actualizados y los datos de las pistas de auditoria.
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>14/08/2012</Fecha>
	<Requerimiento> 
			008 Req_Garantías Reales Partido y Finca, Siebel No. 1-21317220.
			009 Req_Validaciones Indicador Inscripción, Siebel No. 1-21317176.
			012 Req_Garantías Real Tipo de bien, Sibel No. 1-21410161.
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>014 Req_Mantenimiento Valuaciones, Siebel No. 1-21537427.</Requerimiento>
			<Fecha>10/04/2013</Fecha>
			<Descripción>
				Se agregan las sentencias necesarias para poder actualizar la información del avalúo más reciente.
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
	SET LANGUAGE Spanish

	DECLARE @viControladorDocXML INT

	EXEC sp_xml_preparedocument @viControladorDocXML OUTPUT, @psTrama

	BEGIN TRANSACTION
	
	UPDATE 
		dbo.GAR_GARANTIA_REAL
	SET 
		cod_tipo_garantia_real	= ISNULL(datos.cod_tipo_garantia_real, GAR_GARANTIA_REAL.cod_tipo_garantia_real),
		cod_partido				= ISNULL(datos.cod_partido, GAR_GARANTIA_REAL.cod_partido),
        numero_finca			= ISNULL(datos.numero_finca, GAR_GARANTIA_REAL.numero_finca),
       	cod_grado				= ISNULL(datos.cod_grado, GAR_GARANTIA_REAL.cod_grado),
       	cedula_hipotecaria		= ISNULL(datos.cedula_hipotecaria, GAR_GARANTIA_REAL.cedula_hipotecaria),
       	cod_clase_bien			= ISNULL(datos.cod_clase_bien, GAR_GARANTIA_REAL.cod_clase_bien),
       	num_placa_bien			= ISNULL(datos.num_placa_bien, GAR_GARANTIA_REAL.num_placa_bien),
       	cod_tipo_bien			= ISNULL(datos.cod_tipo_bien, GAR_GARANTIA_REAL.cod_tipo_bien)
	FROM	OPENXML(@viControladorDocXML, 'DATOS/MODIFICADOS/GARANTIAS', 2)
		WITH (cod_garantia_real BIGINT, cod_tipo_garantia_real SMALLINT, cod_partido SMALLINT, 
			  numero_finca VARCHAR(25), cod_grado VARCHAR(2), cedula_hipotecaria VARCHAR(2),
			  cod_clase_bien VARCHAR(3), num_placa_bien VARCHAR(25), cod_tipo_bien SMALLINT) datos
	WHERE	dbo.GAR_GARANTIA_REAL.cod_garantia_real = datos.cod_garantia_real
	
	IF (@@ERROR <> 0) 
	BEGIN 
		ROLLBACK TRANSACTION 
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, básicos, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 
	END

	UPDATE 
		GAR_GARANTIAS_REALES_X_OPERACION
	SET
		cod_tipo_mitigador			= ISNULL(datosRelacion.cod_tipo_mitigador, GAR_GARANTIAS_REALES_X_OPERACION.cod_tipo_mitigador),
		cod_tipo_documento_legal	= ISNULL(datosRelacion.cod_tipo_documento_legal, GAR_GARANTIAS_REALES_X_OPERACION.cod_tipo_documento_legal),
		monto_mitigador				= ISNULL(datosRelacion.monto_mitigador, GAR_GARANTIAS_REALES_X_OPERACION.monto_mitigador),
		cod_inscripcion				= ISNULL(datosRelacion.cod_inscripcion, GAR_GARANTIAS_REALES_X_OPERACION.cod_inscripcion),
		fecha_presentacion			= ISNULL(datosRelacion.fecha_presentacion, GAR_GARANTIAS_REALES_X_OPERACION.fecha_presentacion),
		porcentaje_responsabilidad	= ISNULL(datosRelacion.porcentaje_responsabilidad, GAR_GARANTIAS_REALES_X_OPERACION.porcentaje_responsabilidad),
		cod_grado_gravamen			= ISNULL(datosRelacion.cod_grado_gravamen, GAR_GARANTIAS_REALES_X_OPERACION.cod_grado_gravamen),
		cod_operacion_especial		= ISNULL(datosRelacion.cod_operacion_especial, GAR_GARANTIAS_REALES_X_OPERACION.cod_operacion_especial),
		fecha_constitucion			= ISNULL(datosRelacion.fecha_constitucion, GAR_GARANTIAS_REALES_X_OPERACION.fecha_constitucion),
		fecha_vencimiento			= ISNULL(datosRelacion.fecha_vencimiento, GAR_GARANTIAS_REALES_X_OPERACION.fecha_vencimiento),
		cod_tipo_acreedor			= ISNULL(datosRelacion.cod_tipo_acreedor, GAR_GARANTIAS_REALES_X_OPERACION.cod_tipo_acreedor),
		cedula_acreedor				= ISNULL(datosRelacion.cedula_acreedor, GAR_GARANTIAS_REALES_X_OPERACION.cedula_acreedor),
		cod_liquidez				= ISNULL(datosRelacion.cod_liquidez, GAR_GARANTIAS_REALES_X_OPERACION.cod_liquidez),
		cod_tenencia				= ISNULL(datosRelacion.cod_tenencia, GAR_GARANTIAS_REALES_X_OPERACION.cod_tenencia),
		fecha_prescripcion			= ISNULL(datosRelacion.fecha_prescripcion, GAR_GARANTIAS_REALES_X_OPERACION.fecha_prescripcion),
		cod_moneda					= ISNULL(datosRelacion.cod_moneda, GAR_GARANTIAS_REALES_X_OPERACION.cod_moneda)
	FROM	OPENXML(@viControladorDocXML, 'DATOS/MODIFICADOS/GAROPER', 2)
		WITH(cod_operacion BIGINT, cod_garantia_real BIGINT, cod_tipo_mitigador SMALLINT,
			 cod_tipo_documento_legal SMALLINT, monto_mitigador DECIMAL(18,2), cod_inscripcion SMALLINT,
			 fecha_presentacion DATETIME, porcentaje_responsabilidad DECIMAL(5,2), 
			 cod_grado_gravamen SMALLINT, cod_operacion_especial SMALLINT, fecha_constitucion DATETIME,
			 fecha_vencimiento DATETIME, cod_tipo_acreedor SMALLINT, cedula_acreedor VARCHAR(30), 
			 cod_liquidez SMALLINT, cod_tenencia SMALLINT, cod_moneda SMALLINT, fecha_prescripcion DATETIME) datosRelacion
	WHERE	dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_operacion		= datosRelacion.cod_operacion
		AND dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_garantia_real	= datosRelacion.cod_garantia_real

	IF (@@ERROR <> 0)
	BEGIN 
		ROLLBACK TRANSACTION 
		SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la relación de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, de la relación, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 2 
	END

	UPDATE 
		dbo.GAR_VALUACIONES_REALES
	SET
		cedula_empresa							= CASE 
													WHEN datosAvaluo.cedula_empresa IS NULL THEN GAR_VALUACIONES_REALES.cedula_empresa
													WHEN LEN(datosAvaluo.cedula_empresa) = 0 THEN NULL 
													ELSE datosAvaluo.cedula_empresa 
												  END,
		cedula_perito							= CASE 
													WHEN datosAvaluo.cedula_perito IS NULL THEN GAR_VALUACIONES_REALES.cedula_perito
													WHEN LEN(datosAvaluo.cedula_perito) = 0 THEN NULL 
													ELSE datosAvaluo.cedula_perito 
												   END,
		monto_ultima_tasacion_terreno			= ISNULL(datosAvaluo.monto_ultima_tasacion_terreno, GAR_VALUACIONES_REALES.monto_ultima_tasacion_terreno),
		monto_ultima_tasacion_no_terreno		= ISNULL(datosAvaluo.monto_ultima_tasacion_no_terreno, GAR_VALUACIONES_REALES.monto_ultima_tasacion_no_terreno),
		monto_tasacion_actualizada_terreno		= ISNULL(datosAvaluo.monto_tasacion_actualizada_terreno, GAR_VALUACIONES_REALES.monto_tasacion_actualizada_terreno),
		monto_tasacion_actualizada_no_terreno	= ISNULL(datosAvaluo.monto_tasacion_actualizada_no_terreno, GAR_VALUACIONES_REALES.monto_tasacion_actualizada_no_terreno),
		fecha_ultimo_seguimiento				= ISNULL(datosAvaluo.fecha_ultimo_seguimiento, GAR_VALUACIONES_REALES.fecha_ultimo_seguimiento),
		monto_total_avaluo						= ISNULL(datosAvaluo.monto_total_avaluo, GAR_VALUACIONES_REALES.monto_total_avaluo),
		fecha_construccion						= ISNULL(datosAvaluo.fecha_construccion, GAR_VALUACIONES_REALES.fecha_construccion),
		Indicador_Actualizado_Calculo			= ISNULL(datosAvaluo.avaluo_actualizado, GAR_VALUACIONES_REALES.Indicador_Actualizado_Calculo),
		Fecha_Semestre_Calculado				= ISNULL(datosAvaluo.fecha_semestre_actualizado, GAR_VALUACIONES_REALES.Fecha_Semestre_Calculado)

	FROM	OPENXML(@viControladorDocXML, 'DATOS/MODIFICADOS/AVALUO', 2)
		WITH(cod_garantia_real BIGINT, fecha_valuacion DATETIME, cedula_empresa VARCHAR(30), cedula_perito VARCHAR(30),
			 monto_ultima_tasacion_terreno MONEY, monto_ultima_tasacion_no_terreno MONEY, 
			 monto_tasacion_actualizada_terreno MONEY, monto_tasacion_actualizada_no_terreno MONEY,
			 fecha_ultimo_seguimiento DATETIME, monto_total_avaluo MONEY, fecha_construccion DATETIME,
			 avaluo_actualizado BIT, fecha_semestre_actualizado DATETIME) datosAvaluo
	WHERE	dbo.GAR_VALUACIONES_REALES.cod_garantia_real	= datosAvaluo.cod_garantia_real
		AND dbo.GAR_VALUACIONES_REALES.fecha_valuacion		= datosAvaluo.fecha_valuacion

	IF (@@ERROR <> 0)
	BEGIN 
		ROLLBACK TRANSACTION 
		SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar el avalúo de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, del avalúo, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 3 
	END

	INSERT INTO dbo.GAR_BITACORA (des_tabla, 
                                  cod_usuario, 
                                  cod_ip, 
                                  cod_oficina, 
                                  cod_operacion, 
                                  fecha_hora, 
                                  cod_consulta, 
                                  cod_tipo_garantia, 
                                  cod_garantia, 
                                  cod_operacion_crediticia, 
                                  cod_consulta2, 
                                  des_campo_afectado, 
								  est_anterior_campo_afectado, 
                                  est_actual_campo_afectado)
	SELECT	des_tabla, 
			cod_usuario, 
			cod_ip, 
			cod_oficina, 
			cod_operacion, 
			fecha_hora, 
			cod_consulta, 
			cod_tipo_garantia, 
			cod_garantia, 
			cod_operacion_crediticia, 
            cod_consulta2, 
			des_campo_afectado, 
			est_anterior_campo_afectado, 
			est_actual_campo_afectado
	FROM	OPENXML(@viControladorDocXML, 'DATOS/PISTA_AUDITORIA/BITACORA')
		WITH (des_tabla VARCHAR(50), cod_usuario VARCHAR(30), cod_ip VARCHAR(20), cod_oficina INT, 
			  cod_operacion SMALLINT, fecha_hora DATETIME, cod_consulta TEXT, cod_tipo_garantia SMALLINT,
			  cod_garantia VARCHAR(30), cod_operacion_crediticia VARCHAR(30), cod_consulta2 TEXT,
			  des_campo_afectado VARCHAR(50), est_anterior_campo_afectado VARCHAR(100),
			  est_actual_campo_afectado VARCHAR(100)) 
	IF (@@ERROR <> 0)
	BEGIN 
		ROLLBACK TRANSACTION 
		SET @psRespuesta = N'<RESPUESTA><CODIGO>3</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al insertar las pistas de auditoria de la garantía real actualizada</MENSAJE><DETALLE>Se produjo un error al insertar los datos, de la bitácora. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 4 
	END

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @viControladorDocXML
	
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La actualización de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SELECT @psRespuesta

	RETURN 0
END