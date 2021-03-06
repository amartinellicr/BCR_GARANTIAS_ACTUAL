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
	@piIndicadorProceso	TINYINT,
	@psCodigoProceso	VARCHAR(20)	
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
			<Fecha>23/06/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #5, #6, #11 y #12. El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>07/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
				cualquier lógica existente. 
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



----------------------------------------------------------------------
--CARGA CONTRATOS VENCIDOS
----------------------------------------------------------------------

	DECLARE	@vdFecha_Actual_SinHora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
			@viFecha_Actual_Entera INT, --Corresponde al a fecha actual en formato numérico.
			@vsDescripcion_Error VARCHAR(1000), --Descripción del error capturado.
			@vsDescripcion_Bitacora_Errores VARCHAR(5000) --Descripción del error que será guardado en la bitácora de errores.

	--Se inicializan las variables
	SET	@vdFecha_Actual_SinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	

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

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los deudores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				INNER JOIN dbo.GAR_SICC_PRMOC MOC
				ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
				AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
				AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
				LEFT OUTER JOIN dbo.GAR_DEUDOR GD1
				ON GD1.Identificacion_Sicc = MCA.prmca_pco_ident
			WHERE  MCL.bsmcl_estado = 'A'
				AND ((MOC.prmoc_pcoctamay < 815)
					OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
				AND GD1.cedula_deudor IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Deud

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los deudores asociados a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
	DELETE FROM dbo.TMP_GAR_CONTRATOS 

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
		cedula_deudor,
		saldo_actual
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
			MCA.prmca_pco_ident,
			(MCA.prmca_pmo_maxim - MCA.prmca_pmo_utiliz) AS saldo_actual
	FROM	dbo.GAR_SICC_PRMCA MCA
		INNER JOIN dbo.GAR_SICC_PRMOC MOC
		ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		LEFT OUTER JOIN dbo.TMP_GAR_CONTRATOS TMP
		ON TMP.num_contrato = MCA.prmca_pnu_contr
		AND TMP.cod_oficina = MCA.prmca_pco_ofici
		AND TMP.cod_moneda = MCA.prmca_pco_moned
		AND TMP.cod_producto = MCA.prmca_pco_produc
		AND TMP.cod_contabilidad = MCA.prmca_pco_conta
	WHERE	MCA.prmca_estado = 'A'
		AND MOC.prmoc_estado = 'A' 
		AND MOC.prmoc_pse_proces = 1
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815)) --Operaciones no insolutas
		AND TMP.num_contrato IS NULL
		AND TMP.cod_oficina IS NULL
		AND TMP.cod_moneda IS NULL
		AND TMP.cod_producto IS NULL
		AND TMP.cod_contabilidad IS NULL


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
				cod_estado,
				Cuenta_Contable
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
				TMP.cod_estado,
				-1 AS Cuenta_Contable
			FROM	dbo.TMP_GAR_CONTRATOS TMP
				INNER JOIN dbo.GAR_DEUDOR GDE
				ON GDE.cedula_deudor = TMP.cedula_deudor
				LEFT OUTER JOIN dbo.GAR_OPERACION GO1
				ON GO1.cod_oficina = TMP.cod_oficina
				AND GO1.cod_moneda = TMP.cod_moneda
				AND GO1.cod_producto = TMP.cod_producto
				AND GO1.num_contrato = TMP.num_contrato
				AND GO1.num_operacion IS NULL
			WHERE	GO1.cod_oficina IS NULL
				AND GO1.cod_moneda IS NULL
				AND GO1.cod_producto IS NULL
				AND GO1.num_contrato IS NULL

			END TRY
			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION TRA_Ins_Oper

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los contratos nuevos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los fiadores. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_FIDUCIARIA GGF
				ON GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar
			WHERE	MGT.prmgt_estado = 'A'	
				AND MGT.prmgt_pcoclagar = 0
				AND MGT.prmgt_pco_produ = 10
				AND MCL.bsmcl_estado = 'A'
				AND GGF.cod_garantia_fiduciaria IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggf

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los fiadores nuevos asociados a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				Fecha_Replica,
				Porcentaje_Aceptacion
			)
			SELECT	DISTINCT
				GO1.cod_operacion,
				GGF.cod_garantia_fiduciaria,
				0 AS cod_tipo_mitigador,
				NULL AS cod_tipo_documento_legal,
				0 AS monto_mitigador,
				-1 AS porcentaje_responsabilidad,
				0 AS cod_operacion_especial,
				2 AS cod_tipo_acreedor,
				'4000000019' AS cedula_acreedor,
				1 AS cod_estado,
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.GAR_SICC_BSMCL MCL
				ON	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
				ON	GFO.cod_operacion = GO1.cod_operacion
				AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
			WHERE	MGT.prmgt_estado = 'A'	
				AND MGT.prmgt_pcoclagar = 0
				AND GO1.num_operacion IS NULL
				AND GFO.cod_operacion IS NULL
				AND GFO.cod_garantia_fiduciaria IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Gfo

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones nuevas entre las garantías fiduciarias y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
													WHEN dbo.ufn_EsNumero(RTRIM(LTRIM(GGR.numero_finca))) = 0 THEN dbo.ufn_ConvertirCodigoGarantia(RTRIM(LTRIM(GGR.numero_finca)))
													ELSE -1
												END
			FROM	dbo.GAR_GARANTIA_REAL GGR
			WHERE	GGR.cod_clase_garantia >= 10 
				AND GGR.cod_clase_garantia <= 29

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Id_Bienhc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los bienes de hipotecas y cédulas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
			WHERE	GGR.cod_clase_garantia >= 30 
				AND GGR.cod_clase_garantia <= 69

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Act_Id_Bienp

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de los bienes de prendas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION TRA_Act_Id_BienpAlf



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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GGR.cod_tipo_garantia_real = 1
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Grhc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase distinta a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
				AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				AND GGR.cod_tipo_garantia_real = 1
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 11
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Grhc11

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las hipotecas comunes nuevas (con clase igual a 11) asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Grhc11
	
END

--Relación entre la hipoteca y el contrato
IF(@piIndicadorProceso = 6)
BEGIN

	--Se insertan los registros con clase distinta a 11
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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 10) OR (MGT.prmgt_pcoclagar = 19) OR ((MGT.prmgt_pcoclagar >= 12) AND (MGT.prmgt_pcoclagar <= 17)))
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
				
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrohc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones nuevas entre las hipotecas comunes (con clase distinta a 11) y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrohc
		
	
	--Se insertan los registros con clase igual a 11
	BEGIN TRANSACTION TRA_Ins_Ggrohc11
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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 11
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
				
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrohc11

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones nuevas entre las hipotecas comunes (con clase igual a 11) y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrohc11
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
				Identificacion_Alfanumerica_Sicc,
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GGR.cod_tipo_garantia_real = 2
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 18
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Gchc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias, con clase 18, nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON	GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 18
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggroch18

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre la cédulas hipotecarias, con clase 18, nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				Identificacion_Alfanumerica_Sicc,
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) --Cambio del 16/04/2015
				AND GGR.cod_partido = MGT.prmgt_pnu_part
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GGR.cod_tipo_garantia_real = 2
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_pcoclagar >= 20 
				AND MGT.prmgt_pcoclagar <= 29
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Grchc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las cédulas hipotecarias, con clase diferente a 18, nuevas asociadas a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON	GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_pcoclagar >= 20 
				AND MGT.prmgt_pcoclagar <= 29
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggroch

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre la cédulas hipotecarias, con clase diferente 18, nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggroch
END


----------------------------------------------------------------------
--CARGA PRENDAS (GARANTIAS REALES)
----------------------------------------------------------------------
IF(@piIndicadorProceso = 11)
BEGIN

	--Se insertan los registros con clase distinta a 38 o 43
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
				Identificacion_Alfanumerica_Sicc,
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
				AND GGR.cod_tipo_garantia_real = 3
			WHERE	MGT.prmgt_estado = 'A'
				AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
					OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
					OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrp

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase distinta a 38 o 43) asociadas a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrp
		
		
	--Se insertan los registros con clase igual a 38 o 43
	BEGIN TRANSACTION TRA_Ins_Ggrp3843
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
				GETDATE()
			FROM	dbo.GAR_SICC_PRMGT MGT
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON	GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
				AND COALESCE(GGR.Identificacion_Sicc, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
				AND COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
				AND GGR.cod_tipo_garantia_real = 3
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
				AND MGT.prmgt_pco_produ = 10
				AND GGR.cod_garantia_real IS NULL

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrp3843

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las prendas nuevas (con clase igual a 38 o 43) asociadas a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrp3843
END

--Relación entre la prenda y el contrato
IF(@piIndicadorProceso = 12)
BEGIN

	--Se insertan los registros con clase distinta a 38 o 43
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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON	GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND (((MGT.prmgt_pcoclagar >= 30) AND (MGT.prmgt_pcoclagar <= 37))
					OR ((MGT.prmgt_pcoclagar >= 39) AND (MGT.prmgt_pcoclagar <= 42))
					OR ((MGT.prmgt_pcoclagar >= 44) AND (MGT.prmgt_pcoclagar <= 69)))
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrpc

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre las prendas nuevas (con clase distinta a 38 o 43) y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrpc
		
	
	--Se insertan los registros con clase igual a 38 o 43
	BEGIN TRANSACTION TRA_Ins_Ggrpc3843
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
				Fecha_Replica,
				Porcentaje_Aceptacion
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
				-1 AS porcentaje_responsabilidad,
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
				GETDATE(),
				100 AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON	GRO.cod_operacion = GO1.cod_operacion
				AND GRO.cod_garantia_real = GGR.cod_garantia_real
			WHERE	MGT.prmgt_estado = 'A'
				AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
				AND GO1.num_operacion IS NULL
				AND GRO.cod_operacion IS NULL
				AND GRO.cod_garantia_real IS NULL
	
		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Ggrpc3843

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre las prendas nuevas (con clase igual a 38 o 43) y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

		END CATCH

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION TRA_Ins_Ggrpc3843
	
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

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la identificación numérica de las seguridades. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
				LEFT OUTER JOIN dbo.GAR_GARANTIA_VALOR GGV
				ON	GGV.cod_clase_garantia = MGT.prmgt_pcoclagar
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

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las seguridades nuevas asociadas a los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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
				INNER JOIN dbo.TMP_GAR_CONTRATOS TMP
				ON	TMP.num_contrato = MGT.prmgt_pnu_oper
				AND TMP.cod_oficina = MGT.prmgt_pco_ofici
				AND TMP.cod_moneda = MGT.prmgt_pco_moned
				AND TMP.cod_contabilidad = MGT.prmgt_pco_conta
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

			SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar las relaciones entre seguridades nuevas y los contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
			EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_SinHora, @vsDescripcion_Bitacora_Errores, 1

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

