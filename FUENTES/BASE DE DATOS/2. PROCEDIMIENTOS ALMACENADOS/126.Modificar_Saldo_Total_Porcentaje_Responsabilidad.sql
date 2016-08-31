USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Modificar_Saldo_Total_Porcentaje_Responsabilidad', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Modificar_Saldo_Total_Porcentaje_Responsabilidad;
GO

CREATE PROCEDURE [dbo].[Modificar_Saldo_Total_Porcentaje_Responsabilidad]
	
	@piConsecutivo_Operacion		BIGINT,
	@piConsecutivo_Garantia			BIGINT,
	@piCodigo_Tipo_Garantia			SMALLINT,
	@pdSaldo_Actual_Ajustado		DECIMAL(18,2),	
	@pdPorcentaje_Responsabilidad_Ajustado		DECIMAL(5,2),	
	@pdPorcentaje_Responsabilidad_Calculado		DECIMAL(5,2),	
	@psCedula_Usuario				VARCHAR (30),
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Modificar_Saldo_Total_Porcentaje_Responsabilidad</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de modificar la información referente a los saldos totales y porcentajes de responsabilidad ajustados
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Operacion		= Consecutivo de la operación, contrato o giro de contrato.
		@piConsecutivo_Garantia			= Consecutivo de la garantía fiduciaria, real o de valor.
		@piCodigo_Tipo_Garantia			= Codigo del tipo de garantia, del catálogo tipo de Garantias.		
		@pdSaldo_Actual_Ajustado		= Saldo actual ingresado por el usuario para la operación, contrato o giro de contrato.	
		@pdPorcentaje_Responsabilidad_Ajustado	= Porcentaje de responsabilidad ingresado por el usuario para la operación y garantía indicados.
		@pdPorcentaje_Responsabilidad_Calculado = Porcentaje de responsabilidad calculado por el sistema para la operación y garantía indicados.
		@psCedula_Usuario				= Usuario que actualizó el registro
		
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>04/03/2016</Fecha>
	<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish
	
	DECLARE	@vdAjuste_Saldo_Actual	DECIMAL(18,2),
			@vdAjuste_Porcentaje	DECIMAL(5,2),
			@vdAjuste_Porcentaje_Calculado	DECIMAL(5,2),
			@viIndicador_Excluido	SMALLINT
	

	SELECT	@vdAjuste_Saldo_Actual = COALESCE(Saldo_Actual_Ajustado, -1), 
			@vdAjuste_Porcentaje = COALESCE(Porcentaje_Responsabilidad_Ajustado, -1),
			@vdAjuste_Porcentaje_Calculado = COALESCE(Porcentaje_Responsabilidad_Calculado, -1),
			@viIndicador_Excluido = COALESCE(Indicador_Excluido, -1)
	FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD
	WHERE	Consecutivo_Operacion = @piConsecutivo_Operacion
		AND Consecutivo_Garantia = @piConsecutivo_Garantia
		AND Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia


	SELECT	@vdAjuste_Saldo_Actual = COALESCE(@vdAjuste_Saldo_Actual, -1), 
			@vdAjuste_Porcentaje = COALESCE(@vdAjuste_Porcentaje, -1),
			@viIndicador_Excluido = COALESCE(@viIndicador_Excluido, -1)


	IF (@viIndicador_Excluido = -1)
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>El registro no existe.</MENSAJE><DETALLE>Se produjo un error al modificar los datos del saldo total y porcentaje de responsabilidad. El registro no existe.</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE IF (@viIndicador_Excluido = 1)
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>El registro debe ser incluido.</MENSAJE><DETALLE>Se produjo un error al modificar los datos del saldo total y porcentaje de responsabilidad. El registro está excluido.</DETALLE></RESPUESTA>'

		RETURN 2 		
	END
	ELSE IF (@viIndicador_Excluido = 0)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Registro --Inicio
			BEGIN TRY
				
				UPDATE	TPR
				SET		TPR.Saldo_Actual_Ajustado = @pdSaldo_Actual_Ajustado,
						TPR.Porcentaje_Responsabilidad_Ajustado = @pdPorcentaje_Responsabilidad_Ajustado,
						TPR.Porcentaje_Responsabilidad_Calculado = @pdPorcentaje_Responsabilidad_Calculado,
						TPR.Indicador_Ajuste_Saldo_Actual = CASE
																WHEN (@vdAjuste_Saldo_Actual < @pdSaldo_Actual_Ajustado) THEN 1
																WHEN (@vdAjuste_Saldo_Actual > @pdSaldo_Actual_Ajustado) THEN 1
																ELSE 0
															END,
						TPR.Indicador_Ajuste_Porcentaje = CASE
																WHEN (@vdAjuste_Porcentaje < @pdPorcentaje_Responsabilidad_Ajustado) THEN 1
																WHEN (@vdAjuste_Porcentaje > @pdPorcentaje_Responsabilidad_Ajustado) THEN 1
																WHEN (@vdAjuste_Porcentaje_Calculado < @pdPorcentaje_Responsabilidad_Calculado) THEN 1
																WHEN (@vdAjuste_Porcentaje_Calculado > @pdPorcentaje_Responsabilidad_Calculado) THEN 1
																ELSE 0
															END,
						TPR.Indicador_Excluido = 0,
						TPR.Usuario_Modifico = @psCedula_Usuario,
						TPR.Fecha_Modifico = GETDATE()
				FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
				WHERE	Consecutivo_Operacion = @piConsecutivo_Operacion
					AND Consecutivo_Garantia = @piConsecutivo_Garantia
					AND Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Registro

				SET @psRespuesta = N'<RESPUESTA><CODIGO>3</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								    '<MENSAJE>Problema al modificar el registro.</MENSAJE><DETALLE>Se produjo un error al modificar los datos del Saldo Total y Porcentaje de Responsabilidad. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 3

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Registro --Fin

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La modificación de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
			
		SELECT @psRespuesta

		RETURN 0		
	END
END