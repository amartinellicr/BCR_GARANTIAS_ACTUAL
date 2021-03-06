USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaRealXML', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaRealXML;
GO


CREATE PROCEDURE [dbo].[pa_ModificarGarantiaRealXML]
	@psTrama				NTEXT,
	@piCodigo_Garantia_Real BIGINT,
	@piCodigo_Operacion		BIGINT,
	@psCedula_Usuario		VARCHAR(30),
	@psRespuesta			VARCHAR(1000) OUTPUT
AS
BEGIN

/******************************************************************
	<Nombre>pa_ModificarGarantiaRealXML</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que guarda los datos que han sido modificados por el usuario.
	</Descripción>
	<Entradas>
			@psTrama				= Trama que posee los datos que serán actualizados y los datos de las pistas de auditoria.
			@piCodigo_Garantia_Real	= Consecutivo asignado a la garantía real que será modificada.
			@piCodigo_Operacion		= Consecutivo asignado a la operación que respalda la garantía.
			@psCedula_Usuario		= Identificación dle usuario que modifica la garantía.
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
			<Autor> Leonardo Cortes Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>Req_Actualización de procedimientos almacenado, Siebel No. 1-24350791</Requerimiento>
			<Fecha> 18/06/2014</Fecha>
			<Descripción>
				Se actualizan los campos de usuario que modificó y la fecha en que se modificó. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
			<Fecha>19/06/2014</Fecha>
			<Descripción>
					Se agregan los campos referentes a la póliza asociada. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortes Mora,Lidersoft Internacionl S.A</Autor>
			<Requerimiento>Req_Actualización de procedimientos almacenado, Siebel No. 1-24350791</Requerimiento>
			<Fecha>10/09/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se extrae el dato de Fecha_Modifico para su actualizacion
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00025 Segmentación campos % aceptacion Terreno y No terreno</Requerimiento>
			<Fecha>18/09/2015</Fecha>
			<Descripción>
				Se incorpora la modificación de los campos referentes al porcentaje de aceptación del terreno, porcentaje de aceptación del no terreno,
				porcentaje de aceptación del terreno calculado y el porcentaje de aceptación del no terreno calculado.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_2016012910535596 Cambio en Estado de Pólizas</Requerimiento>
			<Fecha>02/02/2016</Fecha>
			<Descripción>
				Se realiza un ajuste al momento de actualizar el indicador de estado del registro de las pólizas relacionadas a garantías,
				se busca activar todas las relaciones para luego desactivar aquellas cuya póliza ha sufrido un cambio de estado. 
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

	--Se declaran las variables
	DECLARE @viControlador_Doc_XML INT,
			@viError_Tran INT, -- Almacena el código del error generado durante la transacción
			@viError_Tran_Gro INT, -- Almacena el código del error generado durante la transacción
			@viError_Tran_Ggr INT, -- Almacena el código del error generado durante la transacción
			@viError_Tran_Gvr INT, -- Almacena el código del error generado durante la transacción
			@vdtFecha_Actual DATETIME --Fecha actual
	
	--Se setean las variables
	SET @vdtFecha_Actual = GETDATE()
			
	EXEC sp_xml_preparedocument @viControlador_Doc_XML OUTPUT, @psTrama

	BEGIN TRANSACTION TRA_Act_Garantia
	
	UPDATE  dbo.GAR_GARANTIA_REAL
	SET		cod_tipo_garantia_real	= COALESCE(datos.cod_tipo_garantia_real, GAR_GARANTIA_REAL.cod_tipo_garantia_real),
			cod_partido				= COALESCE(datos.cod_partido, GAR_GARANTIA_REAL.cod_partido),
			numero_finca			= COALESCE(datos.numero_finca, GAR_GARANTIA_REAL.numero_finca),
       		cod_grado				= COALESCE(datos.cod_grado, GAR_GARANTIA_REAL.cod_grado),
       		cedula_hipotecaria		= COALESCE(datos.cedula_hipotecaria, GAR_GARANTIA_REAL.cedula_hipotecaria),
       		cod_clase_bien			= COALESCE(datos.cod_clase_bien, GAR_GARANTIA_REAL.cod_clase_bien),
       		num_placa_bien			= COALESCE(datos.num_placa_bien, GAR_GARANTIA_REAL.num_placa_bien),
       		cod_tipo_bien			= COALESCE(datos.cod_tipo_bien, GAR_GARANTIA_REAL.cod_tipo_bien),
       		Usuario_Modifico		= COALESCE(datos.Usuario_Modifico, GAR_GARANTIA_REAL.Usuario_Modifico),       	
       		Fecha_Modifico			= COALESCE(datos.Fecha_Modifico, GAR_GARANTIA_REAL.Fecha_Modifico),
       		Indicador_Vivienda_Habitada_Deudor = COALESCE(datos.Indicador_Vivienda_Habitada_Deudor, GAR_GARANTIA_REAL.Indicador_Vivienda_Habitada_Deudor)
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/GARANTIAS', 2)
		WITH (cod_garantia_real BIGINT, cod_tipo_garantia_real SMALLINT, cod_partido SMALLINT, 
			  numero_finca VARCHAR(25), cod_grado VARCHAR(2), cedula_hipotecaria VARCHAR(2),
			  cod_clase_bien VARCHAR(3), num_placa_bien VARCHAR(25), cod_tipo_bien SMALLINT, 
			  Fecha_Modifico DATETIME,
			  Usuario_Modifico VARCHAR(30),
			  Indicador_Vivienda_Habitada_Deudor BIT) datos
	WHERE	dbo.GAR_GARANTIA_REAL.cod_garantia_real = datos.cod_garantia_real
	
	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Garantia
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Garantia
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, básicos, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 1 
	END

	BEGIN TRANSACTION TRA_Act_Relacion

	UPDATE	dbo.GAR_GARANTIAS_REALES_X_OPERACION
	SET		cod_tipo_mitigador			= COALESCE(datosRelacion.cod_tipo_mitigador, GAR_GARANTIAS_REALES_X_OPERACION.cod_tipo_mitigador),
			cod_tipo_documento_legal	= COALESCE(datosRelacion.cod_tipo_documento_legal, GAR_GARANTIAS_REALES_X_OPERACION.cod_tipo_documento_legal),
			monto_mitigador				= COALESCE(datosRelacion.monto_mitigador, GAR_GARANTIAS_REALES_X_OPERACION.monto_mitigador),
			cod_inscripcion				= COALESCE(datosRelacion.cod_inscripcion, GAR_GARANTIAS_REALES_X_OPERACION.cod_inscripcion),
			fecha_presentacion			= COALESCE(datosRelacion.fecha_presentacion, GAR_GARANTIAS_REALES_X_OPERACION.fecha_presentacion),
			porcentaje_responsabilidad	= COALESCE(datosRelacion.porcentaje_responsabilidad, GAR_GARANTIAS_REALES_X_OPERACION.porcentaje_responsabilidad),
			cod_grado_gravamen			= COALESCE(datosRelacion.cod_grado_gravamen, GAR_GARANTIAS_REALES_X_OPERACION.cod_grado_gravamen),
       		Usuario_Modifico			= COALESCE(datosRelacion.Usuario_Modifico, GAR_GARANTIAS_REALES_X_OPERACION.Usuario_Modifico),    
       		Fecha_Modifico				= COALESCE(datosRelacion.Fecha_Modifico, GAR_GARANTIAS_REALES_X_OPERACION.Fecha_Modifico),
			Porcentaje_Aceptacion		= COALESCE(datosRelacion.Porcentaje_Aceptacion, GAR_GARANTIAS_REALES_X_OPERACION.Porcentaje_Aceptacion) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/GAROPER', 2)
		WITH(cod_operacion BIGINT, cod_garantia_real BIGINT, cod_tipo_mitigador SMALLINT,
			 cod_tipo_documento_legal SMALLINT, monto_mitigador DECIMAL(18,2), cod_inscripcion SMALLINT,
			 fecha_presentacion DATETIME, porcentaje_responsabilidad DECIMAL(5,2), 
			 cod_grado_gravamen SMALLINT, cod_operacion_especial SMALLINT, fecha_constitucion DATETIME,
			 fecha_vencimiento DATETIME, cod_tipo_acreedor SMALLINT, cedula_acreedor VARCHAR(30), 
			 cod_liquidez SMALLINT, cod_tenencia SMALLINT, cod_moneda SMALLINT, fecha_prescripcion DATETIME, 
			  Fecha_Modifico DATETIME,
			 Usuario_Modifico VARCHAR(30), Porcentaje_Aceptacion DECIMAL(5,2)) datosRelacion
	WHERE	dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_operacion		= datosRelacion.cod_operacion
		AND dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_garantia_real	= datosRelacion.cod_garantia_real

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Relacion
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Relacion
		SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la relación de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, de la relación, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 2 
	END
	
	BEGIN TRANSACTION TRA_Act_Avaluo
	
	UPDATE	dbo.GAR_VALUACIONES_REALES
	SET		cedula_empresa							= CASE 
														WHEN datosAvaluo.cedula_empresa IS NULL THEN GAR_VALUACIONES_REALES.cedula_empresa
														WHEN LEN(datosAvaluo.cedula_empresa) = 0 THEN NULL 
														ELSE datosAvaluo.cedula_empresa 
													  END,
			cedula_perito							= CASE 
														WHEN datosAvaluo.cedula_perito IS NULL THEN GAR_VALUACIONES_REALES.cedula_perito
														WHEN LEN(datosAvaluo.cedula_perito) = 0 THEN NULL 
														ELSE datosAvaluo.cedula_perito 
													   END,
			monto_ultima_tasacion_terreno			= COALESCE(datosAvaluo.monto_ultima_tasacion_terreno, GAR_VALUACIONES_REALES.monto_ultima_tasacion_terreno),
			monto_ultima_tasacion_no_terreno		= COALESCE(datosAvaluo.monto_ultima_tasacion_no_terreno, GAR_VALUACIONES_REALES.monto_ultima_tasacion_no_terreno),
			monto_tasacion_actualizada_terreno		= COALESCE(datosAvaluo.monto_tasacion_actualizada_terreno, GAR_VALUACIONES_REALES.monto_tasacion_actualizada_terreno),
			monto_tasacion_actualizada_no_terreno	= COALESCE(datosAvaluo.monto_tasacion_actualizada_no_terreno, GAR_VALUACIONES_REALES.monto_tasacion_actualizada_no_terreno),
			fecha_ultimo_seguimiento				= COALESCE(datosAvaluo.fecha_ultimo_seguimiento, GAR_VALUACIONES_REALES.fecha_ultimo_seguimiento),
			monto_total_avaluo						= COALESCE(datosAvaluo.monto_total_avaluo, GAR_VALUACIONES_REALES.monto_total_avaluo),
			fecha_construccion						= COALESCE(datosAvaluo.fecha_construccion, GAR_VALUACIONES_REALES.fecha_construccion),
			Indicador_Actualizado_Calculo			= COALESCE(datosAvaluo.avaluo_actualizado, GAR_VALUACIONES_REALES.Indicador_Actualizado_Calculo),
			Fecha_Semestre_Calculado				= COALESCE(datosAvaluo.fecha_semestre_actualizado, GAR_VALUACIONES_REALES.Fecha_Semestre_Calculado),
       		Usuario_Modifico						= COALESCE(datosAvaluo.Usuario_Modifico, GAR_VALUACIONES_REALES.Usuario_Modifico),       	
       		Fecha_Modifico							= COALESCE(datosAvaluo.Fecha_Modifico, GAR_VALUACIONES_REALES.Fecha_Modifico),
       		
       		--INICIO RQ:RQ_MANT_2015062410418218_00025, se agregan nuevos campos
       		
       		Porcentaje_Aceptacion_Terreno			= COALESCE(datosAvaluo.Porcentaje_Aceptacion_Terreno, GAR_VALUACIONES_REALES.Porcentaje_Aceptacion_Terreno),
       		Porcentaje_Aceptacion_No_Terreno		= COALESCE(datosAvaluo.Porcentaje_Aceptacion_No_Terreno, GAR_VALUACIONES_REALES.Porcentaje_Aceptacion_No_Terreno),
       		Porcentaje_Aceptacion_Terreno_Calculado	= COALESCE(datosAvaluo.Porcentaje_Aceptacion_Terreno_Calculado, GAR_VALUACIONES_REALES.Porcentaje_Aceptacion_Terreno_Calculado),
       		Porcentaje_Aceptacion_No_Terreno_Calculado = COALESCE(datosAvaluo.Porcentaje_Aceptacion_No_Terreno_Calculado, GAR_VALUACIONES_REALES.Porcentaje_Aceptacion_No_Terreno_Calculado)
       		
       		--FIN RQ:RQ_MANT_2015062410418218_00025, se agregan nuevos campos
       		
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/AVALUO', 2)
		WITH(cod_garantia_real BIGINT, fecha_valuacion DATETIME, cedula_empresa VARCHAR(30), cedula_perito VARCHAR(30),
			 monto_ultima_tasacion_terreno MONEY, monto_ultima_tasacion_no_terreno MONEY, 
			 monto_tasacion_actualizada_terreno MONEY, monto_tasacion_actualizada_no_terreno MONEY,
			 fecha_ultimo_seguimiento DATETIME, monto_total_avaluo MONEY, fecha_construccion DATETIME,
			 avaluo_actualizado BIT, fecha_semestre_actualizado DATETIME, Fecha_Modifico DATETIME, Usuario_Modifico VARCHAR(30),
			 Porcentaje_Aceptacion_Terreno DECIMAL(5,2), Porcentaje_Aceptacion_No_Terreno DECIMAL(5,2),
			 Porcentaje_Aceptacion_Terreno_Calculado DECIMAL(5,2), Porcentaje_Aceptacion_No_Terreno_Calculado DECIMAL(5,2)) datosAvaluo
	WHERE	dbo.GAR_VALUACIONES_REALES.cod_garantia_real	= datosAvaluo.cod_garantia_real
		AND dbo.GAR_VALUACIONES_REALES.fecha_valuacion		= datosAvaluo.fecha_valuacion

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avaluo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avaluo
		SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar el avalúo de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, del avalúo, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 3 
	END

	BEGIN TRANSACTION TRA_Eli_Rel_Pol
	
	DELETE	FROM dbo.GAR_POLIZAS_RELACIONADAS
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/ELIMINADOS/POLIZAS', 2)
		WITH(Codigo_SAP NUMERIC(8,0), cod_garantia_real BIGINT, cod_operacion BIGINT) datosPolizaEli
	WHERE	dbo.GAR_POLIZAS_RELACIONADAS.Codigo_SAP	= datosPolizaEli.Codigo_SAP
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_operacion = datosPolizaEli.cod_operacion
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_garantia_real = datosPolizaEli.cod_garantia_real	

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Rel_Pol
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Rel_Pol
		SET @psRespuesta = N'<RESPUESTA><CODIGO>6</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al eliminar la relación con la póliza anterior de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar la relación entre la póliza anterior y la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 4
	END

	BEGIN TRANSACTION TRA_Ins_Rel_Pol
	
	INSERT	INTO dbo.GAR_POLIZAS_RELACIONADAS (Codigo_SAP, cod_operacion, cod_garantia_real, Estado_Registro, Monto_Acreencia, Fecha_Inserto, Usuario_Modifico, Fecha_Modifico, Usuario_Inserto)
	SELECT	datosPolizaIns.Codigo_SAP,
		datosPolizaIns.cod_operacion,
		datosPolizaIns.cod_garantia_real,
		1,
		datosPolizaIns.Monto_Acreencia,
		@vdtFecha_Actual,
		datosPolizaIns.Usuario_Inserto,
		@vdtFecha_Actual,
		datosPolizaIns.Usuario_Inserto
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/INSERTAR/POLIZAS', 2)
		WITH(Codigo_SAP NUMERIC(8,0), cod_garantia_real BIGINT, cod_operacion BIGINT, 
			 Monto_Acreencia NUMERIC(16,2), Usuario_Inserto VARCHAR(30)) datosPolizaIns
	WHERE	NOT EXISTS (SELECT	1
						FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
						WHERE	GPR.Codigo_SAP	= datosPolizaIns.Codigo_SAP
							AND GPR.cod_operacion = datosPolizaIns.cod_operacion
							AND GPR.cod_garantia_real = datosPolizaIns.cod_garantia_real)
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_POLIZAS GP1
					WHERE	GP1.cod_operacion = datosPolizaIns.cod_operacion
						AND GP1.Codigo_SAP = datosPolizaIns.Codigo_SAP
						AND GP1.Estado_Registro = 1)
	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Rel_Pol
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Rel_Pol
		SET @psRespuesta = N'<RESPUESTA><CODIGO>4</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al relacionar la póliza a la garantía real</MENSAJE><DETALLE>Se produjo un error al relacionar los datos, de la póliza, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 5
	END

	BEGIN TRANSACTION TRA_Act_Rel_Pol
	
	UPDATE	dbo.GAR_POLIZAS_RELACIONADAS
	SET		Monto_Acreencia			= COALESCE(datosPolizaAct.Monto_Acreencia, GAR_POLIZAS_RELACIONADAS.Monto_Acreencia),
       		Usuario_Modifico		= COALESCE(datosPolizaAct.Usuario_Modifico, GAR_POLIZAS_RELACIONADAS.Usuario_Modifico),       		
       		Fecha_Modifico			= COALESCE(datosPolizaAct.Fecha_Modifico, GAR_POLIZAS_RELACIONADAS.Fecha_Modifico)
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/POLIZAS', 2)
		WITH(Codigo_SAP NUMERIC(8,0), cod_garantia_real BIGINT, cod_operacion BIGINT, 
			 Monto_Acreencia NUMERIC(16,2), 
			 Fecha_Modifico DATETIME,
			 Usuario_Modifico VARCHAR(30)) datosPolizaAct
	WHERE	dbo.GAR_POLIZAS_RELACIONADAS.Codigo_SAP	= datosPolizaAct.Codigo_SAP
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_operacion = datosPolizaAct.cod_operacion
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_garantia_real = datosPolizaAct.cod_garantia_real		

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Rel_Pol
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Rel_Pol
		SET @psRespuesta = N'<RESPUESTA><CODIGO>5</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la póliza de la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos, de la póliza, de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 6
	END

	BEGIN TRANSACTION TRA_Act_Datos_Control
	
	UPDATE  dbo.GAR_GARANTIA_REAL
	SET		Usuario_Modifico		= COALESCE(datos.Usuario_Modifico, GAR_GARANTIA_REAL.Usuario_Modifico),       	
       		Fecha_Modifico			= COALESCE(datos.Fecha_Modifico, GAR_GARANTIA_REAL.Fecha_Modifico)
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/CONTROL', 2)
		WITH (cod_garantia_real BIGINT, Fecha_Modifico DATETIME, Usuario_Modifico VARCHAR(30)) datos
	WHERE	dbo.GAR_GARANTIA_REAL.cod_garantia_real = datos.cod_garantia_real

	UPDATE	dbo.GAR_GARANTIAS_REALES_X_OPERACION
	SET		Usuario_Modifico			= COALESCE(datosRelacion.Usuario_Modifico, GAR_GARANTIAS_REALES_X_OPERACION.Usuario_Modifico),    
       		Fecha_Modifico				= COALESCE(datosRelacion.Fecha_Modifico, GAR_GARANTIAS_REALES_X_OPERACION.Fecha_Modifico)			
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/CONTROL', 2)
		WITH(cod_operacion BIGINT, cod_garantia_real BIGINT, Fecha_Modifico DATETIME, Usuario_Modifico VARCHAR(30)) datosRelacion
	WHERE	dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_operacion		= datosRelacion.cod_operacion
		AND dbo.GAR_GARANTIAS_REALES_X_OPERACION.cod_garantia_real	= datosRelacion.cod_garantia_real
	
	UPDATE	dbo.GAR_VALUACIONES_REALES
	SET		Usuario_Modifico						= COALESCE(datosAvaluo.Usuario_Modifico, GAR_VALUACIONES_REALES.Usuario_Modifico),       	
       		Fecha_Modifico							= COALESCE(datosAvaluo.Fecha_Modifico, GAR_VALUACIONES_REALES.Fecha_Modifico)
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/CONTROL', 2)
		WITH(cod_garantia_real BIGINT, fecha_valuacion DATETIME, Fecha_Modifico DATETIME, Usuario_Modifico VARCHAR(30)) datosAvaluo
	WHERE	dbo.GAR_VALUACIONES_REALES.cod_garantia_real	= datosAvaluo.cod_garantia_real
		AND dbo.GAR_VALUACIONES_REALES.fecha_valuacion		= datosAvaluo.fecha_valuacion

	UPDATE	dbo.GAR_POLIZAS_RELACIONADAS
	SET		Usuario_Modifico		= COALESCE(datosPolizaAct.Usuario_Modifico, GAR_POLIZAS_RELACIONADAS.Usuario_Modifico),       		
       		Fecha_Modifico			= COALESCE(datosPolizaAct.Fecha_Modifico, GAR_POLIZAS_RELACIONADAS.Fecha_Modifico)
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/MODIFICADOS/CONTROL', 2)
		WITH(Codigo_SAP NUMERIC(8,0), cod_garantia_real BIGINT, cod_operacion BIGINT, 
			 Fecha_Modifico DATETIME, Usuario_Modifico VARCHAR(30)) datosPolizaAct
	WHERE	dbo.GAR_POLIZAS_RELACIONADAS.Codigo_SAP	= datosPolizaAct.Codigo_SAP
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_operacion = datosPolizaAct.cod_operacion
		AND dbo.GAR_POLIZAS_RELACIONADAS.cod_garantia_real = datosPolizaAct.cod_garantia_real

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Datos_Control
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Datos_Control
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al actualizar la garantía real</MENSAJE><DETALLE>Se produjo un error al actualizar los datos de control de la garantía real. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 7
	END
	
	BEGIN TRANSACTION TRA_Act_Bitacora
	
	INSERT	INTO dbo.GAR_BITACORA (des_tabla, cod_usuario, cod_ip, cod_oficina, cod_operacion, 
                                   fecha_hora, cod_consulta, cod_tipo_garantia, cod_garantia, 
                                   cod_operacion_crediticia, cod_consulta2, des_campo_afectado, 
								   est_anterior_campo_afectado, est_actual_campo_afectado)
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
	FROM	OPENXML(@viControlador_Doc_XML, 'DATOS/PISTA_AUDITORIA/BITACORA')
		WITH (des_tabla VARCHAR(50), cod_usuario VARCHAR(30), cod_ip VARCHAR(20), cod_oficina INT, 
			  cod_operacion SMALLINT, fecha_hora DATETIME, cod_consulta TEXT, cod_tipo_garantia SMALLINT,
			  cod_garantia VARCHAR(30), cod_operacion_crediticia VARCHAR(30), cod_consulta2 TEXT,
			  des_campo_afectado VARCHAR(50), est_anterior_campo_afectado VARCHAR(100),
			  est_actual_campo_afectado VARCHAR(100)) 

	SET @viError_Tran = @@Error
	
	IF(@viError_Tran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Bitacora
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Bitacora
		SET @psRespuesta = N'<RESPUESTA><CODIGO>5</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
					        '<MENSAJE>Problema al insertar las pistas de auditoria de la garantía real actualizada</MENSAJE><DETALLE>Se produjo un error al insertar los datos, de la bitácora. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

		RETURN 8
	END

	EXEC sp_xml_removedocument @viControlador_Doc_XML
		
	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>pa_ModificarGarantiaRealXML</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La actualización de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SELECT @psRespuesta

	RETURN 0
END