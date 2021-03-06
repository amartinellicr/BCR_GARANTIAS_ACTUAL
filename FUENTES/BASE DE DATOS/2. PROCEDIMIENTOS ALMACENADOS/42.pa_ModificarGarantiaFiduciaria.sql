USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaFiduciaria', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaFiduciaria;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaFiduciaria]
	--Garantia fiduciaria
	@piConsecutivo_Garantia_Fiduciaria BIGINT,
	@piConsecutivo_Operacion BIGINT,
	@psCedula_Fiador VARCHAR(25),
	@piTipo_Fiador SMALLINT,
	--Garantia fiduciaria X Operacion
	@piTipo_Mitigador SMALLINT,
	@piTipo_Documento_Legal SMALLINT,
	@pdMonto_Mitigador DECIMAL(18,2),
	@pdPorcentaje_Responsabilidad DECIMAL(5,2),
	@piOperacion_Especial SMALLINT,
	@piTipo_Acreedor SMALLINT,
	@psCedula_Acreedor VARCHAR(30),
	@pdPorcentaje_Aceptacion DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	--Bitacora
	@psUsuario_Modifica VARCHAR(30)
AS
/******************************************************************
	<Nombre>pa_ModificarGarantiaFiduciaria</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que modifica la información referente a las garantías fiduciarias relacionadas a las operaciones o contratos.
	</Descripción>
	<Entradas>
		@piConsecutivo_Garantia_Fiduciaria = Consecutivo de la garantía fiduciaria
		@piConsecutivo_Operacion	= Conseutivo del contrato, del cual se obtendrán las garantías fiduciarias asociadas. 
		@psCedula_Fiador = Identificación del fiador.
		@piTipo_Fiador = Tipo de identificación del fiador.
		@piTipo_Mitigador	= Código del tipo de mitigador de riesgo.
		@piTipo_Documento_Legal = Código del tipo de documento legal.
		@pdMonto_Mitigador = Monto mitigador.
		@pdPorcentaje_Responsabilidad = Porcentaje de responsabilidad.
		@piOperacion_Especial = Código de la operación especial.
		@piTipo_Acreedor = Códigodel tipo de persona del acreedor.
		@psCedula_Acreedor = Identificación del acreedor.
		@pdPorcentaje_Aceptacion = Porcentaje de aceptación de la garantía.
		@psUsuario_Modifica = Identificación del usuario que realiza el ajuste de los datos.
	</Entradas>
	<Salidas>
		En caso de que la inserción se lleve acabo de forma correcta se retorna el valor 0 (cero), caso contrario se retorna el código de error 
		y la descripción del mismo. 
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>N/A</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.1</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>02/12/2015</Fecha>
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

BEGIN
	SET NOCOUNT ON
	SET DATEFORMAT dmy

	BEGIN TRANSACTION Mod_Gar_Fidu

		BEGIN TRY

			UPDATE	dbo.GAR_GARANTIA_FIDUCIARIA
			SET		cod_tipo_fiador = @piTipo_Fiador,
					Usuario_Modifico = @psUsuario_Modifica,
					Fecha_Modifico = GETDATE()
			WHERE	cedula_fiador = @psCedula_Fiador
	

			UPDATE  dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
			SET		cod_tipo_mitigador = @piTipo_Mitigador,
					cod_tipo_documento_legal = @piTipo_Documento_Legal,
					monto_mitigador = @pdMonto_Mitigador,
					porcentaje_responsabilidad = @pdPorcentaje_Responsabilidad,
					cod_operacion_especial = @piOperacion_Especial,
					cod_tipo_acreedor = @piTipo_Acreedor,
					cedula_acreedor = @psCedula_Acreedor,
					Usuario_Modifico = @psUsuario_Modifica,
					Fecha_Modifico = GETDATE(),
					Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			WHERE	cod_operacion = @piConsecutivo_Operacion
				AND cod_garantia_fiduciaria = @piConsecutivo_Garantia_Fiduciaria

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION Mod_Gar_Fidu

		SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

	END CATCH	

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION Mod_Gar_Fidu
	RETURN 0
END