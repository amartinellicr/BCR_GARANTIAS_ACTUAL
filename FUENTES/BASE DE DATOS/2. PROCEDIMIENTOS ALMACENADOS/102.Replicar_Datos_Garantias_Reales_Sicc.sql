USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('dbo.Replicar_Datos_Garantias_Reales_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Replicar_Datos_Garantias_Reales_Sicc;
GO

CREATE PROCEDURE [dbo].[Replicar_Datos_Garantias_Reales_Sicc]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)	
AS
BEGIN
/******************************************************************
	<Nombre>Replicar_Datos_Garantias_Reales_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de las garantías reales, del SICC a la base de datos GARANTIAS. 
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
			<Fecha>26/06/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
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
	
	-------------------------------------------------------------------------------------------------------------------------
	-- ACTUALIZAR DATOS DE GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Se actualizan los datos de las garantías reales asociadas a operaciones directas
	IF(@piIndicadorProceso = 1)
	BEGIN
		--Actualizar datos de las hipotecas comunes (con clase distinta a 11) asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperhc
			BEGIN TRY

				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 1
															WHEN MGT.prmgt_pco_grado = 2 THEN 2
															WHEN MGT.prmgt_pco_grado = 3 THEN 3
															WHEN MGT.prmgt_pco_grado >= 4 THEN 4
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperhc

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de hipoteca común (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperhc
					
					
		
		--Actualizar datos de las hipotecas comunes (con clase igual a 11) asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperhc11
			BEGIN TRY

				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 1
															WHEN MGT.prmgt_pco_grado = 2 THEN 2
															WHEN MGT.prmgt_pco_grado = 3 THEN 3
															WHEN MGT.prmgt_pco_grado >= 4 THEN 4
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperhc11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de hipoteca común (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperhc11			
					
					
					
		--Actualizar datos de las cédulas hipotecarias, con clase 18, asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperch18
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 5
															WHEN MGT.prmgt_pco_grado = 2 THEN 6
															WHEN MGT.prmgt_pco_grado = 3 THEN 7
															WHEN MGT.prmgt_pco_grado >= 4 THEN 8
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperch18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales cédula hipotecaria con clase de garantía 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperch18

		--Actualizar datos de las cédulas hipotecarias, con clase diferente a 18, asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperch
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 5
															WHEN MGT.prmgt_pco_grado = 2 THEN 6
															WHEN MGT.prmgt_pco_grado = 3 THEN 7
															WHEN MGT.prmgt_pco_grado >= 4 THEN 8
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar = 1
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperch

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de cádula hipotecaria con clase de garantía diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperch

		--Actualizar datos de las prendas (con clase distinta a 38 o 43) asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperp
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 9
															WHEN MGT.prmgt_pco_grado = 2 THEN 10
															WHEN MGT.prmgt_pco_grado = 3 THEN 11
															WHEN MGT.prmgt_pco_grado >= 4 THEN 12
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
						OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
						OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperp

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de prenda (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperp
			
		
		--Actualizar datos de las prendas (con clase igual a 38 o 43) asociadas a operaciones
		BEGIN TRANSACTION TRA_Act_Garoperp3843
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MOC.prmoc_pfe_const = 0 THEN NULL
													WHEN (ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MOC.prmoc_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1) 
														  AND (LEN(MOC.prmoc_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 9
															WHEN MGT.prmgt_pco_grado = 2 THEN 10
															WHEN MGT.prmgt_pco_grado = 3 THEN 11
															WHEN MGT.prmgt_pco_grado >= 4 THEN 12
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMOC MOC
					ON MOC.prmoc_pco_ofici = GOP.cod_oficina
					AND MOC.prmoc_pco_moned = GOP.cod_moneda
					AND MOC.prmoc_pco_produ = GOP.cod_producto
					AND MOC.prmoc_pnu_oper = GOP.num_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
					AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
					AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
					AND MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
				WHERE	GOP.num_contrato = 0
					AND GOP.num_operacion IS NOT NULL
					AND MOC.prmoc_pnu_contr = 0
					AND MOC.prmoc_pse_proces = 1		--Operaciones activas
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
					AND MOC.prmoc_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperp3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de prenda (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperp3843
	END	

	--Se actualizan los datos de las garantías reales asociadas a contratos
	IF(@piIndicadorProceso = 2)
	BEGIN
	
		--Actualizar datos de las hipotecas comunes (con clase distinta a 11) asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrhc
			BEGIN TRY

				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 1
															WHEN MGT.prmgt_pco_grado = 2 THEN 2
															WHEN MGT.prmgt_pco_grado = 3 THEN 3
															WHEN MGT.prmgt_pco_grado >= 4 THEN 4
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrhc

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de hipoteca común (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrhc
			
		
		--Actualizar datos de las hipotecas comunes (con clase igual a 11) asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrhc11
			BEGIN TRY

				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 1
															WHEN MGT.prmgt_pco_grado = 2 THEN 2
															WHEN MGT.prmgt_pco_grado = 3 THEN 3
															WHEN MGT.prmgt_pco_grado >= 4 THEN 4
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrhc11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de hipoteca común (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrhc11
		
					
		--Actualizar datos de las cédulas hipotecarias, con clase 18, asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrch18
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 5
															WHEN MGT.prmgt_pco_grado = 2 THEN 6
															WHEN MGT.prmgt_pco_grado = 3 THEN 7
															WHEN MGT.prmgt_pco_grado >= 4 THEN 8
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrch18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales cédula hipotecaria con clase de garantía 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrch18

		--Actualizar datos de las cédulas hipotecarias, con clase diferente a 18, asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrch
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 5
															WHEN MGT.prmgt_pco_grado = 2 THEN 6
															WHEN MGT.prmgt_pco_grado = 3 THEN 7
															WHEN MGT.prmgt_pco_grado >= 4 THEN 8
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar = 1
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrch

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de cádula hipotecaria con clase de garantía diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrch

		--Actualizar datos de las prendas (con clase distinta a 38 o 43) asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrp
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 9
															WHEN MGT.prmgt_pco_grado = 2 THEN 10
															WHEN MGT.prmgt_pco_grado = 3 THEN 11
															WHEN MGT.prmgt_pco_grado >= 4 THEN 12
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
						OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
						OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrp

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de prenda (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrp	
			
		
		--Actualizar datos de las prendas (con clase igual a 38 o 43) asociadas a contratos
		BEGIN TRANSACTION TRA_Act_Garcontrp3843
			BEGIN TRY
			
				UPDATE  GRO
				SET     GRO.fecha_constitucion = CASE 
													WHEN MCA.prmca_pfe_const = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1) 
														  AND (LEN(MCA.prmca_pfe_const) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const))
													ELSE NULL
												 END,
						GRO.fecha_vencimiento = CASE 
													WHEN MCA.prmca_pfe_defin = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1) 
														  AND (LEN(MCA.prmca_pfe_defin) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin))
													ELSE NULL
												 END,
						GRO.cod_grado_gravamen =	CASE 
														WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
														WHEN MGT.prmgt_pco_grado >= 4 THEN 4
														ELSE NULL			
													END, 
						GRO.fecha_prescripcion = CASE 
													WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
													WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
														  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
														  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
													ELSE NULL
												 END,
						GRO.cod_tipo_documento_legal =	CASE 
															WHEN MGT.prmgt_pco_grado = 1 THEN 9
															WHEN MGT.prmgt_pco_grado = 2 THEN 10
															WHEN MGT.prmgt_pco_grado = 3 THEN 11
															WHEN MGT.prmgt_pco_grado >= 4 THEN 12
															ELSE NULL
														END,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GOP
					ON GOP.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_garantia_real = GRO.cod_garantia_real
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON MCA.prmca_pco_ofici = GOP.cod_oficina
					AND MCA.prmca_pco_moned = GOP.cod_moneda
					AND MCA.prmca_pco_produc = GOP.cod_producto
					AND MCA.prmca_pnu_contr = GOP.num_contrato
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
					AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
				WHERE	GOP.num_contrato > 0
					AND GOP.num_operacion IS NULL
					AND MCA.prmca_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrp3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de prenda (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrp3843
	END	

	
	-------------------------------------------------------------------------------------------------------------------------
	-- INDICADOR DE INDISCRIPCION DE GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Se asigna el indicador 1 a todas las garantías reales asociadas a operaciones directas activas
	IF(@piIndicadorProceso = 3)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Indinsop
			BEGIN TRY
	
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				WHERE	EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
									INNER JOIN dbo.GAR_SICC_PRMOC MOC
									ON GO1.cod_oficina = MOC.prmoc_pco_ofici
									AND	GO1.cod_moneda = MOC.prmoc_pco_moned
									AND GO1.cod_producto = MOC.prmoc_pco_produ
									AND GO1.num_operacion = MOC.prmoc_pnu_oper
								WHERE	GO1.num_contrato = 0
									AND GO1.cod_operacion = GRO.cod_operacion
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_estado = 'A'	
									AND MOC.prmoc_pnu_contr = 0)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Indinsop

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador de inscripción de las garantías reales asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Indinsop


		--Se asigna el indicador 1 a todas las garantías reales asociadas a contratos vigentes
		BEGIN TRANSACTION TRA_Act_Indinscv
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				WHERE	EXISTS (SELECT	1	
								FROM	dbo.GAR_OPERACION GO1
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON GO1.cod_oficina = MCA.prmca_pco_ofici
									AND	GO1.cod_moneda = MCA.prmca_pco_moned
									AND GO1.cod_producto = MCA.prmca_pco_produc
									AND GO1.num_contrato = MCA.prmca_pnu_contr
								WHERE	GO1.cod_operacion = GRO.cod_operacion
									AND GO1.num_operacion IS NULL
									AND MCA.prmca_estado = 'A'	
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera)
				
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Indinscv

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador de inscripción de las garantías reales asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Indinscv

				
		--Se asigna el indicador 1 a todas las garantías reales asociadas a contratos vencidos, pero con giros activos
		BEGIN TRANSACTION TRA_Act_Indinscvga
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				WHERE	EXISTS (SELECT	1	
								FROM	dbo.GAR_OPERACION GO1
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON GO1.cod_oficina = MCA.prmca_pco_ofici
									AND	GO1.cod_moneda = MCA.prmca_pco_moned
									AND GO1.cod_producto = MCA.prmca_pco_produc
									AND GO1.num_contrato = MCA.prmca_pnu_contr
								WHERE	GO1.cod_operacion = GRO.cod_operacion
									AND GO1.num_operacion IS NULL
									AND MCA.prmca_estado = 'A'	
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND EXISTS (SELECT 1
												FROM dbo.GAR_SICC_PRMOC MOC
												WHERE MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND MOC.prmoc_estado = 'A'
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Indinscvga

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar, a uno, el indicador de inscripción de las garantías reales asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Indinscvga

	END
	
	--Actualiza el indicador de inscripción de garantías reales asociadas a operaciones
	IF(@piIndicadorProceso = 4)
	BEGIN

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grophc3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grophc3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grophc3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grophc2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grophc2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grophc2
		
		
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grophc11_3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grophc11_3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grophc11_3
			
		
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grophc11_2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grophc11_2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grophc11_2
		
		
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropch3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropch3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropch3
			
			
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropch2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropch2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropch2
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropch3_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropch3_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropch3_18
			
			
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropch2_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropch2_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropch2_18
			
			
	    --Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropp3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropp3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropp3
			
			
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropp2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropp2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropp2
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropp3_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropp3_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropp3_3843
			
			
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Gropp2_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	 MOC.prmoc_estado = 'A'
									AND MOC.prmoc_pse_proces = 1	--Operaciones activas
									AND ((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
									AND MOC.prmoc_pnu_contr = 0
									AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
									AND MOC.prmoc_pco_ofici = GO1.cod_oficina
									AND MOC.prmoc_pco_moned = GO1.cod_moneda
									AND MOC.prmoc_pco_produ = GO1.cod_producto
									AND MOC.prmoc_pnu_oper = GO1.num_operacion)
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gropp2_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gropp2_3843

	END
	
	--Actualiza el indicador de inscripción de garantías reales asociadas a contratos vigentes
	IF(@piIndicadorProceso = 5)
	BEGIN
	
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocv3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocv3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocv3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocv2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocv2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocv2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocv3_11
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocv3_11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocv3_11
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocv2_11
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocv2_11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocv2_11
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvch3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvch3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvch3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvch2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvch2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvch2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvch3_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvch3_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvch3_18
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvch2_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvch2_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvch2_18
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvp3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvp3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvp3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvp2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvp2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvp2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvp3_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvp3_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvp3_3843
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvp2_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	>= @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvp2_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvp2_3843

	END
	
	--Actualiza el indicador de inscripción de garantías reales asociadas a contratos vencidos con giros activos
	IF(@piIndicadorProceso = 6)
	BEGIN

		--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vencidos, 
		--pero con giros activos, registradas en el sistema 
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvga3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvga3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvga3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvga2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvga2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase distinta a 11) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvga2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvga3_11
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvga3_11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvga3_11
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvga2_11
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvga2_11

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de hipoteca común (con clase igual a 11) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvga2_11
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgach3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgach3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgach3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgach2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pcotengar = 1
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgach2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase distinta a 18) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgach2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgach3_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgach3_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgach3_18
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgach2_18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND MRI.prmri_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgach2_18

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de cédula hipotecaria (con clase igual a 18) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgach2_18
			
			
		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgap3
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgap3

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgap3
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgap2
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar BETWEEN 30 AND 37)
						OR (MRI.prmri_pcoclagar BETWEEN 39 AND 42)
						OR (MRI.prmri_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgap2

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase distinta a 38 o 43) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgap2
			
			

		--Se realiza el ajuste del indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgap3_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 3,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 2
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgap3_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Inscrita" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgap3_3843
			
		
		--Se realiza el ajuste del indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vencidos con giros activos registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvgap2_3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = 2,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GRO.cod_inscripcion = 1
					AND GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND MRI.prmri_pcoestins = 1
					AND ((MRI.prmri_pcoclagar = 38)
						OR (MRI.prmri_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pcoclagar = MRI.prmri_pcoclagar
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
													AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMCA MCA
								WHERE	MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin	< @viFechaActualEntera
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_SICC_PRMOC MOC
												WHERE	MOC.prmoc_pse_proces = 1		--Operaciones activas
													AND ((MOC.prmoc_pcoctamay < 815)
														OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
													AND MOC.prmoc_estado = 'A'
													AND MOC.prmoc_pnu_contr	= MCA.prmca_pnu_contr	
													AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
													AND MOC.prmoc_pcomonint	= MCA.prmca_pco_moned))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grocvgap2_3843

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción "Anotada" de las garantías reales de prenda (con clase igual a 38 o 43) asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grocvgap2_3843
			
	
			
		--en caso de que se trate del proceso de replica que se encarga de cargar los contratos vencidos se debe actualzia la fecha de réplica en este procedimiento almacenado
		IF(@psCodigoProceso = 'CARGARCONTRATVENCID')
		BEGIN
		
			--Se actualiza la fecha de la replica, de la información básica de la garantía fiduciaria, a la mayor que posea cada registro en la relación
			BEGIN TRANSACTION TRA_Act_Gf
				BEGIN TRY	
				
					UPDATE	GGF
					SET		GGF.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
						INNER JOIN (SELECT GRF.cod_garantia_fiduciaria, MAX(GRF.Fecha_Replica) AS Fecha_Replica
									FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GRF
										INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GF1
										ON GF1.cod_garantia_fiduciaria = GRF.cod_garantia_fiduciaria
									GROUP BY GRF.cod_garantia_fiduciaria) TMP
						ON TMP.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
					WHERE	TMP.Fecha_Replica > COALESCE(GGF.Fecha_Replica, '19000101')

				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gf

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía fiduciaria. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gf
			
			--Se actualiza la fecha de la replica, de la información de la relación de la garantía fiduciaria, a la mayor que posea cada registro en la información básica
			BEGIN TRANSACTION TRA_Act_Grf
				BEGIN TRY	
				
					UPDATE	GRF
					SET		GRF.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GRF
						INNER JOIN (SELECT	GF1.cod_garantia_fiduciaria, MAX(GF1.Fecha_Replica) AS Fecha_Replica
									FROM	dbo.GAR_GARANTIA_FIDUCIARIA GF1
										INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GR1
										ON GR1.cod_garantia_fiduciaria = GF1.cod_garantia_fiduciaria
									GROUP BY GF1.cod_garantia_fiduciaria) TMP
							ON TMP.cod_garantia_fiduciaria = GRF.cod_garantia_fiduciaria
						WHERE	TMP.Fecha_Replica > COALESCE(GRF.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grf

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía fiduciaria. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grf
				
			
			--Se actualiza la fecha de la replica, de la información básica de la garantía real, a la mayor que posea cada registro en la relación
			BEGIN TRANSACTION TRA_Act_Gr
				BEGIN TRY	
					
					UPDATE	GGR
					SET		GGR.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN (SELECT	TM1.cod_garantia_real, MAX(TM1.Fecha_Replica) AS Fecha_Replica
									FROM	(SELECT	DISTINCT GG1.cod_garantia_real, COALESCE(GG1.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIA_REAL GG1
											
											 UNION ALL 
											 
											 SELECT	DISTINCT GRO.cod_garantia_real, COALESCE(GRO.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
											 
											 UNION ALL
											 
											 SELECT	DISTINCT GVR.cod_garantia_real, COALESCE(GVR.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_VALUACIONES_REALES GVR) TM1
									GROUP BY TM1.cod_garantia_real) TMP
						ON TMP.cod_garantia_real = GGR.cod_garantia_real
					WHERE	TMP.Fecha_Replica > COALESCE(GGR.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gr

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gr
			
			--Se actualiza la fecha de la replica, de la información de la relación de la garantía real, a la mayor que posea cada registro en la información básica
			BEGIN TRANSACTION TRA_Act_Gro
				BEGIN TRY	
				
					UPDATE	GRO
					SET		GRO.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN (SELECT	TM1.cod_garantia_real, MAX(TM1.Fecha_Replica) AS Fecha_Replica
									FROM	(SELECT	DISTINCT GG1.cod_garantia_real, COALESCE(GG1.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIA_REAL GG1
											
											 UNION ALL 
											 
											 SELECT	DISTINCT GRO.cod_garantia_real, COALESCE(GRO.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
											 
											 UNION ALL
											 
											 SELECT	DISTINCT GVR.cod_garantia_real, COALESCE(GVR.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_VALUACIONES_REALES GVR) TM1
									GROUP BY TM1.cod_garantia_real) TMP
						ON TMP.cod_garantia_real = GRO.cod_garantia_real
					WHERE	TMP.Fecha_Replica > COALESCE(GRO.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gro

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gro
				
			
			--Se actualiza la fecha de la replica, de la información de la relación de la garantía real, a la mayor que posea cada registro en la información básica
			BEGIN TRANSACTION TRA_Act_Grv
				BEGIN TRY	
				
					UPDATE	GRV
					SET		GRV.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_VALUACIONES_REALES GRV
						INNER JOIN (SELECT	TM1.cod_garantia_real, MAX(TM1.Fecha_Replica) AS Fecha_Replica
									FROM	(SELECT	DISTINCT GG1.cod_garantia_real, COALESCE(GG1.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIA_REAL GG1
											
											 UNION ALL 
											 
											 SELECT	DISTINCT GRO.cod_garantia_real, COALESCE(GRO.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
											 
											 UNION ALL
											 
											 SELECT	DISTINCT GVR.cod_garantia_real, COALESCE(GVR.Fecha_Replica, '19000101') AS Fecha_Replica
											 FROM	dbo.GAR_VALUACIONES_REALES GVR) TM1
									GROUP BY TM1.cod_garantia_real) TMP
						ON TMP.cod_garantia_real = GRV.cod_garantia_real
					WHERE	TMP.Fecha_Replica > COALESCE(GRV.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros del avalúo de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grv
			
			--Se actualiza la fecha de la replica, de la información básica de la garantía de valor, a la mayor que posea cada registro en la relación
			BEGIN TRANSACTION TRA_Act_Gv
				BEGIN TRY	
				
					UPDATE	GGV
					SET		GGV.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIA_VALOR GGV
						INNER JOIN (SELECT	GVO.cod_garantia_valor, MAX(GVO.Fecha_Replica) AS Fecha_Replica
									FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
										INNER JOIN dbo.GAR_GARANTIA_VALOR GV1
										ON GV1.cod_garantia_valor = GVO.cod_garantia_valor
									GROUP BY GVO.cod_garantia_valor) TMP
						ON TMP.cod_garantia_valor = GGV.cod_garantia_valor
					WHERE	TMP.Fecha_Replica > COALESCE(GGV.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gv
			
			--Se actualiza la fecha de la replica, de la información de la relación de la garantía de valor, a la mayor que posea cada registro en la información básica
			BEGIN TRANSACTION TRA_Act_Gvo
				BEGIN TRY	
				
					UPDATE	GVO
					SET		GVO.Fecha_Replica = TMP.Fecha_Replica
					FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						INNER JOIN (SELECT	GGV.cod_garantia_valor, MAX(GGV.Fecha_Replica) AS Fecha_Replica
									FROM	dbo.GAR_GARANTIA_VALOR GGV
										INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GV1
										ON GV1.cod_garantia_valor = GGV.cod_garantia_valor
									GROUP BY GGV.cod_garantia_valor) TMP
							ON TMP.cod_garantia_valor = GVO.cod_garantia_valor
						WHERE	TMP.Fecha_Replica > COALESCE(GVO.Fecha_Replica, '19000101')
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gvo

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gvo
				
		END
	END
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

