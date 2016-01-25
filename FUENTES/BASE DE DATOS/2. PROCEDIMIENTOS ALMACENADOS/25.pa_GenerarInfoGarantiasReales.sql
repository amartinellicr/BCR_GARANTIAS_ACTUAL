USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoGarantiasReales', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.pa_GenerarInfoGarantiasReales
END
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoGarantiasReales]
	@psCedula_Usuario	VARCHAR(30),
	@piEjecutar_Parte	TINYINT
	
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
            @piEjecutar_Parte		= Indica la parte del procedimiento almacenado que será ejecutada, esto con el fin de agilizar el proceso de 
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
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Req_Pólizas, Siebel No. 1-24342731</Requerimiento>
			<Fecha>19/06/2014</Fecha>
			<Descripción>
					Se agregan los campos referentes a la póliza asociada. 
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
			<Fecha>03/07/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #0 y #2. El cambio es referente a la implementación de placas alfanuméricas, 
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>28/09/2015</Fecha>
			<Descripción>
				Se realiza una optimización general, en donde se crean índices en estructuras y tablas nuevas. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Incidente: 2015092810472305 - Solicitud de pase emergencia optimización de procesos 10472294</Requerimiento>
			<Fecha>06/09/2015</Fecha>
			<Descripción>
				Se modifica la forma en como se obtienen los registros referentes a las valuaciones de la garantía, corresponde a la parte de ejecución igual a 2. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00090 Creación Campos Archivos GaRea y GaReaCo</Requerimiento>
			<Fecha>11/10/2015</Fecha>
			<Descripción>
				Se agregan los siguientes campos a la extracción: Porcentaje_Aceptacion_Terreno, Porcentaje_Aceptacion_No_Terreno, 
				Porcentaje_Aceptacion_Terreno_Calculado, Porcentaje_Aceptacion_No_Terreno_Calculado, Coberturas de bienes.
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
	@viCodigo_Operacion		BIGINT,
	@viCodigo_Garantia		BIGINT,
	@viTipo_Garantia_Real	TINYINT,
	@vsFinca				VARCHAR(25),
	@vcGrado				CHAR(2),
	@vsPlaca_Bien			VARCHAR(25),
	@viTipo_Documento_Legal	SMALLINT,
	@vsFinca_Anterior		VARCHAR(25),
	@vcGrado_Anterior		CHAR(2),
	@vsPlaca_Bien_Anterior	VARCHAR(25),
	@viCodigo_Operacion_Anterior BIGINT,
	@vuiId					UNIQUEIDENTIFIER,
	@vdtFecha_Actual_Sin_Hora DATETIME,
	@viFecha_Actual_Entera	INT

	/*Se inicializan las variables globales*/
	SET @vdtFecha_Actual_Sin_Hora	= CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Actual_Sin_Hora, 112))


	IF(@piEjecutar_Parte = 0)
	BEGIN
	
		/*Esta tabla servirá para almacenar los datos de la estructura PRMOC*/
		CREATE TABLE #TEMP_PRMOC (cod_operacion BIGINT)

		CREATE INDEX TEMP_PRMOC_IX_01 ON #TEMP_PRMOC (cod_operacion)

		/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
		INSERT	#TEMP_PRMOC (cod_operacion)
		SELECT	DISTINCT GO1.cod_operacion
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
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
			AND GO1.num_operacion IS NOT NULL 
			


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
				cod_tipo_garantia_real, numero_finca, num_placa_bien, cod_clase_bien, cedula_deudor, cod_estado, 
				Porcentaje_Aceptacion_Terreno, Porcentaje_Aceptacion_No_Terreno, Porcentaje_Aceptacion_Terreno_Calculado, 
				Porcentaje_Aceptacion_No_Terreno_Calculado, Porcentaje_Aceptacion)
		SELECT	DISTINCT 
			GO1.cod_contabilidad, 
			GO1.cod_oficina, 
			GO1.cod_moneda, 
			GO1.cod_producto, 
			GO1.num_operacion AS operacion, 
			GGR.cod_tipo_bien, 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
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
			COALESCE(GVR.monto_tasacion_actualizada_terreno,0) + COALESCE(GVR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
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
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
			GO1.cedula_deudor,
			1 AS cod_estado,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado, 
			--FIN RQ: RQ_MANT_2015062410418218_00090
			GRO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN #TEMP_PRMOC MOC
			ON MOC.cod_operacion = GO1.cod_operacion
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 	
			ON GRO.cod_operacion = GO1.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 	
			ON GRO.cod_garantia_real = GGR.cod_garantia_real 
			LEFT OUTER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GGR.cod_garantia_real = GVR.cod_garantia_real 
			AND GVR.fecha_valuacion = (SELECT MAX(fecha_valuacion) FROM dbo.GAR_VALUACIONES_REALES WHERE cod_garantia_real = GGR.cod_garantia_real) 
			LEFT OUTER JOIN dbo.GAR_PERITO GPE 
			ON GVR.cedula_perito = GPE.cedula_perito 
		WHERE	GO1.num_operacion IS NOT NULL 
			AND GRO.cod_estado = 1
			

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
		FETCH NEXT FROM Garantias_Cursor INTO @viCodigo_Operacion, @viCodigo_Garantia, @viTipo_Garantia_Real, @vsFinca, 
			@vcGrado, @vsPlaca_Bien, @viTipo_Documento_Legal, @vuiId

		SET @vsFinca_Anterior = ''
		SET @vcGrado_Anterior = ''
		SET @vsPlaca_Bien_Anterior = ''
		SET @viCodigo_Operacion_Anterior = -1

		WHILE @@FETCH_STATUS = 0 
		BEGIN
				--Hipotecas
				IF (@viTipo_Garantia_Real = 1) 
				BEGIN
					IF (@viCodigo_Operacion_Anterior = @viCodigo_Operacion) 
					BEGIN
						IF (@vsFinca_Anterior = @vsFinca) 
						BEGIN
							
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @vuiId
							
						END
					END
				END
				--Cédulas 
				IF (@viTipo_Garantia_Real = 2) 
				BEGIN
					IF (@viCodigo_Operacion_Anterior = @viCodigo_Operacion) 
					BEGIN
						IF (@vsFinca_Anterior != @vsFinca) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @vuiId

						END
						ELSE IF ((@vsFinca_Anterior = @vsFinca) AND (@vcGrado_Anterior != @vcGrado)) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @vuiId
							
						END
						ELSE IF ((@vsFinca_Anterior = @vsFinca) AND (@vcGrado_Anterior = @vcGrado)) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @vuiId
							
						END
					END
					ELSE 
					BEGIN
					
						UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
						SET		cod_estado = 1
						WHERE	cod_llave = @vuiId
						
					END
				END
				--Prendas
				ELSE IF (@viTipo_Garantia_Real = 3) 
				BEGIN
					IF (@viCodigo_Operacion_Anterior = @viCodigo_Operacion) 
					BEGIN
						IF (@vsPlaca_Bien_Anterior != @vsPlaca_Bien) 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 1
							WHERE	cod_llave = @vuiId
							
						END
						ELSE 
						BEGIN
						
							UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
							SET		cod_estado = 2
							WHERE	cod_llave = @vuiId
							
						END	
					END
					ELSE 
					BEGIN
					
						UPDATE	dbo.GAR_GIROS_GARANTIAS_REALES 
						SET		cod_estado = 1
						WHERE	cod_llave = @vuiId
						
					END
				END 
						
				SET @vsFinca_Anterior = @vsFinca
				SET @vcGrado_Anterior = @vcGrado
				SET @vsPlaca_Bien_Anterior = @vsPlaca_Bien
				SET @viCodigo_Operacion_Anterior = @viCodigo_Operacion
			      
				FETCH NEXT FROM Garantias_Cursor INTO @viCodigo_Operacion, @viCodigo_Garantia, @viTipo_Garantia_Real, 
				@vsFinca, @vcGrado, @vsPlaca_Bien, @viTipo_Documento_Legal, @vuiId
		END

		CLOSE Garantias_Cursor
		DEALLOCATE Garantias_Cursor

		--Se eliminan los registros que fueron seteados a 2
		DELETE	FROM dbo.GAR_GIROS_GARANTIAS_REALES
		WHERE	cod_estado = 2

		DROP TABLE #TEMP_PRMOC

	END
	IF(@piEjecutar_Parte = 1)
	BEGIN

		DELETE	FROM dbo.TMP_GARANTIAS_REALES 
		WHERE	cod_usuario	= @psCedula_Usuario 
	
		DELETE	FROM dbo.TMP_OPERACIONES 
		WHERE	cod_usuario	= @psCedula_Usuario 

		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario	= @psCedula_Usuario
		
		DELETE	FROM dbo.TMP_VALUACIONES_REALES 
		WHERE	cod_usuario	= @psCedula_Usuario 
				
		/*Esta tabla servirá para almacenar los datos de la estructura PRMOC*/
		CREATE TABLE #TTEMP_PRMOC (cod_operacion BIGINT, Indicador_Es_Giro BIT)

		CREATE INDEX TEMP_PRMOC_IX_01 ON #TTEMP_PRMOC (cod_operacion, Indicador_Es_Giro)

		/*Esta tabla almacenará los contratos vigentes según el SICC*/
		CREATE TABLE #TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato BIGINT, Cod_Operacion_Giro BIGINT)
		 
		CREATE INDEX TEMP_CONTRATOS_VIGENTES_IX_01 ON #TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato, Cod_Operacion_Giro)
	
		/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
		CREATE TABLE #TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato BIGINT, Cod_Operacion_Giro BIGINT)
		 
		CREATE INDEX TEMP_CONTRATOS_VENCIDOS_GA_IX_01 ON #TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato, Cod_Operacion_Giro)
				
		/*Esta tabla almacenará los giros activos según el SICC*/
		CREATE TABLE #TEMP_GIROS_ACTIVOS (	prmoc_pco_oficon SMALLINT,
											prmoc_pcomonint SMALLINT,
											prmoc_pnu_contr INT,
											cod_operacion BIGINT)
		 
		CREATE INDEX TEMP_GIROS_ACTIVOS_IX_01 ON #TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)

	
		/*Se carga la variable tabla con los datos requeridos sobre las operaciones y giros*/
		INSERT	#TTEMP_PRMOC (cod_operacion, Indicador_Es_Giro)
		SELECT	DISTINCT GO1.cod_operacion,
				CASE 
					WHEN GO1.num_contrato = 0 THEN 0
					ELSE 1
				END AS Indicador_Es_Giro
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
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
			AND GO1.num_operacion IS NOT NULL 


		--Se carga la tabla temporal de giros activos
		INSERT	#TEMP_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr, cod_operacion)
		SELECT	DISTINCT MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr, GO1.cod_operacion
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
			AND ((MOC.prmoc_psa_actual < 0)
				OR (MOC.prmoc_psa_actual > 0))
			AND GO1.num_operacion IS NOT NULL 
			AND GO1.num_contrato > 0
		

		--Se carga la tabla temporal de contratos vigentes con giros activos
		INSERT	#TEMP_CONTRATOS_VIGENTES (Cod_Operacion_Contrato, Cod_Operacion_Giro)
		SELECT	DISTINCT GO1.cod_operacion AS Cod_Operacion_Contrato, TGA.cod_operacion AS Cod_Operacion_Giro
		FROM	dbo.GAR_OPERACION GO1 
			INNER JOIN dbo.GAR_SICC_PRMCA MCA
			ON GO1.cod_contabilidad = MCA.prmca_pco_conta
			AND GO1.cod_oficina = MCA.prmca_pco_ofici 
			AND GO1.cod_moneda = MCA.prmca_pco_moned
			AND GO1.num_contrato = MCA.prmca_pnu_contr
			INNER JOIN #TEMP_GIROS_ACTIVOS TGA
			ON TGA.prmoc_pnu_contr = MCA.prmca_pnu_contr
			AND TGA.prmoc_pco_oficon = MCA.prmca_pco_ofici
			AND TGA.prmoc_pcomonint = MCA.prmca_pco_moned
		WHERE	GO1.num_operacion IS NULL 
			AND GO1.num_contrato > 0
			AND MCA.prmca_estado = 'A'
			AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera 

		--Se carga la tabla temporal de contratos vencidos (con giros activos)
		INSERT	#TEMP_CONTRATOS_VENCIDOS_GA (Cod_Operacion_Contrato, Cod_Operacion_Giro)
		SELECT	DISTINCT GO1.cod_operacion AS Cod_Operacion_Contrato, TGA.cod_operacion AS Cod_Operacion_Giro
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
		WHERE	GO1.num_operacion IS NULL 
			AND GO1.num_contrato > 0
			AND MCA.prmca_estado = 'A'
			AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera 
		   
			/*Se obtienen las operaciones activas que posean una garantía real asociada*/	
		INSERT	INTO dbo.TMP_OPERACIONES (cod_operacion, cod_garantia, cod_tipo_garantia,
										  cod_tipo_operacion, ind_contrato_vencido,
										  ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
				GRA.cod_operacion, 
				GRA.cod_garantia_real,
				2 AS cod_tipo_garantia,
				1 AS cod_tipo_operacion, 
				0 AS ind_contrato_vencido,
				0 AS ind_contrato_vencido_giros_activos,
				@psCedula_Usuario AS cod_usuario
		FROM	#TTEMP_PRMOC MOC
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON MOC.cod_operacion = GRA.cod_operacion
		WHERE	MOC.Indicador_Es_Giro = 0
			AND GRA.cod_estado = 1 

		/*Se obtienen los contratos vigentes y las garantías relacionadas a estos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
				MCA.Cod_Operacion_Contrato, 
				GRA.cod_garantia_real,
				2 AS cod_tipo_garantia,
				2 AS cod_tipo_operacion, 
				0 AS ind_contrato_vencido,
				0 AS ind_contrato_vencido_giros_activos,
				@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VIGENTES MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato

		/*Se obtienen las garantías de los contratos vencidos con giros activos y sus garantías reales*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
			MCA.Cod_Operacion_Contrato, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			2 AS cod_tipo_operacion, 
			1 AS ind_contrato_vencido,
			1 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VENCIDOS_GA MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato

		/*Se obtienen los giros activos de contratos vigentes y las garantías relacionadas a estos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
				MCA.Cod_Operacion_Giro, 
				GRA.cod_garantia_real,
				2 AS cod_tipo_garantia,
				3 AS cod_tipo_operacion, 
				0 AS ind_contrato_vencido,
				1 AS ind_contrato_vencido_giros_activos,
				@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VIGENTES MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato

		/*Se obtienen las garantías de los contratos vencidos con giros activos y se les asignan a estos giros las garantías reales de sus contratos*/
		INSERT	INTO dbo.TMP_OPERACIONES(cod_operacion, cod_garantia, cod_tipo_garantia,
										 cod_tipo_operacion, ind_contrato_vencido,
										 ind_contrato_vencido_giros_activos, cod_usuario)
		SELECT	DISTINCT 
			MCA.Cod_Operacion_Giro, 
			GRA.cod_garantia_real,
			2 AS cod_tipo_garantia,
			3 AS cod_tipo_operacion, 
			1 AS ind_contrato_vencido,
			1 AS ind_contrato_vencido_giros_activos,
			@psCedula_Usuario AS cod_usuario
		FROM	#TEMP_CONTRATOS_VENCIDOS_GA MCA
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
			ON GRA.cod_operacion = MCA.Cod_Operacion_Contrato
	END
	IF(@piEjecutar_Parte = 2)
	BEGIN
	
		/*Se crean las tablas temporales locales*/
		
		/*Esta tabla almacenará las operaciones activas según el SICC*/
		CREATE TABLE #TEMP_MOC_OPERACIONES (prmoc_pco_ofici	SMALLINT,
											prmoc_pco_moned	TINYINT,
											prmoc_pco_produ TINYINT,
											prmoc_pnu_oper	INT)
		 
		CREATE INDEX TEMP_MOC_OPERACIONES_IX_01 ON #TEMP_MOC_OPERACIONES (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper)
		
		
		/*Esta tabla almacenará los contratos vigentes según el SICC*/
		CREATE TABLE #TEMP_MCA_CONTRATOS (	prmca_pco_ofici		SMALLINT,
											prmca_pco_moned		TINYINT,
											prmca_pco_produc	TINYINT,
											prmca_pnu_contr		INT)
		 
		CREATE INDEX TEMP_MCA_CONTRATOS_IX_01 ON #TEMP_MCA_CONTRATOS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
	
		/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
		CREATE TABLE #TEMP_MCA_GIROS (	prmca_pco_ofici		SMALLINT,
										prmca_pco_moned		TINYINT,
										prmca_pco_produc	TINYINT,
										prmca_pnu_contr		INT)
		 
		CREATE INDEX TEMP_MCA_GIROS_IX_01 ON #TEMP_MCA_GIROS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)

	
		/*Esta tabla almacenará las garantías hipotecarias no alfanuméricas del SICC que estén activas*/
		CREATE TABLE #TEMP_GAR_HIPOTECAS (	prmgt_pcoclagar TINYINT,
											prmgt_pnu_part  TINYINT,
											prmgt_pnuidegar DECIMAL(12,0),
											prmgt_pfeavaing INT,
											Indicador_Fecha_Mayor BIT,
											Fecha_Valuacion DATETIME)
		 
		CREATE INDEX TEMP_GAR_HIPOTECAS_IX_01 ON #TEMP_GAR_HIPOTECAS (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar)


		/*Esta tabla almacenará las garantías hipotecarias alfanuméricas del SICC que estén activas*/
		CREATE TABLE #TEMP_GAR_HIPOTECAS_ALF (	prmgt_pcoclagar TINYINT,
												prmgt_pnu_part  TINYINT,
												prmgt_pnuidegar DECIMAL(12,0),
												prmgt_pnuide_alf CHAR(12),
												prmgt_pfeavaing INT,
												Indicador_Fecha_Mayor BIT,
												Fecha_Valuacion DATETIME)
		 
		CREATE INDEX TEMP_GAR_HIPOTECAS_ALF_IX_01 ON #TEMP_GAR_HIPOTECAS_ALF (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf)


		/*Esta tabla almacenará las garantías prendarias no alfanuméricas del SICC que estén activas*/
		CREATE TABLE #TEMP_GAR_PRENDAS (	prmgt_pcoclagar TINYINT,
											prmgt_pnuidegar DECIMAL(12,0),
											prmgt_pfeavaing INT,
											Indicador_Fecha_Mayor BIT,
											Fecha_Valuacion DATETIME)
		 
		CREATE INDEX TEMP_GAR_PRENDAS_IX_01 ON #TEMP_GAR_PRENDAS (prmgt_pcoclagar, prmgt_pnuidegar)


		/*Esta tabla almacenará las garantías prendarias alfanuméricas del SICC que estén activas*/
		CREATE TABLE #TEMP_GAR_PRENDAS_ALF (	prmgt_pcoclagar TINYINT,
												prmgt_pnuidegar DECIMAL(12,0),
												prmgt_pnuide_alf CHAR(12),
												prmgt_pfeavaing INT,
												Indicador_Fecha_Mayor BIT,
												Fecha_Valuacion DATETIME)
		 
		CREATE INDEX TEMP_GAR_PRENDAS_ALF_IX_01 ON #TEMP_GAR_PRENDAS_ALF (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf)



		/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
		CREATE TABLE #TEMP_GARANTIA_REAL (	cod_garantia_real BIGINT,
											Fecha_Valuacion DATETIME)
		 
		CREATE INDEX TEMP_GARANTIA_REAL_IX_01 ON #TEMP_GARANTIA_REAL (cod_garantia_real, Fecha_Valuacion)
	
		/*Se cargan las tabla temporales*/
		
		/*Se obtienen todas las operaciones activas*/
		
		INSERT	INTO #TEMP_MOC_OPERACIONES (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper)
		SELECT	prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper
		FROM	dbo.GAR_SICC_PRMOC 
		WHERE	prmoc_pse_proces = 1
			AND prmoc_estado = 'A'
			AND ((prmoc_pcoctamay > 815)
				OR (prmoc_pcoctamay < 815))
						
		/*Se obtienen todos los contratos vigentes*/
	
		INSERT	INTO #TEMP_MCA_CONTRATOS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
		SELECT	prmca_pco_ofici, prmca_pco_moned, 10 AS prmca_pco_produc, prmca_pnu_contr
		FROM	dbo.GAR_SICC_PRMCA 
		WHERE	prmca_estado = 'A'
			AND prmca_pfe_defin >= @viFecha_Actual_Entera
	
		/*Se obtienen todos los contratos vencidos con giros activos*/
		
		INSERT	INTO #TEMP_MCA_GIROS (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
		SELECT	MCA.prmca_pco_ofici, MCA.prmca_pco_moned, 10 AS prmca_pco_produc, MCA.prmca_pnu_contr
		FROM	dbo.GAR_SICC_PRMCA MCA
			INNER JOIN dbo.GAR_SICC_PRMOC MOC
			ON MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
			AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
			AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		WHERE	MCA.prmca_estado = 'A'
			AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera
			AND MOC.prmoc_pse_proces = 1
			AND MOC.prmoc_estado = 'A'
			AND MOC.prmoc_pnu_contr > 0
			AND ((MOC.prmoc_pcoctamay > 815)
				OR (MOC.prmoc_pcoctamay < 815))
			
		
	
		/*Se obtienen las hipotecas no alfanuméricas relacionadas a operaciones y contratos*/
		
		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT	MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT	MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17)
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		/*Se obtiene la fecha que es mayor*/
		UPDATE	TMP
		SET		Indicador_Fecha_Mayor = 1
		FROM	#TEMP_GAR_HIPOTECAS TMP
			LEFT JOIN  #TEMP_GAR_HIPOTECAS TM1
			ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
			AND TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
			AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
			AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
		WHERE	TM1.prmgt_pfeavaing IS NULL
		
		/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS
		WHERE	Indicador_Fecha_Mayor = 0
		
		/*Se eliminan los registros que no poseen una fecha de valuación*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS
		WHERE	prmgt_pfeavaing = 19000101
						
		/*Se carga la información de las garantías reales de tipo hipoteca común y que están relacionadas a una operación o contrato*/
		INSERT	INTO #TEMP_GARANTIA_REAL(cod_garantia_real, Fecha_Valuacion)
		SELECT	GGR.cod_garantia_real,
				TMP.Fecha_Valuacion
		FROM	dbo.GAR_GARANTIA_REAL GGR
			INNER JOIN 	#TEMP_GAR_HIPOTECAS TMP
			ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
			AND GGR.cod_partido = TMP.prmgt_pnu_part 
			AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
		WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)
					
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		/*Se obtienen los avalúos de las garantías de hipoteca común relacionadas a las operaciones*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)

		/*Se obtienen los valúos de las garantías de hipoteca común relacionadas a los contratos*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17)



		/*Se obtienen las hipotecas alfanuméricas relacionadas a operaciones y contratos*/
		INSERT	INTO #TEMP_GAR_HIPOTECAS_ALF(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 11
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS_ALF(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar = 11
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS_ALF(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar = 11
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		/*Se obtiene la fecha que es mayor*/
		UPDATE	TMP
		SET		Indicador_Fecha_Mayor = 1
		FROM	#TEMP_GAR_HIPOTECAS_ALF TMP
			LEFT JOIN  #TEMP_GAR_HIPOTECAS_ALF TM1
			ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
			AND TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
			AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
			AND TMP.prmgt_pnuide_alf = TM1.prmgt_pnuide_alf
			AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
		WHERE	TM1.prmgt_pfeavaing IS NULL
		
		/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS_ALF
		WHERE	Indicador_Fecha_Mayor = 0
		
		/*Se eliminan los registros que no poseen una fecha de valuación*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS_ALF
		WHERE	prmgt_pfeavaing = 19000101
		
		/*Se elimina el contenido de esta tabla temporal*/
		DELETE	FROM #TEMP_GARANTIA_REAL
		
		/*Se carga la información de las garantías reales de tipo hipoteca común y que están relacionadas a una operación o contrato*/
		INSERT	INTO #TEMP_GARANTIA_REAL(cod_garantia_real, Fecha_Valuacion)
		SELECT	GGR.cod_garantia_real,
				TMP.Fecha_Valuacion
		FROM	dbo.GAR_GARANTIA_REAL GGR
			INNER JOIN 	#TEMP_GAR_HIPOTECAS_ALF TMP
			ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
			AND GGR.cod_partido = TMP.prmgt_pnu_part 
			AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
			AND GGR.Identificacion_Alfanumerica_Sicc = TMP.prmgt_pnuide_alf COLLATE database_default
		WHERE	GGR.cod_clase_garantia = 11
					
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		/*Se obtienen los avalúos de las garantías de hipoteca común alfanuméricas relacionadas a las operaciones*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--INICIO RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia = 11

		/*Se obtienen los valúos de las garantías de hipoteca común alfanuméricas relacionadas a los contratos*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND GGR.cod_clase_garantia = 11



		/*Se elimina el contenido de la siguiente tabla temporal*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS

		/*Se obtienen las cédulas hipotecarias relacionadas a operaciones y contratos*/
		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar = 18
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar = 18
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		
		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
				AND MG1.prmgt_pcotengar = 1
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
			AND MG1.prmgt_pcotengar = 1
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_HIPOTECAS(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnu_part,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
			AND MG1.prmgt_pcotengar = 1
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0
		
		
		/*Se obtiene la fecha que es mayor*/
		UPDATE	TMP
		SET		Indicador_Fecha_Mayor = 1
		FROM	#TEMP_GAR_HIPOTECAS TMP
			LEFT JOIN  #TEMP_GAR_HIPOTECAS TM1
			ON TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
			AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
			AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
		WHERE	TM1.prmgt_pfeavaing IS NULL
		
		/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS
		WHERE	Indicador_Fecha_Mayor = 0
		
		/*Se eliminan los registros que no poseen una fecha de valuación*/
		DELETE	FROM #TEMP_GAR_HIPOTECAS
		WHERE	prmgt_pfeavaing = 19000101
				
		/*Se elimina el contenido de esta tabla temporal*/
		DELETE	FROM #TEMP_GARANTIA_REAL
		
		/*Se carga la información de las garantías reales de tipo cédula hipotecaria y que están relacionadas a una operación o contrato*/
		INSERT	INTO #TEMP_GARANTIA_REAL(cod_garantia_real, Fecha_Valuacion)
		SELECT	GGR.cod_garantia_real,
				TMP.Fecha_Valuacion
		FROM	dbo.GAR_GARANTIA_REAL GGR
			INNER JOIN 	#TEMP_GAR_HIPOTECAS TMP
			ON GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
			AND GGR.cod_partido = TMP.prmgt_pnu_part 
		WHERE	GGR.cod_clase_garantia = 18
			OR  GGR.cod_clase_garantia BETWEEN 20 AND 29
				
					
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		/*Se obtienen los avalúos de las garantías de cédula hipotecaria no alfanuméricas relacionadas a las operaciones*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 18)
				OR  (GGR.cod_clase_garantia BETWEEN 20 AND 29))

		/*Se obtienen los valúos de las garantías de cédula hipotecaria no alfanuméricas relacionadas a los contratos*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 18)
				OR  (GGR.cod_clase_garantia BETWEEN 20 AND 29))


		/*Se obtienen las prendas no alfanuméricas relacionadas a operaciones y contratos*/
		
		INSERT	INTO #TEMP_GAR_PRENDAS(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND ((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
						OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
						OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_PRENDAS(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT	MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND ((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
					OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
					OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_PRENDAS(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT	MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND ((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
					OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
					OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		/*Se obtiene la fecha que es mayor*/
		UPDATE	TMP
		SET		Indicador_Fecha_Mayor = 1
		FROM	#TEMP_GAR_PRENDAS TMP
			LEFT JOIN  #TEMP_GAR_PRENDAS TM1
			ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
			AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
			AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
		WHERE	TM1.prmgt_pfeavaing IS NULL
		
		/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
		DELETE	FROM #TEMP_GAR_PRENDAS
		WHERE	Indicador_Fecha_Mayor = 0
		
		/*Se eliminan los registros que no poseen una fecha de valuación*/
		DELETE	FROM #TEMP_GAR_PRENDAS
		WHERE	prmgt_pfeavaing = 19000101
		
		/*Se elimina el contenido de esta tabla temporal*/
		DELETE	FROM #TEMP_GARANTIA_REAL
		
		
		/*Se carga la información de las garantías reales de tipo prenda y que están relacionadas a una operación o contrato*/
		INSERT	INTO #TEMP_GARANTIA_REAL(cod_garantia_real, Fecha_Valuacion)
		SELECT	GGR.cod_garantia_real,
				TMP.Fecha_Valuacion
		FROM	dbo.GAR_GARANTIA_REAL GGR
			INNER JOIN 	#TEMP_GAR_PRENDAS TMP
			ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
		WHERE	GGR.cod_clase_garantia BETWEEN 30 AND 37
			OR GGR.cod_clase_garantia BETWEEN 39 AND 42
			OR GGR.cod_clase_garantia BETWEEN 44 AND 69
					
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		/*Se obtienen los avalúos de las garantías de prenda relacionadas a las operaciones*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia BETWEEN 30 AND 37)
				OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
				OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))

		/*Se obtienen los valúos de las garantías de prenda relacionadas a los contratos*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia BETWEEN 30 AND 37)
				OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
				OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))



		/*Se obtienen las prendas alfanuméricas relacionadas a operaciones y contratos*/
		INSERT	INTO #TEMP_GAR_PRENDAS_ALF(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN #TEMP_MOC_OPERACIONES MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND ((MG1.prmgt_pcoclagar = 38)
						OR (MG1.prmgt_pcoclagar = 43))
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_PRENDAS_ALF(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_CONTRATOS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
		WHERE	MG1.prmgt_estado = 'A'
			AND ((MG1.prmgt_pcoclagar = 38)
					OR (MG1.prmgt_pcoclagar = 43))
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

		INSERT	INTO #TEMP_GAR_PRENDAS_ALF(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, Indicador_Fecha_Mayor, Fecha_Valuacion)
		SELECT  MG1.prmgt_pcoclagar,
				MG1.prmgt_pnuidegar,
				MG1.prmgt_pnuide_alf,
				MG1.prmgt_pfeavaing,
				0 AS Indicador_Fecha_Mayor,
				CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion
		FROM	dbo.GAR_SICC_PRMGT MG1
			INNER JOIN #TEMP_MCA_GIROS MCA
			ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
			AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
			AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
			AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
		WHERE	MG1.prmgt_estado = 'A'
			AND ((MG1.prmgt_pcoclagar = 38)
					OR (MG1.prmgt_pcoclagar = 43))
			AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		/*Se obtiene la fecha que es mayor*/
		UPDATE	TMP
		SET		Indicador_Fecha_Mayor = 1
		FROM	#TEMP_GAR_PRENDAS_ALF TMP
			LEFT JOIN  #TEMP_GAR_PRENDAS_ALF TM1
			ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
			AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
			AND TMP.prmgt_pnuide_alf = TM1.prmgt_pnuide_alf
			AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
		WHERE	TM1.prmgt_pfeavaing IS NULL
		
		/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
		DELETE	FROM #TEMP_GAR_PRENDAS_ALF
		WHERE	Indicador_Fecha_Mayor = 0
		
		/*Se eliminan los registros que no poseen una fecha de valuación*/
		DELETE	FROM #TEMP_GAR_PRENDAS_ALF
		WHERE	prmgt_pfeavaing = 19000101
			
		/*Se elimina el contenido de esta tabla temporal*/
		DELETE	FROM #TEMP_GARANTIA_REAL
		
		/*Se carga la información de las garantías reales de tipo prenda y que están relacionadas a una operación o contrato*/
		INSERT	INTO #TEMP_GARANTIA_REAL(cod_garantia_real, Fecha_Valuacion)
		SELECT	GGR.cod_garantia_real,
				TMP.Fecha_Valuacion
		FROM	dbo.GAR_GARANTIA_REAL GGR
			INNER JOIN 	#TEMP_GAR_PRENDAS_ALF TMP
			ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
			AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
			AND GGR.Identificacion_Alfanumerica_Sicc = TMP.prmgt_pnuide_alf COLLATE database_default
		WHERE	GGR.cod_clase_garantia = 38
			OR GGR.cod_clase_garantia = 43
					
		/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
		/*Se obtienen los avalúos de las garantías de prenda alfanuméricas relacionadas a las operaciones*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--INICIO RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 1
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 38)
				OR (GGR.cod_clase_garantia = 43))

		/*Se obtienen los valúos de las garantías de prenda alfanuméricas relacionadas a los contratos*/
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
			cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			Porcentaje_Aceptacion_Terreno,
			Porcentaje_Aceptacion_No_Terreno,
			Porcentaje_Aceptacion_Terreno_Calculado,
			Porcentaje_Aceptacion_No_Terreno_Calculado
			--FIN RQ: RQ_MANT_2015062410418218_00090
			)
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
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			GVR.Porcentaje_Aceptacion_Terreno,
			GVR.Porcentaje_Aceptacion_No_Terreno,
			GVR.Porcentaje_Aceptacion_Terreno_Calculado,
			GVR.Porcentaje_Aceptacion_No_Terreno_Calculado
			--INICIO RQ: RQ_MANT_2015062410418218_00090
		FROM	dbo.GAR_VALUACIONES_REALES GVR
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
			ON GRO.cod_garantia_real = GVR.cod_garantia_real
			INNER JOIN dbo.TMP_OPERACIONES TMP 
			ON TMP.cod_garantia = GRO.cod_garantia_real
			AND TMP.cod_operacion = GRO.cod_operacion
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TMP.cod_garantia
			INNER JOIN #TEMP_GARANTIA_REAL TM1
			ON GGR.cod_garantia_real = TM1.cod_garantia_real
			AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
		WHERE	TMP.cod_tipo_garantia = 2
			AND TMP.cod_tipo_operacion = 2
			AND TMP.cod_usuario = @psCedula_Usuario
			AND ((GGR.cod_clase_garantia = 38)
					OR (GGR.cod_clase_garantia = 43))
					
					
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
				WHEN VGR.fecha_valuacion IS NULL THEN ''
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
			CASE 
				WHEN  VGR.fecha_ultimo_seguimiento IS NULL THEN ''
				WHEN CONVERT(VARCHAR(10),VGR.fecha_ultimo_seguimiento,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),VGR.fecha_ultimo_seguimiento,103)
			END AS fecha_ultimo_seguimiento, 
			COALESCE(VGR.monto_tasacion_actualizada_terreno,0) + COALESCE(VGR.monto_tasacion_actualizada_no_terreno,0) AS monto_total_avaluo,
			CASE 
				WHEN  VGR.fecha_construccion IS NULL THEN ''
				WHEN CONVERT(VARCHAR(10),VGR.fecha_construccion,103) = '01/01/1900' THEN ''
				ELSE CONVERT(VARCHAR(10),VGR.fecha_construccion,103)
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
			NULL AS cod_moneda,
			NULL AS cod_partido,
			NULL AS cod_tipo_garantia,
			NULL AS Garantia_Real,
			NULL AS fecha_prescripcion,
			TMP.cod_tipo_operacion,
			TMP.ind_contrato_vencido,
			1 AS ind_duplicidad,
			TMP.cod_usuario,
			--INICIO RQ: RQ_MANT_2015062410418218_00090
			VGR.Porcentaje_Aceptacion_Terreno,
			VGR.Porcentaje_Aceptacion_No_Terreno,
			VGR.Porcentaje_Aceptacion_Terreno_Calculado,
			VGR.Porcentaje_Aceptacion_No_Terreno_Calculado,
			NULL AS Codigo_SAP,
			NULL AS Monto_Poliza_Colonizado,
			NULL AS Fecha_Vencimiento_Poliza,
			NULL AS Codigo_Tipo_Poliza_Sugef,
			'N' AS Indicador_Poliza,
			NULL AS Indicador_Coberturas_Obligatorias,
			--FIN RQ: RQ_MANT_2015062410418218_00090
			GRO.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
	IF(@piEjecutar_Parte = 3)
	BEGIN
		/*Se eliminan los registros incompletos*/
		DELETE	FROM dbo.TMP_GARANTIAS_REALES
		WHERE	cod_usuario = @psCedula_Usuario
			AND cod_tipo_operacion IN (1, 3)
			AND cod_tipo_garantia = 2
			AND COALESCE(cod_tipo_documento_legal, -1) = -1
			AND LEN(fecha_presentacion) = 0
			AND COALESCE(cod_tipo_mitigador, -1) = -1
			AND COALESCE(cod_inscripcion, -1) = -1

		/*Se eliminan los registros de hipotecas comunes duplicadas*/
		WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_clase_garantia, cod_partido, numero_finca,
					ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca  ORDER BY cod_clase_garantia, cod_partido, numero_finca) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 10 AND 17
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1

		/*Se eliminan los registros de cédulas hipotecarias con clase 18 duplicadas*/
		WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cod_grado, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_clase_garantia, cod_partido, numero_finca, cod_grado,
					ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca, cod_grado  ORDER BY cod_clase_garantia, cod_partido, numero_finca, cod_grado) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia = 18
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1


		/*Se eliminan los registros de cédulas hipotecarias con clase diferente 18 duplicadas*/
		WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cod_grado, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_clase_garantia, cod_partido, numero_finca, cod_grado,
					ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca, cod_grado  ORDER BY cod_clase_garantia, cod_partido, numero_finca, cod_grado) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 20 AND 29
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1

		/*Se eliminan los registros de prendas duplicadas*/
		WITH CTE (cod_clase_garantia, num_placa_bien, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	cod_clase_garantia, num_placa_bien,
					ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, num_placa_bien  ORDER BY cod_clase_garantia, num_placa_bien) AS cantidadRegistrosDuplicados
			FROM	dbo.TMP_GARANTIAS_REALES
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion IN (1, 3)
				AND cod_tipo_garantia = 2
				AND cod_clase_garantia BETWEEN 30 AND 69
		)
		DELETE
		FROM CTE
		WHERE cantidadRegistrosDuplicados > 1


	END
	IF(@piEjecutar_Parte = 4)
	BEGIN
	
		DECLARE @vdFechaActualSinHora	DATETIME  
		SET @vdFechaActualSinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
		--INICIO RQ: RQ_MANT_2015062410418218_00090

		/*Esta tabla almacenará las coberturas obligatorias por asignar de las pólizas*/
		CREATE TABLE #TEMP_COBERTURAS_POR_ASIGNAR (	Codigo_SAP	NUMERIC(8,0),
													Codigo_Tipo_Poliza NUMERIC(3,0),
													Codigo_Tipo_Cobertura NUMERIC(3,0),
													Cantidad_Coberturas_Obligatorias INT)
		 
		CREATE INDEX TEMP_COBERTURAS_POR_ASIGNAR_IX_01 ON #TEMP_COBERTURAS_POR_ASIGNAR (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura)
		
		/*Esta tabla almacenará las coberturas obligatorias asignadas de las pólizas*/
		CREATE TABLE #TEMP_COBERTURAS_ASIGNADAS (	Codigo_SAP	NUMERIC(8,0),
													Codigo_Tipo_Poliza NUMERIC(3,0),
													Codigo_Tipo_Cobertura NUMERIC(3,0),
													Cantidad_Coberturas_Obligatorias INT)
		 
		CREATE INDEX TEMP_COBERTURAS_ASIGNADAS_IX_01 ON #TEMP_COBERTURAS_ASIGNADAS (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura)

		--FIN RQ: RQ_MANT_2015062410418218_00090
			
		DELETE	FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
		WHERE	Cod_Usuario = @psCedula_Usuario

		INSERT INTO dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO (           
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
				COALESCE(TGR.fecha_valuacion, '19000101') AS Fecha_Valuacion,
				COALESCE(TGR.fecha_ultimo_seguimiento, '19000101') AS Fecha_Ultimo_Seguimiento,
				TGR.cod_tipo_garantia_real,
				TGR.cod_tipo_bien,
				COALESCE(TGR.monto_ultima_tasacion_no_terreno, 0) AS Monto_Ultima_Tasacion_No_Terreno,
				@psCedula_Usuario,
				GGR.Indicador_Vivienda_Habitada_Deudor 
		 FROM	dbo.TMP_GARANTIAS_REALES TGR   
			INNER JOIN  dbo.CAT_PORCENTAJE_ACEPTACION CPA
			ON CPA.Codigo_Tipo_Garantia = 2 
			AND CPA.Codigo_Tipo_Mitigador = TGR.cod_tipo_mitigador
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR
			ON GGR.cod_garantia_real = TGR.cod_garantia_real 
		 WHERE	TGR.cod_usuario =  @psCedula_Usuario	   
			AND TGR.cod_tipo_operacion IN (1, 3)
			AND TGR.cod_tipo_bien BETWEEN 1 AND 4
		 
					
		---------------------------------------------------------------------------------
		/*ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDACIONES */ 
		---------------------------------------------------------------------------------
		------------------------------
		--INDICADOR DE INSCRIPCION
		------------------------------

			--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
			--que no poseen asignado el indicador de inscripción. 
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	IN (1, 3)
					AND TMGR.fecha_presentacion	IS NOT NULL
					AND TMGR.cod_inscripcion IS NULL
			

			--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
			--supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
						
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	IN (1, 3)
					AND TMGR.fecha_constitucion	IS NOT NULL
					AND TMGR.cod_inscripcion IS NOT NULL
					AND TMGR.cod_inscripcion = 2 
					AND @vdFechaActualSinHora > DATEADD(DAY, 60, TMGR.fecha_constitucion)


			--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso 
			--(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 días a la fecha de constitución.  
		    			
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	IN (1, 3)
					AND TMGR.fecha_constitucion	IS NOT NULL
					AND TMGR.cod_inscripcion IS NOT NULL
					AND TMGR.cod_inscripcion = 1 
					AND @vdFechaActualSinHora >= DATEADD(DAY, 30, TMGR.fecha_constitucion)


			--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
			--que poseen asignado el indicador de inscripción "No Aplica", pero que poseen un tipo de bien
			--diferente a "Otros tipos de bienes". 
				
				UPDATE  TPAC
				SET		TPAC.Porcentaje_Aceptacion = 0
				FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					ON TPAC.Cod_Garantia_Real = TMGR.cod_garantia_real
					AND TPAC.Cod_Operacion = TMGR.cod_operacion	
				WHERE	TMGR.cod_usuario = @psCedula_Usuario
					AND TMGR.cod_tipo_operacion	IN (1, 3)
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
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC						
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
						AND TPAC.Cod_Usuario =  @psCedula_Usuario	  

		-------------------
		--TIPO DE BIEN: 3
		-------------------
				---------------
				--SEGUIMIENTO
				---------------	
					--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
				
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  0
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real = 3 
						AND TPAC.Cod_Tipo_Bien = 3							
						AND DATEDIFF(YEAR, TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5	
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
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 1									
						AND DATEDIFF(YEAR, TPAC.Fecha_Ultimo_Seguimiento, @vdFechaActualSinHora) > 1   	            
						AND TPAC.Porcentaje_Aceptacion > 0     
						AND TPAC.Cod_Usuario = @psCedula_Usuario	   
		            
				--------------
				--VALUACION
				--------------
				
					--FECHA VALUACION MAYOR A 5 AÑOS	
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)	
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					WHERE	TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
						AND TPAC.Cod_Tipo_Bien = 1						
						AND DATEDIFF(YEAR, TPAC.Fecha_Valuacion, @vdFechaActualSinHora) > 5	
						AND TPAC.Porcentaje_Aceptacion > 0   
						AND TPAC.Cod_Usuario = @psCedula_Usuario		
			
		-------------------
		--TIPO DE BIEN: 2
		-------------------
				--------------
				--VALUACION
				--------------
				
					--FECHA VALUACION MAYOR A 5 AÑOS FECHA SISTEMA				
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC			
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
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--AND TPAC.Cod_Tipo_Bien = 2			
					--AND NOT EXISTS (SELECT	1
					--				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--				WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--				AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real
					--				AND GPR.Estado_Registro = 1)
					-- AND TPAC.Porcentaje_Aceptacion > 0 
					-- AND TPAC.Cod_Usuario =  @psCedula_Usuario	  
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real						
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--AND TPAC.Cod_Tipo_Bien = 2	
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1				
					--AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					--AND TPAC.Porcentaje_Aceptacion > 0
					--AND TPAC.Cod_Usuario =  @psCedula_Usuario	   
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real						
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real IN (1,2) 
					--AND TPAC.Cod_Tipo_Bien = 2
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1
					--AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					--AND TPAC.Porcentaje_Aceptacion > 0 
					--AND TPAC.Cod_Usuario =  @psCedula_Usuario	  
					
					
		-------------------
		--TIPO DE BIEN: 3
		-------------------					
				--------------
				--POLIZA
				--------------
				--NO TIENE POLIZA ASOCIADA			
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC				
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 3			
					--AND NOT EXISTS (SELECT	1
					--				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--				WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--				AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real
					--				AND GPR.Estado_Registro = 1	)
					-- AND TPAC.Porcentaje_Aceptacion > 0
					-- AND TPAC.Cod_Usuario =  @psCedula_Usuario	   				
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
					--INNER JOIN dbo.TMP_GARANTIAS_REALES TMGR
					--	ON TPAC.Cod_Garantia_Real = TPAC.Cod_Garantia_Real	
					--	AND TPAC.Cod_Operacion = TPAC.Cod_Operacion				
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 3	
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1								
					--AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					-- AND TPAC.Porcentaje_Aceptacion > 0  
					--  AND TPAC.Cod_Usuario =  @psCedula_Usuario	 
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 3
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1
					--AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					-- AND TPAC.Porcentaje_Aceptacion > 0  
					--  AND TPAC.Cod_Usuario =  @psCedula_Usuario	 						
						
		-------------------
		--TIPO DE BIEN: 4
		-------------------
				---------------
				--SEGUIMIENTO
				---------------			
					--FECHA SEGUIMIENTO MAYOR A 6 MESES CONTRA SISTEMA
					
					UPDATE  TPAC
					SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
					FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)			
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 4		
					--AND NOT EXISTS (SELECT	1
					--				FROM	dbo.GAR_POLIZAS_RELACIONADAS GPR
					--				WHERE	GPR.cod_operacion = TPAC.Cod_Operacion
					--				AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real	
					--				AND GPR.Estado_Registro = 1)
					-- AND TPAC.Porcentaje_Aceptacion > 0   
					-- AND TPAC.Cod_Usuario =  @psCedula_Usuario	
									
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MENOR A LA DEL SISTEMA			
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 4	
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1			
					--AND GPO.Fecha_Vencimiento < @vdFechaActualSinHora	
					-- AND TPAC.Porcentaje_Aceptacion > 0  
					--  AND TPAC.Cod_Usuario =  @psCedula_Usuario	 
					
					--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
					--UPDATE  TPAC
					--SET TPAC.Porcentaje_Aceptacion =  (TPAC.Porcentaje_Calculado_Original / 2)
					--FROM dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
					--INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
					--	ON GPR.cod_operacion = TPAC.Cod_Operacion
					--	AND GPR.cod_garantia_real = TPAC.Cod_Garantia_Real							
					--INNER JOIN dbo.GAR_POLIZAS GPO
					--	ON GPO.Codigo_SAP = GPR.Codigo_SAP
					--	AND GPO.cod_operacion = GPR.cod_operacion	
					--WHERE 
					--TPAC.Cod_Tipo_Garantia_Real = 3
					--AND TPAC.Cod_Tipo_Bien = 4
					--AND GPO.Estado_Registro = 1
					--AND GPR.Estado_Registro = 1
					--AND GPO.Fecha_Vencimiento > @vdFechaActualSinHora	
					--AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
					--AND TPAC.Porcentaje_Aceptacion > 0 
					--AND TPAC.Cod_Usuario =  @psCedula_Usuario	
					
		---------------------------------------------------------------------------------
		/* FIN ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDaCIONES */
		---------------------------------------------------------------------------------

		/* ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION DE LA TABLA TEMPORAL PRINCIPAL */ 

			UPDATE	TGR
			SET		TGR.Porcentaje_Aceptacion = 
						(
							CASE 
								WHEN COALESCE(TGR.Porcentaje_Aceptacion, 0) = 0 THEN TPAC.Porcentaje_Aceptacion
								WHEN TGR.Porcentaje_Aceptacion >  TPAC.Porcentaje_Aceptacion THEN TPAC.Porcentaje_Aceptacion
								WHEN TPAC.Porcentaje_Aceptacion > TGR.Porcentaje_Aceptacion  THEN TGR.Porcentaje_Aceptacion
								WHEN TPAC.Porcentaje_Aceptacion = TGR.Porcentaje_Aceptacion  THEN TGR.Porcentaje_Aceptacion														
							END			
						)	
			FROM	TMP_GARANTIAS_REALES TGR
			INNER JOIN dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
				ON TGR.cod_operacion = TPAC.Cod_Operacion
				AND TGR.cod_garantia_real = TPAC.Cod_Garantia_Real	
			WHERE	TGR.cod_usuario = @psCedula_Usuario
				AND TGR.cod_tipo_operacion IN (1, 3)


	/***************************************************************************************************************************************************/
	--INICIO RQ: RQ_MANT_2015062410418218_00090

	--SE ACTUALIZA LA INFORMACIÓN DE LA PÓLIZA
	UPDATE	TGR
	SET		TGR.Codigo_SAP = GPR.Codigo_SAP,
			TGR.Monto_Poliza_Colonizado = GPO.Monto_Poliza_Colonizado,
			TGR.Fecha_Vencimiento_Poliza = GPO.Fecha_Vencimiento,
			TGR.Codigo_Tipo_Poliza_Sugef = TPB.Codigo_Tipo_Poliza_Sugef,
			TGR.Indicador_Poliza = 'S'
	FROM	TMP_GARANTIAS_REALES TGR
		INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
		ON GPR.cod_garantia_real = TGR.cod_garantia_real
		AND GPR.cod_operacion = TGR.cod_operacion
		INNER JOIN dbo.GAR_POLIZAS GPO
		ON GPO.Codigo_SAP = GPR.Codigo_SAP
		AND GPO.cod_operacion = GPR.cod_operacion
		INNER JOIN dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN TPB
		ON TPB.Codigo_Tipo_Poliza_Sap = GPO.Tipo_Poliza
		AND TPB.Codigo_Tipo_Bien = TGR.cod_tipo_bien
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1,3)
		AND GPO.Estado_Registro = 1
		AND GPR.Estado_Registro = 1

	--SE OBTIENEN LAS COBERTURAS OBLIGATORIAS POR ASIGNAR A LA POLIZA
	INSERT	INTO #TEMP_COBERTURAS_POR_ASIGNAR (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura, Cantidad_Coberturas_Obligatorias)
	SELECT  GPO.Codigo_SAP,
			GPO.Tipo_Poliza,
			GPO.Codigo_Tipo_Cobertura,
			COUNT(*) AS Cantidad_Coberturas_Obligatorias
	FROM	dbo.GAR_POLIZAS GPO
		INNER JOIN dbo.GAR_COBERTURAS GCO
		ON GCO.Codigo_Tipo_Poliza = GPO.Tipo_Poliza
		AND GCO.Codigo_Tipo_Cobertura = GPO.Codigo_Tipo_Cobertura
	WHERE	GPO.Estado_Registro = 1
		AND GCO.Indicador_Obligatoria = 1
	GROUP BY GPO.Codigo_SAP, GPO.Tipo_Poliza, GPO.Codigo_Tipo_Cobertura
	
	--SE OBTIENEN LAS COBERTURAS OBLIGATORIAS ASIGNADAS A LA POLIZA
	INSERT	INTO #TEMP_COBERTURAS_ASIGNADAS (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura, Cantidad_Coberturas_Obligatorias)
	SELECT  GPO.Codigo_SAP,
			GPO.Tipo_Poliza,
			GPO.Codigo_Tipo_Cobertura,
			COUNT(*) AS Cantidad_Coberturas_Obligatorias
	FROM	dbo.GAR_POLIZAS GPO
		INNER JOIN dbo.GAR_COBERTURAS_POLIZAS GCP
		ON GCP.Codigo_SAP = GPO.Codigo_SAP
		AND GCP.cod_operacion = GPO.cod_operacion
		AND GCP.Codigo_Tipo_Poliza = GPO.Tipo_Poliza
		AND GCP.Codigo_Tipo_Cobertura = GPO.Codigo_Tipo_Cobertura
		INNER JOIN dbo.GAR_COBERTURAS GCO
		ON GCO.Codigo_Cobertura = GCP.Codigo_Cobertura
		AND GCO.Codigo_Tipo_Poliza = GPO.Tipo_Poliza
		AND GCO.Codigo_Tipo_Cobertura = GPO.Codigo_Tipo_Cobertura
	WHERE	GPO.Estado_Registro = 1
		AND GCO.Indicador_Obligatoria = 1
	GROUP BY GPO.Codigo_SAP, GPO.Tipo_Poliza, GPO.Codigo_Tipo_Cobertura
	
	--SE ACTUALIZA EL INDICADOR DE SI LA POLIZA POSEE TODAS LAS COBERTURAS OBLIGATORIAS ASIGNADAS
	UPDATE	TGR
	SET		TGR.Indicador_Coberturas_Obligatorias = CASE 
														WHEN CP2.Codigo_SAP IS NULL THEN 'NO'
														WHEN CP1.Cantidad_Coberturas_Obligatorias = CP2.Cantidad_Coberturas_Obligatorias THEN 'SI'
														ELSE 'NO'
													END
	FROM	dbo.TMP_GARANTIAS_REALES TGR
		INNER JOIN #TEMP_COBERTURAS_POR_ASIGNAR CP1
		ON CP1.Codigo_SAP = TGR.Codigo_SAP
		LEFT OUTER JOIN #TEMP_COBERTURAS_ASIGNADAS CP2
		ON CP2.Codigo_SAP = TGR.Codigo_SAP
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1,3)
		
	--SE ASIGNA EL VALOR NULL A LOS CAMPOS DE LOS PORCENTAJES QUE SEAN MENORES O IGUALES A -1
	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion_Terreno = NULL
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.Porcentaje_Aceptacion_Terreno <= -1

	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion_No_Terreno = NULL
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.Porcentaje_Aceptacion_No_Terreno <= -1

	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion_Terreno_Calculado = NULL
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.Porcentaje_Aceptacion_Terreno_Calculado <= -1

	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion_No_Terreno_Calculado = NULL
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.Porcentaje_Aceptacion_No_Terreno_Calculado <= -1

	--FIN RQ: RQ_MANT_2015062410418218_00090

	UPDATE	TGR
	SET		TGR.porcentaje_responsabilidad = NULL
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.porcentaje_responsabilidad <= -1

	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion = CASE 
											WHEN TGR.Porcentaje_Aceptacion IS NULL THEN GGR.Porcentaje_Aceptacion
											WHEN TGR.Porcentaje_Aceptacion <= -1 THEN GGR.Porcentaje_Aceptacion
											ELSE TGR.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se cambian las referencias a este campo.
										END
	FROM	dbo.GAR_GIROS_GARANTIAS_REALES GGR 
		LEFT OUTER JOIN dbo.TMP_GARANTIAS_REALES TGR
		ON TGR.cod_oficina = GGR.cod_oficina
		AND TGR.cod_moneda = GGR.cod_moneda
		AND TGR.cod_producto = GGR.cod_producto
		AND TGR.operacion = GGR.operacion
		AND TGR.cod_clase_garantia = GGR.cod_clase_garantia
		AND TGR.cod_bien = GGR.cod_bien  
	WHERE	GGR.cod_tipo_documento_legal IS NOT NULL
		AND GGR.cod_estado = 1
		AND TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.porcentaje_responsabilidad <= -1


	UPDATE	TGR
	SET		TGR.Porcentaje_Aceptacion = 0
	FROM	dbo.TMP_GARANTIAS_REALES TGR
	WHERE	TGR.cod_usuario = @psCedula_Usuario
		AND TGR.cod_tipo_operacion IN (1, 3)
		AND TGR.Porcentaje_Aceptacion <= -1

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
			WHEN TMP.Porcentaje_Aceptacion IS NULL THEN GGR.Porcentaje_Aceptacion
			WHEN TMP.Porcentaje_Aceptacion <= -1 THEN GGR.Porcentaje_Aceptacion
			ELSE TMP.Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se cambian las referencias a este campo.
		END AS PORCENTAJE_ACEPTACION,		
		GGR.fecha_constitucion AS FECHA_CONSTITUCION,
		GGR.cod_grado_gravamen AS GRADO_GRAVAMEN,
		GGR.cod_tipo_acreedor AS TIPO_PERSONA_ACREEDOR,
		GGR.cedula_acreedor AS CEDULA_ACREEDOR,
		MAX(GGR.fecha_vencimiento) AS FECHA_VENCIMIENTO,
		GGR.cod_operacion_especial AS OPERACION_ESPECIAL,
		COALESCE(TMP.fecha_valuacion, '') AS FECHA_VALUACION,
		COALESCE(TMP.cedula_empresa, '') AS CEDULA_EMPRESA,
		COALESCE((CONVERT(VARCHAR(3),TMP.cod_tipo_empresa)), '') AS TIPO_PERSONA_EMPRESA,
		COALESCE(TMP.cedula_perito, '') AS CEDULA_PERITO,
		COALESCE((CONVERT(VARCHAR(3),TMP.cod_tipo_perito)), '') AS TIPO_PERSONA_PERITO,
		COALESCE((CONVERT(VARCHAR(50),TMP.monto_ultima_tasacion_terreno)), '') AS MONTO_ULTIMA_TASACION_TERRENO,
		COALESCE((CONVERT(VARCHAR(50),TMP.monto_ultima_tasacion_no_terreno)), '') AS MONTO_ULTIMA_TASACION_NO_TERRENO,
		COALESCE((CONVERT(VARCHAR(50),TMP.monto_tasacion_actualizada_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_TERRENO,
		COALESCE((CONVERT(VARCHAR(50),TMP.monto_tasacion_actualizada_no_terreno)), '') AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
		COALESCE((CONVERT(VARCHAR(50),TMP.fecha_ultimo_seguimiento)), '') AS FECHA_ULTIMO_SEGUIMIENTO,
		COALESCE((CONVERT(VARCHAR(50),TMP.monto_total_avaluo)), '0') AS MONTO_TOTAL_AVALUO,
		COALESCE(TMP.fecha_construccion, '') AS FECHA_CONSTRUCCION,
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
		TMP.cod_garantia_real,
		--INICIO RQ: RQ_MANT_2015062410418218_00090
		COALESCE((CONVERT(VARCHAR(100), TMP.Codigo_SAP)), '') AS CODIGO_SAP,
		COALESCE((CONVERT(VARCHAR(100), TMP.Monto_Poliza_Colonizado)), '') AS MONTO_POLIZA,
		COALESCE((CONVERT(VARCHAR(10), TMP.Fecha_Vencimiento, 103)), '') AS FECHA_VENCIMIENTO_POLIZA,
		COALESCE((CONVERT(VARCHAR(5), TMP.Codigo_Tipo_Poliza_Sugef)), '') AS TIPO_POLIZA_SUGEF,
		TMP.Indicador_Poliza AS INDICADOR_POLIZA,
		COALESCE((CONVERT(VARCHAR(100), TMP.Porcentaje_Aceptacion_Terreno)), '') AS '%_ACEPTACION_TERRENO',
		COALESCE((CONVERT(VARCHAR(100), TMP.Porcentaje_Aceptacion_No_Terreno)), '') AS '%_ACEPTACION_NO_TERRENO',
		COALESCE((CONVERT(VARCHAR(100), TMP.Porcentaje_Aceptacion_Terreno_Calculado)), '') AS '%_ACEPTACION_TERRENO_CALCULADO',
		COALESCE((CONVERT(VARCHAR(100), TMP.Porcentaje_Aceptacion_No_Terreno_Calculado)), '') AS '%_ACEPTACION_NO_TERRENO_CALCULADO',
		COALESCE((CONVERT(VARCHAR(100), TMP.Indicador_Coberturas_Obligatorias)), '') AS COBERTURA_DE_BIEN,			
		--FIN RQ: RQ_MANT_2015062410418218_00090
		COALESCE((CONVERT(VARCHAR(50),TMP.porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
		AND TMP.cod_tipo_operacion IN (1, 3)
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
		GGR.Porcentaje_Aceptacion,
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
		GO1.num_contrato,
		TMP.Codigo_SAP,
		TMP.Monto_Poliza_Colonizado,
		TMP.Fecha_Vencimiento,
		TMP.Codigo_Tipo_Poliza_Sugef,
		TMP.Indicador_Poliza,
		--INICIO RQ: RQ_MANT_2015062410418218_00090
		TMP.Porcentaje_Aceptacion_Terreno,
		TMP.Porcentaje_Aceptacion_No_Terreno,
		TMP.Porcentaje_Aceptacion_Terreno_Calculado,
		TMP.Porcentaje_Aceptacion_No_Terreno_Calculado,
		TMP.Indicador_Coberturas_Obligatorias,
		--FIN RQ: RQ_MANT_2015062410418218_00090
		TMP.Porcentaje_Aceptacion  --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	END
END
