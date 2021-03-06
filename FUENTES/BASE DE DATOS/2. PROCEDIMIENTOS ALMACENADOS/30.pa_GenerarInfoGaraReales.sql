USE [GARANTIAS]
GO

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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>08/12/2015</Fecha>
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

SET NOCOUNT ON

--Se limpian las tablas temporales
DELETE FROM dbo.GAR_GIROS_GARANTIAS_REALES

--Se insertan las garantias reales
INSERT INTO dbo.GAR_GIROS_GARANTIAS_REALES(
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
											cod_estado,
											Porcentaje_Aceptacion)
SELECT	DISTINCT 
		GO1.cod_contabilidad, 
		GO1.cod_oficina, 
		GO1.cod_moneda, 
		GO1.cod_producto, 
		GO1.num_operacion AS operacion, 
		GGR.cod_tipo_bien, 
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 then CONVERT(varchar(2),GGR.cod_partido) + GGR.numero_finca  
			WHEN 2 then CONVERT(varchar(2),GGR.cod_partido) + GGR.numero_finca  
			WHEN 3 then ISNULL(GGR.cod_clase_bien, '') + GGR.num_placa_bien --RQ: 1-23923921. Se evalúa si el código de la clase de bien es nulo o no. 
		END AS cod_bien, 
		GRO.cod_tipo_mitigador, 
		CASE cod_tipo_documento_legal 
		WHEN -1 THEN NULL
		ELSE GRO.cod_tipo_documento_legal 
		END,
		GRO.monto_mitigador, 
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_presentacion,103),7,4)
		END AS fecha_presentacion,
		GRO.cod_inscripcion, 
		GRO.porcentaje_responsabilidad, 
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_constitucion,103),7,4)
		END AS fecha_constitucion, 
		GRO.cod_grado_gravamen, 
		GRO.cod_tipo_acreedor, 
		GRO.cedula_acreedor, 
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRO.fecha_vencimiento,103),7,4)
		END AS fecha_vencimiento, 
		GRO.cod_operacion_especial, 
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_valuacion,103),7,4)
		END AS fecha_valuacion, 
		GRV.cedula_empresa, 
		CASE WHEN GRV.cedula_empresa IS NULL then NULL ELSE 2 END AS cod_tipo_empresa, 
		GRV.cedula_perito, 
		GP1.cod_tipo_persona AS cod_tipo_perito, 
		GRV.monto_ultima_tasacion_terreno, 
		GRV.monto_ultima_tasacion_no_terreno, 
		GRV.monto_tasacion_actualizada_terreno, 
		GRV.monto_tasacion_actualizada_no_terreno, 
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_ultimo_seguimiento,103),7,4)
		END AS fecha_ultimo_seguimiento, 
		COALESCE(GRV.monto_tasacion_actualizada_terreno,0) + COALESCE(GRV.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
		CASE WHEN 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),7,4) = '01/01/1900' then ''
			 ELSE 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),1,2) + '/' + 
			SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),4,2) + '/' + 
	        		SUBSTRING(CONVERT(varchar(10),GRV.fecha_construccion,103),7,4)
		END AS fecha_construccion,
		CASE GGR.cod_grado
		WHEN -1 THEN NULL
		ELSE GGR.cod_grado
		END,
		GGR.cedula_hipotecaria,
		GGR.cod_clase_garantia,
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		GGR.cod_tipo_garantia_real,
		COALESCE(GGR.numero_finca,'') AS numero_finca,
		COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
		COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
		GO1.cedula_deudor,
	--	NULL AS cod_estado
		1 AS cod_estado, -- AMM 01/11/2008
		GRO.Porcentaje_Aceptacion

FROM	dbo.GAR_OPERACION GO1 
	INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 	
	ON GO1.cod_operacion = GRO.cod_operacion 
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR 	
	ON GRO.cod_garantia_real = GGR.cod_garantia_real 
	LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GRV 
	ON GGR.cod_garantia_real = GRV.cod_garantia_real 
	AND GRV.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_REALES WHERE cod_garantia_real = GGR.cod_garantia_real) 
	LEFT OUTER JOIN dbo.GAR_PERITO GP1 ON GRV.cedula_perito = GP1.cedula_perito 
WHERE	GO1.num_operacion IS NOT NULL 
	AND GO1.cod_estado = 1 
	AND GRO.cod_estado = 1
	AND EXISTS(	SELECT	1
				FROM	dbo.GAR_SICC_PRMOC MOC
				WHERE	MOC.prmoc_pnu_oper = CONVERT(INT, GO1.num_operacion)
					AND MOC.prmoc_pco_ofici =CONVERT(SMALLINT, GO1.cod_oficina)
					AND MOC.prmoc_pco_moned = CONVERT(TINYINT, GO1.cod_moneda )
					--AND GRV.prmoc_pco_produ = CONVERT(TINYINT, GO1.cod_producto )
					AND MOC.prmoc_pco_conta = CONVERT(TINYINT, GO1.cod_contabilidad)
					AND MOC.prmoc_pnu_contr = GO1.num_contrato
					AND MOC.prmoc_pcoctamay <> 815 
					AND MOC.prmoc_pse_proces = 1 
					AND MOC.prmoc_estado = 'A' 
					AND MOC.prmoc_psa_actual <> 0)

----------------------------------------------------------------------------------------
DECLARE 
	@vbConsecutivo_Operacion BIGINT,
	@vbConsecutivo_Garantia BIGINT,
	@viTipo_Garantia_Real TINYINT,
	@vsNumero_Finca VARCHAR(25),
	@vsGrado VARCHAR(2),
	@vsNumero_Placa VARCHAR(25),
	@piTipo_Documento_Legal SMALLINT,
	@vsNumero_Finca_Anterior VARCHAR(25),
	@viGrado_Anterior VARCHAR(2),
	@vsNumero_Placa_Anterior VARCHAR(25),
	@vbConsecutivo_Operacion_Anterior BIGINT,
	@viuId_Registro UNIQUEIDENTIFIER


DECLARE garantias_cursor CURSOR	FAST_FORWARD
FOR 
	SELECT	cod_operacion,
			cod_garantia_real,
			cod_tipo_garantia_real,
			numero_finca,
			cod_grado,
			num_placa_bien,
			cod_tipo_documento_legal,
			cod_llave
	FROM	dbo.GAR_GIROS_GARANTIAS_REALES
	ORDER BY
		cod_operacion,
		numero_finca,
		cod_grado,
		cod_clase_bien,
		num_placa_bien,
		cod_tipo_documento_legal DESC

OPEN	garantias_cursor
FETCH NEXT FROM		garantias_cursor INTO @vbConsecutivo_Operacion, @vbConsecutivo_Garantia, @viTipo_Garantia_Real, @vsNumero_Finca, 
	@vsGrado, @vsNumero_Placa, @piTipo_Documento_Legal, @viuId_Registro

SET @vsNumero_Finca_Anterior = ''
SET @viGrado_Anterior = ''
SET @vsNumero_Placa_Anterior = ''
SET @vbConsecutivo_Operacion_Anterior = -1


WHILE	@@FETCH_STATUS = 0 
BEGIN
		--Hipotecas
		IF (@viTipo_Garantia_Real = 1) BEGIN
			IF (@vbConsecutivo_Operacion_Anterior = @vbConsecutivo_Operacion) 
			BEGIN
				IF (@vsNumero_Finca_Anterior = @vsNumero_Finca) 
				BEGIN
					
					UPDATE GAR_GIROS_GARANTIAS_REALES SET cod_estado = 2
					WHERE cod_llave = @viuId_Registro
				END
			END
		END
				
		SET @vsNumero_Finca_Anterior = @vsNumero_Finca
		SET @viGrado_Anterior = @vsGrado
		SET @vsNumero_Placa_Anterior = @vsNumero_Placa
		SET @vbConsecutivo_Operacion_Anterior = @vbConsecutivo_Operacion
	      
	    FETCH NEXT FROM garantias_cursor INTO @vbConsecutivo_Operacion, @vbConsecutivo_Garantia, @viTipo_Garantia_Real, 
		@vsNumero_Finca, @vsGrado, @vsNumero_Placa, @piTipo_Documento_Legal, @viuId_Registro
END


CLOSE garantias_cursor
DEALLOCATE garantias_cursor

END

