USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasReales', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE pa_GenerarInfoGarantiasReales
END
GO

CREATE
 PROCEDURE [dbo].[pa_GenerarInfoGarantiasReales]
	@psCedula_Usuario	VARCHAR(30),
	@piEjecutarParte	TINYINT
	
AS

/*****************************************************************************************************************************************************
	<Nombre>pa_GenerarInfoGarantiasReales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Genera parte de la información de las Garantías Reales.
	</Descripción>
	<Entradas>
			@psCedula_Usuario		= Identificación del usuario que realiza la consulta. 
									  Este es dato llave usado para la búsqueda de los registros que deben 
                                      ser eliminados de la tabla temporal.
            @piEjecutarParte		= Indica la parte del procedimiento almacenado que será ejecutada, esto con el fin de agilizar el proceso de 
									  generación.
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>18/06/2008</Fecha>
			<Descripción>
				Se optimizan los cursores utilizados, con el fin de que consuman menos tiempo.
		</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>17/11/2010</Fecha>
			<Descripción>
					Se realizan varios ajustes de optimización del proceso.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
			    Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841</Requerimiento>
			<Fecha>12/03/2014</Fecha>
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
			<Requerimiento>
					Ajustes en Procedimientos Almacenados de BCRGarantías, Siebel No. 1-24330461.
			</Requerimiento>
			<Fecha>30/05/2014</Fecha>
			<Descripción>
					Se realiza eliminan las referecnias al a base de datos . 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/
BEGIN

SET NOCOUNT ON

DECLARE 
	@nOperacion2			BIGINT,
	@nGarantia				BIGINT,
	@nTipoGarantiaReal		TINYINT,
	@strFinca				VARCHAR(25),
	@strGrado				VARCHAR(2),
	@strPlacaBien			VARCHAR(25),
	@nTipoDocumentoLegal	SMALLINT,
	@strFincaAnterior		VARCHAR(25),
	@strGradoAnterior		VARCHAR(2),
	@strPlacaBienAnterior	VARCHAR(25),
	@nOperacionAnterior		BIGINT,
	@lid					UNIQUEIDENTIFIER,
	@lfecHoySinHora			DATETIME,
	@lintFechaEntero		INT


	IF(@piEjecutarParte = 0)
	BEGIN
	
		--Se limpian las tablas temporales
		DELETE FROM dbo.GAR_GIROS_GARANTIAS_REALES

		--Se insertan las garantias reales
		INSERT	INTO dbo.GAR_GIROS_GARANTIAS_REALES(cod_contabilidad, cod_oficina, cod_moneda, cod_producto, 
				operacion, cod_tipo_bien, cod_bien, cod_tipo_mitigador, cod_tipo_documento_legal, monto_mitigador,
				fecha_presentacion, cod_inscripcion, porcentaje_responsabilidad, fecha_constitucion, 
				cod_grado_gravamen, cod_tipo_acreedor, cedula_acreedor, fecha_vencimiento, cod_operacion_especial,
				fecha_valuacion, cedula_empresa, cod_tipo_empresa, cedula_perito, cod_tipo_perito, 
				monto_ultima_tasacion_terreno, monto_ultima_tasacion_no_terreno, monto_tasacion_actualizada_terreno,
				monto_tasacion_actualizada_no_terreno, fecha_ultimo_seguimiento, monto_total_avaluo, fecha_construccion,
				cod_grado, cedula_hipotecaria, cod_clase_garantia, cod_operacion, cod_garantia_real,
				cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, cedula_deudor, cod_estado)
		SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
			GGR.cod_tipo_bien, 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN CONVERT(VARCHAR(2),GGR.cod_partido) + GGR.numero_finca  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN CONVERT(VARCHAR(2),GGR.cod_partido) + GGR.numero_finca  
				WHEN GGR.cod_tipo_garantia_real = 3 THEN ISNULL(GGR.cod_clase_bien, '') + GGR.num_placa_bien 
			END AS cod_bien, 
			GRO.cod_tipo_mitigador, 
			CASE 
				WHEN cod_tipo_documento_legal = -1 THEN NULL
				ELSE GRO.cod_tipo_documento_legal 
			END AS cod_tipo_documento_legal,
			GRO.monto_mitigador, 
			CASE 
				WHEN GRO.fecha_presentacion IS NULL THEN ''
				WHEN GRO.fecha_presentacion = '19000101' THEN ''
				ELSE CONVERT(VARCHAR(10),GRO.fecha_presentacion,103)
			END AS fecha_presentacion,
			GRO.cod_inscripcion, 
			GRO.porcentaje_responsabilidad, 
			CASE 
				WHEN GRO.fecha_constitucion IS NULL THEN ''
				WHEN  GRO.fecha_constitucion = '19000101' THEN ''
				ELSE  CONVERT(VARCHAR(10),GRO.fecha_constitucion,103)
			END AS fecha_constitucion, 
			GRO.cod_grado_gravamen, 
			GRO.cod_tipo_acreedor, 
			GRO.cedula_acreedor, 
			CASE 
				WHEN GRO.fecha_vencimiento IS NULL THEN ''
				WHEN GRO.fecha_vencimiento = '19000101' THEN ''
				ELSE CONVERT(VARCHAR(10),GRO.fecha_vencimiento,103)
			END AS fecha_vencimiento, 
			GRO.cod_operacion_especial, 
			CASE 
				WHEN GVR.fecha_valuacion IS NULL THEN ''
				WHEN GVR.fecha_valuacion = '19000101' THEN ''
				ELSE CONVERT(VARCHAR(10),GVR.fecha_valuacion,103)
			END AS fecha_valuacion, 
			GVR.cedula_empresa, 
			CASE 
				WHEN GVR.cedula_empresa IS NULL THEN NULL 
				ELSE 2 
			END AS cod_tipo_empresa, 
			GVR.cedula_perito, 
			GPE.cod_tipo_persona AS cod_tipo_perito, 
			GVR.monto_ultima_tasacion_terreno, 
			GVR.monto_ultima_tasacion_no_terreno, 
			GVR.monto_tasacion_actualizada_terreno, 
			GVR.monto_tasacion_actualizada_no_terreno, 
			CASE 
				WHEN GVR.fecha_ultimo_seguimiento IS NULL THEN ''
				WHEN GVR.fecha_ultimo_seguimiento = '19000101' THEN ''
				ELSE CONVERT(VARCHAR(10),GVR.fecha_ultimo_seguimiento,103)
			END AS fecha_ultimo_seguimiento, 
			ISNULL(GVR.monto_tasacion_actualizada_terreno,0) + ISNULL(GVR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE 
				WHEN GVR.fecha_construccion IS NULL THEN ''
				WHEN GVR.fecha_construccion = '19000101' THEN ''
				ELSE CONVERT(VARCHAR(10),GVR.fecha_construccion,103)
			END AS fecha_construccion,
			CASE 
				WHEN GGR.cod_grado = -1 THEN NULL
				ELSE GGR.cod_grado
			END AS cod_grado,
			GGR.cedula_hipotecaria,
			GGR.cod_clase_garantia,
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			ISNULL(GGR.numero_finca,'') AS numero_finca,
			ISNULL(GGR.num_placa_bien,'') AS num_placa_bien,
			ISNULL(GGR.cod_clase_bien,'') AS cod_clase_bien,
			GO1.cedula_deudor,
			1 AS cod_estado 
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 	
			ON GO1.cod_operacion = GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 	
			ON GRO.cod_garantia_real = GGR.cod_garantia_real 
			LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GGR.cod_garantia_real = GVR.cod_garantia_real 
			AND GVR.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM dbo.GAR_VALUACIONES_REALES WHERE cod_garantia_real = GGR.cod_garantia_real) 
			LEFT OUTER JOIN dbo.GAR_PERITO GPE 
			ON GVR.cedula_perito = GPE.cedula_perito 
		WHERE	GO1.num_operacion IS NOT NULL 
			AND GO1.cod_estado = 1 
			AND GRO.cod_estado = 1
			AND EXISTS(	SELECT	1
						FROM	dbo.GAR_SICC_PRMOC MOC
						WHERE	MOC.prmoc_pnu_oper = GO1.num_operacion
							AND MOC.prmoc_pco_ofici = GO1.cod_oficina
							AND MOC.prmoc_pco_moned = GO1.cod_moneda 
							AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
							AND MOC.prmoc_pnu_contr = GO1.num_contrato
							AND ((MOC.prmoc_pcoctamay < 815)
								OR (MOC.prmoc_pcoctamay > 815))
							AND MOC.prmoc_pse_proces = 1 
							AND MOC.prmoc_estado = 'A' 
							AND ((MOC.prmoc_psa_actual < 0)
								OR (MOC.prmoc_psa_actual > 0)))



		DECLARE Garantias_Cursor CURSOR	FAST_FORWARD
		FOR 
		SELECT  cod_operacion,
			cod_garantia_real,
			cod_tipo_garantia_real,
			numero_finca,
			cod_grado,
			num_placa_bien,
			cod_tipo_documento_legal,
			cod_llave
		FROM	dbo.GAR_GIROS_GARANTIAS_REALES
		ORDER BY
			cod_operacion,
			numero_finca,
			cod_grado,
			cod_clase_bien,
			num_placa_bien,
			cod_tipo_documento_legal DESC

		OPEN Garantias_Cursor
		FETCH NEXT FROM Garantias_Cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, @strFinca, 
			@strGrado, @strPlacaBien, @nTipoDocumentoLegal, @lid

		SET @strFincaAnterior = ''
		SET @strGradoAnterior = ''
		SET @strPlacaBienAnterior = ''
		SET @nOperacionAnterior = -1

		WHILE @@FETCH_STATUS = 0 
		BEGIN
				--Hipotecas
				IF (@nTipoGarantiaReal = 1) 
				BEGIN
					IF (@nOperacionAnterior = @nOperacion2) 
					BEGIN
						IF (@strFincaAnterior = @strFinca) 
						BEGIN
							
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @lid
							
						END
					END
				END
				--Cédulas 
				IF (@nTipoGarantiaReal = 2) 
				BEGIN
					IF (@nOperacionAnterior = @nOperacion2) 
					BEGIN
						IF (@strFincaAnterior != @strFinca) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @lid

						END
						ELSE IF ((@strFincaAnterior = @strFinca) AND (@strGradoAnterior != @strGrado)) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @lid
							
						END
						ELSE IF ((@strFincaAnterior = @strFinca) AND (@strGradoAnterior = @strGrado)) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @lid
							
						END
					END
					ELSE 
					BEGIN
					
						UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
						SET		cod_estado = 1
						WHERE	cod_llave = @lid
						
					END
				END
				--Prendas
				ELSE IF (@nTipoGarantiaReal = 3) 
				BEGIN
					IF (@nOperacionAnterior = @nOperacion2) 
					BEGIN
						IF (@strPlacaBienAnterior != @strPlacaBien) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @lid
							
						END
						ELSE 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @lid
							
						END	
					END
					ELSE 
					BEGIN
					
						UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
						SET		cod_estado = 1
						WHERE	cod_llave = @lid
						
					END
				END 
						
				SET @strFincaAnterior = @strFinca
				SET @strGradoAnterior = @strGrado
				SET @strPlacaBienAnterior = @strPlacaBien
				SET @nOperacionAnterior = @nOperacion2
			      
				FETCH NEXT FROM Garantias_Cursor INTO @nOperacion2, @nGarantia, @nTipoGarantiaReal, 
				@strFinca, @strGrado, @strPlacaBien, @nTipoDocumentoLegal, @lid
		END

		CLOSE Garantias_Cursor
		DEALLOCATE Garantias_Cursor
	
	END
	ELSE IF(@piEjecutarParte = 1)
	BEGIN
		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_usuario	= @psCedula_Usuario 
	
		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_usuario	= @psCedula_Usuario 

		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario	= @psCedula_Usuario
		
		DELETE	FROM dbo.TMP_VALUACIONES_REALES 
		WHERE	cod_usuario	= @psCedula_Usuario 


		/*Variable que servirá para almacenar los datos de la estructura PRMOC*/
		DECLARE	@ptPRMOC TABLE(	prmoc_pco_conta  TINYINT,
								prmoc_pco_ofici  SMALLINT,
								prmoc_pco_moned  TINYINT,
								prmoc_pco_produ  TINYINT,
								prmoc_pnu_oper   INT,
								prmoc_pnu_contr  INT,
								prmoc_pco_oficon SMALLINT,
								prmoc_pcomonint  SMALLINT,
								cod_operacion    BIGINT
								PRIMARY KEY (prmoc_pco_conta, 
											 prmoc_pco_ofici, 
											 prmoc_pco_moned, 
											 prmoc_pco_produ, 
											 prmoc_pnu_oper, 
											 prmoc_pnu_contr,
											 prmoc_pco_oficon,
											 prmoc_pcomonint,
											 cod_operacion)
							  )


		/*Variable que servirá para almacenar los datos de la estructura PRMCA*/
		DECLARE	@ptPRMCA TABLE(	prmca_pco_ofici  SMALLINT,
								prmca_pco_moned  TINYINT,
								prmca_pco_produc TINYINT,
								prmca_pnu_contr  INT,
								cod_operacion    BIGINT
								PRIMARY KEY (prmca_pco_ofici, 
											 prmca_pco_moned, 
											 prmca_pco_produc, 
											 prmca_pnu_contr, 
											 cod_operacion)
							  )
		
		
		SET @lfecHoySinHora	= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		SET @lintFechaEntero = CONVERT(INT, CONVERT(VARCHAR(8), @lfecHoySinHora, 112))


	/***************************************************************************************************************************************************/

		--Se eliminan los registros que fueron seteados a 2
		DELETE	FROM dbo.GAR_GIROS_GARANTIAS_REALES
		WHERE	cod_estado = 2
		
		/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
		INSERT	@ptPRMOC
		SELECT	DISTINCT MOC.prmoc_pco_conta, 
						 MOC.prmoc_pco_ofici, 
						 MOC.prmoc_pco_moned, 
						 MOC.prmoc_pco_produ, 
						 MOC.prmoc_pnu_oper, 
						 MOC.prmoc_pnu_contr,
						 MOC.prmoc_pco_oficon,
						 MOC.prmoc_pcomonint,
						 GO1.cod_operacion
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA	
			ON GO1.cod_operacion = GRA.cod_operacion 
			INNER JOIN dbo.GAR_SICC_PRMOC MOC 
			ON	MOC.prmoc_pco_conta	= GO1.cod_contabilidad
			AND MOC.prmoc_pco_ofici = GO1.cod_oficina
			AND MOC.prmoc_pco_moned = GO1.cod_moneda
			AND MOC.prmoc_pco_produ = GO1.cod_producto
			AND MOC.prmoc_pnu_oper = GO1.num_operacion
		WHERE	MOC.prmoc_pse_proces = 1 
			AND MOC.prmoc_estado = 'A'
			AND ((MOC.prmoc_pcoctamay < 815)
				OR (MOC.prmoc_pcoctamay > 815))
			AND GO1.num_operacion IS NOT NULL 
			AND GO1.cod_estado = 1 

			/*Se obtienen los contratos que poseen giros activos*/
			INSERT	@ptPRMCA
			SELECT	DISTINCT 
				MCA.prmca_pco_ofici,
				MCA.prmca_pco_moned,
				MCA.prmca_pco_produc,
				MCA.prmca_pnu_contr,
				GO1.cod_operacion
			FROM	@ptPRMOC MOC
				INNER JOIN dbo.GAR_SICC_PRMCA MCA
				ON MCA.prmca_pco_ofici = MOC.prmoc_pco_oficon
				AND MCA.prmca_pco_moned = MOC.prmoc_pcomonint
				AND MCA.prmca_pnu_contr = MOC.prmoc_pnu_contr
				INNER JOIN dbo.GAR_OPERACION GO1
				ON GO1.cod_oficina = MCA.prmca_pco_ofici
				AND GO1.cod_moneda = MCA.prmca_pco_moned
				AND GO1.cod_producto = MCA.prmca_pco_produc
				AND GO1.num_contrato = MCA.prmca_pnu_contr
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
				ON GO1.cod_operacion = GRA.cod_operacion 
			WHERE	MOC.prmoc_pnu_oper IS NOT NULL 
				AND MOC.prmoc_pnu_contr > 0
				AND MCA.prmca_estado = 'A'
				AND GO1.num_contrato > 0
				AND GO1.num_operacion IS NULL
		   
			/*Se obtienen las operaciones activas que posean una garantía real asociada*/	
			INSERT	INTO dbo.TMP_OPERACIONES (
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
			SELECT	DISTINCT 
				MOC.cod_operacion, 
				GRA.cod_garantia_real,
				2 AS cod_tipo_garantia,
				CASE 
					WHEN MOC.prmoc_pnu_contr > 0 THEN 3
					ELSE 1
				END AS cod_tipo_operacion, 
				NULL AS ind_contrato_vencido,
				NULL AS ind_contrato_vencido_giros_activos,
				MOC.prmoc_pco_ofici,
				MOC.prmoc_pco_moned,
				MOC.prmoc_pco_produ,
				MOC.prmoc_pnu_oper,
				MOC.prmoc_pnu_contr,
				@psCedula_Usuario AS cod_usuario
			FROM	@ptPRMOC MOC
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
				ON MOC.cod_operacion = GRA.cod_operacion
			WHERE	GRA.cod_estado	=	CASE	
											WHEN MOC.prmoc_pnu_contr > 0 THEN GRA.cod_estado
											ELSE 1
										END

			/*Se obtienen los contratos y las garantías relacionadas a estos*/
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
			SELECT	DISTINCT 
				MCA.cod_operacion, 
				GRA.cod_garantia_real,
				2 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion, 
				NULL AS ind_contrato_vencido,
				NULL AS ind_contrato_vencido_giros_activos,
				MCA.prmca_pco_ofici,
				MCA.prmca_pco_moned,
				MCA.prmca_pco_produc,
				NULL AS num_operacion,
				MCA.prmca_pnu_contr,
				@psCedula_Usuario AS cod_usuario
			FROM	@ptPRMCA MCA
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
				ON GRA.cod_operacion = MCA.cod_operacion

			/*Se obtienen los giros asociados a los contratos y se les asigna las garantías relacionadas a este último*/
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
				cod_oficina_contrato, 
				cod_moneda_contrato, 
				cod_producto_contrato,
				cod_usuario)
			SELECT	DISTINCT 
				GO1.cod_operacion, 
				TMP.cod_garantia,
				2 AS cod_tipo_garantia,
				CASE 
					WHEN PRM.prmoc_pnu_contr > 0 THEN 3
					ELSE 1
				END AS cod_tipo_operacion, 
				NULL AS ind_contrato_vencido,
				NULL AS ind_contrato_vencido_giros_activos,
				GO1.cod_oficina,
				GO1.cod_moneda,
				GO1.cod_producto,
				GO1.num_operacion,
				GO1.num_contrato,
				TMP.cod_oficina AS cod_oficina_contrato,
				TMP.cod_moneda AS cod_moneda_contrato,
				TMP.cod_producto AS cod_producto_contrato,
				@psCedula_Usuario AS cod_usuario
			FROM	@ptPRMOC PRM
				INNER JOIN dbo.GAR_OPERACION GO1 
				ON	GO1.cod_contabilidad = PRM.prmoc_pco_conta
				AND GO1.cod_oficina = PRM.prmoc_pco_ofici
				AND GO1.cod_moneda = PRM.prmoc_pco_moned
				AND GO1.cod_producto = PRM.prmoc_pco_produ
				AND GO1.num_operacion = PRM.prmoc_pnu_oper
				INNER JOIN dbo.TMP_OPERACIONES TMP 
				ON TMP.cod_oficina = PRM.prmoc_pco_oficon
				AND TMP.cod_moneda = PRM.prmoc_pcomonint
				AND TMP.num_contrato = PRM.prmoc_pnu_contr
			WHERE	PRM.prmoc_pnu_contr > 0
				AND GO1.cod_estado = 1 
				AND GO1.num_contrato > 0
				AND TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario

			/*Se eliminan los contratos que fueron cargados*/
			DELETE	FROM dbo.TMP_OPERACIONES 
			WHERE	cod_tipo_garantia = 2 
				AND cod_tipo_operacion = 2
				AND cod_usuario = @psCedula_Usuario 
		END
		ELSE IF(@piEjecutarParte = 2)
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
				AND TMP.cod_tipo_operacion = 1
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
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_clase_garantia BETWEEN 30 AND 69

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
				AND TMP.cod_tipo_operacion = 3
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
				AND TMP.cod_tipo_operacion = 3
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
				AND TMP.cod_tipo_operacion = 3
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_clase_garantia BETWEEN 30 AND 69

			/*Se selecciona la información de la garantía real asociada a los contratos*/
			INSERT	INTO dbo.TMP_GARANTIAS_REALES
			SELECT	DISTINCT 
				GO1.cod_contabilidad, 
				GO1.cod_oficina, 
				GO1.cod_moneda, 
				GO1.cod_producto, 
				GO1.num_operacion AS operacion, 
				GGR.cod_tipo_bien, 
				CASE  
					WHEN GGR.cod_tipo_garantia_real = 1 THEN ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN ISNULL((CONVERT(VARCHAR(2),GGR.cod_partido)), '') + ISNULL(GGR.numero_finca, '') 
					WHEN GGR.cod_tipo_garantia_real = 3 THEN ISNULL(GGR.cod_clase_bien, '') + ISNULL(GGR.num_placa_bien, '')
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
					WHEN CONVERT(VARCHAR(10),VGR.fecha_valuacion,103) = '01/01/1900' THEN ''
					ELSE CONVERT(VARCHAR(10),VGR.fecha_valuacion,103)
				END AS fecha_valuacion, 
				VGR.cedula_empresa, 
				CASE 
					WHEN VGR.cedula_empresa IS NULL THEN NULL 
					ELSE 2 END 
				AS cod_tipo_empresa, 
				VGR.cedula_perito, 
				GPR.cod_tipo_persona AS cod_tipo_perito, 
				VGR.monto_ultima_tasacion_terreno, 
				VGR.monto_ultima_tasacion_no_terreno, 
				VGR.monto_tasacion_actualizada_terreno, 
				VGR.monto_tasacion_actualizada_no_terreno, 
				CASE WHEN CONVERT(VARCHAR(10),VGR.fecha_ultimo_seguimiento,103) = '01/01/1900' THEN ''
					 ELSE CONVERT(VARCHAR(10),VGR.fecha_ultimo_seguimiento,103)
				END AS fecha_ultimo_seguimiento, 
				ISNULL(VGR.monto_tasacion_actualizada_terreno,0) + ISNULL(VGR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
				CASE 
					WHEN CONVERT(VARCHAR(10),VGR.fecha_construccion,103) = '01/01/1900' THEN ''
					ELSE CONVERT(VARCHAR(10),VGR.fecha_construccion,103)
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
				NULL AS cod_moneda,
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
				LEFT OUTER JOIN  dbo.TMP_VALUACIONES_REALES VGR
				ON VGR.cod_garantia_real = GGR.cod_garantia_real
				LEFT OUTER JOIN dbo.GAR_PERITO GPR
				ON VGR.cedula_perito = GPR.cedula_perito 
				INNER JOIN dbo.TMP_OPERACIONES TMP
				ON TMP.cod_operacion = GRO.cod_operacion
				AND TMP.cod_garantia = GRO.cod_garantia_real
			WHERE GRO.cod_estado = 1
				AND VGR.cod_usuario = @psCedula_Usuario
				AND TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion IN (1, 3)
				AND TMP.cod_usuario = @psCedula_Usuario

		END
		IF(@piEjecutarParte = 3)
		BEGIN
			/*Se obtienen las operaciones duplicadas*/
			INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
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
			WHERE	cod_usuario	= @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
			GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, cod_bien, cod_tipo_operacion
			HAVING	COUNT(1) > 1

			/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
			  Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
			UPDATE	dbo.TMP_GARANTIAS_REALES 
			SET		ind_duplicidad = 2
			FROM	dbo.TMP_GARANTIAS_REALES GR
			WHERE	GR.cod_usuario = @psCedula_Usuario
				AND GR.cod_tipo_operacion IN (1, 3)
				AND EXISTS (SELECT	1 
							FROM	dbo.TMP_OPERACIONES_DUPLICADAS TGR
							WHERE	ISNULL(TGR.cod_usuario, '') = ISNULL(GR.cod_usuario, '')
								AND TGR.cod_tipo_garantia = 2
								AND TGR.cod_tipo_operacion IN (1, 3)
								AND TGR.cod_oficina = GR.cod_oficina
								AND TGR.cod_moneda = GR.cod_moneda
								AND TGR.cod_producto = GR.cod_producto
								AND TGR.operacion = GR.operacion
								AND ISNULL(TGR.cod_garantia_sicc, '') = ISNULL(GR.cod_bien, '')
								AND GR.cod_tipo_documento_legal IS NULL
								AND GR.fecha_presentacion IS NULL
								AND GR.cod_tipo_mitigador IS NULL
								AND GR.cod_inscripcion IS NULL)
			

			/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
			DELETE	FROM dbo.TMP_GARANTIAS_REALES 
			WHERE	cod_usuario	= @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3) 
				AND ind_duplicidad = 2 
				 
			/*Se eliminan los duplicados obtenidos*/
			DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
			WHERE	cod_usuario = @psCedula_Usuario  
				AND cod_tipo_operacion IN (1, 3)

			/*Se obtienen las garantías reales de hipoteca común duplicadas*/
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
					NULL AS cod_grado
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia_real = 1 
			GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_tipo_operacion
			HAVING	COUNT(1) > 1

			/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
				cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
			UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
			SET		cod_garantia = TM2.cod_llave
			FROM	dbo.TMP_OPERACIONES_DUPLICADAS TM1
				INNER JOIN dbo.TMP_GARANTIAS_REALES TM2
				ON	TM2.cod_oficina = TM1.cod_oficina
				AND TM2.cod_moneda = TM1.cod_moneda
				AND TM2.cod_producto = TM1.cod_producto
				AND TM2.operacion = TM1.operacion
				AND ISNULL(TM2.numero_finca, '') = ISNULL(TM1.cod_garantia_sicc, '')
			WHERE	TM2.cod_usuario = @psCedula_Usuario
				AND TM2.cod_tipo_garantia = 2
				AND TM2.cod_tipo_operacion IN (1, 3)
				AND TM2.cod_tipo_garantia_real = 1
				AND TM2.cod_llave	= (	SELECT	MIN(TM3.cod_llave)
										FROM	dbo.TMP_GARANTIAS_REALES TM3
										WHERE	ISNULL(TM3.cod_usuario, '')	= ISNULL(TM1.cod_usuario, '')
											AND TM3.cod_tipo_operacion IN (1, 3)
											AND TM3.cod_tipo_garantia_real = 1
											AND TM3.cod_oficina = TM1.cod_oficina
											AND TM3.cod_moneda = TM1.cod_moneda
											AND TM3.cod_producto = TM1.cod_producto
											AND TM3.operacion = TM1.operacion
											AND ISNULL(TM3.numero_finca, '') = ISNULL(TM1.cod_garantia_sicc, ''))
											AND TM1.cod_tipo_garantia = 2

			/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
			UPDATE	dbo.TMP_GARANTIAS_REALES
			SET		ind_duplicidad = 2
			FROM	dbo.TMP_GARANTIAS_REALES GR1
			WHERE GR1.cod_usuario = @psCedula_Usuario
				AND GR1.cod_tipo_operacion IN (1, 3)
				AND GR1.cod_tipo_garantia_real = 1
				AND EXISTS (	SELECT 1 
								FROM dbo.TMP_OPERACIONES_DUPLICADAS TGR
								WHERE ISNULL(TGR.cod_usuario, '') = ISNULL(GR1.cod_usuario, '')
									AND TGR.cod_tipo_garantia = 2
									AND TGR.cod_tipo_operacion IN (1, 3)
									AND TGR.cod_oficina	= GR1.cod_oficina
									AND TGR.cod_moneda = GR1.cod_moneda
									AND TGR.cod_producto = GR1.cod_producto
									AND TGR.operacion = GR1.operacion
									AND ISNULL(TGR.cod_garantia_sicc, '') = ISNULL(GR1.numero_finca, '') 
									AND TGR.cod_garantia <> GR1.cod_llave
									AND GR1.cod_tipo_garantia_real	= 1)


			/*Se eliminan los duplicados obtenidos*/
			DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
			WHERE	cod_usuario	= @psCedula_Usuario  
				AND cod_tipo_garantia = 2
				AND cod_tipo_operacion IN (1, 3)

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
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia_real = 2
			GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, numero_finca, cod_grado, cod_tipo_operacion
			HAVING	COUNT(1) > 1

			/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
				cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
			UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
			SET		cod_garantia	= TM2.cod_llave
			FROM	dbo.TMP_OPERACIONES_DUPLICADAS TM1
			INNER JOIN dbo.TMP_GARANTIAS_REALES TM2
			ON	TM2.cod_oficina = TM1.cod_oficina
				AND TM2.cod_moneda = TM1.cod_moneda
				AND TM2.cod_producto = TM1.cod_producto
				AND TM2.operacion = TM1.operacion
				AND ISNULL(TM2.numero_finca, '') = ISNULL(TM1.cod_garantia_sicc, '')
				AND TM2.cod_grado = TM1.cod_grado
			WHERE	TM2.cod_usuario = @psCedula_Usuario
				AND TM2.cod_tipo_operacion IN (1, 3)
				AND TM2.cod_tipo_garantia_real = 2
				AND TM2.cod_llave = (	SELECT	MIN(TM3.cod_llave)
										FROM	dbo.TMP_GARANTIAS_REALES TM3
										WHERE	ISNULL(TM3.cod_usuario, '') = ISNULL(TM1.cod_usuario, '')
											AND TM3.cod_tipo_operacion IN (1, 3)
											AND TM3.cod_oficina = TM1.cod_oficina
											AND TM3.cod_moneda = TM1.cod_moneda
											AND TM3.cod_producto = TM1.cod_producto
											AND TM3.operacion = TM1.operacion
											AND ISNULL(TM3.numero_finca, '') = ISNULL(TM1.cod_garantia_sicc, '')
											AND TM3.cod_grado = TM1.cod_grado
											AND TM3.cod_tipo_garantia_real = 2
											AND TM1.cod_tipo_garantia = 2)

			/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
			UPDATE	dbo.TMP_GARANTIAS_REALES
			SET		ind_duplicidad = 2
			FROM	dbo.TMP_GARANTIAS_REALES TM1
			WHERE	TM1.cod_usuario = @psCedula_Usuario
				AND TM1.cod_tipo_operacion IN (1, 3)
				AND TM1.cod_tipo_garantia_real = 2
				AND EXISTS (	SELECT 1 
								FROM dbo.TMP_OPERACIONES_DUPLICADAS TOD
								WHERE	ISNULL(TOD.cod_usuario, '') = ISNULL(TM1.cod_usuario, '')
									AND TOD.cod_tipo_garantia = 2
									AND TOD.cod_tipo_operacion IN (1, 3)
									AND TOD.cod_oficina = TM1.cod_oficina
									AND TOD.cod_moneda = TM1.cod_moneda
									AND TOD.cod_producto = TM1.cod_producto
									AND TOD.operacion = TM1.operacion
									AND ISNULL(TOD.cod_garantia_sicc, '') = ISNULL(TM1.numero_finca, '')
									AND TOD.cod_grado = TM1.cod_grado
									AND TOD.cod_garantia <> TM1.cod_llave
									AND TM1.cod_tipo_garantia_real = 2
									AND TM1.cod_tipo_operacion IN (1, 3))

			/*Se eliminan los duplicados obtenidos*/
			DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
			WHERE	cod_usuario = @psCedula_Usuario  
				AND cod_tipo_garantia = 2
				AND cod_tipo_operacion IN (1, 3)

			/*Se obtienen las garantías reales de prenda duplicadas*/
			INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
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
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia_real = 3
			GROUP	BY cod_oficina, cod_moneda, cod_producto, operacion, num_placa_bien, cod_tipo_operacion
			HAVING	COUNT(1) > 1

			/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
				cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
			UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
			SET		cod_garantia = TM2.cod_llave
			FROM	dbo.TMP_OPERACIONES_DUPLICADAS TM1
			INNER JOIN dbo.TMP_GARANTIAS_REALES TM2
				ON	TM2.cod_oficina = TM1.cod_oficina
				AND TM2.cod_moneda = TM1.cod_moneda
				AND TM2.cod_producto = TM1.cod_producto
				AND TM2.operacion = TM1.operacion
				AND ISNULL(TM2.num_placa_bien, '') = ISNULL(TM1.cod_garantia_sicc, '')
			WHERE	TM2.cod_usuario = @psCedula_Usuario
				AND TM2.cod_tipo_operacion IN (1, 3)
				AND TM2.cod_tipo_garantia_real = 3
				AND TM2.cod_llave = (	SELECT	MIN(TM3.cod_llave)
										FROM	dbo.TMP_GARANTIAS_REALES TM3
										WHERE	ISNULL(TM3.cod_usuario, '')	= ISNULL(TM1.cod_usuario, '')
											AND TM3.cod_tipo_operacion IN (1, 3)
											AND TM3.cod_oficina	= TM1.cod_oficina
											AND TM3.cod_moneda = TM1.cod_moneda
											AND TM3.cod_producto = TM1.cod_producto
											AND TM3.operacion = TM1.operacion
											AND ISNULL(TM3.num_placa_bien, '')	= ISNULL(TM1.cod_garantia_sicc, '')
											AND TM3.cod_tipo_garantia_real = 3
											AND TM1.cod_tipo_garantia = 2)


			/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
			UPDATE	dbo.TMP_GARANTIAS_REALES
			SET		ind_duplicidad = 2
			FROM	dbo.TMP_GARANTIAS_REALES TM1
			WHERE	TM1.cod_usuario	 = @psCedula_Usuario
				AND TM1.cod_tipo_operacion IN (1, 3)
				AND TM1.cod_tipo_garantia_real = 3
				AND EXISTS (SELECT	1 
							FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
							WHERE	ISNULL(TOD.cod_usuario, '')	= ISNULL(TM1.cod_usuario, '')
								AND TOD.cod_tipo_garantia = 2
								AND TOD.cod_tipo_operacion IN (1, 3)
								AND TOD.cod_oficina = TM1.cod_oficina
								AND TOD.cod_moneda = TM1.cod_moneda
								AND TOD.cod_producto = TM1.cod_producto
								AND TOD.operacion = TM1.operacion
								AND ISNULL(TOD.cod_garantia_sicc, '') = ISNULL(TM1.num_placa_bien, '')
								AND TOD.cod_garantia <> TM1.cod_llave
								AND TM1.cod_tipo_garantia_real	= 3
								AND TM1.cod_tipo_operacion IN (1, 3))

			/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
			DELETE	FROM dbo.TMP_GARANTIAS_REALES 
			WHERE	cod_usuario	= @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND ind_duplicidad = 2 

	/***************************************************************************************************************************************************/

	SELECT	DISTINCT
		GGR.cod_contabilidad AS CONTABILIDAD,
		GGR.cod_oficina AS OFICINA,
		GGR.cod_moneda AS MONEDA,
		GGR.cod_producto AS PRODUCTO,
		GGR.operacion AS OPERACION,
		GGR.cod_tipo_bien AS TIPO_BIEN,
		GGR.cod_bien AS CODIGO_BIEN,
		GGR.cod_tipo_mitigador AS TIPO_MITIGADOR,
		GGR.cod_tipo_documento_legal AS TIPO_DOCUMENTO_LEGAL,
		MAX(GGR.monto_mitigador) AS MONTO_MITIGADOR,
		GGR.fecha_presentacion AS FECHA_PRESENTACION,
		CASE 
			WHEN TMP.cod_inscripcion IS NULL THEN GGR.cod_inscripcion
			ELSE TMP.cod_inscripcion
		END AS INDICADOR_INSCRIPCION,
		CASE 
			WHEN TMP.porcentaje_responsabilidad IS NULL THEN GGR.porcentaje_responsabilidad
			ELSE TMP.porcentaje_responsabilidad
		END AS PORCENTAJE_ACEPTACION,
		GGR.fecha_constitucion AS FECHA_CONSTITUCION,
		GGR.cod_grado_gravamen AS GRADO_GRAVAMEN,
		GGR.cod_tipo_acreedor AS TIPO_PERSONA_ACREEDOR,
		GGR.cedula_acreedor AS CEDULA_ACREEDOR,
		MAX(GGR.fecha_vencimiento) AS FECHA_VENCIMIENTO,
		GGR.cod_operacion_especial AS OPERACION_ESPECIAL,
		ISNULL(TMP.fecha_valuacion, '') AS FECHA_VALUACION,
		ISNULL(TMP.cedula_empresa, '') AS CEDULA_EMPRESA,
		ISNULL((CONVERT(VARCHAR(3),TMP.cod_tipo_empresa)), '') AS TIPO_PERSONA_EMPRESA,
		ISNULL(TMP.cedula_perito, '') AS CEDULA_PERITO,
		ISNULL((CONVERT(VARCHAR(3),TMP.cod_tipo_perito)), '') AS TIPO_PERSONA_PERITO,
		ISNULL((CONVERT(VARCHAR(50),TMP.monto_ultima_tasacion_terreno)), '') AS MONTO_ULTIMA_TASACION_TERRENO,
		ISNULL((CONVERT(VARCHAR(50),TMP.monto_ultima_tasacion_no_terreno)), '') AS MONTO_ULTIMA_TASACION_NO_TERRENO,
		ISNULL((CONVERT(VARCHAR(50),TMP.monto_tasacion_actualizada_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_TERRENO,
		ISNULL((CONVERT(VARCHAR(50),TMP.monto_tasacion_actualizada_no_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
		ISNULL((CONVERT(VARCHAR(50),TMP.fecha_ultimo_seguimiento)), '') AS FECHA_ULTIMO_SEGUIMIENTO,
		ISNULL((CONVERT(VARCHAR(50),TMP.monto_total_avaluo)), '0') AS MONTO_TOTAL_AVALUO,
		ISNULL(TMP.fecha_construccion, '') AS FECHA_CONSTRUCCION,
		GGR.cod_grado AS COD_GRADO,
		GGR.cedula_hipotecaria AS CEDULA_HIPOTECARIA,
		GGR.cedula_deudor AS CEDULA_DEUDOR,
		GGR.cod_clase_garantia AS TIPO_GARANTIA,
		GD1.nombre_deudor AS NOMBRE_DEUDOR,
		MPC.bsmpc_dco_ofici AS OFICINA_DEUDOR,
		CASE
			WHEN GO1.num_contrato > 0 THEN 1
			ELSE 0
		END AS ES_GIRO,
		TMP.cod_garantia_real
	FROM	dbo.GAR_GIROS_GARANTIAS_REALES GGR 
	INNER JOIN dbo.GAR_SICC_BSMPC MPC 
	ON MPC.bsmpc_sco_ident = CONVERT(DECIMAL, GGR.cedula_deudor)
	INNER JOIN dbo.GAR_DEUDOR GD1 
	ON GGR.cedula_deudor = GD1.cedula_deudor
	INNER JOIN dbo.GAR_OPERACION GO1
	ON GO1.cod_operacion = GGR.cod_operacion
	LEFT OUTER JOIN dbo.TMP_GARANTIAS_REALES TMP
	ON TMP.cod_oficina = GGR.cod_oficina
		AND TMP.cod_moneda = GGR.cod_moneda
		AND TMP.cod_producto = GGR.cod_producto
		AND TMP.operacion = GGR.operacion
		AND TMP.cod_clase_garantia = GGR.cod_clase_garantia
		AND TMP.cod_bien = GGR.cod_bien  
	WHERE	GGR.cod_tipo_documento_legal IS NOT NULL
		AND GGR.cod_estado = 1
		AND MPC.bsmpc_estado = 'A'
		AND TMP.cod_usuario = @psCedula_Usuario
	GROUP BY
		GGR.cod_contabilidad, 
		GGR.cod_oficina, 
		GGR.cod_moneda, 
		GGR.cod_producto, 
		GGR.operacion, 
		GGR.cod_tipo_bien, 
		GGR.cod_bien,
		GGR.cod_tipo_mitigador, 
		GGR.cod_tipo_documento_legal, 
		GGR.fecha_presentacion, 
		GGR.cod_inscripcion, 
		GGR.porcentaje_responsabilidad, 
		GGR.fecha_constitucion, 
		GGR.cod_grado_gravamen, 
		GGR.cod_tipo_acreedor, 
		GGR.cedula_acreedor,
		GGR.cod_operacion_especial, 
		GGR.cod_grado, 
		GGR.cedula_hipotecaria, 
		GGR.cedula_deudor, 
		GGR.cod_clase_garantia,
		GD1.nombre_deudor,
		MPC.bsmpc_dco_ofici,
		TMP.cod_inscripcion,
		TMP.porcentaje_responsabilidad,
		TMP.fecha_valuacion,
		TMP.cedula_empresa,
		TMP.cod_tipo_empresa,
		TMP.cedula_perito,
		TMP.cod_tipo_perito,
		TMP.monto_ultima_tasacion_terreno,
		TMP.monto_ultima_tasacion_no_terreno,
		TMP.monto_tasacion_actualizada_terreno,
		TMP.monto_tasacion_actualizada_no_terreno,
		TMP.fecha_ultimo_seguimiento,
		TMP.monto_total_avaluo,
		TMP.fecha_construccion,
		TMP.cod_garantia_real,
		GO1.num_contrato
	END
END
