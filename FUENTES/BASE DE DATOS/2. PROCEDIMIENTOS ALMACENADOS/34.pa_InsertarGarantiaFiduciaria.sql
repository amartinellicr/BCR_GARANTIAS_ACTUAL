USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarGarantiaFiduciaria', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarGarantiaFiduciaria;
GO

CREATE PROCEDURE [dbo].[pa_InsertarGarantiaFiduciaria]
	--Garantia fiduciaria
	@piTipo_Garantia SMALLINT,
	@piClase_Garantia SMALLINT,
	@psCedula_Fiador VARCHAR(25),
	@psNombre_Fiador VARCHAR(100),
	@piTipo_Fiador SMALLINT,
	--Garantia fiduciaria X Operacion
	@pbConsecutivo_Operacion BIGINT,
	@piTipo_Mitigador SMALLINT,
	@piTipo_Documento_Legal SMALLINT,
	@pdMonto_Mitigador DECIMAL(18,2),
	@pdPorcentaje_Responsabilidad DECIMAL(5,2),
	@piOperacion_Especial SMALLINT,
	@piTipo_Acreedor SMALLINT,
	@psCedula_Acreedor VARCHAR(30),
	@pdPorcentaje_Aceptacion DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
AS
BEGIN
/******************************************************************
	<Nombre>pa_InsertarGarantiaReal</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
			Inserta la información de una garantía fiduciaria específica, relacionada a una operación o contrato específico.
	</Descripción>
	<Entradas>
		@piTipo_Garantia  = Código del tipo de garantía.
		@piClase_Garantia = Código de la clase de garantía.
		@psCedula_Fiador = Identificación del fiador.
		@psNombre_Fiador = Nombre del fiador.
		@piTipo_Fiador = Código del tip ode persona dle fiador.
		@pbConsecutivo_Operacion = Consecutivo de la operación o contrato.
		@piTipo_Mitigador = Código del tipo de mitigador de riesgo.
		@piTipo_Documento_Legal = Código del tipo de documento legal.
		@pdMonto_Mitigador = Monto mitigador de la garantía.
		@pdPorcentaje_Responsabilidad = Poorcentaje de responsabilidad de la garantía.
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

	DECLARE @vbConsecutivo_Garantia_Fiduciaria BIGINT

	BEGIN TRANSACTION Ins_Gar_Fidu

		BEGIN TRY
			IF NOT EXISTS (	SELECT	1
							FROM	dbo.GAR_GARANTIA_FIDUCIARIA
							WHERE	cedula_fiador = @psCedula_Fiador) BEGIN

				INSERT INTO dbo.GAR_GARANTIA_FIDUCIARIA
				(
					cod_tipo_garantia,
					cod_clase_garantia,
					cedula_fiador,
					nombre_fiador,
					cod_tipo_fiador,
					Fecha_Inserto
				)
				VALUES
				(
					@piTipo_Garantia,
					@piClase_Garantia,
					@psCedula_Fiador,
					@psNombre_Fiador,
					@piTipo_Fiador,
					GETDATE()
				)
	
				SET @vbConsecutivo_Garantia_Fiduciaria = Scope_Identity()
			END
			ELSE BEGIN

				SELECT	@vbConsecutivo_Garantia_Fiduciaria = cod_garantia_fiduciaria
				FROM	dbo.GAR_GARANTIA_FIDUCIARIA
				WHERE	cedula_fiador = @psCedula_Fiador		

			END 

			INSERT INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
			(
				cod_operacion, 
				cod_garantia_fiduciaria,
				cod_tipo_mitigador,
				cod_tipo_documento_legal,
				monto_mitigador,
				porcentaje_responsabilidad,
				cod_operacion_especial,
				cod_tipo_acreedor,
				cedula_acreedor,
				Fecha_Inserto,
				Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			)
			VALUES
			(
				@pbConsecutivo_Operacion,
				@vbConsecutivo_Garantia_Fiduciaria,
				@piTipo_Mitigador,
				@piTipo_Documento_Legal,
				@pdMonto_Mitigador,
				@pdPorcentaje_Responsabilidad,
				@piOperacion_Especial,
				@piTipo_Acreedor,
				@psCedula_Acreedor,
				GETDATE(),
				@pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			)

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION Ins_Gar_Fidu

		SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

	END CATCH	

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION Ins_Gar_Fidu

RETURN 0
END