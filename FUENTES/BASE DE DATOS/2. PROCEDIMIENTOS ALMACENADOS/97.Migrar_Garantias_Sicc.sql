USE [GARANTIAS]
GO


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('dbo.Migrar_Garantias_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Migrar_Garantias_Sicc;
GO

CREATE PROCEDURE [dbo].[Migrar_Garantias_Sicc]
	@piIndicadorProceso	TINYINT,
	@psCodigoProceso	VARCHAR(20)	
AS
BEGIN
	
/******************************************************************
	<Nombre>Migrar_Garantias_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de garantías de las nuevas operaciones de crédito y de los nuevos contratos del 
			     SICC a la base de datos GARANTIAS. 
	</Descripción>
	<Entradas>
			@piIndicadorProceso	= Indica la parte del proceso que será ejecutada.
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_2016012910535596 Cambio en Estado de Pólizas</Requerimiento>
			<Fecha>02/02/2016</Fecha>
			<Descripción>
				Se realiza un ajuste al momento de migrar las garantías reales del tipo cédula hipotecaria, esto para que el proceso de migración de pólizas pueda 
				encontrar las pólizas patrimoniales correctamente. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
			<Fecha>09/03/2016</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo de cuenta contable la actualización del campo del saldo actual.
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
	
	DECLARE	@vdtFecha_Actual_Sin_Hora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
			@viFecha_Actual_Entera INT, --Corresponde al a fecha actual en formato numérico.
			@vdtFecha_Actual DATETIME, --Fecha actual del sistema
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
	SET @vdtFecha_Actual = GETDATE()
	SET	@vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(@vdtFecha_Actual AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(@vdtFecha_Actual AS VARCHAR(11)),101)), 112))
	
	---------------------------------------------------------------------------------------------------------------------------
	---- DEUDORES DE OPERACIONES
	---------------------------------------------------------------------------------------------------------------------------
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

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					LEFT OUTER JOIN dbo.GAR_DEUDOR GDE
					ON	GDE.Identificacion_Sicc = MOC.prmoc_sco_ident
				WHERE	MOC.prmoc_pse_proces = 1
					AND MOC.prmoc_estado = 'A'
					AND MCL.bsmcl_estado = 'A'
					AND GDE.cedula_deudor IS NULL
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Deud_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los deudores asociados a las operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Deud_Op
	END
	-----------------------------------------------------------------------------------------------------------------------
	--DEUDORES DE CONTRATOS
	-----------------------------------------------------------------------------------------------------------------------
	IF(@piIndicadorProceso = 2)
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
					LEFT OUTER JOIN dbo.GAR_DEUDOR GDE
					ON	GDE.Identificacion_Sicc = MCA.prmca_pco_ident
				WHERE	MCA.prmca_estado = 'A'
					AND MCL.bsmcl_estado = 'A'
					AND GDE.cedula_deudor IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Deud_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los deudores asociados a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Deud_Ca
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- OPERACIONES DE CREDITO 
	-------------------------------------------------------------------------------------------------------------------------	
	IF(@piIndicadorProceso = 3)
	BEGIN
		BEGIN TRANSACTION TRA_Act_Op
			BEGIN TRY

				--Actualiza la información de las operaciones de crédito
				UPDATE	dbo.GAR_OPERACION
				SET		fecha_constitucion		=	CASE 
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
						saldo_actual			= MOC.prmoc_psa_actual,
						Cuenta_Contable			= MOC.prmoc_pcoctamay
				FROM	dbo.GAR_SICC_PRMOC MOC
					INNER JOIN	dbo.GAR_OPERACION GO1 
					ON GO1.cod_oficina = MOC.prmoc_pco_ofici
					AND GO1.cod_moneda = MOC.prmoc_pco_moned
					AND GO1.cod_producto = MOC.prmoc_pco_produ
					AND GO1.num_operacion = MOC.prmoc_pnu_oper
					AND GO1.num_contrato = MOC.prmoc_pnu_contr
					AND GO1.cod_contabilidad = MOC.prmoc_pco_conta
					INNER JOIN dbo.GAR_DEUDOR GDE
					ON GDE.Identificacion_Sicc = MOC.prmoc_sco_ident
				WHERE	MOC.prmoc_pse_proces = 1
				
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar las operaciones/giros existentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Op
	END

	--Inserta las operaciones de crédito nuevas existentes en SICC
	IF(@piIndicadorProceso = 4)
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
					saldo_actual,
					Cuenta_Contable
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
					MOC.prmoc_psa_actual,
					MOC.prmoc_pcoctamay
				FROM	dbo.GAR_SICC_PRMOC MOC
					INNER JOIN dbo.GAR_DEUDOR GDE
					ON GDE.Identificacion_Sicc = MOC.prmoc_sco_ident
					LEFT OUTER JOIN dbo.GAR_OPERACION GO1
					ON	GO1.cod_oficina	= MOC.prmoc_pco_ofici
					AND GO1.cod_moneda	= MOC.prmoc_pco_moned
					AND GO1.cod_producto = MOC.prmoc_pco_produ
					AND GO1.num_operacion = MOC.prmoc_pnu_oper
					AND GO1.num_contrato = MOC.prmoc_pnu_contr
					AND GO1.cod_contabilidad = MOC.prmoc_pco_conta
				WHERE	MOC.prmoc_pse_proces = 1
					AND GO1.cod_operacion IS NULL
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las operaciones/giros nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Op
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Actualiza la información de los contratos
	IF(@piIndicadorProceso = 5)
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
											  END,
					saldo_actual			= (MCA.prmca_pmo_maxim - MCA.prmca_pmo_utiliz),
					Cuenta_Contable			= -1
				FROM	dbo.GAR_SICC_PRMCA MCA
					INNER JOIN dbo.GAR_OPERACION GO1 
					ON GO1.cod_oficina = MCA.prmca_pco_ofici
					AND GO1.cod_moneda = MCA.prmca_pco_moned
					AND GO1.cod_producto = MCA.prmca_pco_produc
					AND GO1.num_contrato = MCA.prmca_pnu_contr
					AND GO1.cod_contabilidad = MCA.prmca_pco_conta
					INNER JOIN dbo.GAR_DEUDOR GDE
					ON	GDE.Identificacion_Sicc = MCA.prmca_pco_ident
				WHERE	MCA.prmca_estado = 'A'
					AND GO1.num_operacion IS NULL
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar los contratos existentes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Ca
	END
	
	--Inserta los contratos nuevos existentes en SICC
	IF(@piIndicadorProceso = 6)
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
					fecha_vencimiento,
					saldo_actual,
					Cuenta_Contable
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
					END AS prmca_pfe_defin,
					(MCA.prmca_pmo_maxim - MCA.prmca_pmo_utiliz) AS saldo_actual,
					-1 AS Cuenta_Contable
				FROM	dbo.GAR_SICC_PRMCA MCA
					INNER JOIN dbo.GAR_DEUDOR GDE
					ON	GDE.Identificacion_Sicc = MCA.prmca_pco_ident
					LEFT OUTER JOIN dbo.GAR_OPERACION GO1
					ON	GO1.cod_oficina	= MCA.prmca_pco_ofici
					AND GO1.cod_moneda = MCA.prmca_pco_moned
					AND GO1.cod_producto = MCA.prmca_pco_produc
					AND GO1.num_contrato = MCA.prmca_pnu_contr
					AND GO1.cod_contabilidad = MCA.prmca_pco_conta
					AND GO1.num_operacion IS NULL
				WHERE	MCA.prmca_estado = 'A'
					AND GO1.cod_operacion IS NULL
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ca

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los contratos nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ca
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS FIDUCIARIAS
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Fiduciarias de las Operaciones de Crédito
	IF(@piIndicadorProceso = 7)
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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad					
					LEFT OUTER JOIN dbo.GAR_GARANTIA_FIDUCIARIA	GGF
					ON	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND MCL.bsmcl_estado = 'A'
					AND GO1.num_contrato = 0
					AND GGF.cod_garantia_fiduciaria IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggfo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los fiadores nuevos asociados a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggfo
	END

	--Garantias Fiduciarias de Contrato
	IF(@piIndicadorProceso = 8)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON	MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad						
					LEFT OUTER JOIN dbo.GAR_GARANTIA_FIDUCIARIA	GGF
					ON	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND MCL.bsmcl_estado = 'A'
					AND GO1.num_operacion IS NULL
					AND GGF.cod_garantia_fiduciaria IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggfc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggfc
	END


	-----------------------------------------------------------------------------
	--Inserta las Garantias Fiduciarias de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Fiduciarias X Operaciones
	IF(@piIndicadorProceso = 9)
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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto					
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
					INNER JOIN dbo.GAR_SICC_BSMCL MCL
					ON	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
					ON	GFO.cod_operacion = GO1.cod_operacion
					AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
				WHERE	GO1.num_contrato = 0
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND MCL.bsmcl_estado = 'A'
					AND GFO.cod_operacion IS NULL
					AND GFO.cod_garantia_fiduciaria IS NULL
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gfo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de los fiadores nuevos asociados a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gfo
	END

	--Garantias Fiduciarias X Contratos
	IF(@piIndicadorProceso = 10)
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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
					INNER JOIN dbo.GAR_SICC_BSMCL MCL
					ON	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
					ON	GFO.cod_operacion = GO1.cod_operacion
					AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
				WHERE	GO1.num_operacion IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					AND MCL.bsmcl_estado = 'A'
					AND GFO.cod_operacion IS NULL
					AND GFO.cod_garantia_fiduciaria IS NULL
		
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gfc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gfc
	END

	
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Reales de Operaciones
	IF(@piIndicadorProceso = 11)
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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
				WHERE	((GGR.cod_clase_garantia = 19) OR ((GGR.cod_clase_garantia >= 10) AND (GGR.cod_clase_garantia <= 17)))	
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 10) AND (MGT.prmgt_pcoclagar <= 17)))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienhcAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de hipotecas comunes. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
				WHERE	GGR.cod_clase_garantia >= 20 
					AND GGR.cod_clase_garantia <= 29
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND MGT.prmgt_pcotengar = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienchAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de cédulas hipotecarias con clase distinta a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
				WHERE	GGR.cod_clase_garantia >= 30 
					AND GGR.cod_clase_garantia <= 69
					AND GGR.Identificacion_Alfanumerica_Sicc IS NULL
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 30 
					AND MGT.prmgt_pcoclagar <= 69

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Id_BienpAlf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación alfanumérica de los bienes de prenda. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 1
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase distinta a 11) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GGR.cod_tipo_garantia_real = 1
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grho11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase igual a 11) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grho11
	END

	--Garantias Reales de Contrato
	IF(@piIndicadorProceso = 12)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 1
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase distinta a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GGR.cod_tipo_garantia_real = 1
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11 
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grhc11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase igual a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grhc11
	END


	-----------------------------------------------------------------------------
	--Inserta las Cédulas Hipotecarias Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	IF(@piIndicadorProceso = 13)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part --RQ:2016012910535596
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 2
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND MGT.prmgt_pcotengar = 1
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grcho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grcho
	END

	--Garantias Reales de Contrato
	IF(@piIndicadorProceso = 14)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part --RQ:2016012910535596
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 2
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND MGT.prmgt_pcotengar = 1
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grchc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grchc
	END

	--Garantias Reales de Operaciones
	IF(@piIndicadorProceso = 15)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part --RQ:2016012910535596
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 2
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gcho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas, de clase 18, asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gcho
	END

	--Garantias Reales de Contrato
	IF(@piIndicadorProceso = 16)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.cod_partido = MGT.prmgt_pnu_part --RQ:2016012910535596
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 2
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gchc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias nuevas, de clase 18, asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gchc
	END

	
	-----------------------------------------------------------------------------
	--Inserta las Prendas Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	IF(@piIndicadorProceso = 17)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 3
				WHERE	MGT.prmgt_estado = 'A'
					AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
					OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
					OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase distinta a 38 o 43) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= GO1.cod_producto
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GGR.cod_tipo_garantia_real = 3
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND GO1.num_contrato = 0
					AND GGR.cod_garantia_real IS NULL
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpo3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase igual a 38 o 43) asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpo3843
	END

	--Garantias Reales de Contrato
	IF(@piIndicadorProceso = 18)
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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_tipo_garantia_real = 3
				WHERE	MGT.prmgt_estado = 'A'
					AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
					OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
					OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase distinta de 38 o 43) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_ofici	= GO1.cod_oficina
					AND MGT.prmgt_pco_moned	= GO1.cod_moneda
					AND MGT.prmgt_pco_produ	= 10
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GGR.cod_tipo_garantia_real = 3
				WHERE	MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))
					AND GO1.num_operacion IS NULL
					AND GGR.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Ggrpc3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase igual de 38 o 43) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Ggrpc3843
	END
	

	-----------------------------------------------------------------------------
	--Inserta las Garantias Reales de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Hipotecas comunes
	IF(@piIndicadorProceso = 19)
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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto		
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
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
			ON MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10			
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas (con clase distinta a 11) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 11
			AND GO1.num_contrato = 0
			
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
			ON MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 11
			AND GO1.num_operacion IS NULL
		

		DELETE	FROM @TMP_GARANTIAS_REALES
		WHERE	((cod_operacion = 19627) OR (cod_operacion = 19801))


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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groho11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas (con clase igual a 11) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Groho11
	END

	--Cédulas Hipotecarias con clase 18
	IF(@piIndicadorProceso = 20)
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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 18 
			AND GO1.num_contrato = 0
			
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
			ON MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_partido = MGT.prmgt_pnu_part
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar = 18 
			AND GO1.num_operacion IS NULL
	
		DELETE	FROM @TMP_GARANTIAS_REALES
		WHERE	((cod_operacion = 19627) OR (cod_operacion = 19801))

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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Groch18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las hipotecas comunes nuevas asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Groch18
	END

	--Cédulas Hipotecarias con clase diferente a 18
	IF(@piIndicadorProceso = 21)
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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar >= 20 
			AND MGT.prmgt_pcoclagar <= 29
			AND MGT.prmgt_pcotengar = 1
			AND GO1.num_contrato = 0
			
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
			ON  MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcoclagar >= 20 
			AND MGT.prmgt_pcoclagar <= 29
			AND MGT.prmgt_pcotengar = 1
			AND GO1.num_operacion IS NULL
	
		DELETE	FROM @TMP_GARANTIAS_REALES
		WHERE	((cod_operacion = 19627) OR (cod_operacion = 19801))


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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grocho

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las cédulas hipotecarias nuevas asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grocho
	END	
	
	--Prendas de operaciones crediticias
	IF(@piIndicadorProceso = 22)
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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
				OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
				OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
			AND GO1.num_contrato = 0
			
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
			ON MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		WHERE	MGT.prmgt_estado = 'A'
			AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
				OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
				OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
			AND GO1.num_operacion IS NULL

		
		DELETE	FROM @TMP_GARANTIAS_REALES
		WHERE	((cod_operacion = 19627) OR (cod_operacion = 19801))


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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gropo

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las prendas nuevas (con clase distinta a 38 o 43) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
			ON MGT.prmgt_pnu_oper = GO1.num_operacion
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = GO1.cod_producto
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 38)
				OR (MGT.prmgt_pcoclagar = 43))
			AND GO1.num_contrato = 0
			
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
			ON MGT.prmgt_pnu_oper = GO1.num_contrato
			AND MGT.prmgt_pco_ofici = GO1.cod_oficina
			AND MGT.prmgt_pco_moned = GO1.cod_moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
			AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
			AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
		WHERE	MGT.prmgt_estado = 'A'
			AND ((MGT.prmgt_pcoclagar = 38)
				OR (MGT.prmgt_pcoclagar = 43))
			AND GO1.num_operacion IS NULL
		
		DELETE	FROM @TMP_GARANTIAS_REALES
		WHERE	((cod_operacion = 19627) OR (cod_operacion = 19801))


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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	@TMP_GARANTIAS_REALES TMP
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON	GRO.cod_operacion = TMP.cod_operacion
					AND GRO.cod_garantia_real = TMP.cod_garantia_real
				WHERE	GRO.cod_operacion IS NULL
					AND GRO.cod_garantia_real IS NULL
	
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gropo3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones de las prendas nuevas (con clase igual a 38 o 43) asociadas a operaciones y contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gropo3843
	END	

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS DE VALOR
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Valor de Operaciones
	IF(@piIndicadorProceso = 23)
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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					LEFT OUTER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					AND GO1.num_contrato = 0
					AND GGV.cod_garantia_valor IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grvop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las garantías de valor nuevas asociadas a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grvop
	END	

	--Garantias Valor de Contratos
	IF(@piIndicadorProceso = 24)
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
					LEFT OUTER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					AND GO1.num_operacion IS NULL
					AND GGV.cod_garantia_valor IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Grvoc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las garantías de valor nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Grvoc
	END	


	-----------------------------------------------------------------------------
	--Inserta las Garantias de Valor de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Valor X Operaciones
	IF(@piIndicadorProceso = 25)
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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = GO1.cod_producto
					AND MGT.prmgt_pnu_oper = GO1.num_operacion
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
					ON	GVO.cod_operacion = GO1.cod_operacion
					AND GVO.cod_garantia_valor = GGV.cod_garantia_valor
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					AND GO1.num_contrato = 0
					AND GVO.cod_operacion IS NULL
					AND GVO.cod_garantia_valor IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gvoop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre las operaciones y las garantías de valor nuevas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gvoop
	END	

	--Garantias Valor X Contratos
	IF(@piIndicadorProceso = 26)
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
					100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
				FROM	dbo.GAR_SICC_PRMGT MGT
					INNER JOIN dbo.GAR_OPERACION GO1
					ON MGT.prmgt_pco_ofici = GO1.cod_oficina
					AND MGT.prmgt_pco_moned = GO1.cod_moneda
					AND MGT.prmgt_pco_produ = 10
					AND MGT.prmgt_pnu_oper = GO1.num_contrato
					AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
					LEFT OUTER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
					ON	GVO.cod_operacion = GO1.cod_operacion
					AND GVO.cod_garantia_valor = GGV.cod_garantia_valor
				WHERE	MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
					AND GO1.num_operacion IS NULL
					AND GVO.cod_operacion IS NULL
					AND GVO.cod_garantia_valor IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Gvooc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre los contratos y las garantías de valor nuevas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Gvooc
	END	


	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS VENCIDOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Habilita los contratos vencidos que tienen giros activos
	IF(@piIndicadorProceso = 27)
	BEGIN

		/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
		CREATE TABLE #TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion		BIGINT, 
												  cod_contabilidad	TINYINT,
												  cod_oficina		SMALLINT,
												  cod_moneda		TINYINT,
												  cod_producto		TINYINT,
												  num_contrato		DECIMAL(7,0))
		 
		CREATE INDEX TEMP_CONTRATOS_VENCIDOS_GA_IX_01 ON #TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion)
				
		/*Esta tabla almacenará los giros activos según el SICC*/
		CREATE TABLE #TEMP_GIROS_ACTIVOS (	prmoc_pco_oficon SMALLINT,
											prmoc_pcomonint SMALLINT,
											prmoc_pnu_contr INT)
		 
		CREATE INDEX TEMP_GIROS_ACTIVOS_IX_01 ON #TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)


		/*Esta tabla almacenará la fecha de réplica más reciente para cada garantía fiduciaria*/
		CREATE TABLE #TEMP_GARANTIAS_FIDUCIARIAS (Consecutivo_Garantia		BIGINT, 
												  Fecha_Replica				DATETIME)
		 
		CREATE INDEX TEMP_GARANTIAS_FIDUCIARIAS_IX_01 ON #TEMP_GARANTIAS_FIDUCIARIAS (Consecutivo_Garantia)


		/*Esta tabla almacenará la fecha de réplica más reciente para cada garantía real*/
		CREATE TABLE #TEMP_GARANTIAS_REALES (Consecutivo_Garantia	BIGINT, 
											 Fecha_Replica			DATETIME)
		 
		CREATE INDEX TEMP_GARANTIAS_REALES_IX_01 ON #TEMP_GARANTIAS_REALES (Consecutivo_Garantia)


		/*Esta tabla almacenará la fecha de réplica más reciente para cada garantía valor*/
		CREATE TABLE #TEMP_GARANTIAS_VALOR (Consecutivo_Garantia	BIGINT, 
											Fecha_Replica			DATETIME)
		 
		CREATE INDEX TEMP_GARANTIAS_VALOR_IX_01 ON #TEMP_GARANTIAS_VALOR (Consecutivo_Garantia)


		--Se carga la tabla temporal de giros activos
		INSERT	#TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)
		SELECT	MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_SICC_PRMOC MOC 
			ON	MOC.prmoc_pnu_oper = GO1.num_operacion
			AND MOC.prmoc_pco_ofici = GO1.cod_oficina
			AND MOC.prmoc_pco_moned = GO1.cod_moneda
			AND MOC.prmoc_pco_produ = GO1.cod_producto
			AND MOC.prmoc_pco_conta	= GO1.cod_contabilidad
			AND MOC.prmoc_pnu_contr = GO1.num_contrato
		WHERE	MOC.prmoc_pse_proces = 1 
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
				OR (MOC.prmoc_pcoctamay > 815))
			AND COALESCE(GO1.num_operacion, 0) > 0 
			AND GO1.num_contrato > 0
		GROUP BY MOC.prmoc_pco_oficon, 
				MOC.prmoc_pcomonint, 
				MOC.prmoc_pnu_contr

		--Se carga la tabla temporal de contratos vencidos (con giros activos) que poseen garantías activas
		INSERT	#TEMP_CONTRATOS_VENCIDOS_GA (cod_operacion, cod_contabilidad, cod_oficina, cod_moneda, cod_producto, num_contrato)
		SELECT	GO1.cod_operacion, GO1.cod_contabilidad, GO1.cod_oficina, GO1.cod_moneda, 10 AS cod_producto, GO1.num_contrato
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_SICC_PRMCA MCA
			ON GO1.cod_contabilidad = MCA.prmca_pco_conta
			AND GO1.cod_oficina = MCA.prmca_pco_ofici 
			AND GO1.cod_moneda = MCA.prmca_pco_moned
			AND GO1.num_contrato = MCA.prmca_pnu_contr
			INNER JOIN #TEMP_GIROS_ACTIVOS TGA
			ON MCA.prmca_pnu_contr = TGA.prmoc_pnu_contr
			AND MCA.prmca_pco_ofici = TGA.prmoc_pco_oficon
			AND MCA.prmca_pco_moned = TGA.prmoc_pcomonint
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON MPC.bsmpc_sco_ident = MCA.prmca_pco_ident
			INNER JOIN dbo.GAR_SICC_BSMCL MCL
			ON MCL.bsmcl_sco_ident = MPC.bsmpc_sco_ident 
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
			AND MPC.bsmpc_estado = 'A'
			AND MCL.bsmcl_estado = 'A'
			AND MGT.prmgt_estado = 'A'


		BEGIN TRANSACTION TRA_Act_Cvga
			BEGIN TRY
		
				UPDATE	GO1
				SET		GO1.cod_estado = 1
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GO1.cod_operacion
				WHERE	GO1.cod_estado = 2
					AND GO1.num_operacion IS NULL
					
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Cvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GFO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
					ON	GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGF.cod_garantia_fiduciaria = GFO.cod_garantia_fiduciaria
				WHERE	GFO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 0
					

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gfcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías fiduciarias asociadas a los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grhccvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común (con clase distinta a 11) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
					AND GGR.cod_partido = MGT.prmgt_pnu_part
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 11

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grhccvga11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de hipoteca común (con clase igual a 11) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20
					AND MGT.prmgt_pcoclagar <= 29
					AND MGT.prmgt_pcotengar = 1

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grchcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria (con clase distinto a 18) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
					AND GGR.cod_partido = MGT.prmgt_pnu_part
					AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar = 18

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grchcvga18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de cédula hipotecaria (con clase igual a 18) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
						OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
						OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grpcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda (con clase distinta a 38 o 43) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GRO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_REAL GGR
					ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
					AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				WHERE	GRO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND ((MGT.prmgt_pcoclagar = 38)
						OR (MGT.prmgt_pcoclagar = 43))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Grpcvga3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías reales de prenda (con clase igual a 38 o 43) y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

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
					INNER JOIN #TEMP_CONTRATOS_VENCIDOS_GA TCV
					ON TCV.cod_operacion = GVO.cod_operacion
					INNER JOIN dbo.GAR_SICC_PRMGT MGT
					ON MGT.prmgt_pnu_oper = TCV.num_contrato
					AND MGT.prmgt_pco_ofici = TCV.cod_oficina
					AND MGT.prmgt_pco_moned = TCV.cod_moneda
					AND MGT.prmgt_pco_produ = TCV.cod_producto
					AND MGT.prmgt_pco_conta = TCV.cod_contabilidad
					INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
					ON	GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
					AND GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar
				WHERE	GVO.cod_estado = 2
					AND MGT.prmgt_estado = 'A'
					AND MGT.prmgt_pcoclagar >= 20 
					AND MGT.prmgt_pcoclagar <= 29
					AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gvcvga

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al activar las relaciones entre las garantías de valor y los contratos vencidos con giros activos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gvcvga
		
/***********************************************************************************************************************************************/

--SE HOMOLOGA LA FECHA DE REPLICA EN TODOS LOS REGISTROS

/***********************************************************************************************************************************************/
	
		/*SE CARGA LA TABLA TEMPORAL DE GARANTIAS FIDUCIARIAS*/
		;WITH FIDUCIARIAS (Identificacion_Garantia, Fecha_Replica) 
		AS
		(
			SELECT	GF1.Identificacion_Sicc, MAX(COALESCE(GF1.Fecha_Replica, '19000101')) AS Fecha_Replica
			FROM	dbo.GAR_GARANTIA_FIDUCIARIA GF1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GF1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GF1.Identificacion_Sicc
			WHERE MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 0
			GROUP BY GF1.Identificacion_Sicc				
		)
		INSERT #TEMP_GARANTIAS_FIDUCIARIAS (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGF.cod_garantia_fiduciaria, 
				CASE 
					WHEN TMP.Fecha_Replica > COALESCE(GFO.Fecha_Replica, '19000101') THEN TMP.Fecha_Replica
					ELSE COALESCE(GFO.Fecha_Replica, '19000101')
				END AS Fecha_Replica
		FROM	FIDUCIARIAS TMP
			INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
			ON GGF.Identificacion_Sicc = TMP.Identificacion_Garantia
			INNER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
			ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
		
		
		UPDATE	#TEMP_GARANTIAS_FIDUCIARIAS
		SET		Fecha_Replica = NULL
		WHERE	Fecha_Replica = '19000101'
				
		--Se actualiza la fecha de la replica, de la información de la garantía fiduciaria, a la mayor que posea cada registro en la relación
		BEGIN TRANSACTION TRA_Act_Gf
			BEGIN TRY	
			
				UPDATE	GGF
				SET		GGF.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
					INNER JOIN #TEMP_GARANTIAS_FIDUCIARIAS TMP
					ON TMP.Consecutivo_Garantia = GGF.cod_garantia_fiduciaria
				

				UPDATE	GFO
				SET		GFO.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
					INNER JOIN #TEMP_GARANTIAS_FIDUCIARIAS TMP
					ON TMP.Consecutivo_Garantia = GFO.cod_garantia_fiduciaria
				
							
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gf

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información de la garantía fiduciaria. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gf
		
			
		

		/*SE CARGA LA TABLA TEMPORAL DE GARANTIAS REALES*/
		;WITH REALES_HC_NO11 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia, cod_partido) 
		AS
		(
			--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia, GR1.cod_partido
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
				AND MGT.prmgt_pnu_part = GR1.cod_partido
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc, GR1.cod_partido				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_HC_NO11 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.cod_partido = TMP.cod_partido
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia


		;WITH REALES_HC_CG11 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia, cod_partido, Identificacion_Alfanumerica_Sicc) 
		AS
		(
			--HIPOTECAS COMUNES CON CLASE IGUAL 11
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia, GR1.cod_partido, GR1.Identificacion_Alfanumerica_Sicc
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
				AND MGT.prmgt_pnu_part = GR1.cod_partido
				AND MGT.prmgt_pnuide_alf = GR1.Identificacion_Alfanumerica_Sicc
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 11
				AND LEN(COALESCE(MGT.prmgt_pnuide_alf, '')) > 0
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc, GR1.cod_partido, GR1.Identificacion_Alfanumerica_Sicc				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_HC_CG11 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.cod_partido = TMP.cod_partido
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia
			AND GGR.Identificacion_Alfanumerica_Sicc = TMP.Identificacion_Alfanumerica_Sicc
			
		

		;WITH REALES_CH_CG18 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia, cod_partido, cod_grado) 
		AS
		(
			--CEDULAS HIPOTECARIAS CON CLASE IGUAL 18
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia, GR1.cod_partido, GR1.cod_grado
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
				AND MGT.prmgt_pnu_part = GR1.cod_partido
				AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GR1.cod_grado
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 18				
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc, GR1.cod_partido, GR1.cod_grado				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_CH_CG18 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.cod_partido = TMP.cod_partido
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia
			AND GGR.cod_grado = TMP.cod_grado


		;WITH REALES_CH_NO18 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia, cod_partido, cod_grado) 
		AS
		(
			--CEDULAS HIPOTECARIAS CON CLASE DISTINTA A 18
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia, GR1.cod_partido, GR1.cod_grado
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
				AND MGT.prmgt_pnu_part = GR1.cod_partido
				AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GR1.cod_grado
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_pcoclagar >= 20 
				AND MGT.prmgt_pcoclagar <= 29				
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc, GR1.cod_partido, GR1.cod_grado				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_CH_NO18 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.cod_partido = TMP.cod_partido
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia
			AND GGR.cod_grado = TMP.cod_grado
		


		;WITH REALES_PR_NO3843 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia) 
		AS
		(
			--PRENDAS CON CLASE DISTINTA DE 38 Y 43
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
			WHERE	MGT.prmgt_estado = 'A'
				AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
					OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
					OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))				
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_PR_NO3843 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia
			

		;WITH REALES_PR_NO3843 (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia, Identificacion_Alfanumerica_Sicc) 
		AS
		(
			--PRENDAS CON CLASE IGUAL 38 Y 43
			SELECT	GR1.Identificacion_Sicc, MAX(COALESCE(GR1.Fecha_Replica, '19000101')) AS Fecha_Replica, GR1.cod_clase_garantia, GR1.Identificacion_Alfanumerica_Sicc
			FROM	dbo.GAR_GARANTIA_REAL GR1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GR1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GR1.Identificacion_Sicc
				AND MGT.prmgt_pnuide_alf = GR1.Identificacion_Alfanumerica_Sicc
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
				AND LEN(COALESCE(MGT.prmgt_pnuide_alf, '')) > 0				
			GROUP BY GR1.cod_clase_garantia, GR1.Identificacion_Sicc, GR1.Identificacion_Alfanumerica_Sicc				
		)
		INSERT #TEMP_GARANTIAS_REALES (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGR.cod_garantia_real, TMP.Fecha_Replica
		FROM	REALES_PR_NO3843 TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGR.Identificacion_Sicc = TMP.Identificacion_Garantia
			AND GGR.Identificacion_Alfanumerica_Sicc = TMP.Identificacion_Alfanumerica_Sicc

		
		UPDATE	TMP
		SET		TMP.Fecha_Replica = GRO.Fecha_Replica
		FROM	#TEMP_GARANTIAS_REALES TMP
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = TMP.Consecutivo_Garantia
		WHERE	COALESCE(GRO.Fecha_Replica, '19000101') > TMP.Fecha_Replica
		
		
		UPDATE	TMP
		SET		TMP.Fecha_Replica = GVR.Fecha_Replica
		FROM	#TEMP_GARANTIAS_REALES TMP
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = TMP.Consecutivo_Garantia
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR
			ON GVR.cod_garantia_real = GRO.cod_garantia_real
		WHERE	COALESCE(GVR.Fecha_Replica, '19000101') > TMP.Fecha_Replica
			AND GVR.fecha_valuacion = GRO.Fecha_Valuacion_SICC
		
		
		UPDATE	#TEMP_GARANTIAS_REALES
		SET		Fecha_Replica = NULL
		WHERE	Fecha_Replica = '19000101'



		--Se actualiza la fecha de la replica, de la información de la garantía real, a la mayor que posea cada registro en la relación
		BEGIN TRANSACTION TRA_Act_Gr
			BEGIN TRY	
				
				UPDATE	GGR
				SET		GGR.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN #TEMP_GARANTIAS_REALES TMP
					ON TMP.Consecutivo_Garantia = GGR.cod_garantia_real
			
				UPDATE	GRO
				SET		GRO.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					INNER JOIN #TEMP_GARANTIAS_REALES TMP
					ON TMP.Consecutivo_Garantia = GRO.cod_garantia_real

				UPDATE	GRV
				SET		GRV.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_VALUACIONES_REALES GRV
					INNER JOIN #TEMP_GARANTIAS_REALES TMP
					ON TMP.Consecutivo_Garantia = GRV.cod_garantia_real
					INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
					ON GRO.cod_garantia_real = TMP.Consecutivo_Garantia
				WHERE	GRV.fecha_valuacion = GRO.Fecha_Valuacion_SICC
			
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gr

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información de la garantía real. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gr
		
		

		/*SE CARGA LA TABLA TEMPORAL DE GARANTIAS VALOR*/
		;WITH VALOR (Identificacion_Garantia, Fecha_Replica, cod_clase_garantia) 
		AS
		(			
			SELECT	GV1.Identificacion_Sicc, MAX(COALESCE(GV1.Fecha_Replica, '19000101')) AS Fecha_Replica, GV1.cod_clase_garantia
			FROM	dbo.GAR_GARANTIA_VALOR GV1
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pcoclagar = GV1.cod_clase_garantia 
				AND MGT.prmgt_pnuidegar = GV1.Identificacion_Sicc
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar >= 20 
				AND MGT.prmgt_pcoclagar <= 29
				AND ((MGT.prmgt_pcotengar = 6) OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))		
			GROUP BY GV1.cod_clase_garantia, GV1.Identificacion_Sicc				
		)
		INSERT #TEMP_GARANTIAS_VALOR (Consecutivo_Garantia, Fecha_Replica)
		SELECT	GGV.cod_garantia_valor, 
				CASE 
					WHEN TMP.Fecha_Replica > COALESCE(GVO.Fecha_Replica, '19000101') THEN TMP.Fecha_Replica
					ELSE COALESCE(GVO.Fecha_Replica, '19000101')
				END AS Fecha_Replica
		FROM	VALOR TMP
			INNER JOIN dbo.GAR_GARANTIA_VALOR GGV
			ON GGV.cod_clase_garantia = TMP.cod_clase_garantia
			AND GGV.Identificacion_Sicc = TMP.Identificacion_Garantia
			INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
			ON GVO.cod_garantia_valor = GGV.cod_garantia_valor


		UPDATE	#TEMP_GARANTIAS_VALOR
		SET		Fecha_Replica = NULL
		WHERE	Fecha_Replica = '19000101'

		
		--Se actualiza la fecha de la replica, de la información de la garantía de valor, a la mayor que posea cada registro en la relación
		BEGIN TRANSACTION TRA_Act_Gv
			BEGIN TRY	
			
				UPDATE	GGV
				SET		GGV.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIA_VALOR GGV
					INNER JOIN #TEMP_GARANTIAS_VALOR TMP
					ON TMP.Consecutivo_Garantia = GGV.cod_garantia_valor
				
				UPDATE	GVO
				SET		GVO.Fecha_Replica = TMP.Fecha_Replica
				FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
					INNER JOIN #TEMP_GARANTIAS_VALOR TMP
					ON TMP.Consecutivo_Garantia = GVO.cod_garantia_valor
			
			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Act_Gv

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al normalizar la fecha de la réplica entre los registros de la información de la garantía de valor. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdtFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Gv
		
	END	


END