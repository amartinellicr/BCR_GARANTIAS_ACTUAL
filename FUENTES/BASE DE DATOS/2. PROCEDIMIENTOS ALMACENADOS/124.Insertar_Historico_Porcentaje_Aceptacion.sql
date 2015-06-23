USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Historico_Porcentaje_Aceptacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Insertar_Historico_Porcentaje_Aceptacion;
GO

-- =============================================
-- Author:		Leonardo Cortés Mora, Lidersoft Internacional S.A.
-- Create date: 09/12/2014
-- Description:	Procedimiento que se encarga de insertar los datos requeridos en la tabla historial de porcentaje de aceptacion
-- =============================================
CREATE PROCEDURE [dbo].[Insertar_Historico_Porcentaje_Aceptacion]
	
	@psCodigo_Usuario                         VARCHAR(30),
	@piCodigo_Accion						  INT,
	@piCodigo_Consulta						  TEXT       = NULL,
	@piCodigo_Tipo_Garantia					  INT,
	@piCodigo_Tipo_Mitigador				  INT,
	@psDescripcion_Campo_Afectado			  VARCHAR(30) = NULL,
	@psEstado_Anterior_Campo_Afectado         VARCHAR(30) = NULL,
	@psEstado_Actual_Campo_Afectado           VARCHAR(30) = NULL

	
AS
BEGIN TRANSACTION	
	INSERT INTO dbo.PORCENTAJE_ACEPTACION_HST
	(
		Codigo_Usuario,
		Codigo_Accion,
		Codigo_Consulta,
		Codigo_Tipo_Garantia,
		Codigo_Tipo_Mitigador,
		Descripcion_Campo_Afectado,
		Estado_Anterior_Campo_Afectado,
		Estado_Actual_Campo_Afectado,
		Fecha_Hora
	)
	VALUES
	(
		@psCodigo_Usuario,                         
		@piCodigo_Accion,						  
		@piCodigo_Consulta,						  
		@piCodigo_Tipo_Garantia,					  
		@piCodigo_Tipo_Mitigador,				  
		@psDescripcion_Campo_Afectado,			  
		@psEstado_Anterior_Campo_Afectado,         
		@psEstado_Actual_Campo_Afectado,
		GETDATE()  
	
	)

COMMIT TRANSACTION
RETURN 0
