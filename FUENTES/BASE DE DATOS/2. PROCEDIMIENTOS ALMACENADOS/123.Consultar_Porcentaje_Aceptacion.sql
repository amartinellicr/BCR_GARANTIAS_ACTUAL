USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Porcentaje_Aceptacion;
GO

CREATE PROCEDURE [dbo].[Consultar_Porcentaje_Aceptacion]
	
	@piConsecutivo_Registro				INT = NULL,
	@piCodigo_Tipo_Garantia				INT = NULL,
	@piCodigo_Tipo_Mitigador			INT = NULL,
	@piAccion							INT , --1.Consecutivo 2.Tipo Garantia 3. Tipo de Mitigador 4. Tipo Garantia y Tipo Mitigador
	@psRespuesta						VARCHAR(1000) OUTPUT
	
	
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Porcentaje_Aceptacion</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de consultar la información del tipo de porcentaje de Aceptacion
	</Descripción>
	<Entradas>
		@piConsecutivo_Registro	= Consecutivo del registro, en caso de que sea nulo se retornan todos los registros.		
	</Entradas>
	<Salidas>		
	</Salidas>
	<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>09/12/2014</Fecha>
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
	
	--Consecutivo
	IF(@piAccion = 1)
	BEGIN

			SELECT 	
			CPA.Codigo_Porcentaje_Aceptacion AS Codigo_Porcentaje_Aceptacion,
			CPA.Codigo_Tipo_Garantia AS  Codigo_Tipo_Garantia,
			CPA.Codigo_Tipo_Mitigador AS Codigo_Tipo_Mitigador,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'Si'
				ELSE 'No'
			END AS Indicador_NA_Calificacion,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'No'
				ELSE 'Si'
			END AS Indicador_Sin_Calificacion,
			COALESCE(CPA.Porcentaje_Aceptacion,0) AS Porcentaje_Aceptacion,
			COALESCE(CPA.Porcentaje_Cero_Tres,0) AS Porcentaje_Cero_Tres,
			COALESCE(CPA.Porcentaje_Cuatro,0) AS Porcentaje_Cuatro,
			COALESCE(CPA.Porcentaje_Cinco,0) AS Porcentaje_Cinco,
			COALESCE(CPA.Porcentaje_Seis,0) AS Porcentaje_Seis,
			COALESCE(CPA.Usuario_Inserto,'-') AS Usuario_Inserto,
			COALESCE(CPA.Fecha_Inserto,'19000101') AS Fecha_Inserto,
			COALESCE(CPA.Usuario_Modifico,'') AS Usuario_Modifico,
			COALESCE(CPA.Fecha_Modifico,'19000101') AS Fecha_Modifico
									
			FROM	dbo.CAT_PORCENTAJE_ACEPTACION CPA			
			WHERE	CPA.Codigo_Porcentaje_Aceptacion = COALESCE(@piConsecutivo_Registro, CPA.Codigo_Porcentaje_Aceptacion)
	END
	
	--2.Tipo Garantia 
	IF(@piAccion = 2)
	BEGIN
		SELECT 	
			CPA.Codigo_Porcentaje_Aceptacion AS Codigo_Porcentaje_Aceptacion,
			CPA.Codigo_Tipo_Garantia AS  Codigo_Tipo_Garantia,
			CPA.Codigo_Tipo_Mitigador AS Codigo_Tipo_Mitigador,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'Si'
				ELSE 'No'
			END AS Indicador_NA_Calificacion,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'No'
				ELSE 'Si'
			END AS Indicador_Sin_Calificacion,
			COALESCE(CPA.Porcentaje_Aceptacion,0) AS Porcentaje_Aceptacion,
			COALESCE(CPA.Porcentaje_Cero_Tres,0) AS Porcentaje_Cero_Tres,
			COALESCE(CPA.Porcentaje_Cuatro,0) AS Porcentaje_Cuatro,
			COALESCE(CPA.Porcentaje_Cinco,0) AS Porcentaje_Cinco,
			COALESCE(CPA.Porcentaje_Seis,0) AS Porcentaje_Seis,
			COALESCE(CPA.Usuario_Inserto,'-') AS Usuario_Inserto,
			COALESCE(CPA.Fecha_Inserto,'19000101') AS Fecha_Inserto,
			COALESCE(CPA.Usuario_Modifico,'') AS Usuario_Modifico,
			COALESCE(CPA.Fecha_Modifico,'19000101') AS Fecha_Modifico
									
			FROM	dbo.CAT_PORCENTAJE_ACEPTACION CPA			
			WHERE	CPA.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia					
	END
	
	--3. Tipo de Mitigador 
	IF(@piAccion = 3)
	BEGIN
		SELECT 	
			CPA.Codigo_Porcentaje_Aceptacion AS Codigo_Porcentaje_Aceptacion,
			CPA.Codigo_Tipo_Garantia AS  Codigo_Tipo_Garantia,
			CPA.Codigo_Tipo_Mitigador AS Codigo_Tipo_Mitigador,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'Si'
				ELSE 'No'
			END AS Indicador_NA_Calificacion,
			CASE 
				WHEN CPA.Indicador_Sin_Calificacion = 0 THEN 'No'
				ELSE 'Si'
			END AS Indicador_Sin_Calificacion,
			COALESCE(CPA.Porcentaje_Aceptacion,0) AS Porcentaje_Aceptacion,
			COALESCE(CPA.Porcentaje_Cero_Tres,0) AS Porcentaje_Cero_Tres,
			COALESCE(CPA.Porcentaje_Cuatro,0) AS Porcentaje_Cuatro,
			COALESCE(CPA.Porcentaje_Cinco,0) AS Porcentaje_Cinco,
			COALESCE(CPA.Porcentaje_Seis,0) AS Porcentaje_Seis,
			COALESCE(CPA.Usuario_Inserto,'-') AS Usuario_Inserto,
			COALESCE(CPA.Fecha_Inserto,'19000101') AS Fecha_Inserto,
			COALESCE(CPA.Usuario_Modifico,'') AS Usuario_Modifico,
			COALESCE(CPA.Fecha_Modifico,'19000101') AS Fecha_Modifico
									
			FROM	dbo.CAT_PORCENTAJE_ACEPTACION CPA			
			WHERE	CPA.Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador
	END

    --4. Tipo Garantia y Tipo Mitigador
	IF(@piAccion = 4)
	BEGIN
	
		
		SELECT	COALESCE(CPA.Porcentaje_Aceptacion,0) AS Porcentaje_Aceptacion								
		FROM	dbo.CAT_PORCENTAJE_ACEPTACION CPA			
		WHERE	CPA.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia
			AND CPA.Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador
			
		UNION ALL

		SELECT	0 AS Porcentaje_Aceptacion
		WHERE	NOT EXISTS (SELECT 1
							FROM dbo.CAT_PORCENTAJE_ACEPTACION CPA
							WHERE	CPA.Codigo_Tipo_Garantia = @piCodigo_Tipo_Garantia
								AND CPA.Codigo_Tipo_Mitigador = @piCodigo_Tipo_Mitigador)	

	END

END