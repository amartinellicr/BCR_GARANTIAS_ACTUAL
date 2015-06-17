SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasFiduciariasOperaciones]
	@nCodOperacion BIGINT = NULL,
	@nContabilidad TINYINT,
	@nOficina SMALLINT,
	@nMoneda TINYINT,
	@nProducto TINYINT,
	@nOperacion DECIMAL(7),
	@nObtenerSoloCodigo BIT = 0,
	@IDUsuario VARCHAR(30) = NULL
AS

/******************************************************************
<Nombre>pa_ObtenerGarantiasFiduciariasOperaciones</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener las garantías fiduciarias que posee una operación.</Descripción>
<Entradas>
	@nCodOperacion		= Consecutivo de la operación.
	@nContabilidad		= Código de la contabilidad a la que pertenece el contrato
	@nOficina			= Oficina donde se realizó la transacción
	@nMoneda			= Código de la moneda en la que se encuentra el contrato
	@nProducto			= Código del producto.
	@nOperación			= Número de la operación a consultar
	@nObtenerSoloCodigo = Indicador (tipo bit) que determina la información de salida del procedimiento almacenado.
	@IDUsuario			= Identificación del usuario que realiza la consulta. Eso permite la concurrencia.
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
		<Descripción>Se modifica radicalmente la forma en como se obtiene la información, se adapta a la 
                     lógica seguida para generar el archivo de garantías fiduciarias ligadas a operaciones 
                     y giros.
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

	DECLARE @bEsGiro BIT,
			@nCodigoOperacion BIGINT

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion IN (1, 3) AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario

	/*Se declara una variable de tipo tabla, esta funcionará como tabla temporal para poder obtener la información*/
	DECLARE @TMP_GARANTIAS_FIDUCIARIAS TABLE (  cod_contabilidad			tinyint,				
												cod_oficina					smallint,			
												cod_moneda					tinyint,				
												cod_producto				tinyint,			
												operacion					decimal(16),		
												cedula_fiador				varchar(25) collate database_default,		
												cod_tipo_fiador				smallint,			
												cod_tipo_mitigador			smallint,			
												cod_tipo_documento_legal	smallint,			
												monto_mitigador				decimal(18,2),
												porcentaje_responsabilidad  decimal(5,2),		
												cod_tipo_acreedor			smallint,			
												cedula_acreedor				varchar(30) collate database_default,			
												cod_operacion_especial		smallint,			
												nombre_fiador				varchar(50) collate database_default,			
												cod_garantia_fiduciaria		bigint,				
												cod_operacion				bigint,				
												cod_tipo_operacion			tinyint,				
												ind_duplicidad				tinyint		DEFAULT  (1),
												cod_usuario					varchar(30) collate database_default,
												cod_llave					int			IDENTITY (1,1) 
												PRIMARY KEY (cod_llave))

	/*Se determina si se ha enviado el consecutivo de la operación*/
	IF(@nCodOperacion IS NULL)
	BEGIN
		SET @nCodOperacion = (SELECT cod_operacion 
							  FROM dbo.GAR_OPERACION
							  WHERE cod_contabilidad = @nContabilidad
								AND cod_oficina = @nOficina
								AND cod_moneda = @nMoneda
								AND cod_producto = @nProducto
								AND num_operacion = @nOperacion
								AND cod_estado = 1)
	END


	/*Se determina si es un giro, ante lo cual, se procederá a obtener el consecutivo del contrato al cual está asociado dicho giro, esto con la
      la finalidad de obtener las garantías asociadas al mismo. En caso de no ser un giro, entonces se uitliza el consecutivo pasado o encontrado anteirormente*/
	SET @bEsGiro = CASE WHEN (SELECT num_contrato FROM dbo.GAR_OPERACION WHERE cod_operacion = @nCodOperacion AND num_operacion IS NOT NULL AND num_contrato > 0) > 0 THEN 1
				       ELSE 0
				  END

	IF(@bEsGiro = 1)
	BEGIN
		SET @nCodigoOperacion = (SELECT DISTINCT b.cod_operacion
								 FROM 
								(SELECT prmca_pco_conta, prmca_pco_ofici, prmca_pco_moned, 
										prmca_pco_produc, prmca_pnu_contr
								 FROM dbo.GAR_SICC_PRMOC d
								 INNER JOIN  dbo.GAR_SICC_PRMCA e
								  ON e.prmca_pco_ofici = d.prmoc_pco_oficon
								  AND e.prmca_pco_moned = d.prmoc_pcomonint
								  AND e.prmca_pnu_contr = d.prmoc_pnu_contr
								 WHERE d.prmoc_pco_conta = @nContabilidad
									AND d.prmoc_pco_ofici = @nOficina
									AND d.prmoc_pco_moned = @nMoneda
									AND d.prmoc_pco_produ = @nProducto
									AND d.prmoc_pnu_oper = @nOperacion) a
							 INNER JOIN dbo.GAR_OPERACION b
							  ON b.cod_contabilidad = a.prmca_pco_conta
							  AND b.cod_oficina = a.prmca_pco_ofici
							  AND b.cod_moneda = a.prmca_pco_moned
							  AND b.cod_producto = a.prmca_pco_produc
							  AND b.num_contrato = a.prmca_pnu_contr
							 WHERE b.num_operacion IS NULL)
	END
	ELSE
	BEGIN
		SET @nCodigoOperacion = @nCodOperacion
	END
	
	/*Se procede a obtener la información de las garantías aosciadas a la operación*/
	INSERT INTO @TMP_GARANTIAS_FIDUCIARIAS
	SELECT DISTINCT
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_operacion AS operacion, 
		c.cedula_fiador, 
		ISNULL(c.cod_tipo_fiador, -1) AS cod_tipo_fiador,
		ISNULL(b.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
		ISNULL(b.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal, 
		b.monto_mitigador, 
		ISNULL(b.porcentaje_responsabilidad, 0 ) AS porcentaje_responsabilidad, 
		CASE b.cod_tipo_acreedor 
			WHEN NULL THEN 2 
			WHEN -1 THEN 2 
			ELSE b.cod_tipo_acreedor 
		END AS cod_tipo_acreedor, 
		ISNULL(b.cedula_acreedor, '') AS cedula_acreedor, 
		ISNULL(b.cod_operacion_especial, 0) AS cod_operacion_especial,
		c.nombre_fiador,
		b.cod_garantia_fiduciaria,
		a.cod_operacion,
		CASE WHEN @bEsGiro = 1 THEN 3
			 ELSE 1
		END AS cod_tipo_operacion,
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b 
		 ON a.cod_operacion = b.cod_operacion 
		INNER JOIN GAR_GARANTIA_FIDUCIARIA c 
		 ON c.cod_garantia_fiduciaria = b.cod_garantia_fiduciaria
		

	WHERE a.cod_operacion = @nCodigoOperacion
		AND b.cod_estado = CASE	WHEN @bEsGiro = 1 THEN b.cod_estado
								ELSE 1
							END
--		AND EXISTS (SELECT 1
--					FROM dbo.GAR_SICC_PRMGT g
--					WHERE g.prmgt_pco_conta = a.cod_contabilidad
--					 AND g.prmgt_pco_ofici  = a.cod_oficina
--					 AND g.prmgt_pco_moned  = a.cod_moneda
--					 AND g.prmgt_pco_produ  = CASE	WHEN @bEsGiro = 0 THEN a.cod_producto 
--													ELSE 10
--											  END
--					 AND g.prmgt_pnu_oper   = CASE	WHEN @bEsGiro = 0 THEN a.num_operacion 
--													ELSE a.num_contrato
--											  END
--					 AND g.prmgt_pcoclagar  = c.cod_clase_garantia
--					 AND g.prmgt_pnuidegar  = dbo.ufn_ConvertirCodigoGarantia(c.cedula_fiador)
--					 AND g.prmgt_estado = 'A')/*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura del SICC*/

	ORDER BY
		a.cod_contabilidad,
		a.cod_oficina,	
		a.cod_moneda,
		a.cod_producto,
		a.num_operacion,
		c.cedula_fiador,
		b.cod_tipo_documento_legal DESC


	/*Se obtienen las operaciones que se encuentran duplicadas*/
	INSERT INTO TMP_OPERACIONES_DUPLICADAS
	SELECT	cod_oficina, 
			cod_moneda,	
			cod_producto, 
			operacion,
			cod_tipo_operacion,
			cedula_fiador AS cod_garantia_sicc,
			1 AS cod_tipo_garantia,
			@IDUsuario AS cod_usuario,
			MAX(cod_garantia_fiduciaria) AS cod_garantia,
			NULL AS cod_grado

	FROM @TMP_GARANTIAS_FIDUCIARIAS
	
	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion IN (1, 3)

	GROUP BY cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion
	HAVING COUNT(1) > 1


	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
	  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN @TMP_GARANTIAS_FIDUCIARIAS TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM @TMP_GARANTIAS_FIDUCIARIAS T
								WHERE T.cod_oficina = D.cod_oficina
								AND T.cod_moneda = D.cod_moneda
								AND T.cod_producto = D.cod_producto
								AND T.operacion = D.operacion
								AND ISNULL(T.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
								AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
								AND D.cod_tipo_operacion IN (1, 3)
								AND D.cod_tipo_garantia = 1)
	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion IN (1, 3)


	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE @TMP_GARANTIAS_FIDUCIARIAS
	SET ind_duplicidad = 2
	FROM @TMP_GARANTIAS_FIDUCIARIAS GF
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGF
				  WHERE GF.cod_oficina = TGF.cod_oficina
					AND GF.cod_moneda = TGF.cod_moneda
					AND GF.cod_producto = TGF.cod_producto
					AND GF.operacion = TGF.operacion
					AND ISNULL(GF.cedula_fiador, '') = ISNULL(TGF.cod_garantia_sicc, '')
					AND ISNULL(GF.cod_usuario, '') = ISNULL(TGF.cod_usuario, '')
					AND GF.cod_llave <> TGF.cod_garantia
					AND TGF.cod_tipo_operacion IN (1, 3)
					AND TGF.cod_tipo_garantia = 1)
	AND GF.cod_usuario = @IDUsuario
	AND GF.cod_tipo_operacion IN (1, 3)


	/*Se eliminan aquellas garantías que se encuentran con tienen un indicador de duplicidad igual a 2 de un mismo usuario*/
	DELETE FROM @TMP_GARANTIAS_FIDUCIARIAS 
		WHERE cod_tipo_operacion IN (1, 3)
			AND ind_duplicidad = 2 
			AND cod_usuario = @IDUsuario 
	

	/*Se selecciona la información sobre las garantías de la operación o giro*/
	IF(@nObtenerSoloCodigo = 1)
	BEGIN
		SELECT DISTINCT '[Fiador] ' + a.cedula_fiador + ' - ' + a.nombre_fiador AS garantia
					
		FROM @TMP_GARANTIAS_FIDUCIARIAS a
		LEFT OUTER JOIN CAT_ELEMENTO b
			ON b.cat_campo = a.cod_tipo_fiador

		WHERE a.cod_tipo_operacion IN (1, 3)
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo = 1 

		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT DISTINCT 
		b.cat_descripcion as tipo_persona, 
		a.cedula_fiador, 
		a.nombre_fiador, 
		a.cod_tipo_fiador, 
		a.cod_tipo_mitigador, 
		a.cod_tipo_documento_legal, 
		a.monto_mitigador, 
		a.porcentaje_responsabilidad, 
		a.cod_operacion_especial, 
		a.cod_tipo_acreedor, 
		a.cedula_acreedor, 
		@nCodOperacion AS cod_operacion, 
		a.cod_garantia_fiduciaria,
		1 AS cod_estado

		FROM @TMP_GARANTIAS_FIDUCIARIAS a
		LEFT OUTER JOIN CAT_ELEMENTO b
			ON b.cat_campo = a.cod_tipo_fiador

		WHERE a.cod_tipo_operacion IN (1, 3)
			AND a.cod_usuario = @IDUsuario
			AND b.cat_catalogo = 1 

		ORDER BY
			tipo_persona,
			cedula_fiador
	END

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion IN (1, 3) AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario



END
