USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_migrar_garantias', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_migrar_garantias;
GO

CREATE PROCEDURE [dbo].[pa_migrar_garantias]
AS
BEGIN
	
/******************************************************************
	<Nombre>pa_migrar_garantias</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de garantías de las nuevas operaciones de crédito y de los nuevos contratos del 
			     SICC a la base de datos GARANTIAS. Además, actualiza la información de las operaciones y de los 
			     contratos existentes actualmente.
	</Descripción>
	<Entradas></Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.7</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>18/06/2008</Fecha>
			<Descripción>
				Se da un problema de comparación de datos de tipos diferentes, esto a la hora en que
                habilita las garantías fiduciarias, reales y de valor de los contratos que tienen giros activos.
			</Descripción>
		</Cambio>
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
			<Requerimiento>Según correo recibido el 10/10/2012, de Yamileth Lizano Villegas, a petición de José Guzman Granados</Requerimiento>
			<Fecha>10/10/2012</Fecha>
			<Descripción>Se elimina de la excepción de operaciones, durante el proceso de relpica de las 
                         garantías reales la operación con el consecutivo 56272 ( 1 - 220 - 2 - 2 - 5812600)
	        </Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>SIEBEL No. 1-23816691</Requerimiento>
			<Fecha>29/07/2013</Fecha>
			<Descripción>
				Se agrega la sección correspondiente al ajuste del indicador de inscripción, tomando el dato de la estructura PRMRI del BNX
				y asignandolo a la garantía correspondiente en el sistema de garantías.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambios de almacenado, búsqueda y extracción de datos, Sibel: 1 - 23923921</Requerimiento>
			<Fecha>01/10/2013</Fecha>
			<Descripción>
				Se ajusta la forma en que se compara la identificación de la garantía entre el SICC y el
				sistema de garantías, se cambia de una comparación numperica a una de texto.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-21537427.
					Req_Garantia Real, Siebel No. 1-21537644.
			</Requerimiento>
			<Fecha>20/06/2013</Fecha>
			<Descripción>
					Se agregan las sentencias que permiten clasificar los avalúos, de acuerdo a si se trata del más reciente,
					el penúltimo o si pertence al histórico.
					También se agrega el mapeo del tipo de documento legal, según el código de grado de gravamen indicado en el SICC, así mismo,
					el mapeo de la fecha de constitución, fecha de prescripción y de vencimiento de las garantías.
			</Descripción>
		</Cambio>
        <Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Cambio validación y código de clase 18, Siebel 1-23969281.</Requerimiento>
			<Fecha>29/10/2013</Fecha>
			<Descripción>
				Se ajusta la forma en que se clasifican las garantías reales del tipo hipoteca común y cédula hipotecaria,
				esto con el fin de que las garantías con clase 18 sean clasificadas como cédula hipotecaria y no como hipoteca común.
			</Descripción>
		</Cambio>
        <Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					026 Req_Ajuste de campos para correcto funcionamiento del bloque 1, Sibel No. 1-24009801.
			</Requerimiento>
			<Fecha>04/11/2013</Fecha>
			<Descripción>
				Se elimina la restricción de que los siguientes consecutivos de operaciones no sean replicadas, 
				esto al momento de obtener las garantías reales asociadas, a saber:
				 21507 = 205-1-2-20965
				 7831  = 960-1-2-5774925
				 7819  = 483-1-2-5774907
				 5120  = 311-1-2-5778625
				 21390 = 270-1-2-11488
				 39885 = 235-1-2-5795536
				 42596 = 341-1-2-5798415
				 42584 = 949-1-2-5798407
				 5420  = 297-1-2-5778401/2401008
				 8008  = 215-1-2-5774559/2400891
				 56272 = 220-2-2-5812600
				 
				 Los siguientes consecutivos provocan un error al momento de migrar, pues los mismos son giros que tienen asignada el 
				 número de finca en la idendificación de la garantía, cuando la norma es que sea el número del contrato, por este motivo
				 se mantienen en la lista de exclusión:
				 
 				 19627 = 342-1-2-4728/2400118
				 19801 = 342-1-2-4740/2400118

			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Cambios en la Extracción de los campos % de Aceptación, Indicador de Inscripción 
				y Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel 1-24206841.
			</Requerimiento>
			<Fecha>24/03/2014</Fecha>
			<Descripción>
				Se agregan las sentencias necesarias para actualizar el valor del campo correspondiente a la fecha
				de valuación registrada en el SICC, esto dentro de la tabla de valuaciones reales.
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
					Ajuste del campo Fecha Valuación y Fecha Valuación SICC, Siebel No. 1-24315781.
			</Requerimiento>
			<Fecha>18/05/2014</Fecha>
			<Descripción>
					Se modifica la forma en como se replican los avalúos de las garantías reales.
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
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Actualización del indicador de inscripción, Siebel No. 1-24359411.
			</Requerimiento>
			<Fecha>30/05/2014</Fecha>
			<Descripción>
					Se realiza una ajuste en las sentencias correspondientes a la actualización del 
					indicador de inscripción de las garantías asociadas a los contratos. 
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
	
	--INICIO RQ: 1-23816691 Y 1-24331191.
	
	DECLARE	 @vdFechaActualSinHora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones
		@viErrorTran INT, -- Almacena el código del error generado durante la transacción
		@viFechaActualEntera INT --Corresponde al a fecha actual en formato numérico.
	
	
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
	SET	@vdFechaActualSinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	--FIN RQ: 1-23816691 Y 1-24331191.

	-------------------------------------------------------------------------------------------------------------------------
	-- PRMOC
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmoc
	
	TRUNCATE TABLE	dbo.GAR_SICC_PRMOC
	
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
	-- PRMRI
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN TRANSACTION TRA_Eli_Prmri
		
	--Borra la informacion de PRMRI
	TRUNCATE TABLE dbo.GAR_SICC_PRMRI

	SET @viErrorTran = @@Error
	
		IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Eli_Prmri
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Eli_Prmri
	END

	IF(@viErrorTran = 0) 
	BEGIN
		--Se actualiza la estructura dentro del sistema de garantías
		BEGIN TRANSACTION TRA_Act_Prmri
		
		INSERT	INTO dbo.GAR_SICC_PRMRI 
		SELECT	my_aa, prmri_estado, prmri_pco_cod01, prmri_pno_comen, prmri_pnuide_alf, prmri_pco_conta, prmri_pco_moned, prmri_pco_ofici, prmri_pco_produ, 
				prmri_pcoclagar, prmri_pcoestins, prmri_pcoofireg, prmri_pcousureg, prmri_pfe_regis, prmri_pferegins, prmri_pnu_asien, prmri_pnu_consec, prmri_pnu_opera, 
				prmri_pnu_part, prmri_pnu_tomo, prmri_pnuidegar, prmri_pnusecuen, prmri_pnusubsec, prmri_sco_ident, prmri_scoideabo, prmri_scoidedue
		FROM    GARANTIAS_SICC.dbo.GAR_SICC_PRMRI 

		SET @viErrorTran = @@Error

		IF(@viErrorTran = 0) 
		BEGIN
			COMMIT TRANSACTION TRA_Act_Prmri
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION TRA_Act_Prmri
		END
	END
	

	-------------------------------------------------------------------------------------------------------------------------
	-- PRMGT
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmgt
	
	TRUNCATE TABLE	dbo.GAR_SICC_PRMGT
	
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
	-- PRMCA
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN	TRANSACTION TRA_Eli_Prmca
	
	TRUNCATE TABLE	dbo.GAR_SICC_PRMCA
	
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
	

	---------------------------------------------------------------------------------------------------------------------------
	---- DEUDORES DE OPERACIONES
	---------------------------------------------------------------------------------------------------------------------------
	BEGIN TRANSACTION TRA_Ins_Deud_Op
	
	--Inserta los deudores nuevos de operaciones de crédito existentes en SICC
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
		INNER JOIN	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
		ON MCL.bsmcl_sco_ident = MOC.prmoc_sco_ident
	WHERE	MOC.prmoc_pse_proces = 1
		AND MOC.prmoc_estado = 'A'
		AND MCL.bsmcl_estado = 'A'
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_DEUDOR GDE
						WHERE	GDE.Identificacion_Sicc = MOC.prmoc_sco_ident)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Deud_Op
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Deud_Op
	END
	
	-----------------------------------------------------------------------------------------------------------------------
	--DEUDORES DE CONTRATOS
	-----------------------------------------------------------------------------------------------------------------------
	BEGIN TRANSACTION TRA_Ins_Deud_Ca
	
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
		INNER JOIN GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
		ON MCL.bsmcl_sco_ident = MCA.prmca_pco_ident
	WHERE	MCA.prmca_estado = 'A'
		AND MCL.bsmcl_estado = 'A'
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_DEUDOR GDE
						WHERE	GDE.Identificacion_Sicc = MCA.prmca_pco_ident)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Deud_Ca
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Deud_Ca
	END
	
	
	-------------------------------------------------------------------------------------------------------------------------
	-- OPERACIONES DE CREDITO 
	-------------------------------------------------------------------------------------------------------------------------	
	BEGIN TRANSACTION TRA_Act_Op
	
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
					WHERE	GDE.cedula_deudor = MOC.prmoc_sco_ident)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Op
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Op
	END
	
	--Inserta las operaciones de crédito nuevas existentes en SICC
	BEGIN TRANSACTION TRA_Ins_Op
	
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
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Op
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Op
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Actualiza la información de las operaciones de crédito
	BEGIN TRANSACTION TRA_Act_Ca
	
	UPDATE	dbo.GAR_OPERACION
	SET		fecha_constitucion	= CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),1,4) + '-' + 
								  SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),5,2) + '-' + 
						          SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),7,2)),
		cedula_deudor			= MCA.prmca_pco_ident,  
		fecha_vencimiento		= CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),1,4) + '-' + 
								  SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),5,2) + '-' + 
								  SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),7,2)) --RQ: 1-21537644. Se agrega la actualización de este campo.
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
					WHERE	GDE.cedula_deudor = MCA.prmca_pco_ident)
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Ca
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Ca
	END
	
	--Inserta los contratos nuevos existentes en SICC
	BEGIN TRANSACTION TRA_Ins_Ca
	
	INSERT	INTO dbo.GAR_OPERACION
	(
		cod_contabilidad,
		cod_oficina,
		cod_moneda,
		cod_producto,
		num_contrato,
		fecha_constitucion,
		cedula_deudor, --INICIO RQ: 1-21537644 Agregar campo
		fecha_vencimiento -- FIN RQ: 1-2153764
	)
	SELECT 
		MCA.prmca_pco_conta,
		MCA.prmca_pco_ofici,
		MCA.prmca_pco_moned,
		MCA.prmca_pco_produc,
		MCA.prmca_pnu_contr,
		CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),1,4) + '-' + 
		                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),5,2) + '-' + 
		                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_const),7,2)) 
		AS prmca_pfe_const,
		MCA.prmca_pco_ident, --INICIO RQ: 1-21537644 Agregar campo
		CONVERT(DATETIME,SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),1,4) + '-' + 
		                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),5,2) + '-' + 
		                 SUBSTRING(CONVERT(VARCHAR(8), MCA.prmca_pfe_defin),7,2)) 
		AS prmca_pfe_defin
		-- FIN RQ: 1-2153764
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Ca
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Ca
	END

	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS FIDUCIARIAS
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Fiduciarias de las Operaciones de Crédito
	BEGIN TRANSACTION TRA_Ins_Ggfo
	
	INSERT INTO dbo.GAR_GARANTIA_FIDUCIARIA 
	(
		cod_tipo_garantia, 
		cod_clase_garantia, 
		cedula_fiador, 
		nombre_fiador, 
		cod_tipo_fiador,
		Identificacion_Sicc
	)
	SELECT	DISTINCT
		1 AS cod_tipo_garantia,
		MGT.prmgt_pcoclagar AS cod_clase_garantia,
		MGT.prmgt_pnuidegar AS cedula_fiador,
		MCL.bsmcl_sno_clien AS nombre_fiador,
		MCL.bsmcl_scotipide AS cod_tipo_fiador,
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM dbo.GAR_SICC_PRMGT MGT
		INNER JOIN	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
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
						AND GO1.cod_contabilidad = MGT.prmgt_pco_conta)
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_FIDUCIARIA	GGF
						WHERE	GGF.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Ggfo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Ggfo
	END
	
	--Garantias Fiduciarias de Contrato
	BEGIN TRANSACTION TRA_Ins_Ggfc
	
	INSERT INTO dbo.GAR_GARANTIA_FIDUCIARIA 
	(
		cod_tipo_garantia, 
		cod_clase_garantia, 
		cedula_fiador, 
		nombre_fiador, 
		cod_tipo_fiador,
		Identificacion_Sicc
	)
	SELECT	DISTINCT
		1 AS cod_tipo_garantia,
		MGT.prmgt_pcoclagar AS cod_clase_garantia,
		MGT.prmgt_pnuidegar AS cedula_fiador,
		MCL.bsmcl_sno_clien AS nombre_fiador,
		MCL.bsmcl_scotipide AS cod_tipo_fiador,
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
		INNER JOIN	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
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


	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Ggfc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Ggfc
	END
		
	-----------------------------------------------------------------------------
	--Inserta las Garantias Fiduciarias de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Fiduciarias X Operaciones
	BEGIN TRANSACTION TRA_Ins_Gfo
	
	INSERT INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_fiduciaria, 
		cod_operacion_especial, 
		cod_tipo_acreedor, 
		cedula_acreedor, 
		porcentaje_responsabilidad, 
		monto_mitigador
	) 
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGF.cod_garantia_fiduciaria,
		0 AS cod_operacion_especial,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		100 AS porcentaje_responsabilidad,
		GO1.saldo_actual AS monto_mitigador
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
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = 0
		AND EXISTS (SELECT	1
					FROM	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
					WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
						AND MCL.bsmcl_estado = 'A')
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						WHERE	GFO.cod_operacion = GO1.cod_operacion
							AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gfo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gfo
	END
	
	--Garantias Fiduciarias X Contratos
	BEGIN TRANSACTION TRA_Ins_Gfc
	
	INSERT INTO dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_fiduciaria, 
		cod_operacion_especial, 
		cod_tipo_acreedor, 
		cedula_acreedor, 
		porcentaje_responsabilidad, 
		monto_mitigador
	) 
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGF.cod_garantia_fiduciaria,
		0 AS cod_operacion_especial,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		100 AS porcentaje_responsabilidad,
		GO1.saldo_actual AS monto_mitigador
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
					FROM	GARANTIAS_SICC.dbo.GAR_SICC_BSMCL MCL
					WHERE	MCL.bsmcl_sco_ident = MGT.prmgt_pnuidegar
						AND MCL.bsmcl_estado = 'A')
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
						WHERE	GFO.cod_operacion = GO1.cod_operacion
							AND GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria)
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gfc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gfc
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Garantias Reales de Operaciones
	BEGIN TRANSACTION TRA_Ins_Grho
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grho
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grho
	END
	
	--Garantias Reales de Contrato
	BEGIN TRANSACTION TRA_Ins_Grhc
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grhc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grhc
	END

	-----------------------------------------------------------------------------
	--Inserta las Cédulas Hipotecarias Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	BEGIN TRANSACTION TRA_Ins_Grcho
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29
		AND MGT.prmgt_pcotengar = 1
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
						AND MGT.prmgt_pco_moned	= GO1.cod_moneda
						AND MGT.prmgt_pco_produ	= GO1.cod_producto
						AND MGT.prmgt_pnu_oper = GO1.num_operacion
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_REAL GGR
						WHERE	GGR.cod_tipo_garantia_real = 2
							AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
							AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grcho
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grcho
	END
	
	--Garantias Reales de Contrato
	BEGIN TRANSACTION TRA_Ins_Grchc
	
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
		Identificacion_Sicc
	)
	SELECT DISTINCT
		2 AS cod_tipo_garantia,
		MGT.prmgt_pcoclagar AS cod_clase_garantia,
		1 AS cod_tipo_garantia_real,
		MGT.prmgt_pnu_part AS cod_partido,
		MGT.prmgt_pnuidegar AS numero_finca,
		MGT.prmgt_pco_grado AS cod_grado,
		NULL AS cedula_hipotecaria,
		NULL AS cod_clase_bien,
		NULL AS num_placa_bien,
		NULL AS cod_tipo_bien,
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
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
							AND GGR.cod_grado = CONVERT(VARCHAR(2), MGT.prmgt_pco_grado)
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grchc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grchc
	END

	--INICIO RQ: Siebel 1-24103601. Se ajusta la migración de la clase 18.
	--Garantias Reales de Operaciones
	BEGIN TRANSACTION TRA_Ins_Gcho
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = 18
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
						AND MGT.prmgt_pco_moned	= GO1.cod_moneda
						AND MGT.prmgt_pco_produ	= GO1.cod_producto
						AND MGT.prmgt_pnu_oper = GO1.num_operacion
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_REAL GGR
						WHERE	GGR.cod_tipo_garantia_real = 2
							AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
							AND GGR.cod_partido = MGT.prmgt_pnu_part
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gcho
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gcho
	END
	
	--Garantias Reales de Contrato
	BEGIN TRANSACTION TRA_Ins_Gchc
	
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
		Identificacion_Sicc
	)
	SELECT DISTINCT
		2 AS cod_tipo_garantia,
		MGT.prmgt_pcoclagar AS cod_clase_garantia,
		1 AS cod_tipo_garantia_real,
		MGT.prmgt_pnu_part AS cod_partido,
		MGT.prmgt_pnuidegar AS numero_finca,
		MGT.prmgt_pco_grado AS cod_grado,
		NULL AS cedula_hipotecaria,
		NULL AS cod_clase_bien,
		NULL AS num_placa_bien,
		NULL AS cod_tipo_bien,
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
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
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gchc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gchc
	END

	--FIN REQ: Siebel 1-24103601. Se ajusta la migración de la clase 18.  
	
	-----------------------------------------------------------------------------
	--Inserta las Prendas Nuevas existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Reales de Operaciones
	BEGIN TRANSACTION TRA_Ins_Ggrpo
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
		AND EXISTS (SELECT	1
					FROM	dbo.GAR_OPERACION GO1
					WHERE	MGT.prmgt_pco_ofici	= GO1.cod_oficina
						AND MGT.prmgt_pco_moned	= GO1.cod_moneda
						AND MGT.prmgt_pco_produ	= GO1.cod_producto
						AND MGT.prmgt_pnu_oper = GO1.num_operacion
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad)
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_REAL GGR
						WHERE	GGR.cod_tipo_garantia_real = 3
							AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
							AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Ggrpo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Ggrpo
	END
	
	--Garantias Reales de Contrato
	BEGIN TRANSACTION TRA_Ins_Ggrpc
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	FROM	dbo.GAR_SICC_PRMGT MGT
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Ggrpc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Ggrpc
	END
	
	-----------------------------------------------------------------------------
	--Inserta las Garantias Reales de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Hipotecas de operaciones crediticias
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
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 1
			WHEN MGT.prmgt_pco_grado = 2 THEN 2
			WHEN MGT.prmgt_pco_grado = 3 THEN 3
			WHEN MGT.prmgt_pco_grado = 4 THEN 4
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
		AND GO1.cod_operacion NOT IN (19627, 19801)
		
	UNION ALL
	
	--Hipotecas de contratos
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 1
			WHEN MGT.prmgt_pco_grado = 2 THEN 2
			WHEN MGT.prmgt_pco_grado = 3 THEN 3
			WHEN MGT.prmgt_pco_grado = 4 THEN 4
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
		AND GO1.num_operacion IS NULL
		AND GO1.cod_operacion NOT IN (19627, 19801)	
	
	--Se insertan las hipotecas nuevas asocidas 
	BEGIN TRANSACTION TRA_Ins_Groho
	
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
		fecha_prescripcion
	)
	SELECT	DISTINCT
		TMP.cod_operacion,
		TMP.cod_garantia_real,
		TMP.cod_tipo_documento_legal, 
		TMP.monto_mitigador,
		100 AS porcentaje_responsabilidad,
		TMP.cod_grado_gravamen,
		0 AS cod_operacion_especial,
		TMP.fecha_constitucion,
		TMP.fecha_vencimiento,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
		TMP.cod_tenencia,
		TMP.cod_moneda,
		TMP.fecha_prescripcion
	FROM	@TMP_GARANTIAS_REALES TMP
	WHERE	NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						WHERE	GRO.cod_operacion = TMP.cod_operacion
							AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Groho
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Groho
	END

	--Se elimina el contenido de la tabla temporal
	DELETE FROM @TMP_GARANTIAS_REALES

	--Cédulas Hipotecarias de operaciones crediticias
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
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 5
			WHEN MGT.prmgt_pco_grado = 2 THEN 6
			WHEN MGT.prmgt_pco_grado = 3 THEN 7
			WHEN MGT.prmgt_pco_grado = 4 THEN 8
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
	WHERE	MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = 18 --RQ: 1-23969281. Se agrega el código 18.
		AND GO1.cod_operacion NOT IN (19627, 19801)
		
	UNION ALL
	
	--Cédulas Hipotecarias de contratos
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 5
			WHEN MGT.prmgt_pco_grado = 2 THEN 6
			WHEN MGT.prmgt_pco_grado = 3 THEN 7
			WHEN MGT.prmgt_pco_grado = 4 THEN 8
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND MGT.prmgt_pcoclagar = 18 --RQ: 1-23969281. Se agrega el código 18.
		AND GO1.num_operacion IS NULL
		AND GO1.cod_operacion NOT IN (19627, 19801)	
	
	UNION ALL
	
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 5
			WHEN MGT.prmgt_pco_grado = 2 THEN 6
			WHEN MGT.prmgt_pco_grado = 3 THEN 7
			WHEN MGT.prmgt_pco_grado = 4 THEN 8
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND GO1.cod_operacion NOT IN (19627, 19801)
		
	UNION ALL
	
	--Cédulas Hipotecarias de contratos
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 5
			WHEN MGT.prmgt_pco_grado = 2 THEN 6
			WHEN MGT.prmgt_pco_grado = 3 THEN 7
			WHEN MGT.prmgt_pco_grado = 4 THEN 8
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		fecha_prescripcion
	)
	SELECT	DISTINCT
		TMP.cod_operacion,
		TMP.cod_garantia_real,
		TMP.cod_tipo_documento_legal, 
		TMP.monto_mitigador,
		100 AS porcentaje_responsabilidad,
		TMP.cod_grado_gravamen,
		0 AS cod_operacion_especial,
		TMP.fecha_constitucion,
		TMP.fecha_vencimiento,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
		TMP.cod_tenencia,
		TMP.cod_moneda,
		TMP.fecha_prescripcion
	FROM	@TMP_GARANTIAS_REALES TMP
	WHERE	NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						WHERE	GRO.cod_operacion = TMP.cod_operacion
							AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grocho
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grocho
	END
	
	--Se elimina el contenido de la tabla temporal
	DELETE FROM @TMP_GARANTIAS_REALES

	--Prendas de operaciones crediticias
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
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 9
			WHEN MGT.prmgt_pco_grado = 2 THEN 10
			WHEN MGT.prmgt_pco_grado = 3 THEN 11
			WHEN MGT.prmgt_pco_grado = 4 THEN 12
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
		AND GO1.cod_operacion NOT IN (19627, 19801)
		
	UNION ALL
	
	--Prendas de contratos
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGR.cod_garantia_real,
		--INICIO RQ: 1-21537644 Agregar campo
		CASE 
			WHEN MGT.prmgt_pco_grado = 1 THEN 9
			WHEN MGT.prmgt_pco_grado = 2 THEN 10
			WHEN MGT.prmgt_pco_grado = 3 THEN 11
			WHEN MGT.prmgt_pco_grado = 4 THEN 12
			ELSE NULL			
		END AS cod_tipo_documento_legal, -- FIN RQ: 1-2153764
		GO1.saldo_actual AS monto_mitigador,
		MGT.prmgt_pco_grado AS cod_grado_gravamen,
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
		AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
		AND GO1.num_operacion IS NULL
		AND GO1.cod_operacion NOT IN (19627, 19801)	
	

	--Se insertan las prendas nuevas
	BEGIN TRANSACTION TRA_Ins_Gropo
	
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
		fecha_prescripcion
	)
	SELECT	DISTINCT
		TMP.cod_operacion,
		TMP.cod_garantia_real,
		TMP.cod_tipo_documento_legal, 
		TMP.monto_mitigador,
		100 AS porcentaje_responsabilidad,
		TMP.cod_grado_gravamen,
		0 AS cod_operacion_especial,
		TMP.fecha_constitucion,
		TMP.fecha_vencimiento,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		(SELECT TOP 1 cod_liquidez FROM @TMP_GARANTIAS_REALES WHERE cod_operacion = TMP.cod_operacion AND cod_garantia_real = TMP.cod_garantia_real) AS cod_liquidez,
		TMP.cod_tenencia,
		TMP.cod_moneda,
		TMP.fecha_prescripcion
	FROM	@TMP_GARANTIAS_REALES TMP
	WHERE	NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						WHERE	GRO.cod_operacion = TMP.cod_operacion
							AND GRO.cod_garantia_real = TMP.cod_garantia_real)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gropo
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gropo
	END
		
	--INICIO RQ: 1-21537644. Se actualizan algunos datos de la relación entre la garantía real y la operación/contrato a la que este asociada.
	
	--Se actualizan los datos de las garantías reales asociadas a operaciones directas
	BEGIN TRANSACTION TRA_Act_Garoper

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
			GRO.cod_grado_gravamen = MGT.prmgt_pco_grado, 
			GRO.fecha_prescripcion = CASE 
										WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
										WHEN ((ISDATE(CONVERT(VARCHAR(8),MGT.prmgt_pfe_prescr)) = 1) 
											  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
											  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
										ELSE NULL
									 END,
			GRO.cod_tipo_documento_legal =	CASE GGR.cod_tipo_garantia_real 
												WHEN 1 THEN CASE MGT.prmgt_pco_grado
																WHEN 1 THEN 1
																WHEN 2 THEN 2
																WHEN 3 THEN 3
																WHEN 4 THEN 4
																ELSE NULL
															END
												WHEN 2 THEN CASE MGT.prmgt_pco_grado
																WHEN 1 THEN 5
																WHEN 2 THEN 6
																WHEN 3 THEN 7
																WHEN 4 THEN 8
																ELSE NULL
															END
												WHEN 3 THEN CASE MGT.prmgt_pco_grado
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
		AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
		AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		AND MGT.prmgt_estado = 'A'

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
			GRO.cod_grado_gravamen = MGT.prmgt_pco_grado, 
			GRO.fecha_prescripcion = CASE 
									WHEN MGT.prmgt_pfe_prescr = 0 THEN NULL
									WHEN ((ISDATE(CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr)) = 1) 
										  AND (LEN(MGT.prmgt_pfe_prescr) = 8)) 
										  THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), MGT.prmgt_pfe_prescr))
									ELSE NULL
								 END,
			GRO.cod_tipo_documento_legal = CASE GGR.cod_tipo_garantia_real 
											WHEN 1 THEN CASE MGT.prmgt_pco_grado
															WHEN 1 THEN 1
															WHEN 2 THEN 2
															WHEN 3 THEN 3
															WHEN 4 THEN 4
															ELSE NULL
														END
											WHEN 2 THEN CASE MGT.prmgt_pco_grado
															WHEN 1 THEN 5
															WHEN 2 THEN 6
															WHEN 3 THEN 7
															WHEN 4 THEN 8
															ELSE NULL
														END
											WHEN 3 THEN CASE MGT.prmgt_pco_grado
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
		AND GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
		AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
		AND MGT.prmgt_estado = 'A'

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
	--Garantias Valor de Operaciones
	BEGIN TRANSACTION TRA_Ins_Grvop
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	
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
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIA_VALOR GGV
						WHERE	GGV.Identificacion_Sicc = MGT.prmgt_pnuidegar)

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grvop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grvop
	END

	
	--Garantias Valor de Contratos
	BEGIN TRANSACTION TRA_Ins_Grvoc
	
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
		Identificacion_Sicc
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
		MGT.prmgt_pnuidegar AS Identificacion_Sicc
	
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Grvoc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Grvoc
	END
	
	-----------------------------------------------------------------------------
	--Inserta las Garantias de Valor de las Operaciones Crediticias Nuevas 
	--y de los Contratos Nuevos existentes en SICC
	-----------------------------------------------------------------------------
	--Garantias Valor X Operaciones
	BEGIN TRANSACTION TRA_Ins_Gvoop
	
	INSERT	INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_valor, 
		monto_mitigador,
		cod_tipo_acreedor, 
		cedula_acreedor, 
		cod_operacion_especial, 
		porcentaje_responsabilidad 
	) 
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGV.cod_garantia_valor,
		GO1.saldo_actual AS monto_mitigador,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		0 AS cod_operacion_especial,
		100 AS porcentaje_responsabilidad
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
		AND NOT EXISTS (SELECT	1
						FROM	dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
						WHERE	GVO.cod_operacion = GO1.cod_operacion
							AND GVO.cod_garantia_valor = GGV.cod_garantia_valor)

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gvoop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gvoop
	END

	--Garantias Valor X Contratos
	BEGIN TRANSACTION TRA_Ins_Gvooc
	
	INSERT	INTO dbo.GAR_GARANTIAS_VALOR_X_OPERACION
	(
		cod_operacion, 
		cod_garantia_valor, 
		monto_mitigador,
		cod_tipo_acreedor, 
		cedula_acreedor, 
		cod_operacion_especial, 
		porcentaje_responsabilidad 
	) 
	SELECT	DISTINCT
		GO1.cod_operacion,
		GGV.cod_garantia_valor,
		GO1.saldo_actual AS monto_mitigador,
		2 AS cod_tipo_acreedor,
		'4000000019' AS cedula_acreedor,
		0 AS cod_operacion_especial,
		100 AS porcentaje_responsabilidad
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Gvooc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Gvooc
	END
	
	-------------------------------------------------------------------------------------------------------------------------
	-- VALUACIONES DE GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--INICIO RQ: 1-24315781 Y 1-24331191. Se migra el avalúo más reciente para una misma garantía registrada en el Maestro de Garantías (tabla PRMGT).
	
	--Se asigna la fecha del avalúo más reciente para hipotecas comunes
	BEGIN TRANSACTION TRA_Ins_Vrhc
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Vrhc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Vrhc
	END
	
	--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía 18
	BEGIN TRANSACTION TRA_Ins_Vrch18
	
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
	

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Vrch18
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Vrch18
	END
	
	--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
	BEGIN TRANSACTION TRA_Ins_Vrch
	
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
											GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Vrch
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Vrch
	END

	--Se asigna la fecha del avalúo más reciente para prendas
	BEGIN TRANSACTION TRA_Ins_Vrp
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Ins_Vrp
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Ins_Vrp
	END
	
	--INICIO RQ: 1-24206841. Se actualiza el campo de la fecha de valuación registrada en el SICC, en la tabla de valuaciones.
	--Si la fecha de valuación del SICC es 01/01/1900 implica que el dato almacenado en el Maestro de Garantías (tabla PRMGT) no corresponde a una fecha.
	--Si la fecha de valuación dle SICC es igual a NULL es porque la garantía nunca fue encontrada en el Maestro de Garantías (tabla PRMGT).

	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
	BEGIN TRANSACTION TRA_Act_Fvhcop
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvhcop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvhcop
	END
	
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
	BEGIN TRANSACTION TRA_Act_Fvhcc
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvhcc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvhcc
	END
	
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
	BEGIN TRANSACTION TRA_Act_Fvch18op
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvch18op
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvch18op
	END
		
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
	BEGIN TRANSACTION TRA_Act_Fvch18c
	
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
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvch18c
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvch18c
	END
		
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
	BEGIN TRANSACTION TRA_Act_Fvchop
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvchop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvchop
	END
		
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
	BEGIN TRANSACTION TRA_Act_Fvchc
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvchc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvchc
	END	
		
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para prendas
	BEGIN TRANSACTION TRA_Act_Fvpop
	
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvpop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvpop
	END	
	
	--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para prendas
	BEGIN TRANSACTION TRA_Act_Fvpc
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Fvpc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Fvpc
	END	
	
	--FIN RQ: 1-24206841 Y 1-24331191
	
	--INICIO RQ: 1-21537427 Y 1-24331191. Se actualiza el indicador del tipo de registro de los avalúos
	--Se inicializan todos los registros a 0 (cero)
	BEGIN TRANSACTION TRA_Act_Avaluos
	
	UPDATE	dbo.GAR_VALUACIONES_REALES
	SET		Indicador_Tipo_Registro = 0
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avaluos
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avaluos
	END	
	
	--Se obtienen los avalúos más recientes
	BEGIN TRANSACTION TRA_Act_Avalrec
	
	UPDATE	GV1
	SET		GV1.Indicador_Tipo_Registro = 2
	FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN  (SELECT		cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
				 FROM		dbo.GAR_VALUACIONES_REALES
				 GROUP		BY cod_garantia_real) GV2
	ON	GV2.cod_garantia_real = GV1.cod_garantia_real
	AND GV2.fecha_valuacion	= GV1.fecha_valuacion

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalrec
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalrec
	END	
	
	--Se obtienen los penúltimos avalúos
	BEGIN TRANSACTION TRA_Act_Avalpenul
	
	UPDATE	GV1
	SET		GV1.Indicador_Tipo_Registro = 3
	FROM	dbo.GAR_VALUACIONES_REALES GV1
	INNER JOIN (SELECT	cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
				FROM	dbo.GAR_VALUACIONES_REALES
				WHERE	Indicador_Tipo_Registro = 0
				GROUP	BY cod_garantia_real) GV2
	ON	GV2.cod_garantia_real = GV1.cod_garantia_real
	AND GV2.fecha_valuacion	= GV1.fecha_valuacion
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalpenul
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalpenul
	END	
	
	--Se obtienen los avalúos que son iguales a los registrados en el SICC para operaciones
	--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes
	BEGIN TRANSACTION TRA_Act_Avalhc
	
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
		
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalhc
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalhc
	END	
	
	--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía 18
	BEGIN TRANSACTION TRA_Act_Avalch18
	
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
							GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
						) GHC
			ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
			AND GHC.cod_partido = GGR.cod_partido
			AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
		WHERE	GHC.fecha_valuacion > '19000101') TMP
		ON TMP.cod_garantia_real = GV1.cod_garantia_real
		AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalch18
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalch18
	END	
	
	--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
	BEGIN TRANSACTION TRA_Act_Avalch
	
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
														MG1.prmgt_pnu_part,
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
														MG1.prmgt_pnu_part,
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
											GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
							ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
							AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
							AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
							AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
							WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
							GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
						) GHC
			ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
			AND GHC.cod_partido = GGR.cod_partido
			AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
		WHERE	GHC.fecha_valuacion > '19000101') TMP
		ON TMP.cod_garantia_real = GV1.cod_garantia_real
		AND GV1.fecha_valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalch
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalch
	END	
	
	--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas
	BEGIN TRANSACTION TRA_Act_Avalp
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Avalp
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Avalp
	END	
		
	--FIN RQ: 1-21537427 Y 1-24331191	

	-------------------------------------------------------------------------------------------------------------------------
	-- INDICADOR DE INDISCRIPCION DE GARANTIAS REALES
	-------------------------------------------------------------------------------------------------------------------------	
	--Se asigna el indicador 1 a todas las garantías reales asociadas a operaciones directas activas
	BEGIN TRANSACTION TRA_Act_Indinsop
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Indinsop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Indinsop
	END	

	--Se asigna el indicador 1 a todas las garantías reales asociadas a contratos vigentes
	BEGIN TRANSACTION TRA_Act_Indinscv
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Indinscv
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Indinscv
	END	
	
			
	--Se asigna el indicador 1 a todas las garantías reales asociadas a contratos vencidos, pero con giros activos
	BEGIN TRANSACTION TRA_Act_Indinscvga
	
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
	
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Indinscvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Indinscvga
	END			

	--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a operaciones activas registradas en el sistema
	BEGIN TRANSACTION TRA_Act_Grop
	
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
						
	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Grop
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Grop
	END	
	
	--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vigentes registradas en el sistema
	BEGIN TRANSACTION TRA_Act_Grocv
	
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Grocv
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Grocv
	END	

	--Se realiza el ajuste del indicador de inscripción de las garantías reales asociadas a contratos vencidos, 
	--pero con giros activos, registradas en el sistema
	BEGIN TRANSACTION TRA_Act_Grocvga
	
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Grocvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Grocvga
	END	
	
	--FIN RQ: 1-23816691.

	-------------------------------------------------------------------------------------------------------------------------
	-- CONTRATOS VENCIDOS
	-------------------------------------------------------------------------------------------------------------------------	
	--Habilita los contratos vencidos que tienen giros activos
	BEGIN TRANSACTION TRA_Act_Cvga
	
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
						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Cvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Cvga
	END	
	
	--Habilita las garantías fiduciarias de los contratos que tienen giros activos
	BEGIN TRANSACTION TRA_Act_Gfcvga
	
	UPDATE	GFO
	SET		GFO.cod_estado = 1
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
						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Gfcvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Gfcvga
	END	
	
	--Habilita las garantías reales de los contratos que tienen giros activos
	BEGIN TRANSACTION TRA_Act_Grcvga
	
	UPDATE	GRO
	SET		GRO.cod_estado = 1
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
						AND MCA.prmca_estado = 'A'
						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Grcvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Grcvga
	END	
	
	--Habilita las garantías de valor de los contratos que tienen giros activos
	BEGIN TRANSACTION TRA_Act_Gvcvga
	
	UPDATE	GVO
	SET		GVO.cod_estado = 1
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
						AND MCA.prmca_estado = 'A'
						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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

	SET @viErrorTran = @@Error

	IF(@viErrorTran = 0) 
	BEGIN
		COMMIT TRANSACTION TRA_Act_Gvcvga
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION TRA_Act_Gvcvga
	END
	
END