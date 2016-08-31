USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Normalizar_Datos_Porcentaje_Responsabilidad', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Normalizar_Datos_Porcentaje_Responsabilidad;
GO

CREATE PROCEDURE [dbo].[Normalizar_Datos_Porcentaje_Responsabilidad]
	
	@piConsecutivo_Operacion		BIGINT,
	@piConsecutivo_Garantia			BIGINT,
	@piCodigo_Tipo_Garantia			SMALLINT,
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Normalizar_Datos_Porcentaje_Responsabilidad</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de homologar la información referente al porcentaje de responsabilidad en las relaciones entre la garantía y las operaciones.
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Operacion		= Consecutivo de la operación, contrato o giro de contrato.
		@piConsecutivo_Garantia			= Consecutivo de la garantía fiduciaria, real o de valor.
		@piCodigo_Tipo_Garantia			= Codigo del tipo de garantia, del catálogo tipo de Garantias.		
		
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>08/03/2016</Fecha>
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
	
	DECLARE	@vdtFecha_Actual DATETIME
	

	SET		@vdtFecha_Actual = GETDATE()

	/*Se actualizan todos los registros de la misma garantía fiduciaria que esten relacionadas a la operación indicada*/
	BEGIN TRANSACTION TRA_Act_Relaciones_GF --Inicio
		BEGIN TRY
				
			UPDATE	GFO
			SET		GFO.Indicador_Porcentaje_Responsabilidad_Maximo =	CASE	
																			WHEN GSP.Porcentaje_Responsabilidad_Ajustado = 100 THEN 1
																			ELSE 0
																		END,
					GFO.porcentaje_responsabilidad = GSP.Porcentaje_Responsabilidad_Calculado						
			FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD GSP
				INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
				ON GSP.Consecutivo_Operacion = GFO.cod_operacion
				AND GSP.Consecutivo_Garantia = GFO.cod_garantia_fiduciaria
				AND GSP.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia
				INNER JOIN dbo.Obtener_Operaciones_Comunes_Garantias_Fiduciarias_FT(@piConsecutivo_Operacion, @piConsecutivo_Garantia, @vdtFecha_Actual, 0) FN1
				ON FN1.Consecutivo_Operacion = GFO.cod_operacion
				AND FN1.Consecutivo_Garantia = GFO.cod_garantia_fiduciaria
			WHERE	GFO.cod_operacion = @piConsecutivo_Operacion
				AND GFO.cod_garantia_fiduciaria = @piConsecutivo_Garantia
				AND @piCodigo_Tipo_Garantia = 1

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Relaciones_GF

			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al actualizar el registro.</MENSAJE><DETALLE>Se produjo un error al actualizar las relaciones de la garantía. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

			RETURN 1

		END CATCH
			
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Relaciones_GF --Fin


	/*Se actualizan todos los registros de la misma garantía real que esten relacionadas a la operación indicada*/
	BEGIN TRANSACTION TRA_Act_Relaciones_GR --Inicio
		BEGIN TRY
				
			UPDATE	GRO
			SET		GRO.Indicador_Porcentaje_Responsabilidad_Maximo =	CASE	
																			WHEN GSP.Porcentaje_Responsabilidad_Ajustado = 100 THEN 1
																			ELSE 0
																		END,
					GRO.porcentaje_responsabilidad = GSP.Porcentaje_Responsabilidad_Calculado							
			FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD GSP
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GSP.Consecutivo_Operacion = GRO.cod_operacion
				AND GSP.Consecutivo_Garantia = GRO.cod_garantia_real
				AND GSP.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia				
				INNER JOIN dbo.Obtener_Operaciones_Comunes_Garantias_Reales_FT(@piConsecutivo_Operacion, @piConsecutivo_Garantia, @vdtFecha_Actual, 0) FN1
				ON FN1.Consecutivo_Operacion = GRO.cod_operacion
				AND FN1.Consecutivo_Garantia = GRO.cod_garantia_real
			WHERE	GRO.cod_operacion = @piConsecutivo_Operacion
				AND GRO.cod_garantia_real = @piConsecutivo_Garantia
				AND @piCodigo_Tipo_Garantia = 2

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Relaciones_GR

			SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al actualizar el registro.</MENSAJE><DETALLE>Se produjo un error al actualizar las relaciones de la garantía. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

			RETURN 2

		END CATCH
			
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Relaciones_GR --Fin



	/*Se actualizan todos los registros de la misma garantía valor que esten relacionadas a la operación indicada*/
	BEGIN TRANSACTION TRA_Act_Relaciones_GV --Inicio
		BEGIN TRY
				
			UPDATE	GVO
			SET		GVO.Indicador_Porcentaje_Responsabilidad_Maximo =	CASE	
																			WHEN GSP.Porcentaje_Responsabilidad_Ajustado = 100 THEN 1
																			ELSE 0
																		END,
					GVO.porcentaje_responsabilidad = GSP.Porcentaje_Responsabilidad_Calculado							
			FROM	dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD GSP
				INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
				ON GSP.Consecutivo_Operacion = GVO.cod_operacion
				AND GSP.Consecutivo_Garantia = GVO.cod_garantia_valor
				AND GSP.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia							
				INNER JOIN dbo.Obtener_Operaciones_Comunes_Garantias_Valor_FT(@piConsecutivo_Operacion, @piConsecutivo_Garantia, @vdtFecha_Actual, 0) FN1
				ON FN1.Consecutivo_Operacion = GVO.cod_operacion
				AND FN1.Consecutivo_Garantia = GVO.cod_garantia_valor
			WHERE	GVO.cod_operacion = @piConsecutivo_Operacion
				AND GVO.cod_garantia_valor = @piConsecutivo_Garantia
				AND @piCodigo_Tipo_Garantia = 3

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Relaciones_GV

			SET @psRespuesta = N'<RESPUESTA><CODIGO>3</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al actualizar el registro.</MENSAJE><DETALLE>Se produjo un error al actualizar las relaciones de la garantía. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

			RETURN 3

		END CATCH
			
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Relaciones_GV --Fin


	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Saldo_Total_Porcentaje_Responsabilidad</PROCEDIMIENTO><LINEA></LINEA>' + 
					'<MENSAJE>La actualización de los datos ha sido satisfactoria. Se normalizó cada operación.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
			
	SELECT @psRespuesta

	RETURN 0		
	
END