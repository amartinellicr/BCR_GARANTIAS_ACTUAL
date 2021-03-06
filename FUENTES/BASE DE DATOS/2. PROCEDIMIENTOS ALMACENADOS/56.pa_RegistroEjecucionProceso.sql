SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_RegistroEjecucionProceso', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_RegistroEjecucionProceso;
GO

CREATE PROCEDURE [dbo].[pa_RegistroEjecucionProceso](
	@tcocProceso VARCHAR(20),
	@tfecEjecucion DATETIME,
	@tdesObservacion VARCHAR(4000),
	@tindError BIT)
AS

/******************************************************************
	<Nombre>pa_RegistroEjecucionProceso</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Permite registrar la información sobre la ejecución del proceso de generación de archivos automáticos.
	</Descripción>
	<Entradas>
			@tcocProceso		= Identificación del proceso ejecutado.

			@tfecEjecucion		= Fecha y hora en que se ejecuta la generación de un archivo determinado.

			@tdesObservacion	= Mensaje de éxito o de error generado durante la creación del archivo.

			@tindError			= Indicador que determina si se produjo un error (1) o no (0).
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
	<Fecha>17/11/2010</Fecha>
	<Requerimiento>N/A</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Estado de la generación de archivos, Siebel No. 1-23119681</Requerimiento>
			<Fecha>06/05/2013</Fecha>
			<Descripción>
				Se modifica el tamaño del parámetro de entrada "@tdesObservacion", pasando de 254 a 4000, 
				 esto con el fin de poder registrar el mensaje de error que se dió al generar un archivo 
                 específico.
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

DECLARE
	@lconEjecucionProceso INT,
	@lconEjecucionProcesoDetalle SMALLINT
BEGIN
	SELECT @lconEjecucionProceso = 
		conEjecucionProceso
	FROM GAR_EJECUCION_PROCESO
	WHERE cocProceso = @tcocProceso
	AND fecEjecucion = @tfecEjecucion 

	IF @lconEjecucionProceso IS NULL
	BEGIN
		INSERT INTO GAR_EJECUCION_PROCESO(
			cocProceso, fecEjecucion)
		VALUES(
			@tcocProceso, @tfecEjecucion)

		SET @lconEjecucionProceso = @@IDENTITY
	END

	SELECT @lconEjecucionProcesoDetalle = 
		ISNULL(MAX(conEjecucionProcesoDetalle), 0) + 1
	FROM GAR_EJECUCION_PROCESO_DETALLE
	WHERE conEjecucionProceso = @lconEjecucionProceso

	INSERT INTO GAR_EJECUCION_PROCESO_DETALLE(
		conEjecucionProceso, 
		conEjecucionProcesoDetalle,
		desObservacion,
		indError)
	VALUES(
		@lconEjecucionProceso, 
		@lconEjecucionProcesoDetalle,
		@tdesObservacion,
		@tindError)
	
	
END --pa_RegistroEjecucionProceso


