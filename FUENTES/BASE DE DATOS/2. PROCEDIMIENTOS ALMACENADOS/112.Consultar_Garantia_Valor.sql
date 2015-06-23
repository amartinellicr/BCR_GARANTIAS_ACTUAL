USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Garantia_Valor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Garantia_Valor;
GO

CREATE PROCEDURE [dbo].[Consultar_Garantia_Valor]
		
	@piOperacion		BIGINT,
	@piGarantia			BIGINT,
	@psIDUsuario VARCHAR(30) ,
	@psRespuesta		VARCHAR(1000) OUTPUT
AS

-- =============================================
-- Autor:			Ing. Leonardo Cortes Mora
-- Fecha Creación:	24/06/2014
-- Descripción:		Procedimiento almacenado que obtiene la información referente a las garantías de valor relacionadas a operaciones y giros activos
-- =============================================
--				HISTORIAL DE CAMBIOS
-- =============================================
-- Autor:				
-- Fecha Modificación:	
-- Descripción:			
-- =============================================

BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy	


	SELECT DISTINCT 
		GOP.cod_contabilidad, 
		GOP.cod_oficina, 
		GOP.cod_moneda, 
		GOP.cod_producto, 
		GOP.num_operacion AS operacion, 
		GVA.numero_seguridad AS numero_seguridad, 
		ISNULL(GVP.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
		ISNULL(GVP.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
		ISNULL(GVP.monto_mitigador, 0) AS monto_mitigador,
		ISNULL(GVP.fecha_presentacion_registro, '1900-01-01') AS fecha_presentacion,
		ISNULL(GVP.cod_inscripcion, -1) AS cod_inscripcion,
		ISNULL(GVP.porcentaje_responsabilidad, 0) AS porcentaje_responsabilidad,
		ISNULL(GVA.fecha_constitucion, '1900-01-01') AS fecha_constitucion,
		ISNULL(GVP.cod_grado_gravamen, -1) AS cod_grado_gravamen,
		ISNULL(GVP.cod_grado_prioridades, -1) AS cod_grado_prioridades,
		ISNULL(GVP.monto_prioridades, 0) AS monto_prioridades,
		CASE GVP.cod_tipo_acreedor 
			WHEN NULL THEN 2 
			WHEN -1 THEN 2 
			ELSE GVP.cod_tipo_acreedor 
		END AS cod_tipo_acreedor,
		ISNULL(GVP.cedula_acreedor, '') AS cedula_acreedor,
		ISNULL(GVA.fecha_vencimiento_instrumento, '1900-01-01') AS fecha_vencimiento, 
		ISNULL(GVP.cod_operacion_especial, 0) AS cod_operacion_especial,
		ISNULL(GVA.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
		ISNULL(GVA.des_instrumento, '') AS des_instrumento,
		ISNULL(GVA.des_serie_instrumento, '') AS des_serie_instrumento,
		ISNULL(GVA.cod_tipo_emisor, -1) AS cod_tipo_emisor,
		ISNULL(GVA.cedula_emisor, '') AS cedula_emisor,
		ISNULL(GVA.premio, 0) AS premio,
		ISNULL(GVA.cod_isin, '') AS cod_isin,
		ISNULL(GVA.valor_facial, 0) AS valor_facial,
		ISNULL(GVA.cod_moneda_valor_facial, -1) AS cod_moneda_valor_facial,
		ISNULL(GVA.valor_mercado, 0) AS valor_mercado,
		ISNULL(GVA.cod_moneda_valor_mercado, -1) AS cod_moneda_valor_mercado,
		GVA.cod_tipo_garantia,
		GVA.cod_clase_garantia,
		ISNULL(GVA.cod_tenencia, -1) AS cod_tenencia,	
		ISNULL(GVA.fecha_prescripcion, '1900-01-01') AS fecha_prescripcion, 
		GVP.cod_garantia_valor,
		GVP.cod_operacion,
		GVP.cod_estado,
		1 AS ind_duplicidad,
		@psIDUsuario AS cod_usuario,		
		ISNULL(GVA.Usuario_Modifico, '') AS Usuario_Modifico,
		ISNULL (SGU.DES_USUARIO,'') AS Nombre_Usuario_Modifico,
		ISNULL(GVA.Fecha_Modifico,'1900-01-01') AS Fecha_Modifico,
		ISNULL(GVA.Fecha_Inserto,'1900-01-01') AS Fecha_Inserto,
		ISNULL(GVA.Fecha_Replica,'1900-01-01') AS Fecha_Replica	
		
	FROM 
		GAR_OPERACION GOP 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION  GVP 
		ON GOP.cod_operacion = GVP.cod_operacion 

		INNER JOIN GAR_GARANTIA_VALOR  GVA
		ON GVA.cod_garantia_valor = GVP.cod_garantia_valor 

		LEFT JOIN SEG_USUARIO SGU
			ON SGU.COD_USUARIO  = GVA.Usuario_Modifico 

		INNER JOIN CAT_ELEMENTO CEL
			ON CEL.cat_campo = GVA.cod_clase_garantia 

	WHERE	GOP.cod_operacion = @piOperacion
			AND GVA.cod_garantia_valor =  @piGarantia						
			AND CEL.cat_catalogo= 7


	SET @psRespuesta = N'<RESPUESTA>' +
							'<CODIGO>0</CODIGO>' +
							'<NIVEL></NIVEL>' +
							'<ESTADO></ESTADO>' +
							'<PROCEDIMIENTO>Consultar_Garantia_Valor</PROCEDIMIENTO>' +
							'<LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactorio.</MENSAJE>' +
							'<DETALLE></DETALLE>' +
						'</RESPUESTA>'

	RETURN 0


END