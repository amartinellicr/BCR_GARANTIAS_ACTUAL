SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ValidarOperaciones', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ValidarOperaciones;
GO

CREATE PROCEDURE [dbo].[pa_ValidarOperaciones]
	@Contabilidad	TINYINT,
    @Oficina		SMALLINT,
    @Moneda			TINYINT,
	@Producto		TINYINT = NULL,
	@Operacion		INT
AS
BEGIN

	/******************************************************************
		<Nombre>pa_ValidarOperaciones</Nombre>
		<Sistema>BCRGarantías</Sistema>
		<Descripción>
			Procedimiento que se encarga de obtener la información básica sobre alguna operación o contrato,
			en caso de que este último se encuentre vencido, se valida si posee giros activos.
		</Descripción>
		<Entradas>
				@Contabilidad		= Código de la contabilidad de la operación.
				@Oficina			= Código de la oficina de la operación.
				@Moneda				= Código de la moneda de la operación.
				@Producto			= Código del producto de la operación.
				@Operacion			= Número de la operación.
		</Entradas>
		<Salidas></Salidas>
		<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
		<Fecha>17/11/2010</Fecha>
		<Requerimiento>N/A</Requerimiento>
		<Versión>1.0</Versión>
		<Historial>
			<Cambio>
				<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
				<Requerimiento>Indicador de Inscripción, Sibel: 1 - 21317031</Requerimiento>
				<Fecha>14/11/2012</Fecha>
				<Descripción>
					Se agregan las columnas esGiro y consecutivoContrato, esto para poder corregir un problema 
					que se da al momento en que se consulta un giro de contrato.
				</Descripción>
			</Cambio>
			<Cambio>
				<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
				<Requerimiento>Cambios en Giros de contratos, Sibel: 1 - 23496621</Requerimiento>
				<Fecha>04/03/2013</Fecha>
				<Descripción>
					Se agrega la columna denominada "Contrato", misma que posee el contrato al cual pertenece el giro consultado,
					el dato posee el formato Oficina - Moneda - Producto - Número de Contrato. En caso de que la operación consultada
					no sea un giro, se envía el valor vacío.
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


	DECLARE @lfecHoySinHora DATETIME,
			@lintFechaEntero INT,
			@EstaContratoVencido BIT,
	        @bEsGiro BIT,
			@nCodigoOperacion BIGINT


	SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @lintFechaEntero =  CONVERT(INT, CONVERT(varchar(8), @lfecHoySinHora, 112))

	/*Se determina si es un giro, ante lo cual, se procederá a obtener el consecutivo del contrato al cual está asociado dicho giro, esto con la
      la finalidad de obtener las garantías asociadas al mismo. En caso de no ser un giro, entonces se uitliza el consecutivo pasado o encontrado anteirormente*/
	SET @bEsGiro = CASE WHEN (	SELECT num_contrato 
								FROM dbo.GAR_OPERACION 
								WHERE cod_contabilidad = @Contabilidad
								AND cod_oficina = @Oficina
								AND cod_moneda = @Moneda
								AND cod_producto = @Producto
								AND num_operacion = @Operacion
								AND num_operacion IS NOT NULL 
								AND num_contrato > 0
							 ) > 0 THEN 1
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
									 WHERE d.prmoc_pco_conta = @Contabilidad
										AND d.prmoc_pco_ofici = @Oficina
										AND d.prmoc_pco_moned = @Moneda
										AND d.prmoc_pco_produ = @Producto
										AND d.prmoc_pnu_oper = @Operacion) a
								 INNER JOIN dbo.GAR_OPERACION b
								  ON b.cod_contabilidad = a.prmca_pco_conta
								  AND b.cod_oficina = a.prmca_pco_ofici
								  AND b.cod_moneda = a.prmca_pco_moned
								  AND b.cod_producto = a.prmca_pco_produc
								  AND b.num_contrato = a.prmca_pnu_contr
								 WHERE b.num_operacion IS NULL)
		END

	IF(@Producto IS NOT NULL)
		BEGIN
			SELECT	b.cod_operacion, c.cedula_deudor, c.nombre_deudor, 
				CASE	WHEN @bEsGiro = 1 THEN '1'
					ELSE '0'
				END AS esGiro,
				CASE	WHEN @bEsGiro = 1 THEN @nCodigoOperacion 
					ELSE -1 
				END AS consecutivoContrato,
				CASE	WHEN @bEsGiro = 1 THEN (SELECT	CONVERT(VARCHAR(5), cod_contabilidad) + '-' + CONVERT(VARCHAR(5), cod_oficina) + '-' +
														CONVERT(VARCHAR(5), cod_moneda) + '-' + CONVERT(VARCHAR(5), cod_producto) + '-' +
														CONVERT(VARCHAR(100), num_contrato)
												FROM	dbo.GAR_OPERACION
												WHERE	cod_operacion = @nCodigoOperacion)
					ELSE ''
				END AS Contrato	
			FROM dbo.GAR_SICC_PRMOC a
				 INNER JOIN dbo.GAR_OPERACION b
					ON b.cod_contabilidad = a.prmoc_pco_conta
					AND b.cod_oficina = a.prmoc_pco_ofici
					AND b.cod_moneda = a.prmoc_pco_moned
					AND b.cod_producto = a.prmoc_pco_produ
					AND b.num_operacion = a.prmoc_pnu_oper
					AND b.num_contrato = a.prmoc_pnu_contr
				 INNER JOIN dbo.GAR_DEUDOR c
					ON c.cedula_deudor = b.cedula_deudor
			WHERE a.prmoc_pse_proces = 1		--Operaciones activas
				AND a.prmoc_pcoctamay <> 815	--Operaciones no insolutas
				AND a.prmoc_estado = 'A'	
				--AND a.prmoc_psa_actual <> 0	
				AND b.cod_contabilidad = @Contabilidad
				AND b.cod_oficina = @Oficina
				AND b.cod_moneda = @Moneda
				AND b.cod_producto = @Producto
				AND b.num_operacion = @Operacion
		END
	ELSE
		BEGIN
			/*Se verifica si el contrato está vencido o no*/
			SET @EstaContratoVencido = (SELECT CASE WHEN (prmca_pfe_defin >= @lintFechaEntero) THEN 1
													ELSE 0
											   END 
										FROM dbo.GAR_SICC_PRMCA
										WHERE prmca_pco_conta = @Contabilidad
										  AND prmca_pco_ofici = @Oficina
										  AND prmca_pco_moned = @Moneda
										  AND prmca_pnu_contr = @Operacion
										  AND prmca_estado = 'A')

			/*No está vencido*/
			IF(@EstaContratoVencido = 1)
				BEGIN
					SELECT b.cod_operacion, c.cedula_deudor, c.nombre_deudor, '0' AS esGiro, -1 AS consecutivoContrato, '' AS Contrato 
					FROM dbo.GAR_SICC_PRMCA a
						 INNER JOIN dbo.GAR_OPERACION b
							ON b.cod_contabilidad = a.prmca_pco_conta
							 AND b.cod_oficina = a.prmca_pco_ofici
							 AND b.cod_moneda = a.prmca_pco_moned
							 AND b.num_contrato = a.prmca_pnu_contr
						 INNER JOIN dbo.GAR_DEUDOR c
							ON c.cedula_deudor = b.cedula_deudor
					WHERE a.prmca_estado = 'A'
					  AND b.num_operacion IS NULL
					  AND b.num_contrato > 0  
					  AND b.cod_contabilidad = @Contabilidad
					  AND b.cod_oficina = @Oficina
					  AND b.cod_moneda = @Moneda
					  AND b.num_contrato = @Operacion
				END
			ELSE
				BEGIN
					/*El contrato está vencido, por lo que se debe verificar si posee giros activos*/
 					SELECT b.cod_operacion, c.cedula_deudor, c.nombre_deudor, '0' AS esGiro, -1 AS consecutivoContrato, '' AS Contrato 
					FROM dbo.GAR_SICC_PRMCA a
						 INNER JOIN dbo.GAR_OPERACION b
							ON b.cod_contabilidad = a.prmca_pco_conta
							 AND b.cod_oficina = a.prmca_pco_ofici
							 AND b.cod_moneda = a.prmca_pco_moned
							 AND b.num_contrato = a.prmca_pnu_contr
						 INNER JOIN dbo.GAR_DEUDOR c
							ON c.cedula_deudor = b.cedula_deudor
					WHERE a.prmca_estado = 'A'
					  AND b.num_operacion IS NULL
					  AND b.num_contrato > 0  
					  AND b.cod_contabilidad = @Contabilidad
					  AND b.cod_oficina = @Oficina
					  AND b.cod_moneda = @Moneda
					  AND b.num_contrato = @Operacion
					  AND EXISTS (SELECT 1
								  FROM dbo.GAR_SICC_PRMOC a
								  WHERE a.prmoc_pse_proces = 1		--Operaciones activas
									AND a.prmoc_pcoctamay <> 815	--Operaciones no insolutas
									AND a.prmoc_estado = 'A'	
									--AND a.prmoc_psa_actual <> 0	
									AND a.prmoc_pco_oficon = @Oficina
									AND a.prmoc_pcomonint = @Moneda
									AND a.prmoc_pnu_contr = @Operacion)
				END
		END
END

