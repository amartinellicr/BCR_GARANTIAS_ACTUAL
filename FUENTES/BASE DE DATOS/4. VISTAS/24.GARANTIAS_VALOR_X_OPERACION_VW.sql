USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GARANTIAS_VALOR_X_OPERACION_VW]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[GARANTIAS_VALOR_X_OPERACION_VW]
GO


CREATE VIEW [dbo].[GARANTIAS_VALOR_X_OPERACION_VW]
AS
/******************************************************************
	<Nombre>OPERACIONES_INCONSISTENCIAS_VW</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Vista que obtiene las operaciones que poseen asociadas garantías de valor, que pueden ser accedidas desde la aplicación web, que 
				 serán evaludas con la finalidad de obtener algún tipo de inconsistencia
	</Descripción>
	<Entradas>
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>08/06/2012</Fecha>
	<Requerimiento>Indicador de Inscripción, Sibel: 1 - 21317031</Requerimiento>
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

SELECT	DISTINCT	GRO.cod_operacion, 
					GRO.cod_garantia, 
					GRO.cod_tipo_garantia, 
					GRO.cod_tipo_operacion,		
					GRO.cod_oficina, 
					GRO.cod_moneda, 
					GRO.cod_producto, 
					GRO.num_operacion, 
					GRO.num_contrato, 
					GRO.cod_oficina_contrato, 
					GRO.cod_moneda_contrato, 
					GRO.cod_producto_contrato
FROM (
		/*Se carga la información del as garantías de valor asociadas a operaciones directas y contratos*/
		SELECT	
				OPE.cod_operacion,
				GVO.cod_garantia_valor AS cod_garantia,
				3 AS cod_tipo_garantia, -- Garantías de Valor
				1 AS cod_tipo_operacion, -- Operaciones Directas
				OPE.cod_oficina,
				OPE.cod_moneda,
				OPE.cod_producto,
				OPE.num_operacion,
				NULL AS num_contrato,
				NULL AS cod_oficina_contrato,
				NULL AS cod_moneda_contrato,
				NULL AS cod_producto_contrato
		FROM dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
			INNER JOIN dbo.GAR_OPERACION OPE
			ON OPE.cod_operacion = GVO.cod_operacion
		WHERE OPE.num_contrato = 0
			AND EXISTS (SELECT 1  
						FROM dbo.GAR_SICC_PRMOC PMC 
						WHERE PMC.prmoc_pnu_oper	= OPE.num_operacion
						AND PMC.prmoc_pco_ofici		= OPE.cod_oficina
						AND PMC.prmoc_pco_moned		= OPE.cod_moneda
						AND PMC.prmoc_pco_produ		= OPE.cod_producto
						AND PMC.prmoc_pco_conta		= OPE.cod_contabilidad
						AND PMC.prmoc_pcoctamay		<> 815	--Operaciones no insolutas
						AND PMC.prmoc_pse_proces	= 1	--Operaciones activas
						AND PMC.prmoc_estado		= 'A')

		UNION ALL
		--Se cargan los contratos vigentes
		SELECT	
				OPE.cod_operacion,
				GVO.cod_garantia_valor AS cod_garantia,
				3 AS cod_tipo_garantia, -- Garantías de Valor
				2 AS cod_tipo_operacion, -- Contratos
				NULL AS cod_oficina,
				NULL AS cod_moneda,
				NULL AS cod_producto,
				NULL AS num_operacion,
				OPE.num_contrato AS num_contrato,
				OPE.cod_oficina AS cod_oficina_contrato,
				OPE.cod_moneda AS cod_moneda_contrato,
				OPE.cod_producto AS cod_producto_contrato
		FROM dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
			INNER JOIN dbo.GAR_OPERACION OPE
			ON OPE.cod_operacion = GVO.cod_operacion
		WHERE OPE.num_operacion IS NULL
			AND EXISTS (SELECT 1 
						FROM dbo.GAR_SICC_PRMCA PMA
						WHERE PMA.prmca_pnu_contr	= OPE.num_contrato
						AND PMA.prmca_pco_ofici		= OPE.cod_oficina
						AND PMA.prmca_pco_moned		= OPE.cod_moneda
						AND PMA.prmca_pco_produc	= OPE.cod_producto
						AND PMA.prmca_pco_conta		= OPE.cod_contabilidad
						AND PMA.prmca_pfe_defin		>= CONVERT(int, CONVERT(varchar(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
						AND PMA.prmca_estado		= 'A')
		
		UNION ALL
		--Se cargan los contratos vencidos con giros activos
		SELECT	
				OPE.cod_operacion,
				GVO.cod_garantia_valor AS cod_garantia,
				3 AS cod_tipo_garantia, -- Garantías de Valor
				2 AS cod_tipo_operacion, -- Contratos
				NULL AS cod_oficina,
				NULL AS cod_moneda,
				NULL AS cod_producto,
				NULL AS num_operacion,
				OPE.num_contrato AS num_contrato,
				OPE.cod_oficina AS cod_oficina_contrato,
				OPE.cod_moneda AS cod_moneda_contrato,
				OPE.cod_producto AS cod_producto_contrato
		FROM dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
			INNER JOIN dbo.GAR_OPERACION OPE
			ON OPE.cod_operacion = GVO.cod_operacion
		WHERE OPE.num_operacion IS NULL
			AND EXISTS (SELECT 1 
						FROM dbo.GAR_SICC_PRMCA PMA
						WHERE PMA.prmca_pnu_contr	= OPE.num_contrato
						AND PMA.prmca_pco_ofici		= OPE.cod_oficina
						AND PMA.prmca_pco_moned		= OPE.cod_moneda
						AND PMA.prmca_pco_produc	= OPE.cod_producto
						AND PMA.prmca_pco_conta		= OPE.cod_contabilidad
						AND PMA.prmca_pfe_defin		< CONVERT(INT, CONVERT(varchar(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
						AND PMA.prmca_estado		= 'A'
						AND EXISTS (SELECT 1
									FROM dbo.GAR_SICC_PRMOC PMC
									WHERE PMC.prmoc_pse_proces		= 1		--Operaciones activas
										AND PMC.prmoc_pcoctamay		<> 815	--Operaciones no insolutas
										AND PMC.prmoc_estado		= 'A'
										AND PMC.prmoc_pnu_contr		= PMA.prmca_pnu_contr	
										AND PMC.prmoc_pco_oficon	= PMA.prmca_pco_ofici
										AND PMC.prmoc_pcomonint		= PMA.prmca_pco_moned))
) GRO