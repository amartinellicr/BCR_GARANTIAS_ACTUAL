USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('Obtener_Fechas_Semestrales_FT') IS NOT NULL 
    DROP FUNCTION Obtener_Fechas_Semestrales_FT;
GO

CREATE FUNCTION [dbo].[Obtener_Fechas_Semestrales_FT] 
(
	@pdtFecha_Inicial	DATETIME,
	@pdtFecha_Final		DATETIME,
	@piCodigo_Garantia	BIGINT
)
RETURNS @ptbFechas_Semestrales TABLE(
			Numero_Semestre			INT IDENTITY(1,1),
			Fecha_Semestre			DATETIME,
			Codigo_Garantia			BIGINT,
			Tipo_Cambio				DECIMAL(18,2),
			IPC						DECIMAL(18,2),
			Tipo_Cambio_Anterior	DECIMAL(18,2),
			IPC_Anterior			DECIMAL(18,2),
			Tipo_Registro			TINYINT,
			Total_Registros			SMALLINT)
AS
/*****************************************************************************************************************************************************
	<Nombre>Obtener_Fechas_Semestrales_FT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Función que permite obtener la lista de fechas en que se cumple un semestre, entre dos fechas dadas.
	</Descripción>
	<Entradas>
			@pdtFecha_Inicial	= Fecha en que se inicia el conteo semestral.

  			@pdtFecha_Final		= Fecha en que finaliza el conteo semestral.
  			
  			@piCodigo_Garantia	= Consecutivo de la garantía real evaluada.
	</Entradas>
	<Salidas>
			@ptbFechas_Semestrales	= Tabla con las fechas en que se cumplen semestres.
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>10/11/2013</Fecha>
	<Requerimiento>
			Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-XXXXX,
	</Requerimiento>
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

BEGIN
	
	DECLARE @vdtFecha_Semestre DATETIME
	
	SET @vdtFecha_Semestre = @pdtFecha_Inicial
	
	WHILE (@vdtFecha_Semestre <= @pdtFecha_Final)
	BEGIN
		--Se obtien las operaciones comunes
		INSERT	INTO @ptbFechas_Semestrales(Fecha_Semestre, Codigo_Garantia, Tipo_Cambio, 
		                                    IPC, Tipo_Cambio_Anterior, IPC_Anterior, Tipo_Registro)
		VALUES (@vdtFecha_Semestre, @piCodigo_Garantia, NULL, NULL, NULL, NULL, 0)
		
		SET @vdtFecha_Semestre = DATEADD(MONTH, 6, @vdtFecha_Semestre)  
	END
	
	UPDATE	@ptbFechas_Semestrales
	SET		Tipo_Registro = 1
	FROM	(SELECT MAX(Numero_Semestre) AS Num_Semestre FROM @ptbFechas_Semestrales) B
	WHERE	Numero_Semestre = B.Num_Semestre
	
	UPDATE	@ptbFechas_Semestrales
	SET		Tipo_Registro = 2
	FROM	(SELECT MAX(Numero_Semestre) AS Num_Semestre FROM @ptbFechas_Semestrales) B
	WHERE	Numero_Semestre = (B.Num_Semestre - 1)
	
	UPDATE	@ptbFechas_Semestrales
	SET		Tipo_Cambio = CIA.Tipo_Cambio,
			IPC			= CIA.Indice_Precios_Consumidor
	FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA WITH (NOLOCK)
	WHERE	Fecha_Semestre =  CONVERT(DATETIME,CAST(CIA.Fecha_Hora AS VARCHAR(11)),101)
					
	UPDATE	@ptbFechas_Semestrales
	SET		Tipo_Cambio_Anterior	= CIA.Tipo_Cambio,
			IPC_Anterior			= CIA.Indice_Precios_Consumidor
	FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA WITH (NOLOCK)
	WHERE	CONVERT(DATETIME,CAST(CIA.Fecha_Hora AS VARCHAR(11)),101) = DATEADD(MONTH, -6, Fecha_Semestre)
	
	UPDATE	@ptbFechas_Semestrales
	SET		Total_Registros = (SELECT MAX(FS1.Numero_Semestre) FROM @ptbFechas_Semestrales FS1)

	RETURN
END
GO

