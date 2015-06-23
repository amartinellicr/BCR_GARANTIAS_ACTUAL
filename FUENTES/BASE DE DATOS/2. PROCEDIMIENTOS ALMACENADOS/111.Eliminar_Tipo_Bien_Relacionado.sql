USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Eliminar_Tipo_Bien_Relacionado', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Eliminar_Tipo_Bien_Relacionado;
GO

CREATE PROCEDURE [dbo].[Eliminar_Tipo_Bien_Relacionado]
	@piConsecutivo_Relacion			INT,
	@psRespuesta					VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Tipo_Bien_Relacionado</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de eliminar la informaci�n de la relaci�n existente entre tipos de bien, tipos de p�lizas SUGEF y
		tipo de p�lizas SAP. 
	</Descripci�n>
	<Entradas>
		@piConsecutivo_Relacion			= Consecutivo del registr a ser actualizado.
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
	
	DECLARE	@viTipo_Bien INT,
			@viTipo_Poliza_SAP INT
	
	SELECT	@viTipo_Bien = ISNULL(Codigo_Tipo_Bien, 0), @viTipo_Poliza_SAP = ISNULL(Codigo_Tipo_Poliza_Sap, 0)
	FROM	dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN
	WHERE	Consecutivo_Relacion = @piConsecutivo_Relacion
	
	
	IF(EXISTS (	SELECT	1
				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					INNER JOIN 	dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GPR.cod_garantia_real
					INNER JOIN dbo.GAR_POLIZAS GPO
					ON GPO.Codigo_SAP = GPR.Codigo_SAP			
				WHERE	GGR.cod_tipo_bien = @viTipo_Bien
					AND GPO.Tipo_Poliza = @viTipo_Poliza_SAP))
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Problema al eliminar el registro.</MENSAJE><DETALLE>El registro no puede ser eliminado debido a que permite mantener asociadas p�lizas a garant�as.</DETALLE></RESPUESTA>'

		RETURN 1
	END
	ELSE
	BEGIN
	
		BEGIN TRANSACTION TRA_Eli_Rel_Tipol_Tipobien --Inicio
			BEGIN TRY
			
				DELETE	FROM dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN 
				WHERE	Consecutivo_Relacion = @piConsecutivo_Relacion
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0) 
					ROLLBACK TRANSACTION TRA_Eli_Rel_Tipol_Tipobien -- Error
					
				SET @psRespuesta = N'<RESPUESTA><CODIGO>2</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Problema al eliminar el registro.</MENSAJE><DETALLE>Se produjo un error al eliminar los datos de la relaci�n entre los tipos de p�liza y el tipo de bien. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

				RETURN 2
			END CATCH
				
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Rel_Tipol_Tipobien --Fin

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Tipo_Bien_Relacionado</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La eliminaci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
	END
	
	SELECT @psRespuesta

	RETURN 0
END