USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaReal]
	--Garantia real
	@piTipo_Garantia SMALLINT,
	@piClase_Garantia SMALLINT,
	@piTipo_Garantia_Real SMALLINT,
	@piPartido SMALLINT = NULL,
	@psNumero_Finca VARCHAR(20) = NULL,
	@piGrado SMALLINT = NULL,
	@piCedula_Hipotecaria SMALLINT = NULL,
	@psClase_Bien VARCHAR(3) = NULL,
	@psNumero_Placa VARCHAR(12) = NULL,
	@piTipo_Bien SMALLINT = NULL,
	--Garantia real X Operacion
	@pbConsecutivo_Operacion BIGINT,
	@piTipo_Mitigador SMALLINT = NULL,
	@piTipo_Documento_Legal SMALLINT = NULL,
	@pdMonto_Mitigador DECIMAL(18,2),
	@piInscripcion SMALLINT = NULL,
	@pdtFecha_Presentacion DATETIME,
	@pdPorcentaje_Responsabilidad DECIMAL(5,2),
	@piGrado_Gravamen SMALLINT,
	@piOperacion_Especial SMALLINT = NULL,
	@pdtFecha_Constitucion DATETIME,
	@pdtFecha_Vencimiento DATETIME,
	@piTipo_Acreedor SMALLINT = NULL,
	@psCedula_Acreedor VARCHAR(30) = NULL,
	@piLiquidez SMALLINT,
	@piTenencia SMALLINT,
	@pdtFecha_Prescripcion DATETIME,
	@piMoneda SMALLINT,
	@pdPorcentaje_Aceptacion DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
AS
BEGIN
/******************************************************************
	<Nombre>pa_InsertarGarantiaReal</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
			Inserta la información de una garantía real específica, relacionada a una operación o contrato específico.
	</Descripción>
	<Entradas>
		@piTipo_Garantia  = Código del tipo de garantía.
		@piClase_Garantia = Código de la clase de garantía.
		@piTipo_Garantia_Real = Código del tip ode garantía real.
		@piPartido = Código del partido.
		@psNumero_Finca = Número de finca.
		@piGrado = Número de grado de la cédula hipotecaria.
		@piCedula_Hipotecaria = Número de la cédula hipotecaria.
		@psClase_Bien = Código de la clase del bien.
		@psNumero_Placa = Número de identificación del bien.
		@piTipo_Bien = Código del tipo de bien.
		@pbConsecutivo_Operacion = Consecutivo de la operación o contrato.
		@piTipo_Mitigador = Código del tipo de mitigador de riesgo.
		@piTipo_Documento_Legal = Código del tipo de documento legal.
		@pdMonto_Mitigador = Monto mitigador de la garantía.
		@piInscripcion = Código del indicador de inscripción.
		@pdtFecha_Presentacion = Fecha de presentación de la garantía ante el Registro de la Propiedad.
		@pdPorcentaje_Responsabilidad = Poorcentaje de responsabilidad de la garantía.
		@piGrado_Gravamen = Código del grado gravamen.
		@piOperacion_Especial = Código de la operación especial.
		@pdtFecha_Constitucion = Fecha de constitución de la garantía.
		@pdtFecha_Vencimiento = FEcha de vencimiento de la garantía.
		@piTipo_Acreedor = Código del tipo de persona del acreedor de la garantía.
		@psCedula_Acreedor = Identificación del acreedor de la garantía.
		@piLiquidez = Código de liquidez.
		@piTenencia Código de tenencia.
		@pdtFecha_Prescripcion = Fecha de prescripción de la garantía.
		@piMoneda = Código de la moneda de la garantía.
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
			<Fecha>08/12/2015</Fecha>
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

DECLARE @vbConsecutivo_Garantia_Real BIGINT

BEGIN TRANSACTION Ins_Gar_Real

	BEGIN TRY

		IF NOT EXISTS (	SELECT	1
						FROM	dbo.GAR_GARANTIA_REAL
						WHERE	cod_clase_garantia = @piClase_Garantia
							AND cod_tipo_garantia_real = @piTipo_Garantia_Real
							AND cod_partido = @piPartido
							AND numero_finca = @psNumero_Finca
							AND cod_grado = @piGrado
							AND cedula_hipotecaria = @piCedula_Hipotecaria
							AND cod_clase_bien = @psClase_Bien
							AND num_placa_bien = @psNumero_Placa) 
		BEGIN

			INSERT INTO dbo.GAR_GARANTIA_REAL
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
				cod_tipo_bien,
				Fecha_Inserto
			)
			VALUES
			(
				@piTipo_Garantia,
				@piClase_Garantia,
				@piTipo_Garantia_Real,
				@piPartido,
				@psNumero_Finca,
				@piGrado,
				@piCedula_Hipotecaria,
				@psClase_Bien,
				@psNumero_Placa,
				@piTipo_Bien,
				GETDATE()
			)
	
			SET @vbConsecutivo_Garantia_Real = SCOPE_IDENTITY()
		END
		ELSE 
		BEGIN

			SELECT	@vbConsecutivo_Garantia_Real = cod_garantia_real
			FROM	dbo.GAR_GARANTIA_REAL
			WHERE	cod_clase_garantia = @piClase_Garantia
				AND cod_tipo_garantia_real = @piTipo_Garantia_Real
				AND cod_partido = @piPartido
				AND numero_finca = @psNumero_Finca
				AND cod_grado = @piGrado
				AND cedula_hipotecaria = @piCedula_Hipotecaria
				AND cod_clase_bien = @psClase_Bien
				AND num_placa_bien = @psNumero_Placa		
		END 

		INSERT INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
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
			cod_moneda,
			Fecha_Inserto,
			Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		)
		VALUES
		(
			@pbConsecutivo_Operacion,
			@vbConsecutivo_Garantia_Real,
			@piTipo_Mitigador,
			@piTipo_Documento_Legal,
			@pdMonto_Mitigador,
			@piInscripcion,
			@pdtFecha_Presentacion,		
			@pdPorcentaje_Responsabilidad,
			@piGrado_Gravamen,
			@piOperacion_Especial,
			@pdtFecha_Constitucion,
			@pdtFecha_Vencimiento,
			@piTipo_Acreedor,
			@psCedula_Acreedor,
			@piLiquidez,
			@piTenencia,
			@pdtFecha_Prescripcion,
			@piMoneda,
			GETDATE(),
			@pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		)

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION Ins_Gar_Real

		SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

	END CATCH	

IF (@@TRANCOUNT > 0)
	COMMIT TRANSACTION Ins_Gar_Real
RETURN 0
END