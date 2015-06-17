SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaReal]
	--Garantia real
	@nGarantiaReal bigint,
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
<Nombre>pa_ModificarGarantiaReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite modificar la información de una garantía 
             real (hipoteca, cédula hipotecaria, prenda).
</Descripción>
<Entradas>
	@nGarantiaReal			= Código de la garantía real
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

BEGIN TRANSACTION	

	UPDATE 
		GAR_GARANTIA_REAL
	SET 
		cod_tipo_garantia_real = @nTipoGarantiaReal,
		cod_partido = @nPartido,
                     	numero_finca = @strNumFinca,
	       	cod_grado = @nGrado,
	       	cedula_hipotecaria = @nCedulaFiduciaria,
	       	cod_clase_bien = @strClaseBien,
	       	num_placa_bien = @strNumPlaca,
	       	cod_tipo_bien = @nTipoBien
	WHERE
		cod_garantia_real = @nGarantiaReal
		
	

	UPDATE 
		GAR_GARANTIAS_REALES_X_OPERACION
	SET
		cod_tipo_mitigador = @nTipoMitigador,
		cod_tipo_documento_legal = @nTipoDocumentoLegal,
		monto_mitigador = @nMontoMitigador,
		cod_inscripcion = @nInscripcion,
		fecha_presentacion = @dFechaPresentacion,
		porcentaje_responsabilidad = @nPorcentaje,
		cod_grado_gravamen = @nGradoGravamen,
		cod_operacion_especial = @nOperacionEspecial,
		fecha_constitucion = @dFechaConstitucion,
		fecha_vencimiento = @dFechaVencimiento,
		cod_tipo_acreedor = @nTipoAcreedor,
		cedula_acreedor = @strCedulaAcreedor,
		cod_liquidez = @nLiquidez,
		cod_tenencia = @nTenencia,
		fecha_prescripcion = @dFechaPrescripcion,
		cod_moneda = @nMoneda
	WHERE
		cod_operacion = @nOperacion
		AND cod_garantia_real = @nGarantiaReal	
	
COMMIT TRANSACTION
RETURN 0


