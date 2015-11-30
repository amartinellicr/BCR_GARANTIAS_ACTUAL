USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaValor;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaValor]
	--Garantia valor
	@nGarantiaValor BIGINT,
	@nTipoGarantia SMALLINT,
	@nClaseGarantia SMALLINT,
	@strNumeroSeguridad VARCHAR(30),
	@dFechaConstitucion DATETIME = NULL,
	@dFechaVencimiento DATETIME = NULL,
	@nClasificacion SMALLINT = NULL,
	@strInstrumento VARCHAR(25) = NULL,
	@strSerie VARCHAR(25) = NULL,
	@nTipoEmisor SMALLINT = NULL,
	@strCedulaEmisor VARCHAR(30) = NULL,
	@nPremio DECIMAL(5,2) = NULL,
	@strISIN VARCHAR(25) = NULL,
	@nValorFacial DECIMAL(18,2) = NULL,
	@nMonedaValorFacial SMALLINT = NULL,
	@nValorMercado DECIMAL(18,2) = NULL,
	@nMonedaValorMercado SMALLINT = NULL,
	@nTenencia SMALLINT = NULL,
	@dFechaPrescripcion DATETIME = NULL,
	--Garantia valor X Operacion
	@nOperacion BIGINT,
	@nTipoMitigador SMALLINT = NULL,
	@nTipoDocumentoLegal SMALLINT = NULL,
	@nMontoMitigador DECIMAL(18,2) = NULL,
	@nInscripcion SMALLINT = NULL,
	@nPorcentaje DECIMAL(5,2) = NULL,
	@nGradoGravamen SMALLINT = NULL,
	@nGradoPrioridades SMALLINT = NULL,
	@nMontoPrioridades DECIMAL(18,2) = NULL,
	@nOperacionEspecial SMALLINT = NULL,
	@nTipoAcreedor SMALLINT = NULL,
	@strCedulaAcreedor VARCHAR(30) = NULL,
	--Bitacora
	@strUsuario VARCHAR(30),
	@strIP VARCHAR(20),
	@nOficina SMALLINT = NULL,
	@pdPorcentaje_Aceptacion DECIMAL(5,2)
AS

/******************************************************************
	<Nombre>pa_ModificarGarantiaValor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que actualiza los datos de una garantía de valor específica.
	</Descripción>
	<Entradas>
  			@nGarantiaValor				= Consecutivo de la garantía real consultada. Este el dato llave usado para la búsqueda.
			@nTipoGarantia				= Código del tipo de garantía.
			@nClaseGarantia				= Código de la clase de garantía.
			@strNumeroSeguridad			= Número de seguridad de la garantía.
			@dFechaConstitucion			= Fecha de constitución de la garantía.
			@dFechaVencimiento			= Fecha de vencimiento de la garantía.
			@nClasificacion				= Código de la clasificación del instrumento.
			@strInstrumento				= Identificación del instrumento.
			@strSerie					= Serie del instrumento.
			@nTipoEmisor				= Código del tipo de persona del emisor del instrumento.
			@strCedulaEmisor			= Identificación del emisor del instrumento.
			@nPremio					= Porcentaje del premio asignado al instrumento.
			@strISIN					= Código ISIN del instrumento.
			@nValorFacial				= Monto del valor facial del instrumento.
			@nMonedaValorFacial			= Código de la moneda del valor facial del instrumento.
			@nValorMercado				= Monto del valor mercado del instrumento.
			@nMonedaValorMercado		= Código de la moneda del valor mercado del instrumento.
			@nTenencia					= Código de tenencia de la garantía.
			@dFechaPrescripcion			= Fecha de prescripción de la garantía.
			@nOperacion					= Consecutivo de la operación al a que está asociada la garantía real consultada. Este el dato llave usado para la búsqueda.
			@nTipoMitigador				= Código del tipo de mitigador de riesgo de la garantía.
			@nTipoDocumentoLegal		= Código del tipo de documento legal de la garantía.
			@nMontoMitigador			= Monto mitigador asignado a la garantía.
			@nInscripcion				= Código del indicador de inscripción.
			@nPorcentaje				= Porcentaje de responsabilidad asignado a la garantía.
			@nGradoGravamen				= Código del grado de gravamen de la garantía.
			@nGradoPrioridades			= Código del grado de prioridad de la garantía.
			@nMontoPrioridades			= Monto de la prioridad de la garantía.
			@nOperacionEspecial			= Código de la operación especial de la garantía.
			@nTipoAcreedor				= Código del tipo de persona del acreedor.
			@strCedulaAcreedor			= Identificación del acreedor.
			@strUsuario					= Identificación del usuario que realiza la actualización.
			@strIP						= Dirección IP de la máquina desde donde se realiza la actualización.
			@nOficina					= Código de la oficina desde donde se realiza la actualización.
			@pdPorcentaje_Aceptacion	= Porcentaje de aceptación asignado a la garantía.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>009 Req_Validaciones Indicador Inscripción, Siebel No. 1-21317176 (Correo electrónico enviado el 25/09/2012)</Requerimiento>
			<Fecha>28/09/2012</Fecha>
			<Descripción>
				Debido al ajuste aplicado, en virtud de la atención del requerimiento #009 (Siebel No. 1-21317176), 
				se detecta que la fecha de presentación siempre será reportada enel archivo de inconsistencias,
				sin que le usuario pueda realizar el ajuste del a misma desde la aplicación, por ende, 
				el usuario solicita que esta fecha se igual con la fecha de constitución de la garantía.
		</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortes Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>
				Actualizacion de procedimientos almacenado, Siebel No. 1-24350791.	
			</Requerimiento>
			<Fecha>23/06/2014</Fecha>
			<Descripción>
					Se agregan los campos de Usuario_Modifico, Fecha_Modificacion
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
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

BEGIN TRANSACTION	

	UPDATE 
		GAR_GARANTIA_VALOR
	SET 
		fecha_constitucion = @dFechaConstitucion,
		fecha_vencimiento_instrumento = @dFechaVencimiento,
		cod_clasificacion_instrumento = @nClasificacion,
		des_instrumento = @strInstrumento,
		des_serie_instrumento = @strSerie,
		cod_tipo_emisor = @nTipoEmisor,
		cedula_emisor = @strCedulaEmisor,
		premio = @nPremio,
		cod_isin = @strISIN,
		valor_facial = @nValorFacial,
		cod_moneda_valor_facial = @nMonedaValorFacial, 
		valor_mercado = @nValorMercado,
		cod_moneda_valor_mercado = @nMonedaValorMercado,
		cod_tenencia = @nTenencia,
		fecha_prescripcion = @dFechaPrescripcion,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE()

	WHERE
		cod_garantia_valor = @nGarantiaValor

	
	UPDATE 
		GAR_GARANTIAS_VALOR_X_OPERACION
	SET
		cod_tipo_mitigador = @nTipoMitigador,
		cod_tipo_documento_legal = @nTipoDocumentoLegal,
		monto_mitigador = @nMontoMitigador,
		cod_inscripcion = @nInscripcion,
		fecha_presentacion_registro = @dFechaConstitucion,
		porcentaje_responsabilidad = @nPorcentaje, 
		cod_grado_gravamen = @nGradoGravamen,
		cod_grado_prioridades = @nGradoPrioridades,
		monto_prioridades = @nMontoPrioridades,
		cod_operacion_especial = @nOperacionEspecial,
		cod_tipo_acreedor = @nTipoAcreedor,
		cedula_acreedor = @strCedulaAcreedor,
		Usuario_Modifico = @strUsuario,
		Fecha_Modifico = GETDATE(),
		Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion

	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_valor = @nGarantiaValor

COMMIT TRANSACTION
RETURN 0
