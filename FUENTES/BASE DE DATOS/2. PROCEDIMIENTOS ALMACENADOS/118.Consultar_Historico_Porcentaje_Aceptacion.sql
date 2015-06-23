USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Historico_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Historico_Porcentaje_Aceptacion;
GO

CREATE PROCEDURE [dbo].[Consultar_Historico_Porcentaje_Aceptacion]
		
	@piCodigo_Tipo_Garantia	         INT = NULL,
	@piCodigo_Tipo_Mitigador	     INT = NULL,
	@piCodigo_Catalago_Garantia		INT,
	@piCodigo_Catalago_Mitigador	INT,
	@psCodigo_Usuario				VARCHAR(30) = NULL , --Definir si va en combo o que nada mas el usuario digite la cedula. Crear sp que Jale los usuarios del historial 
	@pdtFecha_Inicio				DATETIME,
	@pdtFecha_Final					DATETIME	
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Historial_Porcentaje_Aceptacion</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de consultar la información del histórico de porcentaje de aceptacion.
	</Descripción>
	<Entradas>
		@piConsecutivo_Registro	= Consecutivo del registro, en caso de que sea nulo se retornan todos los registros.	
		
		@piCodigo_Tipo_Garantia		= Codigo del tipo de garantia, del catálogo tipo de Garantias,en caso de que sea nulo se retornan todos los registros.		
		@piCodigo_Tipo_Mitigador	= Codigo del tipo de mitigador, del catálogo tipo de mitigador de riesgo,en caso de que sea nulo se retornan todos los registros.	
		@psCodigo_Usuario			= Código del usuario, cedula, que ha realizado modificaciones a los registros.
		
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

	DECLARE @vdtFechaFinal DATETIME
	
	SET @vdtFechaFinal = (SELECT DATEADD(DAY, 1, @pdtFecha_Final))
	
	SELECT 
		COALESCE(HST.Fecha_Hora,'19000101') AS FECHA_HORA,		
	    COALESCE(HST.Codigo_Usuario,'-')	AS USUARIO ,		
		COALESCE(SUS.DES_USUARIO,'-')	    AS NOMBRE_USUARIO,
		 COALESCE(HST.Descripcion_Campo_Afectado,'-') AS CAMPO,
		CASE
			WHEN HST.Codigo_Accion = 1 THEN 'Insertado'
			WHEN HST.Codigo_Accion = 2 THEN 'Modificado'
			WHEN HST.Codigo_Accion = 3 THEN 'Eliminado'
		END	AS ACCION_REALIZADA,
		
		
		CASE 
			WHEN  COALESCE(HST.Descripcion_Campo_Afectado,'-') = 'Indicador_Sin_Calificacion' 
			THEN 
				CASE 
					WHEN COALESCE(HST.Estado_Anterior_Campo_Afectado,'-') = '0' THEN 'No'
					WHEN COALESCE(HST.Estado_Anterior_Campo_Afectado,'-') = '1' THEN 'Si'	
					ELSE '-'				
				END 
			ELSE COALESCE(HST.Estado_Anterior_Campo_Afectado,'-')		
		END AS VALOR_PASADO,
		
		CASE 
			WHEN  COALESCE(HST.Descripcion_Campo_Afectado,'-') = 'Indicador_Sin_Calificacion' 
			THEN 
				CASE 
					WHEN COALESCE(HST.Estado_Actual_Campo_Afectado,'-') = '0' THEN 'No'
					WHEN COALESCE(HST.Estado_Actual_Campo_Afectado,'-') = '1' THEN 'Si'		
					ELSE '-'			
				END 
			ELSE COALESCE(HST.Estado_Actual_Campo_Afectado,'-')		
		END AS VALOR_ACTUAL,	
		
		(COALESCE(CE1.cat_campo,'')+ ' - '+  COALESCE(CE1.cat_descripcion,'')) AS TIPO_GARANTIA ,
		(COALESCE(CE2.cat_campo,'') + ' - '+ COALESCE(CE2.cat_descripcion,'')) AS TIPO_MITIGADOR	
		
	FROM dbo.PORCENTAJE_ACEPTACION_HST HST
	INNER JOIN SEG_USUARIO SUS
		ON SUS.COD_USUARIO  = HST.Codigo_Usuario COLLATE Latin1_General_CI_AS	
	LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
		ON CE1.CAT_CATALOGO = @piCodigo_Catalago_Garantia
		AND CE1.cat_campo = COALESCE (@piCodigo_Tipo_Garantia, HST.Codigo_Tipo_Garantia)
	LEFT OUTER JOIN dbo.CAT_ELEMENTO CE2
		ON CE2.CAT_CATALOGO = @piCodigo_Catalago_Mitigador
		AND CE2.cat_campo = COALESCE (@piCodigo_Tipo_Mitigador, HST.Codigo_Tipo_Mitigador)
	
	WHERE HST.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal 
	AND	HST.Codigo_Tipo_Garantia = COALESCE( @piCodigo_Tipo_Garantia, HST.Codigo_Tipo_Garantia)
	AND HST.Codigo_Tipo_Mitigador = COALESCE(@piCodigo_Tipo_Mitigador , HST.Codigo_Tipo_Mitigador)
	AND HST.Codigo_Usuario =  COALESCE(@psCodigo_Usuario , HST.Codigo_Usuario)
	ORDER BY HST.FECHA_HORA DESC
	
END