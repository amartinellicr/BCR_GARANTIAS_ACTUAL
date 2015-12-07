USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID ('pa_ModificarGarantiaFiduciariaTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaFiduciariaTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaFiduciariaTarjeta]
	--Garantia fiduciaria
	@piGarantia_Fiduciaria	BIGINT,
	@piTarjeta				INT,
	@psCedula_Fiador		VARCHAR(25),
	@psNombre_Fiador		VARCHAR(100),
	@piTipo_Fiador			SMALLINT,
	--Garantia fiduciaria X Operacion
	@piTipo_Mitigador		SMALLINT,
	@piTipo_Documento_Legal SMALLINT,
	@pdMonto_Mitigador		DECIMAL(18,2),
	@pdPorcentaje_Responsabilidad DECIMAL(5,2),
	@piOperacion_Especial	SMALLINT,
	@piTipo_Acreedor		SMALLINT,
	@psCedula_Acreedor		VARCHAR(30),
	@pdtFecha_Expiracion	DATETIME,
	@pmMonto_Cobertura		MONEY,
	@psObservacion			VARCHAR(150)
AS

/******************************************************************
<Nombre>pa_ModificarGarantiaFiduciariaTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>
		Este procedimiento almacenado permite modificar la información de una garantía fiduciaria 
        para una tarjeta específica.
</Descripción>
<Entradas>
	@piGarantia_Fiduciaria	= Código de la garantía fiduciaria
	@piTarjeta				= Consecutivo interno de la tarjeta
	@psCedula_Fiador		= Cédula del fiador
	@psNombre_Fiador		= Nombre del fiador
	@piTipo_Fiador			= Código de tipo de persona del fiador
	@piTipo_Mitigador		= Código de tipo mitigador riesgo
	@piTipo_Documento_Legal	= Código de tipo de documento legal
	@pdMonto_Mitigador		= Monto mitigador
	@pdPorcentaje_Responsabilidad = Porcentaje de responsabilidad
	@piOperacion_Especial	= Código de operación especial
	@piTipo_Acreedor		= Código de persona del acreedor
	@psCedula_Acreedor		= Cédula del acreedor
	@pdtFecha_Expiracion	= Fecha en que expira la tarjeta.
	@pmMonto_Cobertura		= Monto que cubre el fiador.
	@psObservacion			= Cadena que almacena cualquier observación que el usuario registre.
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>04/12/2015</Fecha>
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

	UPDATE	TAR_GARANTIA_FIDUCIARIA
	SET		cod_tipo_fiador = @piTipo_Fiador
	WHERE	cedula_fiador = @psCedula_Fiador
	

	UPDATE  TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA
	SET		cod_tipo_mitigador = @piTipo_Mitigador,
			cod_tipo_documento_legal = @piTipo_Documento_Legal,
			monto_mitigador = @pdMonto_Mitigador,
			porcentaje_responsabilidad = @pdPorcentaje_Responsabilidad,
			cod_operacion_especial = @piOperacion_Especial,
			cod_tipo_acreedor = @piTipo_Acreedor,
			cedula_acreedor = @psCedula_Acreedor,
			fecha_expiracion = @pdtFecha_Expiracion,
			monto_cobertura = @pmMonto_Cobertura,
			des_observacion = @psObservacion
	WHERE	cod_tarjeta = @piTarjeta
		AND cod_garantia_fiduciaria = @piGarantia_Fiduciaria

COMMIT TRANSACTION
RETURN 0


