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
		
	@piConsecutivo_Operacion	BIGINT,
	@piConsecutivo_Garantia		BIGINT,
	@psCedula_Usuario			VARCHAR(30) ,
	@psRespuesta				VARCHAR(1000) OUTPUT
AS

/******************************************************************
	<Nombre>Consultar_Garantia_Valor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a las garantías de valor relacionadas a operaciones y giros activos.
	</Descripción>
	<Entradas>
			@piConsecutivo_Operacion	= Consecutivo asignado a la operación que respalda la garantía.
			@piConsecutivo_Garantia		= Consecutivo asignado a la garantía real que será modificada.
			@psCedula_Usuario	= Identificación dle usuario que modifica la garantía.
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Ing. Leonardo Cortes Mora, Lidersoft Internacional S.A.</Autor>
	<Fecha>24/06/2014</Fecha>
	<Requerimiento>N/A</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
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
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy	


	SELECT	DISTINCT 
			GOP.cod_contabilidad, 
			GOP.cod_oficina, 
			GOP.cod_moneda, 
			GOP.cod_producto, 
			GOP.num_operacion AS operacion, 
			GVA.numero_seguridad AS numero_seguridad, 
			COALESCE(GVP.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
			COALESCE(GVP.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			COALESCE(GVP.monto_mitigador, 0) AS monto_mitigador,
			CONVERT(VARCHAR(10), (COALESCE(GVP.fecha_presentacion_registro,'1900-01-01')), 103) AS fecha_presentacion_registro,
			--COALESCE(GVP.cod_inscripcion, -1) AS cod_inscripcion,
			0 AS cod_inscripcion,
			COALESCE(GVP.porcentaje_responsabilidad, -1) AS porcentaje_responsabilidad,
			CONVERT(VARCHAR(10), (COALESCE(GVA.fecha_constitucion,'1900-01-01')), 103) AS fecha_constitucion,
			COALESCE(GVP.cod_grado_gravamen, -1) AS cod_grado_gravamen,
			COALESCE(GVP.cod_grado_prioridades, -1) AS cod_grado_prioridades,
			COALESCE(GVP.monto_prioridades, 0) AS monto_prioridades,
			CASE GVP.cod_tipo_acreedor 
				WHEN NULL THEN 2 
				WHEN -1 THEN 2 
				ELSE GVP.cod_tipo_acreedor 
			END AS cod_tipo_acreedor,
			COALESCE(GVP.cedula_acreedor, '') AS cedula_acreedor,
			CONVERT(VARCHAR(10), (COALESCE(GVA.fecha_vencimiento_instrumento,'1900-01-01')), 103) AS fecha_vencimiento_instrumento, 
			COALESCE(GVP.cod_operacion_especial, 0) AS cod_operacion_especial,
			COALESCE(GVA.cod_clasificacion_instrumento, -1) AS cod_clasificacion_instrumento,
			COALESCE(GVA.des_instrumento, '') AS des_instrumento,
			COALESCE(GVA.des_serie_instrumento, '') AS des_serie_instrumento,
			COALESCE(GVA.cod_tipo_emisor, -1) AS cod_tipo_emisor,
			COALESCE(GVA.cedula_emisor, '') AS cedula_emisor,
			COALESCE(GVA.premio, 0) AS premio,
			COALESCE(GVA.cod_isin, '') AS cod_isin,
			COALESCE(GVA.valor_facial, 0) AS valor_facial,
			COALESCE(GVA.cod_moneda_valor_facial, -1) AS cod_moneda_valor_facial,
			COALESCE(GVA.valor_mercado, 0) AS valor_mercado,
			COALESCE(GVA.cod_moneda_valor_mercado, -1) AS cod_moneda_valor_mercado,
			GVA.cod_tipo_garantia,
			GVA.cod_clase_garantia,
			COALESCE(GVA.cod_tenencia, -1) AS cod_tenencia,	
			CONVERT(VARCHAR(10), (COALESCE(GVA.fecha_prescripcion,'1900-01-01')), 103) AS fecha_prescripcion, 
			GVP.cod_garantia_valor,
			GVP.cod_operacion,
			COALESCE(GVA.Usuario_Modifico, '') AS Usuario_Modifico,
			COALESCE (SGU.DES_USUARIO,'') AS Nombre_Usuario_Modifico,
			CONVERT(VARCHAR(10), (COALESCE(GVA.Fecha_Modifico,'1900-01-01')), 103) AS Fecha_Modifico,
			CONVERT(VARCHAR(10), (COALESCE(GVA.Fecha_Inserto,'1900-01-01')), 103) AS Fecha_Inserto,
			CONVERT(VARCHAR(10), (COALESCE(GVA.Fecha_Replica,'1900-01-01')), 103) AS Fecha_Replica,
			COALESCE(GVP.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	GAR_OPERACION GOP 
		INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION  GVP 
		ON GOP.cod_operacion = GVP.cod_operacion 
		INNER JOIN GAR_GARANTIA_VALOR  GVA
		ON GVA.cod_garantia_valor = GVP.cod_garantia_valor 
		LEFT JOIN SEG_USUARIO SGU
			ON SGU.COD_USUARIO  = GVA.Usuario_Modifico COLLATE DATABASE_DEFAULT
		INNER JOIN CAT_ELEMENTO CEL
			ON CEL.cat_campo = GVA.cod_clase_garantia 
	WHERE	GOP.cod_operacion = @piConsecutivo_Operacion
		AND GVA.cod_garantia_valor =  @piConsecutivo_Garantia						
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