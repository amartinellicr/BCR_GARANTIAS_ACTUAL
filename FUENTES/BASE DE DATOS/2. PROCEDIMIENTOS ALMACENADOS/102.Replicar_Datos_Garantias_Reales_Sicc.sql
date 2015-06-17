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
		--Actualizar datos de las hipotecas comunes asociadas a operaciones
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
														END
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
					AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperhc

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de hipoteca común. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garoperhc
					
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
														END
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
														END
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

		--Actualizar datos de las prendas asociadas a operaciones
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
														END
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
					AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garoperp

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre operaciones y garantías reales de prenda. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Garoperp
	END	

	--Se actualizan los datos de las garantías reales asociadas a contratos
	IF(@piIndicadorProceso = 2)
	BEGIN
		--Actualizar datos de las hipotecas comunes asociadas a contratos
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
														END
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
					AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrhc

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de hipoteca común. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Garcontrhc
					
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
														END
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
					AND MGT.prmgt_pcoclagar = 18
					AND GGR.cod_partido = MGT.prmgt_pnu_part
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
														END
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

		--Actualizar datos de las prendas asociadas a contratos
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
														END
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
					AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
					AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND MGT.prmgt_estado = 'A'

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Garcontrp

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la información de las relaciones entre contratos y garantías reales de prenda. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRAN	
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
				SET		GRO.cod_inscripcion = 1
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
				SET		GRO.cod_inscripcion = 1
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
				SET		GRO.cod_inscripcion = 1
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

		--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a operaciones activas registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grop
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = CASE MRI.prmri_pcoestins
												WHEN 1 THEN 2
												WHEN 2 THEN 3
												ELSE 1
										  END
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND GO1.cod_producto = MRI.prmri_pco_produ
					AND GO1.num_operacion = MRI.prmri_pnu_opera
				WHERE	GO1.num_contrato = 0
					AND MRI.prmri_estado = 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND  MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
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
					ROLLBACK TRANSACTION TRA_Act_Grop

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción de las garantías reales asociadas a operaciones activas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grop

	END
	
	--Actualiza el indicador de inscripción de garantías reales asociadas a contratos vigentes
	IF(@piIndicadorProceso = 5)
	BEGIN
	
		--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vigentes registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocv
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = CASE MRI.prmri_pcoestins
												WHEN 1 THEN 2
												WHEN 2 THEN 3
												ELSE 1
										  END
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pco_produ = 10
									AND  MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
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
					ROLLBACK TRANSACTION TRA_Act_Grocv

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción de las garantías reales asociadas a contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grocv


	END
	
	--Actualiza el indicador de inscripción de garantías reales asociadas a contratos vencidos con giros activos
	IF(@piIndicadorProceso = 6)
	BEGIN

		--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vencidos, 
		--pero con giros activos, registradas en el sistema
		BEGIN TRANSACTION TRA_Act_Grocvga
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_inscripcion = CASE MRI.prmri_pcoestins
												WHEN 1 THEN 2
												WHEN 2 THEN 3
												ELSE 1
										  END
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMRI MRI
					ON GO1.cod_oficina = MRI.prmri_pco_ofici
					AND	GO1.cod_moneda = MRI.prmri_pco_moned
					AND MRI.prmri_pco_produ = 10
					AND GO1.num_contrato = MRI.prmri_pnu_opera
				WHERE	GO1.num_operacion IS NULL
					AND MRI.prmri_estado = 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
								WHERE	MGT.prmgt_estado = 'A'
									AND MGT.prmgt_pco_produ = 10
									AND  MGT.prmgt_pco_conta = MRI.prmri_pco_conta
									AND MGT.prmgt_pco_ofici = MRI.prmri_pco_ofici
									AND MGT.prmgt_pco_moned = MRI.prmri_pco_moned
									AND MGT.prmgt_pco_produ = MRI.prmri_pco_produ
									AND MGT.prmgt_pnu_oper = MRI.prmri_pnu_opera
									AND CONVERT(VARCHAR(25), MGT.prmgt_pnuidegar) = RTRIM(LTRIM(MRI.prmri_pnuide_alf))
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_garantia_real = GRO.cod_garantia_real
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
					ROLLBACK TRANSACTION TRA_Act_Grocvga

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el indicador de inscripción de las garantías reales asociadas a contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grocvga
	END
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

