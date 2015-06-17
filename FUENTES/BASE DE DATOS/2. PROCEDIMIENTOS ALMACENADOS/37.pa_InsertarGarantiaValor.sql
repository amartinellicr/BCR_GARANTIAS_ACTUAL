SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[pa_InsertarGarantiaValor]
	--Garantia valor
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
	--@dFechaPresentacion datetime = NULL,
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
<Nombre>pa_InsertarGarantiaValor</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite insertar la información de una garantía de valor.</Descripción>
<Entradas>
	@nTipoGarantia			= Código de tipo de garantía
	@nClaseGarantia			= Código de la clase de garantía
	@strNumeroSeguridad		= Número de seguridad
	@dFechaConstitucion		= Fecha de constitución
	@dFechaVencimiento		= Fecha de vencimiento
	@nClasificacion			= Código de clasificacion del instrumento
	@strInstrumento			= Descripción del instrumento
	@strSerie				= Serie del instrumento
	@nTipoEmisor			= Código de tipo de persona del emisor
	@strCedulaEmisor		= Cédula del emisor
	@nPremio				= Porcentaje de premio
	@strISIN				= Código de ISIN
	@nValorFacial			= Valor facial de la garantía
	@nMonedaValorFacial		= Código de moneda del valor facial
	@nValorMercado			= Valor de mercado de la garantía
	@nMonedaValorMercado	= Código de moneda del valor de mercado
	@nTenencia				= Código de tenencia
	@dFechaPrescripcion		= Fecha de prescripción
	@nOperacion				= Consecutivo interno de la operación crediticia o del contrato
	@nTipoMitigador			= Código de tipo mitigador riesgo
	@nTipoDocumentoLegal	= Código de tipo de documento legal
	@nMontoMitigador		= Monto mitigador
	@nInscripcion			= Código de inscripción
	@dFechaPresentacion		= Fecha de presentación
	@nPorcentaje			= Porcentaje de responsabilidad
	@nGradoGravamen			= Código de grado de gravamen
	@nGradoPrioridades		= Código de grado de prioridades
	@nMontoPrioridades		= Monto de prioridades
	@nOperacionEspecial		= Código de operación especial
	@nTipoAcreedor			= Código de persona del acreedor
	@strCedulaAcreedor		= Cédula del acreedor
	@strUsuario				= Usuario que realiza la transacción
	@strIP					= IP de la máquina donde se realiza la transacción
	@nOficina				= Oficina donde se realiza la transacción
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

DECLARE @nGarantiaValor bigint

BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_GARANTIA_VALOR
			WHERE cod_clase_garantia = @nClaseGarantia
			AND numero_seguridad = @strNumeroSeguridad) BEGIN

		INSERT INTO GAR_GARANTIA_VALOR
		(
			cod_tipo_garantia,
			cod_clase_garantia,
			numero_seguridad,
			fecha_constitucion,
			fecha_vencimiento_instrumento,
			cod_clasificacion_instrumento,
			des_instrumento,
			des_serie_instrumento,
			cod_tipo_emisor,
			cedula_emisor,
			premio,
			cod_isin,
			valor_facial,
			cod_moneda_valor_facial,
			valor_mercado,
			cod_moneda_valor_mercado,
			cod_tenencia,
			fecha_prescripcion
		)
		VALUES
		(
			@nTipoGarantia,
			@nClaseGarantia,
			@strNumeroSeguridad,
			@dFechaConstitucion,
			@dFechaVencimiento,
			@nClasificacion,
			@strInstrumento,
			@strSerie,
			@nTipoEmisor,
			@strCedulaEmisor,
			@nPremio,
			@strISIN,
			@nValorFacial,
			@nMonedaValorFacial,
			@nValorMercado,
			@nMonedaValorMercado,
			@nTenencia,
			@dFechaPrescripcion
		)
	
		SET @nGarantiaValor = Scope_Identity()
	END
	ELSE BEGIN

		SELECT @nGarantiaValor = cod_garantia_valor
		FROM GAR_GARANTIA_VALOR
		WHERE cod_clase_garantia = @nClaseGarantia
		AND numero_seguridad = @strNumeroSeguridad
	END 

	INSERT INTO GAR_GARANTIAS_VALOR_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_valor,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		monto_mitigador,
		cod_inscripcion,
		--fecha_presentacion_registro,
		porcentaje_responsabilidad,
		cod_grado_gravamen,
		cod_grado_prioridades,
		monto_prioridades,
		cod_operacion_especial,
		cod_tipo_acreedor,
		cedula_acreedor
	)
	VALUES
	(
		@nOperacion,
		@nGarantiaValor,
		@nTipoMitigador,
		@nTipoDocumentoLegal,
		@nMontoMitigador,
		@nInscripcion,
		--@dFechaPresentacion,		
		@nPorcentaje,
		@nGradoGravamen,
		@nGradoPrioridades,
		@nMontoPrioridades,
		@nOperacionEspecial,
		@nTipoAcreedor,
		@strCedulaAcreedor
	)

COMMIT TRANSACTION
RETURN 0




