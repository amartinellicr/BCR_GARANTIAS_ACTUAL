USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Generar_Informacion_Cambios_Garantias', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Generar_Informacion_Cambios_Garantias;
GO

CREATE PROCEDURE dbo.Generar_Informacion_Cambios_Garantias
		

	@piAccion					INT, -- 1:Todos Operacion 2:Todos Contratos, 3:Todos General
	@pdtFecha_Inicio			DATETIME,
	@pdtFecha_Fin				DATETIME
	
AS

-- =============================================
-- Autor:			Ing. Leonardo Cortes Mora
-- Fecha Creación:	10/07/2014
-- Descripción:		Procedimiento almacenado que obtiene la informacion de las garantias que se modificaron 
-- =============================================
--				HISTORIAL DE CAMBIOS
-- =============================================
-- Autor:				
-- Fecha Modificación:	
-- Descripción:			
-- =============================================
BEGIN

	DECLARE @vdtFechaFinal DATETIME
	
	SET @vdtFechaFinal = (SELECT DATEADD(DAY, 1, @pdtFecha_Fin))

	/*Todos las operaciones*/
	IF(@piAccion = 1) 
	BEGIN		
	

		-------------------------------------------
		--GARANTIA FIDUCIARIA 1
		-------------------------------------------

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,	
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')		AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)
		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		
		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_contrato = 0	
		AND GBI.cod_tipo_garantia = 1	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL		
		
		-------------------------------------------
		--GARANTIA REAL 2
		-------------------------------------------
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,	
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')		AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)
		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		
		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_contrato = 0	
		AND GBI.cod_tipo_garantia = 2			
		AND CHARINDEX('-', GBI.cod_garantia ) > 1	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL		
		
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')		AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)
		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		
		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_contrato = 0	
		AND GBI.cod_tipo_garantia = 2		
		AND CHARINDEX('[',GBI.cod_garantia ) > 0
	    AND CHARINDEX('-',GBI.cod_garantia ) = 0
	    AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		-------------------------------------------
		--GARANTIA VALOR 3
		-------------------------------------------
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')		AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)
		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		
		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_contrato = 0	
		AND GBI.cod_tipo_garantia = 3	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL				
	
		ORDER BY FECHA_HORA DESC	
			
	END --FIN IF(@piAccion = 1) 

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

	/*Todos los contratos*/
	IF(@piAccion = 2) 
	BEGIN		
	
		-------------------------------------------
		--GARANTIA FIDUCIARIA 1
		-------------------------------------------		
		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,				
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_operacion IS NULL
		AND GBI.cod_tipo_garantia = 1
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL	
		
		-------------------------------------------
		--GARANTIA REAL 2
		-------------------------------------------
		UNION ALL

		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,					
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_operacion IS NULL
		AND GBI.cod_tipo_garantia = 2	
		AND CHARINDEX('-', GBI.cod_garantia ) > 1
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL			
		
		UNION ALL
			
		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,					
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_operacion IS NULL
		AND GBI.cod_tipo_garantia = 2	
		AND CHARINDEX('[',GBI.cod_garantia ) > 0
	    AND CHARINDEX('-',GBI.cod_garantia ) = 0
	    AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		
		-------------------------------------------
		--GARANTIA VALOR 3
		-------------------------------------------
		
		UNION ALL

		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,					
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GOP.num_operacion IS NULL
		AND GBI.cod_tipo_garantia = 3	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL		
				
        ORDER BY FECHA_HORA DESC	
		
	END --FIN IF(@piAccion = 2) 

---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

	/*Todos General*/
	IF(@piAccion = 3) 
	BEGIN
		-------------------------------------------------------------------------------------------------	
		--	OPERACION
		-------------------------------------------------------------------------------------------------		
		-------------------------------------------
		--GARANTIA FIDUCIARIA 1
		-------------------------------------------
		
		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GBI.cod_tipo_garantia = 1
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL			
		
		-------------------------------------------
		--GARANTIA REAL 2
		-------------------------------------------
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GBI.cod_tipo_garantia = 2			
		AND CHARINDEX('-', GBI.cod_garantia ) > 1
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,				
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GBI.cod_tipo_garantia = 2		
     	AND CHARINDEX('[',GBI.cod_garantia ) > 0
	    AND CHARINDEX('-',GBI.cod_garantia ) = 0
	    AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		-------------------------------------------
		--GARANTIA VALOR 3
		-------------------------------------------
		UNION ALL

		SELECT  	
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
														CONVERT(VARCHAR(10), GOP.num_operacion)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		
		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal  
		AND GBI.cod_tipo_garantia = 3
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL			

		-------------------------------------------------------------------------------------------------	
		--	CONTRATO
		-------------------------------------------------------------------------------------------------		
		-------------------------------------------
		--GARANTIA FIDUCIARIA 1
		-------------------------------------------
		
		UNION ALL

		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,		
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,			
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal 
		AND GBI.cod_tipo_garantia = 1	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL	
		
		-------------------------------------------
		--GARANTIA REAL 2
		-------------------------------------------
		
		UNION ALL

		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,	
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,	
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,		
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal 
		AND GBI.cod_tipo_garantia = 2		
		AND CHARINDEX('-', GBI.cod_garantia ) > 1
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		UNION ALL

		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,		
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,		
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal 
		AND GBI.cod_tipo_garantia = 2		
		AND CHARINDEX('[',GBI.cod_garantia ) > 0
	    AND CHARINDEX('-',GBI.cod_garantia ) = 0
	    AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
		
		-------------------------------------------
		--GARANTIA VALOR 3
		-------------------------------------------
		
		UNION ALL
		
		SELECT  
					ISNULL(GBI.cod_garantia,'-')	AS GARANTIA,
					CASE
					WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
					WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
					WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
					END								AS TIPO_GARANTIA,		
					ISNULL(GBI.cod_operacion_crediticia,'-')  AS OPERACION_CREDITICIA,	
					CASE
					WHEN GBI.cod_operacion = 1 THEN 'Insertado'
					WHEN GBI.cod_operacion = 2 THEN 'Modificado'
					WHEN GBI.cod_operacion = 3 THEN 'Eliminado'
					END							AS ACCION_REALIZADA,		
					ISNULL(GBI.des_campo_afectado,'-')	AS CAMPO,		
					ISNULL(GBI.est_anterior_campo_afectado,'-')	AS VALOR_PASADO ,
					ISNULL(GBI.est_actual_campo_afectado,'-')AS  VALOR_ACTUAL,		
					ISNULL(CONVERT(VARCHAR(10), GBI.fecha_hora, 105), '-')	 	AS  FECHA_MODIFICACION	,						 
					ISNULL(GBI.cod_Usuario,'-')	AS USUARIO ,		
					ISNULL(SUS.DES_USUARIO,'-')	AS NOMBRE,
					ISNULL(GBI.fecha_hora,'19000101') AS FECHA_HORA
		FROM dbo.GAR_OPERACION GOP

			INNER JOIN 	 dbo.GAR_BITACORA GBI 
					ON GBI.cod_operacion_crediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
														CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
														CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 														
														CONVERT(VARCHAR(10), GOP.num_contrato)
														)

		 INNER JOIN SEG_USUARIO SUS
					ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS		

		WHERE GBI.fecha_hora BETWEEN @pdtFecha_Inicio AND @vdtFechaFinal 
		AND GBI.cod_tipo_garantia = 3	
		AND GBI.est_actual_campo_afectado IS NOT NULL
		AND GBI.est_anterior_campo_afectado IS NOT NULL
		AND GBI.des_campo_afectado IS NOT NULL
			
		ORDER BY FECHA_HORA DESC	

	END-- FIN 	IF(@piAccion = 3) 

---------------------------------------------------------------------------------------------------------------------------





END --FIN INICIAL