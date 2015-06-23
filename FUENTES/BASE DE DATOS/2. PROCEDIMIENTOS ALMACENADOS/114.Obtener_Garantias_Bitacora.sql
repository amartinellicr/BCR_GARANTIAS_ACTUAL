USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Garantias_Bitacora', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Obtener_Garantias_Bitacora;
GO

CREATE PROCEDURE dbo.Obtener_Garantias_Bitacora
		
	@piCodOperacion				BIGINT = NULL,	
	@piContabilidad				TINYINT,
	@piOficina					SMALLINT,
	@piMoneda					TINYINT,
	@piProducto					TINYINT = NULL,
	@piOperacion				DECIMAL(7),	
	@piContrato					INT,
	@pbEsOperacion				BIT, -- 1:Operacion 0: Contrato
	@psRespuesta				VARCHAR(1000) OUTPUT

AS

-- =============================================
-- Autor:			Ing. Leonardo Cortes Mora
-- Fecha Creación:	03/07/2014
-- Descripción:		Procedimiento almacenado que obtiene el codigo de garantia y el tipo de garantia de las garantias que se encuentran en bitácora
-- =============================================
--				HISTORIAL DE CAMBIOS
-- =============================================
-- Autor: Leonardo Cortes Mora		
-- Fecha Modificación:	25/08/2014
-- Descripción:	Se agregan UNIONS para cada garantia, filtrando cada uno con sus respectivos formatos de presentacion 		
-- =============================================
-- Autor: Leonardo Cortes Mora					
-- Fecha Modificación:	16/09/2014
-- Descripción:	Se quitan el if de CodOperacion, y se unifica el codigo de Operacion Crediticia, esto ya que la tabla GAR_BITACORA
--				se está normalizando los datos para su correcta extraccion 		
-- =============================================
-- Autor:				
-- Fecha Modificación:	
-- Descripción:			
-- =============================================

BEGIN

	-- Declaración de variables
	DECLARE 
	@vsCodOperacionCrediticia	VARCHAR(30)

-----------------------------------------------------------------------------------
-- SEGMENTO PARA DEFINIR SI ES OPERACINO O CONTRATO
----------------------------------------------------------------------------------

	/*Se determina si es Operacion. 1:Operacion 0:Contrato*/
	IF(@pbEsOperacion = 1) 
		BEGIN 
			
				--/*Se determina si se ha enviado el consecutivo de la operación*/
				--IF(@piCodOperacion IS NULL)
				--BEGIN
				--	SET @piCodOperacion = ( 
				--							SELECT DISTINCT GOP.cod_operacion											
				--							FROM dbo.GAR_OPERACION GOP
				--							INNER JOIN 	 dbo.GAR_BITACORA GBI 
				--								ON CONVERT(VARCHAR(10), GOP.cod_operacion) = GBI.cod_operacion_crediticia								
				--							WHERE 
				--							GOP.cod_contabilidad = @piContabilidad
				--							AND GOP.cod_oficina = @piOficina
				--							AND GOP.cod_moneda = @piMoneda
				--							AND GOP.cod_producto = @piProducto
				--							AND GOP.num_operacion = @piOperacion	)		
				--END	

				--SET @vsCodOperacionCrediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
				--																CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
				--																CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 
				--																CONVERT(VARCHAR(10),GOP.cod_producto )  +'-'+ 
				--																CONVERT(VARCHAR(10), GOP.num_operacion)
				--												FROM dbo.GAR_OPERACION GOP
				--												INNER JOIN 	 dbo.GAR_BITACORA GBI 
				--															ON CONVERT(VARCHAR(10), GOP.cod_operacion) = GBI.cod_operacion_crediticia								
				--												WHERE 
																
				--												GOP.cod_contabilidad = @piContabilidad 
				--												AND GOP.cod_oficina =  @piOficina  
				--												AND GOP.cod_moneda = @piMoneda 
				--												AND GOP.cod_producto = @piProducto 
				--												AND GOP.num_operacion = @piOperacion)

            SET @vsCodOperacionCrediticia = CONVERT(VARCHAR(10),@piContabilidad) +'-'+ 
											 CONVERT(VARCHAR(10),@piOficina )+'-'+ 
											 CONVERT(VARCHAR(10),@piMoneda) +'-'+ 
											 CONVERT(VARCHAR(10),@piProducto) + '-'+ 
											 CONVERT(VARCHAR(10),@piOperacion)
															
		END

	ELSE -- FIN IF(@pbEsOperacion = 1) 
		BEGIN
				--/*Se determina si se ha enviado el consecutivo del contrato*/
				--IF(@piCodOperacion IS NULL)
				--BEGIN		
				--	SET @piCodOperacion = (SELECT DISTINCT GOP.cod_operacion											
				--							FROM dbo.GAR_OPERACION GOP
				--							INNER JOIN 	 dbo.GAR_BITACORA GBI 
				--								ON CONVERT(VARCHAR(10), GOP.cod_operacion) = GBI.cod_operacion_crediticia
				--						  WHERE 
				--							GOP.cod_contabilidad = @piContabilidad
				--							AND GOP.cod_oficina = @piOficina
				--							AND GOP.cod_moneda = @piMoneda
				--							AND GOP.num_contrato = @piContrato
				--							AND GOP.num_operacion IS NULL)		

				--END
					
				--/*REVISAR LA SELECCION DEL FORMATO*/
				--SET @vsCodOperacionCrediticia = (SELECT DISTINCT CONVERT(VARCHAR(10),GOP.cod_contabilidad) +'-'+ 
				--																CONVERT(VARCHAR(10),GOP.cod_oficina ) +'-'+ 
				--																CONVERT(VARCHAR(10), GOP.cod_moneda) +'-'+ 																				
				--																CONVERT(VARCHAR(10), GOP.num_contrato)
				--													FROM dbo.GAR_OPERACION GOP
				--													INNER JOIN 	 dbo.GAR_BITACORA GBI 
				--																ON CONVERT(VARCHAR(10), GOP.cod_operacion) = GBI.cod_operacion_crediticia								
				--													WHERE 
				--													GOP.cod_contabilidad = @piContabilidad
				--													AND GOP.cod_oficina = @piOficina
				--													AND GOP.cod_moneda = @piMoneda
				--													AND GOP.num_contrato = @piContrato
				--													AND GOP.num_operacion IS NULL)	
				
          SET @vsCodOperacionCrediticia =  CONVERT(VARCHAR(10),@piContabilidad) +'-'+ 
										   CONVERT(VARCHAR(10),@piOficina) +'-'+ 
										   CONVERT(VARCHAR(10),@piMoneda) +'-'+ 
										   CONVERT(VARCHAR(10),@piContrato)
															

		END

--------------------------------------------------------------------------------------------------------
-- FIN SEGMENTO PARA DEFINIR SI ES OPERACINO O CONTRATO
--------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--											INICIO SELECCION DE DATOS
---------------------------------------------------------------------------------------------------------
-------------------------------------------
--GARANTIA FIDUCIARIA 1
-------------------------------------------

	SELECT DISTINCT GBI.cod_garantia , 
					GBI.cod_tipo_garantia,
					GBI.cod_operacion_crediticia					

	FROM  dbo.GAR_BITACORA GBI
	WHERE 
	GBI.cod_tipo_garantia = 1
	AND GBI.cod_operacion_crediticia =  @vsCodOperacionCrediticia
	AND GBI.est_actual_campo_afectado IS NOT NULL
	AND GBI.est_anterior_campo_afectado IS NOT NULL
	AND GBI.des_campo_afectado IS NOT NULL	

-------------------------------------------
--GARANTIA REAL 2
-------------------------------------------
	UNION ALL
	
	SELECT DISTINCT GBI.cod_garantia , 
					GBI.cod_tipo_garantia,
					GBI.cod_operacion_crediticia					

	FROM  dbo.GAR_BITACORA GBI
	WHERE 
	GBI.cod_tipo_garantia = 2
	AND GBI.cod_operacion_crediticia =  @vsCodOperacionCrediticia		
	AND CHARINDEX('-', GBI.cod_garantia ) > 0
	AND GBI.est_actual_campo_afectado IS NOT NULL
	AND GBI.est_anterior_campo_afectado IS NOT NULL
	AND GBI.des_campo_afectado IS NOT NULL		
	
	UNION ALL
	
	SELECT DISTINCT GBI.cod_garantia , 
					GBI.cod_tipo_garantia,
					GBI.cod_operacion_crediticia					

	FROM  dbo.GAR_BITACORA GBI
	WHERE 
	GBI.cod_tipo_garantia = 2
	AND GBI.cod_operacion_crediticia =  @vsCodOperacionCrediticia		
	AND CHARINDEX('[',GBI.cod_garantia ) > 0
	AND CHARINDEX('-',GBI.cod_garantia ) = 0
	AND GBI.est_actual_campo_afectado IS NOT NULL
	AND GBI.est_anterior_campo_afectado IS NOT NULL
	AND GBI.des_campo_afectado IS NOT NULL	
	
-------------------------------------------
--GARANTIA VALOR 3
-------------------------------------------
	UNION ALL
	
	SELECT DISTINCT GBI.cod_garantia , 
					GBI.cod_tipo_garantia,
					GBI.cod_operacion_crediticia					

	FROM  dbo.GAR_BITACORA GBI
	WHERE 
	GBI.cod_tipo_garantia = 3
	AND GBI.cod_operacion_crediticia =  @vsCodOperacionCrediticia	
	AND GBI.est_actual_campo_afectado IS NOT NULL
	AND GBI.est_anterior_campo_afectado IS NOT NULL
	AND GBI.des_campo_afectado IS NOT NULL		

----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------

	SET @psRespuesta = N'<RESPUESTA>' +
							'<CODIGO>0</CODIGO>' +
							'<NIVEL></NIVEL>' +
							'<ESTADO></ESTADO>' +
							'<PROCEDIMIENTO>Consultar_Cambios_Garantias</PROCEDIMIENTO>' +
							'<LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactorio.</MENSAJE>' +
							'<DETALLE></DETALLE>' +
						'</RESPUESTA>'

	RETURN 0



END
