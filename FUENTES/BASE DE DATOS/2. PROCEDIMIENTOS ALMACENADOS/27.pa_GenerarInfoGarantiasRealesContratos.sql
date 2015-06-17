SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasRealesContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerGarantiasRealesContratos;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasRealesContratos] 
	@psCedula_Usuario	VARCHAR(30),
	@piEjecutarParte	TINYINT
AS
BEGIN
/******************************************************************
	<Nombre>pa_GenerarInfoGarantiasRealesContratos</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a las garantías reales relacionadas 
		a los contratos vigentes o vencidos pero que poseen al menos un giro activo.
	</Descripción>
	<Entradas>
			@psCedula_Usuario		= Identificación del usuario que realiza la consulta. 
									  Este es dato llave usado para la búsqueda de los registros que deben 
                                      ser eliminados de la tabla temporal.
            @piEjecutarParte		= Indica la parte del procedimiento almacenado que será ejecutada, esto con el fin de agilizar el proceso de 
									  generación.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Arnoldo Martinelli Marín, LiderSoft Internacional S.A.</Autor>
	<Fecha>16/11/2010</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.2</Versión>
	<Historial>
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
				Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
			    Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841</Requerimiento>
			<Fecha>13/03/2014</Fecha>
			<Descripción>
				Se ajusta el procedimiento almacenado para que extraíga la información correspondiente al porcentaje de 
				aceptación e indicador de inscripción de la misma forma en como lo obtiene la aplicación para mostralo en pantalla.
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
			<Autor>Leonardo Cortes Mora,Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Ajuste por Fallas Técnicas
			</Requerimiento>
			<Fecha>23/10/2014 </Fecha>
			<Descripción>
				Se modifican dos variables para el manejo de la fecha 
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
	SET DATEFORMAT dmy
	
		/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
		DECLARE
			@lfecHoySinHora DATETIME,
			@lintFechaEntero INT

		SET @lfecHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		SET @lintFechaEntero = CONVERT(INT, CONVERT(VARCHAR(8), @lfecHoySinHora, 112))

	IF(@piEjecutarParte = 0)
	BEGIN
		/*Se eliminan los datos de las tablas temporales asociados al usuario que genera la información*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion = 2 
			
		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_tipo_garantia = 2
			AND cod_tipo_operacion = 2 
			AND cod_usuario = @psCedula_Usuario
			
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_garantia = 2 
			
		DELETE	FROM dbo.TMP_VALUACIONES_REALES 
		WHERE	cod_usuario = @psCedula_Usuario 

	

	/*Se carga la tabla temporal de contratos vigentes y vencidos (con giros activos) con la información de aquellos que posean una garantía real 
		  asociada*/	
		INSERT	INTO dbo.TMP_OPERACIONES(
			cod_operacion,
			cod_garantia,
			cod_tipo_garantia,
			cod_tipo_operacion,
			ind_contrato_vencido,
			ind_contrato_vencido_giros_activos,
			cod_oficina,
			cod_moneda,
			cod_producto,
			num_operacion,
			num_contrato,
			cod_usuario)
		SELECT	TMP.cod_operacion,
			TMP.cod_garantia_real,
			TMP.cod_tipo_garantia,
			TMP.cod_tipo_operacion,
			TMP.ind_contrato_vencido,
			TMP.ind_contrato_vencido_giros_activos,
			TMP.cod_oficina,
			TMP.cod_moneda,
			TMP.cod_producto,
			TMP.num_operacion,
			TMP.num_contrato,
			TMP.cod_usuario
		FROM (
				/*Se obtienen los contratos vencidos con giros activos*/
				SELECT	DISTINCT 
					GO1.cod_operacion, 
					GRA.cod_garantia_real, 
					2 AS cod_tipo_garantia,
					2 AS cod_tipo_operacion, -- 1 = Operaciones, 2 = Contratos y 3 = Giros
					CASE
						WHEN (MCA.prmca_pfe_defin >= @lintFechaEntero) THEN 1
						ELSE 0
					END AS ind_contrato_vencido,
					1 AS ind_contrato_vencido_giros_activos,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato,
					@psCedula_Usuario AS cod_usuario
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON GO1.cod_contabilidad = MCA.prmca_pco_conta
					AND GO1.cod_oficina = MCA.prmca_pco_ofici 
					AND GO1.cod_moneda = MCA.prmca_pco_moned
					AND GO1.num_contrato = CONVERT(DECIMAL(7),MCA.prmca_pnu_contr)
					INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
					ON GO1.cod_operacion = GRA.cod_operacion
				WHERE	GO1.num_operacion IS NULL 
					AND GO1.num_contrato > 0
					AND MCA.prmca_estado = 'A'
					AND MCA.prmca_pfe_defin < @lintFechaEntero
					AND EXISTS (SELECT	1
								FROM	dbo.GAR_SICC_PRMOC MOC
								WHERE	MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici 
									AND	MOC.prmoc_pcomonint = MCA.prmca_pco_moned
									AND	MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
									AND	((MOC.prmoc_pcoctamay < 815)
										OR (MOC.prmoc_pcoctamay > 815)) 
									AND	MOC.prmoc_pse_proces = 1 
									AND	MOC.prmoc_estado = 'A')

				UNION ALL
				
				/*Se carga la tabla temporal de contratos vigentes*/	
				SELECT	DISTINCT 
					GO1.cod_operacion, 
					GRA.cod_garantia_real,
					2 AS cod_tipo_garantia,
					2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
					CASE
						WHEN (MCA.prmca_pfe_defin >= @lintFechaEntero) THEN 1
						ELSE 0
					END AS ind_contrato_vencido,
					1 AS ind_contrato_vencido_giros_activos,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato,
					@psCedula_Usuario AS cod_usuario
				FROM	dbo.GAR_OPERACION GO1
					INNER JOIN dbo.GAR_SICC_PRMCA MCA
					ON GO1.cod_contabilidad = MCA.prmca_pco_conta
					AND GO1.cod_oficina = MCA.prmca_pco_ofici 
					AND GO1.cod_moneda = MCA.prmca_pco_moned
					AND GO1.num_contrato = CONVERT(DECIMAL(7),MCA.prmca_pnu_contr)
					INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
					ON GO1.cod_operacion = GRA.cod_operacion
				WHERE	GO1.num_operacion IS NULL 
					AND GO1.num_contrato > 0
					AND MCA.prmca_estado = 'A'
					AND MCA.prmca_pfe_defin	>= @lintFechaEntero) AS TMP

		/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE HIPOTECA COMÚN*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET		cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 1
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar IN (10, 11, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc


		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CÉDULAS HIPOTECARIAS*/
		UPDATE	dbo.TMP_OPERACIONES
		SET		cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 2
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar	= 18 --RQ: 1-23969281. Se incluye el código 18.
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc



		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CÉDULAS HIPOTECARIAS*/
		UPDATE	dbo.TMP_OPERACIONES
		SET		cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 2
			AND MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pcotengar = 1
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar BETWEEN 20 AND 29 --RQ: 1-23969281. Se excluye el código 18.
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			AND MGT.prmgt_pco_grado = GGR.cod_grado

		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CONTRATOS DE PRENDA*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET 	cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 3
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar BETWEEN 30 AND 69
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc

		/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_estado_garantia = 0 
			AND cod_tipo_operacion = 2 
			AND cod_tipo_garantia = 2 
			AND cod_usuario	 = @psCedula_Usuario 
	END
	ELSE IF(@piEjecutarParte = 1)
	BEGIN
		/*Se cargan los valores de los avalúos en la tabla temporal respectiva*/
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		INSERT	INTO dbo.TMP_VALUACIONES_REALES(
			cod_garantia_real,
			fecha_valuacion,
			cedula_empresa,
			cedula_perito,
			monto_ultima_tasacion_terreno,
			monto_ultima_tasacion_no_terreno,
			monto_tasacion_actualizada_terreno,
			monto_tasacion_actualizada_no_terreno,
			fecha_ultimo_seguimiento,
			monto_total_avaluo,
			cod_recomendacion_perito,
			cod_inspeccion_menor_tres_meses,
			fecha_construccion,
			cod_tipo_bien,
			ind_avaluo_completo,
			cod_usuario)
		SELECT	DISTINCT 
			GVR.cod_garantia_real, 
			GVR.fecha_valuacion, 
			GVR.cedula_empresa, 
			GVR.cedula_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			GVR.fecha_ultimo_seguimiento, 
			GVR.monto_total_avaluo, 
			GVR.cod_recomendacion_perito, 
			GVR.cod_inspeccion_menor_tres_meses, 
			GVR.fecha_construccion,
			GGR.cod_tipo_bien, 
			1 AS grado_completo,
			TMP.cod_usuario
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN (
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion 
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN (	SELECT	TOP 100 PERCENT 
										GGR.cod_clase_garantia,
										GGR.cod_partido,
										GGR.Identificacion_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
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
															WHERE	MG1.prmgt_pcoclagar BETWEEN 10 AND 17
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
															WHERE	MG1.prmgt_pcoclagar BETWEEN 10 AND 17
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin >= @lintFechaEntero
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
															WHERE	MG1.prmgt_pcoclagar BETWEEN 10 AND 17
																AND MG1.prmgt_estado = 'A'
																AND EXISTS (SELECT	1
																			FROM	dbo.GAR_SICC_PRMCA MCA
																			WHERE	MCA.prmca_estado = 'A'
																				AND MCA.prmca_pfe_defin < @lintFechaEntero
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
									WHERE	GGR.cod_clase_garantia BETWEEN 10 AND 17
									GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.cod_partido = GGR.cod_partido
					AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia BETWEEN 10 AND 17

		UNION ALL 
		
		SELECT	DISTINCT 
			GVR.cod_garantia_real, 
			GVR.fecha_valuacion, 
			GVR.cedula_empresa, 
			GVR.cedula_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			GVR.fecha_ultimo_seguimiento, 
			GVR.monto_total_avaluo, 
			GVR.cod_recomendacion_perito, 
			GVR.cod_inspeccion_menor_tres_meses, 
			GVR.fecha_construccion,
			GGR.cod_tipo_bien, 
			1 AS grado_completo,
			TMP.cod_usuario
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN (
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion 
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN (	SELECT	TOP 100 PERCENT 
										GGR.cod_partido,
										GGR.Identificacion_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (SELECT	MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pnu_part,
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
															SELECT	MG1.prmgt_pnu_part,
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
																				AND MCA.prmca_pfe_defin >= @lintFechaEntero
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															SELECT	MG1.prmgt_pnu_part,
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
																				AND MCA.prmca_pfe_defin < @lintFechaEntero
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
															UNION ALL
															SELECT	MG1.prmgt_pnu_part,
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
															SELECT	MG1.prmgt_pnu_part,
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
																				AND MCA.prmca_pfe_defin >= @lintFechaEntero
																				AND MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
																				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
																				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
																				AND MG1.prmgt_pco_produ = 10)
															UNION ALL
															SELECT	MG1.prmgt_pnu_part,
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
																				AND MCA.prmca_pfe_defin < @lintFechaEntero
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
													GROUP BY MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pnu_part = GGR.cod_partido
									AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
									WHERE	((GGR.cod_clase_garantia = 18) 
										OR (GGR.cod_clase_garantia BETWEEN 20 AND 29))
									GROUP BY GGR.cod_partido, GGR.Identificacion_Sicc
								) GHC
					ON GHC.cod_partido = GGR.cod_partido
					AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 18) 
				OR (GGR.cod_clase_garantia BETWEEN 20 AND 29))

		UNION ALL 
		
		SELECT	DISTINCT 
			GVR.cod_garantia_real, 
			GVR.fecha_valuacion, 
			GVR.cedula_empresa, 
			GVR.cedula_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			GVR.fecha_ultimo_seguimiento, 
			GVR.monto_total_avaluo, 
			GVR.cod_recomendacion_perito, 
			GVR.cod_inspeccion_menor_tres_meses, 
			GVR.fecha_construccion,
			GGR.cod_tipo_bien, 
			1 AS grado_completo,
			TMP.cod_usuario
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN (
				SELECT	DISTINCT 
					GGR.cod_garantia_real, 
					CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion 
				FROM	dbo.GAR_GARANTIA_REAL GGR
					INNER JOIN (	SELECT	TOP 100 PERCENT 
										GGR.cod_clase_garantia,
										GGR.Identificacion_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
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
																				AND MCA.prmca_pfe_defin >= @lintFechaEntero
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
																				AND MCA.prmca_pfe_defin < @lintFechaEntero
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
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia BETWEEN 30 AND 69
	END
	IF(@piEjecutarParte = 2)
	BEGIN
		/*Se selecciona la información de la garantía real asociada a los contratos*/
		INSERT INTO dbo.TMP_GARANTIAS_REALES
		SELECT DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_contrato AS operacion, 
			GGR.cod_tipo_bien, 
			CASE GGR.cod_tipo_garantia_real  
				WHEN 1 THEN ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '')  
				WHEN 2 THEN ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '') 
				WHEN 3 THEN ISNULL(GGR.cod_clase_bien, '') + ISNULL(GGR.num_placa_bien, '')
			END AS cod_bien, 
			GRO.cod_tipo_mitigador, 
			GRO.cod_tipo_documento_legal, 
			GRO.monto_mitigador, 
			CASE 
				WHEN CONVERT(VARCHAR(10),GRO.fecha_presentacion,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),GRO.fecha_presentacion,103)
			END AS fecha_presentacion,
			GRO.cod_inscripcion, 
			GRO.porcentaje_responsabilidad, 
			CASE 
				WHEN CONVERT(VARCHAR(10),GRO.fecha_constitucion,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),GRO.fecha_constitucion,103)
			END AS fecha_constitucion, 
			GRO.cod_grado_gravamen, 
			GRO.cod_tipo_acreedor, 
			GRO.cedula_acreedor, 
			CASE 
				WHEN CONVERT(VARCHAR(10),GRO.fecha_vencimiento,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),GRO.fecha_vencimiento,103)
			END AS fecha_vencimiento, 
			GRO.cod_operacion_especial, 
			CASE 
				WHEN CONVERT(VARCHAR(10),GVR.fecha_valuacion,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),GVR.fecha_valuacion,103)
			END AS fecha_valuacion, 
			GVR.cedula_empresa, 
			CASE 
				WHEN GVR.cedula_empresa IS NULL THEN NULL 
				ELSE 2 
			END AS cod_tipo_empresa, 
			GVR.cedula_perito, 
			GP1.cod_tipo_persona AS cod_tipo_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			CASE WHEN CONVERT(VARCHAR(10),GVR.fecha_ultimo_seguimiento,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GVR.fecha_ultimo_seguimiento,103)
			END AS fecha_ultimo_seguimiento, 
			ISNULL(GVR.monto_tasacion_actualizada_terreno,0) + ISNULL(GVR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE WHEN CONVERT(VARCHAR(10),GVR.fecha_construccion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GVR.fecha_construccion,103)
			END AS fecha_construccion,
			GGR.cod_grado,
			GGR.cedula_hipotecaria,
			GGR.cod_clase_garantia,
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			ISNULL(GGR.numero_finca,'') AS numero_finca,
			ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
			ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
			GO1.cedula_deudor,
			1 AS cod_estado,
			NULL AS cod_liquidez,
			NULL AS cod_tenencia,
			NULL AS cod_moneda_garantia,
			NULL AS cod_partido,
			NULL AS cod_tipo_garantia,
			NULL AS Garantia_Real,
			NULL AS fecha_prescripcion,
			TMP.cod_tipo_operacion,
			TMP.ind_contrato_vencido,
			1 AS ind_duplicidad,
			TMP.cod_usuario

		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GO1.cod_operacion = GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GRO.cod_garantia_real = GGR.cod_garantia_real 
			LEFT OUTER JOIN  dbo.TMP_VALUACIONES_REALES GVR
			ON GGR.cod_garantia_real = GVR.cod_garantia_real
			AND GVR.cod_usuario = @psCedula_Usuario
			LEFT OUTER JOIN dbo.GAR_PERITO GP1 
			ON GVR.cedula_perito = GP1.cedula_perito 
			INNER JOIN dbo.TMP_OPERACIONES TMP
			ON TMP.cod_operacion = GRO.cod_operacion
			AND TMP.cod_garantia = GRO.cod_garantia_real
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_operacion = 2
		ORDER	BY
			GO1.cod_operacion,
			GGR.numero_finca,
			GGR.cod_grado,
			GGR.cod_clase_bien,
			GGR.num_placa_bien,
			GRO.cod_tipo_documento_legal DESC,
			GVR.fecha_valuacion DESC

		/*Se obtienen las operaciones duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS(
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_operacion,
			cod_garantia_sicc,
			cod_tipo_garantia,
			cod_usuario,
			cod_garantia,
			cod_grado)
		SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			cod_bien AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion = 2
		GROUP	BY cod_oficina, cod_moneda,cod_producto, operacion, cod_bien, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
		  Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
						WHERE	TGR.cod_oficina					= TOD.cod_oficina
							AND TGR.cod_moneda					= TOD.cod_moneda
							AND TGR.cod_producto				= TOD.cod_producto
							AND TGR.operacion					= TOD.operacion
							AND ISNULL(TGR.cod_bien, '')		= ISNULL(TOD.cod_garantia_sicc, '')
							AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
							AND TOD.cod_tipo_operacion			= 2
							AND TOD.cod_tipo_garantia			= 2
							AND TGR.cod_tipo_documento_legal	IS NULL
							AND TGR.fecha_presentacion			IS NULL
							AND TGR.cod_tipo_mitigador			IS NULL
							AND TGR.cod_inscripcion				IS NULL)
		AND TGR.cod_usuario			= @psCedula_Usuario
		AND TGR.cod_tipo_operacion	= 2


		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_tipo_operacion	= 2 
			AND ind_duplicidad		= 2 
			AND cod_usuario			= @psCedula_Usuario

		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_operacion	= 2

		/*Se obtienen las garantías reales de hipoteca común duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS(
			cod_oficina,
			cod_moneda,
			cod_producto,
			operacion,
			cod_tipo_operacion,
			cod_garantia_sicc,
			cod_tipo_garantia,
			cod_usuario,
			cod_garantia)
		SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_finca AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_tipo_garantia_real	= 1 
			AND cod_tipo_operacion		= 2
			AND cod_usuario				= @psCedula_Usuario
		GROUP	BY	cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TM1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TM1
			ON TM1.cod_oficina					= TOD.cod_oficina
			AND TM1.cod_moneda					= TOD.cod_moneda
			AND TM1.cod_producto				= TOD.cod_producto
			AND TM1.operacion					= TOD.operacion
			AND ISNULL(TM1.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
		WHERE	TM1.cod_llave = (	SELECT	MIN(TM2.cod_llave)
									FROM	dbo.TMP_GARANTIAS_REALES TM2
									WHERE	TM2.cod_oficina					= TOD.cod_oficina
										AND TM2.cod_moneda					= TOD.cod_moneda
										AND TM2.cod_producto				= TOD.cod_producto
										AND TM2.operacion					= TOD.operacion
										AND ISNULL(TM2.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
										AND ISNULL(TM2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
										AND TM2.cod_tipo_garantia_real		= 1
										AND TM2.cod_tipo_operacion			= 2
										AND TOD.cod_tipo_garantia			= 2)
			AND TM1.cod_tipo_garantia_real	= 1
			AND TM1.cod_usuario				= @psCedula_Usuario
			AND TM1.cod_tipo_operacion		= 2


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
						WHERE	TGR.cod_oficina					= TOD.cod_oficina
							AND TGR.cod_moneda					= TOD.cod_moneda
							AND TGR.cod_producto				= TOD.cod_producto
							AND TGR.operacion					= TOD.operacion
							AND ISNULL(TGR.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
							AND TGR.cod_tipo_garantia_real		= 1
							AND TGR.cod_tipo_operacion			= 2
							AND TOD.cod_tipo_garantia			= 2)
			AND TGR.cod_tipo_garantia_real	= 1
			AND TGR.cod_usuario				= @psCedula_Usuario
			AND TGR.cod_tipo_operacion		= 2


		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_operacion	= 2

		/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			numero_finca AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE cod_usuario				= @psCedula_Usuario
			AND cod_tipo_operacion		= 2
			AND cod_tipo_garantia_real	= 2
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TM1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TM1
			ON TM1.cod_oficina					= TOD.cod_oficina
			AND TM1.cod_moneda					= TOD.cod_moneda
			AND TM1.cod_producto				= TOD.cod_producto
			AND TM1.operacion					= TOD.operacion
			AND ISNULL(TM1.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
			AND TM1.cod_grado					= TOD.cod_grado
		WHERE	TM1.cod_llave = (SELECT	MIN(TM2.cod_llave)
								FROM	dbo.TMP_GARANTIAS_REALES TM2
								WHERE	TM2.cod_oficina					= TOD.cod_oficina
									AND TM2.cod_moneda					= TOD.cod_moneda
									AND TM2.cod_producto				= TOD.cod_producto
									AND TM2.operacion					= TOD.operacion
									AND ISNULL(TM2.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
									AND TM2.cod_grado					= TOD.cod_grado
									AND ISNULL(TM2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
									AND TM2.cod_tipo_garantia_real		= 2
									AND TM2.cod_tipo_operacion			= 2
									AND TOD.cod_tipo_garantia			= 2)
			AND TM1.cod_tipo_garantia_real	= 2
			AND TM1.cod_usuario				= @psCedula_Usuario
			AND TM1.cod_tipo_operacion		= 2


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
						WHERE	TGR.cod_oficina					= TOD.cod_oficina
							AND TGR.cod_moneda					= TOD.cod_moneda
							AND TGR.cod_producto				= TOD.cod_producto
							AND TGR.operacion					= TOD.operacion
							AND ISNULL(TGR.numero_finca, '')	= ISNULL(TOD.cod_garantia_sicc, '')
							AND TGR.cod_grado					= TOD.cod_grado
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
							AND TGR.cod_tipo_garantia_real		= 2
							AND TGR.cod_tipo_operacion			= 2
							AND TOD.cod_tipo_garantia			= 2)
			AND TGR.cod_tipo_garantia_real	= 2
			AND TGR.cod_usuario				= @psCedula_Usuario
			AND TGR.cod_tipo_operacion		= 2

		/*Se eliminan los duplicados obtenidos*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_operacion	= 2

		/*Se obtienen las garantías reales de prenda duplicadas*/
		INSERT INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	cod_oficina, 
			cod_moneda, 
			cod_producto, 
			operacion,
			cod_tipo_operacion, 
			num_placa_bien AS cod_garantia_sicc,
			2 AS cod_tipo_garantia,
			@psCedula_Usuario AS cod_usuario,
			MAX(cod_garantia_real) AS cod_garantia,
			NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario				= @psCedula_Usuario
			AND cod_tipo_operacion		= 2
			AND cod_tipo_garantia_real	= 3
		GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = TM1.cod_llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES TM1
			ON TM1.cod_oficina					= TOD.cod_oficina
			AND TM1.cod_moneda					= TOD.cod_moneda
			AND TM1.cod_producto				= TOD.cod_producto
			AND TM1.operacion					= TOD.operacion
			AND ISNULL(TM1.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
		WHERE	TM1.cod_llave = (SELECT MIN(TM2.cod_llave)
								FROM dbo.TMP_GARANTIAS_REALES TM2
								WHERE TM2.cod_oficina					= TOD.cod_oficina
									AND TM2.cod_moneda					= TOD.cod_moneda
									AND TM2.cod_producto				= TOD.cod_producto
									AND TM2.operacion					= TOD.operacion
									AND ISNULL(TM2.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
									AND ISNULL(TM2.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
									AND TM2.cod_tipo_garantia_real		= 3
									AND TM2.cod_tipo_operacion			= 2
									AND TOD.cod_tipo_garantia			= 2)
			AND TM1.cod_tipo_garantia_real	= 3
			AND TM1.cod_usuario				= @psCedula_Usuario
			AND TM1.cod_tipo_operacion		= 2

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES
		SET		ind_duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
						WHERE	TGR.cod_oficina					= TOD.cod_oficina
							AND TGR.cod_moneda					= TOD.cod_moneda
							AND TGR.cod_producto				= TOD.cod_producto
							AND TGR.operacion					= TOD.operacion
							AND ISNULL(TGR.num_placa_bien, '')	= ISNULL(TOD.cod_garantia_sicc, '')
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND ISNULL(TGR.cod_usuario, '')		= ISNULL(TOD.cod_usuario, '')
							AND TGR.cod_tipo_garantia_real		= 3
							AND TGR.cod_tipo_operacion			= 2
							AND TOD.cod_tipo_garantia			= 2)
			AND TGR.cod_tipo_garantia_real	= 3
			AND TGR.cod_usuario				= @psCedula_Usuario
			AND TGR.cod_tipo_operacion		= 2

		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_usuario			= @psCedula_Usuario
			AND cod_tipo_operacion	= 2 
			AND	ind_duplicidad		= 2 

		/*Se seleccionan los datos de salida para el usuario que genera la información*/
		SELECT DISTINCT
			TGR.cod_contabilidad AS CONTABILIDAD,
			TGR.cod_oficina AS OFICINA,
			TGR.cod_moneda AS MONEDA,
			TGR.cod_producto AS PRODUCTO,
			TGR.operacion AS OPERACION,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_bien)), '') AS TIPO_BIEN,
			ISNULL((CONVERT(VARCHAR(50), TGR.cod_bien)), '') AS CODIGO_BIEN,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_mitigador)), '') AS TIPO_MITIGADOR,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
			ISNULL((CONVERT(VARCHAR(50),(MAX(TGR.monto_mitigador)))), '') AS MONTO_MITIGADOR,
			ISNULL((CONVERT(VARCHAR(10), TGR.fecha_presentacion, 103)), '') AS FECHA_PRESENTACION,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_inscripcion)), '') AS INDICADOR_INSCRIPCION,
			ISNULL((CONVERT(VARCHAR(50), TGR.porcentaje_responsabilidad)), '') AS PORCENTAJE_ACEPTACION,
			ISNULL((CONVERT(VARCHAR(10), TGR.fecha_constitucion, 103)), '') AS FECHA_CONSTITUCION,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_grado_gravamen)), '') AS GRADO_GRAVAMEN,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
			ISNULL(TGR.cedula_acreedor, '') AS CEDULA_ACREEDOR,
			ISNULL((CONVERT(VARCHAR(10), (MAX(TGR.fecha_vencimiento)), 103)), '') AS FECHA_VENCIMIENTO,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
			ISNULL((CONVERT(VARCHAR(10), TGR.fecha_valuacion, 103)), '') AS FECHA_VALUACION,
			ISNULL(TGR.cedula_empresa, '') AS CEDULA_EMPRESA,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_empresa)), '') AS TIPO_PERSONA_EMPRESA,
			ISNULL(TGR.cedula_perito, '') AS CEDULA_PERITO,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_tipo_perito)), '')AS TIPO_PERSONA_PERITO,
			ISNULL((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_terreno)), '') AS MONTO_ULTIMA_TASACION_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_no_terreno)), '') AS MONTO_ULTIMA_TASACION_NO_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_TERRENO,
			ISNULL((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_no_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
			ISNULL((CONVERT(VARCHAR(10), TGR.fecha_ultimo_seguimiento, 103)), '') AS FECHA_ULTIMO_SEGUIMIENTO,
			ISNULL((CONVERT(VARCHAR(50), TGR.monto_total_avaluo)), '') AS MONTO_TOTAL_AVALUO,
			ISNULL((CONVERT(VARCHAR(10), TGR.fecha_construccion, 103)), '') AS FECHA_CONSTRUCCION,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_grado)), '') AS COD_GRADO,
			ISNULL(TGR.cedula_hipotecaria, '') AS CEDULA_HIPOTECARIA,
			ISNULL(TGR.cedula_deudor, '') AS CEDULA_DEUDOR,
			ISNULL(GD1.nombre_deudor, '') AS NOMBRE_DEUDOR,
			ISNULL((CONVERT(VARCHAR(5), MPC.bsmpc_dco_ofici)), '') AS OFICINA_DEUDOR,
			ISNULL((CONVERT(VARCHAR(3), TGR.cod_clase_garantia)), '') AS TIPO_GARANTIA,
			TGR.ind_operacion_vencida AS ES_CONTRATO_VENCIDO
		FROM	TMP_GARANTIAS_REALES TGR
			INNER JOIN GAR_SICC_BSMPC MPC
			ON TGR.cedula_deudor = CONVERT(VARCHAR(30), MPC.bsmpc_sco_ident)
			INNER JOIN GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'
		GROUP	BY
			TGR.cod_contabilidad, 
			TGR.cod_oficina,
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			TGR.cod_tipo_bien, 
			TGR.cod_bien,
			TGR.cod_tipo_mitigador, 
			TGR.cod_tipo_documento_legal, 
			TGR.fecha_presentacion, 
			TGR.cod_inscripcion, 
			TGR.porcentaje_responsabilidad, 
			TGR.fecha_constitucion, 
			TGR.cod_grado_gravamen, 
			TGR.cod_tipo_acreedor, 
			TGR.cedula_acreedor,
			TGR.cod_operacion_especial, 
			TGR.fecha_valuacion, 
			TGR.cedula_empresa, 
			TGR.cod_tipo_empresa, 
			TGR.cedula_perito,
			TGR.cod_tipo_perito, 
			TGR.monto_ultima_tasacion_terreno, 
			TGR.monto_ultima_tasacion_no_terreno, 
			TGR.monto_tasacion_actualizada_terreno, 
			TGR.monto_tasacion_actualizada_no_terreno, 
			TGR.fecha_ultimo_seguimiento, 
			TGR.monto_total_avaluo, 
			TGR.fecha_construccion, 
			TGR.cod_grado, 
			TGR.cedula_hipotecaria, 
			TGR.cedula_deudor, 
			GD1.nombre_deudor,
			MPC.bsmpc_dco_ofici,
			TGR.cod_clase_garantia,
			TGR.ind_operacion_vencida
		ORDER BY TGR.operacion
	END
END


