USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaReal]
	--Garantia real
	@pbConsecutivo_Garantia_Real BIGINT,
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
	@psCedula_Usuario VARCHAR(30),
	@pdPorcentaje_Aceptacion DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
AS
BEGIN
/******************************************************************
	<Nombre>pa_ModificarGarantiaReal</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
			Modifica la información de una garantía real específica, relacionada a una operación o contrato específico.
	</Descripción>
	<Entradas>
		@pbConsecutivo_Garantia_Real = Consecutivo de la garantía real.
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
		@psCedula_Usuario = Identificación del usuario que realiza la modificación.
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

	BEGIN TRANSACTION Mod_Gar_Real
		BEGIN TRY
			UPDATE	GAR_GARANTIA_REAL
			SET		cod_tipo_garantia_real = @piTipo_Garantia_Real,
					cod_partido = @piPartido,
					numero_finca = @psNumero_Finca,
       				cod_grado = @piGrado,
       				cedula_hipotecaria = @piCedula_Hipotecaria,
       				cod_clase_bien = @psClase_Bien,
       				num_placa_bien = @psNumero_Placa,
       				cod_tipo_bien = @piTipo_Bien,
					Usuario_Modifico = @psCedula_Usuario,
					Fecha_Modifico = GETDATE()
			WHERE	cod_garantia_real = @pbConsecutivo_Garantia_Real

			UPDATE  GAR_GARANTIAS_REALES_X_OPERACION
			SET 	cod_tipo_mitigador = @piTipo_Mitigador,
					cod_tipo_documento_legal = @piTipo_Documento_Legal,
					monto_mitigador = @pdMonto_Mitigador,
					cod_inscripcion = @piInscripcion,
					fecha_presentacion = @pdtFecha_Presentacion,
					porcentaje_responsabilidad = @pdPorcentaje_Responsabilidad,
					cod_grado_gravamen = @piGrado_Gravamen,
					cod_operacion_especial = @piOperacion_Especial,
					fecha_constitucion = @pdtFecha_Constitucion,
					fecha_vencimiento = @pdtFecha_Vencimiento,
					cod_tipo_acreedor = @piTipo_Acreedor,
					cedula_acreedor = @psCedula_Acreedor,
					cod_liquidez = @piLiquidez,
					cod_tenencia = @piTenencia,
					fecha_prescripcion = @pdtFecha_Prescripcion,
					cod_moneda = @piMoneda,
					Usuario_Modifico = @psCedula_Usuario,
					Fecha_Modifico = GETDATE(),
					Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			WHERE	cod_operacion = @pbConsecutivo_Operacion
				AND cod_garantia_real = @pbConsecutivo_Garantia_Real	
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION Mod_Gar_Real

			SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

		END CATCH	

IF (@@TRANCOUNT > 0)
	COMMIT TRANSACTION Mod_Gar_Real
RETURN 0
END