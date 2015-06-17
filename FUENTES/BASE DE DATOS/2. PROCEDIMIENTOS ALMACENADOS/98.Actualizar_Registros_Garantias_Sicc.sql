USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.Actualizar_Registros_Garantias_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Actualizar_Registros_Garantias_Sicc;
GO

CREATE PROCEDURE [dbo].[Actualizar_Registros_Garantias_Sicc]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)	
AS
BEGIN
/******************************************************************
	<Nombre>Actualizar_Registros_Garantias_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Actualiza cierta información de garantías de las operaciones de crédito y de los contratos del 
			     SICC existentes en la base de datos GARANTIAS. Además, habilita y deshabilita registros.
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
	
	---------------------------------------------------------------------------------------------------------------------------
	---- DEUDORES
	---------------------------------------------------------------------------------------------------------------------------
	--Inicializa el estado de los deudores como Inactivos
	IF(@piIndicadorProceso = 1)
	BEGIN
	
		--Se actualiza el campo de la identificación del deudor
		BEGIN TRANSACTION TRA_Act_Id_Deudor
			BEGIN TRY
			
				UPDATE	GDE
				SET		GDE.Identificacion_Sicc =	CASE
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GDE.cedula_deudor))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GDE.cedula_deudor))))
														ELSE -1
													END
				FROM	dbo.GAR_DEUDOR GDE

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Deudor

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la identificación numérica de los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Deudor
	
	
		BEGIN TRANSACTION TRA_Act_Deu
			BEGIN TRY
	
				UPDATE	dbo.GAR_DEUDOR 
				SET		cod_estado = 2

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Deu

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al desactivar a los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION TRA_Act_Deu

			--Actualiza los deudores de operaciones de crédito
			BEGIN	TRANSACTION TRA_Act_Deuop
				BEGIN TRY
			
					UPDATE 	DEU
					SET		DEU.nombre_deudor = MCL.bsmcl_sno_clien,
						DEU.cod_tipo_deudor = MCL.bsmcl_scotipide,
						DEU.cod_estado = 1	--Activo
					FROM	dbo.GAR_DEUDOR DEU
						INNER JOIN	dbo.GAR_SICC_BSMCL MCL
						ON MCL.bsmcl_sco_ident = DEU.Identificacion_Sicc
					WHERE	MCL.bsmcl_estado = 'A'
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMOC MOC
									WHERE	MOC.prmoc_pse_proces = 1 --Operaciones activas
										AND MOC.prmoc_estado = 'A'
										AND ((MOC.prmoc_psa_actual < 0)
											OR (MOC.prmoc_psa_actual > 0))	
										AND ((MOC.prmoc_pcoctamay < 815)
											OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
										AND MOC.prmoc_sco_ident = MCL.bsmcl_sco_ident
										AND MOC.prmoc_sco_ident = DEU.Identificacion_Sicc)
			

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Deuop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar y activar los deudores asociados a las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Deuop

			--Actualiza los deudores de operaciones de crédito
			BEGIN	TRANSACTION TRA_Act_Deuc
				BEGIN TRY
					UPDATE 	DEU
					SET		DEU.nombre_deudor = MCL.bsmcl_sno_clien,
						DEU.cod_tipo_deudor = MCL.bsmcl_scotipide,
						DEU.cod_estado = 1	--Activo
					FROM	dbo.GAR_DEUDOR DEU
						INNER JOIN	dbo.GAR_SICC_BSMCL MCL
						ON MCL.bsmcl_sco_ident = DEU.Identificacion_Sicc
					WHERE	MCL.bsmcl_estado = 'A'
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMCA MCA
									WHERE	MCA.prmca_estado = 'A'
										AND MCA.prmca_pfe_defin >= @viFechaActualEntera
										AND MCA.prmca_pco_ident = MCL.bsmcl_sco_ident)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Deuc

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar y activar los deudores asociados a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Deuc
		END
	END


	-------------------------------------------------------------------------------------------------------------------------
	-- OPERACIONES DE CREDITO Y CONTRATOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las operaciones como Canceladas
	IF(@piIndicadorProceso = 2)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Oper
			BEGIN TRY
	
				UPDATE	dbo.GAR_OPERACION 
				SET		cod_estado = 2

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Oper

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al desactivar a los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1


			END CATCH
			
		IF (@@TRANCOUNT > 0)
		BEGIN

			COMMIT TRANSACTION TRA_Act_Oper

			--Actualiza las operaciones activas
			BEGIN	TRANSACTION TRA_Act_Opera
				BEGIN TRY
			
					UPDATE	GO1
					SET		GO1.cod_estado = 1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMOC MOC
									WHERE	MOC.prmoc_pse_proces = 1 --Operaciones activas
										AND MOC.prmoc_estado = 'A'
										AND ((MOC.prmoc_psa_actual < 0)
											OR (MOC.prmoc_psa_actual > 0))	
										AND ((MOC.prmoc_pcoctamay < 815)
											OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
										AND MOC.prmoc_pnu_oper = GO1.num_operacion
										AND MOC.prmoc_pnu_contr = GO1.num_contrato
										AND MOC.prmoc_pco_ofici = GO1.cod_oficina
										AND MOC.prmoc_pco_moned = GO1.cod_moneda
										AND MOC.prmoc_pco_produ = GO1.cod_producto
										AND MOC.prmoc_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Opera

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Opera

			--Actualiza los contratos vigentes
			BEGIN	TRANSACTION TRA_Act_Contra
				BEGIN TRY
			
					UPDATE	GO1
					SET		GO1.cod_estado = 1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	GO1.num_operacion IS NULL
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMCA MCA
									WHERE	MCA.prmca_estado = 'A'
										AND MCA.prmca_pfe_defin >= @viFechaActualEntera
										AND MCA.prmca_pnu_contr = GO1.num_contrato
										AND MCA.prmca_pco_ofici = GO1.cod_oficina
										AND MCA.prmca_pco_moned = GO1.cod_moneda
										AND MCA.prmca_pco_produc = GO1.cod_producto
										AND MCA.prmca_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Contra

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar los contratos vigentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Contra

			-- Actualiza el número de oficina donde se contabilizó el contrato al que pertenece el giro
			BEGIN	TRANSACTION TRA_Act_Oficont
				BEGIN TRY
			
					UPDATE	GO1
					SET		GO1.cod_oficon = MCA.prmca_pco_ofici
					FROM	dbo.GAR_OPERACION GO1
						INNER JOIN dbo.GAR_SICC_PRMCA MCA
						ON GO1.cod_oficina = MCA.prmca_pco_ofici
						AND GO1.cod_moneda = MCA.prmca_pco_moned
						AND GO1.cod_producto = MCA.prmca_pco_produc
						AND GO1.num_contrato = MCA.prmca_pnu_contr
					WHERE	GO1.num_operacion IS NULL
						AND GO1.num_contrato > 0
				
				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Oficont

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la oficina contable de los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Oficont
			
			--Oficina contable de los giros
			BEGIN	TRANSACTION TRA_Act_Oficong
				BEGIN TRY
			
					UPDATE	GO1
					SET		GO1.cod_oficon = MOC.prmoc_pco_oficon
					FROM	dbo.GAR_OPERACION GO1
						INNER JOIN dbo.GAR_SICC_PRMOC MOC
						ON GO1.cod_oficina = MOC.prmoc_pco_ofici
						AND GO1.cod_moneda = MOC.prmoc_pco_moned
						AND GO1.cod_producto = MOC.prmoc_pco_produ
						AND GO1.num_contrato = MOC.prmoc_pnu_contr
						AND GO1.num_operacion = MOC.prmoc_pnu_oper
					WHERE	GO1.num_operacion IS NOT NULL
						AND GO1.num_contrato > 0

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Oficong

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la oficina contable de los giros de contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Oficong
			
			--Oficina contable de las operaciones
			BEGIN	TRANSACTION TRA_Act_Oficonop
				BEGIN TRY
			
					UPDATE	GO1
					SET		GO1.cod_oficon = MOC.prmoc_pco_oficon
					FROM	dbo.GAR_OPERACION GO1
						INNER JOIN dbo.GAR_SICC_PRMOC MOC
						ON GO1.cod_oficina = MOC.prmoc_pco_ofici
						AND GO1.cod_moneda = MOC.prmoc_pco_moned
						AND GO1.cod_producto = MOC.prmoc_pco_produ
						AND GO1.num_contrato = MOC.prmoc_pnu_contr
						AND GO1.num_operacion = MOC.prmoc_pnu_oper
					WHERE	GO1.num_contrato = 0
						AND GO1.num_operacion IS NOT NULL

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Oficonop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la oficina contable de las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
	
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Oficonop
		END
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS FIDUCIARIAS
	-------------------------------------------------------------------------------------------------------------------------	
	--Actualiza los nombres de los fiadores
	IF(@piIndicadorProceso = 3)
	BEGIN
	
		--Se actualiza el campo de la identificación del fiador
		BEGIN TRANSACTION TRA_Act_Id_Fiador
			BEGIN TRY
			
				UPDATE	GGF
				SET		GGF.Identificacion_Sicc =	CASE
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGF.cedula_fiador))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GGF.cedula_fiador))))
														ELSE -1
													END
				FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Fiador

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la identificación numérica de los fiadores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Fiador
	
	
		BEGIN TRANSACTION TRA_Act_Fiador
			BEGIN TRY
	
				UPDATE	GGF
				SET		nombre_fiador = MCL.bsmcl_sno_clien
				FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					INNER JOIN	dbo.GAR_SICC_BSMCL MCL
					ON MCL.bsmcl_sco_ident = GGF.Identificacion_Sicc

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Fiador

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar el nombre de los fiadores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Fiador
	END
	
		
	--Inicializa el estado de las garantias fiduciarias como Canceladas
	IF(@piIndicadorProceso = 4)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Gfo
			BEGIN TRY
	
				UPDATE	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
				SET		cod_estado = 2

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gfo

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al desactivar las relaciones de las garantías fiduciarias. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gfo
		
			--Actualiza el estado de las garantias fiduciarias de operaciones
			BEGIN	TRANSACTION TRA_Act_Gfop
				BEGIN TRY
			
					UPDATE	GFO
					SET		GFO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
						ON GGF.cod_garantia_fiduciaria = GFO.cod_garantia_fiduciaria
					WHERE	GO1.cod_estado = 1
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = 0	
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
										AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gfop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías fiduciarias y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gfop
	
		
			--Actualiza el estado de las garantias fiduciarias de contratos
			BEGIN	TRANSACTION TRA_Act_Gfoc
				BEGIN TRY
			
					UPDATE	GFO
					SET		cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GFO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
						ON GGF.cod_garantia_fiduciaria = GFO.cod_garantia_fiduciaria
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = 0	
										AND MGT.prmgt_pnu_oper = GO1.num_contrato
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
										AND MGT.prmgt_pnuidegar = GGF.Identificacion_Sicc)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gfoc

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías fiduciarias y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gfoc

		END
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las garantias reales como Canceladas
	IF(@piIndicadorProceso = 5)
	BEGIN
		
		--Se actualiza el campo de la identificación del bien de las hipotecas y cédulas
		BEGIN TRANSACTION TRA_Act_Id_Bienhc
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Sicc =	CASE
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.numero_finca))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GGR.numero_finca))))
														ELSE -1
													END
				FROM	dbo.GAR_GARANTIA_REAL GGR
				WHERE	GGR.cod_clase_garantia BETWEEN 10 AND 29

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Bienhc

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la identificación numérica de los bienes de hipotecas y cédulas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Bienhc
	
	
		--Se actualiza el campo de la identificación del bien de las hipotecas y cédulas
		BEGIN TRANSACTION TRA_Act_Id_Bienp
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Sicc =	CASE 
														WHEN (dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.num_placa_bien))) = 1) THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GGR.num_placa_bien)))) 
														ELSE -1 
													END
				FROM	dbo.GAR_GARANTIA_REAL GGR
				WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Bienp

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la identificación numérica de los bienes de prendas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Bienp
	
	
		BEGIN TRANSACTION TRA_Act_Gro
			BEGIN TRY
	
				UPDATE	dbo.GAR_GARANTIAS_REALES_X_OPERACION 
				SET		cod_estado = 2

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gro

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gro

			--Actualiza el estado de las garantias reales de hipoteca común de operaciones
			BEGIN	TRANSACTION TRA_Act_Grhcop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grhcop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grhcop
	

			--Actualiza el estado de las garantias reales de hipoteca común de contratos
			BEGIN	TRANSACTION TRA_Act_Grohcv
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_contrato
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grohcv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grohcv


			--Actualiza el estado de las garantias reales de cédula hipotecaria, con clase 18, de operaciones
			BEGIN	TRANSACTION TRA_Act_Grch18op
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GGR.cod_clase_garantia = 18
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grch18op

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria, con clase 18, y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grch18op
	

			--Actualiza el estado de las garantias reales de cédula hipotecaria, con clase 18, de contratos
			BEGIN	TRANSACTION TRA_Act_Groch18cv
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND GGR.cod_clase_garantia = 18
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnu_part = GGR.cod_partido
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_contrato
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Groch18cv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria, con clase 18, y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Groch18cv

			--Actualiza el estado de las garantias reales de cédula hipotecaria, con clase diferente a 18, de operaciones
			BEGIN	TRANSACTION TRA_Act_Grchop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GGR.cod_clase_garantia BETWEEN 20 AND 29
						AND GRO.cod_tenencia = 1
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcotengar = 1
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pco_grado = GGR.cod_grado
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grchop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria, con clase diferente a 18, y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grchop
	

			--Actualiza el estado de las garantias reales de cédula hipotecaria, con clase diferente a 18, de contratos
			BEGIN	TRANSACTION TRA_Act_Grochcv
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND GGR.cod_clase_garantia BETWEEN 20 AND 29
						AND GRO.cod_tenencia = 1
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcotengar = 1
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pco_grado = GGR.cod_grado
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grochcv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria, con clase diferente a 18, y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grochcv


			--Actualiza el estado de las garantias reales de prenda de operaciones
			BEGIN	TRANSACTION TRA_Act_Grpop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GGR.cod_clase_garantia BETWEEN 30 AND 69
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Grpop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Grpop
	

			--Actualiza el estado de las garantias reales de prenda de contratos
			BEGIN	TRANSACTION TRA_Act_Gropcv
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND GGR.cod_clase_garantia BETWEEN 30 AND 69
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
										AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
										AND MGT.prmgt_pnu_oper = GO1.num_contrato
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gropcv

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gropcv

		END
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS DE VALOR
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las garantias de valor como Canceladas
	IF(@piIndicadorProceso = 6)
	BEGIN
	
		--Se actualiza el campo de la identificación de la seguridad
		BEGIN TRANSACTION TRA_Act_Id_Segur
			BEGIN TRY
			
				UPDATE	GVR
				SET		GVR.Identificacion_Sicc =	CASE
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GVR.numero_seguridad))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GVR.numero_seguridad))))
														ELSE -1
													END
				FROM	dbo.GAR_GARANTIA_VALOR GVR

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Segur

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al actualizar la identificación numérica de las seguridades. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Segur
	
	
		BEGIN TRANSACTION TRA_Act_Gvo
			BEGIN TRY
	
				UPDATE	dbo.GAR_GARANTIAS_VALOR_X_OPERACION 
				SET		cod_estado = 2

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gvo

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al desactivar las relaciones de las garantías de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gvo

			--Actualiza el estado de las garantias de valor de operaciones
			BEGIN	TRANSACTION TRA_Act_Gvop
				BEGIN TRY

					UPDATE	GVO
					SET		GVO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
						ON GGV.cod_garantia_valor = GVO.cod_garantia_valor
					WHERE	GO1.cod_estado = 1
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
										AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
										AND MGT.prmgt_pcotengar IN (2,3,4,6) 
										AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
										AND MGT.prmgt_pnu_oper = GO1.num_operacion
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = GO1.cod_producto
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

				END TRY
				BEGIN CATCH
					IF (@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION TRA_Act_Gvop

					SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías de valor y las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
	
				END CATCH
				
			IF (@@TRANCOUNT > 0)
				COMMIT TRANSACTION TRA_Act_Gvop


			--Actualiza el estado de las garantias de valor de contratos
			BEGIN	TRANSACTION TRA_Act_Gvoc
				BEGIN TRY

					UPDATE	GVO
					SET		GVO.cod_estado = 1
					FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						INNER JOIN dbo.GAR_OPERACION GO1
						ON GO1.cod_operacion = GVO.cod_operacion
						INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
						ON GGV.cod_garantia_valor = GVO.cod_garantia_valor
					WHERE	GO1.cod_estado = 1
						AND GO1.num_operacion IS NULL
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_SICC_PRMGT MGT
									WHERE	MGT.prmgt_estado = 'A'
										AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
										AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
										AND MGT.prmgt_pcotengar IN (2,3,4,6) 
										AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
										AND MGT.prmgt_pnu_oper = GO1.num_contrato
										AND MGT.prmgt_pco_ofici = GO1.cod_oficina
										AND MGT.prmgt_pco_moned = GO1.cod_moneda
										AND MGT.prmgt_pco_produ = 10
										AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)

					END TRY
					BEGIN CATCH
						IF (@@TRANCOUNT > 0)
							ROLLBACK TRANSACTION TRA_Act_Gvoc

						SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al activar las relaciones entre las garantías de valor y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
						EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1
		
					END CATCH
					
				IF (@@TRANCOUNT > 0)
					COMMIT TRANSACTION TRA_Act_Gvoc
		END
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- Elimina las hipotecas duplicadas
	-------------------------------------------------------------------------------------------------------------------------	
	IF(@piIndicadorProceso = 7)
	BEGIN
		BEGIN TRY
			DECLARE
				@nCodOperacion BIGINT,
				@nContabilidad TINYINT,
				@nOficina SMALLINT,
				@nMoneda TINYINT,
				@nProducto TINYINT,
				@nOperacion DECIMAL(7,0),
				@nGarantia BIGINT,
				@nPartido TINYINT,
				@strFinca VARCHAR(25),
				@nClaseGarantia SMALLINT,
				@nGrado SMALLINT,
				@nTipoMitigador SMALLINT

			DECLARE curGarantias CURSOR FOR 

				SELECT	GO1.cod_operacion,
					GO1.cod_contabilidad, 
					GO1.cod_oficina, 
					GO1.cod_moneda, 
					GO1.cod_producto, 
					GO1.num_operacion,
					GGR.cod_garantia_real,
					GGR.cod_partido,
					GGR.numero_finca,
					GGR.cod_clase_garantia,
					GRO.cod_grado_gravamen,
					GRO.cod_tipo_mitigador
				FROM  dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON GRO.cod_operacion = GO1.cod_operacion
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GRO.cod_garantia_real = GGR.cod_garantia_real
				WHERE	GRO.cod_estado = 1
					AND GO1.cod_estado = 1 
					AND GGR.cod_tipo_garantia_real = 1
				ORDER BY	GO1.num_operacion,
					ISNULL(GRO.cod_tipo_mitigador, 99)

			OPEN curGarantias

			FETCH NEXT FROM curGarantias 
			INTO @nCodOperacion, @nContabilidad, @nOficina, @nMoneda, @nProducto, @nOperacion, @nGarantia, @nPartido, @strFinca, @nClaseGarantia, @nGrado, @nTipoMitigador

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF EXISTS (	SELECT	1 
							FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								INNER JOIN dbo.GAR_GARANTIA_REAL GGR
								ON GRO.cod_garantia_real = GGR.cod_garantia_real
							WHERE	GRO.cod_operacion = @nCodOperacion 
								AND GGR.cod_partido = @nPartido 								AND GGR.numero_finca = @strFinca 
								AND GGR.cod_clase_garantia = @nClaseGarantia
								AND GRO.cod_grado_gravamen = @nGrado
								AND GGR.cod_garantia_real = @nGarantia
								AND GRO.cod_estado = 1) 
				BEGIN
					IF EXISTS (	SELECT	1 
								FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									INNER JOIN dbo.GAR_GARANTIA_REAL GGR
									ON GRO.cod_garantia_real = GGR.cod_garantia_real
								WHERE	GRO.cod_operacion = @nCodOperacion 
									AND GGR.cod_partido = @nPartido 
									AND GGR.numero_finca = @strFinca 
									AND GGR.cod_clase_garantia = @nClaseGarantia
									AND GRO.cod_grado_gravamen = @nGrado
									AND GGR.cod_garantia_real <> @nGarantia
									AND GRO.cod_estado = 1) 
					BEGIN
						UPDATE	GRO
						SET		GRO.cod_estado = 1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
							INNER JOIN dbo.GAR_GARANTIA_REAL GGR
							ON GRO.cod_garantia_real = GGR.cod_garantia_real
						WHERE	GRO.cod_operacion = @nCodOperacion 
							AND GGR.cod_partido = @nPartido 
							AND GGR.numero_finca = @strFinca 
							AND GGR.cod_clase_garantia = @nClaseGarantia
							AND GRO.cod_grado_gravamen = @nGrado
							AND GGR.cod_garantia_real = @nGarantia
							AND GRO.cod_estado = 1
				
						UPDATE	GRO
						SET		GRO.cod_estado = 2
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
							INNER JOIN dbo.GAR_GARANTIA_REAL GGR
							ON GRO.cod_garantia_real = GGR.cod_garantia_real
						WHERE	GRO.cod_operacion = @nCodOperacion 
							AND GGR.cod_partido = @nPartido 
							AND GGR.numero_finca = @strFinca 
							AND GGR.cod_clase_garantia = @nClaseGarantia
							AND GRO.cod_grado_gravamen = @nGrado
							AND GGR.cod_garantia_real <> @nGarantia
							AND GRO.cod_estado = 1
					END
				END
					
				FETCH NEXT FROM curGarantias 
				INTO @nCodOperacion, @nContabilidad, @nOficina, @nMoneda, @nProducto, @nOperacion, @nGarantia, @nPartido, @strFinca, @nClaseGarantia, @nGrado, @nTipoMitigador
			END

			CLOSE curGarantias
			DEALLOCATE curGarantias

			-------------------------------------------------------------------------------------------------------------------------
			-- Corrige garantias reales (cedulas hipotecarias vs seguridades)
			-------------------------------------------------------------------------------------------------------------------------
			UPDATE	GRO
			SET		GRO.cod_estado = 2
			FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE GGR.numero_finca IN ('61771250', '5793545', '61435803')


		END TRY
		BEGIN CATCH

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al desactivar garantías reales duplicadas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH
	END
	
END


