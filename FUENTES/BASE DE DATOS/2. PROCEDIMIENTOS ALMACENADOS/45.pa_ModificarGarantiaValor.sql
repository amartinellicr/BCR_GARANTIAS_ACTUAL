SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[pa_ModificarGarantiaValor]
	--Garantia valor
	@nGarantiaValor bigint,
	@nTipoGarantia smallint,
	@nClaseGarantia smallint,
	@strNumeroSeguridad varchar(30),
	@dFechaConstitucion datetime = NULL,
	@dFechaVencimiento datetime = NULL,
	@nClasificacion smallint = NULL,
	@strInstrumento varchar(25) = NULL,
	@strSerie varchar(25) = NULL,
	@nTipoEmisor smallint = NULL,
	@strCedulaEmisor varchar(30) = NULL,
	@nPremio decimal(5,2) = NULL,
	@strISIN varchar(25) = NULL,
	@nValorFacial decimal(18,2) = NULL,
	@nMonedaValorFacial smallint = NULL,
	@nValorMercado decimal(18,2) = NULL,
	@nMonedaValorMercado smallint = NULL,
	@nTenencia smallint = NULL,
	@dFechaPrescripcion datetime = NULL,
	--Garantia valor X Operacion
	@nOperacion bigint,
	@nTipoMitigador smallint = NULL,
	@nTipoDocumentoLegal smallint = NULL,
	@nMontoMitigador decimal(18,2) = NULL,
	@nInscripcion smallint = NULL,
	@nPorcentaje decimal(5,2) = NULL,
	@nGradoGravamen smallint = NULL,
	@nGradoPrioridades smallint = NULL,
	@nMontoPrioridades decimal(18,2) = NULL,
	@nOperacionEspecial smallint = NULL,
	@nTipoAcreedor smallint = NULL,
	@strCedulaAcreedor varchar(30) = NULL,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
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
			@nPorcentaje				= Porcentaje de aceptación asignado a la garantía.
			@nGradoGravamen				= Código del grado de gravamen de la garantía.
			@nGradoPrioridades			= Código del grado de prioridad de la garantía.
			@nMontoPrioridades			= Monto de la prioridad de la garantía.
			@nOperacionEspecial			= Código de la operación especial de la garantía.
			@nTipoAcreedor				= Código del tipo de persona del acreedor.
			@strCedulaAcreedor			= Identificación del acreedor.
			@strUsuario					= Identificación del usuario que realiza la actualización.
			@strIP						= Dirección IP de la máquina desde donde se realiza la actualización.
			@nOficina					= Código de la oficina desde donde se realiza la actualización.
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
		fecha_prescripcion = @dFechaPrescripcion
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
		cedula_acreedor = @strCedulaAcreedor
	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_valor = @nGarantiaValor

COMMIT TRANSACTION
RETURN 0
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



