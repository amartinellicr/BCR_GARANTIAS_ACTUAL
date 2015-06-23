USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Cambios_Garantias', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Cambios_Garantias;
GO

CREATE PROCEDURE dbo.Consultar_Cambios_Garantias
	
	@piOperacion_Crediticia		VARCHAR(30),
	@piCod_Garantia				VARCHAR(30),
	@piAccion					INT, --1: Consulta Garantias Asociadas 2:Consulta archivo txt
	@psRespuesta				VARCHAR(1000) OUTPUT

AS
	/************************************************************************************************
	 *                                                                                              * 
	 *								INICIO DE LA SELECCION DE DATOS		     						*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
BEGIN

    SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	
/******************************************************************
	<Historial>
		<Cambio>
			<Autor>Leonardo Cortes Mora, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios en Garantias Siebel 1-24361471 </Requerimiento>
			<Fecha>10/09/2014</Fecha>
			<Descripción>
				Se quieta el DISTINCT del SELECT para que jale todos los datos
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor> Leonardo Cortes Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>Cambios en Garantias Siebel 1-24361471</Requerimiento>
			<Fecha> 18/09/2014</Fecha>
			<Descripción>
				Se agregan dos campos nuevos, Tipo_Garantia y Accion_Realizada,
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortes Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>Cambios en Garantias Siebel 1-24361471</Requerimiento>
			<Fecha> 23/09/2014</Fecha>
			<Descripción> 
					Se quita la parte de XML, trama, se sustituye por un SELECT normal
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


------------------------------------------------------------------------------------------------------
-- CONSULTA GARANTIAS ASOCIADAS
------------------------------------------------------------------------------------------------------

	IF(@piAccion = 1)
	BEGIN		
			
		SELECT		
			CASE
			WHEN  GBI.cod_tipo_garantia = 1 THEN 'Fiduciaria'
			WHEN  GBI.cod_tipo_garantia = 2 THEN 'Real'
			WHEN  GBI.cod_tipo_garantia = 3 THEN 'Valor'					
			END								AS TIPO_GARANTIA,
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

		FROM dbo.GAR_BITACORA GBI 
			 INNER JOIN SEG_USUARIO SUS
				ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS
		WHERE 
			GBI.cod_garantia = @piCod_Garantia	
			AND GBI.est_actual_campo_afectado IS NOT NULL
			AND GBI.est_anterior_campo_afectado IS NOT NULL
			AND GBI.des_campo_afectado IS NOT NULL	
			
			ORDER BY FECHA_HORA DESC
			
	END

-------------------------------------------------------------------------------------------------------
---- GENERAR ARCHIVO TXT
--------------------------------------------------------------------------------------------------------
	IF(@piAccion = 2)
	BEGIN
			
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

		FROM dbo.GAR_BITACORA GBI 
			 INNER JOIN SEG_USUARIO SUS
				ON SUS.COD_USUARIO  = GBI.cod_Usuario COLLATE Latin1_General_CI_AS
		WHERE 
			GBI.cod_garantia = @piCod_Garantia	
			AND GBI.est_actual_campo_afectado IS NOT NULL
			AND GBI.est_anterior_campo_afectado IS NOT NULL
			AND GBI.des_campo_afectado IS NOT NULL	
			
		ORDER BY FECHA_HORA DESC
			

	END

	RETURN 0

END
