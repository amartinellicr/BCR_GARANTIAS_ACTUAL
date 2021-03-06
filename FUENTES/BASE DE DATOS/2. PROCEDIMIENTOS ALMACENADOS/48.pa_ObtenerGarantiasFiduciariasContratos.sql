USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasFiduciariasContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerGarantiasFiduciariasContratos;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasFiduciariasContratos]
	@piConsecutivo_Operacion BIGINT = NULL,
	@piCodigo_Contabilidad TINYINT,
	@piCodigo_Oficina SMALLINT,
	@piCodigo_Moneda TINYINT,
	@pdNumero_Contrato INT,
	@pbObtener_Solo_Codigo BIT = 0,	
	@psCedula_Usuario VARCHAR(30) = NULL
AS

/******************************************************************
	<Nombre>pa_ObtenerGarantiasFiduciariasContratos</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a las garantías fiduciarias relacionadas a los contratos vigentes.
	</Descripción>
	<Entradas>
		@piConsecutivo_Operacion	= Conseutivo del contrato, del cual se obtendrán las garantías fiduciarias asociadas. 
		@piCodigo_Contabilidad		= Código de la contabilidad del contrato.
		@piCodigo_Oficina			= Número de la oficina del contrato.
		@piCodigo_Moneda			= Código de la moneda del contrato.
		@pdNumero_Contrato			= Número del contrato.
		@pbObtener_Solo_Codigo		= Indica si se obtiene sólo la inforación referente al código del a garantía o la información completa.
		@psCedula_Usuario				= Identificación del usuario que realzia la consulta de la operación.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>N/A</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.4</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>17/11/2010</Fecha>
			<Descripción>
				Se modifica radicalmente la forma en como se obtiene la información, se adapta a la lógica seguida 
				para generar el archivo de garantías reales ligadas a contratos.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortés Mora, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios de almacenado, búsqueda y extracción de datos, Sibel: 1 - 23923921</Requerimiento>
			<Fecha>23/06/2014</Fecha>
			<Descripción>
				Se agrega la extracción de los datos de usuario modificó, fecha de modificación, fecha de inserción 
				y fecha de la réplica.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>02/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
			<Fecha>10/03/2016</Fecha>
			<Descripción>
				El cambio es referente a la extracción de nuevos campos necesarios.
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

	/*Se declara la tabla temporal para poder obtener la información*/
	CREATE TABLE #TMP_GARANTIAS_FIDUCIARIAS_CONTRATOS	(cod_contabilidad			TINYINT,				
														cod_oficina					SMALLINT,			
														cod_moneda					TINYINT,				
														cod_producto				TINYINT,			
														operacion					DECIMAL(16),		
														cedula_fiador				VARCHAR(25) COLLATE DATABASE_DEFAULT,		
														cod_tipo_fiador				SMALLINT,			
														cod_tipo_mitigador			SMALLINT,			
														cod_tipo_documento_legal	SMALLINT,			
														monto_mitigador				DECIMAL(18,2),
														porcentaje_responsabilidad  DECIMAL(5,2),		
														cod_tipo_acreedor			SMALLINT,			
														cedula_acreedor				VARCHAR(30) COLLATE DATABASE_DEFAULT,			
														cod_operacion_especial		SMALLINT,			
														nombre_fiador				VARCHAR(50) COLLATE DATABASE_DEFAULT,			
														cod_garantia_fiduciaria		BIGINT,				
														cod_operacion				BIGINT,				
														cod_tipo_operacion			TINYINT,				
														ind_duplicidad				TINYINT		DEFAULT  (1),
														cod_usuario					VARCHAR(30) COLLATE DATABASE_DEFAULT,
														cod_llave					INT			IDENTITY (1,1) ,
														Usuario_Modifico            VARCHAR(30)  COLLATE DATABASE_DEFAULT,
														Nombre_Usuario_Modifico     VARCHAR(100) COLLATE DATABASE_DEFAULT,
														Fecha_Modifico				DATETIME,
														Fecha_Inserto				DATETIME,
														Fecha_Replica				DATETIME,
														Porcentaje_Aceptacion		DECIMAL(5,2), --RQ_MANT_2015111010495738_00610: Se agrega este campo.
														Indicador_Porcentaje_Responsabilidad_Maximo BIT, --RQ_MANT_2015111010495738_00615: Se agrega este campo.
														Indicador_Cuenta_Contable_Especial  BIT --RQ_MANT_2015111010495738_00615: Se agrega este campo.
														PRIMARY KEY (cod_llave))

	/*Esta tabla almacenará las garantías fiduciarias del SICC que estén activas*/
	CREATE TABLE #TEMP_GAR_FIADORES (	prmgt_pcoclagar TINYINT,
										prmgt_pnuidegar DECIMAL(12,0))
		 
	CREATE INDEX TEMP_GAR_FIADORES_IX_01 ON #TEMP_GAR_FIADORES (prmgt_pcoclagar, prmgt_pnuidegar)

	/*Se determina si se ha enviado el consecutivo del contrato*/
	IF(@piConsecutivo_Operacion IS NULL)
	BEGIN
		SET @piConsecutivo_Operacion = (SELECT	cod_operacion 
							  FROM	dbo.GAR_OPERACION
							  WHERE	cod_contabilidad = @piCodigo_Contabilidad
								AND cod_oficina = @piCodigo_Oficina
								AND cod_moneda = @piCodigo_Moneda
								AND num_contrato = @pdNumero_Contrato
								AND num_operacion IS NULL)
	END
	
	/*Se obtienen los fiadores relacionados a los contratos vigentes*/
	INSERT	INTO #TEMP_GAR_FIADORES(prmgt_pcoclagar, prmgt_pnuidegar)
	SELECT	MGT.prmgt_pcoclagar,
			MGT.prmgt_pnuidegar
	FROM	dbo.GAR_SICC_PRMGT MGT
		INNER JOIN	dbo.GAR_SICC_BSMCL MCL
		ON MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
	WHERE	 MGT.prmgt_pnu_oper = @pdNumero_Contrato
		AND MGT.prmgt_pco_ofici = @piCodigo_Oficina
		AND MGT.prmgt_pco_moned = @piCodigo_Moneda
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = @piCodigo_Contabilidad
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = 0
		AND MCL.bsmcl_estado = 'A'


	/*Se obtiene la información de las garantías fiduciarias ligadas al contrato y se insertan en la tabla temporal*/
	INSERT #TMP_GARANTIAS_FIDUCIARIAS_CONTRATOS 
	SELECT	DISTINCT
		GO1.cod_contabilidad, 
		GO1.cod_oficina, 
		GO1.cod_moneda, 
		GO1.cod_producto, 
		GO1.num_contrato AS operacion, 
		GGF.cedula_fiador, 
		COALESCE(GGF.cod_tipo_fiador, -1) AS cod_tipo_fiador,
		COALESCE(GFO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		COALESCE(GFO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal, 
		GFO.monto_mitigador, 
		COALESCE(GFO.porcentaje_responsabilidad, -1) AS porcentaje_responsabilidad, 
		CASE GFO.cod_tipo_acreedor 
			WHEN NULL THEN 2 
			WHEN -1 THEN 2 
			ELSE GFO.cod_tipo_acreedor 
		END AS cod_tipo_acreedor, 
		COALESCE(GFO.cedula_acreedor, '') AS cedula_acreedor, 
		COALESCE(GFO.cod_operacion_especial, 0) AS cod_operacion_especial,
		GGF.nombre_fiador,
		GFO.cod_garantia_fiduciaria,
		GO1.cod_operacion,
		2 AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		@psCedula_Usuario AS cod_usuario,
		COALESCE(GGF.Usuario_Modifico, '') AS Usuario_Modifico,
		COALESCE (SU1.DES_USUARIO,'') AS Nombre_Usuario_Modifico,
		COALESCE(GGF.Fecha_Modifico,'1900-01-01') AS Fecha_Modifico,
		COALESCE(GGF.Fecha_Inserto,'1900-01-01') AS Fecha_Inserto,
		COALESCE(GGF.Fecha_Replica,'1900-01-01') AS Fecha_Replica,
		COALESCE(GFO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		GFO.Indicador_Porcentaje_Responsabilidad_Maximo, --RQ_MANT_2015111010495738_00615: Se agrega este campo.		
		0 AS Indicador_Cuenta_Contable_Especial --RQ_MANT_2015111010495738_00615: Se agrega este campo.	
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO 
		ON GO1.cod_operacion = GFO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF 
		ON GGF.cod_garantia_fiduciaria = GFO.cod_garantia_fiduciaria
		INNER JOIN #TEMP_GAR_FIADORES TGF
		ON GGF.cod_clase_garantia = TGF.prmgt_pcoclagar
		AND GGF.Identificacion_Sicc = TGF.prmgt_pnuidegar
		LEFT JOIN dbo.SEG_USUARIO SU1
		ON SU1.COD_USUARIO  = GGF.Usuario_Modifico COLLATE DATABASE_DEFAULT
	WHERE	GO1.cod_operacion = @piConsecutivo_Operacion
	ORDER BY
		GO1.cod_contabilidad,
		GO1.cod_oficina,	
		GO1.cod_moneda,
		GO1.cod_producto,
		GO1.num_contrato,
		GGF.cedula_fiador,
		GFO.cod_tipo_documento_legal DESC


	/*Se eliminan los registros duplicados*/
	WITH CTE (cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion  ORDER BY cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_FIDUCIARIAS_CONTRATOS
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se selecciona la información sobre las garantías del contrato*/
	IF(@pbObtener_Solo_Codigo = 1)
	BEGIN
		SELECT	DISTINCT '[Fiador] ' + TGF.cedula_fiador + ' - ' + TGF.nombre_fiador AS garantia				
		FROM	#TMP_GARANTIAS_FIDUCIARIAS_CONTRATOS TGF
			LEFT OUTER JOIN CAT_ELEMENTO CE1
			ON CE1.cat_campo = TGF.cod_tipo_fiador
		WHERE	TGF.cod_usuario = @psCedula_Usuario
			AND TGF.cod_tipo_operacion = 2
			AND CE1.cat_catalogo = 1 
		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT	DISTINCT 
			COALESCE(CE1.cat_descripcion, 'Sin Definir') AS tipo_persona, 
			TGF.cedula_fiador, 
			TGF.nombre_fiador, 
			TGF.cod_tipo_fiador, 
			TGF.cod_tipo_mitigador, 
			TGF.cod_tipo_documento_legal, 
			TGF.monto_mitigador, 
			TGF.porcentaje_responsabilidad, 
			TGF.cod_operacion_especial, 
			TGF.cod_tipo_acreedor, 
			TGF.cedula_acreedor, 
			TGF.cod_operacion, 
			TGF.cod_garantia_fiduciaria,
			1 AS cod_estado,
			TGF.Usuario_Modifico,
			TGF.Nombre_Usuario_Modifico,
			TGF.Fecha_Modifico,
			TGF.Fecha_Inserto,
			TGF.Fecha_Replica,
			TGF.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			TGF.Indicador_Porcentaje_Responsabilidad_Maximo, --RQ_MANT_2015111010495738_00615: Se agrega este campo.
			TGF.Indicador_Cuenta_Contable_Especial --RQ_MANT_2015111010495738_00615: Se agrega este campo.
		FROM	#TMP_GARANTIAS_FIDUCIARIAS_CONTRATOS TGF
			LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1
			ON CE1.cat_catalogo = 1
			AND TGF.cod_tipo_fiador = CE1.cat_campo
		WHERE	TGF.cod_usuario = @psCedula_Usuario
			AND TGF.cod_tipo_operacion = 2
		ORDER BY
			tipo_persona,
			cedula_fiador
	END
END
