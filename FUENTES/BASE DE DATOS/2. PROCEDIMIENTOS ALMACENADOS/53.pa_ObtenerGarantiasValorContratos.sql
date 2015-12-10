USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasValorContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerGarantiasValorContratos;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasValorContratos]
	@piConsecutivo_Operacion BIGINT = NULL,
	@piCodigo_Contabilidad TINYINT,
	@piCodigo_Oficina SMALLINT,
	@piCodigo_Moneda TINYINT,
	@pdNumero_Contrato INT,
	@pbObtener_Solo_Codigo BIT = 0,
	@psCedula_Usuario VARCHAR(30) = NULL
AS

/******************************************************************
<Nombre>pa_ObtenerGarantiasValorContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento almacenado que obtiene la información referente a las garantías de valor 
			 relacionadas a los contratos vigentes.
</Descripción>
<Entradas>
	@piConsecutivo_Operacion	= Código de la operación
	@piCodigo_Contabilidad		= Código de la contabilidad a la que pertenece el contrato
	@piCodigo_Oficina			= Oficina donde se realizó la transacción
	@piCodigo_Moneda			= Código de la moneda en la que se encuentra el contrato
	@pdNumero_Contrato			= Código del contrato.
	@pbObtener_Solo_Codigo		= Indicador (tipo bit) que determina la información de salida del procedimiento almacenado.
	@psCedula_Usuario				= Identificación del usuario que realiza la consulta. Eso permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
		<Requerimiento>N/A</Requerimiento>
		<Fecha>17/11/2010</Fecha>
		<Descripción>Se modifica radicalmente la forma en como se obtiene la información, se adapta a la lógica seguida 
				     para generar el archivo de garantías de valor ligadas a contratos.
		</Descripción>
	</Cambio>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>04/12/2015</Fecha>
		<Descripción>
			Se realiza un ajuste general, en el que se eliminan aquellos campos que no son requeridos en la información retornada,
			también se optimizan los mecanismo empleados para la obtención de los registros y la eliminación de posibles duplicados.  
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

	/*Se declara la variable tipo tabla que funcionara como maestra*/
	CREATE TABLE #TMP_GARANTIAS_VALOR_CONTRATO (	cod_contabilidad				TINYINT,
													cod_oficina						SMALLINT,
													cod_moneda						TINYINT,
													cod_producto					TINYINT,
													operacion						DECIMAL (7,0),
													numero_seguridad				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
													cod_tipo_mitigador				SMALLINT,
													cod_tipo_documento_legal		SMALLINT,
													fecha_presentacion				VARCHAR (10)	COLLATE DATABASE_DEFAULT,
													cod_inscripcion					SMALLINT,
													cod_tipo_garantia				SMALLINT,
													cod_clase_garantia				SMALLINT,
													cod_garantia_valor				BIGINT,
													cod_operacion					BIGINT,
													cod_estado						SMALLINT,
													cod_tipo_operacion				TINYINT,
													ind_duplicidad					TINYINT			DEFAULT (1)	,
													cod_usuario						VARCHAR (30)	COLLATE DATABASE_DEFAULT,
													cod_llave						BIGINT			IDENTITY(1,1)
													PRIMARY KEY (cod_llave)
												)

	/*Esta tabla almacenará las garantías de valor del SICC que estén activas*/
	CREATE TABLE #TEMP_GAR_VALORES (	prmgt_pcoclagar TINYINT,
										prmgt_pnuidegar DECIMAL(12,0))
		 
	CREATE INDEX TEMP_GAR_VALORES_IX_01 ON #TEMP_GAR_VALORES (prmgt_pcoclagar, prmgt_pnuidegar)

		
	/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
	DECLARE
		@lfecHoySinHora DATETIME,
		@lintFechaEntero INT

	SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @lintFechaEntero =  CONVERT(int, CONVERT(VARCHAR(8), @lfecHoySinHora, 112))

	/*Se determina si se ha enviado el consecutivo del contrato*/
	IF(@piConsecutivo_Operacion IS NULL)
	BEGIN
		SET @piConsecutivo_Operacion = (	SELECT	cod_operacion 
									FROM	dbo.GAR_OPERACION
									WHERE	cod_contabilidad = @piCodigo_Contabilidad
										AND cod_oficina = @piCodigo_Oficina
										AND cod_moneda = @piCodigo_Moneda
										AND num_contrato = @pdNumero_Contrato
										AND num_operacion IS NULL)
	END

	/*Se obtienen los fiadores relacionados a los contratos vigentes*/
	INSERT	INTO #TEMP_GAR_VALORES(prmgt_pcoclagar, prmgt_pnuidegar)
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
		AND MGT.prmgt_pcoclagar  BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar  IN (2,3,4,6)
		AND MCL.bsmcl_estado = 'A'


	/*Se selecciona la información de la garantía de valor asociada a los contratos*/
	INSERT	INTO #TMP_GARANTIAS_VALOR_CONTRATO
	SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_contrato AS operacion, 
			GGV.numero_seguridad AS numero_seguridad, 
			COALESCE(GVO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador,
			COALESCE(GVO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GVO.fecha_presentacion_registro, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			COALESCE(GVO.cod_inscripcion, -1) AS cod_inscripcion,
			GGV.cod_tipo_garantia,
			GGV.cod_clase_garantia,
			GVO.cod_garantia_valor,
			GVO.cod_operacion,
			GVO.cod_estado,
			2 AS cod_tipo_operacion,	
			@psCedula_Usuario AS cod_usuario	
	FROM	dbo.GAR_OPERACION GO1
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO 
		ON GVO.cod_operacion = GO1.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
		ON GGV.cod_garantia_valor = GVO.cod_garantia_valor 
		INNER JOIN #TEMP_GAR_VALORES TGV
		ON GGV.cod_clase_garantia = TGV.prmgt_pcoclagar
		AND GGV.Identificacion_Sicc = TGV.prmgt_pnuidegar
	WHERE	GO1.cod_operacion = @piConsecutivo_Operacion
	ORDER BY
		cod_operacion,
		numero_seguridad,
		cod_tipo_documento_legal DESC

	/*Se eliminan los registros incompletos*/
	DELETE	FROM #TMP_GARANTIAS_VALOR_CONTRATO
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_documento_legal = -1
		AND fecha_presentacion = '19000101'
		AND cod_tipo_mitigador = -1
		AND cod_inscripcion = -1

	/*Se eliminan los registros duplicados*/
	WITH CTE (numero_seguridad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	numero_seguridad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion,
				ROW_NUMBER() OVER(PARTITION BY numero_seguridad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion  ORDER BY numero_seguridad, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion) AS cantidadRegistrosDuplicados
		FROM	#TMP_GARANTIAS_VALOR_CONTRATO
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	IF(@pbObtener_Solo_Codigo = 1)
	BEGIN
		SELECT	DISTINCT '[Número de Seguridad] ' + GVC.numero_seguridad AS garantia
		FROM	#TMP_GARANTIAS_VALOR_CONTRATO GVC
			INNER JOIN CAT_ELEMENTO CE1
			ON CE1.cat_campo = GVC.cod_clase_garantia 
		WHERE	GVC.cod_tipo_operacion = 2 
			AND GVC.cod_usuario = @psCedula_Usuario
			AND CE1.cat_catalogo= 7 
		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT	DISTINCT 
				GVC.cod_operacion, 
				GVC.cod_garantia_valor, 
				CONVERT(VARCHAR(3),CE1.cat_campo) + ' - ' + CE1.cat_descripcion AS des_clase_garantia, 
				GVC.numero_seguridad 
		FROM	#TMP_GARANTIAS_VALOR_CONTRATO GVC
			INNER JOIN CAT_ELEMENTO CE1
			ON CE1.cat_campo = GVC.cod_clase_garantia 
		WHERE	GVC.cod_usuario = @psCedula_Usuario
			AND CE1.cat_catalogo= 7 
		ORDER BY	GVC.numero_seguridad
	END
END
