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
<Descripción>Procedimiento que se encarga de obtener la información de los contratos, utilizada para la generación del archivo que requiere SEGUI.
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
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/

BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	/*Se eliminan los registros que el usuario creara en la consulta anterior*/
	DELETE FROM TMP_ARCHIVO_CONTRATOS WHERE cod_usuario = @IDUsuario


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

	INSERT INTO TMP_ARCHIVO_CONTRATOS
	SELECT 
		prmca_pco_ofici,
		prmca_pco_moned,
		prmca_pco_produc,
		prmca_pnu_contr,
		CASE prmca_pco_moned
			WHEN 1 THEN prmca_pmo_maxim
			WHEN 2 THEN prmca_pmo_maxim * @montoTipoCambio
		END AS prmca_pmo_maxim,
		CASE prmca_pco_moned
			WHEN 1 THEN prmca_pmo_utiliz
			WHEN 2 THEN prmca_pmo_utiliz * @montoTipoCambio
		END AS prmca_pmo_utiliz,
		CASE prmca_pco_moned
			WHEN 1 THEN prmca_pmo_reserv
			WHEN 2 THEN prmca_pmo_reserv * @montoTipoCambio
		END AS prmca_pmo_reserv,
		CASE prmca_pco_moned
			WHEN 1 THEN prmca_psa_discon
			WHEN 2 THEN prmca_psa_discon * @montoTipoCambio
		END AS prmca_psa_discon,
		CASE prmca_pco_moned
			WHEN 1 THEN prmca_psa_conta
			WHEN 2 THEN prmca_psa_conta * @montoTipoCambio
		END AS prmca_psa_conta,
		0 AS saldo_actual_giros,
		0 AS monto_mitigador,
		@IDUsuario AS cod_usuario

	FROM 
		gar_sicc_prmca a

	WHERE 
		prmca_estado = 'A'
		AND ((CONVERT(varchar(10),prmca_pfe_defin) >= CONVERT(varchar(10),GETDATE(),111))
		OR
			((CONVERT(varchar(10),prmca_pfe_defin) < CONVERT(varchar(10),GETDATE(),111))
			--AND prmca_pmo_utiliz > 0)
			AND EXISTS (SELECT 1 
						FROM dbo.GAR_SICC_PRMOC
						WHERE prmoc_pco_oficon = prmca_pco_ofici
						AND prmoc_pcomonint = prmca_pco_moned
						AND prmoc_pnu_contr = prmca_pnu_contr
						AND prmoc_pcoctamay <> 815 
						AND prmoc_pse_proces = 1 
						AND prmoc_estado = 'A')))

	/*Se actualiza el campo correspondiente al saldo actual de los giros*/
	UPDATE TMP_ARCHIVO_CONTRATOS
	SET saldo_actual_giros = P.saldo_act_giros

	FROM  TMP_ARCHIVO_CONTRATOS T
		INNER JOIN
		(SELECT T1.prmca_pco_ofici, T1.prmca_pco_moned, T1.prmca_pco_produc, T1.prmca_pnu_contr, T1.cod_usuario,
			CASE prmca_pco_moned
				WHEN 1 THEN SUM(ISNULL(prmoc_psa_actual,0))
				WHEN 2 THEN SUM(ISNULL(prmoc_psa_actual,0)) * @montoTipoCambio
			END AS saldo_act_giros

		 FROM TMP_ARCHIVO_CONTRATOS T1
			LEFT OUTER JOIN gar_sicc_prmoc 
			ON T1.prmca_pco_ofici = prmoc_pco_oficon
			AND T1.prmca_pco_moned = prmoc_pcomonint
			AND T1.prmca_pnu_contr = prmoc_pnu_contr
			AND prmoc_estado = 'A'
			AND prmoc_pcoctamay <> 815 
			AND prmoc_pse_proces = 1 
		
		WHERE cod_usuario = @IDUsuario

		GROUP BY
			prmca_pco_ofici,
			prmca_pco_moned,
			prmca_pco_produc,
			prmca_pnu_contr,
			prmca_pmo_maxim,
			prmca_pmo_utiliz,
			prmca_pmo_reserv,
			prmca_psa_discon,
			prmca_psa_conta,
			cod_usuario
		) P
	
	ON P.prmca_pco_ofici = T.prmca_pco_ofici
	AND P.prmca_pco_moned = T.prmca_pco_moned
	AND P.prmca_pco_produc = T.prmca_pco_produc
	AND P.prmca_pnu_contr = T.prmca_pnu_contr
	AND P.cod_usuario = T.cod_usuario
		
	WHERE P.cod_usuario = @IDUsuario



	/*Se actualiza el campo del monto mitigador con la sumatoria de montos mitigadores de cada garantía real asociada*/
	UPDATE TMP_ARCHIVO_CONTRATOS
		SET monto_mitigador = P.monto_mit 

	FROM TMP_ARCHIVO_CONTRATOS T
		INNER JOIN (SELECT a.prmca_pco_ofici, a.prmca_pco_moned, a.prmca_pco_produc, a.prmca_pnu_contr, 
					 a.cod_usuario, SUM(ISNULL(c.monto_mitigador,0)) AS monto_mit
		  FROM TMP_ARCHIVO_CONTRATOS a
		  LEFT OUTER JOIN gar_operacion b
			ON a.prmca_pco_moned = b.cod_moneda
			AND a.prmca_pnu_contr = b.num_contrato
			LEFT OUTER JOIN gar_garantias_reales_x_operacion c
			ON b.cod_operacion = c.cod_operacion

		  WHERE	b.num_operacion IS NULL
			AND a.cod_usuario = @IDUsuario 

		  GROUP BY
			prmca_pco_ofici,
			prmca_pco_moned,
			prmca_pco_produc,
			prmca_pnu_contr,
			prmca_pmo_maxim,
			prmca_pmo_utiliz,
			prmca_pmo_reserv,
			prmca_psa_discon,
			prmca_psa_conta,
			saldo_actual_giros,
			cod_usuario) P
	
	ON P.prmca_pco_ofici = T.prmca_pco_ofici
	AND P.prmca_pco_moned = T.prmca_pco_moned
	AND P.prmca_pco_produc = T.prmca_pco_produc
	AND P.prmca_pnu_contr = T.prmca_pnu_contr
	AND P.cod_usuario = T.cod_usuario

	WHERE P.cod_usuario = @IDUsuario 

	/*Se actualiza el campo del monto mitigador con la sumatoria de montos mitigadores de cada garantía de valor asociada*/
	UPDATE TMP_ARCHIVO_CONTRATOS
		SET monto_mitigador = monto_mitigador + P.monto_mit 

	FROM TMP_ARCHIVO_CONTRATOS T
		INNER JOIN (SELECT a.prmca_pco_ofici, a.prmca_pco_moned, a.prmca_pco_produc, a.prmca_pnu_contr, 
					 a.cod_usuario, SUM(ISNULL(c.monto_mitigador,0)) AS monto_mit
		  FROM TMP_ARCHIVO_CONTRATOS a
		  LEFT OUTER JOIN gar_operacion b
			ON a.prmca_pco_moned = b.cod_moneda
			AND a.prmca_pnu_contr = b.num_contrato
			LEFT OUTER JOIN gar_garantias_valor_x_operacion c
			ON b.cod_operacion = c.cod_operacion

		  WHERE	b.num_operacion IS NULL
			AND a.cod_usuario = @IDUsuario 

		  GROUP BY
			prmca_pco_ofici,
			prmca_pco_moned,
			prmca_pco_produc,
			prmca_pnu_contr,
			prmca_pmo_maxim,
			prmca_pmo_utiliz,
			prmca_pmo_reserv,
			prmca_psa_discon,
			prmca_psa_conta,
			saldo_actual_giros,
			cod_usuario) P
	
	ON P.prmca_pco_ofici = T.prmca_pco_ofici
	AND P.prmca_pco_moned = T.prmca_pco_moned
	AND P.prmca_pco_produc = T.prmca_pco_produc
	AND P.prmca_pnu_contr = T.prmca_pnu_contr
	AND P.cod_usuario = T.cod_usuario

	WHERE P.cod_usuario = @IDUsuario 
		
	/*Se extrae la infromación*/
	SELECT prmca_pco_ofici,
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

	FROM TMP_ARCHIVO_CONTRATOS

	WHERE cod_usuario = @IDUsuario
	
	ORDER BY prmca_pnu_contr

END

