USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Insertar_Porcentaje_Aceptacion;
GO

CREATE PROCEDURE [dbo].[Insertar_Porcentaje_Aceptacion]
	
	@piCodigo_Tipo_Garantia			INT,
	@piCodigo_Tipo_Mitigador		INT,	
	@pbIndicador_Sin_Calificacion	BIT, 
	@pdPorcentaje_Aceptacion		DECIMAL (5,2),
	@pdPorcentaje_Cero_Tres			DECIMAL (5,2) = NULL,
	@pdPorcentaje_Cuatro		    DECIMAL (5,2) = NULL,
	@pdPorcentaje_Cinco				DECIMAL (5,2) = NULL,
	@pdPorcentaje_Seis				DECIMAL (5,2) = NULL,
	@psUsuario_Inserto				VARCHAR (30),
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Insertar_Porcentaje_Aceptacion</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de insertar la informaci�n del cat�logo Porcentaje de Aceptacion, para esta primer version
		los campos porcentaje 0-3,4,5 y 6; no se utilizan, mas adelante se van a implementar
	</Descripci�n>
	<Entradas>		
		
		@piCodigo_Tipo_Garantia			= Codigo del tipo de garantia, del cat�logo tipo de Garantias		
		@piCodigo_Tipo_Mitigador		= Codigo del tipo de mitigador, del cat�logo tipo de mitigador de riesgo	
		@pbIndicador_Sin_Calificacion	= Hace referencia a la clasificaci�n del porcentaje  de aceptaci�n a registrar.
											0:  No aplica calificaci�n
											1: Sin Calificaci�n 
		@pdPorcentaje_Aceptacion		= Porcentaje de Aceptacion Calculado
		@pdPorcentaje_Cero_Tres			= Porcentaje de Aceptacion rango de 0 a 3
		@pdPorcentaje_Cuatro		    = Porcentaje de Aceptacion Cuatro
		@pdPorcentaje_Cinco				= Porcentaje de Aceptacion Cinco
		@pdPorcentaje_Seis				= Porcentaje de Aceptacion Seis
		@psUsuario_Inserto				= Usuario que ingres� el registro
		
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Leonarod Cort�s Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>08/12/2014</Fecha>
	<Requerimiento>Req_Porce_Aceptacion, Siebel No. 1-24613011</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish
	
	IF EXISTS (	SELECT	1
				FROM	dbo.CAT_PORCENTAJE_ACEPTACION
				WHERE	Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia 
				AND Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador
			   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>El registro ya existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos del tipo de Porcentaje de Aceptaci�n. El registro ya existe.</DETALLE></RESPUESTA>'

		RETURN 1 		
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Tipo_Por_Aceptacion --Inicio
			BEGIN TRY
		
				INSERT	INTO dbo.CAT_PORCENTAJE_ACEPTACION
				(
				Codigo_Tipo_Garantia,
				Codigo_Tipo_Mitigador,
				Indicador_Sin_Calificacion,
				Porcentaje_Aceptacion,
				Porcentaje_Cero_Tres,
				Porcentaje_Cuatro,
				Porcentaje_Cinco,
				Porcentaje_Seis,
				Usuario_Inserto,
				Fecha_Inserto
				)				
				
				VALUES
				(
				@piCodigo_Tipo_Garantia,
				@piCodigo_Tipo_Mitigador,
				@pbIndicador_Sin_Calificacion,
				@pdPorcentaje_Aceptacion,
				@pdPorcentaje_Cero_Tres,
				@pdPorcentaje_Cuatro,
				@pdPorcentaje_Cinco,
				@pdPorcentaje_Seis,
				@psUsuario_Inserto,
				GETDATE()
				)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Tipo_Por_Aceptacion

				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
								    '<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos del tipo de Porcentaje de Aceptaci�n. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 2

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Tipo_Por_Aceptacion --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Porcentaje_Aceptacion</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La inserci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END