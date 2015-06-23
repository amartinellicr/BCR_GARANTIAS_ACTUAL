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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de insertar la informaci�n de la relaci�n existente entre tipos de bien, tipos de p�lizas SUGEF y
		tipo de p�lizas SAP. 
	</Descripci�n>
	<Entradas>
		@piCodigo_Tipo_Bien				= C�digo del tipo de bien.
		@piCodigo_Tipo_Poliza_Sap		= C�digo del tipo de p�liza SAP.
		@piCodigo_Tipo_Poliza_Sugef		= C�digo del tipo de p�liza SUGEF.
		@piCatalogo_Tipo_Poliza			= C�digo del cat�logo de los tipos de p�liza SAP.
		@piCatalogo_Tipo_Bien			= C�digo del cat�logo de los tipos de bien.
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/06/2014</Fecha>
	<Requerimiento>Req_P�lizas, Siebel No. 1-24342731</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor>Leonardo Cort�s Mora,Lidersoft Internacional S.A.</Autor>
			<Requerimiento>PNS</Requerimiento>
			<Fecha>01-12-14</Fecha>
			<Descripci�n> Se cambia el mensaje del primer if y se agrega los datos respectivos</Descripci�n>
		</Cambio>
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
								'<MENSAJE>El registro ya existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El registro ya existe.</DETALLE></RESPUESTA>'


		RETURN 1 		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_ELEMENTO
						WHERE	cat_catalogo = @piCatalogo_Tipo_Bien
							AND cat_campo = CONVERT(VARCHAR(5), @piCodigo_Tipo_Bien)
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de bien no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de bien no existe.</DETALLE></RESPUESTA>'

		RETURN 2		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_ELEMENTO
						WHERE	cat_catalogo = @piCatalogo_Tipo_Poliza
							AND cat_campo = CONVERT(VARCHAR(5), @piCodigo_Tipo_Poliza_Sap)
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>3</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de p�liza SAP no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de p�liza SAP no existe.</DETALLE></RESPUESTA>'

		RETURN 3		
	END
	ELSE IF NOT EXISTS (SELECT	1
						FROM	dbo.CAT_TIPOS_POLIZAS_SUGEF
						WHERE	Codigo_Tipo_Poliza_Sugef = @piCodigo_Tipo_Poliza_Sugef
					   )
	BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>4</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de p�liza SUGEF no existe.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El tipo de p�liza SUGEF no existe.</DETALLE></RESPUESTA>'

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
									'<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 5
		END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Rel_Tipol_Tipobien --Fin
		
		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La inserci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		SELECT @psRespuesta

		RETURN 0
	END
END