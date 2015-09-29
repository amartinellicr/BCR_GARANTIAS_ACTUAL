USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasFiduciarias', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasFiduciarias;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasFiduciarias] 
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasFiduciarias</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite generar la información a ser incluida en los archivos 
             SEGUI, sobre las garantías fiduciarias.
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
		<Requerimiento></Requerimiento>
		<Fecha>08/04/2008</Fecha>
		<Descripción>Permite obtener la información necesaria para generar el archivo SEGUI, se agrega el 
                     filtrado de las tarjetas que poseen garantías fiduciarias y cuyo estado sea diferente a 
                     los suministrados en el parámetro de entrada.
        </Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>04/11/2008</Fecha>
		<Descripción>Se modifica la forma en que se obtienen las garantías fiduciarias de los giros de los 
                     contratos.
		</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>24/03/2009</Fecha>
		<Descripción>Se modifica el uso de tablas temporales globales por tablas temporales locales.</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>17/11/2010</Fecha>
		<Descripción>Se realizan varios ajustes de optimización del proceso.</Descripción>
	</Cambio>
	<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>28/09/2015</Fecha>
			<Descripción>
				Se realiza una optimización general, en donde se crean índices en estructuras y tablas nuevas. 
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
/*IF OBJECT_ID('tempdb..##GAR_GIROS_GARANTIAS_FIDUCIARIAS') IS NOT NULL
DROP TABLE ##GAR_GIROS_GARANTIAS_FIDUCIARIAS*/

DELETE FROM dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS

IF OBJECT_ID('tempdb..#TMP_GARANTIA_FIDUCIARIA') IS NOT NULL
DROP TABLE #TMP_GARANTIA_FIDUCIARIA

/*declare @FiltroTarjeta varchar(100)
set @FiltroTarjeta = 'L,V,H'*/
IF OBJECT_ID('tempdb..#TMP_AUTO_ESTADIST') IS NOT NULL
DROP TABLE #TMP_AUTO_ESTADIST

	--Se eliminan las estidísticas
	DECLARE	@vsTabla VARCHAR(MAX),
			@vsEstadistica VARCHAR(MAX),
			@vsSentencia NVARCHAR(MAX),
			@vsSentenciaBorrado VARCHAR(MAX),
			@vsSentenciaActualizacion VARCHAR(MAX)

	DECLARE Eliminar_Estadisticas CURSOR FOR

	-- Guardo en el Cursor --
	SELECT	OBJECT_SCHEMA_NAME(SST.object_id) + '.' + OBJECT_NAME(SST.object_id) AS 'Table', 
	SST.name AS 'Stat'
	FROM	sys.stats SST WITH (NOLOCK)
	JOIN sys.stats_columns AS SSC (NOLOCK)
	ON SST.stats_id = SSC.stats_id AND
	SST.object_id = SSC.object_id
	WHERE	STATS_DATE(SST.object_id, SST.stats_id) IS NULL 
	AND  OBJECT_SCHEMA_NAME(SST.object_id) + '.' + OBJECT_NAME(SST.object_id) NOT LIKE 'sys%' 
	AND  SST.name LIKE '_WA%'
	ORDER BY OBJECT_SCHEMA_NAME(SST.object_id) + '.' + OBJECT_NAME(SST.object_id)

	OPEN Eliminar_Estadisticas

	FETCH NEXT FROM Eliminar_Estadisticas
	INTO
	@vsTabla,
	@vsEstadistica

	WHILE @@FETCH_STATUS = 0
	BEGIN
			SET @vsSentencia = 'DROP STATISTICS ' + @vsTabla + '.' + @vsEstadistica
			EXEC sp_executesql @vsSentencia

			FETCH NEXT FROM Eliminar_Estadisticas
			INTO @vsTabla, @vsEstadistica
	END
               

	CLOSE Eliminar_Estadisticas

	DEALLOCATE Eliminar_Estadisticas
	
	
	SELECT	ST1.object_id, 
			ST1.stats_id,
			ST1.name,
			SC1.column_id,
			ST1.auto_created
	INTO	#TMP_AUTO_ESTADIST
	FROM	sys.stats AS ST1 WITH (NOLOCK)
		LEFT JOIN sys.stats_columns AS SC1
		ON  ST1.object_id = SC1.object_id
		AND ST1.stats_id = SC1.stats_id
	WHERE	ST1.auto_created = 1 
		AND SC1.stats_column_id = 1


	DECLARE Eliminar_Estadisticas_2 CURSOR FOR
	

	SELECT	'DROP STATISTICS [' + OBJECT_SCHEMA_NAME(sys.stats.object_id)+ '].[' + OBJECT_NAME(sys.stats.object_id) + '].['+ #TMP_AUTO_ESTADIST.name + ']' AS Sentencia
	FROM    sys.stats WITH (NOLOCK)
		INNER JOIN sys.stats_columns 
		ON sys.stats.object_id = sys.stats_columns.object_id 
		AND sys.stats.stats_id = sys.stats_columns.stats_id
		INNER JOIN #TMP_AUTO_ESTADIST ON
		sys.stats_columns.object_id = #TMP_AUTO_ESTADIST.object_id 
		AND	sys.stats_columns.column_id = #TMP_AUTO_ESTADIST.column_id				
		INNER JOIN sys.columns 
		ON sys.stats.object_id = sys.columns.object_id 
		AND sys.stats_columns.column_id = sys.columns.column_id			
		WHERE sys.stats.auto_created = 0 
			AND sys.stats_columns.stats_column_id = 1 
			AND sys.stats_columns.stats_id <> #TMP_AUTO_ESTADIST.stats_id 
			AND OBJECTPROPERTY(sys.stats.object_id, 'IsMsShipped') = 0

	OPEN Eliminar_Estadisticas_2

	FETCH NEXT FROM Eliminar_Estadisticas_2
	INTO @vsSentenciaBorrado
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @vsSentencia = @vsSentenciaBorrado
			EXEC sp_executesql @vsSentencia
			FETCH NEXT FROM Eliminar_Estadisticas_2
			INTO @vsSentenciaBorrado
		  END
	                      
	CLOSE Eliminar_Estadisticas_2

	DEALLOCATE Eliminar_Estadisticas_2
	 
 
	--Se actualizan las estadísticas
	SET @vsSentenciaActualizacion = ' WITH FULLSCAN'

	DECLARE ACTUALIZACION_ESTAD CURSOR FOR

	SELECT	DISTINCT
			OBJECT_SCHEMA_NAME(ST2.object_id) + '.' + OBJECT_NAME(ST2.object_id) AS 'Table'
	FROM	sys.stats ST2 WITH (NOLOCK)
		JOIN sys.stats_columns AS SC2 (NOLOCK)
		ON ST2.stats_id = SC2.stats_id AND
		ST2.object_id = SC2.object_id  
	WHERE	STATS_DATE(ST2.object_id, ST2.stats_id) IS NOT NULL 
		AND DATEDIFF(DAY, STATS_DATE(ST2.object_id, ST2.stats_id), GETDATE()) > 6 
		AND  OBJECT_SCHEMA_NAME(ST2.object_id) + '.' + OBJECT_NAME(ST2.object_id) NOT LIKE 'sys%' 
	ORDER BY OBJECT_SCHEMA_NAME(ST2.object_id) + '.' + OBJECT_NAME(ST2.object_id)


	OPEN ACTUALIZACION_ESTAD

	FETCH NEXT FROM ACTUALIZACION_ESTAD
    INTO @vsTabla
    WHILE @@FETCH_STATUS = 0
		BEGIN
			 SET @vsSentencia = N'UPDATE STATISTICS ' + @vsTabla +@vsSentenciaActualizacion
			 EXEC sp_executesql @vsSentencia
		           
			 FETCH NEXT FROM ACTUALIZACION_ESTAD
			 INTO @vsTabla
		END
         
    CLOSE ACTUALIZACION_ESTAD

    DEALLOCATE ACTUALIZACION_ESTAD
  

--Se insertan las garantias fiduciarias
INSERT INTO dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
SELECT DISTINCT
	a.cod_contabilidad, 
	a.cod_oficina, 
	a.cod_moneda, 
	a.cod_producto, 
	a.num_operacion as operacion, 
	c.cedula_fiador, 
	c.cod_tipo_fiador,
	null as fecha_valuacion,
	0 as ingreso_neto,
	0 as cod_tipo_mitigador, 
	b.cod_tipo_documento_legal, 
	0 as monto_mitigador, 
	b.porcentaje_responsabilidad, 
	b.cod_tipo_acreedor, 
	b.cedula_acreedor, 
	b.cod_operacion_especial,
	c.nombre_fiador,
	a.cedula_deudor,
	e.nombre_deudor,
	f.bsmpc_dco_ofici as oficina_deudor,
	null as cod_estado_tarjeta
/*INTO 
	GAR_GIROS_GARANTIAS_FIDUCIARIAS*/
FROM 
	GAR_OPERACION a 
	INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b 
	ON a.cod_operacion = b.cod_operacion 
	INNER JOIN GAR_GARANTIA_FIDUCIARIA c 
	ON b.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria 
	INNER JOIN GAR_DEUDOR e on a.cedula_deudor = e.cedula_deudor
	INNER JOIN GAR_SICC_BSMPC f on f.bsmpc_sco_ident = CONVERT(DECIMAL, e.cedula_deudor)
	
WHERE a.cod_estado = 1 
	AND b.cod_estado = 1
	AND f.bsmpc_estado = 'A'
AND EXISTS(
	SELECT 1
	FROM GAR_SICC_PRMOC d
	WHERE d.prmoc_pnu_oper = CONVERT(INT, a.num_operacion)
	and d.prmoc_pco_ofici =CONVERT(SMALLINT, a.cod_oficina)
	and d.prmoc_pco_moned = CONVERT(TINYINT, a.cod_moneda )
	and d.prmoc_pco_produ = CONVERT(TINYINT, a.cod_producto )
	and d.prmoc_pco_conta = CONVERT(TINYINT, a.cod_contabilidad)
	AND d.prmoc_pnu_contr = 0
	and d.prmoc_pcoctamay <> 815 
	and d.prmoc_pse_proces = 1 
	and d.prmoc_estado = 'A' 
	and d.prmoc_psa_actual <> 0
	)
	

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
		c.cedula_fiador,
		c.cod_tipo_fiador,
		0 as ingreso_neto,
		b.cod_tipo_mitigador,
		b.cod_tipo_documento_legal,
		b.monto_mitigador,
		b.porcentaje_responsabilidad,
		b.cod_tipo_acreedor,
		b.cedula_acreedor,
		b.cod_operacion_especial,
		c.nombre_fiador,
		a.cedula_deudor,
		d.nombre_deudor,
		e.bsmpc_dco_ofici as oficina_deudor

	INTO #TGARGIROSACTIVOS	

	FROM #TGIROSACTIVOS a
	INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b ON b.cod_operacion = a.cod_operacion
	INNER JOIN GAR_GARANTIA_FIDUCIARIA c ON c.cod_garantia_fiduciaria = b.cod_garantia_fiduciaria
	INNER JOIN GAR_DEUDOR d ON d.cedula_deudor = a.cedula_deudor
	INNER JOIN GAR_SICC_BSMPC e ON e.bsmpc_sco_ident = CONVERT(DECIMAL, d.cedula_deudor)
	WHERE b.cod_estado = 1
	AND e.bsmpc_estado = 'A'


-- Se insertan las garantías de los giros de los contratos

	INSERT INTO dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
	SELECT DISTINCT
		a.cod_contabilidad,
		a.cod_oficina,
		a.cod_moneda,
		a.cod_producto,
		a.operacion,
		a.cedula_fiador,
		a.cod_tipo_fiador,
		'' as fecha_valuacion,
		a.ingreso_neto,
		a.cod_tipo_mitigador,
		a.cod_tipo_documento_legal,
		a.monto_mitigador,
		a.porcentaje_responsabilidad,
		a.cod_tipo_acreedor,
		a.cedula_acreedor,
		a.cod_operacion_especial,
		a.nombre_fiador,
		a.cedula_deudor,
		a.nombre_deudor,
		a.oficina_deudor,
		'' as cod_estado_tarjeta

	FROM #TGARGIROSACTIVOS a 
	INNER JOIN GAR_GIROS_GARANTIAS_FIDUCIARIAS b ON a.operacion <> b.operacion
	AND a.cedula_fiador <> b.cedula_fiador


SELECT *, 1 as cod_estado
INTO #TMP_GARANTIA_FIDUCIARIA
FROM dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS

DECLARE 
	@nContabilidadVal tinyint,
	@nOficinaVal smallint,
	@nMonedaVal tinyint,
	@nProductoVal tinyint,
	@nNumOperacionVal decimal(7),
	@strCedulaVal varchar(30),
	@nTipoDocumentoLegalVal smallint,
	@nNumOperacionAnterior decimal(7),
	@strCedulaAnterior bigint


DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_contabilidad,
	cod_oficina,	
	cod_moneda,
	cod_producto,
	operacion,
	cedula_fiador,
	cod_tipo_documento_legal
FROM 
	#TMP_GARANTIA_FIDUCIARIA
ORDER BY
	cod_contabilidad,
	cod_oficina,	
	cod_moneda,
	cod_producto,
	operacion,
	cedula_fiador,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nContabilidadVal,@nOficinaVal,@nMonedaVal,@nProductoVal,@nNumOperacionVal,@strCedulaVal,@nTipoDocumentoLegalVal

SET @nNumOperacionAnterior = -1
SET @strCedulaAnterior = ''

WHILE @@FETCH_STATUS = 0 BEGIN
	IF ((@nNumOperacionAnterior = @nNumOperacionVal) AND (@strCedulaAnterior != @strCedulaVal)) BEGIN
		UPDATE #TMP_GARANTIA_FIDUCIARIA
		SET cod_estado = 2
		WHERE cod_contabilidad = @nContabilidadVal
		AND cod_oficina = @nOficinaVal
		AND cod_moneda = @nMonedaVal
		AND cod_producto = @nProductoVal
		AND operacion = @nNumOperacionVal
		AND cedula_fiador = @strCedulaVal
		AND cod_tipo_documento_legal = @nTipoDocumentoLegalVal
	END
	
	SET @nNumOperacionAnterior = @nNumOperacionVal
	SET @strCedulaAnterior = @strCedulaVal
      
    FETCH NEXT FROM garantias_cursor INTO @nContabilidadVal,@nOficinaVal,@nMonedaVal,@nProductoVal,@nNumOperacionVal,@strCedulaVal,@nTipoDocumentoLegalVal
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor

delete dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS

insert into dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
SELECT DISTINCT 
cod_contabilidad, cod_oficina, cod_moneda, cod_producto, operacion, cedula_fiador, cod_tipo_fiador, 
fecha_valuacion, ingreso_neto, cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador, porcentaje_responsabilidad, 
cod_tipo_acreedor, cedula_acreedor, cod_operacion_especial, nombre_fiador, cedula_deudor, nombre_deudor, oficina_deudor, null
FROM #TMP_GARANTIA_FIDUCIARIA 
WHERE cod_estado = 1

/**Código que genera la información relacionada con tarjeta**/

--Inserta las garantias fiduciarias de tarjetas de crédito MasterCard
insert into dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
select distinct
	1 as cod_contabilidad,
	b.cod_oficina_registra as cod_oficina,
	b.cod_moneda as cod_moneda, 
	7 as cod_producto, 
	b.num_tarjeta as num_operacion, 
	c.cedula_fiador,
	c.cod_tipo_fiador,
	'' as fecha_valuacion,
	0 as ingreso_neto,
	a.cod_tipo_mitigador,
	a.cod_tipo_documento_legal, 
	a.monto_mitigador, 
	a.porcentaje_responsabilidad, 
	a.cod_tipo_acreedor, 
	a.cedula_acreedor, 
	a.cod_operacion_especial, 
	c.nombre_fiador,
	d.cedula_deudor,
	d.nombre_deudor,
	e.bsmpc_dco_ofici as oficina_deudor,
	b.cod_estado_tarjeta
FROM TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA a
INNER JOIN TAR_TARJETA b on a.cod_tarjeta = b.cod_tarjeta
INNER JOIN TAR_GARANTIA_FIDUCIARIA c on a.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria
INNER JOIN GAR_DEUDOR d on b.cedula_deudor = d.cedula_deudor
INNER JOIN GAR_SICC_BSMPC e on e.bsmpc_sco_ident = CONVERT(DECIMAL, b.cedula_deudor)
WHERE e.bsmpc_estado = 'A'
AND (b.cod_estado_tarjeta <> 'L' or b.cod_estado_tarjeta <> 'V' or
	  b.cod_estado_tarjeta <> 'H')

--Se filtran las tarjetas según el estado que posean
/*DECLARE @string_var varchar(20)
DECLARE @strConsulta nvarchar(800)
DECLARE @Valor varchar(1)
DECLARE @EntroCiclo int 

SET @strConsulta = 'DELETE FROM ##GAR_GIROS_GARANTIAS_FIDUCIARIAS WHERE '

IF(LEN(@FiltroTarjeta) > 0)
BEGIN
	SET @EntroCiclo = 0
	
	IF(LEN(@FiltroTarjeta) > 1)
	BEGIN
		SET @strConsulta = @strConsulta + ' (cod_estado_tarjeta like '
	END
	ELSE IF(LEN(@FiltroTarjeta) = 1)
	BEGIN
		SET @strConsulta = @strConsulta + ' ('
	END

	WHILE LEN(@FiltroTarjeta) > 1
	BEGIN
		SET @EntroCiclo = 1
		SET @Valor = SUBSTRING(@FiltroTarjeta, 1, (CHARINDEX( ',', @FiltroTarjeta)-1))
		SET @strConsulta = @strConsulta + char(39) +  @Valor +  char(39)
		
		IF(LEN(@FiltroTarjeta) > 3)
		BEGIN
			SET @strConsulta = @strConsulta + ' or cod_estado_tarjeta like '
		END

		SET @FiltroTarjeta = SUBSTRING(@FiltroTarjeta, (CHARINDEX( ',', @FiltroTarjeta)+1), len(@FiltroTarjeta))
	END

	IF(LEN(@FiltroTarjeta) = 1)
	BEGIN
		IF(@EntroCiclo = 0)
		BEGIN
			SET @strConsulta = @strConsulta + ' cod_estado_tarjeta like ' + char(39) +  @FiltroTarjeta +  char(39) + ')'
		END
		ELSE
		BEGIN
			SET @strConsulta = @strConsulta + ' or cod_estado_tarjeta like ' + char(39) +  @FiltroTarjeta +  char(39) + ')'
		END
	END
	ELSE IF (LEN(@FiltroTarjeta) < 1)
	BEGIN
		SET @strConsulta = @strConsulta + ')'
	END

	--EXEC(@strConsulta)
	exec sp_executesql @strConsulta

END*/

/**fin del código que genera la información relacionada con tarjetas**/

--SELECT * FROM dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS WHERE cod_tipo_documento_legal is not null

IF OBJECT_ID('tempdb..#TGIROSACTIVOS') IS NOT NULL
DROP TABLE #TGIROSACTIVOS

IF OBJECT_ID('tempdb..#TGARGIROSACTIVOS') IS NOT NULL
DROP TABLE #TGARGIROSACTIVOS

IF OBJECT_ID('tempdb..#TMP_GARANTIA_FIDUCIARIA') IS NOT NULL
DROP TABLE #TMP_GARANTIA_FIDUCIARIA

SELECT cod_contabilidad as CONTABILIDAD,
cod_oficina as OFICINA,
cod_moneda as MONEDA,
cod_producto as PRODUCTO,
operacion as OPERACION,
cedula_fiador as CEDULA_FIADOR,
cod_tipo_fiador as TIPO_PERSONA_FIADOR,
fecha_valuacion as FECHA_VERIFICACION_ASALARIADO,
ingreso_neto as SALARIO_NETO_FIADOR,
cod_tipo_mitigador as TIPO_MITIGADOR_RIESGO,
cod_tipo_documento_legal as TIPO_DOCUMENTO_LEGAL,
monto_mitigador as MONTO_MITIGADOR,
porcentaje_responsabilidad as PORCENTAJE_RESPONSABILIDAD,
cod_tipo_acreedor as TIPO_PERSONA_ACREEDOR,
cedula_acreedor as CEDULA_ACREEDOR,
cod_operacion_especial as OPERACION_ESPECIAL,
nombre_fiador as NOMBRE_FIADOR,
cedula_deudor as CEDULA_DEUDOR,
nombre_deudor as NOMBRE_DEUDOR,
oficina_deudor as OFICINA_DEUDOR,
cod_estado_tarjeta as CODIGO_INTERNO_SISTAR
FROM dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS 
WHERE cod_tipo_documento_legal is not null

END


