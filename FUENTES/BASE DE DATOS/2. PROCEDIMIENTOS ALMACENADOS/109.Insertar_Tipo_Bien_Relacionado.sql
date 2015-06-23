USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Tipo_Bien_Relacionado', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Insertar_Tipo_Bien_Relacionado;
GO

CREATE PROCEDURE [dbo].[Insertar_Tipo_Bien_Relacionado]
	@piCodigo_Tipo_Bien				INT,
	@piCodigo_Tipo_Poliza_Sap		INT,
	@piCodigo_Tipo_Poliza_Sugef		INT,
	@piCatalogo_Tipo_Poliza			INT,
	@piCatalogo_Tipo_Bien			INT,
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Insertar_Tipo_Bien_Relacionado</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de insertar la información de la relación existente entre tipos de bien, tipos de pólizas SUGEF y
		tipo de pólizas SAP. 
	</Descripción>
	<Entradas>
		@piCodigo_Tipo_Bien				= Código del tipo de bien.
		@piCodigo_Tipo_Poliza_Sap		= Código del tipo de póliza SAP.
		@piCodigo_Tipo_Poliza_Sugef		= Código del tipo de póliza SUGEF.
		@piCatalogo_Tipo_Poliza			= Código del catálogo de los tipos de póliza SAP.
		@piCatalogo_Tipo_Bien			= Código del catálogo de los tipos de bien.
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/06/2014</Fecha>
	<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Leonardo Cortés Mora,Lidersoft Internacional S.A.</Autor>
			<Requerimiento>PNS</Requerimiento>
			<Fecha>01-12-14</Fecha>
			<Descripción> Se cambia el mensaje del primer if y se agrega los datos respectivos</Descripción>
		</Cambio>
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
	
	DECLARE	@viConsecutivo_Relacion INT

	SET @viConsecutivo_Relacion = (
									SELECT	ISNULL(Consecutivo_Relacion, -1) AS Consecutivo_Relacion
									FROM	dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN
									WHERE	Codigo_Tipo_Poliza_Sugef = @piCodigo_Tipo_Poliza_Sugef
										AND Codigo_Tipo_Poliza_Sap = @piCodigo_Tipo_Poliza_Sap
										AND Codigo_Tipo_Bien = @piCodigo_Tipo_Bien
								 )

	IF (@viConsecutivo_Relacion > -1)
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA>' + CONVERT(VARCHAR(100), @viConsecutivo_Relacion) + '</LINEA>' + 
								'<MENSAJE>El registro ya existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El registro ya existe.</DETALLE></RESPUESTA>'


		RETURN 1 		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_ELEMENTO
						WHERE	cat_catalogo = @piCatalogo_Tipo_Bien
							AND cat_campo = CONVERT(VARCHAR(5), @piCodigo_Tipo_Bien)
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de bien no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de bien no existe.</DETALLE></RESPUESTA>'

		RETURN 2		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_ELEMENTO
						WHERE	cat_catalogo = @piCatalogo_Tipo_Poliza
							AND cat_campo = CONVERT(VARCHAR(5), @piCodigo_Tipo_Poliza_Sap)
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>3</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de póliza SAP no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de póliza SAP no existe.</DETALLE></RESPUESTA>'

		RETURN 3		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_TIPOS_POLIZAS_SUGEF
						WHERE	Codigo_Tipo_Poliza_Sugef = @piCodigo_Tipo_Poliza_Sugef
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>4</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de póliza SUGEF no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El tipo de póliza SUGEF no existe.</DETALLE></RESPUESTA>'

		RETURN 4		
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Rel_Tipol_Tipobien --Inicio
			BEGIN TRY
			
				INSERT	INTO dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN (Codigo_Tipo_Poliza_Sap, Codigo_Tipo_Poliza_Sugef, Codigo_Tipo_Bien)
				VALUES	(@piCodigo_Tipo_Poliza_Sap, @piCodigo_Tipo_Poliza_Sugef, @piCodigo_Tipo_Bien)
		
		END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Rel_Tipol_Tipobien -- Error
					
				SET @psRespuesta = N'<RESPUESTA><CODIGO>5</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relación entre los tipos de póliza y el tipo de bien. El código obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 5
		END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Rel_Tipol_Tipobien --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La inserción de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END