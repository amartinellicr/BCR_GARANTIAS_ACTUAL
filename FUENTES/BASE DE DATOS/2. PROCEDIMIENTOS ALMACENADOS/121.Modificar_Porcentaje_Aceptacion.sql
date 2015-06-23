USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Modificar_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Modificar_Porcentaje_Aceptacion;
GO

CREATE PROCEDURE [dbo].[Modificar_Porcentaje_Aceptacion]
	
	@piCodigo_Porcentaje_Aceptacion INT,
	@piCodigo_Tipo_Garantia			INT,
	@piCodigo_Tipo_Mitigador		INT,	
	@pbIndicador_Sin_Calificacion	BIT, 
	@pdPorcentaje_Aceptacion		DECIMAL (5,2),
	@pdPorcentaje_Cero_Tres			DECIMAL (5,2) = NULL,
	@pdPorcentaje_Cuatro		    DECIMAL (5,2) = NULL,
	@pdPorcentaje_Cinco				DECIMAL (5,2) = NULL,
	@pdPorcentaje_Seis				DECIMAL (5,2) = NULL,
	@psUsuario_Modifico				VARCHAR (30),
	@psRespuesta				VARCHAR(1000) OUTPUT
	
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Modificar_Porcentaje_Aceptacion</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de modificar la información del tipo de Porcentaje de Aceptacion
	</Descripción>
	<Entradas>
		@piCodigo_Porcentaje_Aceptacion			= Consecutivo del registro.		
		@piCodigo_Tipo_Garantia					= Codigo del tipo de garantia, del catálogo tipo de Garantias		
		@piCodigo_Tipo_Mitigador				= Codigo del tipo de mitigador, del catálogo tipo de mitigador de riesgo	
		@pbIndicador_Sin_Calificacion			= Hace referencia a la clasificación del porcentaje  de aceptación a registrar.
												0:  No aplica calificación
												1: Sin Calificación 
		@pdPorcentaje_Aceptacion				= Porcentaje de Aceptacion Calculado
		@pdPorcentaje_Cero_Tres					= Porcentaje de Aceptacion rango de 0 a 3
		@pdPorcentaje_Cuatro					 = Porcentaje de Aceptacion Cuatro
		@pdPorcentaje_Cinco						= Porcentaje de Aceptacion Cinco
		@pdPorcentaje_Seis						= Porcentaje de Aceptacion Seis
		@psUsuario_Modifico						= Usuario que ingresó el registro
	
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>08/12/2014</Fecha>
	<Requerimiento>Req_Porce_Aceptacion, Siebel No. 1-24613011</Requerimiento>
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
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish
		
	DECLARE	@viCantidadRegistros SMALLINT --Contiene la cantidad de registros que poseen el mismo tipo de garantía y el tipo de mitigador
			
	SET	@viCantidadRegistros = (	SELECT	COUNT(Codigo_Porcentaje_Aceptacion) 
									FROM	dbo.CAT_PORCENTAJE_ACEPTACION 
									WHERE	Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia 
										AND Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador
								) 


	IF (@viCantidadRegistros = 0)		
	BEGIN
		BEGIN TRANSACTION TRA_Mod_TPA1 --Inicio
			BEGIN TRY
			
				UPDATE	dbo.CAT_PORCENTAJE_ACEPTACION
				SET		
					Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia,
					Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador,
					Indicador_Sin_Calificacion = @pbIndicador_Sin_Calificacion,
					Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion,
					Porcentaje_Cero_Tres = @pdPorcentaje_Cero_Tres,
					Porcentaje_Cuatro = @pdPorcentaje_Cuatro,
					Porcentaje_Cinco = @pdPorcentaje_Cinco,
					Porcentaje_Seis = @pdPorcentaje_Seis,
					Usuario_Modifico = @psUsuario_Modifico,
					Fecha_Modifico = GETDATE()			
						
				WHERE	Codigo_Porcentaje_Aceptacion = @piCodigo_Porcentaje_Aceptacion

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Mod_TPA1 -- Error

				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Problema al actualizar el registro.</MENSAJE><DETALLE>Se produjo un error al actualizar los datos del tipo de Porcentaje de Aceptación. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 1
			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Mod_TPA1 --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La actualización de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		
		SELECT @psRespuesta

		RETURN 0
	END
	ELSE IF (@viCantidadRegistros = 1)		
	BEGIN 
			
		IF EXISTS (	SELECT	1
					FROM	dbo.CAT_PORCENTAJE_ACEPTACION 
					WHERE	Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia 
						AND Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador
						AND Codigo_Porcentaje_Aceptacion = @piCodigo_Porcentaje_Aceptacion)
		BEGIN

			BEGIN TRANSACTION TRA_Mod_TPA2 --Inicio
				BEGIN TRY
			
					UPDATE	dbo.CAT_PORCENTAJE_ACEPTACION
					SET						
					Indicador_Sin_Calificacion = @pbIndicador_Sin_Calificacion,
					Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion,
					Porcentaje_Cero_Tres = @pdPorcentaje_Cero_Tres,
					Porcentaje_Cuatro = @pdPorcentaje_Cuatro,
					Porcentaje_Cinco = @pdPorcentaje_Cinco,
					Porcentaje_Seis = @pdPorcentaje_Seis,
					Usuario_Modifico = @psUsuario_Modifico,
					Fecha_Modifico = GETDATE()			
						
					WHERE	Codigo_Porcentaje_Aceptacion = @piCodigo_Porcentaje_Aceptacion

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Mod_TPA2 -- Error
					SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
										'<MENSAJE>Problema al actualizar el registro.</MENSAJE><DETALLE>Se produjo un error al actualizar los datos del tipo de Porcentaje de Aceptación. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

					RETURN 2 
				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Mod_TPA2 --Fin
		
			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La actualización de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

			SELECT @psRespuesta

			RETURN 0	
		END
		ELSE
		BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Problema al actualizar el registro, debido a que existe una relacion</MENSAJE><DETALLE>Se produjo un error al actualizar los datos del tipo de Porcentaje de Aceptación. El registro ya existe</DETALLE></RESPUESTA>'

			SELECT @psRespuesta

			RETURN 3	
	
		END
	END
	ELSE
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al actualizar el registro, debido a que existe una relacion</MENSAJE><DETALLE>Se produjo un error al actualizar los datos del tipo de Porcentaje de Aceptación. El registro ya existe</DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 3	
	
	END

END
