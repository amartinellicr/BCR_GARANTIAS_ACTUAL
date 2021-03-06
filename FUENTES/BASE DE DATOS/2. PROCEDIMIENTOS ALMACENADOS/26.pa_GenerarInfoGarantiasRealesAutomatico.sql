SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasRealesAutomatico', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasRealesAutomatico;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasRealesAutomatico] AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasRealesAutomatico</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite generar la información a ser incluida en los archivos SEGUI, 
             sobre las garantías reales. 
</Descripción>
<Entradas></Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli M., Lidersoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>29/10/2008</Fecha>
		<Descripción>Se agrega la programación necesaria para corregir el problema de la asignación de las
                     garantías de los contratos a los giros.
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
	
	SET NOCOUNT ON;

	
--Se limpian las tablas temporales
delete from GAR_GIROS_GARANTIAS_REALES

IF OBJECT_ID('tempdb..#TMP') IS NOT NULL
DROP TABLE #TMP

--Se insertan las garantias reales
insert into GAR_GIROS_GARANTIAS_REALES
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
		when 3 then c.cod_clase_bien + c.num_placa_bien 
	end as cod_bien, 
	b.cod_tipo_mitigador, 
	b.cod_tipo_documento_legal, 
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
	c.cod_grado,
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
	1 as cod_estado, -- AMM 01/11/2008
	newid()

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


--Se cargan las garantias correspondientes a giros 
--DECLARE @nContabilidad tinyint, 
--	@nOficina smallint,
--	@nMoneda tinyint,
--	@nProducto tinyint,
--	@nOperacion decimal(7),
--	@nContrato decimal(7)
--
--DECLARE contratos_cursor CURSOR FOR
--
--	SELECT DISTINCT  
--		a.cod_contabilidad, 
--		a.cod_oficina, 
--		a.cod_moneda, 
--		a.cod_producto, 
--		a.num_operacion, 
--		a.num_contrato
--	FROM 
--		gar_operacion a
--		inner join gar_garantias_reales_x_operacion b
--		on a.cod_operacion = b.cod_operacion
--	WHERE 
--		a.num_operacion IS NOT NULL -- AMM 04/11/2008
--		and a.num_operacion > 0 
--		and a.num_contrato > 0
--		and a.cod_estado = 1
--
--OPEN contratos_cursor
--
--FETCH NEXT FROM contratos_cursor 
--INTO @nContabilidad, @nOficina, @nMoneda, @nProducto, @nOperacion, @nContrato
--
--WHILE @@FETCH_STATUS = 0
--BEGIN
--	--Garantias Reales de Giros
--	INSERT INTO GAR_GIROS_GARANTIAS_REALES
--	SELECT DISTINCT
--		a.cod_contabilidad,
--		a.cod_oficina,
--		a.cod_moneda,
--		@nProducto as cod_producto,
--		@nOperacion as num_operacion,
--		c.cod_tipo_bien,
--		case c.cod_tipo_garantia_real  
--			when 1 then convert(varchar(2),c.cod_partido) + c.numero_finca  
--			when 2 then convert(varchar(2),c.cod_partido) + c.numero_finca  
--			when 3 then c.cod_clase_bien + c.num_placa_bien 
--		end as cod_bien, 
--		b.cod_tipo_mitigador, 
--		b.cod_tipo_documento_legal, 
--		b.monto_mitigador, 
--		case when 
--			substring(convert(varchar(10),b.fecha_presentacion,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_presentacion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_presentacion,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),b.fecha_presentacion,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_presentacion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_presentacion,103),7,4)
--		end as fecha_presentacion,
--		b.cod_inscripcion, 
--		b.porcentaje_responsabilidad, 
--		case when 
--			substring(convert(varchar(10),b.fecha_constitucion,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_constitucion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_constitucion,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),b.fecha_constitucion,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_constitucion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_constitucion,103),7,4)
--		end as fecha_constitucion, 
--		b.cod_grado_gravamen, 
--		b.cod_tipo_acreedor, 
--		b.cedula_acreedor, 
--		case when 
--			substring(convert(varchar(10),b.fecha_vencimiento,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_vencimiento,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_vencimiento,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),b.fecha_vencimiento,103),1,2) + '/' + 
--			substring(convert(varchar(10),b.fecha_vencimiento,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),b.fecha_vencimiento,103),7,4)
--		end as fecha_vencimiento, 
--		b.cod_operacion_especial, 
--		case when 
--			substring(convert(varchar(10),d.fecha_valuacion,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_valuacion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),d.fecha_valuacion,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),d.fecha_valuacion,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_valuacion,103),4,2) + '/' + 
--		        	substring(convert(varchar(10),d.fecha_valuacion,103),7,4)
--		end as fecha_valuacion, 
--		d.cedula_empresa, 
--		case when d.cedula_empresa is null then null else 2 end as cod_tipo_empresa, 
--		d.cedula_perito, 
--		e.cod_tipo_persona as cod_tipo_perito, 
--		d.monto_ultima_tasacion_terreno, 
--		d.monto_ultima_tasacion_no_terreno, 
--		d.monto_tasacion_actualizada_terreno, 
--		d.monto_tasacion_actualizada_no_terreno, 
--		case when 
--			substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),4,2) + '/' + 
--		      	substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),4,2) + '/' + 
--		     	   substring(convert(varchar(10),d.fecha_ultimo_seguimiento,103),7,4)
--		end as fecha_ultimo_seguimiento, 
--		isnull(d.monto_tasacion_actualizada_terreno,0) + isnull(d.monto_tasacion_actualizada_no_terreno,0) as monto_total_avaluo,
--		case when 
--			substring(convert(varchar(10),d.fecha_construccion,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_construccion,103),4,2) + '/' + 
--		     	substring(convert(varchar(10),d.fecha_construccion,103),7,4) = '01/01/1900' then ''
--		     else 
--			substring(convert(varchar(10),d.fecha_construccion,103),1,2) + '/' + 
--			substring(convert(varchar(10),d.fecha_construccion,103),4,2) + '/' + 
--		       	substring(convert(varchar(10),d.fecha_construccion,103),7,4)
--		end as fecha_construccion,
--		c.cod_grado,
--		c.cedula_hipotecaria,
--		c.cod_clase_garantia,
--		a.cod_operacion,
--		c.cod_garantia_real,
--		c.cod_tipo_garantia_real,
--		isnull(c.numero_finca,'') as numero_finca,
--		isnull(c.num_placa_bien,'') as num_placa_bien,
--		isnull(c.cod_clase_bien,'') as cod_clase_bien,
--		a.cedula_deudor,
----		null as cod_estado
--		1 as cod_estado -- AMM 01/11/2008
--
--	FROM 
--		GAR_OPERACION a,
--		GAR_GARANTIAS_REALES_X_OPERACION b, 
--		GAR_GARANTIA_REAL c
--		LEFT OUTER JOIN GAR_VALUACIONES_REALES d
--		ON c.cod_garantia_real = d.cod_garantia_real
--		AND d.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_REALES WHERE cod_garantia_real = c.cod_garantia_real)
--		LEFT OUTER JOIN GAR_PERITO e
--		ON d.cedula_perito = e.cedula_perito
--	WHERE 
--		a.cod_contabilidad = @nContabilidad
--		AND a.cod_oficina = @nOficina
--		AND a.cod_moneda = @nMoneda
--		AND a.num_operacion is null
--		AND a.num_contrato = @nContrato
--		AND a.cod_estado = 1
--		AND a.cod_operacion = b.cod_operacion
--		AND b.cod_estado = 1
--		AND b.cod_garantia_real = c.cod_garantia_real
--
--	FETCH NEXT FROM contratos_cursor 
--	INTO @nContabilidad, @nOficina, @nMoneda, @nProducto, @nOperacion, @nContrato
--END
--
--CLOSE contratos_cursor
--DEALLOCATE contratos_cursor
/*hasta aca llega pa_GenerarInfoGaraReales*/

/*de aqui en adelante va pa_GenerarInfoGarantiasReales*/

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
	@nOperacionAnterior bigint

DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_operacion,
	cod_garantia_real,
	cod_tipo_garantia_real,
	numero_finca,
	cod_grado,
	num_placa_bien,
	cod_tipo_documento_legal
FROM 
	#TMP 
ORDER BY
	cod_operacion,
	numero_finca,
	cod_grado,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, @strFinca, @strGrado, @strPlacaBien, @nTipoDocumentoLegal

SET @strFincaAnterior = ''
SET @strGradoAnterior = ''
SET @strPlacaBienAnterior = ''
SET @nOperacionAnterior = -1

IF (@@CURSOR_ROWS > 1) BEGIN
	WHILE @@FETCH_STATUS = 0 BEGIN
		--Hipotecas
		IF (@nTipoGarantiaReal = 1) BEGIN
			IF (@nOperacionAnterior = @nOperacion2) BEGIN
				IF (@strFincaAnterior = @strFinca) BEGIN
					UPDATE #TMP
					SET cod_estado = 2
					WHERE cod_operacion = @nOperacion2
					AND cod_garantia_real = @nGarantia
					AND numero_finca = @strFinca
				END
			END
		END
				
		SET @strFincaAnterior = @strFinca
		SET @strGradoAnterior = @strGrado
		SET @strPlacaBienAnterior = @strPlacaBien
		SET @nOperacionAnterior = @nOperacion2
	      
	    FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, @strFinca, @strGrado, @strPlacaBien, @nTipoDocumentoLegal
	END
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor

------------------------------------------------------------------------------------------

delete GAR_GIROS_GARANTIAS_REALES

insert into GAR_GIROS_GARANTIAS_REALES
SELECT DISTINCT 
cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_bien, cod_bien,
cod_tipo_mitigador, case when cod_tipo_documento_legal = -1 then null else cod_tipo_documento_legal end as cod_tipo_documento_legal, 
monto_mitigador, fecha_presentacion, cod_inscripcion, 
porcentaje_responsabilidad, fecha_constitucion, cod_grado_gravamen, cod_tipo_acreedor, cedula_acreedor,
fecha_vencimiento, cod_operacion_especial, fecha_valuacion, cedula_empresa, cod_tipo_empresa, cedula_perito,
cod_tipo_perito, monto_ultima_tasacion_terreno, monto_ultima_tasacion_no_terreno, monto_tasacion_actualizada_terreno, 
monto_tasacion_actualizada_no_terreno, fecha_ultimo_seguimiento, monto_total_avaluo, fecha_construccion, 
case when cod_grado = -1 then null else cod_grado end as cod_grado, cedula_hipotecaria, cod_clase_garantia,
cod_operacion, cod_garantia_real, cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien,cedula_deudor, null as cod_estado
FROM ##TMP 
WHERE cod_estado = 1


--select * from #tmp where operacion = 5782528 order by codigo_bien

SELECT 
	a.cod_contabilidad as CONTABILIDAD,
	a.cod_oficina as OFICINA,
	a.cod_moneda as MONEDA,
	a.cod_producto as PRODUCTO,
	a.operacion as OPERACION,
	a.cod_tipo_bien as TIPO_BIEN,
	a.cod_bien as CODIGO_BIEN,
	a.cod_tipo_mitigador as TIPO_MITIGADOR,
	a.cod_tipo_documento_legal as TIPO_DOCUMENTO_LEGAL,
	max(a.monto_mitigador) as MONTO_MITIGADOR,
	a.fecha_presentacion as FECHA_PRESENTACION,
	a.cod_inscripcion as INDICADOR_INSCRIPCION,
	a.porcentaje_responsabilidad as PORCENTAJE_RESPONSABILIDAD,
	a.fecha_constitucion as FECHA_CONSTITUCION,
	a.cod_grado_gravamen as GRADO_GRAVAMEN,
	a.cod_tipo_acreedor as TIPO_PERSONA_ACREEDOR,
	a.cedula_acreedor as CEDULA_ACREEDOR,
	max(a.fecha_vencimiento) as FECHA_VENCIMIENTO,
	a.cod_operacion_especial as OPERACION_ESPECIAL,
	a.fecha_valuacion as FECHA_VALUACION,
	a.cedula_empresa as CEDULA_EMPRESA,
	a.cod_tipo_empresa as TIPO_PERSONA_EMPRESA,
	a.cedula_perito as CEDULA_PERITO,
	a.cod_tipo_perito as TIPO_PERSONA_PERITO,
	a.monto_ultima_tasacion_terreno as MONTO_ULTIMA_TASACION_TERRENO,
	a.monto_ultima_tasacion_no_terreno as MONTO_ULTIMA_TASACION_NO_TERRENO,
	a.monto_tasacion_actualizada_terreno as MONTO_TASACION_ACTUALIZADA_TERRENO,
	a.monto_tasacion_actualizada_no_terreno as MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
	a.fecha_ultimo_seguimiento as FECHA_ULTIMO_SEGUIMIENTO,
	a.monto_total_avaluo as MONTO_TOTAL_AVALUO,
	a.fecha_construccion as FECHA_CONSTRUCCION,
	a.cod_grado as COD_GRADO,
	a.cedula_hipotecaria as CEDULA_HIPOTECARIA,
	a.cedula_deudor as CEDULA_DEUDOR,
	c.nombre_deudor as NOMBRE_DEUDOR,
	b.bsmpc_dco_ofici as OFICINA_DEUDOR,
	a.cod_clase_garantia as TIPO_GARANTIA
FROM 
	GAR_GIROS_GARANTIAS_REALES a 
	INNER JOIN GAR_SICC_BSMPC b
	on a.cedula_deudor = convert(varchar(30), b.bsmpc_sco_ident)
	and b.bsmpc_estado = 'A'
	INNER JOIN GAR_DEUDOR c
	on a.cedula_deudor = c.cedula_deudor
WHERE 
	a.cod_tipo_documento_legal is not null
	--and operacion = 5788023
GROUP BY
	a.cod_contabilidad, 
	a.cod_oficina, 
	a.cod_moneda, 
	a.cod_producto, 
	a.operacion, 
	a.cod_tipo_bien, 
	a.cod_bien,
	a.cod_tipo_mitigador, 
	a.cod_tipo_documento_legal, 
	a.fecha_presentacion, 
	a.cod_inscripcion, 
	a.porcentaje_responsabilidad, 
	a.fecha_constitucion, 
	a.cod_grado_gravamen, 
	a.cod_tipo_acreedor, 
	a.cedula_acreedor,
	a.cod_operacion_especial, 
	a.fecha_valuacion, 
	a.cedula_empresa, 
	a.cod_tipo_empresa, 
	a.cedula_perito,
	a.cod_tipo_perito, 
	a.monto_ultima_tasacion_terreno, 
	a.monto_ultima_tasacion_no_terreno, 
	a.monto_tasacion_actualizada_terreno, 
	a.monto_tasacion_actualizada_no_terreno, 
	a.fecha_ultimo_seguimiento, 
	a.monto_total_avaluo, 
	a.fecha_construccion, 
	a.cod_grado, 
	a.cedula_hipotecaria, 
	a.cedula_deudor, 
	c.nombre_deudor,
	b.bsmpc_dco_ofici,
	a.cod_clase_garantia 

    
END


