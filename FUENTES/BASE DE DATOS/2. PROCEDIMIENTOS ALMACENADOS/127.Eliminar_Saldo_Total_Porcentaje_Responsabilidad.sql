USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Eliminar_Saldo_Total_Porcentaje_Responsabilidad', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Eliminar_Saldo_Total_Porcentaje_Responsabilidad;
GO

CREATE PROCEDURE [dbo].[Eliminar_Saldo_Total_Porcentaje_Responsabilidad]
	
	@piConsecutivo_Operacion		BIGINT,
	@piConsecutivo_Garantia			BIGINT,
	@piCodigo_Tipo_Garantia			SMALLINT,
	@psCedula_Usuario				VARCHAR (30),
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Saldo_Total_Porcentaje_Responsabilidad</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de eliminar logicamente la información referente a los saldos totales y porcentajes de responsabilidad ajustados
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Operacion		= Consecutivo de la operación, contrato o giro de contrato.
		@piConsecutivo_Garantia			= Consecutivo de la garantía fiduciaria, real o de valor.
		@piCodigo_Tipo_Garantia			= Codigo del tipo de garantia, del catálogo tipo de Garantias.		
		@psCedula_Usuario				= Usuario que eliminó el registro
		
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
	
	DECLARE	@viIndicador_Excluido SMALLINT
	

	SELECT	@viIndicador_Excluido = COALESCE(Indicador_Excluido, -1)
	FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD
	WHERE	Consecutivo_Operacion = @piConsecutivo_Operacion
		AND Consecutivo_Garantia = @piConsecutivo_Garantia
		AND Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia

	SELECT	@viIndicador_Excluido = COALESCE(@viIndicador_Excluido, -1)

	IF (@viIndicador_Excluido = -1)
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>El registro no existe.</MENSAJE><DETALLE>Se produjo un error al modificar los datos del saldo total y porcentaje de responsabilidad. El registro no existe.</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE IF (@viIndicador_Excluido = 0)
	BEGIN
		BEGIN TRANSACTION TRA_Eli_Registro --Inicio
			BEGIN TRY
				
				UPDATE	TPR
				SET		TPR.Saldo_Actual_Ajustado = -1,
						TPR.Porcentaje_Responsabilidad_Ajustado = -1,
						TPR.Porcentaje_Responsabilidad_Calculado = -1,
						TPR.Indicador_Ajuste_Saldo_Actual = 0,
						TPR.Indicador_Ajuste_Porcentaje = 0,
						TPR.Indicador_Excluido = 1,
						TPR.Usuario_Elimino = @psCedula_Usuario,
						TPR.Fecha_Elimino = GETDATE()
				FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
				WHERE	Consecutivo_Operacion = @piConsecutivo_Operacion
					AND Consecutivo_Garantia = @piConsecutivo_Garantia
					AND Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Registro

				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								    '<MENSAJE>Problema al excluir el registro.</MENSAJE><DETALLE>Se produjo un error al excluir el registro Saldo Total y Porcentaje de Responsabilidad. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 2

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Registro --Fin


		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La exclusión del registro ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
			
		SELECT @psRespuesta

		RETURN 0		
	END
END