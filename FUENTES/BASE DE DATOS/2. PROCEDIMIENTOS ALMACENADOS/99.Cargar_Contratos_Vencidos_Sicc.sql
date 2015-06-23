USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('dbo.Cargar_Contratos_Vencidos_Sicc', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Cargar_Contratos_Vencidos_Sicc;
GO

CREATE PROCEDURE [dbo].[Cargar_Contratos_Vencidos_Sicc]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)	
AS
BEGIN
/******************************************************************
	<Nombre>Cargar_Contratos_Vencidos_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
			Migra la información de garantías de los contratos vencidos, con giros activos, del 
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
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
******************************************************************/
SET NOCOUNT ON 



----------------------------------------------------------------------
--CARGA CONTRATOS VENCIDOS
----------------------------------------------------------------------

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
--Inserta el deudor del contrato
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
	
			
	BEGIN TRANSACTION TRA_Ins_Deud
		BEGIN TRY

			INSERT	INTO  dbo.GAR_DEUDOR
			(
				cedula_deudor, 
				nombre_deudor, 
				cod_tipo_deudor, 
				cod_vinculado_entidad,
				Identificacion_Sicc
			)
			SELECT	DISTINCT
				MCA.prmca_pco_ident,
				MCL.bsmcl_sno_clien,
				MCL.bsmcl_scotipide,
				2 AS cod_vinculado_entidad,
				MCA.prmca_pco_ident
			FROM	dbo.GAR_SICC_PRMCA MCA
				INNER JOIN dbo.GAR_SICC_BSMCL MCL
				ON MCL.bsmcl_sco_ident = MCA.prmca_pco_ident
			WHERE  MCL.bsmcl_estado = 'A'
				AND EXISTS (SELECT	1
							FROM	dbo.GAR_SICC_PRMOC MOC
							WHERE	MOC.prmoc_estado = 'A' 
							AND ((MOC.prmoc_pcoctamay < 815)
								OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
							AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
							AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
							AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr)	
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_DEUDOR
								WHERE	Identificacion_Sicc = MCA.prmca_pco_ident)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Deud

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los deudores asociados a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Deud
END


-------------------------------------------------------------------------------------------------------------------------
-- CONTRATOS
-------------------------------------------------------------------------------------------------------------------------	
--Inserta la información del contrato
IF(@piIndicadorProceso = 2)
BEGIN
	--Elimina de la tabla todos los registros 
	TRUNCATE TABLE dbo.TMP_GAR_CONTRATOS 

	--Inserta la información del contrato
	INSERT INTO dbo.TMP_GAR_CONTRATOS 
	(
		cod_contabilidad, 
		cod_oficina, 
		cod_moneda, 
		cod_producto, 
		num_contrato, 
		fecha_constitucion, 
		fecha_vencimiento, 
		cedula_deudor
	)
	SELECT	DISTINCT
		MCA.prmca_pco_conta,
		MCA.prmca_pco_ofici,
		MCA.prmca_pco_moned,
		MCA.prmca_pco_produc,
		MCA.prmca_pnu_contr,
		CASE 
			WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_const)) 
			ELSE CONVERT(DATETIME, '1900-01-01')
		END AS prmca_pfe_const,
		CASE 
			WHEN ISDATE(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MCA.prmca_pfe_defin)) 
			ELSE CONVERT(DATETIME, '1900-01-01')
		END AS prmca_pfe_defin,
		MCA.prmca_pco_ident
	FROM	dbo.GAR_SICC_PRMCA MCA
	WHERE  MCA.prmca_estado = 'A'
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_SICC_PRMOC MOC
					WHERE	MOC.prmoc_estado = 'A' 
					AND ((MOC.prmoc_pcoctamay < 815)
						OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
					AND MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
					AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
					AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr)	
		AND NOT EXISTS (SELECT	1
						FROM	dbo.TMP_GAR_CONTRATOS TMP
						WHERE	TMP.num_contrato = MCA.prmca_pnu_contr
							AND TMP.cod_oficina = MCA.prmca_pco_ofici
							AND TMP.cod_moneda = MCA.prmca_pco_moned
							AND TMP.cod_producto = MCA.prmca_pco_produc
							AND TMP.cod_contabilidad = MCA.prmca_pco_conta)


	--Inserta los contratos en GAR_OPERACION
	BEGIN TRANSACTION TRA_Ins_Oper
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
				cod_estado
			)
			SELECT DISTINCT 
				TMP.cod_contabilidad, 
				TMP.cod_oficina, 
				TMP.cod_moneda, 
				TMP.cod_producto, 
				TMP.num_operacion, 
				TMP.num_contrato, 
				TMP.fecha_constitucion, 
				TMP.cedula_deudor, 
				TMP.fecha_vencimiento, 
				TMP.monto_original, 
				TMP.saldo_actual, 
				TMP.cod_estado
			FROM	dbo.TMP_GAR_CONTRATOS TMP
			WHERE	EXISTS (SELECT	1
							FROM	dbo.GAR_DEUDOR GDE
							WHERE	GDE.cedula_deudor = TMP.cedula_deudor)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_OPERACION GO1
								WHERE	GO1.cod_oficina = TMP.cod_oficina
									AND GO1.cod_moneda = TMP.cod_moneda
									AND GO1.cod_producto = TMP.cod_producto
									AND GO1.num_contrato = TMP.num_contrato
									AND GO1.num_operacion IS NULL)

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Oper

				SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los contratos nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

			END CATCH

		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Ins_Oper
END


----------------------------------------------------------------------
--CARGA GARANTIAS FIDUCIARIAS
----------------------------------------------------------------------
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
			
			
	BEGIN TRANSACTION TRA_Ins_Ggf
		BEGIN TRY

			INSERT	INTO dbo.GAR_GARANTIA_FIDUCIARIA
			(
				cod_tipo_garantia, 
				cod_clase_garantia, 
				cedula_fiador, 
				nombre_fiador, 
				cod_tipo_fiador,
				Identificacion_Sicc,
				Fecha_Replica
			)
			SELECT	DISTINCT 
				1 AS cod_tipo_garantia,
				MGT.prmgt_pcoclagar AS cod_clase_garantia,
				MGT.prmgt_pnuidegar AS cedula_fiador,
				MCL.bsmcl_sno_clien AS nombre_fiador,
				MCL.bsmcl_scotipide AS cod_tipo_fiador,
				MGT.prmgt_pnuidegar AS Identificacion_Sicc,
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN	dbo.GAR_SICC_BSMCL MCL
				ON MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
			WHERE	MGT.prmgt_estado = 'A'	
				AND MGT.prmgt_pcoclagar = 0
				AND MGT.prmgt_pco_produ = 10
				AND MCL.bsmcl_estado = 'A'
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
								WHERE	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggf

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggf
END

--Relación entre el fiador y el contrato
IF(@piIndicadorProceso = 4)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Gfo
		BEGIN TRY

			INSERT	INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
			(
				cod_operacion,
				cod_garantia_fiduciaria,
				cod_tipo_mitigador,
				cod_tipo_documento_legal,
				monto_mitigador,
				porcentaje_responsabilidad,
				cod_operacion_especial,
				cod_tipo_acreedor,
				cedula_acreedor,
				cod_estado,
				Fecha_Replica
			)
			SELECT	DISTINCT
				GO1.cod_operacion,
				GGF.cod_garantia_fiduciaria,
				0 AS cod_tipo_mitigador,
				NULL AS cod_tipo_documento_legal,
				0 AS monto_mitigador,
				0 AS porcentaje_responsabilidad,
				0 AS cod_operacion_especial,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				1 AS cod_estado,
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.GAR_OPERACION GO1
				ON GO1.num_contrato = MGT.prmgt_pnu_oper
				AND GO1.cod_oficina = MGT.prmgt_pco_ofici
				AND GO1.cod_moneda = MGT.prmgt_pco_moned
				AND GO1.cod_contabilidad = MGT.prmgt_pco_conta
				AND MGT.prmgt_pco_produ = 10
				INNER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
				ON GGF.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
			WHERE	MGT.prmgt_estado = 'A'	
				AND MGT.prmgt_pcoclagar = 0
				AND GO1.num_operacion IS NULL
				AND EXISTS (SELECT	1
							FROM	dbo.GAR_SICC_BSMCL MCL
							WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar)
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
								WHERE	GFO.cod_operacion = GO1.cod_operacion
									AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Gfo

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones nuevas entre las garantías fiduciarias y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Gfo
END


----------------------------------------------------------------------
--CARGA HIPOTECAS (GARANTIAS REALES)
----------------------------------------------------------------------
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) 
				AND MGT.prmgt_pco_produ = 10
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
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

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las hipotecas comunes nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Grhc
END

--Relación entre la hipoteca y el contrato
IF(@piIndicadorProceso = 6)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Ggrohc
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
				Fecha_Replica
			)
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
				100 AS porcentaje_responsabilidad,
				CASE 
					WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
					WHEN MGT.prmgt_pco_grado >= 4 THEN 4
					ELSE NULL			
				END AS cod_grado_gravamen,
				0 AS cod_operacion_especial,
				GO1.fecha_constitucion AS fecha_constitucion,
				GO1.fecha_vencimiento,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				MGT.prmgt_pcoliqgar AS cod_liquidez,
				MGT.prmgt_pcotengar AS cod_tenencia,
				MGT.prmgt_pco_mongar AS cod_moneda,
				CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
					 ELSE CONVERT(DATETIME, '1900-01-01')
				END AS fecha_prescripcion,
				GETDATE()
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
				AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) 
				AND GO1.num_operacion IS NULL
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								WHERE	GRO.cod_operacion = GO1.cod_operacion
									AND GRO.cod_garantia_real = GGR.cod_garantia_real)
				
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrohc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones nuevas entre las hipotecas comunes y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrohc
END


----------------------------------------------------------------------
--CARGA CEDULAS HIPOTECARIAS (GARANTIAS REALES)
----------------------------------------------------------------------
--Cédulas hipotecarias con clase 18
IF(@piIndicadorProceso = 7)
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 18
				AND MGT.prmgt_pco_produ = 10
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_tipo_garantia_real = 2
									AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
									AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
									AND GGR.cod_partido = MGT.prmgt_pnu_part
									AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Gchc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las cédulas hipotecarias, con clase 18, nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Gchc
END

--Relación entre la cédula hipotecaria de clase 18 y el contrato
IF(@piIndicadorProceso = 8)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Ggroch18
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
				Fecha_Replica
			)
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
				100 AS porcentaje_responsabilidad,
				CASE 
					WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
					WHEN MGT.prmgt_pco_grado >= 4 THEN 4
					ELSE NULL			
				END AS cod_grado_gravamen,
				0 AS cod_operacion_especial,
				GO1.fecha_constitucion AS fecha_constitucion,
				GO1.fecha_vencimiento,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				MGT.prmgt_pcoliqgar AS cod_liquidez,
				MGT.prmgt_pcotengar AS cod_tenencia,
				MGT.prmgt_pco_mongar AS cod_moneda,
				CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
					 ELSE CONVERT(DATETIME, '1900-01-01')
				END AS fecha_prescripcion,
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.GAR_OPERACION GO1
				ON MGT.prmgt_pco_ofici = GO1.cod_oficina
				AND MGT.prmgt_pco_moned = GO1.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pnu_oper = GO1.num_contrato
				AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 18
				AND GO1.num_operacion IS NULL
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								WHERE	GRO.cod_operacion = GO1.cod_operacion
									AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggroch18

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones entre la cédulas hipotecarias, con clase 18, nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggroch18
END

--Cédulas hipotecarias con clase diferente a la 18
IF(@piIndicadorProceso = 9)
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
				AND MGT.prmgt_pco_produ = 10
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_tipo_garantia_real = 2
									AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
									AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
									AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Grchc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las cédulas hipotecarias, con clase diferente a 18, nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Grchc
END

--Relación entre la cédula hipotecaria y el contrato
IF(@piIndicadorProceso = 10)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Ggroch
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
				Fecha_Replica
			)
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
				100 AS porcentaje_responsabilidad,
				CASE 
					WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
					WHEN MGT.prmgt_pco_grado >= 4 THEN 4
					ELSE NULL			
				END AS cod_grado_gravamen,
				0 AS cod_operacion_especial,
				GO1.fecha_constitucion AS fecha_constitucion,
				GO1.fecha_vencimiento,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				MGT.prmgt_pcoliqgar AS cod_liquidez,
				MGT.prmgt_pcotengar AS cod_tenencia,
				MGT.prmgt_pco_mongar AS cod_moneda,
				CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
					 ELSE CONVERT(DATETIME, '1900-01-01')
				END AS fecha_prescripcion,
				GETDATE()
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
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								WHERE	GRO.cod_operacion = GO1.cod_operacion
									AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggroch

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones entre la cédulas hipotecarias, con clase diferente 18, nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggroch
END


----------------------------------------------------------------------
--CARGA PRENDAS (GARANTIAS REALES)
----------------------------------------------------------------------
IF(@piIndicadorProceso = 11)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Ggrp
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
				AND MGT.prmgt_pco_produ = 10
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_REAL GGR
								WHERE	GGR.cod_tipo_garantia_real = 3
									AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
									AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrp

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las prendas nuevas asociadas a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrp
END

--Relación entre la prenda y el contrato
IF(@piIndicadorProceso = 12)
BEGIN
	BEGIN TRANSACTION TRA_Ins_Ggrpc
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
				Fecha_Replica
			)
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
				100 AS porcentaje_responsabilidad,
				CASE 
					WHEN ((MGT.prmgt_pco_grado >= 1) AND (MGT.prmgt_pco_grado <= 3)) THEN MGT.prmgt_pco_grado
					WHEN MGT.prmgt_pco_grado >= 4 THEN 4
					ELSE NULL			
				END AS cod_grado_gravamen,
				0 AS cod_operacion_especial,
				GO1.fecha_constitucion AS fecha_constitucion,
				GO1.fecha_vencimiento,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				MGT.prmgt_pcoliqgar AS cod_liquidez,
				MGT.prmgt_pcotengar AS cod_tenencia,
				MGT.prmgt_pco_mongar AS cod_moneda,
				CASE WHEN ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1 THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
					 ELSE CONVERT(DATETIME, '1900-01-01')
				END AS fecha_prescripcion,
				GETDATE()
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
				AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
				AND GO1.num_operacion IS NULL
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								WHERE	GRO.cod_operacion = GO1.cod_operacion
									AND GRO.cod_garantia_real = GGR.cod_garantia_real)
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrpc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones entre las prendas nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrpc
END


----------------------------------------------------------------------
--CARGA GARANTIAS DE VALOR
----------------------------------------------------------------------
IF(@piIndicadorProceso = 13)
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
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIA_VALOR GGV
								WHERE	GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Grvoc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las seguridades nuevas asociadas a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Grvoc
END

--Relación entre la seguridad y el contrato
IF(@piIndicadorProceso = 14)
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
				porcentaje_responsabilidad,
				Fecha_Replica
			) 
			SELECT	DISTINCT
				GO1.cod_operacion,
				GGV.cod_garantia_valor,
				GO1.saldo_actual AS monto_mitigador,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				0 AS cod_operacion_especial,
				100 AS porcentaje_responsabilidad,
				GETDATE()
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
				AND EXISTS (SELECT	1
							FROM	dbo.TMP_GAR_CONTRATOS TMP
							WHERE	TMP.num_contrato = MGT.prmgt_pnu_oper
								AND TMP.cod_oficina = MGT.prmgt_pco_ofici
								AND TMP.cod_moneda = MGT.prmgt_pco_moned
								AND TMP.cod_contabilidad = MGT.prmgt_pco_conta)
				AND NOT EXISTS (SELECT	1
								FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
								WHERE	GVO.cod_operacion = GO1.cod_operacion
									AND GVO.cod_garantia_valor = GGV.cod_garantia_valor)

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Gvooc

			SELECT @vsDescripcionBitacoraErrores = 'Se produjo un error al migrar las relaciones entre seguridades nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFechaActualSinHora, @vsDescripcionBitacoraErrores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Gvooc
END


END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

