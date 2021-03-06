USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ActualizarRegistros', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ActualizarRegistros;
GO

CREATE PROCEDURE [dbo].[pa_ActualizarRegistros]

AS
BEGIN
/******************************************************************
	<Nombre>pa_ActualizarRegistros</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Actualiza cierta información de garantías de las operaciones de crédito y de los nuevos contratos del 
			     SICC existentes en la base de datos GARANTIAS. Además, habilita y deshabilita registros.
	</Descripción>
	<Entradas></Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>29/10/2008</Fecha>
			<Descripción>
				Se agrega la programación necesaria para corregir el problema de la asignación de las
			    garantías de los contratos a los giros.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Req_Garantia Real, Siebel No. 1-21537644.
			</Requerimiento>
			<Fecha>20/06/2013</Fecha>
			<Descripción>
					Se agrega el mapeo del tipo de documento legal, según el código de grado de gravamen indicado en el SICC, así mismo,
					el mapeo de la fecha de constitución, fecha de prescripción y de vencimiento de las garantías.
					También se realiza el mapeo de los campos de las estructuras del SICC, esto por cambios suscitados en la tablas
					del BNX.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Actualizacion de procedimientos almacenados, Siebel No. 1-24307807.
			</Requerimiento>
			<Fecha>13/05/2014</Fecha>
			<Descripción>
					Se elimina la referencia al BNX, mediante el uso del link server, por la referencia a una base de datos local. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajustes por Fallas Técnicas, Siebel No. 1-24331191.
			</Requerimiento>
			<Fecha>28/05/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se extrae la información del SICC, tomándo en 
					cuenta que las operación esté activa o el contrato vigente o vencido con giros 
					activos. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Ajustes en Procedimientos Almacenados de BCRGarantías, Siebel No. 1-24330461.
			</Requerimiento>
			<Fecha>30/05/2014</Fecha>
			<Descripción>
					Se realiza una ajuste general al procedimiento almacenado, principalmente la
					inclusión de transacciones por cada inserción, actualización o eliminación que 
					se haga. 
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
	SET XACT_ABORT ON

	DECLARE	 @viErrorTran INT, -- Almacena el código del error generado durante la transacción
		@viErrorTranMaestra INT, -- Almacena el código del error generado durante la transacción maestra
		@viFechaActualEntera INT --Corresponde al a fecha actual en formato numérico.

	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
		
	-------------------------------------------------------------------------------------------------------------------------
	-- EXTRAE LA INFORMACION DEL DATABRIDGE
	-------------------------------------------------------------------------------------------------------------------------
	--INICIO RQ: 1-24009801. Se seleccionan los campos específicos de cada estructura del SICC.

	-------------------------------------------------------------------------------------------------------------------------
	-- BSMCL
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Bsmcl
	
	TRUNCATE TABLE dbo.GAR_SICC_BSMCL
	
	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Bsmcl
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Bsmcl
	END
	
	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Bsmcl
		
		INSERT	INTO dbo.GAR_SICC_BSMCL
		SELECT	bsmcl_estado, bsmcl_sno_clien, bsmcl_sco_ident, bsmcl_sco_sexo, bsmcl_scoacteco, bsmcl_scoautbpe, bsmcl_scoestciv, bsmcl_scopercli, 
			bsmcl_scosececo, bsmcl_scotipcli, bsmcl_scotipide, bsmcl_scotipper, bsmcl_sfe_nacim, bsmcl_sseclict
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL
	
		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Bsmcl
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Bsmcl
		END
	END
	-------------------------------------------------------------------------------------------------------------------------
	-- BSMPC
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Bsmpc
	
	TRUNCATE TABLE dbo.GAR_SICC_BSMPC
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Bsmpc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Bsmpc
	END

	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Bsmpc
		
		INSERT	INTO dbo.GAR_SICC_BSMPC
		SELECT	bsmpc_estado, bsmpc_acoidereg, bsmpc_afe_trans, bsmpc_afereltra, bsmpc_afe1ind10, bsmpc_aho_trans, bsmpc_aseindi01, bsmpc_aseindi02, 
			bsmpc_aseindi03, bsmpc_aseindi04, bsmpc_aseindi05, bsmpc_aseindi06, bsmpc_aseindi07, bsmpc_aseindi08, bsmpc_aseindi09, bsmpc_aseindi10, 
			bsmpc_dco_ofici, bsmpc_sco_ident, bsmpc_tmo_ponde, bsmpc_tmo1ind01, bsmpc_tmo1ind02, bsmpc_tmo1ind03, bsmpc_tmo1ind04, 
			bsmpc_tmo1ind06, bsmpc_tmo1ind08, bsmpc_tmo1ind09, bsmpc_tmo2ind08, bsmpc_tmo2ind09, bsmpc_tmo3ind08, bsmpc_tmo3ind09, 
			bsmpc_tmo4ind08, bsmpc_tmo4ind09
		 FROM	GARANTIAS_SICC.dbo.GAR_SICC_BSMPC

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Bsmpc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Bsmpc
		END
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- PRHCS
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Act_Prhcs
	
	TRUNCATE TABLE dbo.GAR_SICC_PRHCS
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Bsmpc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Bsmpc
	END
	
	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Prhcs
		
		INSERT	INTO dbo.GAR_SICC_PRHCS 
		SELECT	prhcs_estado, prhcs_pco_calif, prhcs_pcoidesug, prhcs_pco_clien, prhcs_pcotipcal, prhcs_pcousureg, prhcs_pfe_regis 
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_PRHCS

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prhcs
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prhcs
		END
	END
	-------------------------------------------------------------------------------------------------------------------------
	-- PRMCA
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmca
	
	TRUNCATE TABLE dbo.GAR_SICC_PRMCA
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Prmca
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Prmca
	END

	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Prmca
		
		INSERT	INTO dbo.GAR_SICC_PRMCA
		SELECT  prmca_estado, prmca_pco_aprob, prmca_pco_apro2, prmca_pco_conta, prmca_pco_ident, prmca_pco_moned, prmca_pco_num01, prmca_pco_num02, 
			prmca_pco_num03, prmca_pco_ofici, prmca_pco_produc, prmca_pco_tipcre, prmca_pcoclacon, prmca_pcoestcre, prmca_pcointflu, prmca_pcooficta, 
			prmca_pcotipcon, prmca_pfe_const, prmca_pfe_defin, prmca_pfe_regis, prmca_pmo_maxim, prmca_pmo_mon01, prmca_pmo_mon02, 
			prmca_pmo_mon03, prmca_pmo_reserv, prmca_pmo_utiliz, prmca_pnu_contr, prmca_pnuctacte, prmca_pnudigver, prmca_psa_conta, 
			prmca_psa_discon, prmca_pse_contab, prmca_pse_val01, prmca_pse_val02, prmca_pse_val03, prmca_ptataspis
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_PRMCA

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prmca
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prmca
		END
	END
	-------------------------------------------------------------------------------------------------------------------------
	-- PRMGT
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmgt
	
	TRUNCATE TABLE dbo.GAR_SICC_PRMGT
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Prmgt
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Prmgt
	END
	
	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Prmgt
		
		INSERT	INTO dbo.GAR_SICC_PRMGT
		SELECT  prmgt_estado, prmgt_pco_adic1, prmgt_pco_adic2, prmgt_pco_conta, prmgt_pco_grado, prmgt_pco_moned, prmgt_pco_mongar, prmgt_pco_ofici, 
			prmgt_pco_produ, prmgt_pcoclagar, prmgt_pcoliqgar, prmgt_pcotengar, prmgt_pfe_adic1, prmgt_pfe_prescr, prmgt_pfeavaing, prmgt_pfeultins, 
			prmgt_pmoavaing, prmgt_pmoresgar, prmgt_pnu_asien, prmgt_pnu_folio, prmgt_pnu_oper, prmgt_pnu_part, prmgt_pnu_tomo, prmgt_pnuidegar, 
			prmgt_pse_adic1--, prmgt_pnuide_alf
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_PRMGT

		SET @viErrorTran = @@Error

		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prmgt
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prmgt
		END
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- PRMOC
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmoc
	
	TRUNCATE TABLE dbo.GAR_SICC_PRMOC
	
	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Prmoc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Prmoc
	END

	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Prmoc
		
		INSERT	INTO GAR_SICC_PRMOC 
		SELECT	prmoc_estado, prmoc_pcocaladi, prmoc_pcocalope, prmoc_pno_clien, prmoc_pnu_atras, prmoc_dco_ofici, prmoc_pco_aprob, prmoc_pco_conta, 
			prmoc_pco_desti, prmoc_pco_divis, prmoc_pco_moned, prmoc_pco_ofici, prmoc_pco_oficon, prmoc_pco_plazo, prmoc_pco_poliz, prmoc_pco_produ, 
			prmoc_pcoaltrie, prmoc_pcocalint, prmoc_pcoctamay, prmoc_pcoestlog, prmoc_pcoestpres, prmoc_pcofreflu, prmoc_pcogracon, prmoc_pcoinsagr, 
			prmoc_pcointflu, prmoc_pcolincre, prmoc_pcomonint, prmoc_pditrapro, prmoc_pfe_aprob, prmoc_pfe_const, prmoc_pfe_conta, prmoc_pfe_defin, 
			prmoc_pfeconant, prmoc_pfegentab, prmoc_pfeintpag, prmoc_pfelimide, prmoc_pfeproflu, prmoc_pfepropag, prmoc_pferelint, prmoc_pfeultact, 
			prmoc_pfeultcal, prmoc_pfeultpag, prmoc_pfevenabo, prmoc_pfevenint, prmoc_pfevigtas, prmoc_pmo_girad, prmoc_pmo_origi, prmoc_pmocrepen, 
			prmoc_pmodebpen, prmoc_pmointdia, prmoc_pmointgan, prmoc_pnu_contr, prmoc_pnu_direc, prmoc_pnu_oper, prmoc_pnu_solic, prmoc_psa_actual, 
			prmoc_psa_ayer, prmoc_psa_ideal, prmoc_psaactmea, prmoc_pse_base, prmoc_pse_cei, prmoc_pse_cerrar, prmoc_pse_emple, prmoc_pse_interv, 
			prmoc_pse_proces, prmoc_pse_prorr, prmoc_pse_scacs, prmoc_psearrpag, prmoc_psecobaut, prmoc_psecomadm, prmoc_pseintade, 
			prmoc_psepagpen, prmoc_pseprocj, prmoc_pserectab, prmoc_psesolarr, prmoc_pta_inter, prmoc_pta_plus, prmoc_ptacomadm, prmoc_pvacomadm, 
			prmoc_sco_ident, prmoc_scoanalis, prmoc_scoejecue 
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_PRMOC

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prmoc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prmoc
		END
	END
		
	-------------------------------------------------------------------------------------------------------------------------
	-- PRMSC
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmsc
	
	TRUNCATE TABLE dbo.GAR_SICC_PRMSC
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Prmsc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Prmsc
	END
	
	IF(@viErrorTran = 0) 
	BEGIN
		BEGIN	TRANSACTION TRA_Act_Prmsc
		
		INSERT	INTO dbo.GAR_SICC_PRMSC
		SELECT	prmsc_estado, prmsc_ppasercon, prmsc_pco_conta, prmsc_pco_ident, prmsc_pco_moned, prmsc_pco_msg1, prmsc_pco_msg2, prmsc_pco_ofici, 
			prmsc_pco_produ, prmsc_pco_usuar, prmsc_pcoestrel, prmsc_pcosercon, prmsc_pfe_inici, prmsc_pfe_msg1, prmsc_pfe_msg2, prmsc_pfe_regis, 
			prmsc_pfe_venci, prmsc_pnu_oper, prmsc_pnudocref, prmsc_psesercon
		FROM	GARANTIAS_SICC.dbo.GAR_SICC_PRMSC

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prmsc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prmsc
		END
	END
	
	--FIN RQ: 1-24009801.

	---------------------------------------------------------------------------------------------------------------------------
	---- DEUDORES
	---------------------------------------------------------------------------------------------------------------------------
	--Inicializa el estado de los deudores como Inactivos
	BEGIN	TRANSACTION TRA_Act_Deu
	
	UPDATE	dbo.GAR_DEUDOR SET cod_estado = 2

	SET @viErrorTranMaestra = @@Error
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Deu
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Deu
	END
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		--Actualiza los deudores de operaciones de crédito
		BEGIN	TRANSACTION TRA_Act_Deuop
		
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
		

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Deuop
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Deuop
		END
	
		--Actualiza los deudores de operaciones de crédito
		BEGIN	TRANSACTION TRA_Act_Deuc
		
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Deuc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Deuc
		END
	END


	-------------------------------------------------------------------------------------------------------------------------
	-- OPERACIONES DE CREDITO Y CONTRATOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las operaciones como Canceladas
	BEGIN	TRANSACTION TRA_Act_Oper
	
	UPDATE	dbo.GAR_OPERACION SET cod_estado = 2

	SET @viErrorTranMaestra = @@Error
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Oper
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Oper
	END
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		--Actualiza las operaciones activas
		BEGIN	TRANSACTION TRA_Act_Opera
		
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

		SET @viErrorTran = @@Error
		
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Opera
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Opera
		END

		--Actualiza los contratos vigentes
		BEGIN	TRANSACTION TRA_Act_Contra
		
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Contra
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Contra
		END
	END
	
	-- Actualiza el número de oficina donde se contabilizó el contrato al que pertenece el giro
	BEGIN	TRANSACTION TRA_Act_Oficont
	
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
		
	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Oficont
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Oficont
	END
	
	--Oficina contable de los giros
	BEGIN	TRANSACTION TRA_Act_Oficong
	
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

	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Oficong
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Oficong
	END
	
	--Oficina contable de las operaciones
	BEGIN	TRANSACTION TRA_Act_Oficonop
	
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

	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Oficonop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Oficonop
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS FIDUCIARIAS
	-------------------------------------------------------------------------------------------------------------------------	
	--Actualiza los nombres de los fiadores
	BEGIN	TRANSACTION TRA_Act_Fiador
	
	UPDATE	GGF
	SET		nombre_fiador = MCL.bsmcl_sno_clien
	FROM	dbo.GAR_GARANTIA_FIDUCIARIA GGF
		INNER JOIN	dbo.GAR_SICC_BSMCL MCL
		ON MCL.bsmcl_sco_ident = GGF.Identificacion_Sicc

	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fiador
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fiador
	END
		
	--Inicializa el estado de las garantias fiduciarias como Canceladas
	BEGIN	TRANSACTION TRA_Act_Gfo
	
	UPDATE	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION SET cod_estado = 2

	SET @viErrorTranMaestra = @@Error
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Gfo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Gfo
	END
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN

		--Actualiza el estado de las garantias fiduciarias de operaciones
		BEGIN	TRANSACTION TRA_Act_Gfop
		
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gfop
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Gfop
		END
		
		
		--Actualiza el estado de las garantias fiduciarias de contratos
		BEGIN	TRANSACTION TRA_Act_Gfoc
		
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gfoc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Gfoc
		END
		
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las garantias reales como Canceladas
	BEGIN	TRANSACTION TRA_Act_Gro
	
	UPDATE	dbo.GAR_GARANTIAS_REALES_X_OPERACION SET cod_estado = 2

	SET @viErrorTranMaestra = @@Error
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Gro
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Gro
	END
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		--Actualiza el estado de las garantias reales de operaciones
		BEGIN	TRANSACTION TRA_Act_Grop

		UPDATE	GRO
		SET		GRO.cod_estado = 1
		FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			INNER JOIN dbo.GAR_OPERACION GO1
			ON GO1.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = GRO.cod_garantia_real
		WHERE	GO1.cod_estado = 1
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Grop
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Grop
		END

		--Actualiza el estado de las garantias reales de contratos
		BEGIN	TRANSACTION TRA_Act_Grocv

		UPDATE	GRO
		SET		GRO.cod_estado = 1
		FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			INNER JOIN dbo.GAR_OPERACION GO1
			ON GO1.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = GRO.cod_garantia_real
		WHERE	GO1.cod_estado = 1
			AND GO1.num_operacion IS NULL
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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Grocv
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Grocv
		END

	END

	--INICIO RQ: 1-21537644. Se actualizan algunos datos de la relación entre la garantía real y la operación/contrato a la que este asociada.
	
	--Se actualizan los datos de las garantías reales asociadas a operaciones directas
	BEGIN TRANSACTION TRA_Act_Garoper

	UPDATE  GRO
	SET     GRO.fecha_constitucion = CASE 
										WHEN GSP.prmoc_pfe_const = 0 THEN NULL
										WHEN (ISDATE(CONVERT(VARCHAR(8),GSP.prmoc_pfe_const)) = 1) 
											  
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GSP.prmoc_pfe_const))
										ELSE NULL
									 END,
			GRO.fecha_vencimiento = CASE 
										WHEN GSP.prmoc_pfe_defin = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),GSP.prmoc_pfe_defin)) = 1) 
											  AND (LEN(GSP.prmoc_pfe_defin) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GSP.prmoc_pfe_defin))
										ELSE NULL
									 END,
			GRO.cod_grado_gravamen = SPR.prmgt_pco_grado, 
			GRO.fecha_prescripcion = CASE 
										WHEN SPR.prmgt_pfe_prescr = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),SPR.prmgt_pfe_prescr)) = 1) 
											  AND (LEN(SPR.prmgt_pfe_prescr) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), SPR.prmgt_pfe_prescr))
										ELSE NULL
									 END,
			GRO.cod_tipo_documento_legal =	CASE GGR.cod_tipo_garantia_real 
												WHEN 1 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 1
																WHEN 2 THEN 2
																WHEN 3 THEN 3
																WHEN 4 THEN 4
																ELSE NULL
															END
												WHEN 2 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 5
																WHEN 2 THEN 6
																WHEN 3 THEN 7
																WHEN 4 THEN 8
																ELSE NULL
															END
												WHEN 3 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 9
																WHEN 2 THEN 10
																WHEN 3 THEN 11
																WHEN 4 THEN 12
																ELSE NULL
															END
												ELSE NULL
											END
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GAR_OPERACION GOP
		ON GOP.cod_operacion = GRO.cod_operacion
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR
		ON GGR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_SICC_PRMOC GSP
		ON GSP.prmoc_pco_ofici = GOP.cod_oficina
		AND GSP.prmoc_pco_moned = GOP.cod_moneda
		AND GSP.prmoc_pco_produ = GOP.cod_producto
		AND GSP.prmoc_pnu_oper = GOP.num_operacion
		INNER JOIN dbo.GAR_SICC_PRMGT SPR
		ON SPR.prmgt_pco_ofici = GSP.prmoc_pco_ofici
		AND SPR.prmgt_pco_moned = GSP.prmoc_pco_moned
		AND SPR.prmgt_pco_produ = GSP.prmoc_pco_produ
		AND SPR.prmgt_pnu_oper = GSP.prmoc_pnu_oper
	WHERE	GOP.num_contrato = 0
		AND GOP.num_operacion IS NOT NULL
		AND GSP.prmoc_pnu_contr = 0
		AND GSP.prmoc_pse_proces = 1		--Operaciones activas
		AND ((GSP.prmoc_pcoctamay < 815)
			OR (GSP.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND GSP.prmoc_estado = 'A'	
		AND GGR.cod_clase_garantia = SPR.prmgt_pcoclagar
		AND GGR.Identificacion_Sicc = SPR.prmgt_pnuidegar
		AND SPR.prmgt_estado = 'A'

	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Garoper
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Garoper
	END


	--Se actualizan los datos de las garantías reales asociadas a contratos
	BEGIN TRANSACTION TRA_Act_Garcontr

	UPDATE  GRO
	SET     GRO.fecha_constitucion = CASE 
										WHEN GSP.prmca_pfe_const = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),GSP.prmca_pfe_const)) = 1) 
											  AND (LEN(GSP.prmca_pfe_const) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GSP.prmca_pfe_const))
										ELSE NULL
									 END,
			GRO.fecha_vencimiento = CASE 
										WHEN GSP.prmca_pfe_defin = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),GSP.prmca_pfe_defin)) = 1) 
											  AND (LEN(GSP.prmca_pfe_defin) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), GSP.prmca_pfe_defin))
										ELSE NULL
									 END,
			GRO.cod_grado_gravamen = SPR.prmgt_pco_grado, 
			GRO.fecha_prescripcion = CASE 
										WHEN SPR.prmgt_pfe_prescr = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),SPR.prmgt_pfe_prescr)) = 1) 
											  AND (LEN(SPR.prmgt_pfe_prescr) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), SPR.prmgt_pfe_prescr))
										ELSE NULL
									 END,
			GRO.cod_tipo_documento_legal =	CASE GGR.cod_tipo_garantia_real 
												WHEN 1 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 1
																WHEN 2 THEN 2
																WHEN 3 THEN 3
																WHEN 4 THEN 4
																ELSE NULL
															END
												WHEN 2 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 5
																WHEN 2 THEN 6
																WHEN 3 THEN 7
																WHEN 4 THEN 8
																ELSE NULL
															END
												WHEN 3 THEN CASE SPR.prmgt_pco_grado
																WHEN 1 THEN 9
																WHEN 2 THEN 10
																WHEN 3 THEN 11
																WHEN 4 THEN 12
																ELSE NULL
															END
												ELSE NULL
											END
	FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
		INNER JOIN dbo.GAR_OPERACION GOP
		ON GOP.cod_operacion = GRO.cod_operacion
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR
		ON GGR.cod_garantia_real = GRO.cod_garantia_real
		INNER JOIN dbo.GAR_SICC_PRMCA GSP
		ON GSP.prmca_pco_ofici = GOP.cod_oficina
		AND GSP.prmca_pco_moned = GOP.cod_moneda
		AND GSP.prmca_pco_produc = GOP.cod_producto
		AND GSP.prmca_pnu_contr = GOP.num_contrato
		INNER JOIN dbo.GAR_SICC_PRMGT SPR
		ON SPR.prmgt_pco_ofici = GSP.prmca_pco_ofici
		AND SPR.prmgt_pco_moned = GSP.prmca_pco_moned
		AND SPR.prmgt_pco_produ = 10
		AND SPR.prmgt_pnu_oper = GSP.prmca_pnu_contr
	WHERE	GOP.num_contrato > 0
		AND GOP.num_operacion IS NULL
		AND GGR.cod_clase_garantia = SPR.prmgt_pcoclagar
		AND GGR.Identificacion_Sicc = SPR.prmgt_pnuidegar
		AND SPR.prmgt_estado = 'A'

	SET @viErrorTran = @@Error
	
	IF(@viErrorTran = 0)
	BEGIN
		COMMIT TRANSACTION TRA_Act_Garcontr
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Garcontr
	END

	--FIN RQ: 1-21537644.
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS DE VALOR
	-------------------------------------------------------------------------------------------------------------------------	
	--Inicializa el estado de las garantias de valor como Canceladas
	BEGIN	TRANSACTION TRA_Act_Gvo
	
	UPDATE	dbo.GAR_GARANTIAS_VALOR_X_OPERACION SET cod_estado = 2

	SET @viErrorTranMaestra = @@Error
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Gvo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Gvo
	END
	
	IF(@viErrorTranMaestra = 0) 
	BEGIN
		--Actualiza el estado de las garantias de valor de operaciones
		BEGIN	TRANSACTION TRA_Act_Gvop

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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gvop
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Gvop
		END

		--Actualiza el estado de las garantias de valor de contratos
		BEGIN	TRANSACTION TRA_Act_Gvoc

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

		SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Gvoc
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Gvoc
		END

	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- Elimina las hipotecas duplicadas
	-------------------------------------------------------------------------------------------------------------------------	
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
						AND GGR.cod_partido = @nPartido 						AND GGR.numero_finca = @strFinca 
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
	
END


