SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasFiduciariasContratos]
	@IDUsuario varchar(30)
AS

/******************************************************************
<Nombre>pa_GenerarInfoGarantiasFiduciariasContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento almacenado que obtiene la información referente a las garantías fiduciarias 
             relacionadas a los contratos vigentes o vencidos pero que aún poseen giros activos.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>18/11/2010</Fecha>
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

BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS WHERE cod_tipo_operacion = 2 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario

	/*Se declaran las variables para utilizar la fecha actual como un entero*/
	DECLARE
		@lfecHoySinHora DATETIME,
		@lintFechaEntero INT

	SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @lintFechaEntero =  CONVERT(int, CONVERT(varchar(8), @lfecHoySinHora, 112))

	/*Se obtienen los contratos vencidos o no que poseen al menos un giro activo y que tenga relacionada al menos una garantía fiduciaria*/
	INSERT INTO TMP_OPERACIONES(
	cod_operacion,
	cod_garantia,
	cod_tipo_garantia,
	cod_tipo_operacion,
	ind_contrato_vencido,
	ind_contrato_vencido_giros_activos,
	cod_oficina,
	cod_moneda,
	cod_producto,
	num_operacion,
	num_contrato,
	cod_usuario)
	SELECT A.*
	FROM (
			/*Se obtienen los contratos vencidos con giros activos*/
			SELECT DISTINCT GO.cod_operacion, 
				GFA.cod_garantia_fiduciaria, 
				1 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion, -- 1 = Operaciones, 2 = Contratos y 3 = Giros
				CASE
					WHEN (prmca_pfe_defin >= @lintFechaEntero) THEN 1
					ELSE 0
				END AS ind_contrato_vencido,
				1 AS ind_contrato_vencido_giros_activos,
				GO.cod_oficina,
				GO.cod_moneda,
				GO.cod_producto,
				GO.num_operacion,
				GO.num_contrato,
				@IDUsuario AS cod_usuario

			FROM GAR_OPERACION GO
			INNER JOIN GAR_SICC_PRMCA PRC
			ON GO.cod_contabilidad = PRC.prmca_pco_conta
				AND GO.cod_oficina = PRC.prmca_pco_ofici 
				AND GO.cod_moneda = PRC.prmca_pco_moned
				AND GO.num_contrato = CONVERT(decimal(7),PRC.prmca_pnu_contr)
			INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFA
			ON GO.cod_operacion = GFA.cod_operacion
			
			WHERE GO.num_operacion IS NULL 
			AND GO.num_contrato > 0
			AND PRC.prmca_estado = 'A'
			AND prmca_pfe_defin < @lintFechaEntero
			AND EXISTS (SELECT	1
						FROM	GAR_SICC_PRMOC P
						WHERE	P.prmoc_pco_oficon = PRC.prmca_pco_ofici 
						AND		P.prmoc_pcomonint = PRC.prmca_pco_moned
						AND		P.prmoc_pnu_contr = PRC.prmca_pnu_contr
						AND		P.prmoc_pcoctamay <> 815 
						AND		P.prmoc_pse_proces = 1 
						AND		P.prmoc_estado = 'A')

			UNION ALL
			/*Se obtienen los contratos vigentes que poseen una garantía relacionada*/
			--INSERT INTO TMP_OPERACIONES
			SELECT DISTINCT GO.cod_operacion, 
				GFA.cod_garantia_fiduciaria, 
				1 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion, -- 1 = Operaciones, 2 = Contratos y 3 = Giros
				CASE
					WHEN (prmca_pfe_defin >= @lintFechaEntero) THEN 1
					ELSE 0
				END AS ind_contrato_vencido,
				1 AS ind_contrato_vencido_giros_activos,
				GO.cod_oficina,
				GO.cod_moneda,
				GO.cod_producto,
				GO.num_operacion,
				GO.num_contrato,
				@IDUsuario AS cod_usuario

			FROM GAR_OPERACION GO
			INNER JOIN GAR_SICC_PRMCA PRC
			ON GO.cod_contabilidad = PRC.prmca_pco_conta
				AND GO.cod_oficina = PRC.prmca_pco_ofici 
				AND GO.cod_moneda = PRC.prmca_pco_moned
				AND GO.num_contrato = CONVERT(decimal(7),PRC.prmca_pnu_contr)
			INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFA
			ON GO.cod_operacion = GFA.cod_operacion

			WHERE GO.num_operacion IS NULL 
			AND GO.num_contrato > 0
			AND PRC.prmca_estado = 'A'
			AND prmca_pfe_defin >= @lintFechaEntero) AS A


	/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
	UPDATE TMP_OPERACIONES SET cod_estado_garantia = 1

	FROM TMP_OPERACIONES TMP
	INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA G
	ON G.cod_garantia_fiduciaria = TMP.cod_garantia
	INNER JOIN dbo.GAR_SICC_PRMGT GT
	ON GT.prmgt_pco_ofici = TMP.cod_oficina
	AND GT.prmgt_pco_moned = TMP.cod_moneda
	AND GT.prmgt_pnu_oper = TMP.num_contrato

	WHERE TMP.cod_tipo_garantia = 1
	AND TMP.cod_tipo_operacion = 2
	AND TMP.num_operacion IS NULL
	AND TMP.num_contrato > 0
	AND TMP.cod_usuario = @IDUsuario
	AND GT.prmgt_estado = 'A'
	AND	GT.prmgt_pco_produ = 10
	AND GT.prmgt_pcoclagar = 0
	AND GT.prmgt_pcoclagar = G.cod_clase_garantia
	AND GT.prmgt_pnuidegar = dbo.ufn_ConvertirCodigoGarantia(G.cedula_fiador)

	/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
	DELETE 
	FROM TMP_OPERACIONES 
	WHERE cod_estado_garantia = 0 
	AND cod_tipo_operacion = 2 
	AND cod_tipo_garantia = 1 
	AND cod_usuario = @IDUsuario 

	
	/*Se obtiene la información de las garantías fiduciarias ligadas al contrato y se insertan en la tabla temporal*/
	INSERT INTO TMP_GARANTIAS_FIDUCIARIAS(
	cod_contabilidad,
	cod_oficina,
	cod_moneda,
	cod_producto,
	operacion,
	cedula_fiador,
	cod_tipo_fiador,
	fecha_valuacion,
	ingreso_neto,
	cod_tipo_mitigador,
	cod_tipo_documento_legal,
	monto_mitigador,
	porcentaje_responsabilidad,
	cod_tipo_acreedor,
	cedula_acreedor,
	cod_operacion_especial,
	nombre_fiador,
	cedula_deudor,
	nombre_deudor,
	oficina_deudor,
	cod_estado_tarjeta,
	cod_garantia_fiduciaria,
	cod_operacion,
	cod_tipo_operacion,
	ind_operacion_vencida,
	ind_duplicidad,
	cod_usuario)
	SELECT DISTINCT
		a.cod_contabilidad, 
		a.cod_oficina, 
		a.cod_moneda, 
		a.cod_producto, 
		a.num_contrato AS operacion, 
		c.cedula_fiador, 
		c.cod_tipo_fiador,
		CONVERT(varchar(10),vf.fecha_valuacion,103) AS fecha_valuacion,
		vf.ingreso_neto,
		b.cod_tipo_mitigador, 
		b.cod_tipo_documento_legal, 
		0 AS monto_mitigador, 
		b.porcentaje_responsabilidad, 
		b.cod_tipo_acreedor, 
		b.cedula_acreedor, 
		b.cod_operacion_especial,
		c.nombre_fiador,
		a.cedula_deudor,
		e.nombre_deudor,
		f.bsmpc_dco_ofici AS oficina_deudor,
		NULL AS cod_estado_tarjeta,
		b.cod_garantia_fiduciaria,
		a.cod_operacion,
		TMP.cod_tipo_operacion,
		TMP.ind_contrato_vencido,
		1 AS ind_duplicidad,
		@IDUsuario AS cod_usuario
		
	FROM 
		GAR_OPERACION a 
		INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b 
		ON a.cod_operacion = b.cod_operacion 
		INNER JOIN TMP_OPERACIONES TMP
		ON TMP.cod_operacion = b.cod_operacion
		AND TMP.cod_garantia = b.cod_garantia_fiduciaria
		INNER JOIN GAR_GARANTIA_FIDUCIARIA c 
		ON TMP.cod_garantia = c.cod_garantia_fiduciaria 
		LEFT OUTER JOIN GAR_VALUACIONES_FIADOR vf
		ON vf.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria
		AND vf.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM GAR_VALUACIONES_FIADOR WHERE cod_garantia_fiduciaria = c.cod_garantia_fiduciaria)  
		INNER JOIN GAR_DEUDOR e
		ON a.cedula_deudor = e.cedula_deudor
		INNER JOIN GAR_SICC_BSMPC f
		ON e.cedula_deudor = CONVERT(varchar(30), f.bsmpc_sco_ident)
		 AND f.bsmpc_estado = 'A'

	WHERE TMP.cod_usuario = @IDUsuario
		AND TMP.cod_tipo_garantia = 1
		AND TMP.cod_tipo_operacion = 2

	ORDER BY
		a.cod_contabilidad,
		a.cod_oficina,	
		a.cod_moneda,
		a.cod_producto,
		a.num_contrato,
		c.cedula_fiador,
		b.cod_tipo_documento_legal DESC

	/*Se obtienen las operaciones que se encuentran duplicadas*/
	INSERT INTO TMP_OPERACIONES_DUPLICADAS(
	cod_oficina,
	cod_moneda,
	cod_producto,
	operacion,
	cod_tipo_operacion,
	cod_garantia_sicc,
	cod_tipo_garantia,
	cod_usuario,
	cod_garantia,
	cod_grado)
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

	FROM TMP_GARANTIAS_FIDUCIARIAS
	
	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion = 2

	GROUP BY cedula_fiador, cod_oficina, cod_moneda, cod_producto, operacion, cod_tipo_operacion
	HAVING COUNT(1) > 1

	/*Se actualiza el indicador de duplicidad a 2, estas son las garantías que se encuentran duplicadas
	  y tienen alguos de los datos claves nulos o vacíos*/
	UPDATE TMP_GARANTIAS_FIDUCIARIAS
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_FIDUCIARIAS GF
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGF
				  WHERE GF.cod_oficina = TGF.cod_oficina
					AND GF.cod_moneda = TGF.cod_moneda
					AND GF.cod_producto = TGF.cod_producto
					AND GF.operacion = TGF.operacion
					AND ISNULL(GF.cedula_fiador, '') = ISNULL(TGF.cod_garantia_sicc, '')
					AND ISNULL(GF.cod_usuario, '') = ISNULL(TGF.cod_usuario, '')
					AND TGF.cod_tipo_operacion = 2
					AND TGF.cod_tipo_garantia = 1
					AND GF.cod_tipo_documento_legal IS NULL
					AND GF.fecha_valuacion IS NULL
					AND ((GF.cod_tipo_mitigador IS NULL) OR (GF.cod_tipo_mitigador = 0)))
					--AND GF.cod_garantia_fiduciaria <> TGF.cod_garantia)
	
	AND GF.cod_usuario = @IDUsuario 
	AND GF.cod_tipo_operacion = 2
			 

	/*Se eliminan aquellas garantías que se encuentran con tienen un indicador de duplicidad igual a 2 de un mismo usuario*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS 
		WHERE cod_tipo_operacion = 2 
			AND ind_duplicidad = 2 
			AND cod_usuario = @IDUsuario 

	/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
	  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
	UPDATE TMP_OPERACIONES_DUPLICADAS
	SET cod_garantia = TT.cod_llave
	FROM TMP_OPERACIONES_DUPLICADAS D
	INNER JOIN TMP_GARANTIAS_FIDUCIARIAS TT
	ON TT.cod_oficina = D.cod_oficina
	AND TT.cod_moneda = D.cod_moneda
	AND TT.cod_producto = D.cod_producto
	AND TT.operacion = D.operacion
	AND ISNULL(TT.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
	WHERE TT.cod_llave = (SELECT MIN(T.cod_llave)
								FROM TMP_GARANTIAS_FIDUCIARIAS T
								WHERE T.cod_oficina = D.cod_oficina
								AND T.cod_moneda = D.cod_moneda
								AND T.cod_producto = D.cod_producto
								AND T.operacion = D.operacion
								AND ISNULL(T.cedula_fiador, '') = ISNULL(D.cod_garantia_sicc, '')
								AND ISNULL(T.cod_usuario, '') = ISNULL(D.cod_usuario, '')
								AND D.cod_tipo_operacion = 2
								AND D.cod_tipo_garantia = 1)
	AND TT.cod_usuario = @IDUsuario
	AND TT.cod_tipo_operacion = 2


	/*Se eliminan los dupplicados que sean diferentes al código de garantía actualizado anteriormente*/
	UPDATE TMP_GARANTIAS_FIDUCIARIAS
	SET ind_duplicidad = 2
	FROM TMP_GARANTIAS_FIDUCIARIAS GF
	WHERE EXISTS (SELECT 1 
				  FROM TMP_OPERACIONES_DUPLICADAS TGF
				  WHERE GF.cod_oficina = TGF.cod_oficina
					AND GF.cod_moneda = TGF.cod_moneda
					AND GF.cod_producto = TGF.cod_producto
					AND GF.operacion = TGF.operacion
					AND ISNULL(GF.cedula_fiador, '') = ISNULL(TGF.cod_garantia_sicc, '')
					AND ISNULL(GF.cod_usuario, '') = ISNULL(TGF.cod_usuario, '')
					AND GF.cod_llave <> TGF.cod_garantia
					AND TGF.cod_tipo_operacion = 2
					AND TGF.cod_tipo_garantia = 1)
	AND GF.cod_usuario = @IDUsuario
	AND GF.cod_tipo_operacion = 2


	/*Se eliminan aquellas garantías que se encuentran con tienen un indicador de duplicidad igual a 2 de un mismo usuario*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS 
		WHERE cod_tipo_operacion = 2
			AND ind_duplicidad = 2 
			AND cod_usuario = @IDUsuario 

	/*Se selecciona la información que contendrá el archivo*/
	SELECT DISTINCT cod_contabilidad AS CONTABILIDAD,
		cod_oficina AS OFICINA,
		cod_moneda AS MONEDA,
		cod_producto AS PRODUCTO,
		operacion AS OPERACION,
		cedula_fiador AS CEDULA_FIADOR,
		cod_tipo_fiador AS TIPO_PERSONA_FIADOR,
		ISNULL((CONVERT(varchar(10),fecha_valuacion,103)), '') AS FECHA_VERIFICACION_ASALARIADO,
		ISNULL((CONVERT(varchar(50),ingreso_neto)), '') AS SALARIO_NETO_FIADOR,
		ISNULL((CONVERT(varchar(3),cod_tipo_mitigador)), '') AS TIPO_MITIGADOR_RIESGO,
		ISNULL((CONVERT(varchar(3),cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
		ISNULL((CONVERT(varchar(50), monto_mitigador)), '') AS MONTO_MITIGADOR,
		ISNULL((CONVERT(varchar(50), porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD,
		ISNULL((CONVERT(varchar(3),cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
		ISNULL(cedula_acreedor, '') AS CEDULA_ACREEDOR,
		ISNULL((CONVERT(varchar(3),cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
		ISNULL(nombre_fiador, '') AS NOMBRE_FIADOR,
		ISNULL(cedula_deudor, '') AS CEDULA_DEUDOR,
		ISNULL(nombre_deudor, '') AS NOMBRE_DEUDOR,
		ISNULL((CONVERT(varchar(5),oficina_deudor)), '') AS OFICINA_DEUDOR,
		'' AS BIN,
		ISNULL((CONVERT(varchar(5),cod_estado_tarjeta)), '') AS CODIGO_INTERNO_SISTAR,
		ind_operacion_vencida AS ES_CONTRATO_VENCIDO

	FROM TMP_GARANTIAS_FIDUCIARIAS 

	WHERE cod_usuario = @IDUsuario
		AND cod_tipo_operacion = 2

	ORDER BY operacion

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE FROM TMP_GARANTIAS_FIDUCIARIAS WHERE cod_tipo_operacion = 2 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario
	DELETE FROM TMP_OPERACIONES_DUPLICADAS WHERE cod_tipo_operacion = 2 AND cod_tipo_garantia = 1 AND cod_usuario = @IDUsuario

END
