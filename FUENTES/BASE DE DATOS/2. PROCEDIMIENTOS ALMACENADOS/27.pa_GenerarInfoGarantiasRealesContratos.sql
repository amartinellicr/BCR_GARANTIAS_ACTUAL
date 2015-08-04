USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasRealesContratos', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasRealesContratos;
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
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
			<Fecha>19/06/2014</Fecha>
			<Descripción>
					Se agregan los campos referentes a la póliza asociada. 
			</Descripción>
		</Cambio>
				<Cambio>
			<Autor>Leonardo Cortes Mora,Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Ajuste por Fallas Técnicas
			</Requerimiento>
			<Fecha>01/09/2014 </Fecha>
			<Descripción>
				Se modifican dos variables para el manejo de la fecha 
			</Descripción>
		</Cambio>
			<Cambio>
			<Autor>leonardo Cortés Mora,Lidersoft Internacional S.A. </Autor>
			<Requerimiento>Porcentaje de Aceptacion Caculado, Siebel No. 1-24613011</Requerimiento>
			<Fecha>02/02/2015</Fecha>
			<Descripción>
					Se realiza la escogencia del valor menor entre el porcentaje de aceptacion y el porcentaje de aceptacion calculado del catalogo.
					Se agrega otro if para el calculo respecto del valor menor del porcentaje de aceptacion 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>06/07/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #0. El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015072910438633 - Solicitud de Cambios en la Sección de Pólizas y Valuaciones</Requerimiento>
			<Fecha>29/07/2015</Fecha>
			<Descripción>
				Se sustituyen los castigos de la fecha de último seguimiento, para los tipos de bien igual a 2, por uno nuevo, donde se 
				castiga si el deudor no habita la vivienda.
				También se inhabilitan todos los castigos referentes a las pólizas. 
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
	
		BEGIN TRAN TRA_borrar_datos
		
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

		COMMIT TRAN TRA_borrar_datos

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
		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE HIPOTECA COMÚN, CON CLASE DISTINTA A 11*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET		cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 1
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19) --RQ: 1-23969281. Se excluye el código 18.
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			
			
		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE HIPOTECA COMÚN, CON CLASE IGUAL A 11*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET		cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 1
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar = 11
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
			AND MGT.prmgt_pnu_part = GGR.cod_partido
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')

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
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 2
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pcoclagar	= 18 --RQ: 1-23969281. Se incluye el código 18.
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			AND MGT.prmgt_pnu_part = GGR.cod_partido


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
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
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
			AND MGT.prmgt_pnu_part = GGR.cod_partido

		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CONTRATOS DE PRENDA, CON CLASE DISTINTA A 38 O 43*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET 	cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 3
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND ((MGT.prmgt_pcoclagar BETWEEN 30 AND 37)
					OR (MGT.prmgt_pcoclagar BETWEEN 39 AND 42)
					OR (MGT.prmgt_pcoclagar BETWEEN 44 AND 69))
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			
		
		/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CONTRATOS DE PRENDA, CON CLASE IGUAL A 38 O 43*/
		UPDATE	dbo.TMP_OPERACIONES 
		SET 	cod_estado_garantia = 1
		FROM	dbo.TMP_OPERACIONES TMP
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN dbo.GAR_SICC_PRMGT MGT
			ON MGT.prmgt_pco_ofici = TMP.cod_oficina
			AND MGT.prmgt_pco_moned = TMP.cod_moneda
			AND MGT.prmgt_pnu_oper = TMP.num_contrato
		WHERE	TMP.cod_usuario = @psCedula_Usuario
			AND TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.num_operacion IS NULL
			AND TMP.num_contrato > 0
			AND GGR.cod_tipo_garantia_real = 3
			AND MGT.prmgt_estado = 'A'
			AND	MGT.prmgt_pco_produ = 10
			AND ((MGT.prmgt_pcoclagar = 38)
					OR (MGT.prmgt_pcoclagar = 43))
			AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
			AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')

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
		INSERT INTO dbo.TMP_VALUACIONES_REALES(
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
									WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)
									GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.cod_partido = GGR.cod_partido
					AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)

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
										GGR.cod_partido,
										GGR.Identificacion_Sicc,
										GGR.Identificacion_Alfanumerica_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND MGT.prmgt_pnu_part = GGR.cod_partido
									AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
									WHERE	GGR.cod_clase_garantia = 11
									GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.cod_partido = GGR.cod_partido
					AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia = 11

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
			AND TMP.cod_tipo_operacion = 1
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
									WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
												OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
												OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
									GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia BETWEEN 30 AND 37)
					OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
					OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))

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
										GGR.Identificacion_Alfanumerica_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
									WHERE	((GGR.cod_clase_garantia = 38)
												OR (GGR.cod_clase_garantia = 43))
									GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 38)
					OR (GGR.cod_clase_garantia = 43))

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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
															WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
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
									WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)
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
			AND GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)

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
										GGR.cod_partido,
										GGR.Identificacion_Sicc,
										GGR.Identificacion_Alfanumerica_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnu_part,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	MG1.prmgt_pcoclagar = 11
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
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND MGT.prmgt_pnu_part = GGR.cod_partido
									AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
									WHERE	GGR.cod_clase_garantia = 11
									GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND GHC.cod_partido = GGR.cod_partido
					AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia = 11

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
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND MGT.prmgt_pnu_part = GGR.cod_partido
									AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
									WHERE	((GGR.cod_clase_garantia = 18) 
										OR (GGR.cod_clase_garantia BETWEEN 20 AND 29))
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
															WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																		OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																		OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
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
									WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
												OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
												OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
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
			AND ((GGR.cod_clase_garantia BETWEEN 30 AND 37)
					OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
					OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))

		
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
										GGR.Identificacion_Alfanumerica_Sicc,
										MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion
									FROM	dbo.GAR_GARANTIA_REAL GGR 
										INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
															MAX(MG2.prmgt_pfeavaing) AS prmgt_pfeavaing
													FROM	
													(		SELECT	MG1.prmgt_pcoclagar,
																MG1.prmgt_pnuidegar,
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
																MG1.prmgt_pnuide_alf,
																CASE 
																	WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																	WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																	ELSE '19000101'
																END AS prmgt_pfeavaing
															FROM	dbo.GAR_SICC_PRMGT MG1
															WHERE	((MG1.prmgt_pcoclagar = 38)
																		OR (MG1.prmgt_pcoclagar = 43))
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
													GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing) MGT
									ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
									AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
									AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
									WHERE	((GGR.cod_clase_garantia = 38)
												OR (GGR.cod_clase_garantia = 43))
									GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc
								) GHC
					ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
					AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
					AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				WHERE	GHC.fecha_valuacion > '19000101') TM1
				ON TM1.cod_garantia_real = GVR.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.fecha_valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 38)
				OR (GGR.cod_clase_garantia = 43))
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
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
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
			COALESCE(GVR.monto_tasacion_actualizada_terreno,0) + COALESCE(GVR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE WHEN CONVERT(VARCHAR(10),GVR.fecha_construccion,103) = '01/01/1900' THEN ''
				 ELSE CONVERT(VARCHAR(10),GVR.fecha_construccion,103)
			END AS fecha_construccion,
			GGR.cod_grado,
			GGR.cedula_hipotecaria,
			GGR.cod_clase_garantia,
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
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
							AND COALESCE(TGR.cod_bien, '')		= COALESCE(TOD.cod_garantia_sicc, '')
							AND COALESCE(TGR.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
			AND COALESCE(TM1.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	TM1.cod_llave = (	SELECT	MIN(TM2.cod_llave)
									FROM	dbo.TMP_GARANTIAS_REALES TM2
									WHERE	TM2.cod_oficina					= TOD.cod_oficina
										AND TM2.cod_moneda					= TOD.cod_moneda
										AND TM2.cod_producto				= TOD.cod_producto
										AND TM2.operacion					= TOD.operacion
										AND COALESCE(TM2.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
										AND COALESCE(TM2.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
							AND COALESCE(TGR.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND COALESCE(TGR.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
			AND COALESCE(TM1.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
			AND TM1.cod_grado					= TOD.cod_grado
		WHERE	TM1.cod_llave = (SELECT	MIN(TM2.cod_llave)
								FROM	dbo.TMP_GARANTIAS_REALES TM2
								WHERE	TM2.cod_oficina					= TOD.cod_oficina
									AND TM2.cod_moneda					= TOD.cod_moneda
									AND TM2.cod_producto				= TOD.cod_producto
									AND TM2.operacion					= TOD.operacion
									AND COALESCE(TM2.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
									AND TM2.cod_grado					= TOD.cod_grado
									AND COALESCE(TM2.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
							AND COALESCE(TGR.numero_finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
							AND TGR.cod_grado					= TOD.cod_grado
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND COALESCE(TGR.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
			AND COALESCE(TM1.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	TM1.cod_llave = (SELECT MIN(TM2.cod_llave)
								FROM dbo.TMP_GARANTIAS_REALES TM2
								WHERE TM2.cod_oficina					= TOD.cod_oficina
									AND TM2.cod_moneda					= TOD.cod_moneda
									AND TM2.cod_producto				= TOD.cod_producto
									AND TM2.operacion					= TOD.operacion
									AND COALESCE(TM2.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
									AND COALESCE(TM2.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
							AND COALESCE(TGR.num_placa_bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
							AND TGR.cod_llave					<> TOD.cod_garantia
							AND COALESCE(TGR.cod_usuario, '')		= COALESCE(TOD.cod_usuario, '')
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
		
		
	END
	
	IF(@piEjecutarParte = 3)
	BEGIN
	
		DECLARE @vdFechaActualSinHora	DATETIME  
		SET @vdFechaActualSinHora		= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
							
		
		DECLARE @TMP_PORCENTAJE_ACEPTACION_CALCULADO TABLE (
		          
					 Cod_Operacion						BIGINT,
					 Cod_Garantia_Real					BIGINT,
					 Porcentaje_Aceptacion				DECIMAL (5,2),
					 Porcentaje_Calculado_Original      DECIMAL (5,2),
					 Fecha_Valuacion					DATETIME,
					 Fecha_Ultimo_Seguimiento			DATETIME,
					 Cod_Tipo_Garantia_Real				SMALLINT,
					 Cod_Tipo_Bien						SMALLINT,
					 Monto_Ultima_Tasacion_No_Terreno	DECIMAL(18,2),					 
					 Cod_Usuario						VARCHAR(30),
					 Deudor_Habita_Vivienda				BIT
		       
					 )

		INSERT INTO @TMP_PORCENTAJE_ACEPTACION_CALCULADO (           
					 Cod_Operacion,
					 Cod_Garantia_Real,              
					 Porcentaje_Aceptacion,
					 Porcentaje_Calculado_Original,
					 Fecha_Valuacion,
					 Fecha_Ultimo_Seguimiento,
					 Cod_Tipo_Garantia_Real,
					 Cod_Tipo_Bien,
					 Monto_Ultima_Tasacion_No_Terreno,
					 Cod_Usuario,
					 Deudor_Habita_Vivienda		 

					 ) 

		/*Se insertan todos los porcentajes de aceptacion con el monto original del catalogo*/      

		 SELECT	DISTINCT    
			 TGR.cod_operacion,
			 TGR.cod_garantia_real,
			 CPA.Porcentaje_Aceptacion AS Porcentaje_Aceptacion,  
			 CPA.Porcentaje_Aceptacion AS Porcentaje_Calculado_Original,
			 TGR.fecha_valuacion,
			 TGR.fecha_ultimo_seguimiento,
			 TGR.cod_tipo_garantia_real,
			 TGR.cod_tipo_bien,
			 TGR.monto_ultima_tasacion_no_terreno,
			 @psCedula_Usuario,
			 GGR.Indicador_Vivienda_Habitada_Deudor
		     
		 FROM	dbo.TMP_GARANTIAS_REALES TGR   
			INNER JOIN  dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = TGR.cod_tipo_mitigador
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TGR.cod_garantia_real 
		 WHERE	TGR.cod_usuario = @psCedula_Usuario	   
			AND TGR.cod_tipo_operacion = 2
			AND TGR.cod_tipo_bien BETWEEN 1 AND 4			
			
		
		---------------------------------------------------------------------------------
		/*ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDaCIONES */ 
		---------------------------------------------------------------------------------
		------------------------------
		--INDICAROD DE INSCRIPCION
		------------------------------

			--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
			--que no poseen asignado el indicador de inscripción. 
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	= 2
					AND TMGR.fecha_presentacion	IS NOT NULL
					AND TMGR.cod_inscripcion IS NULL
			

			--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
			--supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
						
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	= 2
					AND TMGR.fecha_constitucion	IS NOT NULL
					AND TMGR.cod_inscripcion IS NOT NULL
					AND TMGR.cod_inscripcion = 2 
					AND @vdFechaActualSinHora > DATEADD(DAY, 60, TMGR.fecha_constitucion)


			--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso 
			--(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 días a la fecha de constitución.  
		    			
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion = 2
					AND TMGR.fecha_constitucion IS NOT NULL
					AND TMGR.cod_inscripcion IS NOT NULL
					AND TMGR.cod_inscripcion = 1 
					AND @vdFechaActualSinHora >= DATEADD(DAY, 30, TMGR.fecha_constitucion)


			--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "No Aplica", pero que poseen un tipo de bien
			--diferente a "Otros tipos de bienes". 
				
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion = 2
					AND TMGR.cod_inscripcion IS NOT NULL
					AND TMGR.cod_inscripcion = 0 
					AND TMGR.cod_tipo_bien <> 14								

		------------------------------
		--FIN INDICADOR DE INSCRIPCION
		------------------------------
			
		--------------------------------------------------------------------------
		--SE REDUCEN A 0
		--------------------------------------------------------------------------

		-------------------
		--TIPO DE BIEN: 1
		-------------------
				--------------
				--POLIZA
				--------------	
				
					--POLIZA ASOCIADA
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = 0
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC						
						INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
						ON GPR.cod_operacion = TPAC.Cod_Operacion
						AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real						
						INNER JOIN dbo.GAR_POLIZAS GPO
						ON GPO.Codigo_SAP = GPR.Codigo_SAP
						AND GPO.cod_operacion = GPR.cod_operacion				
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 1	
						AND GPO.Estado_Registro = 1
						AND GPR.Estado_Registro = 1
						AND TPAC.Cod_Usuario = @psCedula_Usuario	  

		-------------------
		--TIPO DE BIEN: 3
		-------------------
				---------------
				--SEGUIMIENTO
				---------------	
					--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
				
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  0
					--FROM @TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3 
					--AND TPAC.Cod_Tipo_Bien = 3							
					--AND  DATEDIFF(YEAR,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 1 
					--AND TPAC.Cod_Usuario =  @psCedula_Usuario	
		        
				--------------
				--VALUACION
				--------------	
					
					--FECHA VALUACION MAYOR A 5 AÑOS
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = 0
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real = 3 
						AND TPAC.Cod_Tipo_Bien = 3							
						AND DATEDIFF(YEAR,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5	
						AND TPAC.Cod_Usuario = @psCedula_Usuario		

		-------------------------------------------------------------------
		--SE REDUCEN A LA MITAD
		-------------------------------------------------------------------
		-------------------
		--TIPO DE BIEN: 1
		-------------------

				---------------
				--SEGUIMIENTO
			   ---------------	
			   
					--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA

					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 1									
						AND DATEDIFF(YEAR,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 1   	            
						AND TPAC.Porcentaje_Aceptacion > 0     
						AND TPAC.Cod_Usuario = @psCedula_Usuario	   
		            
				--------------
				--VALUACION
				--------------
				
					--FECHA VALUACION MAYOR A 5 AÑOS	
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)	
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 1						
						AND DATEDIFF(YEAR,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5	
						AND TPAC.Porcentaje_Aceptacion > 0   
						AND TPAC.Cod_Usuario = @psCedula_Usuario		
			
		-------------------
		--TIPO DE BIEN: 2
		-------------------
				--------------
				--VALUACION
				--------------
				
					--FECHA VALUACION MAYOR A 18 MESES FECHA SISTEMA, MIENTAS EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA, PERO EL DEUDOR NO HABITA LA VIVIENDA 				
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC			
					--WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--	AND TPAC.Cod_Tipo_Bien = 2	
					--	AND  DATEDIFF(MONTH,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 18
					--	AND DATEDIFF(MONTH,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 3
					--	AND TPAC.Deudor_Habita_Vivienda = 0
					--	AND TPAC.Porcentaje_Aceptacion > 0 
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 
					
					
					
					--FECHA VALUACION MAYOR A 18 MESES FECHA SISTEMA, MIENTAS NO EXISTA DIFERENCIA MAYOR A 3 MESES ENTRE FECHA SEGUIMIENTO Y FECHA DEL SISTEMA Y EL DEUDOR HABITA LA VIVIENDA				
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC			
					--WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--	AND TPAC.Cod_Tipo_Bien = 2	
					--	AND  DATEDIFF(MONTH,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 18
					--	AND DATEDIFF(MONTH,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) <= 3
					--	AND TPAC.Deudor_Habita_Vivienda = 1
					--	AND TPAC.Porcentaje_Aceptacion > 0 
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	
					
					--FECHA VALUACION MAYOR A 5 AÑOS FECHA SISTEMA				
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC			
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 2	
						AND  DATEDIFF(YEAR,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5
						AND TPAC.Porcentaje_Aceptacion > 0 
						AND TPAC.Cod_Usuario = @psCedula_Usuario	
						
				---------------
				--SEGUIMIENTO
				---------------
				
					--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)		
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 2
						AND DATEDIFF(YEAR,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 1 
						AND COALESCE(TPAC.Deudor_Habita_Vivienda, 0) = 0	
						AND TPAC.Porcentaje_Aceptacion > 0   
						AND TPAC.Cod_Usuario = @psCedula_Usuario	
					
				--------------
				--POLIZA
				--------------
					--NO TIENE POLIZA ASOCIADA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					--WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--	AND TPAC.Cod_Tipo_Bien = 2			
					--	AND NOT EXISTS (SELECT	1
					--					FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--					WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--						AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real
					--						AND GPR.Estado_Registro = 1)
					--	 AND TPAC.Porcentaje_Aceptacion > 0 
					--	 AND TPAC.Cod_Usuario = @psCedula_Usuario	  
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real						
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--	AND TPAC.Cod_Tipo_Bien = 2	
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1				
					--	AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					--	AND TPAC.Porcentaje_Aceptacion > 0
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	   
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real						
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--	AND TPAC.Cod_Tipo_Bien = 2
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1
					--	AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--	AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					--	AND TPAC.Porcentaje_Aceptacion > 0 
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	  
					
					
		-------------------
		--TIPO DE BIEN: 3
		-------------------					
				--------------
				--POLIZA
				--------------
				--NO TIENE POLIZA ASOCIADA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC				
					--WHERE	TPAC.Cod_Tipo_Garantia_Real = 3
					--	AND TPAC.Cod_Tipo_Bien = 3			
					--	AND NOT EXISTS (SELECT	1
					--					FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--					WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--						AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real	
					--						AND GPR.Estado_Registro = 1)
					--	AND TPAC.Porcentaje_Aceptacion > 0
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	   				
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					--	INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					--	ON TPAC.Cod_Garantia_Real = TPAC.Cod_Garantia_Real	
					--	AND TPAC.Cod_Operacion = TPAC.Cod_Operacion				
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE	TPAC.Cod_Tipo_Garantia_Real = 3
					--	AND TPAC.Cod_Tipo_Bien = 3	
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1			
					--	AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					--	AND TPAC.Porcentaje_Aceptacion > 0  
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE  TPAC.Cod_Tipo_Garantia_Real = 3
					--	AND TPAC.Cod_Tipo_Bien = 3
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1
					--	AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--	AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					--	AND TPAC.Porcentaje_Aceptacion > 0  
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 						
						
		-------------------
		--TIPO DE BIEN: 4
		-------------------
				---------------
				--SEGUIMIENTO
				---------------			
					--FECHA SEGUIMIENTO MAYOR A 6 MESES CONTRA SISTEMA
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real = 3 
						AND TPAC.Cod_Tipo_Bien = 4								
						AND DATEDIFF(MONTH,TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 6 
						AND TPAC.Porcentaje_Aceptacion > 0 
						AND TPAC.Cod_Usuario = @psCedula_Usuario	  
					
				--------------
				--VALUACION
				--------------	
				
					--FECHA VALUACION MAYOR A 5 AÑOS
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real = 3 
						AND TPAC.Cod_Tipo_Bien = 4				
						AND DATEDIFF(YEAR,TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5	
						AND TPAC.Porcentaje_Aceptacion > 0
						AND TPAC.Cod_Usuario = @psCedula_Usuario	   					
					
				--------------
				--POLIZA
				--------------
				--NO TIENE POLIZA ASOCIADA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					--WHERE	TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 4		
					--AND NOT EXISTS (SELECT	1
					--				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--				WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--					AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real
					--					AND GPR.Estado_Registro = 1	)
					--AND TPAC.Porcentaje_Aceptacion > 0   
					--AND TPAC.Cod_Usuario = @psCedula_Usuario	
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE	TPAC.Cod_Tipo_Garantia_Real = 3
					--	AND TPAC.Cod_Tipo_Bien = 4
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1				
					--	AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					--	AND TPAC.Porcentaje_Aceptacion > 0  
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM	@TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--	INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--	INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE	TPAC.Cod_Tipo_Garantia_Real = 3
					--	AND TPAC.Cod_Tipo_Bien = 4
					--	AND GPO.Estado_Registro = 1
					--	AND GPR.Estado_Registro = 1
					--	AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--	AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					--	AND TPAC.Porcentaje_Aceptacion > 0 
					--	AND TPAC.Cod_Usuario = @psCedula_Usuario	  
					
		---------------------------------------------------------------------------------
		/* FIN ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDaCIONES */
		---------------------------------------------------------------------------------

		/* ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION DE LA TABLA TEMPORAL PRINCIPAL */ 

			UPDATE	TGR
			SET		TGR.porcentaje_responsabilidad = 
						(
							CASE 
								WHEN COALESCE(TGR.porcentaje_responsabilidad ,0)= 0 THEN TPAC.Porcentaje_Aceptacion
								WHEN TGR.porcentaje_responsabilidad >  TPAC.Porcentaje_Aceptacion THEN TPAC.Porcentaje_Aceptacion
								WHEN TPAC.Porcentaje_Aceptacion > TGR.porcentaje_responsabilidad  THEN TGR.porcentaje_responsabilidad	
								WHEN TPAC.Porcentaje_Aceptacion = TGR.porcentaje_responsabilidad  THEN TGR.porcentaje_responsabilidad													
							END			
						)	
			FROM	TMP_GARANTIAS_REALES TGR
				INNER JOIN @TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
				ON TGR.cod_operacion = TPAC.Cod_Operacion
				AND TGR.cod_garantia_real = TPAC.Cod_Garantia_Real	
			WHERE	TGR.cod_usuario = @psCedula_Usuario			
				AND TGR.cod_tipo_operacion = 2
			

		
/***************************************************************************************************************************************************/

		/*Se seleccionan los datos de salida para el usuario que genera la información*/
		SELECT DISTINCT
			TGR.cod_contabilidad AS CONTABILIDAD,
			TGR.cod_oficina AS OFICINA,
			TGR.cod_moneda AS MONEDA,
			TGR.cod_producto AS PRODUCTO,
			TGR.operacion AS OPERACION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_bien)), '') AS TIPO_BIEN,
			COALESCE((CONVERT(VARCHAR(50), TGR.cod_bien)), '') AS CODIGO_BIEN,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_mitigador)), '') AS TIPO_MITIGADOR,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_documento_legal)), '') AS TIPO_DOCUMENTO_LEGAL,
			COALESCE((CONVERT(VARCHAR(50),(MAX(TGR.monto_mitigador)))), '') AS MONTO_MITIGADOR,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_presentacion, 103)), '') AS FECHA_PRESENTACION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_inscripcion)), '') AS INDICADOR_INSCRIPCION,
			COALESCE((CONVERT(VARCHAR(50), TGR.porcentaje_responsabilidad)), '') AS PORCENTAJE_ACEPTACION,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_constitucion, 103)), '') AS FECHA_CONSTITUCION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_grado_gravamen)), '') AS GRADO_GRAVAMEN,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_acreedor)), '') AS TIPO_PERSONA_ACREEDOR,
			COALESCE(TGR.cedula_acreedor, '') AS CEDULA_ACREEDOR,
			COALESCE((CONVERT(VARCHAR(10), (MAX(TGR.fecha_vencimiento)), 103)), '') AS FECHA_VENCIMIENTO,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_operacion_especial)), '') AS OPERACION_ESPECIAL,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_valuacion, 103)), '') AS FECHA_VALUACION,
			COALESCE(TGR.cedula_empresa, '') AS CEDULA_EMPRESA,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_empresa)), '') AS TIPO_PERSONA_EMPRESA,
			COALESCE(TGR.cedula_perito, '') AS CEDULA_PERITO,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_tipo_perito)), '')AS TIPO_PERSONA_PERITO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_terreno)), '') AS MONTO_ULTIMA_TASACION_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_ultima_tasacion_no_terreno)), '') AS MONTO_ULTIMA_TASACION_NO_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_TERRENO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_tasacion_actualizada_no_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_ultimo_seguimiento, 103)), '') AS FECHA_ULTIMO_SEGUIMIENTO,
			COALESCE((CONVERT(VARCHAR(50), TGR.monto_total_avaluo)), '') AS MONTO_TOTAL_AVALUO,
			COALESCE((CONVERT(VARCHAR(10), TGR.fecha_construccion, 103)), '') AS FECHA_CONSTRUCCION,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_grado)), '') AS COD_GRADO,
			COALESCE(TGR.cedula_hipotecaria, '') AS CEDULA_HIPOTECARIA,
			COALESCE(TGR.cedula_deudor, '') AS CEDULA_DEUDOR,
			COALESCE(GD1.nombre_deudor, '') AS NOMBRE_DEUDOR,
			COALESCE((CONVERT(VARCHAR(5), MPC.bsmpc_dco_ofici)), '') AS OFICINA_DEUDOR,
			COALESCE((CONVERT(VARCHAR(3), TGR.cod_clase_garantia)), '') AS TIPO_GARANTIA,
			TGR.ind_operacion_vencida AS ES_CONTRATO_VENCIDO,
			COALESCE((CONVERT(VARCHAR(100), TMP.Codigo_SAP)), '') AS CODIGO_SAP,
			COALESCE((CONVERT(VARCHAR(100), TMP.Monto_Poliza_Colonizado)), '') AS MONTO_POLIZA,
			COALESCE((CONVERT(VARCHAR(10), TMP.Fecha_Vencimiento, 103)), '') AS FECHA_VENCIMIENTO_POLIZA,
			COALESCE((CONVERT(VARCHAR(5), TMP.Codigo_Tipo_Poliza_Sugef)), '') AS TIPO_POLIZA_SUGEF,
			CASE
				WHEN TMP.Codigo_SAP IS NOT NULL THEN 'S'
				ELSE 'N'
			END AS INDICADOR_POLIZA
		FROM	TMP_GARANTIAS_REALES TGR
			INNER JOIN GAR_SICC_BSMPC MPC
			ON TGR.cedula_deudor = CONVERT(VARCHAR(30), MPC.bsmpc_sco_ident)
			INNER JOIN GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			LEFT OUTER JOIN (SELECT	GPO.Codigo_SAP, GPO.cod_operacion, GPR.cod_garantia_real,
									GPO.Monto_Poliza_Colonizado, GPO.Fecha_Vencimiento, 
									TPB.Codigo_Tipo_Poliza_Sugef, COALESCE(TPB.Codigo_Tipo_Bien, -1) AS Codigo_Tipo_Bien
							 FROM	dbo.GAR_POLIZAS GPO
								INNER JOIN	dbo.GAR_POLIZAS_RELACIONADAS GPR
								ON GPR.Codigo_SAP = GPO.Codigo_SAP
								AND GPR.cod_operacion = GPO.cod_operacion
								LEFT OUTER JOIN dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
								ON TPB.Codigo_Tipo_Poliza_Sap = GPO.Tipo_Poliza
							WHERE	GPO.Estado_Registro = 1
							AND GPR.Estado_Registro = 1) TMP
			ON TMP.cod_operacion = TGR.cod_operacion
			AND TMP.cod_garantia_real = TGR.cod_garantia_real
			AND TMP.Codigo_Tipo_Bien = TGR.cod_tipo_bien
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
			TGR.ind_operacion_vencida,
			TMP.Codigo_SAP,
			TMP.Monto_Poliza_Colonizado,
			TMP.Fecha_Vencimiento,
			TMP.Codigo_Tipo_Poliza_Sugef
		ORDER BY TGR.operacion
	END
END


