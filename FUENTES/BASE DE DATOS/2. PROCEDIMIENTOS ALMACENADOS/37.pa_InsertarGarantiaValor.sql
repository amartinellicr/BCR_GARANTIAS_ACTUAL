USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaValor;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaValor]
	--Garantia valor
	@piTipo_Garantia SMALLINT,
	@piClase_Garantia SMALLINT,
	@psNumero_Seguridad VARCHAR(30),
	@pdtFecha_Constitucion DATETIME = NULL,
	@pdtFecha_Vencimiento DATETIME = NULL,
	@piClasificacion SMALLINT = NULL,
	@psInstrumento VARCHAR(25) = NULL,
	@psSerie VARCHAR(25) = NULL,
	@piTipo_Emisor SMALLINT = NULL,
	@psCedula_Emisor VARCHAR(30) = NULL,
	@pdPremio DECIMAL(5,2) = NULL,
	@psISIN VARCHAR(25) = NULL,
	@pdValor_Facial DECIMAL(18,2) = NULL,
	@piMoneda_Valor_Facial SMALLINT = NULL,
	@pdValor_Mercado DECIMAL(18,2) = NULL,
	@pdMoneda_Valor_Mercado SMALLINT = NULL,
	@piTenencia SMALLINT = NULL,
	@pdtFecha_Prescripcion DATETIME = NULL,
	--Garantia valor X Operacion
	@pbConsecutivo_Operacion BIGINT,
	@piTipo_Mitigador SMALLINT = NULL,
	@piTipo_Documento_Legal SMALLINT = NULL,
	@pdMonto_Mitigador DECIMAL(18,2) = NULL,
	@piInscripcion SMALLINT = NULL,
	--@dFechaPresentacion datetime = NULL,
	@pdPorcentaje_Responsabilidad DECIMAL(5,2) = -1,
	@piGrado_Gravamen SMALLINT = NULL,
	@piGrado_Prioridades SMALLINT = NULL,
	@pdMonto_Prioridades DECIMAL(18,2) = NULL,
	@piOperacion_Especial SMALLINT = NULL,
	@piTipo_Acreedor SMALLINT = NULL,
	@psCedula_Acreedor VARCHAR(30) = NULL,
	@pdPorcentaje_Aceptacion DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
AS
BEGIN
/******************************************************************
	<Nombre>pa_InsertarGarantiaValor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
			Inserta la información de una garantía de valor específica, relacionada a una operación o contrato específico.
	</Descripción>
	<Entradas>
		@piTipo_Garantia  = Código del tipo de garantía.
		@piClase_Garantia = Código de la clase de garantía.
		@psNumero_Seguridad = Identificación del bien.
		@pdtFecha_Constitucion = Fecha de constitución de la garantía.
		@pdtFecha_Vencimiento = Fecha de vencimiento de la garantía.
		@piClasificacion = Código de clasificación del instrumento.
		@psInstrumento = Código del instrumento.
		@psSerie = Número de serie del instrumento.
		@piTipo_Emisor = Tipo de persona del emisor del instrumento.
		@psCedula_Emisor = Identificación del instrumento.
		@pdPremio = Porcentaje del premio que posee el instrumento.
		@psISIN = Código ISIN.
		@pdValor_Facial = Valor facial del bien.
		@piMoneda_Valor_Facial = Moneda del valor facial del bien.
		@pdValor_Mercado = Valor mercado del bien.
		@pdMoneda_Valor_Mercado = Moneda del valor mercado del bien.
		@piTenencia = Código de tenencia.
		@pdtFecha_Prescripcion = FEcha de prescripción de la garantía.
		@pbConsecutivo_Operacion = Consecutivo de la operación o contrato.
		@piTipo_Mitigador = Código del tipo de mitigador de riesgo.
		@piTipo_Documento_Legal = Código del tipo de documento legal.
		@pdMonto_Mitigador = Monto mitigador de la garantía.
		@piInscripcion = Código del indicador de inscripción.
		@pdPorcentaje_Responsabilidad = Poorcentaje de responsabilidad de la garantía.
		@piGrado_Gravamen = Código del grado gravamen.
		@piGrado_Prioridades = Código del grado de prioridad.
		@pdMonto_Prioridades = Monto de la prioridad.
		@piOperacion_Especial = Código de la operación especial.
		@piTipo_Acreedor = Código del tipo de persona del acreedor de la garantía.
		@psCedula_Acreedor = Identificación del acreedor de la garantía.
		@pdPorcentaje_Aceptacion = Porcentaje de aceptación de la garantía.

	</Entradas>
	<Salidas>
		En caso de que la inserción se lleve acabo de forma correcta se retorna el valor 0 (cero), caso contrario se retorna el código de error 
		y la descripción del mismo. 
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.1</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>09/12/2015</Fecha>
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

	DECLARE @vbConsecutivo_Garantia_Valor BIGINT

	BEGIN TRANSACTION Ins_Gar_Valor	

		BEGIN TRY

			IF NOT EXISTS (	SELECT	1
							FROM	dbo.GAR_GARANTIA_VALOR
							WHERE	cod_clase_garantia = @piClase_Garantia
							AND		numero_seguridad = @psNumero_Seguridad) 
			BEGIN

				INSERT INTO dbo.GAR_GARANTIA_VALOR
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
					fecha_prescripcion,
					Fecha_Inserto
				)
				VALUES
				(
					@piTipo_Garantia,
					@piClase_Garantia,
					@psNumero_Seguridad,
					@pdtFecha_Constitucion,
					@pdtFecha_Vencimiento,
					@piClasificacion,
					@psInstrumento,
					@psSerie,
					@piTipo_Emisor,
					@psCedula_Emisor,
					@pdPremio,
					@psISIN,
					@pdValor_Facial,
					@piMoneda_Valor_Facial,
					@pdValor_Mercado,
					@pdMoneda_Valor_Mercado,
					@piTenencia,
					@pdtFecha_Prescripcion,
					GETDATE()
				)
	
				SET @vbConsecutivo_Garantia_Valor = Scope_Identity()
			END
			ELSE 
			BEGIN

				SELECT	@vbConsecutivo_Garantia_Valor = cod_garantia_valor
				FROM	dbo.GAR_GARANTIA_VALOR
				WHERE	cod_clase_garantia = @piClase_Garantia
					AND numero_seguridad = @psNumero_Seguridad
			END 

			INSERT INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
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
				cedula_acreedor,
				Fecha_Inserto,
				Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			)
			VALUES
			(
				@pbConsecutivo_Operacion,
				@vbConsecutivo_Garantia_Valor,
				@piTipo_Mitigador,
				@piTipo_Documento_Legal,
				@pdMonto_Mitigador,
				@piInscripcion,
				--@dFechaPresentacion,		
				@pdPorcentaje_Responsabilidad,
				@piGrado_Gravamen,
				@piGrado_Prioridades,
				@pdMonto_Prioridades,
				@piOperacion_Especial,
				@piTipo_Acreedor,
				@psCedula_Acreedor,
				GETDATE(),
				@pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			)

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION Ins_Gar_Valor

		SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

	END CATCH	

IF (@@TRANCOUNT > 0)
	COMMIT TRANSACTION Ins_Gar_Valor
RETURN 0
END