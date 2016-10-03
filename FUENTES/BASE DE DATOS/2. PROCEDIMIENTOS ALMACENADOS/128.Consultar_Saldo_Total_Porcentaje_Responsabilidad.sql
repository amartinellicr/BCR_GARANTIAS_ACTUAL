USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Saldo_Total_Porcentaje_Responsabilidad', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Consultar_Saldo_Total_Porcentaje_Responsabilidad;
GO

CREATE PROCEDURE [dbo].[Consultar_Saldo_Total_Porcentaje_Responsabilidad]
	
	@piConsecutivo_Garantia		BIGINT,
	@piCodigo_Tipo_Garantia		SMALLINT,
	@psCedula_Usuario			VARCHAR (30)
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Saldo_Total_Porcentaje_Responsabilidad</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de consultar la información referente a los saldos totales y porcentajes de responsabilidad ajustados
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Garantia			= Consecutivo de la garantía fiduciaria, real o de valor.
		@piCodigo_Tipo_Garantia			= Codigo del tipo de garantia, del catálogo tipo de Garantias.	
		@psCedula_Usuario				= Idendificación del usuario que ejecuta la acción.
		
	</Entradas>
	<Salidas>
			@psRespuesta				= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>04/03/2016</Fecha>
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
	

	DECLARE	@viClase_Garantia				SMALLINT,
			@vdIdentificacion_Garantia		DECIMAL(12,0),
			@viCodigo_Partido				SMALLINT = NULL,
			@viCodigo_Tenencia_Garantia		SMALLINT = NULL,
			@vsCodigo_Grado_Garantia		VARCHAR(2) = NULL,
			@vsIdentificacion_Alfanumerica	VARCHAR(25) = NULL,
			@viTipo_Persona					SMALLINT = NULL,
			@viFecha_Actual_Entera			INT

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
											Cedula_Usuario		VARCHAR(30))

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
	

	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))

	/*SE OBTIENEN LOS DATOS DE LA GARANTIA SUMINSTRADA, SEGUN SU TIPO*/
	--GARANTIAS FIDUCIARIAS
		
	WITH GARANTIAS (Identificacion_Sicc, cod_tipo_fiador) AS
	(
		SELECT	Identificacion_Sicc, cod_tipo_fiador
		FROM	dbo.GAR_GARANTIA_FIDUCIARIA
		WHERE	cod_garantia_fiduciaria = @piConsecutivo_Garantia
	)
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGF.cod_garantia_fiduciaria AS Consecutivo_Garantia,
			@piCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			0 AS Clase_Garantia,
			GGF.Identificacion_Sicc AS Identificacion_Garantia,
			NULL AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			NULL AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	GARANTIAS TMP
		INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
		ON GGF.Identificacion_Sicc = TMP.Identificacion_Sicc
		AND GGF.cod_tipo_fiador = TMP.cod_tipo_fiador
	WHERE	GGF.cod_tipo_garantia = @piCodigo_Tipo_Garantia;
	
	--GARANTIAS REALES
		
	WITH GARANTIAS (cod_clase_garantia, Identificacion_Sicc, Identificacion_Alfanumerica_Sicc, cod_grado, cod_tenencia, cod_partido) AS
	(
		SELECT	cod_clase_garantia, 
				Identificacion_Sicc, 
				CASE 
					WHEN cod_clase_garantia = 11 THEN Identificacion_Alfanumerica_Sicc
					WHEN cod_clase_garantia = 38 THEN Identificacion_Alfanumerica_Sicc
					WHEN cod_clase_garantia = 43 THEN Identificacion_Alfanumerica_Sicc
					ELSE NULL
				END AS Identificacion_Alfanumerica_Sicc, 
				CASE
					WHEN ((cod_tipo_garantia_real = 2) AND (cod_clase_garantia >= 20) AND (cod_clase_garantia <= 29)) THEN cod_grado
					WHEN cod_clase_garantia = 18 THEN cod_grado
					ELSE NULL
				END AS cod_grado, 
				CASE
					WHEN ((cod_tipo_garantia_real = 2) AND (cod_clase_garantia >= 20) AND (cod_clase_garantia <= 29)) THEN 1
					ELSE NULL
				END AS cod_tenencia, 
				CASE
					WHEN ((cod_clase_garantia >= 10) AND (cod_clase_garantia <= 29)) THEN cod_partido
					ELSE NULL
				END AS cod_partido
		FROM	dbo.GAR_GARANTIA_REAL
		WHERE	cod_garantia_real = @piConsecutivo_Garantia
	)
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGR.cod_garantia_real AS Consecutivo_Garantia,
			@piCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			TMP.cod_clase_garantia AS Clase_Garantia,
			GGR.Identificacion_Sicc AS Identificacion_Garantia,
			TMP.cod_partido AS Codigo_Partido,
			TMP.cod_tenencia AS Codigo_Tenencia_Garantia,
			TMP.cod_grado AS Codigo_Grado_Garantia,
			TMP.Identificacion_Alfanumerica_Sicc AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario
	FROM	GARANTIAS TMP
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR
		ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
		AND GGR.Identificacion_Sicc = TMP.Identificacion_Sicc
		AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') =	CASE 
																		WHEN TMP.cod_clase_garantia = 11 THEN TMP.Identificacion_Alfanumerica_Sicc
																		WHEN TMP.cod_clase_garantia = 38 THEN TMP.Identificacion_Alfanumerica_Sicc
																		WHEN TMP.cod_clase_garantia = 43 THEN TMP.Identificacion_Alfanumerica_Sicc
																		ELSE COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
																	END 
		AND GGR.cod_partido = COALESCE(TMP.cod_partido, GGR.cod_partido)
		AND COALESCE(GGR.cod_grado, '') = COALESCE(TMP.cod_grado, '')
	WHERE	GGR.cod_tipo_garantia = @piCodigo_Tipo_Garantia;

	--GARANTIAS VALOR

	WITH GARANTIAS (Identificacion_Sicc, cod_clase_garantia) AS
	(
		SELECT	Identificacion_Sicc, cod_clase_garantia
		FROM	dbo.GAR_GARANTIA_VALOR
		WHERE	cod_garantia_valor = @piConsecutivo_Garantia
	)
	INSERT #TEMP_GARANTIAS (Consecutivo_Garantia, Codigo_Tipo_Garantia, Clase_Garantia, Identificacion_Garantia, Codigo_Partido, 
							Codigo_Tenencia_Garantia, Codigo_Grado_Garantia, Identificacion_Alfanumerica, Cedula_Usuario)
	SELECT	GGV.cod_garantia_valor AS Consecutivo_Garantia,
			@piCodigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
			GGV.cod_clase_garantia AS Clase_Garantia,
			GGV.Identificacion_Sicc AS Identificacion_Garantia,
			NULL AS Codigo_Partido,
			NULL AS Codigo_Tenencia_Garantia,
			NULL AS Codigo_Grado_Garantia,
			NULL AS Identificacion_Alfanumerica,
			@psCedula_Usuario AS Cedula_Usuario 
	FROM	GARANTIAS TMP
		INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
		ON GGV.Identificacion_Sicc = TMP.Identificacion_Sicc
		AND GGV.cod_clase_garantia = TMP.cod_clase_garantia
	WHERE	GGV.cod_tipo_garantia = @piCodigo_Tipo_Garantia;


	/*SE ELIMINAN LOS REGISTROS DE LAS GARANTIAS QUE SEAN INVALIDAS*/
	DELETE	FROM #TEMP_GARANTIAS
	FROM	#TEMP_GARANTIAS TM1
			RIGHT OUTER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pcoclagar = TM1.Clase_Garantia
			AND MGT.prmgt_pnuidegar = TM1.Identificacion_Garantia
			AND MGT.prmgt_pnu_part = COALESCE(TM1.Codigo_Partido, MGT.prmgt_pnu_part) 
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(TM1.Identificacion_Alfanumerica, COALESCE(MGT.prmgt_pnuide_alf, '')) 
			AND MGT.prmgt_pnuide_alf = MGT.prmgt_pnuide_alf
			AND MGT.prmgt_pco_grado = COALESCE(TM1.Codigo_Grado_Garantia, MGT.prmgt_pco_grado) 
			AND MGT.prmgt_pcotengar = COALESCE(TM1.Codigo_Tenencia_Garantia, MGT.prmgt_pcotengar)
		WHERE	TM1.Cedula_Usuario = @psCedula_Usuario 
			AND MGT.prmgt_estado = 'A'
			AND Clase_Garantia IS NULL
			AND Identificacion_Garantia IS NULL 
			AND Codigo_Partido IS NULL
			AND Codigo_Tenencia_Garantia IS NULL 
			AND Codigo_Grado_Garantia IS NULL
			AND Identificacion_Alfanumerica IS NULL;



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
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
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
			TM1.Cedula_Usuario
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
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
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
			TCV.Cedula_Usuario
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
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
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
			TV1.Cedula_Usuario
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
									  Tipo_Operacion, Codigo_Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, Cedula_Usuario)
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
			GR1.Cedula_Usuario
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
			TPR.Indicador_Excluido
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
			TPR.Indicador_Excluido

END