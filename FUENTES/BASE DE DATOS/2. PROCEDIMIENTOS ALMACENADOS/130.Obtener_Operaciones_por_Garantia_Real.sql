USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Operaciones_por_Garantia_Real', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Obtener_Operaciones_por_Garantia_Real;
GO

CREATE PROCEDURE [dbo].[Obtener_Operaciones_por_Garantia_Real]
	
	@piConsecutivo_Garantia		BIGINT = NULL,
	@psIdentificacion_Bien		VARCHAR(25),
	@piCodigo_Clase_Garantia	SMALLINT,
	@piCodigo_Partido			SMALLINT = NULL,
	@psCodigo_Grado				VARCHAR(2) = NULL,
	@psCedula_Usuario			VARCHAR (30)
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Obtener_Operaciones_por_Garantia_Real</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de obtener las operaciones, contrato y giros de contrato asociados a una hipoteca o prenda determinada, además de 
		consultar la información referente a los saldos totales y porcentajes de responsabilidad ajustados.
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Garantia			= Consecutivo de la garantía.
		@pdIdentificacion_Bien			= Identificación del bien.
		@piCodigo_Clase_Garantia		= Código de la clase de garantía.
		@piCodigo_Partido				= Código del partido.
		@psCodigo_Grado					= Código del grado de la cédula hipotecaria.
		@psCedula_Usuario				= Idendificación del usuario que ejecuta la acción.
		
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>07/03/2016</Fecha>
	<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish
	

	DECLARE	@vsIdentificacion_Bien			VARCHAR(25),
			@viCodigo_Clase_Garantia		SMALLINT,
			@vdIdentificacion_Garantia		DECIMAL(12,0),
			@viCodigo_Partido				SMALLINT,
			@viCodigo_Tenencia_Garantia		SMALLINT,
			@viCodigo_Grado_Garantia		TINYINT,
			@viFecha_Actual_Entera			INT,
			@viCodigo_Tipo_Garantia			SMALLINT = 2


	/*Esta tabla servirá para almacenar los datos de la estructura temporal de operaciones relacionadas*/
	CREATE TABLE #TEMP_OPERACIONES_COMUNES (Codigo_Contabilidad TINYINT,
											Codigo_Oficina		SMALLINT,
											Codigo_Moneda		TINYINT,
											Codigo_Producto		TINYINT,
											Operacion			DECIMAL(7,0),
											Saldo_Actual		DECIMAL(18,2),
											Cuenta_Contable		SMALLINT,
											Tipo_Operacion		VARCHAR(10),
											Codigo_Tipo_Operacion TINYINT,
											Consecutivo_Operacion BIGINT,
											Consecutivo_Garantia BIGINT,
											Codigo_Tipo_Garantia SMALLINT,	
											Cedula_Usuario		VARCHAR(30),
											Numero_Registro		BIGINT)

	CREATE INDEX TEMP_TEMP_OPERACIONES_COMUNES_IX_01 ON #TEMP_OPERACIONES_COMUNES (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
	
	/*Esta tabla servirá para almacenar los datos de la estructura temporal de la garantía*/
	CREATE TABLE #TEMP_GARANTIAS (Consecutivo_Garantia			BIGINT,
								  Codigo_Tipo_Garantia			SMALLINT,
								  Clase_Garantia				SMALLINT,
								  Identificacion_Garantia		DECIMAL(12,0),
								  Codigo_Partido				SMALLINT,
								  Codigo_Tenencia_Garantia		SMALLINT,
								  Codigo_Grado_Garantia			TINYINT,
								  Identificacion_Alfanumerica	CHAR(12) COLLATE DATABASE_DEFAULT,	
								  Cedula_Usuario				VARCHAR(30))

	CREATE INDEX TEMP_TEMP_GARANTIAS_IX_01 ON #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
	

	/*SE OBTIENEN LOS DATOS DE LA GARANTIA CUANDO SE SUMINISTRA EL CONSECUTIVO DE LA MISMA*/
	IF(COALESCE(@piConsecutivo_Garantia, -1) > 0)
	BEGIN
		SELECT	@vsIdentificacion_Bien = GGR.Identificacion_Alfanumerica_Sicc, 
				@viCodigo_Clase_Garantia = GGR.cod_clase_garantia,
				@vdIdentificacion_Garantia =	CASE
													WHEN (GGR.cod_clase_garantia = 19) THEN -1 
													ELSE GGR.Identificacion_Sicc
												END,
				@viCodigo_Partido = CASE		
										WHEN (GGR.cod_clase_garantia >= 30) THEN NULL
										ELSE  GGR.cod_partido
									END,

				 @viCodigo_Tenencia_Garantia = CASE
														WHEN (GGR.cod_clase_garantia >= 20) AND (GGR.cod_clase_garantia <= 29) THEN 1 
														ELSE NULL
													END,

				 @viCodigo_Grado_Garantia = CASE
												WHEN (GGR.cod_clase_garantia = 18) THEN CAST(GGR.cod_grado AS TINYINT)
												WHEN (GGR.cod_clase_garantia >= 20) AND (GGR.cod_clase_garantia <= 29) THEN CAST(GGR.cod_grado AS TINYINT)
												ELSE NULL
											END
		FROM	dbo.GAR_GARANTIA_REAL GGR
		WHERE	GGR.cod_garantia_real = @piConsecutivo_Garantia
	END
	ELSE
	BEGIN

		SET	@vsIdentificacion_Bien = @psIdentificacion_Bien

		SET @viCodigo_Clase_Garantia = @piCodigo_Clase_Garantia

		SET	@vdIdentificacion_Garantia =	CASE
												WHEN (@viCodigo_Clase_Garantia = 11)  THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(@vsIdentificacion_Bien)))
												WHEN (@viCodigo_Clase_Garantia = 38)  THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(@vsIdentificacion_Bien)))
												WHEN (@viCodigo_Clase_Garantia = 43)  THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(@vsIdentificacion_Bien)))
												WHEN (@viCodigo_Clase_Garantia = 19) THEN -1 
												ELSE CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(@vsIdentificacion_Bien))))
											END
		SET @viCodigo_Partido = CASE		
									WHEN (@viCodigo_Clase_Garantia >= 30) THEN NULL
									ELSE  @piCodigo_Partido
								END

		SET @viCodigo_Tenencia_Garantia = CASE
												WHEN (@viCodigo_Clase_Garantia >= 20) AND (@viCodigo_Clase_Garantia <= 29) THEN 1 
												ELSE NULL
											END

		SET @viCodigo_Grado_Garantia = CASE
											WHEN (@viCodigo_Clase_Garantia = 18) THEN CAST(@psCodigo_Grado AS TINYINT)
											WHEN (@viCodigo_Clase_Garantia >= 20) AND (@viCodigo_Clase_Garantia <= 29) THEN CAST(@psCodigo_Grado AS TINYINT)
											ELSE NULL
										  END
	END




	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))

	/*SE OBTIENEN LOS DATOS DE LA GARANTIA SUMINSTRADA, SEGUN SU TIPO*/
	--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			GGR.cod_partido AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND ((GGR.cod_clase_garantia = 10)
			OR (GGR.cod_clase_garantia >= 12) AND (GGR.cod_clase_garantia <= 17))


	--HIPOTECAS COMUNES CON CLASE IGUAL A 11
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			GGR.cod_partido AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_clase_garantia = 11

		
	--CEDULAS HIPOTECARIAS CON CLASE IGUAL A 18
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			GGR.cod_partido AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			GGR.cod_grado AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @viCodigo_Grado_Garantia 
		AND GGR.cod_clase_garantia = 18
				

	--CEDULAS HIPOTECARIAS CON CLASE DISTINTA DE 18
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			GGR.cod_partido AS Codigo_Partido,
			1 AS Codigo_Tenencia_Garantia,
			GGR.cod_grado AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @viCodigo_Grado_Garantia 
		AND GGR.cod_clase_garantia >= 20 
		AND GGR.cod_clase_garantia <= 29
		AND MGT.prmgt_pcotengar = 1


	--PRENDAS CON CLASE DISTINTA DE 38 Y 43
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			NULL AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND (((GGR.cod_clase_garantia >= 30) AND (GGR.cod_clase_garantia<= 37))
			OR ((GGR.cod_clase_garantia >= 39) AND (GGR.cod_clase_garantia <= 42))
			OR ((GGR.cod_clase_garantia >= 44) AND (GGR.cod_clase_garantia <= 69)))


	--PRENDAS CON CLASE IGUAL A 38 Y 43
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@viCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGR.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			NULL AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			GGR.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	dbo.GAR_GARANTIA_REAL GGR
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_estado = 'A'	
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
	WHERE	GGR.cod_clase_garantia = @viCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))
	

	/*SE ELIMINAN LOS REGISTROS DUPLICADOS*/
	WITH DUPLICADOS (Consecutivo_Garantia, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Consecutivo_Garantia, 
				ROW_NUMBER() OVER(PARTITION BY Consecutivo_Garantia  ORDER BY Consecutivo_Garantia) AS cantidadRegistrosDuplicados
		FROM	#TEMP_GARANTIAS
	)
	DELETE
	FROM DUPLICADOS
	WHERE cantidadRegistrosDuplicados > 1;

	

	/*SE CARGA LA TABLA DE OPERACIONES RELACIONADAS A LA GARANTIA - OPERACIONES*/
	WITH OPERACIONES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
					  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario) 
	AS
	(
		SELECT	GO1.cod_contabilidad AS Codigo_Contabilidad, 
				GO1.cod_oficina AS Codigo_Oficina, 
				GO1.cod_moneda AS Codigo_Moneda, 
				GO1.cod_producto AS Codigo_Producto, 
				GO1.num_operacion AS Operacion, 
				GO1.saldo_actual AS Saldo_Actual, 
				GO1.Cuenta_Contable AS Cuenta_Contable,
				'Operación' AS Tipo_Operacion,
				1 AS Codigo_Tipo_Operacion, 
				GO1.cod_operacion AS Consecutivo_Operacion,
				TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
				TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
				@psCedula_Usuario AS Cedula_Usuario
		FROM	dbo.GAR_OPERACION GO1	
			INNER JOIN dbo.GAR_SICC_PRMOC MOC
			ON MOC.prmoc_pnu_oper = GO1.num_operacion
			AND MOC.prmoc_pco_ofici = GO1.cod_oficina
			AND MOC.prmoc_pco_moned = GO1.cod_moneda
			AND MOC.prmoc_pco_produ = GO1.cod_producto
			AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
			AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
			AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
			AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
			AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
			INNER JOIN #TEMP_GARANTIAS TMP
			ON MGT.prmgt_pcoclagar = TMP.Clase_Garantia
			AND MGT.prmgt_pnuidegar = TMP.Identificacion_Garantia
			AND MGT.prmgt_pnu_part = COALESCE(TMP.Codigo_Partido, MGT.prmgt_pnu_part)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(TMP.Identificacion_Alfanumerica, COALESCE(MGT.prmgt_pnuide_alf, '')) 
			AND MGT.prmgt_pco_grado = COALESCE(TMP.Codigo_Grado_Garantia, MGT.prmgt_pco_grado)
			AND MGT.prmgt_pcotengar = COALESCE(TMP.Codigo_Tenencia_Garantia, MGT.prmgt_pcotengar)
		WHERE	GO1.num_contrato = 0
			AND MOC.prmoc_pse_proces = 1
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815))
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
			AND MGT.prmgt_estado = 'A'
			AND TMP.Cedula_Usuario = @psCedula_Usuario
	)
	INSERT #TEMP_OPERACIONES_COMUNES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario, Numero_Registro)
	SELECT	TM1.Codigo_Contabilidad, 
			TM1.Codigo_Oficina, 
			TM1.Codigo_Moneda, 
			TM1.Codigo_Producto, 
			TM1.Operacion, 
			TM1.Saldo_Actual, 
			TM1.Cuenta_Contable,
			TM1.Tipo_Operacion,
			TM1.Codigo_Tipo_Operacion,
			TM1.Consecutivo_Operacion,
			TM1.Consecutivo_Garantia,
			TM1.Codigo_Tipo_Garantia,
			TM1.Cedula_Usuario, 
			NULL AS Numero_Registro
	FROM	OPERACIONES TM1
	WHERE	TM1.Cedula_Usuario = @psCedula_Usuario;

	

	/*SE CARGA LA TABLA DE OPERACIONES RELACIONADAS A LA GARANTIA - CONTRATOS VIGENTES*/
	WITH CONTRATOS_VIGENTES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
							 Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario) 
	AS
	(
		SELECT	GO1.cod_contabilidad AS Codigo_Contabilidad, 
				GO1.cod_oficina AS Codigo_Oficina, 
				GO1.cod_moneda AS Codigo_Moneda, 
				GO1.cod_producto AS Codigo_Producto, 
				GO1.num_contrato AS Operacion, 
				GO1.saldo_actual AS Saldo_Actual, 
				GO1.Cuenta_Contable AS Cuenta_Contable,
				'Contrato' AS Tipo_Operacion,
				2 AS Codigo_Tipo_Operacion, 
				GO1.cod_operacion AS Consecutivo_Operacion,
				TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
				TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia, 
				@psCedula_Usuario AS Cedula_Usuario
		FROM	dbo.GAR_OPERACION GO1	
			INNER JOIN dbo.GAR_SICC_PRMCA MCA
			ON MCA.prmca_pnu_contr = GO1.num_contrato
			AND MCA.prmca_pco_ofici = GO1.cod_oficina
			AND MCA.prmca_pco_moned = GO1.cod_moneda
			AND MCA.prmca_pco_produc = GO1.cod_producto
			AND MCA.prmca_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
			AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
			AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
			INNER JOIN #TEMP_GARANTIAS TMP
			ON MGT.prmgt_pcoclagar = TMP.Clase_Garantia
			AND MGT.prmgt_pnuidegar = TMP.Identificacion_Garantia
			AND MGT.prmgt_pnu_part = COALESCE(TMP.Codigo_Partido, MGT.prmgt_pnu_part)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(TMP.Identificacion_Alfanumerica, COALESCE(MGT.prmgt_pnuide_alf, '')) 
			AND MGT.prmgt_pco_grado = COALESCE(TMP.Codigo_Grado_Garantia, MGT.prmgt_pco_grado)
			AND MGT.prmgt_pcotengar = COALESCE(TMP.Codigo_Tenencia_Garantia, MGT.prmgt_pcotengar)
		WHERE	COALESCE(GO1.num_operacion, -1) = -1
			AND MCA.prmca_estado = 'A'
			AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera
			AND MGT.prmgt_estado = 'A'
			AND TMP.Cedula_Usuario = @psCedula_Usuario
	)
	INSERT #TEMP_OPERACIONES_COMUNES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario, Numero_Registro)
	SELECT	TCV.Codigo_Contabilidad, 
			TCV.Codigo_Oficina, 
			TCV.Codigo_Moneda, 
			TCV.Codigo_Producto, 
			TCV.Operacion, 
			TCV.Saldo_Actual, 
			TCV.Cuenta_Contable,
			TCV.Tipo_Operacion,
			TCV.Codigo_Tipo_Operacion,
			TCV.Consecutivo_Operacion,
			TCV.Consecutivo_Garantia,
			TCV.Codigo_Tipo_Garantia,
			TCV.Cedula_Usuario, 
			NULL AS Numero_Registro
	FROM	CONTRATOS_VIGENTES TCV
	WHERE	TCV.Cedula_Usuario = @psCedula_Usuario;


	/*SE CARGA LA TABLA DE OPERACIONES RELACIONADAS A LA GARANTIA - CONTRATOS VENCIDOS CON GIROS ACTIVOS*/
	WITH CONTRATOS_VENCIDOS (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
							 Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario) 
	AS
	(
		SELECT	GO1.cod_contabilidad AS Codigo_Contabilidad, 
				GO1.cod_oficina AS Codigo_Oficina, 
				GO1.cod_moneda AS Codigo_Moneda, 
				GO1.cod_producto AS Codigo_Producto, 
				GO1.num_contrato AS Operacion, 
				GO1.saldo_actual AS Saldo_Actual, 
				GO1.Cuenta_Contable AS Cuenta_Contable,
				'Contrato' AS Tipo_Operacion,
				2 AS Codigo_Tipo_Operacion, 
				GO1.cod_operacion AS Consecutivo_Operacion,
				TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
				TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia, 
				@psCedula_Usuario AS Cedula_Usuario
		FROM	dbo.GAR_OPERACION GO1	
			INNER JOIN dbo.GAR_SICC_PRMCA MCA
			ON MCA.prmca_pnu_contr = GO1.num_contrato
			AND MCA.prmca_pco_ofici = GO1.cod_oficina
			AND MCA.prmca_pco_moned = GO1.cod_moneda
			AND MCA.prmca_pco_produc = GO1.cod_producto
			AND MCA.prmca_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
			AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
			AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
			INNER JOIN dbo.GAR_SICC_PRMOC MOC
			ON MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
			AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
			AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned 
			INNER JOIN #TEMP_GARANTIAS TMP
			ON MGT.prmgt_pcoclagar = TMP.Clase_Garantia
			AND MGT.prmgt_pnuidegar = TMP.Identificacion_Garantia
			AND MGT.prmgt_pnu_part = COALESCE(TMP.Codigo_Partido, MGT.prmgt_pnu_part)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(TMP.Identificacion_Alfanumerica, COALESCE(MGT.prmgt_pnuide_alf, '')) 
			AND MGT.prmgt_pco_grado = COALESCE(TMP.Codigo_Grado_Garantia, MGT.prmgt_pco_grado)
			AND MGT.prmgt_pcotengar = COALESCE(TMP.Codigo_Tenencia_Garantia, MGT.prmgt_pcotengar)
		WHERE	COALESCE(GO1.num_operacion, -1) = -1
			AND MCA.prmca_estado = 'A'
			AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
			AND MGT.prmgt_estado = 'A'
			AND TMP.Cedula_Usuario = @psCedula_Usuario
			AND MOC.prmoc_pse_proces = 1
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815))
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
	)
	INSERT #TEMP_OPERACIONES_COMUNES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario, Numero_Registro)
	SELECT	TV1.Codigo_Contabilidad, 
			TV1.Codigo_Oficina, 
			TV1.Codigo_Moneda, 
			TV1.Codigo_Producto, 
			TV1.Operacion, 
			TV1.Saldo_Actual, 
			TV1.Cuenta_Contable,
			TV1.Tipo_Operacion,
			TV1.Codigo_Tipo_Operacion,
			TV1.Consecutivo_Operacion,
			TV1.Consecutivo_Garantia,
			TV1.Codigo_Tipo_Garantia,
			TV1.Cedula_Usuario,
			NULL AS Numero_Registro
	FROM	CONTRATOS_VENCIDOS TV1
	WHERE	TV1.Cedula_Usuario = @psCedula_Usuario;


	/*SE CARGA LA TABLA DE OPERACIONES RELACIONADAS A LA GARANTIA - GIROS ACTIVOS*/
	WITH GIROS (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
							 Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario) 
	AS
	(
		SELECT	GO2.cod_contabilidad AS Codigo_Contabilidad, 
				GO2.cod_oficina AS Codigo_Oficina, 
				GO2.cod_moneda AS Codigo_Moneda, 
				GO2.cod_producto AS Codigo_Producto, 
				GO2.num_operacion AS Operacion, 
				GO2.saldo_actual AS Saldo_Actual, 
				GO2.Cuenta_Contable AS Cuenta_Contable,
				'Giro' AS Tipo_Operacion,
				3 AS Codigo_Tipo_Operacion, 
				GO2.cod_operacion AS Consecutivo_Operacion,
				TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
				TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia, 
				@psCedula_Usuario AS Cedula_Usuario
		FROM	dbo.GAR_OPERACION GO1	
			INNER JOIN dbo.GAR_SICC_PRMCA MCA
			ON MCA.prmca_pnu_contr = GO1.num_contrato
			AND MCA.prmca_pco_ofici = GO1.cod_oficina
			AND MCA.prmca_pco_moned = GO1.cod_moneda
			AND MCA.prmca_pco_produc = GO1.cod_producto
			AND MCA.prmca_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
			AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
			AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
			INNER JOIN dbo.GAR_SICC_PRMOC MOC
			ON MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
			AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
			AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned 
			INNER JOIN dbo.GAR_OPERACION GO2
			ON GO2.cod_oficina = MOC.prmoc_pco_ofici
			AND GO2.cod_moneda = MOC.prmoc_pco_moned
			AND GO2.cod_producto = MOC.prmoc_pco_produ
			AND GO2.num_operacion = MOC.prmoc_pnu_oper
			INNER JOIN #TEMP_GARANTIAS TMP
			ON MGT.prmgt_pcoclagar = TMP.Clase_Garantia
			AND MGT.prmgt_pnuidegar = TMP.Identificacion_Garantia
			AND MGT.prmgt_pnu_part = COALESCE(TMP.Codigo_Partido, MGT.prmgt_pnu_part)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(TMP.Identificacion_Alfanumerica, COALESCE(MGT.prmgt_pnuide_alf, '')) 
			AND MGT.prmgt_pco_grado = COALESCE(TMP.Codigo_Grado_Garantia, MGT.prmgt_pco_grado)
			AND MGT.prmgt_pcotengar = COALESCE(TMP.Codigo_Tenencia_Garantia, MGT.prmgt_pcotengar)
		WHERE	COALESCE(GO1.num_operacion, -1) = -1
			AND MCA.prmca_estado = 'A'
			AND MGT.prmgt_estado = 'A'
			AND MOC.prmoc_pse_proces = 1
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815))
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
			AND TMP.Cedula_Usuario = @psCedula_Usuario
			AND GO2.num_contrato > 0
			AND COALESCE(GO2.num_operacion, -1) > -1
	)
	INSERT #TEMP_OPERACIONES_COMUNES (Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Saldo_Actual, Cuenta_Contable,
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario, Numero_Registro)
	SELECT	GR1.Codigo_Contabilidad, 
			GR1.Codigo_Oficina, 
			GR1.Codigo_Moneda, 
			GR1.Codigo_Producto, 
			GR1.Operacion, 
			GR1.Saldo_Actual, 
			GR1.Cuenta_Contable,
			GR1.Tipo_Operacion,
			GR1.Codigo_Tipo_Operacion,
			GR1.Consecutivo_Operacion,
			GR1.Consecutivo_Garantia,
			GR1.Codigo_Tipo_Garantia,
			GR1.Cedula_Usuario,
			NULL AS Numero_Registro
	FROM	GIROS GR1
	WHERE	GR1.Cedula_Usuario = @psCedula_Usuario;

	/*SE ELIMINAN LOS REGISTROS DUPLICADOS*/
	WITH DUPLICADOS_OPERACIONES (Consecutivo_Operacion, Consecutivo_Garantia, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Consecutivo_Operacion, Consecutivo_Garantia, 
				ROW_NUMBER() OVER(PARTITION BY Consecutivo_Operacion, Consecutivo_Garantia  ORDER BY Consecutivo_Operacion, Consecutivo_Garantia) AS cantidadRegistrosDuplicados
		FROM	#TEMP_OPERACIONES_COMUNES
	)
	DELETE
	FROM DUPLICADOS_OPERACIONES
	WHERE cantidadRegistrosDuplicados > 1;


	/*SE ESTABLECE EL ORDEN EN QUE SE DEBEN MOSTRAR LOS REGISTROS*/
	WITH DUPLICADOS (Consecutivo_Operacion, Consecutivo_Garantia, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Consecutivo_Operacion, Consecutivo_Garantia,
				ROW_NUMBER() OVER(PARTITION BY Consecutivo_Operacion ORDER BY Consecutivo_Operacion) AS cantidadRegistrosDuplicados
		FROM	#TEMP_OPERACIONES_COMUNES 
	)
	UPDATE TOC
	SET  TOC.Numero_Registro = cantidadRegistrosDuplicados
	FROM DUPLICADOS DUP
		INNER JOIN #TEMP_OPERACIONES_COMUNES TOC
		ON TOC.Consecutivo_Operacion = DUP.Consecutivo_Operacion
		AND TOC.Consecutivo_Garantia = DUP.Consecutivo_Garantia;
	

	SELECT	TM1.Consecutivo_Operacion, 
			TM1.Consecutivo_Garantia, 
			TM1.Codigo_Tipo_Garantia, 
			TM1.Saldo_Actual,
			TM1.Cuenta_Contable,
			TM1.Tipo_Operacion,
			TM1.Codigo_Tipo_Operacion,
			CASE 
				WHEN TM1.Codigo_Tipo_Operacion = 2 THEN (CAST(TM1.Codigo_Oficina AS VARCHAR) + '-' + CAST(TM1.Codigo_Moneda AS VARCHAR) + '-' + CAST(TM1.Operacion AS VARCHAR))
				ELSE (CAST(TM1.Codigo_Oficina AS VARCHAR) + '-' + CAST(TM1.Codigo_Moneda AS VARCHAR) + '-' + CAST(TM1.Codigo_Producto AS VARCHAR) + '-' + CAST(TM1.Operacion AS VARCHAR))
			END AS Operacion_Larga,
			TPR.Saldo_Actual_Ajustado, 
			TPR.Porcentaje_Responsabilidad_Ajustado, 
			TPR.Porcentaje_Responsabilidad_Calculado,
            TPR.Indicador_Ajuste_Saldo_Actual, 
			TPR.Indicador_Ajuste_Porcentaje, 
			TPR.Indicador_Excluido,
			TM1.Numero_Registro
	FROM	#TEMP_OPERACIONES_COMUNES TM1
			LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
		ON TM1.Consecutivo_Operacion = TPR.Consecutivo_Operacion
		AND TM1.Consecutivo_Garantia = TPR.Consecutivo_Garantia
		AND TM1.Codigo_Tipo_Garantia = TPR.Codigo_Tipo_Garantia
	WHERE	TM1.Cedula_Usuario = @psCedula_Usuario
	GROUP BY TM1.Consecutivo_Operacion, 
			TM1.Consecutivo_Garantia, 
			TM1.Codigo_Tipo_Garantia, 
			TM1.Saldo_Actual,
			TM1.Cuenta_Contable,
			TM1.Tipo_Operacion,
			TM1.Codigo_Tipo_Operacion,
			TM1.Codigo_Oficina,
			TM1.Codigo_Moneda,
			TM1.Codigo_Producto,
			TM1.Operacion,
			TPR.Saldo_Actual_Ajustado, 
			TPR.Porcentaje_Responsabilidad_Ajustado, 
			TPR.Porcentaje_Responsabilidad_Calculado,
            TPR.Indicador_Ajuste_Saldo_Actual, 
			TPR.Indicador_Ajuste_Porcentaje, 
			TPR.Indicador_Excluido,
			TM1.Numero_Registro

END