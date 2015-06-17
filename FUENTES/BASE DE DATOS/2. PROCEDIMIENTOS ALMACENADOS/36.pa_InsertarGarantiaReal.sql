SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pa_InsertarGarantiaReal]
	--Garantia real
	@nTipoGarantia smallint,
	@nClaseGarantia smallint,
	@nTipoGarantiaReal smallint,
	@nPartido smallint = NULL,
	@strNumFinca varchar(20) = NULL,
	@nGrado smallint = NULL,
	@nCedulaFiduciaria smallint = NULL,
	@strClaseBien varchar(3) = NULL,
	@strNumPlaca varchar(12) = NULL,
	@nTipoBien smallint = NULL,
	--Garantia real X Operacion
	@nOperacion bigint,
	@nTipoMitigador smallint = NULL,
	@nTipoDocumentoLegal smallint = NULL,
	@nMontoMitigador decimal(18,2),
	@nInscripcion smallint = NULL,
	@dFechaPresentacion datetime,
	@nPorcentaje decimal(5,2),
	@nGradoGravamen smallint,
	@nOperacionEspecial smallint = NULL,
	@dFechaConstitucion datetime,
	@dFechaVencimiento datetime,
	@nTipoAcreedor smallint = NULL,
	@strCedulaAcreedor varchar(30) = NULL,
	@nLiquidez smallint,
	@nTenencia smallint,
	@dFechaPrescripcion datetime,
	@nMoneda smallint,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_InsertarGarantiaReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite insertar la información de una garantía real 
             (hipoteca, cédula hipotecaria, prenda).
</Descripción>
<Entradas>
	@nTipoGarantia			= Código de tipo de garantía
	@nClaseGarantia			= Código de la clase de garantía
	@nTipoGarantiaReal		= Código de tipo de garantía real
	@nPartido				= Código de partido
	@strNumFinca			= Número de finca
	@nGrado					= Código de grado
	@nCedulaFiduciaria		= Cédula hipotecaria
	@strClaseBien			= Clase del bien
	@strNumPlaca			= Identificación del bien
	@nTipoBien				= Código del tipo de bien
	@nOperacion				= Consecutivo interno de la operación crediticia o del contrato
	@nTipoMitigador			= Código de tipo mitigador riesgo
	@nTipoDocumentoLegal	= Código de tipo de documento legal
	@nMontoMitigador		= Monto mitigador
	@nInscripcion			= Código de inscripción
	@dFechaPresentacion		= Fecha de presentación
	@nPorcentaje			= Porcentaje de responsabilidad
	@nGradoGravamen			= Código de grado de gravamen
	@nOperacionEspecial		= Código de operación especial
	@dFechaConstitucion		= Fecha de constitución
	@dFechaVencimiento		= Fecha de vencimiento
	@nTipoAcreedor			= Código de persona del acreedor
	@strCedulaAcreedor		= Cédula del acreedor
	@nLiquidez				= Código de liquidez
	@nTenencia				= Código de tenencia
	@dFechaPrescripcion		= Fecha de prescripción
	@nMoneda				= Código de moneda de la garantía
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

DECLARE @nGarantiaReal bigint

BEGIN TRANSACTION	

	IF NOT EXISTS (SELECT 1
			FROM GAR_GARANTIA_REAL
			WHERE cod_clase_garantia = @nClaseGarantia
			AND cod_tipo_garantia_real = @nTipoGarantiaReal
			AND cod_partido = @nPartido
			AND numero_finca = @strNumFinca
			AND cod_grado = @nGrado
			AND cedula_hipotecaria = @nCedulaFiduciaria
			AND cod_clase_bien = @strClaseBien
			AND num_placa_bien = @strNumPlaca) BEGIN

		INSERT INTO GAR_GARANTIA_REAL
		(
			cod_tipo_garantia,
			cod_clase_garantia,
			cod_tipo_garantia_real,
			cod_partido,
			numero_finca,
			cod_grado,
			cedula_hipotecaria,
			cod_clase_bien,
			num_placa_bien,
			cod_tipo_bien
		)
		VALUES
		(
			@nTipoGarantia,
			@nClaseGarantia,
			@nTipoGarantiaReal,
			@nPartido,
			@strNumFinca,
			@nGrado,
			@nCedulaFiduciaria,
			@strClaseBien,
			@strNumPlaca,
			@nTipoBien
		)
	
		SET @nGarantiaReal = Scope_Identity()
	END
	ELSE BEGIN

		SELECT @nGarantiaReal = cod_garantia_real
		FROM GAR_GARANTIA_REAL
		WHERE cod_clase_garantia = @nClaseGarantia
		AND cod_tipo_garantia_real = @nTipoGarantiaReal
		AND cod_partido = @nPartido
		AND numero_finca = @strNumFinca
		AND cod_grado = @nGrado
		AND cedula_hipotecaria = @nCedulaFiduciaria
		AND cod_clase_bien = @strClaseBien
		AND num_placa_bien = @strNumPlaca		
	END 

	INSERT INTO GAR_GARANTIAS_REALES_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_real,
		cod_tipo_mitigador,
		cod_tipo_documento_legal,
		monto_mitigador,
		cod_inscripcion,
		fecha_presentacion,
		porcentaje_responsabilidad,
		cod_grado_gravamen,
		cod_operacion_especial,
		fecha_constitucion,
		fecha_vencimiento,
		cod_tipo_acreedor,
		cedula_acreedor,
		cod_liquidez,
		cod_tenencia,
		fecha_prescripcion,
		cod_moneda
	)
	VALUES
	(
		@nOperacion,
		@nGarantiaReal,
		@nTipoMitigador,
		@nTipoDocumentoLegal,
		@nMontoMitigador,
		@nInscripcion,
		@dFechaPresentacion,		
		@nPorcentaje,
		@nGradoGravamen,
		@nOperacionEspecial,
		@dFechaConstitucion,
		@dFechaVencimiento,
		@nTipoAcreedor,
		@strCedulaAcreedor,
		@nLiquidez,
		@nTenencia,
		@dFechaPrescripcion,
		@nMoneda
	)

COMMIT TRANSACTION
RETURN 0



