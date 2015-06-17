USE GARANTIAS
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.Eliminar_Datos_Estructuras_SICC', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Eliminar_Datos_Estructuras_SICC;
GO

CREATE PROCEDURE [dbo].[Eliminar_Datos_Estructuras_SICC]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)
	
AS
/*****************************************************************************************************************************************************
	<Nombre>Eliminar_Datos_Estructuras_SICC</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que elimina el contenido de las estructuras locales del SICC.
	</Descripci�n>
	<Entradas>
			@piIndicadorProceso		= Indica el tipo del proceso que requiere eliminar los datos, donde:
										1 : Proceso de r�plica que migra la informaci�n del SICC.
										2 : Proceso de r�plica que actualiza la informcaic�n desde el SICC.
			
			@psCodigoProceso		= C�digo del proceso que ejecuta este procedimiento almacenado.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>13/02/2014</Fecha>
	<Requerimiento>
			Req Bcr Garantias Migraci�n, Siebel No.1-24015441
	</Requerimiento>
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
BEGIN

	DECLARE @vsMensajeError	NVARCHAR(4000),
			@viNumeroError	INT,
			@tcocProceso	VARCHAR(20),
			@tfecEjecucion	DATETIME,
			@tdesObservacion VARCHAR(4000),
			@tindError		BIT,
			@psResultado	CHAR(1)
			
	SET @psResultado = '0'
	SET @tfecEjecucion = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	BEGIN TRY

		BEGIN TRAN BSMCL
		
			DELETE	FROM dbo.GAR_SICC_BSMCL 
			WHERE	@piIndicadorProceso = 2
			
		COMMIT TRAN BSMCL
		
	END TRY
	BEGIN CATCH

		ROLLBACK TRAN BSMCL
		SELECT 
			@vsMensajeError = ERROR_MESSAGE(),
			@viNumeroError = ERROR_NUMBER()

		SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_BSMCL. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
		SET @tcocProceso = @psCodigoProceso
		SET @tindError = 1
		SET @psResultado = '1'
		
		EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

	END CATCH

BEGIN TRY

	BEGIN TRAN BSMPC
	
		DELETE FROM  dbo.GAR_SICC_BSMPC
		WHERE	@piIndicadorProceso = 2
		
	COMMIT TRAN BSMPC
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN BSMPC
	
    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_BSMPC. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRHCS
	
		DELETE FROM  dbo.GAR_SICC_PRHCS
		WHERE	@piIndicadorProceso = 2
		
	COMMIT TRAN PRHCS
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRHCS
	
    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRHCS. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRMCA
	
		DELETE FROM  dbo.GAR_SICC_PRMCA
		WHERE	@piIndicadorProceso IN (1, 2)
		
	COMMIT TRAN PRMCA
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRMCA
	
    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRMCA. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRMGT
	
		DELETE FROM  dbo.GAR_SICC_PRMGT
		WHERE	@piIndicadorProceso IN (1, 2)
		
	COMMIT TRAN PRMGT
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRMGT

    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRMGT. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRMOC
	
		DELETE FROM  dbo.GAR_SICC_PRMOC
		WHERE	@piIndicadorProceso IN (1, 2)
		
	COMMIT TRAN PRMOC
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRMOC

    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRMOC. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRMSC
	
		DELETE FROM  dbo.GAR_SICC_PRMSC
		WHERE	@piIndicadorProceso = 2
		
	COMMIT TRAN PRMSC
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRMSC

    SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRMSC. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN PRMRI
	
		DELETE FROM  dbo.GAR_SICC_PRMRI
		WHERE	@piIndicadorProceso IN (1, 2)
		
	COMMIT TRAN PRMRI
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN PRMRI

	SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_PRMRI. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

BEGIN TRY

	BEGIN TRAN DAMHT
	
		DELETE FROM  dbo.GAR_SICC_DAMHT
		WHERE	@piIndicadorProceso IN (1, 2)
		
	COMMIT TRAN DAMHT
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN DAMHT

	SELECT 
        @vsMensajeError = ERROR_MESSAGE(),
        @viNumeroError = ERROR_NUMBER()

	SET @tdesObservacion = 'Se ha presentado un error al momento de eliminar la informaci�n de la tabla GAR_SICC_DAMHT. C�digo del error: ' + CAST(@viNumeroError AS VARCHAR(1000)) + '. Detalle T�cnico: ' + CAST(@vsMensajeError AS VARCHAR(4000))
	SET @tcocProceso = @psCodigoProceso
	SET @tindError = 1
	SET @psResultado = '1'
	
	EXEC dbo.pa_RegistroEjecucionProceso @tcocProceso, @tfecEjecucion, @tdesObservacion, @tindError

END CATCH

SELECT @psResultado AS codigoFallo

END