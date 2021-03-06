USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoContratos;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoContratos] 
	@IDUsuario VARCHAR(30) = NULL
AS

/******************************************************************
<Nombre>pa_GenerarInfoContratos</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>
	Procedimiento que se encarga de obtener la información de los contratos, utilizada para la generación del archivo que requiere SEGUI.
    La base de este procedimiento fue proporcionado por el Ing. Javier Chaves Alvarado.
</Descripción>
<Entradas>
	@IDUsuario = Identificación del usuario que realiza la consulta. Esto permite la concurrencia.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
<Fecha>12/10/2010</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>Creación de Tablas para SICAD, No. 2016012710534870</Requerimiento>
		<Fecha>16/02/2016</Fecha>
		<Descripción>
			Se realiza un ajuste con el fin de optimizar el proceso. 
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

BEGIN
	SET NOCOUNT ON
	SET DATEFORMAT dmy

	/*Se eliminan los registros que el usuario creara en la consulta anterior*/
	DELETE FROM dbo.TMP_ARCHIVO_CONTRATOS WHERE cod_usuario = @IDUsuario


	/*Se declaran las variables para utilizar la fecha actual como un entero y para almacenar el tipo de cambio obtenido*/
	DECLARE
		@lfecHoySinHora		DATETIME,
		@lintFechaEntero	INT,
		@montoTipoCambio	MONEY

	SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @lintFechaEntero =  CONVERT(int, CONVERT(varchar(8), @lfecHoySinHora, 112))

	/*Se obtiene el tipo de cambio a la fecha actual*/
	SET @montoTipoCambio = dbo.ufn_ObtenerTipoCambioSICC (GETDATE())

	/*Extrae la información de contratos de PRMCA*/



	INSERT	INTO dbo.TMP_ARCHIVO_CONTRATOS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, prmca_pmo_maxim, 
											prmca_pmo_utiliz, prmca_pmo_reserv, prmca_psa_discon, prmca_psa_conta, saldo_actual_giros, 
											monto_mitigador, cod_usuario)
	SELECT  MCA.prmca_pco_ofici,
			MCA.prmca_pco_moned,
			MCA.prmca_pco_produc,
			MCA.prmca_pnu_contr,
			MCA.prmca_pmo_maxim,
			MCA.prmca_pmo_utiliz,
			MCA.prmca_pmo_reserv,
			MCA.prmca_psa_discon,
			MCA.prmca_psa_conta,
			0 AS saldo_actual_giros,
			0 AS monto_mitigador,
			@IDUsuario AS cod_usuario
	FROM	dbo.GAR_SICC_PRMCA MCA
	WHERE	MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @lintFechaEntero
	GROUP BY MCA.prmca_pco_ofici,
			MCA.prmca_pco_moned,
			MCA.prmca_pco_produc,
			MCA.prmca_pnu_contr,
			MCA.prmca_pmo_maxim,
			MCA.prmca_pmo_utiliz,
			MCA.prmca_pmo_reserv,
			MCA.prmca_psa_discon,
			MCA.prmca_psa_conta

	UNION ALL

	SELECT  MCA.prmca_pco_ofici,
			MCA.prmca_pco_moned,
			MCA.prmca_pco_produc,
			MCA.prmca_pnu_contr,
			MCA.prmca_pmo_maxim,
			MCA.prmca_pmo_utiliz,
			MCA.prmca_pmo_reserv,
			MCA.prmca_psa_discon,
			MCA.prmca_psa_conta,
			0 AS saldo_actual_giros,
			0 AS monto_mitigador,
			@IDUsuario AS cod_usuario
	FROM	dbo.GAR_SICC_PRMCA MCA
		INNER JOIN dbo.GAR_SICC_PRMOC MOC
		ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr		
	WHERE	MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @lintFechaEntero	
		AND ((MOC.prmoc_pcoctamay < 815) OR (MOC.prmoc_pcoctamay > 815))
		AND MOC.prmoc_pse_proces = 1 
		AND MOC.prmoc_estado = 'A'	
	GROUP BY MCA.prmca_pco_ofici,
			MCA.prmca_pco_moned,
			MCA.prmca_pco_produc,
			MCA.prmca_pnu_contr,
			MCA.prmca_pmo_maxim,
			MCA.prmca_pmo_utiliz,
			MCA.prmca_pmo_reserv,
			MCA.prmca_psa_discon,
			MCA.prmca_psa_conta


	UPDATE	TAC
	SET		TAC.prmca_pmo_maxim = TA1.prmca_pmo_maxim * @montoTipoCambio,
			TAC.prmca_pmo_utiliz = TA1.prmca_pmo_utiliz * @montoTipoCambio,
			TAC.prmca_pmo_reserv = TA1.prmca_pmo_reserv * @montoTipoCambio,
			TAC.prmca_psa_discon = TA1.prmca_psa_discon * @montoTipoCambio,
			TAC.prmca_psa_conta = TA1.prmca_psa_conta * @montoTipoCambio
	FROM	dbo.TMP_ARCHIVO_CONTRATOS TAC
		INNER JOIN dbo.TMP_ARCHIVO_CONTRATOS TA1
		ON TA1.prmca_pco_ofici = TAC.prmca_pco_ofici
		AND TA1.prmca_pco_moned = TAC.prmca_pco_moned
		AND TA1.prmca_pco_produc = TAC.prmca_pco_produc
		AND TA1.prmca_pnu_contr = TAC.prmca_pnu_contr
		AND TA1.cod_usuario = TAC.cod_usuario
	WHERE	TAC.cod_usuario = @IDUsuario
		AND TAC.prmca_pco_moned = 2
	

	/*Se actualiza el campo correspondiente al saldo actual de los giros*/
	WITH GIROS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, cod_usuario, saldo_act_giros) AS
	(
		SELECT	TA1.prmca_pco_ofici, 
				TA1.prmca_pco_moned, 
				TA1.prmca_pco_produc, 
				TA1.prmca_pnu_contr, 
				TA1.cod_usuario,
				CASE TA1.prmca_pco_moned
					WHEN 1 THEN SUM(ISNULL(MOC.prmoc_psa_actual,0))
					WHEN 2 THEN SUM(ISNULL(MOC.prmoc_psa_actual,0)) * @montoTipoCambio
				END AS saldo_act_giros
		 FROM	dbo.TMP_ARCHIVO_CONTRATOS TA1
			LEFT OUTER JOIN dbo.GAR_SICC_PRMOC MOC
			ON TA1.prmca_pco_ofici = MOC.prmoc_pco_oficon
			AND TA1.prmca_pco_moned = MOC.prmoc_pcomonint
			AND TA1.prmca_pnu_contr = MOC.prmoc_pnu_contr
			AND ((MOC.prmoc_pcoctamay < 815) OR (MOC.prmoc_pcoctamay > 815))
			AND MOC.prmoc_pse_proces = 1 
			AND MOC.prmoc_estado = 'A'
		WHERE	TA1.cod_usuario = @IDUsuario
		GROUP BY TA1.prmca_pco_ofici,
				TA1.prmca_pco_moned,
				TA1.prmca_pco_produc,
				TA1.prmca_pnu_contr,
				TA1.prmca_pmo_maxim,
				TA1.prmca_pmo_utiliz,
				TA1.prmca_pmo_reserv,
				TA1.prmca_psa_discon,
				TA1.prmca_psa_conta,
				TA1.cod_usuario
	)
	UPDATE dbo.TMP_ARCHIVO_CONTRATOS
	SET saldo_actual_giros = GIROS.saldo_act_giros
	FROM  GIROS 
	WHERE TMP_ARCHIVO_CONTRATOS.prmca_pco_ofici = GIROS.prmca_pco_ofici
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_moned = GIROS.prmca_pco_moned
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_produc = GIROS.prmca_pco_produc
		AND TMP_ARCHIVO_CONTRATOS.prmca_pnu_contr = GIROS.prmca_pnu_contr
		AND TMP_ARCHIVO_CONTRATOS.cod_usuario = GIROS.cod_usuario
	
	/*Se actualiza el campo del monto mitigador con la sumatoria de montos mitigadores de cada garantía real asociada*/
	
	WITH MITIGADORES (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, cod_usuario, monto_mit) AS
	(
		SELECT	TA1.prmca_pco_ofici, 
				TA1.prmca_pco_moned, 
				TA1.prmca_pco_produc, 
				TA1.prmca_pnu_contr, 
				TA1.cod_usuario,
				SUM(COALESCE(GRO.monto_mitigador,0)) AS monto_mit
		 FROM	dbo.TMP_ARCHIVO_CONTRATOS TA1
			LEFT OUTER JOIN dbo.GAR_OPERACION GO1
			ON TA1.prmca_pco_moned = GO1.cod_moneda
			AND TA1.prmca_pnu_contr = GO1.num_contrato
			LEFT OUTER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GO1.cod_operacion = GRO.cod_operacion
		WHERE	TA1.cod_usuario = @IDUsuario
			AND GO1.num_operacion IS NULL
		GROUP BY TA1.prmca_pco_ofici,
				TA1.prmca_pco_moned,
				TA1.prmca_pco_produc,
				TA1.prmca_pnu_contr,
				TA1.prmca_pmo_maxim,
				TA1.prmca_pmo_utiliz,
				TA1.prmca_pmo_reserv,
				TA1.prmca_psa_discon,
				TA1.prmca_psa_conta,
				TA1.saldo_actual_giros,
				TA1.cod_usuario
	)
	UPDATE dbo.TMP_ARCHIVO_CONTRATOS
	SET monto_mitigador = MITIGADORES.monto_mit
	FROM  MITIGADORES 
	WHERE TMP_ARCHIVO_CONTRATOS.prmca_pco_ofici = MITIGADORES.prmca_pco_ofici
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_moned = MITIGADORES.prmca_pco_moned
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_produc = MITIGADORES.prmca_pco_produc
		AND TMP_ARCHIVO_CONTRATOS.prmca_pnu_contr = MITIGADORES.prmca_pnu_contr
		AND TMP_ARCHIVO_CONTRATOS.cod_usuario = MITIGADORES.cod_usuario
	


	/*Se actualiza el campo del monto mitigador con la sumatoria de montos mitigadores de cada garantía de valor asociada*/
	WITH MITIGADORES (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr, cod_usuario, monto_mit) AS
	(
		SELECT	TA1.prmca_pco_ofici, 
				TA1.prmca_pco_moned, 
				TA1.prmca_pco_produc, 
				TA1.prmca_pnu_contr, 
				TA1.cod_usuario,
				SUM(COALESCE(GVO.monto_mitigador,0)) AS monto_mit
		 FROM	dbo.TMP_ARCHIVO_CONTRATOS TA1
			LEFT OUTER JOIN dbo.GAR_OPERACION GO1
			ON TA1.prmca_pco_moned = GO1.cod_moneda
			AND TA1.prmca_pnu_contr = GO1.num_contrato
			LEFT OUTER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO
			ON GO1.cod_operacion = GVO.cod_operacion
		WHERE	TA1.cod_usuario = @IDUsuario
			AND GO1.num_operacion IS NULL
		GROUP BY TA1.prmca_pco_ofici,
				TA1.prmca_pco_moned,
				TA1.prmca_pco_produc,
				TA1.prmca_pnu_contr,
				TA1.prmca_pmo_maxim,
				TA1.prmca_pmo_utiliz,
				TA1.prmca_pmo_reserv,
				TA1.prmca_psa_discon,
				TA1.prmca_psa_conta,
				TA1.saldo_actual_giros,
				TA1.cod_usuario
	)
	UPDATE dbo.TMP_ARCHIVO_CONTRATOS
	SET monto_mitigador = monto_mitigador + MITIGADORES.monto_mit
	FROM  MITIGADORES 
	WHERE TMP_ARCHIVO_CONTRATOS.prmca_pco_ofici = MITIGADORES.prmca_pco_ofici
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_moned = MITIGADORES.prmca_pco_moned
		AND TMP_ARCHIVO_CONTRATOS.prmca_pco_produc = MITIGADORES.prmca_pco_produc
		AND TMP_ARCHIVO_CONTRATOS.prmca_pnu_contr = MITIGADORES.prmca_pnu_contr
		AND TMP_ARCHIVO_CONTRATOS.cod_usuario = MITIGADORES.cod_usuario
	

		
	/*Se extrae la infromación*/
	SELECT	prmca_pco_ofici,
			prmca_pco_moned,
			prmca_pco_produc,
			prmca_pnu_contr,
			prmca_pmo_maxim,
			prmca_pmo_utiliz,
			prmca_pmo_reserv,
			prmca_psa_discon,
			prmca_psa_conta,
			saldo_actual_giros,
			monto_mitigador
	FROM	dbo.TMP_ARCHIVO_CONTRATOS
	WHERE	cod_usuario = @IDUsuario
	ORDER BY prmca_pnu_contr

END

