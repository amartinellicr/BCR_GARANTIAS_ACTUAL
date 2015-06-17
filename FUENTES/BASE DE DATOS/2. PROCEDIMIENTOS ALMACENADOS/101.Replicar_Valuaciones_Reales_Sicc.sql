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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Migra la informaci�n de las valuaciones de las garant�as reales, del 
			     SICC a la base de datos GARANTIAS. 
	</Descripci�n>
	<Entradas>
			@piIndicadorProceso		= Indica la parte del proceso que ser� ejecutada.
			@psCodigoProceso		= C�digo del proceso que ejecuta este procedimiento almacenado.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>12/07/2014</Fecha>
	<Requerimiento>Req Bcr Garantias Migraci�n, Siebel No.1-24015441</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
******************************************************************/
	SET NOCOUNT ON 


	DECLARE	 @vdFechaActualSinHora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
		@viFechaActualEntera INT, --Corresponde al a fecha actual en formato num�rico.
		@vsDescripcionError VARCHAR(1000), --Descripci�n del error capturado.
		@vsDescripcionBitacoraErrores VARCHAR(5000) --Descripci�n del error que ser� guardado en la bit�cora de errores.

	--Se inicializan las variables
	SET	@vdFechaActualSinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
----------------------------------------------------------------------
--CARGA VALUACIONES DE GARANTIAS REALES
----------------------------------------------------------------------
--Se asigna la fecha del aval�o m�s reciente para hipotecas comunes
IF(@piIndicadorProceso = 1)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Vrhc
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
								WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los aval�os de las hipotecas comunes. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrhc
END	

--Se asigna la fecha del aval�o m�s reciente para c�dulas hipotecarias con clase de garant�a 18
IF(@piIndicadorProceso = 2)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Vrch18
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo
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

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los aval�os de las c�dulas hipotecarias con clase 18. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrch18
END	

--Se asigna la fecha del aval�o m�s reciente para c�dulas hipotecarias con clase de garant�a diferente a 18
IF(@piIndicadorProceso = 3)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Vrch
		BEGIN TRY

			INSERT INTO dbo.GAR_VALUACIONES_REALES
			(
				cod_garantia_real, 
				fecha_valuacion, 
				monto_total_avaluo
			)
			SELECT	DISTINCT 
				GGR.cod_garantia_real, 
				CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
				0 AS monto_total_avaluo
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

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los aval�os de las c�dulas hipotecarias con clase diferente a 18. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Vrch
END	

--Se asigna la fecha del aval�o m�s reciente para prendas
IF(@piIndicadorProceso = 4)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Vrp
			BEGIN TRY
	
				INSERT INTO dbo.GAR_VALUACIONES_REALES
				(
					cod_garantia_real, 
					fecha_valuacion, 
					monto_total_avaluo
				)
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
					0 AS monto_total_avaluo
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
									WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los aval�os de las prendas. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Vrp
	END	

--Se actualiza el campo de la fecha de valuaci�n registrada en el SICC, en la tabla de valuaciones.
--Si la fecha de valuaci�n del SICC es 01/01/1900 implica que el dato almacenado en el Maestro de Garant�as (tabla PRMGT) no corresponde a una fecha.
--Si la fecha de valuaci�n dle SICC es igual a NULL es porque la garant�a nunca fue encontrada en el Maestro de Garant�as (tabla PRMGT).

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y esa operaci�n dentro del Maestro de Garant�as del SICC, esto para hipotecas comunes
IF(@piIndicadorProceso = 5)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvhcop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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
			WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada hipoteca com�n asociada a operaciones. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcop
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y ese contrato dentro del Maestro de Garant�as del SICC, esto para hipotecas comunes
IF(@piIndicadorProceso = 6)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvhcc
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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
			WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvhcop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada hipoteca com�n asociada a contratos. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvhcop
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y esa operaci�n dentro del Maestro de Garant�as del SICC, esto para c�dulas hipotecarias
IF(@piIndicadorProceso = 7)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvch18op
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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
				AND GGR.cod_partido	= MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc	= MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvch18op

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada c�dula hipotecaria, con clase 18, asociada a operaciones. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvch18op
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y ese contrato dentro del Maestro de Garant�as del SICC, esto para c�dulas hipotecarias
IF(@piIndicadorProceso = 8)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvch18c
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_operacion IS NULL
				AND MGT.prmgt_estado = 'A'
	
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvch18c

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada c�dula hipotecaria, con clase 18, asociada a contratos. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvch18c
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y esa operaci�n dentro del Maestro de Garant�as del SICC, esto para c�dulas hipotecarias
IF(@piIndicadorProceso = 9)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvchop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada c�dula hipotecaria, con clase diferente a 18, asociada a operaciones. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvchop
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y ese contrato dentro del Maestro de Garant�as del SICC, esto para c�dulas hipotecarias
IF(@piIndicadorProceso = 10)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvchc
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada c�dula hipotecaria, con clase diferente a 18, asociada a contratos. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvchc
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y esa operaci�n dentro del Maestro de Garant�as del SICC, esto para prendas
IF(@piIndicadorProceso = 11)
BEGIN
	BEGIN TRANSACTION TRA_Act_Fvpop
		BEGIN TRY

			UPDATE	GRO
			SET		GRO.Fecha_Valuacion_SICC =	CASE 
													WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
													WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
													ELSE '19000101'
												END
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
			WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
				AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GO1.num_contrato = 0
				AND MGT.prmgt_estado = 'A'

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION TRA_Act_Fvpop

		SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada prenda asociada a operaciones. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
		EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

	END CATCH
	
	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Act_Fvpop
END	

--Se actualiza la fecha de valuaci�n SICC con el dato almacenado para esa garant�a y ese contrato dentro del Maestro de Garant�as del SICC, esto para prendas
IF(@piIndicadorProceso = 12)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Fvpc
			BEGIN TRY
	
				UPDATE	GRO
				SET		GRO.Fecha_Valuacion_SICC =	CASE 
														WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
														WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
														ELSE '19000101'
													END
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
				WHERE	GGR.cod_clase_garantia	BETWEEN 30 AND 69
					AND GGR.cod_clase_garantia	= MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GO1.num_operacion IS NULL
					AND MGT.prmgt_estado = 'A'
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Fvpc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la fecha de valuaci�n del SICC para una determinada prenda asociada a contratos. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Fvpc
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a cero, el indicador del tipo de registro de los aval�os. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avaluos

	
		--Se obtienen los aval�os m�s recientes
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a dos, el indicador del tipo de registro de los aval�os. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avaluos

		
		--Se obtienen los pen�ltimos aval�os
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a tres, el indicador del tipo de registro de los aval�os. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalpenul

		
		
		--Se obtienen los aval�os que son iguales a los registrados en el SICC para operaciones
		--Se asigna el m�nimo monto de la fecha del aval�o m�s reciente para hipotecas comunes
		BEGIN TRANSACTION TRA_Act_Avalhc
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
																WHERE	MG1.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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
										WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los aval�os y el monto total del aval�o de las hipotecas comunes. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalhc

		
		--Se asigna el m�nimo monto de la fecha del avla�o m�s reciente para c�dulas hipotecarias con clase de garant�a 18
		BEGIN TRANSACTION TRA_Act_Avalch18
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1 
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los aval�os y el monto total del aval�o de las c�dulas hipotecarias con clase 18. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalch18

		
		--Se asigna el m�nimo monto de la fecha del avla�o m�s reciente para c�dulas hipotecarias con clase de garant�a diferente a 18
		BEGIN TRANSACTION TRA_Act_Avalch
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1 
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los aval�os y el monto total del aval�o de las c�dulas hipotecarias con clase diferente a 18. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalch

		
		--Se asigna el m�nimo monto de la fecha del avla�o m�s reciente para prendas
		BEGIN TRANSACTION TRA_Act_Avalp
			BEGIN TRY
		
				UPDATE	GV1
				SET		GV1.monto_total_avaluo = TMP.monto_total_avaluo,
						GV1.Indicador_Tipo_Registro = 1 
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
														GROUP BY MG2.prmgt_pcoclagar, prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
																WHERE	MG1.prmgt_pcoclagar BETWEEN 30 AND 69
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
										WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los aval�os y el monto total del aval�o de las prendas. Detalle T�cnico: ' + ERROR_MESSAGE() + ('. C�digo de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Avalp
	END	

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

