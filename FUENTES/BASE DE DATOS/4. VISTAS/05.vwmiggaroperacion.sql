USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggaroperacion]
	AS

/******************************************************************
<Nombre>vwmiggaroperacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las operaciones que serán migradas</Descripción>
<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
<Fecha>28/08/2009</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/

	SELECT O.*, 
		D.DeudorCodeudor_cod_iddeudor, 
		D.TiposPersonas_cod_tipo_persona,	
		D.cedulaRelacion AS cedulaRelacionDeudor,
		D.cedula_deudor_sugef,
		D.ind_actualizo_cedulasugef

	FROM vwmiggardeudorcodeudor D, 
	(
	/*
		Operaciones de crédito
	*/
	SELECT
		cod_operacion,
		'OPERACION' AS cocTipo,

		LTRIM(RTRIM(CONVERT(VARCHAR(2), cod_contabilidad))) + 
		RIGHT('000' + LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_oficina))), 3) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_moneda))) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(2), cod_producto))) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(10), num_operacion))) AS OperacionesGarantias_cod_idoperacion,

		
		cod_oficina AS Oficinas_cod_oficina,
		cod_contabilidad AS Operaciones_cod_contabilidad,
		cod_estado AS Operaciones_ind_activa,
		num_operacion AS Operaciones_num_operacion,
		CONVERT(bigint, NULL) AS Operaciones_num_contrato,
		cedula_deudor AS cedulaRelacion,
		cod_producto AS TiposProductos_cod_tipo_producto,
		cod_moneda AS TiposMonedas_cod_tipo_moneda,		
		monto_original AS OperacionesGarantias_mon_original	
	FROM GAR_OPERACION
	WHERE num_contrato = 0
	AND cod_estado = 1
	UNION ALL
	/*
		Giros de contrato
	*/
	SELECT 
		cod_operacion,
		'GIRO' AS cocTipo,

		LTRIM(RTRIM(CONVERT(VARCHAR(2), cod_contabilidad))) + 
		RIGHT('000' + LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_oficina))), 3) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_moneda))) +  
		LTRIM(RTRIM(CONVERT(VARCHAR(2), cod_producto))) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(10), num_operacion))) AS OperacionesGarantias_cod_idoperacion,

		
		cod_oficina AS Oficinas_cod_oficina,
		cod_contabilidad AS Operaciones_cod_contabilidad,
		cod_estado AS Operaciones_ind_activa,
		CONVERT(bigint, num_operacion) AS Operaciones_num_operacion,
		num_contrato AS Operaciones_num_contrato,
		cedula_deudor AS DeudorCodeudor_cod_iddeudor,
		cod_producto AS TiposProductos_cod_tipo_producto,
		cod_moneda AS TiposMonedas_cod_tipo_moneda,		
		monto_original AS OperacionesGarantias_mon_original
	FROM GAR_OPERACION
	WHERE num_contrato > 0
	AND num_operacion IS NOT NULL
	AND cod_estado = 1
	UNION ALL
	/*
		Contratos
	*/
	SELECT 
		cod_operacion,
		'CONTRATO' AS cocTipo,

		LTRIM(RTRIM(CONVERT(VARCHAR(2), cod_contabilidad))) + 
		RIGHT('000' + LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_oficina))), 3) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(4), cod_moneda))) + 
		LTRIM(RTRIM(CONVERT(VARCHAR(10), num_contrato))) AS OperacionesGarantias_cod_idoperacion,

		
		cod_oficina AS Oficinas_cod_oficina,
		cod_contabilidad AS Operaciones_cod_contabilidad,
		cod_estado AS Operaciones_ind_activa,
		--Volver a poner el NULO
		CONVERT(bigint, num_operacion) AS Operaciones_num_operacion,
		num_contrato AS Operaciones_num_contrato,
		cedula_deudor AS DeudorCodeudor_cod_iddeudor,
		6 AS TiposProductos_cod_tipo_producto,
		cod_moneda AS TiposMonedas_cod_tipo_moneda,		
		ISNULL(monto_original, 0) AS OperacionesGarantias_mon_original
	FROM GAR_OPERACION
	WHERE num_operacion IS NULL
	AND num_contrato > 0
	AND cod_estado = 1) AS O
	
	WHERE D.cedulaRelacion = O.cedulaRelacion
