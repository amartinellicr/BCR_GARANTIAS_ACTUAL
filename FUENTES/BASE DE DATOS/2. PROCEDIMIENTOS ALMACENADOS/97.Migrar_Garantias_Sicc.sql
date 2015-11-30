USE [GARANTIAS]
GO


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.Migrar_Garantias_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Migrar_Garantias_Sicc;
GO

CREATE PROCEDURE [dbo].[Migrar_Garantias_Sicc]
	@piIndicador_Proceso		TINYINT,
	@psCodigo_Proceso		VARCHAR(20)	
AS
BEGIN
	
/******************************************************************
	<Nombre>Migrar_Garantias_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de garantías de las nuevas operaciones de crédito y de los nuevos contratos del 
			     SICC a la base de datos GARANTIAS. 
	</Descripción>
	<Entradas>
			@piIndicador_Proceso	= Indica la parte del proceso que será ejecutada.
			@psCodigo_Proceso		= Código del proceso que ejecuta este procedimiento almacenado.
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
			<Fecha>24/06/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #11, #12, #17, #18, #19, #22 y #27. El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
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
	
	DECLARE	 @vdtFecha_Actual_Sin_Hora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
		@viFecha_Actual_Entera INT, --Corresponde al a fecha actual en formato numérico.
		@vsDescripcion_Error VARCHAR(1000), --Descripción del error capturado.
		@vsDescripcion_Bitacora_Errores VARCHAR(5000) --Descripción del error que será guardado en la bitácora de errores.
		
	DECLARE		@TMP_GARANTIAS_REALES TABLE (
												cod_operacion							BIGINT,
												cod_garantia_real						BIGINT,
												cod_tipo_documento_legal				SMALLINT,
												monto_mitigador							DECIMAL(18, 2),
												cod_grado_gravamen						SMALLINT,
												fecha_constitucion						DATETIME,
												fecha_vencimiento						DATETIME,
												cod_liquidez							SMALLINT,
												cod_tenencia							SMALLINT,
												cod_moneda								SMALLINT,
												fecha_prescripcion						DATETIME
											) --Almacenará la información de las garantías reales.
	
	--Se inicializan las variables
	SET	@vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	---------------------------------------------------------------------------------------------------------------------------
	---- DEUDORES DE OPERACIONES
	---------------------------------------------------------------------------------------------------------------------------
	IF(@piIndicador_Proceso = 1)
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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Deudor
		
		
		--Inserta los deudores nuevos de operaciones de crédito existentes en SICC
		BEGIN TRANSACTION TRA_Ins_Deud_Op
			BEGIN TRY
				INSERT	INTO dbo.GAR_DEUDOR 
				(
					cedula_deudor, 
					nombre_deudor, 
					cod_tipo_deudor, 
					cod_vinculado_entidad,
					Identificacion_Sicc
				)
				SELECT	DISTINCT
					MOC.prmoc_sco_ident, 
					MCL.bsmcl_sno_clien, 
					MCL.bsmcl_scotipide, 
					2 AS cod_vinculado_entidad,
					MOC.prmoc_sco_ident
				FROM	dbo.GAR_SICC_PRMOC MOC
					INNER JOIN	dbo.GAR_SICC_BSMCL MCL
					ON MCL.bsmcl_sco_ident = MOC.prmoc_sco_ident
				WHERE	MOC.prmoc_pse_proces = 1
					AND MOC.prmoc_estado = 'A'
					AND MCL.bsmcl_estado = 'A'
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_DEUDOR GDE
									WHERE	GDE.Identificacion_Sicc = MOC.prmoc_sco_ident)
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Deud_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los deudores asociados a las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Deud_Op
	END
	-----------------------------------------------------------------------------------------------------------------------
	--DEUDORES DE CONTRATOS
	-----------------------------------------------------------------------------------------------------------------------
	IF(@piIndicador_Proceso = 2)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Deud_Ca
			BEGIN TRY
	
				--Inserta los deudores nuevos de contratos existentes en SICC
				INSERT	INTO dbo.GAR_DEUDOR 
				(
					cedula_deudor, 
					nombre_deudor, 
					cod_tipo_deudor, 
					cod_vinculado_entidad,
					Identificacion_Sicc
				)
				SELECT DISTINCT
					MCA.prmca_pco_ident,
					MCL.bsmcl_sno_clien,
					MCL.bsmcl_scotipide,
					2 AS cod_vinculado_entidad,
					MCA.prmca_pco_ident
				FROM dbo.GAR_SICC_PRMCA MCA
					INNER JOIN dbo.GAR_SICC_BSMCL MCL
					ON MCL.bsmcl_sco_ident = MCA.prmca_pco_ident
				WHERE	MCA.prmca_estado = 'A'
					AND MCL.bsmcl_estado = 'A'
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_DEUDOR GDE
									WHERE	GDE.Identificacion_Sicc = MCA.prmca_pco_ident)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Deud_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los deudores asociados a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Deud_Ca
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- OPERACIONES DE CREDITO 
	-------------------------------------------------------------------------------------------------------------------------	
	IF(@piIndicador_Proceso = 3)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Op
			BEGIN TRY

				--Actualiza la información de las operaciones de crédito
				UPDATE	dbo.GAR_OPERACION
				SET		fecha_constitucion	=	CASE 
													WHEN ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1 
													THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) 
													ELSE CONVERT(DATETIME, '1900-01-01') 
												END,
					cedula_deudor			= MOC.prmoc_sco_ident,
					fecha_vencimiento		=	CASE 
													WHEN ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1 
													THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) 
													ELSE CONVERT(DATETIME, '1900-01-01') 
												END,
					monto_original			= MOC.prmoc_pmo_origi,
					saldo_actual			= MOC.prmoc_psa_actual
				FROM	dbo.GAR_SICC_PRMOC MOC
					INNER JOIN	dbo.GAR_OPERACION GO1 
					ON GO1.cod_oficina = MOC.prmoc_pco_ofici
					AND GO1.cod_moneda = MOC.prmoc_pco_moned
					AND GO1.cod_producto = MOC.prmoc_pco_produ
					AND GO1.num_operacion = MOC.prmoc_pnu_oper
					AND GO1.num_contrato = MOC.prmoc_pnu_contr
					AND GO1.cod_contabilidad = MOC.prmoc_pco_conta
				WHERE	MOC.prmoc_pse_proces = 1
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_DEUDOR GDE
								WHERE	GDE.Identificacion_Sicc = MOC.prmoc_sco_ident)
				
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar las operaciones/giros existentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Op
	END

	--Inserta las operaciones de crédito nuevas existentes en SICC
	IF(@piIndicador_Proceso = 4)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Op
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_OPERACION
				(
					cod_contabilidad,
					cod_oficina,
					cod_moneda,
					cod_producto,
					num_operacion,
					num_contrato,
					fecha_constitucion,
					cedula_deudor,
					fecha_vencimiento,
					monto_original,
					saldo_actual
				)
				SELECT 
					MOC.prmoc_pco_conta, 
					MOC.prmoc_pco_ofici, 
					MOC.prmoc_pco_moned, 
					MOC.prmoc_pco_produ, 
					MOC.prmoc_pnu_oper, 
					MOC.prmoc_pnu_contr,
					CASE WHEN ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_const)) 
						 ELSE CONVERT(DATETIME, '1900-01-01') 
					END AS prmoc_pfe_const,
					MOC.prmoc_sco_ident,
					CASE WHEN ISDATE(CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MOC.prmoc_pfe_defin)) 
						 ELSE CONVERT(DATETIME, '1900-01-01') 
					END AS prmoc_pfe_defin,
					MOC.prmoc_pmo_origi,
					MOC.prmoc_psa_actual
				FROM	dbo.GAR_SICC_PRMOC MOC
				WHERE	MOC.prmoc_pse_proces = 1
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_DEUDOR GDE
								WHERE	GDE.Identificacion_Sicc = MOC.prmoc_sco_ident)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_OPERACION GO1
									WHERE	GO1.cod_oficina	= MOC.prmoc_pco_ofici
										AND GO1.cod_moneda	= MOC.prmoc_pco_moned
										AND GO1.cod_producto = MOC.prmoc_pco_produ
										AND GO1.num_operacion = MOC.prmoc_pnu_oper
										AND GO1.num_contrato = MOC.prmoc_pnu_contr
										AND GO1.cod_contabilidad = MOC.prmoc_pco_conta)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las operaciones/giros nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Op
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Actualiza la información de los contratos
	IF(@piIndicador_Proceso = 5)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Ca
			BEGIN TRY
	
				UPDATE	dbo.GAR_OPERACION
				SET		fecha_constitucion	= CASE 
												WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) 
												ELSE CONVERT(DATETIME, '1900-01-01') 
											  END,
					cedula_deudor			= MCA.prmca_pco_ident,  
					fecha_vencimiento		= CASE 
												WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) 
												ELSE CONVERT(DATETIME, '1900-01-01') 
											  END
				FROM	dbo.GAR_SICC_PRMCA MCA
					INNER JOIN dbo.GAR_OPERACION GO1 
					ON GO1.cod_oficina = MCA.prmca_pco_ofici
					AND GO1.cod_moneda = MCA.prmca_pco_moned
					AND GO1.cod_producto = MCA.prmca_pco_produc
					AND GO1.num_contrato = MCA.prmca_pnu_contr
					AND GO1.cod_contabilidad = MCA.prmca_pco_conta
				WHERE	MCA.prmca_estado = 'A'
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_DEUDOR GDE
								WHERE	GDE.Identificacion_Sicc = MCA.prmca_pco_ident)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar los contratos existentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Ca
	END
	
	--Inserta los contratos nuevos existentes en SICC
	IF(@piIndicador_Proceso = 6)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Ca
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_OPERACION
				(
					cod_contabilidad,
					cod_oficina,
					cod_moneda,
					cod_producto,
					num_contrato,
					fecha_constitucion,
					cedula_deudor,
					fecha_vencimiento 
				)
				SELECT 
					MCA.prmca_pco_conta,
					MCA.prmca_pco_ofici,
					MCA.prmca_pco_moned,
					MCA.prmca_pco_produc,
					MCA.prmca_pnu_contr,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) 
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS prmca_pfe_const,
					MCA.prmca_pco_ident, 
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) 
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS prmca_pfe_defin
				FROM	dbo.GAR_SICC_PRMCA MCA
				WHERE	MCA.prmca_estado = 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_DEUDOR GDE
								WHERE	GDE.Identificacion_Sicc = MCA.prmca_pco_ident)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_OPERACION GO1
									WHERE	GO1.cod_oficina	= MCA.prmca_pco_ofici
										AND GO1.cod_moneda = MCA.prmca_pco_moned
										AND GO1.cod_producto = MCA.prmca_pco_produc
										AND GO1.num_contrato = MCA.prmca_pnu_contr
										AND GO1.cod_contabilidad = MCA.prmca_pco_conta
										AND GO1.num_operacion IS NULL)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los contratos nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ca
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS FIDUCIARIAS
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Fiduciarias de las Operaciones de Crédito
	IF(@piIndicador_Proceso = 7)
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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los fiadores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Fiador
			
			
		BEGIN TRANSACTION TRA_Ins_Ggfo
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_FIDUCIARIA 
				(
					cod_tipo_garantia, 
					cod_clase_garantia, 
					cedula_fiador, 
					nombre_fiador, 
					cod_tipo_fiador,
					Identificacion_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT	DISTINCT
					1 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					MGT.prmgt_pnuidegar AS cedula_fiador,
					MCL.bsmcl_sno_clien AS nombre_fiador,
					MCL.bsmcl_scotipide AS cod_tipo_fiador,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					GETDATE(),
					GETDATE()
				FROM dbo.GAR_SICC_PRMGT MGT
					INNER JOIN	dbo.GAR_SICC_BSMCL MCL
					ON MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND MCL.bsmcl_estado = 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.cod_oficina = MGT.prmgt_pco_ofici
									AND GO1.cod_moneda = MGT.prmgt_pco_moned
									AND GO1.cod_producto = MGT.prmgt_pco_produ
									AND GO1.num_operacion = MGT.prmgt_pnu_oper
									AND GO1.cod_contabilidad = MGT.prmgt_pco_conta
									AND GO1.num_contrato = 0)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_FIDUCIARIA	GGF
									WHERE	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggfo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los fiadores nuevos asociados a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggfo
	END

	--Garantias Fiduciarias de Contrato
	IF(@piIndicador_Proceso = 8)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Ggfc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_FIDUCIARIA 
				(
					cod_tipo_garantia, 
					cod_clase_garantia, 
					cedula_fiador, 
					nombre_fiador, 
					cod_tipo_fiador,
					Identificacion_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT	DISTINCT
					1 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					MGT.prmgt_pnuidegar AS cedula_fiador,
					MCL.bsmcl_sno_clien AS nombre_fiador,
					MCL.bsmcl_scotipide AS cod_tipo_fiador,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN	dbo.GAR_SICC_BSMCL MCL
					ON MCL.bsmcl_sco_ident	= MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado	= 'A'
					AND MGT.prmgt_pcoclagar	= 0
					AND MGT.prmgt_pco_produ = 10
					AND MCL.bsmcl_estado	= 'A'
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici = GO1.cod_oficina
									AND MGT.prmgt_pco_moned = GO1.cod_moneda
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_FIDUCIARIA	GGF
									WHERE	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggfc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggfc
	END


	-----------------------------------------------------------------------------
	--Inserta las Garantias Fiduciarias de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Fiduciarias X Operaciones
	IF(@piIndicador_Proceso = 9)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gfo
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
				(
					cod_operacion, 
					cod_garantia_fiduciaria, 
					cod_operacion_especial, 
					cod_tipo_acreedor, 
					cedula_acreedor, 
					porcentaje_responsabilidad, 
					monto_mitigador,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				) 
				SELECT	DISTINCT
					GO1.cod_operacion,
					GGF.cod_garantia_fiduciaria,
					0 AS cod_operacion_especial,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					-1 AS porcentaje_responsabilidad,
					GO1.saldo_actual AS monto_mitigador,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto
					AND MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	GO1.num_contrato = 0
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_BSMCL MCL
								WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
									AND MCL.bsmcl_estado = 'A')
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
									WHERE	GFO.cod_operacion = GO1.cod_operacion
										AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gfo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de los fiadores nuevos asociados a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gfo
	END

	--Garantias Fiduciarias X Contratos
	IF(@piIndicador_Proceso = 10)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gfc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
				(
					cod_operacion, 
					cod_garantia_fiduciaria, 
					cod_operacion_especial, 
					cod_tipo_acreedor, 
					cedula_acreedor, 
					porcentaje_responsabilidad, 
					monto_mitigador,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				) 
				SELECT	DISTINCT
					GO1.cod_operacion,
					GGF.cod_garantia_fiduciaria,
					0 AS cod_operacion_especial,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					-1 AS porcentaje_responsabilidad,
					GO1.saldo_actual AS monto_mitigador,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	GO1.num_operacion IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_BSMCL MCL
								WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
									AND MCL.bsmcl_estado = 'A')
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
									WHERE	GFO.cod_operacion = GO1.cod_operacion
										AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gfc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gfc
	END

	
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Reales de Operaciones
	IF(@piIndicador_Proceso = 11)
	BEGIN
	
		--Se actualiza el campo de la identificación del bien de las hipotecas y cédulas
		BEGIN TRANSACTION TRA_Act_Id_Bienhc
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Sicc =	CASE
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.numero_finca))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GGR.numero_finca))))
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.numero_finca))) = 0 THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(GGR.numero_finca)))
														ELSE -1
													END
				FROM	dbo.GAR_GARANTIA_REAL GGR
				WHERE	GGR.cod_clase_garantia BETWEEN 10 AND 29

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Bienhc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los bienes de hipotecas y cédulas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Bienhc
	
	
		--Se actualiza el campo de la identificación del bien de las hipotecas y cédulas
		BEGIN TRANSACTION TRA_Act_Id_Bienp
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Sicc =	CASE 
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.num_placa_bien))) = 1 THEN CONVERT(DECIMAL(12,0), (RTRIM(LTRIM(GGR.num_placa_bien)))) 
														WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.num_placa_bien))) = 0 THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(GGR.num_placa_bien)))
														ELSE -1 
													END
				FROM	dbo.GAR_GARANTIA_REAL GGR
				WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_Bienp

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los bienes de prendas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Bienp
	
	
		--Se actualiza la identificación alfanumérica de las hipotecas comunes 
		BEGIN TRANSACTION TRA_Act_Id_BienhcAlf
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf,
						GGR.numero_finca = CASE 
												WHEN GGR.cod_clase_garantia = 11 THEN MGT.prmgt_pnuide_alf
												ELSE GGR.numero_finca
										   END
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				WHERE	GGR.cod_clase_garantia IN (10, 11, 12, 13, 14, 15, 16, 17, 19)
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienhcAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de hipotecas comunes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_BienhcAlf
			
			
		--Se actualiza la identificación alfanumérica de las cédulas hipotecarias con clase 18 
		BEGIN TRANSACTION TRA_Act_Id_BienchAlf18
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
				WHERE	GGR.cod_clase_garantia = 18
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienchAlf18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de cédulas hipotecarias con clase igual a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_BienchAlf18
		
	
		--Se actualiza la identificación alfanumérica de las cédulas hipotecarias con clase distinta a 18 
		BEGIN TRANSACTION TRA_Act_Id_BienchAlf
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnu_part = GGR.cod_partido
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
					AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
				WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienchAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de cédulas hipotecarias con clase distinta a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_BienchAlf
	
	
		--Se actualiza la identificación alfanumérica de las prendas 
		BEGIN TRANSACTION TRA_Act_Id_BienpAlf
			BEGIN TRY
			
				UPDATE	GGR
				SET		GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf,
						GGR.num_placa_bien =	CASE 
													WHEN GGR.cod_clase_garantia = 38 THEN MGT.prmgt_pnuide_alf
													WHEN GGR.cod_clase_garantia = 43 THEN MGT.prmgt_pnuide_alf
													ELSE GGR.num_placa_bien
												END
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
					AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 69
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienpAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de prenda. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_BienpAlf
	
	
	
		--Se insertan los registros con clase distinta a 11
		BEGIN TRANSACTION TRA_Ins_Grho
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					1 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
				   	MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19) 
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 1
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase distinta a 11) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grho
			
			
		--Se insertan los registros con clase igual a 11
		BEGIN TRANSACTION TRA_Ins_Grho11
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					1 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					COALESCE(MGT.prmgt_pnuide_alf, '') AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,					
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 1
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, ''))
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grho11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase igual a 11) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grho11
	END

	--Garantias Reales de Contrato
	IF(@piIndicador_Proceso = 12)
	BEGIN
	
		--Se insertan los registros con clase distinta a 11
		BEGIN TRANSACTION TRA_Ins_Grhc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					1 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19) 
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 1
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase distinta a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc
			
			
		--Se insertan los registros con clase igual a 11
		BEGIN TRANSACTION TRA_Ins_Grhc11
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					1 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					COALESCE(MGT.prmgt_pnuide_alf, '') AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11 
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 1
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, ''))
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase igual a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11
	END


	-----------------------------------------------------------------------------
	--Inserta las Cédulas Hipotecarias Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	IF(@piIndicador_Proceso = 13)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Grcho
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					2 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					MGT.prmgt_pco_grado AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar = 1
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 2
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grcho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grcho
	END

	--Garantias Reales de Contrato
	IF(@piIndicador_Proceso = 14)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Grchc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					2 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					MGT.prmgt_pco_grado AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcotengar = 1
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 2
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchc
	END

	--Garantias Reales de Operaciones
	IF(@piIndicador_Proceso = 15)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gcho
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					2 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					MGT.prmgt_pco_grado AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 2
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gcho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas, de clase 18, asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gcho
	END

	--Garantias Reales de Contrato
	IF(@piIndicador_Proceso = 16)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gchc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					2 AS cod_tipo_garantia_real,
					MGT.prmgt_pnu_part AS cod_partido,
					MGT.prmgt_pnuidegar AS numero_finca,
					MGT.prmgt_pco_grado AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					NULL AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 2
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.cod_partido = MGT.prmgt_pnu_part
										AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gchc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas, de clase 18, asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gchc
	END

	
	-----------------------------------------------------------------------------
	--Inserta las Prendas Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	IF(@piIndicador_Proceso = 17)
	BEGIN
	
		--Se insertan los registros con clase distinta a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Ggrpo
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					3 AS cod_tipo_garantia_real,
					NULL AS cod_partido,
					NULL AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					MGT.prmgt_pnuidegar AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
						OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
						OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 3
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase distinta a 38 o 43) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpo
			
		
		--Se insertan los registros con clase igual a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Ggrpo3843
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					3 AS cod_tipo_garantia_real,
					NULL AS cod_partido,
					NULL AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					COALESCE(MGT.prmgt_pnuide_alf, '') AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.num_contrato = 0
									AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= GO1.cod_producto
									AND MGT.prmgt_pnu_oper = GO1.num_operacion
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 3
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, ''))
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpo3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase igual a 38 o 43) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpo3843
	END

	--Garantias Reales de Contrato
	IF(@piIndicador_Proceso = 18)
	BEGIN
	
		--Se insertan los registros con clase distinta a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Ggrpc
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					3 AS cod_tipo_garantia_real,
					NULL AS cod_partido,
					NULL AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					MGT.prmgt_pnuidegar AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
						OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
						OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 3
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase distinta de 38 o 43) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpc
			
		
		--Se insertan los registros con clase igual a 38 o 43
		BEGIN TRANSACTION TRA_Ins_Ggrpc3843
			BEGIN TRY
	
				INSERT INTO dbo.GAR_GARANTIA_REAL
				(
					cod_tipo_garantia,
					cod_clase_garantia,	
					cod_tipo_garantia_real,
					cod_partido,
					numero_finca,
					cod_grado,
					cedula_hipotecaria,
					cod_clase_bien,
					num_placa_bien,
					cod_tipo_bien,
					Identificacion_Sicc,
					Identificacion_Alfanumerica_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT DISTINCT
					2 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					3 AS cod_tipo_garantia_real,
					NULL AS cod_partido,
					NULL AS numero_finca,
					NULL AS cod_grado,
					NULL AS cedula_hipotecaria,
					NULL AS cod_clase_bien,
					COALESCE(MGT.prmgt_pnuide_alf, '') AS num_placa_bien,
					NULL AS cod_tipo_bien,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					MGT.prmgt_pnuide_alf AS Identificacion_Alfanumerica_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
									AND MGT.prmgt_pco_moned	= GO1.cod_moneda
									AND MGT.prmgt_pco_produ	= 10
									AND MGT.prmgt_pnu_oper = GO1.num_contrato
									AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
									AND GO1.num_operacion IS NULL)
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_REAL GGR
									WHERE	GGR.cod_tipo_garantia_real = 3
										AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
										AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
										AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, ''))
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpc3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase igual de 38 o 43) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpc3843
	END
	

	-----------------------------------------------------------------------------
	--Inserta las Garantias Reales de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Hipotecas comunes
	IF(@piIndicador_Proceso = 19)
	BEGIN
	
		--Se insertan los registros con clase distinta a 11
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 1
				WHEN MGT.prmgt_pco_grado = 2 THEN 2
				WHEN MGT.prmgt_pco_grado = 3 THEN 3
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE 
				WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19) 
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Hipotecas de contratos, con clase distinta a 11
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 1
				WHEN MGT.prmgt_pco_grado = 2 THEN 2
				WHEN MGT.prmgt_pco_grado = 3 THEN 3
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19) 
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
		
		--Se insertan las hipotecas nuevas asocidas 
		BEGIN TRANSACTION TRA_Ins_Groho
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas (con clase distinta a 11) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Groho
			
		--Se elimina el contenido de la estructura temporal
		DELETE FROM @TMP_GARANTIAS_REALES
			
		--Se insertan los registros con clase igual a 11
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 1
				WHEN MGT.prmgt_pco_grado = 2 THEN 2
				WHEN MGT.prmgt_pco_grado = 3 THEN 3
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE 
				WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 11
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Hipotecas de contratos, con clase igual a 11
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 1
				WHEN MGT.prmgt_pco_grado = 2 THEN 2
				WHEN MGT.prmgt_pco_grado = 3 THEN 3
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 11
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
		
		--Se insertan las hipotecas nuevas asocidas, con clase igual a 11 
		BEGIN TRANSACTION TRA_Ins_Groho11
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groho11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas (con clase igual a 11) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Groho11
	END

	--Cédulas Hipotecarias con clase 18
	IF(@piIndicador_Proceso = 20)
	BEGIN
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 5
				WHEN MGT.prmgt_pco_grado = 2 THEN 6
				WHEN MGT.prmgt_pco_grado = 3 THEN 7
				WHEN MGT.prmgt_pco_grado >= 4 THEN 8
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 18 
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Cédulas Hipotecarias de contratos
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 5
				WHEN MGT.prmgt_pco_grado = 2 THEN 6
				WHEN MGT.prmgt_pco_grado = 3 THEN 7
				WHEN MGT.prmgt_pco_grado >= 4 THEN 8
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 18 
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
	
		--Se insertan las relaciones de las cédulas hipotecarias con clase 18 nuevas
		BEGIN TRANSACTION TRA_Ins_Groch18
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groch18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Groch18
	END

	--Cédulas Hipotecarias con clase diferente a 18
	IF(@piIndicador_Proceso = 21)
	BEGIN
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 5
				WHEN MGT.prmgt_pco_grado = 2 THEN 6
				WHEN MGT.prmgt_pco_grado = 3 THEN 7
				WHEN MGT.prmgt_pco_grado >= 4 THEN 8
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
			AND MGT.prmgt_pcotengar = 1
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Cédulas Hipotecarias de contratos
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 5
				WHEN MGT.prmgt_pco_grado = 2 THEN 6
				WHEN MGT.prmgt_pco_grado = 3 THEN 7
				WHEN MGT.prmgt_pco_grado >= 4 THEN 8
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
			AND MGT.prmgt_pcotengar = 1
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
	

		--Se insertan las cédulas hipotecarias nuevas 
		BEGIN TRANSACTION TRA_Ins_Grocho
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grocho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las cédulas hipotecarias nuevas asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grocho
	END	
	
	--Prendas de operaciones crediticias
	IF(@piIndicador_Proceso = 22)
	BEGIN
	
		--Se insertan los registros con clase distinta a 38 o 43
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 9
				WHEN MGT.prmgt_pco_grado = 2 THEN 10
				WHEN MGT.prmgt_pco_grado = 3 THEN 11
				WHEN MGT.prmgt_pco_grado >= 4 THEN 12
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
				OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
				OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Prendas de contratos con clase distinta de 38 o 43
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 9
				WHEN MGT.prmgt_pco_grado = 2 THEN 10
				WHEN MGT.prmgt_pco_grado = 3 THEN 11
				WHEN MGT.prmgt_pco_grado >= 4 THEN 12
				ELSE NULL			
			END AS cod_tipo_documento_legal,
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
				OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
				OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
		

		--Se insertan las prendas nuevas, con clase distinta de 38 o 43
		BEGIN TRANSACTION TRA_Ins_Gropo
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gropo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las prendas nuevas (con clase distinta a 38 o 43) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gropo
			
			
		
		--Se insertan los registros con clase igual a 38 o 43
		INSERT	INTO @TMP_GARANTIAS_REALES (
			cod_operacion,
			cod_garantia_real,
			cod_tipo_documento_legal,
			monto_mitigador,
			cod_grado_gravamen,
			fecha_constitucion,
			fecha_vencimiento,
			cod_liquidez,
			cod_tenencia,
			cod_moneda,
			fecha_prescripcion)
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 9
				WHEN MGT.prmgt_pco_grado = 2 THEN 10
				WHEN MGT.prmgt_pco_grado = 3 THEN 11
				WHEN MGT.prmgt_pco_grado >= 4 THEN 12
				ELSE NULL			
			END AS cod_tipo_documento_legal, 
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 38)
				OR (MGT.prmgt_pcoclagar = 43))
			AND GO1.num_contrato = 0
			AND GO1.cod_operacion NOT IN (19627, 19801)
			
		UNION ALL
		
		--Prendas de contratos con clase igual de 38 o 43
		SELECT	DISTINCT
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			CASE 
				WHEN MGT.prmgt_pco_grado = 1 THEN 9
				WHEN MGT.prmgt_pco_grado = 2 THEN 10
				WHEN MGT.prmgt_pco_grado = 3 THEN 11
				WHEN MGT.prmgt_pco_grado >= 4 THEN 12
				ELSE NULL			
			END AS cod_tipo_documento_legal,
			GO1.saldo_actual AS monto_mitigador,
			CASE 
				WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
				WHEN MGT.prmgt_pco_grado >= 4 THEN 4
				ELSE NULL			
			END AS cod_grado_gravamen,
			GO1.fecha_constitucion AS fecha_constitucion,
			GO1.fecha_vencimiento,
			MGT.prmgt_pcoliqgar AS cod_liquidez,
			MGT.prmgt_pcotengar AS cod_tenencia,
			MGT.prmgt_pco_mongar AS cod_moneda,
			CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
				 ELSE CONVERT(DATETIME, '1900-01-01')
			END AS fecha_prescripcion
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN dbo.GAR_OPERACION GO1
			ON MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 38)
				OR (MGT.prmgt_pcoclagar = 43))
			AND GO1.num_operacion IS NULL
			AND GO1.cod_operacion NOT IN (19627, 19801)	
		

		--Se insertan las prendas nuevas, con clase distinta de 38 o 43
		BEGIN TRANSACTION TRA_Ins_Gropo3843
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_REALES_X_OPERACION
				(
					cod_operacion,
					cod_garantia_real,	
					cod_tipo_documento_legal,
					monto_mitigador,
					porcentaje_responsabilidad,
					cod_grado_gravamen,
					cod_operacion_especial,
					fecha_constitucion,
					fecha_vencimiento,
					cod_tipo_acreedor,
					cedula_acreedor,
					cod_liquidez,
					cod_tenencia,
					cod_moneda,
					fecha_prescripcion,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				)
				SELECT	DISTINCT
					TMP.cod_operacion,
					TMP.cod_garantia_real,
					TMP.cod_tipo_documento_legal, 
					TMP.monto_mitigador,
					-1 AS porcentaje_responsabilidad,
					TMP.cod_grado_gravamen,
					0 AS cod_operacion_especial,
					TMP.fecha_constitucion,
					TMP.fecha_vencimiento,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
					TMP.cod_tenencia,
					TMP.cod_moneda,
					TMP.fecha_prescripcion,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	@TMP_GARANTIAS_REALES TMP
				WHERE	NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
									WHERE	GRO.cod_operacion = TMP.cod_operacion
										AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gropo3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las prendas nuevas (con clase igual a 38 o 43) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gropo3843
	END	

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS DE VALOR
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Valor de Operaciones
	IF(@piIndicador_Proceso = 23)
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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de las seguridades. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_Segur
			
	
		BEGIN TRANSACTION TRA_Ins_Grvop
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIA_VALOR
				(
					cod_tipo_garantia,
					cod_clase_garantia,
					numero_seguridad,
					fecha_constitucion,
					fecha_vencimiento_instrumento,
					cod_clasificacion_instrumento,
					des_instrumento,
					des_serie_instrumento,
					cod_tipo_emisor,
					cedula_emisor,
					premio,
					cod_isin,
					valor_facial,
					cod_moneda_valor_facial,
					valor_mercado,
					cod_moneda_valor_mercado,
					cod_tenencia,
					fecha_prescripcion,
					Identificacion_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT	DISTINCT
					3 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					MGT.prmgt_pnuidegar AS numero_seguridad,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_constitucion)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_constitucion))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_constitucion,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_vencimiento)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_vencimiento))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_vencimiento_instrumento,
					NULL AS cod_clasificacion_instrumento,
					NULL AS des_instrumento,
					NULL AS des_serie_instrumento,
					NULL AS cod_tipo_emisor,
					NULL AS cedula_emisor,
					NULL AS premio,
					NULL AS cod_isin,
					NULL AS valor_facial,
					NULL AS cod_moneda_valor_facial,
					NULL AS valor_mercado,
					NULL AS cod_moneda_valor_mercado,
					MGT.prmgt_pcotengar AS cod_tenencia,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_prescripcion,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto
					AND MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar IN (2,3,4,6)
					AND GO1.num_contrato = 0
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_VALOR GGV
									WHERE	GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grvop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las garantías de valor nuevas asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grvop
	END	

	--Garantias Valor de Contratos
	IF(@piIndicador_Proceso = 24)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Grvoc
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIA_VALOR
				(
					cod_tipo_garantia,
					cod_clase_garantia,
					numero_seguridad,
					fecha_constitucion,
					fecha_vencimiento_instrumento,
					cod_clasificacion_instrumento,
					des_instrumento,
					des_serie_instrumento,
					cod_tipo_emisor,
					cedula_emisor,
					premio,
					cod_isin,
					valor_facial,
					cod_moneda_valor_facial,
					valor_mercado,
					cod_moneda_valor_mercado,
					cod_tenencia,
					fecha_prescripcion,
					Identificacion_Sicc,
					Fecha_Inserto,
					Fecha_Replica
				)
				SELECT	DISTINCT
					3 AS cod_tipo_garantia,
					MGT.prmgt_pcoclagar AS cod_clase_garantia,
					MGT.prmgt_pnuidegar AS numero_seguridad,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_constitucion)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_constitucion))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_constitucion,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), GO1.fecha_vencimiento)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GO1.fecha_vencimiento))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_vencimiento_instrumento,
					NULL AS cod_clasificacion_instrumento,
					NULL AS des_instrumento,
					NULL AS des_serie_instrumento,
					NULL AS cod_tipo_emisor,
					NULL AS cedula_emisor,
					NULL AS premio,
					NULL AS cod_isin,
					NULL AS valor_facial,
					NULL AS cod_moneda_valor_facial,
					NULL AS valor_mercado,
					NULL AS cod_moneda_valor_mercado,
					MGT.prmgt_pcotengar AS cod_tenencia,
					CASE 
						WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
						ELSE CONVERT(DATETIME, '1900-01-01')
					END AS fecha_prescripcion,
					MGT.prmgt_pnuidegar AS Identificacion_Sicc,
					GETDATE(),
					GETDATE()
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar IN (2,3,4,6)
					AND GO1.num_operacion IS NULL
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIA_VALOR GGV
									WHERE	GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grvoc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las garantías de valor nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grvoc
	END	


	-----------------------------------------------------------------------------
	--Inserta las Garantias de Valor de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Valor X Operaciones
	IF(@piIndicador_Proceso = 25)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gvoop
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
				(
					cod_operacion, 
					cod_garantia_valor, 
					monto_mitigador,
					cod_tipo_acreedor, 
					cedula_acreedor, 
					cod_operacion_especial, 
					porcentaje_responsabilidad,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion 
				) 
				SELECT	DISTINCT
					GO1.cod_operacion,
					GGV.cod_garantia_valor,
					GO1.saldo_actual AS monto_mitigador,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					0 AS cod_operacion_especial,
					-1 AS porcentaje_responsabilidad,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto
					AND MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar IN (2,3,4,6)
					AND GO1.num_contrato = 0
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
									WHERE	GVO.cod_operacion = GO1.cod_operacion
										AND GVO.cod_garantia_valor = GGV.cod_garantia_valor)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gvoop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre las operaciones y las garantías de valor nuevas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gvoop
	END	

	--Garantias Valor X Contratos
	IF(@piIndicador_Proceso = 26)
	BEGIN
		BEGIN TRANSACTION TRA_Ins_Gvooc
			BEGIN TRY
	
				INSERT	INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
				(
					cod_operacion, 
					cod_garantia_valor, 
					monto_mitigador,
					cod_tipo_acreedor, 
					cedula_acreedor, 
					cod_operacion_especial, 
					porcentaje_responsabilidad ,
					Fecha_Inserto,
					Fecha_Replica,
					Porcentaje_Aceptacion
				) 
				SELECT	DISTINCT
					GO1.cod_operacion,
					GGV.cod_garantia_valor,
					GO1.saldo_actual AS monto_mitigador,
					2 AS cod_tipo_acreedor,
					'4000000019' AS cedula_acreedor,
					0 AS cod_operacion_especial,
					-1 AS porcentaje_responsabilidad,
					GETDATE(),
					GETDATE(),
					100 AS Porcentaje_Aceptacion
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
					AND MGT.prmgt_pcotengar IN (2,3,4,6)
					AND GO1.num_operacion IS NULL
					AND NOT EXISTS (SELECT	1
									FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
									WHERE	GVO.cod_operacion = GO1.cod_operacion
										AND GVO.cod_garantia_valor = GGV.cod_garantia_valor)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gvooc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre los contratos y las garantías de valor nuevas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gvooc
	END	


	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS VENCIDOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Habilita los contratos vencidos que tienen giros activos
	IF(@piIndicador_Proceso = 27)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Cvga
			BEGIN TRY
		
				UPDATE	GO1
				SET		GO1.cod_estado = 1
				FROM	dbo.GAR_OPERACION GO1
				WHERE	GO1.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
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
					ROLLBACK TRANSACTION TRA_Act_Cvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Cvga

		
		--Habilita las garantías fiduciarias de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Gfcvga
			BEGIN TRY
		
				UPDATE	GFO
				SET		GFO.cod_estado = 1,
						GFO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GFO.cod_operacion
				WHERE	GFO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
												WHERE	GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)
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
					ROLLBACK TRANSACTION TRA_Act_Gfcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías fiduciarias asociadas a los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gfcvga

		
		--Habilita las garantías reales de hipoteca común (con clase distinta a 11) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grhccvga
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
													AND GGR.cod_partido = MGT.prmgt_pnu_part)
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
					ROLLBACK TRANSACTION TRA_Act_Grhccvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común (con clase distinta a 11) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grhccvga


		--Habilita las garantías reales de hipoteca común (con clase igual a 11) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grhccvga11
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pcoclagar = 11
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
													AND GGR.cod_partido = MGT.prmgt_pnu_part)
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
					ROLLBACK TRANSACTION TRA_Act_Grhccvga11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común (con clase igual a 11) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grhccvga11

	
		--Habilita las garantías reales de cédula hipotecaria (con clase distinto a 18) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grchcvga
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado))
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
					ROLLBACK TRANSACTION TRA_Act_Grchcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria (con clase distinto a 18) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grchcvga

	
		--Habilita las garantías reales de cédula hipotecaria (con clase igual a 18) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grchcvga18
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pcoclagar = 18
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
													AND GGR.cod_partido = MGT.prmgt_pnu_part
													AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado))
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
					ROLLBACK TRANSACTION TRA_Act_Grchcvga18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria (con clase igual a 18) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grchcvga18




		--Habilita las garantías reales de prenda (con clase distinta a 38 o 43) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grpcvga
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
										OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
										OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
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
					ROLLBACK TRANSACTION TRA_Act_Grpcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda (con clase distinta a 38 o 43) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grpcvga

	
		--Habilita las garantías reales de prenda (con clase igual a 38 o 43) de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Grpcvga3843
			BEGIN TRY
		
				UPDATE	GRO
				SET		GRO.cod_estado = 1,
						GRO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GRO.cod_operacion
				WHERE	GRO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND ((MGT.prmgt_pcoclagar = 38)
										OR (MGT.prmgt_pcoclagar = 43))
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_REAL GGR
												WHERE	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
													AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, ''))
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
					ROLLBACK TRANSACTION TRA_Act_Grpcvga3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda (con clase igual a 38 o 43) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Grpcvga3843

	
		--Habilita las garantías de valor de los contratos que tienen giros activos
		BEGIN TRANSACTION TRA_Act_Gvcvga
			BEGIN TRY
		
				UPDATE	GVO
				SET		GVO.cod_estado = 1,
						GVO.Fecha_Replica = GETDATE()
				FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
					INNER JOIN dbo.GAR_OPERACION GO1
					ON GO1.cod_operacion = GVO.cod_operacion
				WHERE	GVO.cod_estado = 2
					AND GO1.num_operacion IS NULL
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMGT MGT
									INNER JOIN dbo.GAR_SICC_PRMCA MCA
									ON MCA.prmca_pnu_contr = MGT.prmgt_pnu_oper 
									AND MCA.prmca_pco_ofici = MGT.prmgt_pco_ofici
									AND MCA.prmca_pco_moned = MGT.prmgt_pco_moned
									AND MCA.prmca_pco_conta = MGT.prmgt_pco_conta
									INNER JOIN dbo.GAR_SICC_BSMPC MPC
									ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
									INNER JOIN dbo.GAR_SICC_BSMCL MCL
									ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident
								WHERE	MGT.prmgt_estado = 'A' 
									AND MGT.prmgt_pco_produ = 10
									AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
									AND MGT.prmgt_pcotengar IN (2,3,4,6) 
									AND MCA.prmca_estado = 'A'
									AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
									AND MCA.prmca_pnu_contr = GO1.num_contrato
									AND MCA.prmca_pco_ofici = GO1.cod_oficina
									AND MCA.prmca_pco_moned = GO1.cod_moneda
									AND MCA.prmca_pco_produc = GO1.cod_producto
									AND MCA.prmca_pco_conta = GO1.cod_contabilidad
									AND MPC.bsmpc_estado = 'A'
									AND MCL.bsmcl_estado = 'A'
									AND EXISTS (SELECT	1
												FROM	dbo.GAR_GARANTIA_VALOR GGV
												WHERE	GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
													AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)
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
					ROLLBACK TRANSACTION TRA_Act_Gvcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías de valor y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gvcvga
		
				
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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía fiduciaria. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía fiduciaria. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros del avalúo de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información básica de la garantía de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la relación de la garantía de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigo_Proceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gvo

	END	
END