SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGaraReales', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGaraReales;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGaraReales]
AS
BEGIN
/******************************************************************
	<Nombre>pa_GenerarInfoGaraReales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Genera parte de la información de las Garantías Reales.
	</Descripción>
	<Entradas></Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>N/A</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.4</Versión>
	<Historial>
		<Cambio>
			<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>18/06/2008</Fecha>
			<Descripción>
				Se optimizan los cursores utilizados, con el fin de que consuman menos tiempo.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>29/10/2008</Fecha>
			<Descripción>
				Se agrega la programación necesaria para corregir el problema de la asignación de las
				garantías de los contratos a los giros.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>17/11/2010</Fecha>
			<Descripción>
				Se realizan varios ajustes de optimización del proceso.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios de almacenado, búsqueda y extracción de datos, Sibel: 1 - 23923921</Requerimiento>
			<Fecha>01/10/2013</Fecha>
			<Descripción>
				Se ajusta la forma en que se compara la identificación de la garantía entre el SICC y el
				sistema de garantías, se cambia de una comparación numperica a una de texto.
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

SET NOCOUNT ON

--Se limpian las tablas temporales
delete from GAR_GIROS_GARANTIAS_REALES

--Se insertan las garantias reales
insert into GAR_GIROS_GARANTIAS_REALES(
cod_contabilidad,
cod_oficina,
cod_moneda,
cod_producto,
operacion,
cod_tipo_bien,
cod_bien,
cod_tipo_mitigador,
cod_tipo_documento_legal,
monto_mitigador,
fecha_presentacion,
cod_inscripcion,
porcentaje_responsabilidad,
fecha_constitucion,
cod_grado_gravamen,
cod_tipo_acreedor,
cedula_acreedor,
fecha_vencimiento,
cod_operacion_especial,
fecha_valuacion,
cedula_empresa,
cod_tipo_empresa,
cedula_perito,
cod_tipo_perito,
monto_ultima_tasacion_terreno,
monto_ultima_tasacion_no_terreno,
monto_tasacion_actualizada_terreno,
monto_tasacion_actualizada_no_terreno,
fecha_ultimo_seguimiento,
monto_total_avaluo,
fecha_construccion,
cod_grado,
cedula_hipotecaria,
cod_clase_garantia,
cod_operacion,
cod_garantia_real,
cod_tipo_garantia_real,
numero_finca,
num_placa_bien,
cod_clase_bien,
cedula_deudor,
cod_estado)
SELECT DISTINCT 
	a.cod_contabilidad, 
	a.cod_oficina, 
	a.cod_moneda, 
	a.cod_producto, 
	a.num_operacion as operacion, 
	c.cod_tipo_bien, 
	case c.cod_tipo_garantia_real  
		when 1 then convert(varchar(2),c.cod_partido) + c.numero_finca  
		when 2 then convert(varchar(2),c.cod_partido) + c.numero_finca  
		when 3 then ISNULL(c.cod_clase_bien, '') + c.num_placa_bien --RQ: 1-23923921. Se evalúa si el código de la clase de bien es nulo o no. 
	end as cod_bien, 
	b.cod_tipo_mitigador, 
	case cod_tipo_documento_legal 
	WHEN -1 THEN NULL
	ELSE b.cod_tipo_documento_legal 
	END,
	b.monto_mitigador, 
	case when 
		substring(convert(varchar(10),b.fecha_presentacion,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_presentacion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_presentacion,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),b.fecha_presentacion,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_presentacion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_presentacion,103),7,4)
	end as fecha_presentacion,
	b.cod_inscripcion, 
	b.porcentaje_responsabilidad, 
	case when 
		substring(convert(varchar(10),b.fecha_constitucion,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_constitucion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_constitucion,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),b.fecha_constitucion,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_constitucion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_constitucion,103),7,4)
	end as fecha_constitucion, 
	b.cod_grado_gravamen, 
	b.cod_tipo_acreedor, 
	b.cedula_acreedor, 
	case when 
		substring(convert(varchar(10),b.fecha_vencimiento,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_vencimiento,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_vencimiento,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),b.fecha_vencimiento,103),1,2) + '/' + 
		substring(convert(varchar(10),b.fecha_vencimiento,103),4,2) + '/' + 
	        	substring(convert(varchar(10),b.fecha_vencimiento,103),7,4)
	end as fecha_vencimiento, 
	b.cod_operacion_especial, 
	case when 
		substring(convert(varchar(10),d.fecha_valuacion,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_valuacion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_valuacion,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),d.fecha_valuacion,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_valuacion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_valuacion,103),7,4)
	end as fecha_valuacion, 
	d.cedula_empresa, 
	case when d.cedula_empresa is null then null else 2 end as cod_tipo_empresa, 
	d.cedula_perito, 
	e.cod_tipo_persona as cod_tipo_perito, 
	d.monto_ultima_tasacion_terreno, 
	d.monto_ultima_tasacion_no_terreno, 
	d.monto_tasacion_actualizada_terreno, 
	d.monto_tasacion_actualizada_no_terreno, 
	case when 
		substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),7,4)
	end as fecha_ultimo_seguimiento, 
	isnull(d.monto_tasacion_actualizada_terreno,0) + isnull(d.monto_tasacion_actualizada_no_terreno,0) as monto_total_avaluo,
	case when 
		substring(convert(varchar(10),d.fecha_construccion,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_construccion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_construccion,103),7,4) = '01/01/1900' then ''
	     else 
		substring(convert(varchar(10),d.fecha_construccion,103),1,2) + '/' + 
		substring(convert(varchar(10),d.fecha_construccion,103),4,2) + '/' + 
	        	substring(convert(varchar(10),d.fecha_construccion,103),7,4)
	end as fecha_construccion,
	CASE c.cod_grado
	WHEN -1 THEN NULL
	ELSE c.cod_grado
	END,
		
	c.cedula_hipotecaria,
	c.cod_clase_garantia,
	a.cod_operacion,
	c.cod_garantia_real,
	c.cod_tipo_garantia_real,
	isnull(c.numero_finca,'') as numero_finca,
	isnull(c.num_placa_bien,'') as num_placa_bien,
	isnull(c.cod_clase_bien,'') as cod_clase_bien,
	a.cedula_deudor,
--	null as cod_estado
	1 as cod_estado -- AMM 01/11/2008

FROM GAR_OPERACION a INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION b 	ON a.cod_operacion = b.cod_operacion 
INNER JOIN GAR_GARANTIA_REAL c 	ON b.cod_garantia_real = c.cod_garantia_real 
LEFT OUTER JOIN GAR_VALUACIONES_REALES d ON c.cod_garantia_real = d.cod_garantia_real 
	AND d.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_REALES WHERE cod_garantia_real = c.cod_garantia_real) 
LEFT OUTER JOIN GAR_PERITO e ON d.cedula_perito = e.cedula_perito 
WHERE a.num_operacion IS NOT NULL 
AND a.cod_estado = 1 
AND b.cod_estado = 1
 
AND EXISTS(
	SELECT 1
	FROM GAR_SICC_PRMOC d
	WHERE d.prmoc_pnu_oper = CONVERT(INT, a.num_operacion)
	and d.prmoc_pco_ofici =CONVERT(SMALLINT, a.cod_oficina)
	and d.prmoc_pco_moned = CONVERT(TINYINT, a.cod_moneda )
	--and d.prmoc_pco_produ = CONVERT(TINYINT, a.cod_producto )
	and d.prmoc_pco_conta = CONVERT(TINYINT, a.cod_contabilidad)
	AND d.prmoc_pnu_contr = a.num_contrato
	and d.prmoc_pcoctamay <> 815 
	and d.prmoc_pse_proces = 1 
	and d.prmoc_estado = 'A' 
	and d.prmoc_psa_actual <> 0)

/*

FROM 
	GAR_OPERACION a 
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION b 
	ON a.cod_operacion = b.cod_operacion 
	INNER JOIN GAR_GARANTIA_REAL c 
	ON b.cod_garantia_real = c.cod_garantia_real 
	LEFT OUTER JOIN GAR_VALUACIONES_REALES d 
	ON c.cod_garantia_real = d.cod_garantia_real 
	AND d.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_REALES WHERE cod_garantia_real = c.cod_garantia_real) 
	LEFT OUTER JOIN GAR_PERITO e 
	ON d.cedula_perito = e.cedula_perito 
	INNER JOIN GAR_SICC_PRMOC f
	on a.cod_contabilidad = f.prmoc_pco_conta
--	and a.cod_oficina = f.prmoc_pco_ofici 
	and a.cod_oficon = f.prmoc_pco_oficon -- AMM 01/11/2008
	and a.cod_moneda = f.prmoc_pco_moned
--	and a.cod_producto = f.prmoc_pco_produ -- AMM 01/11/2008
	and a.num_operacion = convert(decimal(7),f.prmoc_pnu_oper)
	and a.num_contrato = convert(decimal(7),f.prmoc_pnu_contr)
WHERE  
	a.num_operacion IS NOT NULL  
	and a.cod_estado = 1 AND b.cod_estado = 1
	and f.prmoc_pcoctamay <> 815 
	and f.prmoc_pse_proces = 1 
	and f.prmoc_estado = 'A' 
	and f.prmoc_psa_actual <> 0 
*/
/*
SELECT 
cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, cod_bien,
cod_tipo_mitigador, case when cod_tipo_documento_legal is null then -1 else cod_tipo_documento_legal end as cod_tipo_documento_legal, 
monto_mitigador, fecha_presentacion, cod_inscripcion, 
porcentaje_responsabilidad, fecha_constitucion, cod_grado_gravamen, cod_tipo_acreedor, cedula_acreedor,
fecha_vencimiento, cod_operacion_especial, fecha_valuacion, cedula_empresa, cod_tipo_empresa, cedula_perito,
cod_tipo_perito, monto_ultima_tasacion_terreno, monto_ultima_tasacion_no_terreno, monto_tasacion_actualizada_terreno, 
monto_tasacion_actualizada_no_terreno, fecha_ultimo_seguimiento, monto_total_avaluo, fecha_construccion, 
case when cod_grado is null then -1 else cod_grado end as cod_grado, cedula_hipotecaria, cod_clase_garantia, 
cod_operacion, cod_garantia_real, cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, cedula_deudor, 1 as cod_estado
INTO #TMP
FROM GAR_GIROS_GARANTIAS_REALES
*/

------------------------------------------------------------------------------------------
DECLARE 
	@nOperacion2 bigint,
	@nGarantia bigint,
	@nTipoGarantiaReal tinyint,
	@strFinca varchar(25),
	@strGrado varchar(2),
	@strPlacaBien varchar(25),
	@nTipoDocumentoLegal smallint,
	@strFincaAnterior varchar(25),
	@strGradoAnterior varchar(2),
	@strPlacaBienAnterior varchar(25),
	@nOperacionAnterior bigint,
	@lid UNIQUEIDENTIFIER


DECLARE garantias_cursor CURSOR	FAST_FORWARD
FOR 
SELECT 
	cod_operacion,
	cod_garantia_real,
	cod_tipo_garantia_real,
	numero_finca,
	cod_grado,
	num_placa_bien,
	cod_tipo_documento_legal,
	cod_llave
FROM GAR_GIROS_GARANTIAS_REALES

ORDER BY
	cod_operacion,
	numero_finca,
	cod_grado,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, @strFinca, 
	@strGrado, @strPlacaBien, @nTipoDocumentoLegal, @lid

SET @strFincaAnterior = ''
SET @strGradoAnterior = ''
SET @strPlacaBienAnterior = ''
SET @nOperacionAnterior = -1


WHILE @@FETCH_STATUS = 0 
BEGIN
		--Hipotecas
		IF (@nTipoGarantiaReal = 1) BEGIN
			IF (@nOperacionAnterior = @nOperacion2) 
			BEGIN
				IF (@strFincaAnterior = @strFinca) 
				BEGIN
					
					UPDATE GAR_GIROS_GARANTIAS_REALES SET cod_estado = 2
					WHERE cod_llave = @lid
				END
			END
		END
				
		SET @strFincaAnterior = @strFinca
		SET @strGradoAnterior = @strGrado
		SET @strPlacaBienAnterior = @strPlacaBien
		SET @nOperacionAnterior = @nOperacion2
	      
	    FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, 
		@strFinca, @strGrado, @strPlacaBien, @nTipoDocumentoLegal, @lid
END


CLOSE garantias_cursor
DEALLOCATE garantias_cursor

/*
delete from GAR_GIROS_GARANTIAS_REALES

insert into GAR_GIROS_GARANTIAS_REALES(
cod_contabilidad,
cod_oficina,
cod_moneda,
cod_producto,
operacion,
cod_tipo_bien,
cod_bien,
cod_tipo_mitigador,
cod_tipo_documento_legal,
monto_mitigador,
fecha_presentacion,
cod_inscripcion,
porcentaje_responsabilidad,
fecha_constitucion,
cod_grado_gravamen,
cod_tipo_acreedor,
cedula_acreedor,
fecha_vencimiento,
cod_operacion_especial,
fecha_valuacion,
cedula_empresa,
cod_tipo_empresa,
cedula_perito,
cod_tipo_perito,
monto_ultima_tasacion_terreno,
monto_ultima_tasacion_no_terreno,
monto_tasacion_actualizada_terreno,
monto_tasacion_actualizada_no_terreno,
fecha_ultimo_seguimiento,
monto_total_avaluo,
fecha_construccion,
cod_grado,
cedula_hipotecaria,
cod_clase_garantia,
cod_operacion,
cod_garantia_real,
cod_tipo_garantia_real,
numero_finca,
num_placa_bien,
cod_clase_bien,
cedula_deudor,
cod_estado)
select 
cod_contabilidad,
cod_oficina,
cod_moneda,
cod_producto,
operacion,
cod_tipo_bien,
cod_bien,
cod_tipo_mitigador,
cod_tipo_documento_legal,
monto_mitigador,
fecha_presentacion,
cod_inscripcion,
porcentaje_responsabilidad,
fecha_constitucion,
cod_grado_gravamen,
cod_tipo_acreedor,
cedula_acreedor,
fecha_vencimiento,
cod_operacion_especial,
fecha_valuacion,
cedula_empresa,
cod_tipo_empresa,
cedula_perito,
cod_tipo_perito,
monto_ultima_tasacion_terreno,
monto_ultima_tasacion_no_terreno,
monto_tasacion_actualizada_terreno,
monto_tasacion_actualizada_no_terreno,
fecha_ultimo_seguimiento,
monto_total_avaluo,
fecha_construccion,
cod_grado,
cedula_hipotecaria,
cod_clase_garantia,
cod_operacion,
cod_garantia_real,
cod_tipo_garantia_real,
numero_finca,
num_placa_bien,
cod_clase_bien,
cedula_deudor,
cod_estado
from #TMP
*/

END

