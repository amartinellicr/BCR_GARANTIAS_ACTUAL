SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasValor;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasValor] AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasValor</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite generar la información a ser incluida en los archivos SEGUI,
             sobre las garantías de valor.
</Descripción>
<Entradas></Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>05/11/2008</Fecha>
		<Descripción>Se modifica la forma en que se obtienen las garantías de valor de los giros de los contratos.</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>26/03/2009</Fecha>
		<Descripción>Se modifica la forma en que se descartan las garantías duplicadas, esto dentro del cursor.</Descripción>
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

--Se limpian las tablas temporales
/*DROP TABLE #GAR_GIROS_GARANTIAS_VALOR
DROP TABLE #TMP1*/

delete from dbo.GAR_GIROS_GARANTIAS_VALOR

IF OBJECT_ID('tempdb..#TMP_GAR_VALOR') IS NOT NULL
DROP TABLE #TMP_GAR_VALOR

--Se insertan las garantias de valor
insert into dbo.GAR_GIROS_GARANTIAS_VALOR
SELECT DISTINCT 
	a.cod_contabilidad, 
	a.cod_oficina, 
	a.cod_moneda, 
	a.cod_producto, 
	a.num_operacion as operacion, 
	c.numero_seguridad, 
	b.cod_tipo_mitigador, 
	b.cod_tipo_documento_legal, 
	b.monto_mitigador, 
	case when 
		substring(convert(varchar(10),b.fecha_presentacion_registro,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_presentacion_registro,103),4,2) + '/' + 
	             substring(convert(varchar(10),b.fecha_presentacion_registro,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),b.fecha_presentacion_registro,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_presentacion_registro,103),4,2) + '/' + 
	          	substring(convert(varchar(10),b.fecha_presentacion_registro,103),7,4)
	end as fecha_presentacion, 
	b.cod_inscripcion, 
	b.porcentaje_responsabilidad, 
	case when 
		substring(convert(varchar(10),c.fecha_constitucion,103),1,2) + '/' + 
		substring(convert(varchar(10),c.fecha_constitucion,103),4,2) + '/' + 
	           	substring(convert(varchar(10),c.fecha_constitucion,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),c.fecha_constitucion,103),1,2) + '/' + 
		substring(convert(varchar(10),c.fecha_constitucion,103),4,2) + '/' + 
	          	substring(convert(varchar(10),c.fecha_constitucion,103),7,4)
	end as fecha_constitucion, 
	b.cod_grado_gravamen, 
	b.cod_grado_prioridades, 
	b.monto_prioridades, 
	b.cod_tipo_acreedor, 
	b.cedula_acreedor, 
	case when 
		substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),1,2) + '/' + 
		substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),4,2) + '/' + 
	          	substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),1,2) + '/' + 
		substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),4,2) + '/' + 
	          	substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),7,4)
	end as fecha_vencimiento, 
	b.cod_operacion_especial, 
	c.cod_clasificacion_instrumento, 
	c.des_instrumento, 
	c.des_serie_instrumento, 
	c.cod_tipo_emisor, 
	c.cedula_emisor, 
	c.premio, 
	c.cod_isin, 
	c.valor_facial, 
	c.cod_moneda_valor_facial, 
	c.valor_mercado, 
	c.cod_moneda_valor_mercado,
	e.prmgt_pmoresgar as monto_responsabilidad,
	e.prmgt_pco_mongar as cod_moneda_garantia,
	a.cedula_deudor,
	f.nombre_deudor,
	g.bsmpc_dco_ofici as oficina_deudor
/*INTO 
	#GAR_GIROS_GARANTIAS_VALOR*/
FROM 
	GAR_OPERACION a 
	INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION b 
	ON a.cod_operacion = b.cod_operacion 
	INNER JOIN GAR_GARANTIA_VALOR c 
	ON b.cod_garantia_valor = c.cod_garantia_valor 
	INNER JOIN GAR_SICC_PRMOC d
	on a.cod_contabilidad = d.prmoc_pco_conta
	and a.cod_oficina = d.prmoc_pco_ofici
	and a.cod_moneda = d.prmoc_pco_moned
	and a.cod_producto = d.prmoc_pco_produ
	and a.num_operacion = convert(decimal(7),d.prmoc_pnu_oper)
	and a.num_contrato = convert(decimal(7),d.prmoc_pnu_contr)
	INNER JOIN GAR_SICC_PRMGT e
	on d.prmoc_pco_conta = e.prmgt_pco_conta
	and d.prmoc_pco_ofici = e.prmgt_pco_ofici
	and d.prmoc_pco_moned = e.prmgt_pco_moned
	and d.prmoc_pco_produ = e.prmgt_pco_produ
	and d.prmoc_pnu_oper = e.prmgt_pnu_oper
	and c.numero_seguridad = convert(varchar(25),e.prmgt_pnuidegar)
	INNER JOIN GAR_DEUDOR f
	on a.cedula_deudor = f.cedula_deudor
	INNER JOIN GAR_SICC_BSMPC g
	on f.cedula_deudor = convert(varchar(30), g.bsmpc_sco_ident)
	and g.bsmpc_estado = 'A'
WHERE  
	a.num_operacion IS NOT NULL  
	and a.cod_estado = 1 
	and b.cod_estado = 1
	and d.prmoc_pnu_contr = 0
	and d.prmoc_pcoctamay <> 815 
	and d.prmoc_pse_proces = 1 
	and d.prmoc_estado = 'A' 
	and d.prmoc_psa_actual <> 0
	and b.cod_tipo_documento_legal is not null
	and ((c.cod_clase_garantia = 20 and c.cod_tenencia <> 6) or 
	     (c.cod_clase_garantia <> 20 and c.cod_tenencia = 6) or
	     (c.cod_clase_garantia <> 20 and c.cod_tenencia <> 6))


--Se cargan las garantias correspondientes a giros 
IF OBJECT_ID('tempdb..#TGIROSACTIVOS') IS NOT NULL
DROP TABLE #TGIROSACTIVOS

SELECT  cod_contabilidad,
		cod_operacion, 
		cod_oficina, 
		cod_moneda,
		cod_producto, 
		num_operacion, 
		num_contrato,
		fecha_constitucion,
		fecha_vencimiento,
		cedula_deudor

INTO #TGIROSACTIVOS

FROM dbo.GAR_OPERACION 

WHERE 
		num_contrato > 0 
		AND num_operacion IS NOT NULL
		AND cod_estado = 1 


IF OBJECT_ID('tempdb..#TGARGIROSACTIVOS') IS NOT NULL
DROP TABLE #TGARGIROSACTIVOS

	SELECT DISTINCT
		a.cod_contabilidad,
		a.cod_oficina,
		a.cod_moneda,
		a.cod_producto,
		a.num_operacion as operacion,
		c.numero_seguridad, 
		b.cod_tipo_mitigador, 
		case when b.cod_tipo_documento_legal = -1 then NULL 
			 else b.cod_tipo_documento_legal 
		end as cod_tipo_documento_legal,
		b.monto_mitigador, 
		case when 
			substring(convert(varchar(10),b.fecha_presentacion_registro,103),1,2) + '/' + 
			substring(convert(varchar(10),b.fecha_presentacion_registro,103),4,2) + '/' + 
		          	substring(convert(varchar(10),b.fecha_presentacion_registro,103),7,4) = '01/01/1900' then ''
		     else 
			substring(convert(varchar(10),b.fecha_presentacion_registro,103),1,2) + '/' + 
			substring(convert(varchar(10),b.fecha_presentacion_registro,103),4,2) + '/' + 
		          	substring(convert(varchar(10),b.fecha_presentacion_registro,103),7,4)
		end as fecha_presentacion, 
		b.cod_inscripcion, 
		b.porcentaje_responsabilidad, 
		case when 
			substring(convert(varchar(10),c.fecha_constitucion,103),1,2) + '/' + 
			substring(convert(varchar(10),c.fecha_constitucion,103),4,2) + '/' + 
		          	substring(convert(varchar(10),c.fecha_constitucion,103),7,4) = '01/01/1900' then ''
		     else 
			substring(convert(varchar(10),c.fecha_constitucion,103),1,2) + '/' + 
			substring(convert(varchar(10),c.fecha_constitucion,103),4,2) + '/' + 
		          	substring(convert(varchar(10),c.fecha_constitucion,103),7,4)
		end as fecha_constitucion, 
		b.cod_grado_gravamen, 
		b.cod_grado_prioridades, 
		b.monto_prioridades, 
		b.cod_tipo_acreedor, 
		b.cedula_acreedor, 
		case when 
			substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),1,2) + '/' + 
			substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),4,2) + '/' + 
		          	substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),7,4) = '01/01/1900' then ''
		     else 
			substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),1,2) + '/' + 
			substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),4,2) + '/' + 
		          	substring(convert(varchar(10),c.fecha_vencimiento_instrumento,103),7,4)
		end as fecha_vencimiento, 
		b.cod_operacion_especial, 
		c.cod_clasificacion_instrumento, 
		c.des_instrumento, 
		c.des_serie_instrumento, 
		c.cod_tipo_emisor, 
		c.cedula_emisor, 
		c.premio, 
		c.cod_isin, 
		c.valor_facial, 
		c.cod_moneda_valor_facial, 
		c.valor_mercado, 
		c.cod_moneda_valor_mercado,
		e.prmgt_pmoresgar as monto_responsabilidad,
		e.prmgt_pco_mongar as cod_moneda_garantia,
		a.cedula_deudor,
		f.nombre_deudor,
		g.bsmpc_dco_ofici as oficina_deudor
	
	INTO #TGARGIROSACTIVOS	

	FROM 
		#TGIROSACTIVOS a,
		GAR_GARANTIAS_VALOR_X_OPERACION b, 
		GAR_GARANTIA_VALOR c,
		GAR_SICC_PRMCA d,
		GAR_SICC_PRMGT e,
		GAR_DEUDOR f,
		GAR_SICC_BSMPC g
	WHERE 
		a.cod_operacion = b.cod_operacion
		AND b.cod_estado = 1
		AND b.cod_garantia_valor = c.cod_garantia_valor
		and a.num_contrato = convert(decimal(7),e.prmgt_pnu_oper)
		and d.prmca_pnu_contr = e.prmgt_pnu_oper
		and c.numero_seguridad = convert(varchar(25),e.prmgt_pnuidegar)
		and ((c.cod_clase_garantia = 20 and c.cod_tenencia <> 6) or 
		     (c.cod_clase_garantia <> 20 and c.cod_tenencia = 6) or
		     (c.cod_clase_garantia <> 20 and c.cod_tenencia <> 6))
		and a.cedula_deudor = f.cedula_deudor
		and f.cedula_deudor = convert(varchar(30), g.bsmpc_sco_ident)
		and g.bsmpc_estado = 'A'


-- Se insertan las garantías de los giros de los contratos

	INSERT INTO dbo.GAR_GIROS_GARANTIAS_VALOR
	SELECT DISTINCT
		a.cod_contabilidad,
		a.cod_oficina,
		a.cod_moneda,
		a.cod_producto,
		a.operacion,
		a.numero_seguridad, 
		a.cod_tipo_mitigador, 
		a.cod_tipo_documento_legal,
		a.monto_mitigador, 
		a.fecha_presentacion, 
		a.cod_inscripcion, 
		a.porcentaje_responsabilidad, 
		a.fecha_constitucion, 
		a.cod_grado_gravamen, 
		a.cod_grado_prioridades, 
		a.monto_prioridades, 
		a.cod_tipo_acreedor, 
		a.cedula_acreedor, 
		a.fecha_vencimiento, 
		a.cod_operacion_especial, 
		a.cod_clasificacion_instrumento, 
		a.des_instrumento, 
		a.des_serie_instrumento, 
		a.cod_tipo_emisor, 
		a.cedula_emisor, 
		a.premio, 
		a.cod_isin, 
		a.valor_facial, 
		a.cod_moneda_valor_facial, 
		a.valor_mercado, 
		a.cod_moneda_valor_mercado,
		a.monto_responsabilidad,
		a.cod_moneda_garantia,
		a.cedula_deudor,
		a.nombre_deudor,
		a.oficina_deudor

	FROM 
		#TGARGIROSACTIVOS a INNER JOIN
		GAR_GIROS_GARANTIAS_VALOR b 
		ON   a.operacion <> b.operacion
		AND a.numero_seguridad <> b.numero_seguridad



IF OBJECT_ID('tempdb..#TGARGIROSACTIVOS') IS NOT NULL
DROP TABLE #TGARGIROSACTIVOS


SELECT *, 1 as cod_estado
INTO #TMP_GAR_VALOR
FROM dbo.GAR_GIROS_GARANTIAS_VALOR
WHERE cod_tipo_documento_legal IS NOT NULL -- Esto no estaba antes del 26/03/2009, se filtra para que el cursor dure menos en ejecutarse.

DECLARE 
	@nContabilidadVal tinyint,
	@nOficinaVal smallint,
	@nMonedaVal tinyint,
	@nProductoVal tinyint,
	@nNumOperacionVal decimal(7),
	@strSeguridadVal varchar(25),
	@nTipoDocumentoLegalVal smallint,
	@nNumOperacionAnterior decimal(7),
	@strSeguridadAnterior varchar(25)

DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_contabilidad,
	cod_oficina,	
	cod_moneda,
	cod_producto,
	operacion,
	numero_seguridad,
	cod_tipo_documento_legal
FROM 
	#TMP_GAR_VALOR
ORDER BY
	cod_contabilidad,
	cod_oficina,	
	cod_moneda,
	cod_producto,
	operacion,
	numero_seguridad,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nContabilidadVal,@nOficinaVal,@nMonedaVal,@nProductoVal,@nNumOperacionVal,@strSeguridadVal,@nTipoDocumentoLegalVal

SET @nNumOperacionAnterior = -1
SET @strSeguridadAnterior = ''

--Se cambia @strSeguridadAnterior != @strSeguridadVal por @strSeguridadAnterior = @strSeguridadVal
WHILE @@FETCH_STATUS = 0 BEGIN
	IF ((@nNumOperacionAnterior = @nNumOperacionVal) AND (@strSeguridadAnterior = @strSeguridadVal)) BEGIN
		UPDATE #TMP_GAR_VALOR
		SET cod_estado = 2
		WHERE cod_contabilidad = @nContabilidadVal
		AND cod_oficina = @nOficinaVal
		AND cod_moneda = @nMonedaVal
		AND cod_producto = @nProductoVal
		AND operacion = @nNumOperacionVal
		AND numero_seguridad = @strSeguridadVal
		AND cod_tipo_documento_legal = @nTipoDocumentoLegalVal
	END
	
	SET @nNumOperacionAnterior = @nNumOperacionVal
	SET @strSeguridadAnterior = @strSeguridadVal
      
      	FETCH NEXT FROM garantias_cursor INTO @nContabilidadVal,@nOficinaVal,@nMonedaVal,@nProductoVal,@nNumOperacionVal,@strSeguridadVal,@nTipoDocumentoLegalVal
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor

delete dbo.GAR_GIROS_GARANTIAS_VALOR

insert into dbo.GAR_GIROS_GARANTIAS_VALOR
SELECT DISTINCT 
cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, numero_seguridad, 
cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador,  fecha_presentacion, 
cod_inscripcion, porcentaje_responsabilidad, fecha_constitucion, cod_grado_gravamen, 
cod_grado_prioridades, monto_prioridades, cod_tipo_acreedor, cedula_acreedor, 
fecha_vencimiento, cod_operacion_especial, cod_clasificacion_instrumento, des_instrumento, 
des_serie_instrumento, cod_tipo_emisor, cedula_emisor, premio, cod_isin, valor_facial,
cod_moneda_valor_facial, valor_mercado, cod_moneda_valor_mercado, monto_responsabilidad, 
cod_moneda_garantia, cedula_deudor, nombre_deudor, oficina_deudor
FROM #TMP_GAR_VALOR 
WHERE cod_estado = 1

--SELECT * FROM dbo.GAR_GIROS_GARANTIAS_VALOR WHERE cod_tipo_documento_legal is not null
SELECT
cod_contabilidad as CONTABILIDAD, 
cod_oficina as OFICINA, 
cod_moneda as MONEDA, 
cod_producto as PRODUCTO, 
operacion as OPERACION, 
numero_seguridad as NUMERO_SEGURIDAD, 
cod_tipo_mitigador as TIPO_MITIGADOR, 
cod_tipo_documento_legal as TIPO_DOCUMENTO_LEGAL, 
monto_mitigador as MONTO_MITIGADOR,  
fecha_presentacion as FECHA_PRESENTACION, 
cod_inscripcion as INDICADOR_INSCRIPCION, 
porcentaje_responsabilidad as PORCENTAJE_RESPONSABILIDAD, 
fecha_constitucion as FECHA_CONSTITUCION, 
cod_grado_gravamen as GRADO_GRAVAMEN, 
cod_grado_prioridades as GRADO_PRIORIDAD, 
monto_prioridades as MONTO_PRIORIDAD, 
cod_tipo_acreedor as TIPO_PERSONA_ACREEDOR, 
cedula_acreedor as CEDULA_ACREEDOR, 
fecha_vencimiento as FECHA_VENCIMIENTO, 
cod_operacion_especial as OPERACION_ESPECIAL, 
cod_clasificacion_instrumento as CLASIFICACION_INSTRUMENTO,
des_instrumento as INSTRUMENTO, 
des_serie_instrumento as SERIE_INSTRUMENTO, 
cod_tipo_emisor as TIPO_PERSONA_EMISOR, 
cedula_emisor as CEDULA_EMISOR, 
premio as PREMIO, 
cod_isin as ISIN, 
valor_facial as VALOR_FACIAL,
cod_moneda_valor_facial as MONEDA_VALOR_FACIAL, 
valor_mercado as VALOR_MERCADO, 
cod_moneda_valor_mercado as MONEDA_VALOR_MERCADO, 
monto_responsabilidad as MONTO_RESPONSABILIDAD, 
cod_moneda_garantia as MONEDA_GARANTIA, 
cedula_deudor as CEDULA_DEUDOR, 
nombre_deudor as NOMBRE_DEUDOR, 
oficina_deudor as OFICINA_DEUDOR
FROM dbo.GAR_GIROS_GARANTIAS_VALOR 
WHERE cod_tipo_documento_legal is not null


END
