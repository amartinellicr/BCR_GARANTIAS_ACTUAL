USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('pa_CargarContratosVencidos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_CargarContratosVencidos;
GO

CREATE PROCEDURE [dbo].[pa_CargarContratosVencidos] AS
BEGIN
/******************************************************************
	<Nombre>pa_CargarContratosVencidos</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de garantías de los contratos vencidos, con giros activos, del 
			     SICC a la base de datos GARANTIAS. 
	</Descripción>
	<Entradas></Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.2</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Req_Garantia Real, Siebel No. 1-21537644.
			</Requerimiento>
			<Fecha>20/06/2013</Fecha>
			<Descripción>
					Se agrega el mapeo del tipo de documento legal, según el código de grado de gravamen indicado en el SICC, así mismo,
					el mapeo de la fecha de constitución, fecha de prescripción y de vencimiento de las garantías.
			</Descripción>
		</Cambio>
                <Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambio validación y código de clase 18, Siebel 1-23969281.</Requerimiento>
			<Fecha>29/10/2013</Fecha>
			<Descripción>
				Se ajusta la forma en que se clasifican las garantías reales del tipo hipoteca común y cédula hipotecaria,
				esto con el fin de que las garantías con clase 18 sean clasificadas como cédula hipotecaria y no como hipoteca común.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajuste del campo Fecha Valuación y Fecha Valuación SICC, Siebel No. 1-24315781.
			</Requerimiento>
			<Fecha>18/05/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se replican los avalúos de las garantías reales.
			</Descripción>
		</Cambio>	
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajustes por Fallas Técnicas, Siebel No. 1-24331191.
			</Requerimiento>
			<Fecha>28/05/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se extrae la información del SICC, tomándo en 
					cuenta que las operación esté activa o el contrato vigente o vencido con giros 
					activos. 
			</Descripción>
		</Cambio>	
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajustes en Procedimientos Almacenados de BCRGarantías, Siebel No. 1-24330461.
			</Requerimiento>
			<Fecha>30/05/2014</Fecha>
			<Descripción>
					Se realiza una ajuste general al procedimiento almacenado, principalmente la
					inclusión de transacciones por cada inserción, actualización o eliminación que 
					se haga. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Actualización del indicador de inscripción, Siebel No. 1-24359411.
			</Requerimiento>
			<Fecha>30/05/2014</Fecha>
			<Descripción>
					Se realiza una ajuste en las sentencias correspondientes a la actualización del 
					indicador de inscripción de las garantías asociadas a los contratos. 
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
SET XACT_ABORT ON


TRUNCATE TABLE dbo.TMP_GAR_CONTRATOS

----------------------------------------------------------------------
--CARGA CONTRATOS VENCIDOS
----------------------------------------------------------------------

	--INICIO RQ: 1-24331191.
	
	DECLARE		
		@viFechaActualEntera INT, --Corresponde al a fecha actual en formato numérico.
		@viErrorTran INT -- Almacena el código del error generado durante la transacción
		
	--Se inicializan las variables
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))

	--FIN RQ: 1-24331191.

--Inserta el deudor del contrato
BEGIN TRANSACTION TRA_Ins_Deud

INSERT	INTO  dbo.GAR_DEUDOR
(
	cedula_deudor, 
	nombre_deudor, 
	cod_tipo_deudor, 
	cod_vinculado_entidad,
	Identificacion_Sicc
)
SELECT	DISTINCT
	MCA.prmca_pco_ident,
	MCL.bsmcl_sno_clien,
	MCL.bsmcl_scotipide,
	2 AS cod_vinculado_entidad,
	MCA.prmca_pco_ident
FROM	dbo.GAR_SICC_PRMCA MCA
	INNER JOIN dbo.GAR_SICC_BSMCL MCL
	ON MCL.bsmcl_sco_ident = MCA.prmca_pco_ident
WHERE  MCL.bsmcl_estado = 'A'
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMOC MOC
				WHERE	MOC.prmoc_estado = 'A' 
				AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
				AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
				AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
				AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr)	
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_DEUDOR
					WHERE	Identificacion_Sicc = MCA.prmca_pco_ident)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Deud
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Deud
END


--Inserta la información del contrato
INSERT INTO dbo.TMP_GAR_CONTRATOS 
(
	cod_contabilidad, 
	cod_oficina, 
	cod_moneda, 
	cod_producto, 
	num_contrato, 
	fecha_constitucion, 
	fecha_vencimiento, --RQ: 1-21537644. Se agrega este campo
	cedula_deudor
)
SELECT	DISTINCT
	MCA.prmca_pco_conta,
	MCA.prmca_pco_ofici,
	MCA.prmca_pco_moned,
	MCA.prmca_pco_produc,
	MCA.prmca_pnu_contr,
	CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),1,4) + '-' + 
	                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),5,2) + '-' + 
	                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),7,2)) 
	AS prmca_pfe_const,
	CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),1,4) + '-' + 
	SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),5,2) + '-' + 
	SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),7,2)) AS prmca_pfe_defin, --RQ: 1-21537644. Se agrega este campo
	MCA.prmca_pco_ident
FROM	dbo.GAR_SICC_PRMCA MCA
WHERE  MCA.prmca_estado = 'A'
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMOC MOC
				WHERE	MOC.prmoc_estado = 'A' 
				AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
				AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
				AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
				AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr)	
	AND NOT EXISTS (SELECT	1
					FROM	dbo.TMP_GAR_CONTRATOS TMP
					WHERE	TMP.num_contrato = MCA.prmca_pnu_contr
						AND TMP.cod_oficina = MCA.prmca_pco_ofici
						AND TMP.cod_moneda = MCA.prmca_pco_moned
						AND TMP.cod_producto = MCA.prmca_pco_produc
						AND TMP.cod_contabilidad = MCA.prmca_pco_conta)


--Inserta los contratos en GAR_OPERACION
BEGIN TRANSACTION TRA_Ins_Oper

INSERT	INTO dbo.GAR_OPERACION
(
	cod_contabilidad, 
	cod_oficina, 
	cod_moneda, 
	cod_producto, 
	num_operacion, 
	num_contrato, 
	fecha_constitucion, 
	cedula_deudor, 
	fecha_vencimiento, 
	monto_original, 
	saldo_actual, 
	cod_estado
)
SELECT DISTINCT 
	TMP.cod_contabilidad, 
	TMP.cod_oficina, 
	TMP.cod_moneda, 
	TMP.cod_producto, 
	TMP.num_operacion, 
	TMP.num_contrato, 
	TMP.fecha_constitucion, 
	TMP.cedula_deudor, 
	TMP.fecha_vencimiento, 
	TMP.monto_original, 
	TMP.saldo_actual, 
	TMP.cod_estado
FROM	dbo.TMP_GAR_CONTRATOS TMP
WHERE	EXISTS (SELECT	1
				FROM	dbo.GAR_DEUDOR GDE
				WHERE	GDE.Identificacion_Sicc = TMP.cedula_deudor)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	GO1.cod_oficina = TMP.cod_oficina
						AND GO1.cod_moneda = TMP.cod_moneda
						AND GO1.cod_producto = TMP.cod_producto
						AND GO1.num_contrato = TMP.num_contrato
						AND GO1.num_operacion IS NULL)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Oper
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Oper
END

----------------------------------------------------------------------
--CARGA GARANTIAS FIDUCIARIAS
----------------------------------------------------------------------
BEGIN TRANSACTION TRA_Ins_Ggf

INSERT	INTO dbo.GAR_GARANTIA_FIDUCIARIA
(
	cod_tipo_garantia, 
	cod_clase_garantia, 
	cedula_fiador, 
	nombre_fiador, 
	cod_tipo_fiador,
	Identificacion_Sicc
)
SELECT	DISTINCT 
	1 AS cod_tipo_garantia,
	MGT.prmgt_pcoclagar AS cod_clase_garantia,
	MGT.prmgt_pnuidegar AS cedula_fiador,
	MCL.bsmcl_sno_clien AS nombre_fiador,
	MCL.bsmcl_scotipide AS cod_tipo_fiador,
	MGT.prmgt_pnuidegar AS Identificacion_Sicc
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN	dbo.GAR_SICC_BSMCL MCL
	ON MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'	
	AND MGT.prmgt_pcoclagar = 0
	AND MGT.prmgt_pco_produ = 10
	AND MCL.bsmcl_estado = 'A'
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					WHERE	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggf
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggf
END

--Relación entre el fiador y el contrato
BEGIN TRANSACTION TRA_Ins_Gfo

INSERT	INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
(
	cod_operacion,
	cod_garantia_fiduciaria,
	cod_tipo_mitigador,
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_operacion_especial,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_estado
)
SELECT	DISTINCT
	GO1.cod_operacion,
	GGF.cod_garantia_fiduciaria,
	0 AS cod_tipo_mitigador,
	NULL AS cod_tipo_documento_legal,
	0 AS monto_mitigador,
	0 AS porcentaje_responsabilidad,
	0 AS cod_operacion_especial,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	1 AS cod_estado
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON GO1.num_contrato = MGT.prmgt_pnu_oper
	AND GO1.cod_oficina = MGT.prmgt_pco_ofici
	AND GO1.cod_moneda = MGT.prmgt_pco_moned
	AND GO1.cod_contabilidad = MGT.prmgt_pco_conta
	AND MGT.prmgt_pco_produ = 10
	INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
	ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'	
	AND MGT.prmgt_pcoclagar = 0
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_BSMCL MCL
				WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar)
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
					WHERE	GFO.cod_operacion = GO1.cod_operacion
						AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Gfo
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Gfo
END

----------------------------------------------------------------------
--CARGA HIPOTECAS (GARANTIAS REALES)
----------------------------------------------------------------------
BEGIN TRANSACTION TRA_Ins_Grhc
	
	INSERT INTO dbo.GAR_GARANTIA_REAL
	(
		cod_tipo_garantia,
		cod_clase_garantia,	
		cod_tipo_garantia_real,
		cod_partido,
		numero_finca,
		cod_grado,
		cedula_hipotecaria,
		cod_clase_bien,
		num_placa_bien,
		cod_tipo_bien,
		Identificacion_Sicc
	)
	SELECT DISTINCT
		2 AS cod_tipo_garantia,
		MGT.prmgt_pcoclagar AS cod_clase_garantia,
		1 AS cod_tipo_garantia_real,
		MGT.prmgt_pnu_part AS cod_partido,
		MGT.prmgt_pnuidegar AS numero_finca,
		NULL AS cod_grado,
		NULL AS cedula_hipotecaria,
		NULL AS cod_clase_bien,
		NULL AS num_placa_bien,
		NULL AS cod_tipo_bien,
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
		AND MGT.prmgt_pco_produ = 10
		AND EXISTS (SELECT	1
					FROM	dbo.TMP_GAR_CONTRATOS TMP
					WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
						AND TMP.cod_oficina = MGT.prmgt_pco_ofici
						AND TMP.cod_moneda = MGT.prmgt_pco_moned
						AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_REAL GGR
						WHERE	GGR.cod_tipo_garantia_real = 1
							AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
							AND GGR.cod_partido = MGT.prmgt_pnu_part
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grhc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grhc
	END

--Relación entre la hipoteca y el contrato
BEGIN TRANSACTION TRA_Ins_Ggrohc

INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
(
	cod_operacion,
	cod_garantia_real,	
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_grado_gravamen,
	cod_operacion_especial,
	fecha_constitucion,
	fecha_vencimiento,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_liquidez,
	cod_tenencia,
	cod_moneda,
	fecha_prescripcion
)
SELECT	DISTINCT
	GO1.cod_operacion,
	GGR.cod_garantia_real,
	--INICIO RQ: 1-21537644 Agregar campo
	CASE 
		WHEN MGT.prmgt_pco_grado = 1 THEN 1
		WHEN MGT.prmgt_pco_grado = 2 THEN 2
		WHEN MGT.prmgt_pco_grado = 3 THEN 3
		WHEN MGT.prmgt_pco_grado = 4 THEN 4
		ELSE NULL			
	END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
	GO1.saldo_actual AS monto_mitigador,
	100 AS porcentaje_responsabilidad,
	MGT.prmgt_pco_grado AS cod_grado_gravamen,
	0 AS cod_operacion_especial,
	GO1.fecha_constitucion AS fecha_constitucion,
	GO1.fecha_vencimiento,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	MGT.prmgt_pcoliqgar AS cod_liquidez,
	MGT.prmgt_pcotengar AS cod_tenencia,
	MGT.prmgt_pco_mongar AS cod_moneda,
	CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
		 ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_prescripcion
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR
	ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					WHERE	GRO.cod_operacion = GO1.cod_operacion
						AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggrohc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggrohc
END

----------------------------------------------------------------------
--CARGA CEDULAS HIPOTECARIAS (GARANTIAS REALES)
----------------------------------------------------------------------
--Cédulas hipotecarias con clase 18
BEGIN TRANSACTION TRA_Ins_Gchc

INSERT INTO dbo.GAR_GARANTIA_REAL
(
	cod_tipo_garantia,
	cod_clase_garantia,	
	cod_tipo_garantia_real,
	cod_partido,
	numero_finca,
	cod_grado,
	cedula_hipotecaria,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_bien,
	Identificacion_Sicc
)
SELECT DISTINCT
	2 AS cod_tipo_garantia,
	MGT.prmgt_pcoclagar AS cod_clase_garantia,
	2 AS cod_tipo_garantia_real,
	MGT.prmgt_pnu_part AS cod_partido,
	MGT.prmgt_pnuidegar AS numero_finca,
	MGT.prmgt_pco_grado AS cod_grado,
	NULL AS cedula_hipotecaria,
	NULL AS cod_clase_bien,
	NULL AS num_placa_bien,
	NULL AS cod_tipo_bien,
	MGT.prmgt_pnuidegar AS Identificacion_Sicc
FROM	dbo.GAR_SICC_PRMGT MGT
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar = 18
	AND MGT.prmgt_pco_produ = 10
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIA_REAL GGR
					WHERE	GGR.cod_tipo_garantia_real = 2
						AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.cod_partido = MGT.prmgt_pnu_part
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Gchc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Gchc
END


--Cédulas hipotecarias con clase diferente a la 18
BEGIN TRANSACTION TRA_Ins_Grchc

INSERT INTO dbo.GAR_GARANTIA_REAL
(
	cod_tipo_garantia,
	cod_clase_garantia,	
	cod_tipo_garantia_real,
	cod_partido,
	numero_finca,
	cod_grado,
	cedula_hipotecaria,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_bien,
	Identificacion_Sicc
)
SELECT DISTINCT
	2 AS cod_tipo_garantia,
	MGT.prmgt_pcoclagar AS cod_clase_garantia,
	2 AS cod_tipo_garantia_real,
	MGT.prmgt_pnu_part AS cod_partido,
	MGT.prmgt_pnuidegar AS numero_finca,
	MGT.prmgt_pco_grado AS cod_grado,
	NULL AS cedula_hipotecaria,
	NULL AS cod_clase_bien,
	NULL AS num_placa_bien,
	NULL AS cod_tipo_bien,
	MGT.prmgt_pnuidegar AS Identificacion_Sicc
FROM	dbo.GAR_SICC_PRMGT MGT
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcotengar = 1
	AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
	AND MGT.prmgt_pco_produ = 10
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIA_REAL GGR
					WHERE	GGR.cod_tipo_garantia_real = 2
						AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Grchc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Grchc
END


--Relación entre la cédula hipotecaria de clase 18 y el contrato
BEGIN TRANSACTION TRA_Ins_Ggroch18

INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
(
	cod_operacion,
	cod_garantia_real,	
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_grado_gravamen,
	cod_operacion_especial,
	fecha_constitucion,
	fecha_vencimiento,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_liquidez,
	cod_tenencia,
	cod_moneda,
	fecha_prescripcion
)
SELECT	DISTINCT
	GO1.cod_operacion,
	GGR.cod_garantia_real,
	--INICIO RQ: 1-21537644 Agregar campo
	CASE 
		WHEN MGT.prmgt_pco_grado = 1 THEN 5
		WHEN MGT.prmgt_pco_grado = 2 THEN 6
		WHEN MGT.prmgt_pco_grado = 3 THEN 7
		WHEN MGT.prmgt_pco_grado = 4 THEN 8
		ELSE NULL			
	END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
	GO1.saldo_actual AS monto_mitigador,
	100 AS porcentaje_responsabilidad,
	MGT.prmgt_pco_grado AS cod_grado_gravamen,
	0 AS cod_operacion_especial,
	GO1.fecha_constitucion AS fecha_constitucion,
	GO1.fecha_vencimiento,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	MGT.prmgt_pcoliqgar AS cod_liquidez,
	MGT.prmgt_pcotengar AS cod_tenencia,
	MGT.prmgt_pco_mongar AS cod_moneda,
	CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
		 ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_prescripcion
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR
	ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar = 18
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					WHERE	GRO.cod_operacion = GO1.cod_operacion
						AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggroch18
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggroch18
END

--Relación entre la cédula hipotecaria y el contrato
BEGIN TRANSACTION TRA_Ins_Ggroch

INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
(
	cod_operacion,
	cod_garantia_real,	
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_grado_gravamen,
	cod_operacion_especial,
	fecha_constitucion,
	fecha_vencimiento,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_liquidez,
	cod_tenencia,
	cod_moneda,
	fecha_prescripcion
)
SELECT	DISTINCT
	GO1.cod_operacion,
	GGR.cod_garantia_real,
	--INICIO RQ: 1-21537644 Agregar campo
	CASE 
		WHEN MGT.prmgt_pco_grado = 1 THEN 5
		WHEN MGT.prmgt_pco_grado = 2 THEN 6
		WHEN MGT.prmgt_pco_grado = 3 THEN 7
		WHEN MGT.prmgt_pco_grado = 4 THEN 8
		ELSE NULL			
	END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
	GO1.saldo_actual AS monto_mitigador,
	100 AS porcentaje_responsabilidad,
	MGT.prmgt_pco_grado AS cod_grado_gravamen,
	0 AS cod_operacion_especial,
	GO1.fecha_constitucion AS fecha_constitucion,
	GO1.fecha_vencimiento,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	MGT.prmgt_pcoliqgar AS cod_liquidez,
	MGT.prmgt_pcotengar AS cod_tenencia,
	MGT.prmgt_pco_mongar AS cod_moneda,
	CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
		 ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_prescripcion
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR
	ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
	AND MGT.prmgt_pcotengar = 1
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					WHERE	GRO.cod_operacion = GO1.cod_operacion
						AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggroch
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggroch
END

----------------------------------------------------------------------
--CARGA PRENDAS (GARANTIAS REALES)
----------------------------------------------------------------------
BEGIN TRANSACTION TRA_Ins_Ggrpc
	
INSERT INTO dbo.GAR_GARANTIA_REAL
(
	cod_tipo_garantia,
	cod_clase_garantia,	
	cod_tipo_garantia_real,
	cod_partido,
	numero_finca,
	cod_grado,
	cedula_hipotecaria,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_bien,
	Identificacion_Sicc
)
SELECT DISTINCT
	2 AS cod_tipo_garantia,
	MGT.prmgt_pcoclagar AS cod_clase_garantia,
	3 AS cod_tipo_garantia_real,
	NULL AS cod_partido,
	NULL AS numero_finca,
	NULL AS cod_grado,
	NULL AS cedula_hipotecaria,
	NULL AS cod_clase_bien,
	MGT.prmgt_pnuidegar AS num_placa_bien,
	NULL AS cod_tipo_bien,
	MGT.prmgt_pnuidegar AS Identificacion_Sicc
FROM	dbo.GAR_SICC_PRMGT MGT
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
	AND MGT.prmgt_pco_produ = 10
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIA_REAL GGR
					WHERE	GGR.cod_tipo_garantia_real = 3
						AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggrpc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggrpc
END

--Relación entre la prenda y el contrato
BEGIN TRANSACTION TRA_Ins_Ggroch

INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
(
	cod_operacion,
	cod_garantia_real,	
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_grado_gravamen,
	cod_operacion_especial,
	fecha_constitucion,
	fecha_vencimiento,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_liquidez,
	cod_tenencia,
	cod_moneda,
	fecha_prescripcion
)
SELECT	DISTINCT
	GO1.cod_operacion,
	GGR.cod_garantia_real,
	--INICIO RQ: 1-21537644 Agregar campo
	CASE 
		WHEN MGT.prmgt_pco_grado = 1 THEN 9
		WHEN MGT.prmgt_pco_grado = 2 THEN 10
		WHEN MGT.prmgt_pco_grado = 3 THEN 11
		WHEN MGT.prmgt_pco_grado = 4 THEN 12
		ELSE NULL			
	END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
	GO1.saldo_actual AS monto_mitigador,
	100 AS porcentaje_responsabilidad,
	MGT.prmgt_pco_grado AS cod_grado_gravamen,
	0 AS cod_operacion_especial,
	GO1.fecha_constitucion AS fecha_constitucion,
	GO1.fecha_vencimiento,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	MGT.prmgt_pcoliqgar AS cod_liquidez,
	MGT.prmgt_pcotengar AS cod_tenencia,
	MGT.prmgt_pco_mongar AS cod_moneda,
	CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
		 ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_prescripcion
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR
	ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					WHERE	GRO.cod_operacion = GO1.cod_operacion
						AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Ggroch
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Ggroch
END

----------------------------------------------------------------------
--CARGA GARANTIAS DE VALOR
----------------------------------------------------------------------
BEGIN TRANSACTION TRA_Ins_Grvoc
	
INSERT	INTO dbo.GAR_GARANTIA_VALOR
(
	cod_tipo_garantia,
	cod_clase_garantia,
	numero_seguridad,
	fecha_constitucion,
	fecha_vencimiento_instrumento,
	cod_clasificacion_instrumento,
	des_instrumento,
	des_serie_instrumento,
	cod_tipo_emisor,
	cedula_emisor,
	premio,
	cod_isin,
	valor_facial,
	cod_moneda_valor_facial,
	valor_mercado,
	cod_moneda_valor_mercado,
	cod_tenencia,
	fecha_prescripcion,
	Identificacion_Sicc
)
SELECT	DISTINCT
	3 AS cod_tipo_garantia,
	MGT.prmgt_pcoclagar AS cod_clase_garantia,
	MGT.prmgt_pnuidegar AS numero_seguridad,
	CASE 
		WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_constitucion)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_constitucion))
	    ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_constitucion,
	CASE 
		WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_vencimiento)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_vencimiento))
	    ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_vencimiento_instrumento,
	NULL AS cod_clasificacion_instrumento,
	NULL AS des_instrumento,
	NULL AS des_serie_instrumento,
	NULL AS cod_tipo_emisor,
	NULL AS cedula_emisor,
	NULL AS premio,
	NULL AS cod_isin,
	NULL AS valor_facial,
	NULL AS cod_moneda_valor_facial,
	NULL AS valor_mercado,
	NULL AS cod_moneda_valor_mercado,
	MGT.prmgt_pcotengar AS cod_tenencia,
	CASE 
		WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
	    ELSE CONVERT(DATETIME, '1900-01-01')
	END AS fecha_prescripcion,
	MGT.prmgt_pnuidegar AS Identificacion_Sicc

FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
	AND MGT.prmgt_pcotengar IN (2,3,4,6)
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIA_VALOR GGV
					WHERE	GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Grvoc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Grvoc
END
	

--Relación entre la seguridad y el contrato
BEGIN TRANSACTION TRA_Ins_Gvooc

INSERT	INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
(
	cod_operacion, 
	cod_garantia_valor, 
	monto_mitigador,
	cod_tipo_acreedor, 
	cedula_acreedor, 
	cod_operacion_especial, 
	porcentaje_responsabilidad
	
) 
SELECT	DISTINCT
	GO1.cod_operacion,
	GGV.cod_garantia_valor,
	GO1.saldo_actual AS monto_mitigador,
	2 AS cod_tipo_acreedor,
	'4000000019' AS cedula_acreedor,
	0 AS cod_operacion_especial,
	100 AS porcentaje_responsabilidad
FROM	dbo.GAR_SICC_PRMGT MGT
	INNER JOIN dbo.GAR_OPERACION GO1
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
	AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
	INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
	ON GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
WHERE	MGT.prmgt_estado = 'A'
	AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
	AND MGT.prmgt_pcotengar IN (2,3,4,6)
	AND GO1.num_operacion IS NULL
	AND EXISTS (SELECT	1
				FROM	dbo.TMP_GAR_CONTRATOS TMP
				WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
					AND TMP.cod_oficina = MGT.prmgt_pco_ofici
					AND TMP.cod_moneda = MGT.prmgt_pco_moned
					AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
					WHERE	GVO.cod_operacion = GO1.cod_operacion
						AND GVO.cod_garantia_valor = GGV.cod_garantia_valor)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Gvooc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Gvooc
END

----------------------------------------------------------------------
--CARGA VALUACIONES DE GARANTIAS REALES
----------------------------------------------------------------------

--INICIO RQ: 1-24315781 Y 1-24331191. Se migra el avalúo más reciente para una misma garantía registrada en el Maestro de Garantías (tabla PRMGT).

--Se asigna la fecha del avalúo más reciente para hipotecas comunes
BEGIN TRANSACTION TRA_Ins_Vrhc

INSERT INTO dbo.GAR_VALUACIONES_REALES
(
	cod_garantia_real, 
	fecha_valuacion, 
	monto_total_avaluo
)
SELECT	DISTINCT 
	GGR.cod_garantia_real, 
	CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
	0 AS monto_total_avaluo
FROM	dbo.GAR_GARANTIA_REAL GGR
	INNER JOIN (	SELECT	TOP 100 PERCENT 
						GGR.cod_clase_garantia,
						GGR.cod_partido,
						GGR.Identificacion_Sicc,
						MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
					GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
				) GHC
	ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
	AND GHC.cod_partido = GGR.cod_partido
	AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
WHERE	GHC.fecha_valuacion > '19000101'
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_VALUACIONES_REALES GVR
					WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Vrhc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Vrhc
END

--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía 18
BEGIN TRANSACTION TRA_Ins_Vrch18

INSERT INTO dbo.GAR_VALUACIONES_REALES
(
	cod_garantia_real, 
	fecha_valuacion, 
	monto_total_avaluo
)
SELECT	DISTINCT 
	GGR.cod_garantia_real, 
	CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
	0 AS monto_total_avaluo
FROM	dbo.GAR_GARANTIA_REAL GGR
	INNER JOIN (	SELECT	TOP 100 PERCENT 
						GGR.cod_clase_garantia,
						GGR.cod_partido,
						GGR.Identificacion_Sicc,
						MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					WHERE	GGR.cod_clase_garantia = 18
					GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
				) GHC
	ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
	AND GHC.cod_partido = GGR.cod_partido
	AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
WHERE	GHC.fecha_valuacion > '19000101'
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_VALUACIONES_REALES GVR
					WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))


SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Vrch18
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Vrch18
END

--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
BEGIN TRANSACTION TRA_Ins_Vrch

INSERT INTO dbo.GAR_VALUACIONES_REALES
(
	cod_garantia_real, 
	fecha_valuacion, 
	monto_total_avaluo
)
SELECT	DISTINCT 
	GGR.cod_garantia_real, 
	CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
	0 AS monto_total_avaluo
FROM	dbo.GAR_GARANTIA_REAL GGR
	INNER JOIN (	SELECT	TOP 100 PERCENT 
						GGR.cod_clase_garantia,
						GGR.cod_partido,
						GGR.Identificacion_Sicc,
						MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
					GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
				) GHC
	ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
	AND GHC.cod_partido = GGR.cod_partido
	AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
WHERE	GHC.fecha_valuacion > '19000101'
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_VALUACIONES_REALES GVR
					WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Vrch
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Vrch
END

--Se asigna la fecha del avalúo más reciente para prendas
BEGIN TRANSACTION TRA_Ins_Vrp

INSERT INTO dbo.GAR_VALUACIONES_REALES
(
	cod_garantia_real, 
	fecha_valuacion, 
	monto_total_avaluo
)
SELECT	DISTINCT 
	GGR.cod_garantia_real, 
	CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
	0 AS monto_total_avaluo
FROM	dbo.GAR_GARANTIA_REAL GGR
	INNER JOIN (	SELECT	TOP 100 PERCENT 
						GGR.cod_clase_garantia,
						GGR.Identificacion_Sicc,
						MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
					GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc
				) GHC
	ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
	AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
WHERE	GHC.fecha_valuacion > '19000101'
	AND NOT EXISTS (SELECT	1
					FROM	dbo.GAR_VALUACIONES_REALES GVR
					WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Ins_Vrp
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Ins_Vrp
END

--INICIO RQ: 1-24206841. Se actualiza el campo de la fecha de valuación registrada en el SICC, en la tabla de valuaciones.
--Si la fecha de valuación del SICC es 01/01/1900 implica que el dato almacenado en el Maestro de Garantías (tabla PRMGT) no corresponde a una fecha.
--Si la fecha de valuación dle SICC es igual a NULL es porque la garantía nunca fue encontrada en el Maestro de Garantías (tabla PRMGT).

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
BEGIN TRANSACTION TRA_Act_Fvhcop

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion 	= GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici  = GO1.cod_oficina
	AND MGT.prmgt_pco_moned	= GO1.cod_moneda
	AND MGT.prmgt_pco_produ	= GO1.cod_producto
	AND MGT.prmgt_pnu_oper = GO1.num_operacion
WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_contrato = 0
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvhcop
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvhcop
END

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
BEGIN TRANSACTION TRA_Act_Fvhcc

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_operacion IS NULL
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvhcc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvhcc
END

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
BEGIN TRANSACTION TRA_Act_Fvch18op

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = GO1.cod_producto
	AND MGT.prmgt_pnu_oper = GO1.num_operacion
WHERE	GGR.cod_clase_garantia = 18
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido	= MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc	= MGT.prmgt_pnuidegar
	AND GO1.num_contrato = 0
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvch18op
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvch18op
END
	
--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
BEGIN TRANSACTION TRA_Act_Fvch18c

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
WHERE	GGR.cod_clase_garantia = 18
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_operacion IS NULL
	AND MGT.prmgt_estado = 'A'
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvch18c
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvch18c
END
	
--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
BEGIN TRANSACTION TRA_Act_Fvchop

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = GO1.cod_producto
	AND MGT.prmgt_pnu_oper = GO1.num_operacion
WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido = MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_contrato = 0
	AND MGT.prmgt_pcotengar = 1
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvchop
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvchop
END
	
--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
BEGIN TRANSACTION TRA_Act_Fvchc

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ	= 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.cod_partido	= MGT.prmgt_pnu_part
	AND GGR.Identificacion_Sicc	= MGT.prmgt_pnuidegar
	AND GO1.num_operacion IS NULL
	AND MGT.prmgt_pcotengar	= 1
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvchc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvchc
END	
	
--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para prendas
BEGIN TRANSACTION TRA_Act_Fvpop

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ = GO1.cod_producto
	AND MGT.prmgt_pnu_oper = GO1.num_operacion
WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_contrato = 0
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvpop
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvpop
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para prendas
BEGIN TRANSACTION TRA_Act_Fvpc

UPDATE	GRO
SET		GRO.Fecha_Valuacion_SICC =	CASE 
										WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
										WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
										ELSE '19000101'
									END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_OPERACION GO1 
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMGT MGT 
	ON MGT.prmgt_pco_ofici = GO1.cod_oficina
	AND MGT.prmgt_pco_moned = GO1.cod_moneda
	AND MGT.prmgt_pco_produ	= 10
	AND MGT.prmgt_pnu_oper = GO1.num_contrato
WHERE	GGR.cod_clase_garantia	BETWEEN 30 AND 69
	AND GGR.cod_clase_garantia	= MGT.prmgt_pcoclagar
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND GO1.num_operacion IS NULL
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Fvpc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Fvpc
END	

--FIN RQ: 1-24206841 Y 1-24331191

--INICIO RQ: 1-21537427 Y 1-24331191. Se actualiza el indicador del tipo de registro de los avalúos
--Se inicializan todos los registros a 0 (cero)
BEGIN TRANSACTION TRA_Act_Avaluos

UPDATE	dbo.GAR_VALUACIONES_REALES
SET		Indicador_Tipo_Registro = 0

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avaluos
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avaluos
END	

--Se obtienen los avalúos más recientes
BEGIN TRANSACTION TRA_Act_Avalrec

UPDATE	GV1
SET		GV1.Indicador_Tipo_Registro = 2
FROM	dbo.GAR_VALUACIONES_REALES GV1
INNER JOIN  (SELECT		cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
			 FROM		dbo.GAR_VALUACIONES_REALES
			 GROUP		BY cod_garantia_real) GV2
ON	GV2.cod_garantia_real = GV1.cod_garantia_real
AND GV2.fecha_valuacion	= GV1.fecha_valuacion

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalrec
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalrec
END	

--Se obtienen los penúltimos avalúos
BEGIN TRANSACTION TRA_Act_Avalpenul

UPDATE	GV1
SET		GV1.Indicador_Tipo_Registro = 3
FROM	dbo.GAR_VALUACIONES_REALES GV1
INNER JOIN (SELECT	cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
			FROM	dbo.GAR_VALUACIONES_REALES
			WHERE	Indicador_Tipo_Registro = 0
			GROUP	BY cod_garantia_real) GV2
ON	GV2.cod_garantia_real = GV1.cod_garantia_real
AND GV2.fecha_valuacion	= GV1.fecha_valuacion

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalpenul
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalpenul
END	

--Se obtienen los avalúos que son iguales a los registrados en el SICC para operaciones
--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes
BEGIN TRANSACTION TRA_Act_Avalhc

UPDATE	GV1
SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
		GV1.Indicador_Tipo_Registro = 1
FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN (
	SELECT	DISTINCT 
		GGR.cod_garantia_real, 
		CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
		GHC.monto_total_avaluo 
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN (	SELECT	TOP 100 PERCENT 
							GGR.cod_clase_garantia,
							GGR.cod_partido,
							GGR.Identificacion_Sicc,
							MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
							MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
						FROM	dbo.GAR_GARANTIA_REAL GGR 
							INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
											MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
						ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
						AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
						AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
						AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
						WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
						GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
					) GHC
		ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
		AND GHC.cod_partido = GGR.cod_partido
		AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
	WHERE	GHC.fecha_valuacion > '19000101') TMP
	ON TMP.cod_garantia_real = GV1.cod_garantia_real
	AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
	
SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalhc
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalhc
END	

--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía 18
BEGIN TRANSACTION TRA_Act_Avalch18

UPDATE	GV1
SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
		GV1.Indicador_Tipo_Registro = 1 
FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN (
	SELECT	DISTINCT 
		GGR.cod_garantia_real, 
		CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
		GHC.monto_total_avaluo 
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN (	SELECT	TOP 100 PERCENT 
							GGR.cod_clase_garantia,
							GGR.cod_partido,
							GGR.Identificacion_Sicc,
							MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
							MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
						FROM	dbo.GAR_GARANTIA_REAL GGR 
							INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
											MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar = 18
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
						ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
						AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
						AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
						AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
						WHERE	GGR.cod_clase_garantia = 18
						GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
					) GHC
		ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
		AND GHC.cod_partido = GGR.cod_partido
		AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
	WHERE	GHC.fecha_valuacion > '19000101') TMP
	ON TMP.cod_garantia_real = GV1.cod_garantia_real
	AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalch18
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalch18
END	

--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
BEGIN TRANSACTION TRA_Act_Avalch

UPDATE	GV1
SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
		GV1.Indicador_Tipo_Registro = 1 
FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN (
	SELECT	DISTINCT 
		GGR.cod_garantia_real, 
		CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
		GHC.monto_total_avaluo 
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN (	SELECT	TOP 100 PERCENT 
							GGR.cod_clase_garantia,
							GGR.cod_partido,
							GGR.Identificacion_Sicc,
							MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
							MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
						FROM	dbo.GAR_GARANTIA_REAL GGR 
							INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
											MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnu_part,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcotengar = 1
													AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
						ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
						AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
						AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
						AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
						WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
						GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
					) GHC
		ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
		AND GHC.cod_partido = GGR.cod_partido
		AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
	WHERE	GHC.fecha_valuacion > '19000101') TMP
	ON TMP.cod_garantia_real = GV1.cod_garantia_real
	AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalch
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalch
END	

--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas
BEGIN TRANSACTION TRA_Act_Avalp

UPDATE	GV1
SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
		GV1.Indicador_Tipo_Registro = 1 
FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN (
	SELECT	DISTINCT 
		GGR.cod_garantia_real, 
		CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
		GHC.monto_total_avaluo 
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN (	SELECT	TOP 100 PERCENT 
							GGR.cod_clase_garantia,
							GGR.Identificacion_Sicc,
							MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
							MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
						FROM	dbo.GAR_GARANTIA_REAL GGR 
							INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
												MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
											MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
										FROM	
										(		SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMOC MOC
																WHERE	MOC.prmoc_pse_proces = 1
																	AND MOC.prmoc_estado = 'A'
																	AND MOC.prmoc_pnu_contr = 0
																	AND ((MOC.prmoc_pcoctamay > 815)
																		OR (MOC.prmoc_pcoctamay < 815))
																	AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																	AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																	AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																	AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10)
												UNION ALL
												SELECT	MG1.prmgt_pcoclagar,
													MG1.prmgt_pnuidegar,
													CASE 
														WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
														ELSE '19000101'
													END AS prmgt_pfeavaing,
													MG1.prmgt_pmoavaing
												FROM	dbo.GAR_SICC_PRMGT MG1
												WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
													AND MG1.prmgt_estado = 'A'
													AND EXISTS (SELECT	1
																FROM	dbo.GAR_SICC_PRMCA MCA
																WHERE	MCA.prmca_estado = 'A'
																	AND MCA.prmca_pfe_defin < @viFechaActualEntera
																	AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																	AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																	AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																	AND MG1.prmgt_pco_produ = 10
																	AND EXISTS (SELECT	1
																		FROM	dbo.GAR_SICC_PRMOC MC1
																		WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																			AND MC1.prmoc_estado = 'A'	
																			AND ((MC1.prmoc_pcoctamay > 815)
																				OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																			AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																			AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																			AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
										) MG2
										GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
						ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
						AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
						AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
						WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
						GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc
					) GHC
		ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
		AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
	WHERE	GHC.fecha_valuacion > '19000101') TMP
	ON TMP.cod_garantia_real = GV1.cod_garantia_real
	AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Avalp
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Avalp
END	

--FIN RQ: 1-21537427 Y 1-24331191

--INICIO RQ: 1-21537644. Se actualizan algunos datos de la relación entre la garantía real y la operación/contrato a la que este asociada.

--Se actualizan los datos de las garantías reales asociadas a contratos
BEGIN TRANSACTION TRA_Act_Garcontr

UPDATE  GRO
SET     GRO.fecha_constitucion = CASE 
								WHEN MCA.prmca_pfe_const = 0 THEN NULL
								WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
									  AND (LEN(MCA.prmca_pfe_const) = 8)) 
									  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
								ELSE NULL
							 END,
		GRO.fecha_vencimiento = CASE 
								WHEN MCA.prmca_pfe_defin = 0 THEN NULL
								WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
									  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
									  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
								ELSE NULL
							 END,
		GRO.cod_grado_gravamen = MGT.prmgt_pco_grado, 
		GRO.fecha_prescripcion = CASE 
								WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
								WHEN ((ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1) 
									  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
									  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
								ELSE NULL
							 END,
		GRO.cod_tipo_documento_legal = CASE GGR.cod_tipo_garantia_real 
										WHEN 1 THEN CASE MGT.prmgt_pco_grado
														WHEN 1 THEN 1
														WHEN 2 THEN 2
														WHEN 3 THEN 3
														WHEN 4 THEN 4
														ELSE NULL
													END
										WHEN 2 THEN CASE MGT.prmgt_pco_grado
														WHEN 1 THEN 5
														WHEN 2 THEN 6
														WHEN 3 THEN 7
														WHEN 4 THEN 8
														ELSE NULL
													END
										WHEN 3 THEN CASE MGT.prmgt_pco_grado
														WHEN 1 THEN 9
														WHEN 2 THEN 10
														WHEN 3 THEN 11
														WHEN 4 THEN 12
														ELSE NULL
													END
										ELSE NULL
									END
									
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN dbo.GAR_OPERACION GOP
	ON GOP.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_GARANTIA_REAL GGR
	ON GGR.cod_garantia_real = GRO.cod_garantia_real
	INNER JOIN dbo.GAR_SICC_PRMCA MCA
	ON MCA.prmca_pco_ofici = GOP.cod_oficina
	AND MCA.prmca_pco_moned = GOP.cod_moneda
	AND MCA.prmca_pco_produc = GOP.cod_producto
	AND MCA.prmca_pnu_contr = GOP.num_contrato
	INNER JOIN dbo.GAR_SICC_PRMGT MGT
	ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
	AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
	AND MGT.prmgt_pco_produ = 10
	AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
WHERE	GOP.num_contrato > 0
	AND GOP.num_operacion IS NULL
	AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
	AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	AND MGT.prmgt_estado = 'A'

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Garcontr
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Garcontr
END

--FIN RQ: 1-21537644.

--INICIO RQ: 1-23816691. Actualización del indicador de inscripción.
--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vigentes registradas en el sistema
BEGIN TRANSACTION TRA_Act_Grocv

UPDATE	GRO
SET		GRO.cod_inscripcion = CASE MRI.prmri_pcoestins
								WHEN 1 THEN 2
								WHEN 2 THEN 3
								ELSE 1
						  END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN dbo.GAR_OPERACION GO1
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMRI MRI
	ON GO1.cod_oficina = MRI.prmri_pco_ofici
	AND	GO1.cod_moneda = MRI.prmri_pco_moned
	AND MRI.prmri_pco_produ = 10
	AND GO1.num_contrato = MRI.prmri_pnu_opera
WHERE	GO1.num_operacion IS NULL
	AND MRI.prmri_estado = 'A'
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pco_produ = 10
					AND  MGT.prmgt_pco_conta = MRI.prmri_pco_conta
					AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
					AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
					AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
					AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
					AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
									AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMCA MCA
				WHERE MCA.prmca_estado = 'A'
					AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
					AND MCA.prmca_pco_conta = GO1.cod_contabilidad
					AND MCA.prmca_pco_ofici = GO1.cod_oficina
					AND MCA.prmca_pco_moned = GO1.cod_moneda
					AND MCA.prmca_pco_produc = GO1.cod_producto
					AND MCA.prmca_pnu_contr = GO1.num_contrato)

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Grocv
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Grocv
END	

--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vencidos, 
--pero con giros activos, registradas en el sistema
BEGIN TRANSACTION TRA_Act_Grocvga

UPDATE	GRO
SET		GRO.cod_inscripcion = CASE MRI.prmri_pcoestins
								WHEN 1 THEN 2
								WHEN 2 THEN 3
								ELSE 1
						  END
FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
	INNER JOIN dbo.GAR_OPERACION GO1
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN dbo.GAR_SICC_PRMRI MRI
	ON GO1.cod_oficina = MRI.prmri_pco_ofici
	AND	GO1.cod_moneda = MRI.prmri_pco_moned
	AND MRI.prmri_pco_produ = 10
	AND GO1.num_contrato = MRI.prmri_pnu_opera
WHERE	GO1.num_operacion IS NULL
	AND MRI.prmri_estado = 'A'
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pco_produ = 10
					AND  MGT.prmgt_pco_conta = MRI.prmri_pco_conta
					AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
					AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
					AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
					AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
					AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
									AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
	AND EXISTS (SELECT	1
				FROM	dbo.GAR_SICC_PRMCA MCA
			    WHERE	MCA.prmca_estado = 'A'
					AND MCA.prmca_pfe_defin	< @viFechaActualEntera
					AND MCA.prmca_pco_conta = GO1.cod_contabilidad
					AND MCA.prmca_pco_ofici = GO1.cod_oficina
					AND MCA.prmca_pco_moned = GO1.cod_moneda
					AND MCA.prmca_pco_produc = GO1.cod_producto
					AND MCA.prmca_pnu_contr = GO1.num_contrato
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
									AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
									AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

SET @viErrorTran = @@Error

IF(@viErrorTran = 0) 
BEGIN
	COMMIT TRANSACTION TRA_Act_Grocvga
END
ELSE
BEGIN
	ROLLBACK TRANSACTION TRA_Act_Grocvga
END	

--FIN RQ: 1-23816691.
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

