USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Procesar_Registros_Saldo_Total_Porcentaje_Responsabilidad', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Procesar_Registros_Saldo_Total_Porcentaje_Responsabilidad;
GO

CREATE PROCEDURE [dbo].[Procesar_Registros_Saldo_Total_Porcentaje_Responsabilidad]
	@piIndicadorProceso	TINYINT,
	@psCodigoProceso	VARCHAR(20)	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Procesar_Registros_Saldo_Total_Porcentaje_Responsabilidad</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que se encarga de procesar (incluir o eliminar) los registros replicados del SICC y que existen o son nuevos 
		dentro de la estructura referente al mantenimiento de saldos totales y porcentaje de responsabilidad.
	</Descripción>
	<Entradas>		
		
		@piIndicadorProceso	= Indica la parte del proceso que será ejecutada.
		@psCodigoProceso	= Código del proceso que ejecuta este procedimiento almacenado.
		
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>10/03/2016</Fecha>
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
	
	DECLARE	@vdtFecha_Actual_Sin_Hora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
			@viFecha_Actual_Entera INT, --Corresponde al a fecha actual en formato numérico.
			@vdtFecha_Actual DATETIME, --Fecha actual del sistema
			@vsDescripcion_Error VARCHAR(1000), --Descripción del error capturado.
			@vsDescripcion_Bitacora_Errores VARCHAR(5000) --Descripción del error que será guardado en la bitácora de errores.
		
	
	--Se inicializan las variables
	SET @vdtFecha_Actual = GETDATE()
	SET	@vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(@vdtFecha_Actual AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(@vdtFecha_Actual AS VARCHAR(11)),101)), 112))

-------------------------------------------------------------------------------------------------------------------------
-- SE CREAN Y CARGAN LAS ESTRUCTURAS COMUNES
-------------------------------------------------------------------------------------------------------------------------	

	/*Esta tabla almacenará los contratos vigentes según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VIG (	cod_operacion BIGINT, 
										cod_contabilidad	TINYINT,
										cod_oficina			SMALLINT,
										cod_moneda			TINYINT,
										cod_producto		TINYINT,
										num_contrato		DECIMAL(7,0))
		 
	CREATE INDEX TEMP_CONTRATOS_VIG_IX_01 ON #TEMP_CONTRATOS_VIG (cod_operacion)

		
	/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
	CREATE TABLE #TEMP_CONTRATOS_VENC_GA (	cod_operacion		BIGINT, 
											cod_contabilidad	TINYINT,
											cod_oficina			SMALLINT,
											cod_moneda			TINYINT,
											cod_producto		TINYINT,
											num_contrato		DECIMAL(7,0))
		 
	CREATE INDEX TEMP_CONTRATOS_VENC_GA_IX_01 ON #TEMP_CONTRATOS_VENC_GA (cod_operacion)
				
	/*Esta tabla almacenará los giros activos según el SICC*/
	CREATE TABLE #TEMP_GIROS_ACTIV (	prmoc_pco_oficon	SMALLINT,
										prmoc_pcomonint		SMALLINT,
										prmoc_pnu_contr		INT,
										cod_operacion		BIGINT,
										cod_contabilidad	TINYINT,
										cod_oficina			SMALLINT,
										cod_moneda			TINYINT,
										cod_producto		TINYINT,
										num_operacion		DECIMAL(7,0),
										num_contrato		DECIMAL(7,0),
										cod_producto_contr	TINYINT,
										cod_contrato		BIGINT)
		 
	CREATE INDEX TEMP_GIRO_ACTIV_IX_01 ON #TEMP_GIROS_ACTIV (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)
	CREATE INDEX TEMP_GIRO_ACTIV_IX_02 ON #TEMP_GIROS_ACTIV (cod_operacion)
	CREATE INDEX TEMP_GIRO_ACTIV_IX_03 ON #TEMP_GIROS_ACTIV (cod_contrato)

	/*Esta tabla servirá para almacenar los datos de la estructura PRMOC*/
	CREATE TABLE #TEMP_OPERACIONES (cod_operacion		BIGINT,
									cod_contabilidad	TINYINT,
									cod_oficina			SMALLINT,
									cod_moneda			TINYINT,
									cod_producto		TINYINT,
									num_operacion		DECIMAL(7,0))

	CREATE INDEX TTEMP_OPERACIONES_IX_01 ON #TEMP_OPERACIONES (cod_operacion)

	/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
	INSERT	#TEMP_OPERACIONES (cod_operacion, cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_operacion)
	SELECT	GO1.cod_operacion, GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, GO1.cod_producto, GO1.num_operacion
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMOC MOC 
		ON	MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta	= GO1.cod_contabilidad
		AND MOC.prmoc_pnu_contr = GO1.num_contrato
	WHERE	COALESCE(GO1.num_operacion, 0) > 0 
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1 
		AND MOC.prmoc_estado = 'A'
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))
		AND ((MOC.prmoc_psa_actual < 0)
			OR (MOC.prmoc_psa_actual > 0))

	--Se carga la tabla temporal de contratos vigentes
	INSERT	#TEMP_CONTRATOS_VIG (cod_operacion, cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_contrato)
	SELECT	GO1.cod_operacion, GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, 10 AS cod_producto, GO1.num_contrato
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON GO1.cod_contabilidad = MCA.prmca_pco_conta
		AND GO1.cod_oficina = MCA.prmca_pco_ofici 
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.num_contrato = MCA.prmca_pnu_contr
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera 

	--Se carga la tabla temporal de giros activos
	INSERT	#TEMP_GIROS_ACTIV (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr, cod_operacion, cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_operacion, num_contrato, cod_producto_contr, cod_contrato)
	SELECT	MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr, GO1.cod_operacion, GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, GO1.cod_producto, GO1.num_operacion, GO1.num_contrato, 10 AS cod_producto_contr, GO2.cod_operacion
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMOC MOC 
		ON	MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta	= GO1.cod_contabilidad
		AND MOC.prmoc_pnu_contr = GO1.num_contrato
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON MCA.prmca_pco_ofici = MOC.prmoc_pco_oficon
		AND MCA.prmca_pco_moned = MOC.prmoc_pcomonint
		AND MCA.prmca_pnu_contr = MOC.prmoc_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2
		ON MCA.prmca_pnu_contr = GO2.num_contrato
		AND MCA.prmca_pco_ofici = GO2.cod_oficina
		AND MCA.prmca_pco_moned = GO2.cod_moneda
		AND MCA.prmca_pco_produc = GO2.cod_producto
		AND MCA.prmca_pco_conta = GO2.cod_contabilidad
	WHERE	MOC.prmoc_pse_proces = 1 
		AND MOC.prmoc_estado = 'A'
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))
		AND COALESCE(GO1.num_operacion, 0) > 0 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND COALESCE(GO2.num_operacion, 0) = 0
		AND GO2.num_contrato > 0 
	GROUP BY MOC.prmoc_pco_oficon, 
			MOC.prmoc_pcomonint, 
			MOC.prmoc_pnu_contr, 
			GO1.cod_operacion,
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion, 
			GO1.num_contrato, 
			GO2.cod_operacion

	--Se carga la tabla temporal de contratos vencidos (con giros activos) que poseen garantías activas
	INSERT	#TEMP_CONTRATOS_VENC_GA (cod_operacion, cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_contrato)
	SELECT	GO1.cod_operacion, GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, 10 AS cod_producto, GO1.num_contrato
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_SICC_PRMCA MCA
		ON GO1.cod_contabilidad = MCA.prmca_pco_conta
		AND GO1.cod_oficina = MCA.prmca_pco_ofici 
		AND GO1.cod_moneda = MCA.prmca_pco_moned
		AND GO1.num_contrato = MCA.prmca_pnu_contr
		INNER JOIN #TEMP_GIROS_ACTIV TGA
		ON MCA.prmca_pnu_contr = TGA.prmoc_pnu_contr
		AND MCA.prmca_pco_ofici = TGA.prmoc_pco_oficon
		AND MCA.prmca_pco_moned = TGA.prmoc_pcomonint
		INNER JOIN dbo.GAR_SICC_PRMGT MGT
		ON MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
	WHERE	GO1.num_operacion IS NULL 
		AND GO1.num_contrato > 0
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera 
		AND MGT.prmgt_estado = 'A'



/***********************************************************************************************************************************************/

-------------------------------------------------------------------------------------------------------------------------
-- SE ELIMINAN LOS REGISTROS INVALIDOS DE LA TABLA DE SALDOS TOTALES Y PORCENTAJES DE RESPONSABILIDAD
-------------------------------------------------------------------------------------------------------------------------	
	IF(@piIndicadorProceso = 1)
	BEGIN

/***********************************************************************************************************************************************/

--GARANTIAS FIDUCIARIAS

/***********************************************************************************************************************************************/

		--Se eliminan las garantías fiduciarias relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Gf_Opr
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TP1.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	FIDUCIARIAS TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL
					
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gf_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de las garantías fiduciarias, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gf_Opr
		
		
		--Se eliminan las garantías fiduciarias relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Gf_CVig
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TCV.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	FIDUCIARIAS TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gf_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de las garantías fiduciarias, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gf_CVig


		--Se eliminan las garantías fiduciarias relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Gf_CV_GA
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TCV.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	FIDUCIARIAS TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL								
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gf_CV_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de las garantías fiduciarias, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gf_CV_GA
		

		--Se eliminan las garantías fiduciarias relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Gf_GA
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TGA.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	FIDUCIARIAS TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gf_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de las garantías fiduciarias, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gf_GA




/***********************************************************************************************************************************************/

--GARANTIAS REALES

/***********************************************************************************************************************************************/

--OPERACIONES

/***********************************************************************************************************************************************/

		--Se eliminan las garantías reales, de hipoteca común con clase de garantía diferente de 11, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grhcno11_Opr
			BEGIN TRY	
			
				;WITH REALES_HCNO11 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HCNO11 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhcno11_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase distinta a 11, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhcno11_Opr
		
		
		--Se eliminan las garantías reales, de hipoteca común con clase de garantía igual a 11, relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grhc11_Opr
			BEGIN TRY	
			
				;WITH REALES_HC11 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HC11 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhc11_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase igual a 11, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhc11_Opr



		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grch18_Opr
			BEGIN TRY	
			
				;WITH REALES_CH18 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CH18 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grch18_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grch18_Opr


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grchno18_Opr
			BEGIN TRY	
			
				;WITH REALES_CHNO18 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CHNO18 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL								
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grchno18_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grchno18_Opr


		--Se eliminan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grpno3843_Opr
			BEGIN TRY	
			
				;WITH REALES_PNO3843 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_PNO3843 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grpno3843_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase distinta a 38 y 43, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grpno3843_Opr


		--Se eliminan las garantías reales, de prenda con clase de garantía igual a 38 y 43, relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Grp3843_Opr
			BEGIN TRY	
			
				;WITH REALES_P3843 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_P3843 TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grp3843_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase igual a 38 y 43, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grp3843_Opr


/***********************************************************************************************************************************************/

--CONTRATOS VIGENTES

/***********************************************************************************************************************************************/

                                                                                                                                              
		--Se eliminan las garantías reales, de hipoteca común con clase de garantía diferente de 11, relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grhcno11_CVig
			BEGIN TRY	
			
				;WITH REALES_HCNO11_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HCNO11_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhcno11_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase distinta a 11, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhcno11_CVig


		--Se eliminan las garantías reales, de hipoteca común con clase de garantía igual a 11, nuevas relacionadas a los ocntratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grhc11_CVig
			BEGIN TRY	
			
				;WITH REALES_HC11_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HC11_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL								
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhc11_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase igual a 11, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhc11_CVig


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grch18_CVig
			BEGIN TRY	
			
				;WITH REALES_CH18_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CH18_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grch18_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grch18_CVig


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grchno18_CVig
			BEGIN TRY	
			
				;WITH REALES_CHNO18_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CHNO18_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grchno18_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grchno18_CVig


		--Se eliminan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grpno3843_CVig
			BEGIN TRY	
			
				;WITH REALES_PNO3843_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_PNO3843_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grpno3843_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase distinta a 38 y 43, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grpno3843_CVig


		--Se eliminan las garantías reales, de prenda con clase de garantía igual a 38 y 43, relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Grp3843_CVig
			BEGIN TRY	
			
				;WITH REALES_P3843_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_P3843_CVig TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grp3843_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase igual a 38 y 43, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grp3843_CVig


/***********************************************************************************************************************************************/

--CONTRATOS VENCIDOS CON GIROS ACTIVOS

/***********************************************************************************************************************************************/

		--Se eliminan las garantías reales, de hipoteca común con clase de garantía diferente de 11, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grhcno11_CVGa
			BEGIN TRY	
			
				;WITH REALES_HCNO11_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HCNO11_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhcno11_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase distinta a 11, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhcno11_CVGa


		--Se eliminan las garantías reales, de hipoteca común con clase de garantía igual a 11, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grhc11_CVGa
			BEGIN TRY	
			
				;WITH REALES_HC11_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HC11_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhc11_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidas de garantías reales de hipoteca común con clase igual a 11, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhc11_CVGa


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grch18_CVGa
			BEGIN TRY	
			
				;WITH REALES_CH18_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CH18_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grch18_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grch18_CVGa


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grchno18_CVGa
			BEGIN TRY	
			
				;WITH REALES_CHNO18_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CHNO18_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grchno18_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grchno18_CVGa


		--Se eliminan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grpno3843_CVGa
			BEGIN TRY	
			
				;WITH REALES_PNO3843_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_PNO3843_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grpno3843_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase distinta a 38 y 43, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grpno3843_CVGa


		--Se eliminan las garantías reales, de prenda con clase de garantía igual a 38 y 43, relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Grp3843_CVGa
			BEGIN TRY	
			
				;WITH REALES_P3843_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_P3843_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grp3843_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inv{alidos de garantías reales de prenda con clase igual a 38 y 43, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grp3843_CVGa



/***********************************************************************************************************************************************/

--GIROS ACTIVOS

/***********************************************************************************************************************************************/

		

		--Se eliminan las garantías reales, de hipoteca común con clase de garantía diferente de 11, relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grhcno11_Ga
			BEGIN TRY	
			
				;WITH REALES_HCNO11_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HCNO11_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhcno11_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase distinta a 11, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhcno11_Ga


		--Se eliminan las garantías reales, de hipoteca común con clase de garantía igual a 11, relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grhc11_Ga
			BEGIN TRY	
			
				;WITH REALES_HC11_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_HC11_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grhc11_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de hipoteca común con clase igual a 11, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grhc11_Ga


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grch18_Ga
			BEGIN TRY	
			
				;WITH REALES_CH18_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CH18_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grch18_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grch18_Ga


		--Se eliminan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18,  relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grchno18_Ga
			BEGIN TRY	
			
				;WITH REALES_CHNO18_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_CHNO18_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grchno18_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grchno18_Ga


		--Se eliminan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grpno3843_Ga
			BEGIN TRY	
			
				;WITH REALES_PNO3843_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_PNO3843_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grpno3843_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase distinta a 38 y 43, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grpno3843_Ga


		--Se eliminan las garantías reales, de prenda con clase de garantía igual a 38 y 43, relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Grp3843_Ga
			BEGIN TRY	
			
				;WITH REALES_P3843_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	REALES_P3843_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Grp3843_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías reales de prenda con clase igual a 38 y 43, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Grp3843_Ga



/***********************************************************************************************************************************************/

--GARANTIAS VALOR

/***********************************************************************************************************************************************/

		--Se eliminan las garantías valor relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Eli_Gv_Opr
			BEGIN TRY	
			
				;WITH VALORES_OP (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TP1.cod_operacion, GGV.cod_garantia_valor
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	VALORES_OP TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gv_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías valor, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gv_Opr
		
		
		--Se eliminan las garantías valor relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Eli_Gv_CVig
			BEGIN TRY	
			
				;WITH VALORES_CVIG (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TCV.cod_operacion, GGV.cod_garantia_valor
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	VALORES_CVIG TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gv_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías valor, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gv_CVig


		--Se eliminan las garantías valor relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Eli_Gv_CV_GA
			BEGIN TRY	
			
				;WITH VALORES_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TCV.cod_operacion, GGV.cod_garantia_valor
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	VALORES_CVGA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gv_CV_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías valor, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gv_CV_GA
		

		--Se eliminan las garantías valor relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Eli_Gv_GA
			BEGIN TRY	
			
				;WITH VALORES_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.cod_oficina
						AND MGT.prmgt_pco_moned = TGA.cod_moneda
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TGA.cod_operacion, GGV.cod_garantia_valor
									
				)
				DELETE	FROM dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD 
				FROM	VALORES_GA TMP 
					RIGHT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TMP.Consecutivo_Operacion IS NULL
					AND TMP.Consecutivo_Garantia IS NULL
					AND TMP.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Eli_Gv_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al eliminar los registros inválidos de garantías valor, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Eli_Gv_GA


	END

/***********************************************************************************************************************************************/

-------------------------------------------------------------------------------------------------------------------------
-- SE INSERTAN LOS REGISTROS NUEVOS DENTRO DE LA TABLA DE SALDOS TOTALES Y PORCENTAJES DE RESPONSABILIDAD
-------------------------------------------------------------------------------------------------------------------------	
	IF(@piIndicadorProceso = 2)
	BEGIN

/***********************************************************************************************************************************************/

--GARANTIAS FIDUCIARIAS

/***********************************************************************************************************************************************/

		--Se insertan las garantías fiduciarias nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Gf_Opr
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TP1.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	FIDUCIARIAS TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gf_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías fiduciarias, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gf_Opr
		
		
		--Se insertan las garantías fiduciarias nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Gf_CVig
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TCV.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	FIDUCIARIAS TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gf_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías fiduciarias, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gf_CVig


		--Se insertan las garantías fiduciarias nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Gf_CV_GA
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TCV.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	FIDUCIARIAS TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gf_CV_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías fiduciarias, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gf_CV_GA
		

		--Se insertan las garantías fiduciarias nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Gf_GA
			BEGIN TRY	
			
				;WITH FIDUCIARIAS (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGF.cod_garantia_fiduciaria, 1 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GFO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGF.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 0
					GROUP BY TGA.cod_operacion, GGF.cod_garantia_fiduciaria
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	FIDUCIARIAS TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gf_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías fiduciarias, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gf_GA




/***********************************************************************************************************************************************/

--GARANTIAS REALES

/***********************************************************************************************************************************************/

--OPERACIONES

/***********************************************************************************************************************************************/

		--Se insertan las garantías reales, de hipoteca común con clase de garantía diferente de 11, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grhcno11_Opr
			BEGIN TRY	
			
				;WITH REALES_HCNO11 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HCNO11 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhcno11_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase distinta a 11, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhcno11_Opr
		
		
		--Se insertan las garantías reales, de hipoetca común con clase de garantía igual a 11, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grhc11_Opr
			BEGIN TRY	
			
				;WITH REALES_HC11 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HC11 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase igual a 11, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11_Opr



		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grch18_Opr
			BEGIN TRY	
			
				;WITH REALES_CH18 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CH18 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grch18_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grch18_Opr


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grchno18_Opr
			BEGIN TRY	
			
				;WITH REALES_CHNO18 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CHNO18 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchno18_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchno18_Opr


		--Se insertan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grpno3843_Opr
			BEGIN TRY	
			
				;WITH REALES_PNO3843 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_PNO3843 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grpno3843_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase distinta a 38 y 43, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grpno3843_Opr


		--Se insertan las garantías reales, de prenda con clase de garantía igual a 38 y 43, nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Grp3843_Opr
			BEGIN TRY	
			
				;WITH REALES_P3843 (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TP1.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_P3843 TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grp3843_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase igual a 38 y 43, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grp3843_Opr


/***********************************************************************************************************************************************/

--CONTRATOS VIGENTES

/***********************************************************************************************************************************************/

                                                                                                                                              
		--Se insertan las garantías reales, de hipoteca común con clase de garantía diferente de 11, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grhcno11_CVig
			BEGIN TRY	
			
				;WITH REALES_HCNO11_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HCNO11_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhcno11_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase distinta a 11, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhcno11_CVig


		--Se insertan las garantías reales, de hipoteca común con clase de garantía igual a 11, nuevas relacionadas a los ocntratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grhc11_CVig
			BEGIN TRY	
			
				;WITH REALES_HC11_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HC11_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase igual a 11, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11_CVig


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grch18_CVig
			BEGIN TRY	
			
				;WITH REALES_CH18_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CH18_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grch18_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grch18_CVig


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grchno18_CVig
			BEGIN TRY	
			
				;WITH REALES_CHNO18_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CHNO18_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchno18_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchno18_CVig


		--Se insertan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grpno3843_CVig
			BEGIN TRY	
			
				;WITH REALES_PNO3843_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_PNO3843_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grpno3843_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase distinta a 38 y 43, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grpno3843_CVig


		--Se insertan las garantías reales, de prenda con clase de garantía igual a 38 y 43, nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Grp3843_CVig
			BEGIN TRY	
			
				;WITH REALES_P3843_CVig (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_P3843_CVig TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grp3843_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase igual a 38 y 43, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grp3843_CVig


/***********************************************************************************************************************************************/

--CONTRATOS VENCIDOS CON GIROS ACTIVOS

/***********************************************************************************************************************************************/

		--Se insertan las garantías reales, de hipoteca común con clase de garantía diferente de 11, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grhcno11_CVGa
			BEGIN TRY	
			
				;WITH REALES_HCNO11_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HCNO11_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhcno11_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase distinta a 11, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhcno11_CVGa


		--Se insertan las garantías reales, de hipoteca común con clase de garantía igual a 11, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grhc11_CVGa
			BEGIN TRY	
			
				;WITH REALES_HC11_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HC11_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase igual a 11, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11_CVGa


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grch18_CVGa
			BEGIN TRY	
			
				;WITH REALES_CH18_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CH18_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grch18_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grch18_CVGa


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grchno18_CVGa
			BEGIN TRY	
			
				;WITH REALES_CHNO18_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CHNO18_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchno18_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchno18_CVGa


		--Se insertan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grpno3843_CVGa
			BEGIN TRY	
			
				;WITH REALES_PNO3843_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_PNO3843_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grpno3843_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase distinta a 38 y 43, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grpno3843_CVGa


		--Se insertan las garantías reales, de prenda con clase de garantía igual a 38 y 43, nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Grp3843_CVGa
			BEGIN TRY	
			
				;WITH REALES_P3843_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TCV.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_P3843_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grp3843_CVGa

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase igual a 38 y 43, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grp3843_CVGa



/***********************************************************************************************************************************************/

--GIROS ACTIVOS

/***********************************************************************************************************************************************/

		

		--Se insertan las garantías reales, de hipoteca común con clase de garantía diferente de 11, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grhcno11_Ga
			BEGIN TRY	
			
				;WITH REALES_HCNO11_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HCNO11_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhcno11_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase distinta a 11, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhcno11_Ga


		--Se insertan las garantías reales, de hipoteca común con clase de garantía igual a 11, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grhc11_Ga
			BEGIN TRY	
			
				;WITH REALES_HC11_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 11
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_HC11_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de hipoteca común con clase igual a 11, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11_Ga


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía igual a 18, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grch18_Ga
			BEGIN TRY	
			
				;WITH REALES_CH18_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = 18
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CH18_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grch18_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase igual a 18, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grch18_Ga


		--Se insertan las garantías reales, de cédula hipotecaria con clase de garantía distinta a 18, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grchno18_Ga
			BEGIN TRY	
			
				;WITH REALES_CHNO18_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND MGT.prmgt_pcotengar = 1
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_CHNO18_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchno18_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de cédula hipotecaria con clase distinta a 18, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchno18_Ga


		--Se insertan las garantías reales, de prenda con clase de garantía distinta a 38 y 43, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grpno3843_Ga
			BEGIN TRY	
			
				;WITH REALES_PNO3843_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
							OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
							OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_PNO3843_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grpno3843_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase distinta a 38 y 43, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grpno3843_Ga


		--Se insertan las garantías reales, de prenda con clase de garantía igual a 38 y 43, nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Grp3843_Ga
			BEGIN TRY	
			
				;WITH REALES_P3843_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGR.cod_garantia_real, 2 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						ON GRO.cod_garantia_real = GGR.cod_garantia_real
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') 
					WHERE	MGT.prmgt_estado = 'A'
						AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
					GROUP BY TGA.cod_operacion, GGR.cod_garantia_real
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	REALES_P3843_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grp3843_Ga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías reales de prenda con clase igual a 38 y 43, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grp3843_Ga






/***********************************************************************************************************************************************/

--GARANTIAS VALOR

/***********************************************************************************************************************************************/

		--Se insertan las garantías valor nuevas relacionadas a las operaciones
		BEGIN TRANSACTION TRA_Ins_Gv_Opr
			BEGIN TRY	
			
				;WITH VALORES_OP (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TP1.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_OPERACIONES TP1
						ON TP1.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TP1.num_operacion
						AND MGT.prmgt_pco_ofici = TP1.cod_oficina
						AND MGT.prmgt_pco_moned = TP1.cod_moneda
						AND MGT.prmgt_pco_produ = TP1.cod_producto
						AND MGT.prmgt_pco_conta = TP1.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TP1.cod_operacion, GGV.cod_garantia_valor
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	VALORES_OP TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gv_Opr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías valor, relacionadas a operaciones, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gv_Opr
		
		
		--Se insertan las garantías valor nuevas relacionadas a los contratos vigentes
		BEGIN TRANSACTION TRA_Ins_Gv_CVig
			BEGIN TRY	
			
				;WITH VALORES_CVIG (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_CONTRATOS_VIG TCV
						ON TCV.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TCV.cod_operacion, GGV.cod_garantia_valor
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	VALORES_CVIG TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gv_CVig

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías valor, relacionadas a contratos vigentes, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gv_CVig


		--Se insertan las garantías valor nuevas relacionadas a los contratos vencidos con giros activos
		BEGIN TRANSACTION TRA_Ins_Gv_CV_GA
			BEGIN TRY	
			
				;WITH VALORES_CVGA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TCV.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_CONTRATOS_VENC_GA TCV
						ON TCV.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TCV.num_contrato
						AND MGT.prmgt_pco_ofici = TCV.cod_oficina
						AND MGT.prmgt_pco_moned = TCV.cod_moneda
						AND MGT.prmgt_pco_produ = TCV.cod_producto
						AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TCV.cod_operacion, GGV.cod_garantia_valor
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	VALORES_CVGA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gv_CV_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías valor, relacionadas a contratos vencidos con giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gv_CV_GA
		

		--Se insertan las garantías valor nuevas relacionadas a los giros activos
		BEGIN TRANSACTION TRA_Ins_Gv_GA
			BEGIN TRY	
			
				;WITH VALORES_GA (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia) 
				AS
				(
					SELECT	TGA.cod_operacion, GGV.cod_garantia_valor, 3 AS Codigo_Tipo_Garantia
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
						INNER JOIN #TEMP_GIROS_ACTIV TGA
						ON TGA.cod_contrato = GVO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = TGA.num_contrato
						AND MGT.prmgt_pco_ofici = TGA.prmoc_pco_oficon
						AND MGT.prmgt_pco_moned = TGA.prmoc_pcomonint
						AND MGT.prmgt_pco_produ = TGA.cod_producto_contr
						AND MGT.prmgt_pco_conta = TGA.cod_contabilidad
						AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
						AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
					WHERE	MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar >= 20 
						AND MGT.prmgt_pcoclagar <= 29
						AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					GROUP BY TGA.cod_operacion, GGV.cod_garantia_valor
									
				)
				INSERT  dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD (Consecutivo_Operacion, Consecutivo_Garantia, Codigo_Tipo_Garantia, 
																			Saldo_Actual_Ajustado, Porcentaje_Responsabilidad_Ajustado, 
																			Indicador_Ajuste_Saldo_Actual, Indicador_Ajuste_Porcentaje, 
																			Indicador_Excluido, Fecha_Replica)
				
				SELECT	TMP.Consecutivo_Operacion AS Consecutivo_Operacion,
						TMP.Consecutivo_Garantia AS Consecutivo_Garantia,
						TMP.Codigo_Tipo_Garantia AS Codigo_Tipo_Garantia,
						-1 AS Saldo_Actual_Ajustado, 
						-1 AS Porcentaje_Responsabilidad_Ajustado,
						0 AS Indicador_Ajuste_Saldo_Actual,
						0 AS Indicador_Ajuste_Porcentaje,
						0 AS Indicador_Excluido,
						@vdtFecha_Actual AS Fecha_Replica
				FROM	VALORES_GA TMP 
					LEFT OUTER JOIN dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD TPR
					ON TPR.Consecutivo_Operacion = TMP.Consecutivo_Operacion
					AND TPR.Consecutivo_Garantia = TMP.Consecutivo_Garantia
					AND TPR.Codigo_Tipo_Garantia = TMP.Codigo_Tipo_Garantia
				WHERE	TPR.Consecutivo_Operacion IS NULL
					AND TPR.Consecutivo_Garantia IS NULL
					AND TPR.Codigo_Tipo_Garantia IS NULL							
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gv_GA

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al incluir los registros de las nuevas garantías valor, relacionadas a giros activos, en la tabla del mantenimiento de saldos totales y porcentajes de responsabilidad. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gv_GA




/***********************************************************************************************************************************************/




	END
	
END