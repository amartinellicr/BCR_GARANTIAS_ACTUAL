USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('dbo.Replicar_Valuaciones_Reales_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Replicar_Valuaciones_Reales_Sicc;
GO

CREATE PROCEDURE [dbo].[Replicar_Valuaciones_Reales_Sicc]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)	
AS
BEGIN
/******************************************************************
	<Nombre>Replicar_Valuaciones_Reales_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de las valuaciones de las garantías reales, del 
			     SICC a la base de datos GARANTIAS. 
	</Descripción>
	<Entradas>
			@piIndicadorProceso		= Indica la parte del proceso que será ejecutada.
			@psCodigoProceso		= Código del proceso que ejecuta este procedimiento almacenado.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>12/07/2014</Fecha>
	<Requerimiento>Req Bcr Garantias Migración, Siebel No.1-24015441</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>29/06/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #1, #4, #5, #6, #11, #12 y #13. El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
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


	DECLARE	 @vdFechaActualSinHora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
		@viFechaActualEntera INT, --Corresponde al a fecha actual en formato numérico.
		@vsDescripcionError VARCHAR(1000), --Descripción del error capturado.
		@vsDescripcionBitacoraErrores VARCHAR(5000) --Descripción del error que será guardado en la bitácora de errores.

	--Se inicializan las variables
	SET	@vdFechaActualSinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
----------------------------------------------------------------------
--CARGA VALUACIONES DE GARANTIAS REALES
----------------------------------------------------------------------
--Se asigna la fecha del avalúo más reciente para hipotecas comunes
IF(@piIndicadorProceso = 1)
BEGIN

	--Se insertan las valuaciones de hipotecas comunes con clase distinta a 11
	BEGIN TRANSACTION TRA_Ins_Vrhc
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo,
				Fecha_Replica
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo,
				GETDATE()
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN (	SELECT	TOP 100 PERCENT 
									GGR.cod_clase_garantia,
									GGR.cod_partido,
									GGR.Identificacion_Sicc,
									MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
								FROM	dbo.GAR_GARANTIA_REAL GGR 
									INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMOC MOC
																			WHERE	MOC.prmoc_pse_proces = 1
																				AND MOC.prmoc_estado = 'A'
																				AND MOC.prmoc_pnu_contr = 0
																				AND ((MOC.prmoc_pcoctamay > 815)
																					OR (MOC.prmoc_pcoctamay < 815))
																				AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
															UNION ALL
															
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin < @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10
																				AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMOC MC1
																					WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																						AND MC1.prmoc_estado = 'A'	
																						AND ((MC1.prmoc_pcoctamay > 815)
																							OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																						AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																						AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																						AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
													) MG2
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
								ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
								AND MGT.prmgt_pnu_part = GGR.cod_partido
								AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
								WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
								GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
							) GHC
				ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
				AND GHC.cod_partido = GGR.cod_partido
				AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
			WHERE	GHC.fecha_valuacion > '19000101'
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_VALUACIONES_REALES GVR
								WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
									AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Ins_Vrhc

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las hipotecas comunes (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrhc
		
		
	--Se insertan las valuaciones de hipotecas comunes con clase igual a 11
	BEGIN TRANSACTION TRA_Ins_Vrhc11
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo,
				Fecha_Replica
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo,
				GETDATE()
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN (	SELECT	TOP 100 PERCENT 
									GGR.cod_clase_garantia,
									GGR.cod_partido,
									GGR.Identificacion_Sicc,
									GGR.Identificacion_Alfanumerica_Sicc,
									MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
								FROM	dbo.GAR_GARANTIA_REAL GGR 
									INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnu_part, MG2.prmgt_pnuide_alf, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMOC MOC
																			WHERE	MOC.prmoc_pse_proces = 1
																				AND MOC.prmoc_estado = 'A'
																				AND MOC.prmoc_pnu_contr = 0
																				AND ((MOC.prmoc_pcoctamay > 815)
																					OR (MOC.prmoc_pcoctamay < 815))
																				AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
															UNION ALL
															
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin < @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10
																				AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMOC MC1
																					WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																						AND MC1.prmoc_estado = 'A'	
																						AND ((MC1.prmoc_pcoctamay > 815)
																							OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																						AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																						AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																						AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
													) MG2
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
								ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
								AND MGT.prmgt_pnu_part = GGR.cod_partido
								AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
								AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
								WHERE	GGR.cod_clase_garantia = 11
								GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
							) GHC
				ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
				AND GHC.cod_partido = GGR.cod_partido
				AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
				AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
			WHERE	GHC.fecha_valuacion > '19000101'
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_VALUACIONES_REALES GVR
								WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
									AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Ins_Vrhc11

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las hipotecas comunes (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrhc11
END	

--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía 18
IF(@piIndicadorProceso = 2)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Vrch18
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo,
				Fecha_Replica
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo,
				GETDATE()
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN (	SELECT	TOP 100 PERCENT 
									GGR.cod_clase_garantia,
									GGR.cod_partido,
									GGR.Identificacion_Sicc,
									MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
								FROM	dbo.GAR_GARANTIA_REAL GGR 
									INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 18
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMOC MOC
																			WHERE	MOC.prmoc_pse_proces = 1
																				AND MOC.prmoc_estado = 'A'
																				AND MOC.prmoc_pnu_contr = 0
																				AND ((MOC.prmoc_pcoctamay > 815)
																					OR (MOC.prmoc_pcoctamay < 815))
																				AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
															UNION ALL
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 18
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 18
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin < @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10
																				AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMOC MC1
																					WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																						AND MC1.prmoc_estado = 'A'	
																						AND ((MC1.prmoc_pcoctamay > 815)
																							OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																						AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																						AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																						AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
													) MG2
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
								ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
								AND MGT.prmgt_pnu_part = GGR.cod_partido
								AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
								WHERE	GGR.cod_clase_garantia = 18
								GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
							) GHC
				ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
				AND GHC.cod_partido = GGR.cod_partido
				AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
			WHERE	GHC.fecha_valuacion > '19000101'
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_VALUACIONES_REALES GVR
								WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
									AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Ins_Vrch18

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las cédulas hipotecarias con clase 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrch18
END	

--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
IF(@piIndicadorProceso = 3)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Vrch
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo,
				Fecha_Replica
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo,
				GETDATE()
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN (	SELECT	TOP 100 PERCENT 
									GGR.cod_clase_garantia,
									GGR.cod_grado,
									GGR.Identificacion_Sicc,
									MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
								FROM	dbo.GAR_GARANTIA_REAL GGR 
									INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pco_grado, MG2.prmgt_pnuidegar, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcotengar = 1
																AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMOC MOC
																			WHERE	MOC.prmoc_pse_proces = 1
																				AND MOC.prmoc_estado = 'A'
																				AND MOC.prmoc_pnu_contr = 0
																				AND ((MOC.prmoc_pcoctamay > 815)
																					OR (MOC.prmoc_pcoctamay < 815))
																				AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
															UNION ALL
															SELECT	MG1.prmgt_pcoclagar,
																CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcotengar = 1
																AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															SELECT	MG1.prmgt_pcoclagar,
																CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																MG1.prmgt_pnuidegar,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcotengar = 1
																AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin < @viFechaActualEntera
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10
																				AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMOC MC1
																					WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																						AND MC1.prmoc_estado = 'A'	
																						AND ((MC1.prmoc_pcoctamay > 815)
																							OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																						AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																						AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																						AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
													) MG2
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pco_grado, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
								ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
								AND MGT.prmgt_pco_grado = GGR.cod_grado
								AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
								WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
								GROUP BY GGR.cod_clase_garantia, GGR.cod_grado, GGR.Identificacion_Sicc
							) GHC
				ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
				AND GHC.cod_grado = GGR.cod_grado
				AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
			WHERE	GHC.fecha_valuacion > '19000101'
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_VALUACIONES_REALES GVR
								WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
									AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Ins_Vrch

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las cédulas hipotecarias con clase diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrch
END	

--Se asigna la fecha del avalúo más reciente para prendas
IF(@piIndicadorProceso = 4)
	BEGIN
	
		--Se insertan las valuaciones de prendas con clase distinta a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Vrp
			BEGIN TRY
	
				INSERT INTO dbo.GAR_VALUACIONES_REALES
				(
					cod_garantia_real, 
					fecha_valuacion, 
					monto_total_avaluo,
					Fecha_Replica
				)
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
					0 AS monto_total_avaluo,
					GETDATE()
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN (	SELECT	TOP 100 PERCENT 
										GGR.cod_clase_garantia,
										GGR.Identificacion_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE  ((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
									WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
												OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
												OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
									GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
				WHERE	GHC.fecha_valuacion > '19000101'
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_VALUACIONES_REALES GVR
									WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
										AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Vrp

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las prendas (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Vrp
			
			
		--Se insertan las valuaciones de prendas con clase distinta a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Vrp3843
			BEGIN TRY
	
				INSERT INTO dbo.GAR_VALUACIONES_REALES
				(
					cod_garantia_real, 
					fecha_valuacion, 
					monto_total_avaluo,
					Fecha_Replica
				)
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
					0 AS monto_total_avaluo,
					GETDATE()
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN (	SELECT	TOP 100 PERCENT 
										GGR.cod_clase_garantia,
										GGR.Identificacion_Sicc,
										GGR.Identificacion_Alfanumerica_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (	SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE  ((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
									WHERE	((GGR.cod_clase_garantia = 38)
												OR (GGR.cod_clase_garantia = 43))
									GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				WHERE	GHC.fecha_valuacion > '19000101'
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_VALUACIONES_REALES GVR
									WHERE	GVR.cod_garantia_real = GGR.cod_garantia_real
										AND GVR.fecha_valuacion = CONVERT(DATETIME, GHC.fecha_valuacion))
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Vrp3843

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los avalúos de las prendas (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Vrp3843
	END	

--Se actualiza el campo de la fecha de valuación registrada en el SICC, en la tabla de valuaciones.
--Si la fecha de valuación del SICC es 01/01/1900 implica que el dato almacenado en el Maestro de Garantías (tabla PRMGT) no corresponde a una fecha.
--Si la fecha de valuación dle SICC es igual a NULL es porque la garantía nunca fue encontrada en el Maestro de Garantías (tabla PRMGT).

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
IF(@piIndicadorProceso = 5)
BEGIN

	--Actualización del dato para hipotecas comunes con clase distinta a 11
	BEGIN TRANSACTION TRA_Act_Fvhcop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion 	= GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici  = GO1.cod_oficina
				AND MGT.prmgt_pco_moned	= GO1.cod_moneda
				AND MGT.prmgt_pco_produ	= GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase distinta a 11) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcop
		
		
	
	--Actualización del dato para hipotecas comunes con clase igual a 11
	BEGIN TRANSACTION TRA_Act_Fvhcop11
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion 	= GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici  = GO1.cod_oficina
				AND MGT.prmgt_pco_moned	= GO1.cod_moneda
				AND MGT.prmgt_pco_produ	= GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	GGR.cod_clase_garantia = 11
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
				AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcop11

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcop11
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
IF(@piIndicadorProceso = 6)
BEGIN

	--Actualización del dato para hipotecas comunes con clase distinta a 11
	BEGIN TRANSACTION TRA_Act_Fvhcc
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pnu_oper = GO1.num_contrato
			WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcc

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase distinta a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcc
		
		
	--Actualización del dato para hipotecas comunes con clase igual a 11
	BEGIN TRANSACTION TRA_Act_Fvhcc11
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pnu_oper = GO1.num_contrato
			WHERE	GGR.cod_clase_garantia = 11
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
				AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcc11

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcc11
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
IF(@piIndicadorProceso = 7)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvch18op
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	GGR.cod_clase_garantia = 18
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
				AND GGR.cod_partido	= MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc	= MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvch18op

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase 18, asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvch18op
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
IF(@piIndicadorProceso = 8)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvch18c
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pnu_oper = GO1.num_contrato
			WHERE	GGR.cod_clase_garantia = 18
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_estado = 'A'
	
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvch18c

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase 18, asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvch18c
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
IF(@piIndicadorProceso = 9)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvchop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvchop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cédula hipotecaria, con clase diferente a 18, asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvchop
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
IF(@piIndicadorProceso = 10)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvchc
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ	= 10
				AND MGT.prmgt_pnu_oper = GO1.num_contrato
			WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
				AND GGR.Identificacion_Sicc	= MGT.prmgt_pnuidegar
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_pcotengar	= 1
				AND MGT.prmgt_estado = 'A'
			
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvchc

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase diferente a 18, asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvchc
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para prendas
IF(@piIndicadorProceso = 11)
BEGIN
	
	--Actualización del dato para hipotecas comunes con clase distinta a 38 o 43
	BEGIN TRANSACTION TRA_Act_Fvpop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
						OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
						OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvpop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase distinta a 38 o 43) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvpop
		
		
	--Actualización del dato para hipotecas comunes con clase igual a 38 o 43
	BEGIN TRANSACTION TRA_Act_Fvpop3843
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END,
					GRO.Fecha_Replica = GETDATE()
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
				ON GGR.cod_garantia_real = GRO.cod_garantia_real
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON GO1.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_SICC_PRMGT MGT 
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = GO1.cod_producto
				AND MGT.prmgt_pnu_oper = GO1.num_operacion
			WHERE	((GGR.cod_clase_garantia = 38)
						OR (GGR.cod_clase_garantia = 43))
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
				AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvpop3843

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase igual a 38 o 43) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvpop3843
END	

--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para prendas
IF(@piIndicadorProceso = 12)
	BEGIN
	
		--Actualización del dato para hipotecas comunes con clase diferente a 38 o 43
		BEGIN TRANSACTION TRA_Act_Fvpc
			BEGIN TRY
	
				UPDATE	GRO
				SET		GRO.Fecha_Valuacion_SICC =	CASE 
														WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
														ELSE '19000101'
													END,
					GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_OPERACION GO1 
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT 
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
				WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
						OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
						OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
					AND GGR.cod_clase_garantia	= MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GO1.num_operacion IS NULL
					AND MGT.prmgt_estado = 'A'
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Fvpc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase diferente a 38 o 43) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Fvpc
			
			
			
		--Actualización del dato para hipotecas comunes con clase igual a 38 o 43
		BEGIN TRANSACTION TRA_Act_Fvpc3843
			BEGIN TRY
	
				UPDATE	GRO
				SET		GRO.Fecha_Valuacion_SICC =	CASE 
														WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
														ELSE '19000101'
													END,
					GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_OPERACION GO1 
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT 
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
				WHERE	((GGR.cod_clase_garantia = 38)
						OR (GGR.cod_clase_garantia = 43))
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GO1.num_operacion IS NULL
					AND MGT.prmgt_estado = 'A'
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Fvpc3843

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase igual a 38 o 43) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Fvpc3843
	END	

--Se inicializan todos los registros a 0 (cero)
IF(@piIndicadorProceso = 13)
	BEGIN
	
		BEGIN TRANSACTION TRA_Act_Avaluos
			BEGIN TRY
	
				UPDATE	dbo.GAR_VALUACIONES_REALES
				SET		Indicador_Tipo_Registro = 0
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avaluos

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a cero, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avaluos

	
		--Se obtienen los avalúos más recientes
		BEGIN TRANSACTION TRA_Act_Avalrec
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.Indicador_Tipo_Registro = 2
				FROM	dbo.GAR_VALUACIONES_REALES GV1
				INNER JOIN  (SELECT		cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
							 FROM		dbo.GAR_VALUACIONES_REALES
							 GROUP		BY cod_garantia_real) GV2
				ON	GV2.cod_garantia_real = GV1.cod_garantia_real
				AND GV2.fecha_valuacion	= GV1.fecha_valuacion

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avaluos

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a dos, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avaluos

		
		--Se obtienen los penúltimos avalúos
		BEGIN TRANSACTION TRA_Act_Avalpenul
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.Indicador_Tipo_Registro = 3
				FROM	dbo.GAR_VALUACIONES_REALES GV1
				INNER JOIN (SELECT	cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
							FROM	dbo.GAR_VALUACIONES_REALES
							WHERE	Indicador_Tipo_Registro = 0
							GROUP	BY cod_garantia_real) GV2
				ON	GV2.cod_garantia_real = GV1.cod_garantia_real
				AND GV2.fecha_valuacion	= GV1.fecha_valuacion
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalpenul

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a tres, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalpenul

		
			
		--Se obtienen los avalúos que son iguales a los registrados en el SICC para operaciones
		--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes, con clase distinta a 11
		BEGIN TRANSACTION TRA_Act_Avalhc
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.cod_partido,
											GGR.Identificacion_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
										AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
										GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND GHC.cod_partido = GGR.cod_partido
						AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
			
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalhc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las hipotecas comunes (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalhc



		--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes, con clase igual a 11
		BEGIN TRANSACTION TRA_Act_Avalhc11
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.cod_partido,
											GGR.Identificacion_Sicc,
											GGR.Identificacion_Alfanumerica_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
										AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 11
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
										AND COALESCE(MG3.prmgt_pnuidegar, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(MG3.prmgt_pnuide_alf, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	GGR.cod_clase_garantia = 11
										GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND GHC.cod_partido = GGR.cod_partido
						AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
						AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
			
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalhc11

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las hipotecas comunes (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalhc11


		
		--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía 18
		BEGIN TRANSACTION TRA_Act_Avalch18
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE() 
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.cod_partido,
											GGR.Identificacion_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcoclagar = 18
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
										AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	GGR.cod_clase_garantia = 18
										GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.cod_grado
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND GHC.cod_partido = GGR.cod_partido
						AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalch18

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las cédulas hipotecarias con clase 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalch18

		
		--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
		BEGIN TRANSACTION TRA_Act_Avalch
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE() 
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.cod_grado,
											GGR.Identificacion_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pco_grado, MG2.prmgt_pnuidegar, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnu_part,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pco_grado, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pco_grado = GGR.cod_grado
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pco_grado,
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	CONVERT(VARCHAR(2), MG1.prmgt_pco_grado) AS prmgt_pco_grado,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	MG1.prmgt_pcotengar = 1
																	AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pco_grado, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND MG3.prmgt_pco_grado = MGT.prmgt_pco_grado
										AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
										GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.cod_grado
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND GHC.cod_grado = GGR.cod_grado
						AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalch

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las cédulas hipotecarias con clase diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalch

		
		--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas, con clase diferente a 38 o 43
		BEGIN TRANSACTION TRA_Act_Avalp
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE() 
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.Identificacion_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																			OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																			OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
													OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
													OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
										GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalp

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las prendas (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalp
			
			
		--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas, con clase igual a 38 o 43
		BEGIN TRANSACTION TRA_Act_Avalp3843
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1,
						GV1.Fecha_Replica = GETDATE() 
				FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (
					SELECT	DISTINCT 
						GGR.cod_garantia_real, 
						CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
						GHC.monto_total_avaluo 
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (	SELECT	TOP 100 PERCENT 
											GGR.cod_clase_garantia,
											GGR.Identificacion_Sicc,
											GGR.Identificacion_Alfanumerica_Sicc,
											MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
											MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
										FROM	dbo.GAR_GARANTIA_REAL GGR 
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
																MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
										ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
										AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
														FROM	
														(		SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMOC MOC
																				WHERE	MOC.prmoc_pse_proces = 1
																					AND MOC.prmoc_estado = 'A'
																					AND MOC.prmoc_pnu_contr = 0
																					AND ((MOC.prmoc_pcoctamay > 815)
																						OR (MOC.prmoc_pcoctamay < 815))
																					AND MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
																					AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
																					AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
																					AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin >= @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10)
																UNION ALL
																SELECT	MG1.prmgt_pcoclagar,
																	MG1.prmgt_pnuidegar,
																	MG1.prmgt_pnuide_alf,
																	CASE 
																		WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																		WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																		ELSE '19000101'
																	END AS prmgt_pfeavaing,
																	MG1.prmgt_pmoavaing
																FROM	dbo.GAR_SICC_PRMGT MG1
																WHERE	((MG1.prmgt_pcoclagar = 38)
																			OR (MG1.prmgt_pcoclagar = 43))
																	AND MG1.prmgt_estado = 'A'
																	AND EXISTS (SELECT	1
																				FROM	dbo.GAR_SICC_PRMCA MCA
																				WHERE	MCA.prmca_estado = 'A'
																					AND MCA.prmca_pfe_defin < @viFechaActualEntera
																					AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																					AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																					AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																					AND MG1.prmgt_pco_produ = 10
																					AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMOC MC1
																						WHERE	MC1.prmoc_pse_proces = 1		--Operaciones activas
																							AND MC1.prmoc_estado = 'A'	
																							AND ((MC1.prmoc_pcoctamay > 815)
																								OR (MC1.prmoc_pcoctamay < 815))	--Operaciones no insolutas
																							AND MC1.prmoc_pco_oficon = MCA.prmca_pco_ofici
																							AND MC1.prmoc_pcomonint = MCA.prmca_pco_moned
																							AND MC1.prmoc_pnu_contr = MCA.prmca_pnu_contr))
														) MG2
														GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MG3
										ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
										AND COALESCE(MG3.prmgt_pnuidegar, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(MG3.prmgt_pnuide_alf, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
										AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
										WHERE	((GGR.cod_clase_garantia = 38)
													OR (GGR.cod_clase_garantia = 43))
										GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
									) GHC
						ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
						AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
						AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
					WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.cod_garantia_real
					AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
		
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Avalp3843

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las prendas (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalp3843
	END	

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

