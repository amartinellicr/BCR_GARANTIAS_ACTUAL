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
	@piEjecutar_Parte	TINYINT
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
            @piEjecutar_Parte		= Indica la parte del procedimiento almacenado que será ejecutada, esto con el fin de agilizar el proceso de 
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
				Se modifica la forma en como se obtienen los registros referentes a las valuaciones de la garantía, corresponde a la parte de ejecución igual a 1. 
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Creación de Tablas para SICAD, No. 2016012710534870</Requerimiento>
			<Fecha>16/02/2016</Fecha>
			<Descripción>
				Se realiza un ajuste con el fin de contemplar la carga de algunas de las estructuras creadas para SICAD. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>PBI 13977: Mantenimientos Garantías Reales</Requerimiento>
			<Fecha>Octubre - 2016</Fecha>
			<Descripción>Se agregra el campo referente al monto total del avalúo colonizado. 
						 Adicionalmente, se incorpora el control de errores.
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
	SET DATEFORMAT dmy
	
	BEGIN TRY

		/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
		DECLARE	@vdtFecha_Actual_Sin_Hora DATETIME,
				@viFecha_Actual_Entera INT,
				@viContador TINYINT

		SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Actual_Sin_Hora, 112))

		IF(@piEjecutar_Parte = 0)
		BEGIN
	
			/*TABLA AUXILIAR DE CLASES DE GARANTIAS VALIDAS PARA EL ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_CLASES_GAR_VALIDAS') IS NOT NULL
				DROP TABLE dbo.AUX_CLASES_GAR_VALIDAS


			CREATE TABLE dbo.AUX_CLASES_GAR_VALIDAS(
				Tipo_Garantia_Real TINYINT,
				Codigo_Clase_Garantia TINYINT,
				Ind_Clase_Alfanumerica BIT
			) ON [PRIMARY]


			SET @viContador = 10

			WHILE (@viContador < 70)
			BEGIN
					
				INSERT dbo.AUX_CLASES_GAR_VALIDAS (Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica)
				SELECT	1 Tipo_Garantia_Real, --HIPOTECAS COMUNES
						@viContador AS Codigo_Clase_Garantia,
						CASE WHEN @viContador = 11 THEN 1
								ELSE 0
						END AS Ind_Clase_Alfanumerica
				WHERE	@viContador >= 10
					AND @viContador <= 17
					
				UNION 

				SELECT	2 Tipo_Garantia_Real, --CEDULAS HIPOTECARIAS
						@viContador AS Codigo_Clase_Garantia,
						0 AS Ind_Clase_Alfanumerica
				WHERE	@viContador = 18
					OR ((@viContador >= 20) AND (@viContador <= 29))

				UNION 

				SELECT	3 Tipo_Garantia_Real, --PRENDAS
						@viContador AS Codigo_Clase_Garantia,
						CASE WHEN @viContador = 38 THEN 1
								WHEN @viContador = 43 THEN 1
								ELSE 0
						END AS Ind_Clase_Alfanumerica
				WHERE	@viContador >= 30 
					AND @viContador <= 69

				SET @viContador = @viContador + 1

			END


			CREATE INDEX AUX_CLASES_GAR_VALIDAS_IX_01 ON dbo.AUX_CLASES_GAR_VALIDAS (Tipo_Garantia_Real, Codigo_Clase_Garantia) ON [PRIMARY]


			/*TABLA AUXILIAR DE GIROS ACTIVOS*/
			IF OBJECT_ID('dbo.AUX_GIROS_ACTIVOS') IS NOT NULL
				DROP TABLE dbo.AUX_GIROS_ACTIVOS


			CREATE TABLE dbo.AUX_GIROS_ACTIVOS(
				prmoc_pco_oficon SMALLINT,
				prmoc_pcomonint SMALLINT,
				prmoc_pnu_contr INT
			) ON [PRIMARY]

			--Se carga la tabla temporal de giros activos
			INSERT	dbo.AUX_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr)
			SELECT	MOC.prmoc_pco_oficon, MOC.prmoc_pcomonint, MOC.prmoc_pnu_contr
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
				AND ((MOC.prmoc_pcoctamay < 815) OR (MOC.prmoc_pcoctamay > 815))
				AND ((MOC.prmoc_psa_actual < 0) OR (MOC.prmoc_psa_actual > 0))
				AND ISNULL(GO1.num_operacion, 0) > 0 
				AND GO1.num_contrato > 0
			GROUP BY MOC.prmoc_pco_oficon, 
					MOC.prmoc_pcomonint, 
					MOC.prmoc_pnu_contr
		
			CREATE INDEX AUX_GIROS_ACTIVOS_IX_01 ON dbo.AUX_GIROS_ACTIVOS (prmoc_pco_oficon, prmoc_pcomonint, prmoc_pnu_contr) ON [PRIMARY]


			/*TABLA AUXILIAR DE CONTRATOS VIGENTES*/
			IF OBJECT_ID('dbo.AUX_CONTRATOS_VIGENTES') IS NOT NULL
				DROP TABLE dbo.AUX_CONTRATOS_VIGENTES


			CREATE TABLE dbo.AUX_CONTRATOS_VIGENTES(
				cod_operacion BIGINT
			) ON [PRIMARY]

			--Se carga la tabla temporal de contratos vigentes con giros activos
			INSERT	dbo.AUX_CONTRATOS_VIGENTES (cod_operacion)
			SELECT	GO1.cod_operacion
			FROM	dbo.GAR_OPERACION GO1 
				INNER JOIN dbo.GAR_SICC_PRMCA MCA
				ON GO1.cod_contabilidad = MCA.prmca_pco_conta
				AND GO1.cod_oficina = MCA.prmca_pco_ofici 
				AND GO1.cod_moneda = MCA.prmca_pco_moned
				AND GO1.num_contrato = MCA.prmca_pnu_contr
			WHERE	GO1.num_operacion IS NULL 
				AND GO1.num_contrato > 0
				AND MCA.prmca_estado = 'A'
				AND MCA.prmca_pfe_defin >= @viFecha_Actual_Entera
			
			CREATE INDEX AUX_CONTRATOS_VIGENTES_IX_01 ON dbo.AUX_CONTRATOS_VIGENTES (cod_operacion) ON [PRIMARY]


			/*TABLA AUXILIAR DE CONTRATOS VENCIDOS CON GIROS ACTIVOS*/
			IF OBJECT_ID('dbo.AUX_CONTRATOS_VENCIDOS_GA') IS NOT NULL
				DROP TABLE dbo.AUX_CONTRATOS_VENCIDOS_GA


			CREATE TABLE dbo.AUX_CONTRATOS_VENCIDOS_GA(
				cod_operacion BIGINT
			) ON [PRIMARY]


			--Se carga la tabla temporal de contratos vencidos (con giros activos)
			INSERT	dbo.AUX_CONTRATOS_VENCIDOS_GA (cod_operacion)
			SELECT	GO1.cod_operacion
			FROM	dbo.GAR_OPERACION GO1 
				INNER JOIN dbo.GAR_SICC_PRMCA MCA
				ON GO1.cod_contabilidad = MCA.prmca_pco_conta
				AND GO1.cod_oficina = MCA.prmca_pco_ofici 
				AND GO1.cod_moneda = MCA.prmca_pco_moned
				AND GO1.num_contrato = MCA.prmca_pnu_contr
				INNER JOIN dbo.AUX_GIROS_ACTIVOS TGA
				ON MCA.prmca_pnu_contr = TGA.prmoc_pnu_contr
				AND MCA.prmca_pco_ofici = TGA.prmoc_pco_oficon
				AND MCA.prmca_pco_moned = TGA.prmoc_pcomonint
			WHERE	GO1.num_operacion IS NULL 
				AND GO1.num_contrato > 0
				AND MCA.prmca_estado = 'A'
				AND MCA.prmca_pfe_defin < @viFecha_Actual_Entera

			CREATE INDEX AUX_CONTRATOS_VENCIDOS_GA_IX_01 ON dbo.AUX_CONTRATOS_VENCIDOS_GA (cod_operacion) ON [PRIMARY]



			/*Se carga la tabla temporal de contratos vigentes y vencidos (con giros activos) con la información de aquellos que posean una garantía real 
			  asociada*/	
			/*TABLA AUXILIAR DE OPERACIONES PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_OPERACIONES_GRC') IS NOT NULL
				DROP TABLE dbo.AUX_OPERACIONES_GRC

			CREATE TABLE dbo.AUX_OPERACIONES_GRC
			(
				cod_operacion         BIGINT  NULL,
				cod_garantia          BIGINT  NULL,
				cod_tipo_garantia     TINYINT  NULL,
				cod_tipo_operacion    TINYINT  NULL,
				ind_contrato_vencido  TINYINT  NULL,
				ind_contrato_vencido_giros_activos  TINYINT  NULL,
				cod_oficina           SMALLINT  NULL,
				cod_moneda            TINYINT  NULL,
				cod_producto          TINYINT  NULL,
				num_operacion         DECIMAL(7)  NULL,
				num_contrato          DECIMAL(7)  NULL,
				cod_estado_garantia   BIT  NULL 
				CONSTRAINT DF_AUX_OPERACIONES_GRC_codestadogarantia
					 DEFAULT  0,				
				cod_usuario           VARCHAR(30)  NULL 
			) ON [PRIMARY]
			
			
			INSERT	INTO dbo.AUX_OPERACIONES_GRC(
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
			SELECT	GO1.cod_operacion, 
					GRA.cod_garantia_real,
					2 AS cod_tipo_garantia,
					2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
					0 AS ind_contrato_vencido,
					0 AS ind_contrato_vencido_giros_activos,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato,
					@psCedula_Usuario AS cod_usuario
			FROM	dbo.GAR_OPERACION GO1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES TCV
				ON GO1.cod_operacion = TCV.cod_operacion
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
				ON GO1.cod_operacion = GRA.cod_operacion
			WHERE	GO1.num_operacion IS NULL 
				AND GO1.num_contrato > 0
			GROUP BY GO1.cod_operacion, 
					GRA.cod_garantia_real,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato
		
		
			INSERT	INTO dbo.AUX_OPERACIONES_GRC(
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
			SELECT	GO1.cod_operacion, 
					GRA.cod_garantia_real,
					2 AS cod_tipo_garantia,
					2 AS cod_tipo_operacion,  -- 1 = Operaciones, 2 = Contratos y 3 = Giros
					1 AS ind_contrato_vencido,
					1 AS ind_contrato_vencido_giros_activos,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato,
					@psCedula_Usuario AS cod_usuario
			FROM	dbo.GAR_OPERACION GO1
				INNER JOIN dbo.AUX_CONTRATOS_VENCIDOS_GA TCV
				ON GO1.cod_operacion = TCV.cod_operacion
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRA
				ON GO1.cod_operacion = GRA.cod_operacion
			WHERE	GO1.num_operacion IS NULL 
				AND GO1.num_contrato > 0	
			GROUP BY GO1.cod_operacion, 
					GRA.cod_garantia_real,
					GO1.cod_oficina,
					GO1.cod_moneda,
					GO1.cod_producto,
					GO1.num_operacion,
					GO1.num_contrato
		
		
			/*Se actualiza el estado de aquellas garantías que se encuentran la estructura PRMGT*/
			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE HIPOTECA COMÚN, CON CLASE DISTINTA A 11*/
			UPDATE	dbo.AUX_OPERACIONES_GRC 
			SET		cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 1
				AND MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pnu_part = GGR.cod_partido
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
				AND CGV.Tipo_Garantia_Real = 1
				AND CGV.Ind_Clase_Alfanumerica = 0
			
			
			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE HIPOTECA COMÚN, CON CLASE IGUAL A 11*/
			UPDATE	dbo.AUX_OPERACIONES_GRC 
			SET		cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 1
				AND MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar = 11
				AND MGT.prmgt_pnu_part = GGR.cod_partido
				AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
				AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			
			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CÉDULAS HIPOTECARIAS*/
			UPDATE	dbo.AUX_OPERACIONES_GRC
			SET		cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 2
				AND MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar	= 18 --RQ: 1-23969281. Se incluye el código 18.
				AND MGT.prmgt_pnu_part = GGR.cod_partido
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
			

			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CÉDULAS HIPOTECARIAS*/
			UPDATE	dbo.AUX_OPERACIONES_GRC
			SET		cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 2
				AND MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pcoclagar > 18
				AND MGT.prmgt_pnu_part = GGR.cod_partido
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				AND MGT.prmgt_pcotengar = 1
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
				AND CGV.Tipo_Garantia_Real = 2
				AND CGV.Ind_Clase_Alfanumerica = 0

			
			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CONTRATOS DE PRENDA, CON CLASE DISTINTA A 38 O 43*/
			UPDATE	dbo.AUX_OPERACIONES_GRC 
			SET 	cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 3
				AND MGT.prmgt_estado = 'A'
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
				AND CGV.Ind_Clase_Alfanumerica = 0
		
			/*SE VERIFICA LA EXISTENCIA DE LAS GARANTÍAS REALES DE CONTRATOS DE PRENDA, CON CLASE IGUAL A 38 O 43*/
			UPDATE	dbo.AUX_OPERACIONES_GRC 
			SET 	cod_estado_garantia = 1
			FROM	dbo.AUX_OPERACIONES_GRC TMP
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.GAR_SICC_PRMGT MGT
				ON MGT.prmgt_pnu_oper = TMP.num_contrato
				AND MGT.prmgt_pco_ofici = TMP.cod_oficina
				AND MGT.prmgt_pco_moned = TMP.cod_moneda
				AND MGT.prmgt_pco_produ = 10
				AND MGT.prmgt_pco_conta = 1
				AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_tipo_garantia_real = 3
				AND MGT.prmgt_estado = 'A'
				AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
				AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
				AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
				AND CGV.Ind_Clase_Alfanumerica = 1

			/*SE ELIMINAN AQUELLAS GARANTÍAS QUE NO TENGAN UNA CORRESPONDENCIA CON PRMGT*/
			DELETE	FROM dbo.AUX_OPERACIONES_GRC 
			WHERE	cod_estado_garantia = 0 
				AND cod_tipo_garantia = 2 
				AND cod_tipo_operacion = 2 
				AND cod_usuario	= @psCedula_Usuario 
		END
		IF(@piEjecutar_Parte = 1)
		BEGIN
	
			/*Se cargan las tabla temporales*/
			
			/*TABLA AUXILIAR DE OPERACIONES DEL SICC PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_OPERACIONES_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_OPERACIONES_SICC

			/*Esta tabla almacenará las operaciones activas según el SICC*/
			CREATE TABLE dbo.AUX_OPERACIONES_SICC 
			(	
				prmoc_pco_ofici	SMALLINT,
				prmoc_pco_moned	TINYINT,
				prmoc_pco_produ TINYINT,
				prmoc_pnu_oper	INT
			) ON [PRIMARY]
		 

			/*Se obtienen todas las operaciones activas*/
			INSERT	INTO dbo.AUX_OPERACIONES_SICC (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper)
			SELECT	prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper
			FROM	dbo.GAR_SICC_PRMOC 
			WHERE	prmoc_pse_proces = 1
				AND prmoc_estado = 'A'
				AND ((prmoc_pcoctamay > 815) OR (prmoc_pcoctamay < 815))


			CREATE INDEX AUX_OPERACIONES_SICC_IX_01 ON dbo.AUX_OPERACIONES_SICC (prmoc_pco_ofici, prmoc_pco_moned, prmoc_pco_produ, prmoc_pnu_oper) ON [PRIMARY]


			/*TABLA AUXILIAR DE CONTRATOS VIGENTES DEL SICC PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_CONTRATOS_VIGENTES_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_CONTRATOS_VIGENTES_SICC

			/*Esta tabla almacenará los contratos vigentes según el SICC*/
			CREATE TABLE dbo.AUX_CONTRATOS_VIGENTES_SICC 
			(	
				prmca_pco_ofici		SMALLINT,
				prmca_pco_moned		TINYINT,
				prmca_pco_produc	TINYINT,
				prmca_pnu_contr		INT
			) ON [PRIMARY]
		 

			/*Se obtienen todos los contratos vigentes*/
			INSERT	INTO dbo.AUX_CONTRATOS_VIGENTES_SICC (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
			SELECT	prmca_pco_ofici, prmca_pco_moned, 10 AS prmca_pco_produc, prmca_pnu_contr
			FROM	dbo.GAR_SICC_PRMCA 
			WHERE	prmca_estado = 'A'
				AND prmca_pfe_defin >= @viFecha_Actual_Entera


			CREATE INDEX AUX_CONTRATOS_VIGENTES_SICC_IX_01 ON dbo.AUX_CONTRATOS_VIGENTES_SICC (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr) ON [PRIMARY]
	
			
			/*TABLA AUXILIAR DE GIROS ACTIVOS DEL SICC PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GIROS_ACTIVOS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GIROS_ACTIVOS_SICC


			/*Esta tabla almacenará los contratos vencidos con giros activos según el SICC*/
			CREATE TABLE dbo.AUX_GIROS_ACTIVOS_SICC 
			(	
				prmca_pco_ofici		SMALLINT,
				prmca_pco_moned		TINYINT,
				prmca_pco_produc	TINYINT,
				prmca_pnu_contr		INT
			) ON [PRIMARY]
		 
				
			/*Se obtienen todos los contratos vencidos con giros activos*/
			INSERT	INTO dbo.AUX_GIROS_ACTIVOS_SICC (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr)
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
				AND ((MOC.prmoc_pcoctamay > 815) OR (MOC.prmoc_pcoctamay < 815))


			CREATE INDEX AUX_GIROS_ACTIVOS_SICC_IX_01 ON dbo.AUX_GIROS_ACTIVOS_SICC (prmca_pco_ofici, prmca_pco_moned, prmca_pco_produc, prmca_pnu_contr) ON [PRIMARY]



			/*TABLA AUXILIAR DE GARANTIAS HIPOTECARIAS NO ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_HIPOTECAS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_HIPOTECAS_SICC
	
			/*Esta tabla almacenará las garantías hipotecarias no alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_HIPOTECAS_SICC 
			(	
				prmgt_pcoclagar TINYINT NULL,
				prmgt_pnu_part  TINYINT NULL,
				prmgt_pnuidegar DECIMAL(12,0) NULL,
				prmgt_pfeavaing INT NULL,
				prmgt_pco_mongar TINYINT NULL,
				prmgt_pmoavaing DECIMAL(14,2) NULL,
				Indicador_Fecha_Mayor BIT NULL,
				Fecha_Valuacion DATETIME NULL,
				Monto_Total_Avaluo DECIMAL(14,2) NULL
			) ON [PRIMARY]
		 
				
			/*Se obtienen las hipotecas no alfanuméricas relacionadas a operaciones y contratos*/
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 1
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				--AND ((MG1.prmgt_pcoclagar = 10) OR ((MG1.prmgt_pcoclagar >= 12) AND (MG1.prmgt_pcoclagar <= 17))) 
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
					
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 1
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				--AND ((MG1.prmgt_pcoclagar = 10) OR ((MG1.prmgt_pcoclagar >= 12) AND (MG1.prmgt_pcoclagar <= 17))) 
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
					
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 1
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar																
			WHERE	MG1.prmgt_estado = 'A'
				--AND ((MG1.prmgt_pcoclagar = 10) OR ((MG1.prmgt_pcoclagar >= 12) AND (MG1.prmgt_pcoclagar <= 17))) 
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
					
				
			CREATE INDEX AUX_GAR_HIPOTECAS_SICC_IX_01 ON dbo.AUX_GAR_HIPOTECAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) ON [PRIMARY]


			/*TABLA AUXILIAR DE GARANTIAS HIPOTECARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_HIPOTECAS_ALF_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_HIPOTECAS_ALF_SICC
	

			/*Esta tabla almacenará las garantías hipotecarias alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_HIPOTECAS_ALF_SICC 
			(	
				prmgt_pcoclagar TINYINT NULL,
				prmgt_pnu_part  TINYINT NULL,
				prmgt_pnuidegar DECIMAL(12,0) NULL,
				prmgt_pnuide_alf CHAR(12) NULL,
				prmgt_pfeavaing INT NULL,
				prmgt_pco_mongar TINYINT NULL,
				prmgt_pmoavaing DECIMAL(14,2) NULL,
				Indicador_Fecha_Mayor BIT NULL,
				Fecha_Valuacion DATETIME NULL,
				Monto_Total_Avaluo DECIMAL(14,2) NULL
			) ON [PRIMARY]
		 

			/*Se obtienen las hipotecas alfanuméricas relacionadas a operaciones y contratos*/
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 11
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 11
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 11
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0	


			CREATE INDEX AUX_GAR_HIPOTECAS_ALF_SICC_IX_01 ON dbo.AUX_GAR_HIPOTECAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf) ON [PRIMARY]


			/*TABLA AUXILIAR DE CEDULAS HIPOTECARIAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_CEDULAS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_CEDULAS_SICC
	
			/*Esta tabla almacenará las garantías hipotecarias no alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_CEDULAS_SICC 
			(	
				prmgt_pcoclagar TINYINT NULL,
				prmgt_pnu_part  TINYINT NULL,
				prmgt_pnuidegar DECIMAL(12,0) NULL,
				prmgt_pfeavaing INT NULL,
				prmgt_pco_mongar TINYINT NULL,
				prmgt_pmoavaing DECIMAL(14,2) NULL,
				prmgt_pco_grado TINYINT NULL,
				Indicador_Fecha_Mayor BIT NULL,
				Fecha_Valuacion DATETIME NULL,
				Monto_Total_Avaluo DECIMAL(14,2) NULL
			) ON [PRIMARY]


			/*Se obtienen las cédulas hipotecarias relacionadas a operaciones y contratos*/
			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0		
		
		
			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 2
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar > 18 
				AND MG1.prmgt_pcotengar = 1
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 2
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar > 18
				AND MG1.prmgt_pcotengar = 1
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 2
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar																
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar > 18
				AND MG1.prmgt_pcotengar = 1
				AND COALESCE(MG1.prmgt_pfeavaing, 0) > 0


			CREATE INDEX AUX_GAR_CEDULAS_SICC_IX_01 ON dbo.AUX_GAR_CEDULAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) ON [PRIMARY]

			

			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS NO ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_PRENDAS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_PRENDAS_SICC

			/*Esta tabla almacenará las garantías prendarias no alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_PRENDAS_SICC 
			(	
				prmgt_pcoclagar TINYINT NULL,
				prmgt_pnuidegar DECIMAL(12,0) NULL,
				prmgt_pfeavaing INT NULL,
				prmgt_pco_mongar TINYINT NULL,
				prmgt_pmoavaing DECIMAL(14,2) NULL,
				Indicador_Fecha_Mayor BIT NULL,
				Fecha_Valuacion DATETIME NULL,
				Monto_Total_Avaluo DECIMAL(14,2) NULL
			) ON [PRIMARY]
		 
				
			/*Se obtienen las prendas no alfanuméricas relacionadas a operaciones y contratos*/
		
			INSERT	INTO dbo.AUX_GAR_PRENDAS_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

			INSERT	INTO dbo.AUX_GAR_PRENDAS_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

			INSERT	INTO dbo.AUX_GAR_PRENDAS_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar																
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

					
			CREATE INDEX AUX_GAR_PRENDAS_SICC_IX_01 ON dbo.AUX_GAR_PRENDAS_SICC (prmgt_pcoclagar, prmgt_pnuidegar) ON [PRIMARY]


			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_PRENDAS_ALF_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_PRENDAS_ALF_SICC

			/*Esta tabla almacenará las garantías prendarias alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_PRENDAS_ALF_SICC 
			(	
				prmgt_pcoclagar TINYINT NULL,
				prmgt_pnuidegar DECIMAL(12,0) NULL,
				prmgt_pnuide_alf CHAR(12) NULL,
				prmgt_pfeavaing INT NULL,
				prmgt_pco_mongar TINYINT NULL,
				prmgt_pmoavaing DECIMAL(14,2) NULL,
				Indicador_Fecha_Mayor BIT NULL,
				Fecha_Valuacion DATETIME NULL,
				Monto_Total_Avaluo DECIMAL(14,2) NULL
			) ON [PRIMARY]
		 

			/*Se obtienen las prendas alfanuméricas relacionadas a operaciones y contratos*/
			INSERT	INTO dbo.AUX_GAR_PRENDAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar	
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 1

			INSERT	INTO dbo.AUX_GAR_PRENDAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar	
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 1

			INSERT	INTO dbo.AUX_GAR_PRENDAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = 3
				AND CGV.Codigo_Clase_Garantia = MG1.prmgt_pcoclagar																	
			WHERE	MG1.prmgt_estado = 'A'
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0	
				AND CGV.Ind_Clase_Alfanumerica = 1


			CREATE INDEX AUX_GAR_PRENDAS_ALF_SICC_IX_01 ON dbo.AUX_GAR_PRENDAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf) ON [PRIMARY]
		
	

			/*SE DETEMRINA LA FECHA DE VALUACION MAS RECIENTE*/
	
			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIA_REAL_GR') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIA_REAL_GR


			/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
			CREATE TABLE dbo.AUX_GARANTIA_REAL_GR 
			(	
				cod_garantia_real BIGINT,
				Fecha_Valuacion DATETIME
			) ON [PRIMARY]
		 
				

			/*Se obtiene la fecha que es mayor*/
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1
			FROM	dbo.AUX_GAR_HIPOTECAS_SICC TMP
				LEFT JOIN  dbo.AUX_GAR_HIPOTECAS_SICC TM1
				ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
				AND TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
				AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
				AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
			WHERE	TM1.prmgt_pfeavaing IS NULL
		
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_SICC
			WHERE	prmgt_pfeavaing = 19000101
								
						
			/*Se carga la información de las garantías reales de tipo hipoteca común y que están relacionadas a una operación o contrato*/
			INSERT	INTO dbo.AUX_GARANTIA_REAL_GR(cod_garantia_real, Fecha_Valuacion)
			SELECT	GGR.cod_garantia_real,
					TMP.Fecha_Valuacion
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN 	dbo.AUX_GAR_HIPOTECAS_SICC TMP
				ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
				AND GGR.cod_partido = TMP.prmgt_pnu_part 
				AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia	
			WHERE	CGV.Tipo_Garantia_Real = 1
				AND CGV.Ind_Clase_Alfanumerica = 0
					

			CREATE INDEX AUX_GARANTIA_REAL_GR_IX_01 ON dbo.AUX_GARANTIA_REAL_GR (cod_garantia_real, Fecha_Valuacion) ON [PRIMARY]
	

			/*TABLA AUXILIAR DE AVALUOS DE GARANTIAS REALES PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_VALUACIONES_REALES_GRC') IS NOT NULL
				DROP TABLE dbo.AUX_VALUACIONES_REALES_GRC

			CREATE TABLE dbo.AUX_VALUACIONES_REALES_GRC
			(
				cod_garantia_real     BIGINT  NULL,
				fecha_valuacion       DATETIME  NULL,
				cedula_empresa        VARCHAR(30)  NULL,
				cedula_perito         VARCHAR(30)  NULL,
				monto_ultima_tasacion_terreno  MONEY  NULL,
				monto_ultima_tasacion_no_terreno  MONEY  NULL,
				monto_tasacion_actualizada_terreno  MONEY  NULL,
				monto_tasacion_actualizada_no_terreno  MONEY  NULL,
				fecha_ultimo_seguimiento  DATETIME  NULL,
				monto_total_avaluo    MONEY  NULL,
				cod_recomendacion_perito  SMALLINT  NULL,
				cod_inspeccion_menor_tres_meses  SMALLINT  NULL,
				fecha_construccion    DATETIME  NULL,
				cod_tipo_bien         SMALLINT  NULL,
				ind_avaluo_completo   TINYINT  NULL 
				CONSTRAINT DF_AUX_VALUACIONES_REALES_GRC_ind_avaluo_completo
						DEFAULT  1,
				cod_usuario           VARCHAR(30)  NULL,
				Porcentaje_Aceptacion_Terreno  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_No_Terreno  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_Terreno_Calculado  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_No_Terreno_Calculado  DECIMAL(5,2) NULL,
				Monto_Total_Avaluo_Colonizado    MONEY  NULL
			) ON [PRIMARY]




			/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
			/*Se obtienen los avalúos de las garantías de hipoteca común relacionadas a las operaciones*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 1
				AND CGV.Ind_Clase_Alfanumerica = 0 
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado

			/*Se obtienen los valúos de las garantías de hipoteca común relacionadas a los contratos*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 1
				AND CGV.Ind_Clase_Alfanumerica = 0  
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado
			

			/*SE OBTIENE EL AVALUO MAS RECIENTE DE LAS HIPOTECAS COMUNES ALFANUMERICAS*/
						
			/*Se obtiene la fecha que es mayor*/
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1
			FROM	dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
				LEFT JOIN  dbo.AUX_GAR_HIPOTECAS_ALF_SICC TM1
				ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
				AND TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
				AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
				AND TMP.prmgt_pnuide_alf = TM1.prmgt_pnuide_alf
				AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
			WHERE	ISNULL(TM1.prmgt_pfeavaing, 0) = 0
		
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			WHERE	prmgt_pfeavaing = 19000101
		
			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIA_REAL_GR') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIA_REAL_GR


			/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
			CREATE TABLE dbo.AUX_GARANTIA_REAL_GR 
			(	
				cod_garantia_real BIGINT,
				Fecha_Valuacion DATETIME
			) ON [PRIMARY]
		
			/*Se carga la información de las garantías reales de tipo hipoteca común y que están relacionadas a una operación o contrato*/
			INSERT	INTO dbo.AUX_GARANTIA_REAL_GR(cod_garantia_real, Fecha_Valuacion)
			SELECT	GGR.cod_garantia_real,
					TMP.Fecha_Valuacion
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN 	dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
				ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
				AND GGR.cod_partido = TMP.prmgt_pnu_part 
				AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
				AND GGR.Identificacion_Alfanumerica_Sicc = TMP.prmgt_pnuide_alf COLLATE database_default
			WHERE	GGR.cod_clase_garantia = 11

			CREATE INDEX AUX_GARANTIA_REAL_GR_IX_01 ON dbo.AUX_GARANTIA_REAL_GR (cod_garantia_real, Fecha_Valuacion) ON [PRIMARY]
					
			/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
			/*Se obtienen los avalúos de las garantías de hipoteca común alfanuméricas relacionadas a las operaciones*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_clase_garantia = 11
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado

			/*Se obtienen los valúos de las garantías de hipoteca común alfanuméricas relacionadas a los contratos*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND GGR.cod_clase_garantia = 11
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado


		
			/*SE OBTIENE EL AVALUO MAS RECIENTE DE LAS CEDULAS HIPOTECARIAS*/
					
		
			/*Se obtiene la fecha que es mayor*/
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1
			FROM	dbo.AUX_GAR_CEDULAS_SICC TMP
				LEFT JOIN  dbo.AUX_GAR_CEDULAS_SICC TM1
				ON TMP.prmgt_pnu_part = TM1.prmgt_pnu_part 
				AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
				AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
			WHERE	ISNULL(TM1.prmgt_pfeavaing, 0) = 0
		
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_CEDULAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_CEDULAS_SICC
			WHERE	prmgt_pfeavaing = 19000101
				
				
			/*TABLA AUXILIAR DE CEDULAS HIPOTECARIAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIA_REAL_GR') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIA_REAL_GR


			/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
			CREATE TABLE dbo.AUX_GARANTIA_REAL_GR 
			(	
				cod_garantia_real BIGINT,
				Fecha_Valuacion DATETIME
			) ON [PRIMARY]

		
			/*Se carga la información de las garantías reales de tipo cédula hipotecaria y que están relacionadas a una operación o contrato*/
			INSERT	INTO dbo.AUX_GARANTIA_REAL_GR(cod_garantia_real, Fecha_Valuacion)
			SELECT	GGR.cod_garantia_real,
					TMP.Fecha_Valuacion
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN 	dbo.AUX_GAR_CEDULAS_SICC TMP
				ON GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
				AND GGR.cod_partido = TMP.prmgt_pnu_part 
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	CGV.Tipo_Garantia_Real = 2
				
			CREATE INDEX AUX_GARANTIA_REAL_GR_IX_01 ON dbo.AUX_GARANTIA_REAL_GR (cod_garantia_real, Fecha_Valuacion) ON [PRIMARY]
					
			/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
			/*Se obtienen los avalúos de las garantías de cédula hipotecaria no alfanuméricas relacionadas a las operaciones*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 2
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado

			/*Se obtienen los valúos de las garantías de cédula hipotecaria no alfanuméricas relacionadas a los contratos*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 2
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado


					
			/*SE OBTIENE EL AVALUO MAS RECIENTE DE LAS PRENDAS NO ALFANUMERICAS*/
					
		
			/*Se obtiene la fecha que es mayor*/
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1
			FROM	dbo.AUX_GAR_PRENDAS_SICC TMP
				LEFT JOIN  dbo.AUX_GAR_PRENDAS_SICC TM1
				ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
				AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
				AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
			WHERE	ISNULL(TM1.prmgt_pfeavaing, 0) = 0
		
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_SICC
			WHERE	prmgt_pfeavaing = 19000101
		
				
			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS NO ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIA_REAL_GR') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIA_REAL_GR


			/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
			CREATE TABLE dbo.AUX_GARANTIA_REAL_GR 
			(	
				cod_garantia_real BIGINT,
				Fecha_Valuacion DATETIME
			) ON [PRIMARY]

				
			/*Se carga la información de las garantías reales de tipo prenda y que están relacionadas a una operación o contrato*/
			INSERT	INTO dbo.AUX_GARANTIA_REAL_GR(cod_garantia_real, Fecha_Valuacion)
			SELECT	GGR.cod_garantia_real,
					TMP.Fecha_Valuacion
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN 	dbo.AUX_GAR_PRENDAS_SICC TMP
				ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
				AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 0
				
			CREATE INDEX AUX_GARANTIA_REAL_GR_IX_01 ON dbo.AUX_GARANTIA_REAL_GR (cod_garantia_real, Fecha_Valuacion) ON [PRIMARY]
					
			/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
			/*Se obtienen los avalúos de las garantías de prenda relacionadas a las operaciones*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 0
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado

			/*Se obtienen los valúos de las garantías de prenda relacionadas a los contratos*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 0
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado



			/*SE OBTIENE EL AVALUO MAS RECIENTE DE LAS PRENDAS ALFANUMERICAS*/
					
		
			/*Se obtiene la fecha que es mayor*/
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1
			FROM	dbo.AUX_GAR_PRENDAS_ALF_SICC TMP
				LEFT JOIN  dbo.AUX_GAR_PRENDAS_ALF_SICC TM1
				ON TMP.prmgt_pcoclagar = TM1.prmgt_pcoclagar
				AND TMP.prmgt_pnuidegar = TM1.prmgt_pnuidegar
				AND TMP.prmgt_pnuide_alf = TM1.prmgt_pnuide_alf
				AND TMP.prmgt_pfeavaing < TM1.prmgt_pfeavaing
			WHERE	ISNULL(TM1.prmgt_pfeavaing, 0) = 0
		
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_ALF_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_ALF_SICC
			WHERE	prmgt_pfeavaing = 19000101
			
			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIA_REAL_GR') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIA_REAL_GR


			/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
			CREATE TABLE dbo.AUX_GARANTIA_REAL_GR 
			(	
				cod_garantia_real BIGINT,
				Fecha_Valuacion DATETIME
			) ON [PRIMARY]


		
			/*Se carga la información de las garantías reales de tipo prenda y que están relacionadas a una operación o contrato*/
			INSERT	INTO dbo.AUX_GARANTIA_REAL_GR(cod_garantia_real, Fecha_Valuacion)
			SELECT	GGR.cod_garantia_real,
					TMP.Fecha_Valuacion
			FROM	dbo.GAR_GARANTIA_REAL GGR
				INNER JOIN 	dbo.AUX_GAR_PRENDAS_ALF_SICC TMP
				ON GGR.cod_clase_garantia = TMP.prmgt_pcoclagar
				AND GGR.Identificacion_Sicc = TMP.prmgt_pnuidegar
				AND GGR.Identificacion_Alfanumerica_Sicc = TMP.prmgt_pnuide_alf COLLATE database_default
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 1
				
			CREATE INDEX AUX_GARANTIA_REAL_GR_IX_01 ON dbo.AUX_GARANTIA_REAL_GR (cod_garantia_real, Fecha_Valuacion) ON [PRIMARY]
					
			/* El grado completo se refiere a que tan completo se encuentra un avalúo, siendo 0 = completo, 1 = incompleto*/
			/*Se obtienen los avalúos de las garantías de prenda alfanuméricas relacionadas a las operaciones*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 1
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 1
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado 


			/*Se obtienen los valúos de las garantías de prenda alfanuméricas relacionadas a los contratos*/
			INSERT INTO dbo.AUX_VALUACIONES_REALES_GRC
			(
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
				Porcentaje_Aceptacion_No_Terreno_Calculado,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			)
			SELECT	GVR.cod_garantia_real, 
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
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					--FIN RQ: RQ_MANT_2015062410418218_00090
					GVR.Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
				ON GRO.cod_garantia_real = GVR.cod_garantia_real
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP 
				ON TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_operacion = GRO.cod_operacion
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TMP.cod_garantia
				INNER JOIN dbo.AUX_GARANTIA_REAL_GR TM1
				ON GGR.cod_garantia_real = TM1.cod_garantia_real
				AND GVR.fecha_valuacion = TM1.Fecha_Valuacion
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				AND CGV.Tipo_Garantia_Real = 3
				AND CGV.Ind_Clase_Alfanumerica = 1
			GROUP BY GVR.cod_garantia_real, 
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
					TMP.cod_usuario,
					GVR.Porcentaje_Aceptacion_Terreno,
					GVR.Porcentaje_Aceptacion_No_Terreno,
					GVR.Porcentaje_Aceptacion_Terreno_Calculado,
					GVR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					GVR.Monto_Total_Avaluo_Colonizado



			CREATE CLUSTERED INDEX AUX_VALUACIONES_REALES_GRC_IX_01 ON dbo.AUX_VALUACIONES_REALES_GRC (cod_usuario) ON [PRIMARY]

		END
		IF(@piEjecutar_Parte = 2)
		BEGIN
			
			/*TABLA AUXILIAR DE GARANTIAS REALES PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GARANTIAS_REALES_GRC') IS NOT NULL
				DROP TABLE dbo.AUX_GARANTIAS_REALES_GRC

			CREATE TABLE dbo.AUX_GARANTIAS_REALES_GRC
			(
				cod_contabilidad      TINYINT  NULL ,
				cod_oficina           SMALLINT  NULL ,
				cod_moneda            TINYINT  NULL ,
				cod_producto          TINYINT  NULL ,
				operacion             DECIMAL(7)  NULL ,
				cod_tipo_bien         SMALLINT  NULL ,
				cod_bien              VARCHAR(25)  NULL ,
				cod_tipo_mitigador    SMALLINT  NULL ,
				cod_tipo_documento_legal  SMALLINT  NULL ,
				monto_mitigador       DECIMAL(18,2)  NULL ,
				fecha_presentacion    VARCHAR(10)  NULL ,
				cod_inscripcion       SMALLINT  NULL ,
				porcentaje_responsabilidad  DECIMAL(5,2)  NULL ,
				fecha_constitucion    VARCHAR(10)  NULL ,
				cod_grado_gravamen    SMALLINT  NULL ,
				cod_tipo_acreedor     SMALLINT  NULL ,
				cedula_acreedor       VARCHAR(30)  NULL ,
				fecha_vencimiento     VARCHAR(10)  NULL ,
				cod_operacion_especial  SMALLINT  NULL ,
				fecha_valuacion       VARCHAR(10)  NULL ,
				cedula_empresa        VARCHAR(30)  NULL ,
				cod_tipo_empresa      smallint  NULL ,
				cedula_perito         VARCHAR(30)  NULL ,
				cod_tipo_perito       SMALLINT  NULL ,
				monto_ultima_tasacion_terreno  DECIMAL(18,2)  NULL ,
				monto_ultima_tasacion_no_terreno  DECIMAL(18,2)  NULL ,
				monto_tasacion_actualizada_terreno  DECIMAL(18,2)  NULL ,
				monto_tasacion_actualizada_no_terreno  DECIMAL(18,2)  NULL ,
				fecha_ultimo_seguimiento  VARCHAR(10)  NULL ,
				monto_total_avaluo    DECIMAL(18,2)  NULL ,
				fecha_construccion    VARCHAR(10)  NULL ,
				cod_grado             VARCHAR(2)  NULL ,
				cedula_hipotecaria    VARCHAR(2)  NULL ,
				cod_clase_garantia    SMALLINT  NULL ,
				cod_operacion         BIGINT  NULL ,
				cod_garantia_real     BIGINT  NULL ,
				cod_tipo_garantia_real  TINYINT  NULL ,
				numero_finca          VARCHAR(25)  NULL ,
				num_placa_bien        VARCHAR(25)  NULL ,
				cod_clase_bien        VARCHAR(3)  NULL ,
				cedula_deudor         VARCHAR(30)  NULL ,
				cod_estado            SMALLINT  NULL ,
				cod_liquidez          SMALLINT  NULL ,
				cod_tenencia          SMALLINT  NULL ,
				cod_moneda_garantia   SMALLINT  NULL ,
				cod_partido           SMALLINT  NULL ,
				cod_tipo_garantia     SMALLINT  NULL ,
				Garantia_Real         VARCHAR(150)  NULL ,
				fecha_prescripcion    VARCHAR(10)  NULL ,
				cod_tipo_operacion    TINYINT  NOT NULL ,
				ind_operacion_vencida  TINYINT  NULL ,
				ind_duplicidad        TINYINT  NOT NULL 
				CONSTRAINT DF_AUX_GARANTIAS_REALES_GRC_ind_duplicidad
						DEFAULT  1 ,
				cod_usuario           VARCHAR(30)  NOT NULL ,
				Porcentaje_Aceptacion_Terreno  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_No_Terreno  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_Terreno_Calculado  DECIMAL(5,2) NULL,
				Porcentaje_Aceptacion_No_Terreno_Calculado  DECIMAL(5,2) NULL,
				Codigo_SAP NUMERIC(8,0) NULL,
				Monto_Poliza_Colonizado NUMERIC(16,2) NULL,
				Fecha_Vencimiento_Poliza DATETIME NULL,
				Codigo_Tipo_Poliza_Sugef  INT NULL,
				Indicador_Poliza CHAR(1) NULL,
				Indicador_Coberturas_Obligatorias  CHAR(2) NULL,
				Porcentaje_Aceptacion DECIMAL(5,2)  NOT NULL 
				CONSTRAINT DF_AUX_GARANTIAS_REALES_GRC_PorcentajeAceptacion
						DEFAULT  -1,
				Monto_Total_Avaluo_Colonizado DECIMAL(18,2)  NULL 
			) ON [PRIMARY]
			

					
			/*Se selecciona la información de la garantía real asociada a los contratos*/
			INSERT	INTO dbo.AUX_GARANTIAS_REALES_GRC
			SELECT	GO1.cod_contabilidad, 
					GO1.cod_oficina, 
					GO1.cod_moneda, 
					GO1.cod_producto, 
					GO1.num_contrato AS operacion, 
					GGR.cod_tipo_bien, 
					CASE 
						WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
						WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
						WHEN ((GGR.cod_tipo_garantia_real = 3) AND (CGV.Ind_Clase_Alfanumerica = 0)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
						WHEN ((GGR.cod_tipo_garantia_real = 3) AND (CGV.Ind_Clase_Alfanumerica = 1)) THEN COALESCE(GGR.num_placa_bien,'') 
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
					GRO.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
					VGR.Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo
			FROM	dbo.GAR_OPERACION GO1 
				INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
				ON GO1.cod_operacion = GRO.cod_operacion 
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
				ON GRO.cod_garantia_real = GGR.cod_garantia_real 
				LEFT OUTER JOIN  dbo.AUX_VALUACIONES_REALES_GRC VGR
				ON VGR.cod_garantia_real = GGR.cod_garantia_real
				AND VGR.cod_usuario = @psCedula_Usuario
				LEFT OUTER JOIN dbo.GAR_PERITO GPR
				ON VGR.cedula_perito = GPR.cedula_perito 
				INNER JOIN dbo.AUX_OPERACIONES_GRC TMP
				ON TMP.cod_operacion = GRO.cod_operacion
				AND TMP.cod_garantia = GRO.cod_garantia_real
				AND TMP.cod_tipo_garantia = 2
				AND TMP.cod_tipo_operacion = 2
				AND TMP.cod_usuario = @psCedula_Usuario
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON 	CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE GRO.cod_estado = 1
			GROUP BY GO1.cod_contabilidad, 
					GO1.cod_oficina, 
					GO1.cod_moneda, 
					GO1.cod_producto, 
					GO1.num_contrato, 
					GGR.cod_tipo_bien, 
					GGR.cod_tipo_garantia_real, 
					GRO.cod_tipo_mitigador, 
					GRO.cod_tipo_documento_legal, 
					GRO.monto_mitigador, 
					GRO.fecha_presentacion,
					GRO.cod_inscripcion, 
					GRO.porcentaje_responsabilidad, 
					GRO.fecha_constitucion, 
					GRO.cod_grado_gravamen, 
					GRO.cod_tipo_acreedor, 
					GRO.cedula_acreedor, 
					GRO.fecha_vencimiento, 
					GRO.cod_operacion_especial, 
					GRO.Porcentaje_Aceptacion,
					VGR.fecha_valuacion,
					VGR.cedula_empresa, 
					VGR.cedula_perito, 
					GPR.cod_tipo_persona, 
					VGR.monto_ultima_tasacion_terreno, 
					VGR.monto_ultima_tasacion_no_terreno, 
					VGR.monto_tasacion_actualizada_terreno, 
					VGR.monto_tasacion_actualizada_no_terreno, 
					VGR.fecha_ultimo_seguimiento, 
					VGR.fecha_construccion,
					GGR.cod_grado,
					GGR.cedula_hipotecaria,
					GGR.cod_clase_garantia,
					GO1.cod_operacion,
					GGR.cod_garantia_real,
					GGR.cod_tipo_garantia_real,
					GGR.cod_partido,
					GGR.numero_finca,
					GGR.num_placa_bien,
					GGR.cod_clase_bien,
					GO1.cedula_deudor,
					TMP.cod_tipo_operacion,
					TMP.ind_contrato_vencido,
					TMP.cod_usuario,
					VGR.Porcentaje_Aceptacion_Terreno,
					VGR.Porcentaje_Aceptacion_No_Terreno,
					VGR.Porcentaje_Aceptacion_Terreno_Calculado,
					VGR.Porcentaje_Aceptacion_No_Terreno_Calculado,
					VGR.Monto_Total_Avaluo_Colonizado,
					CGV.Ind_Clase_Alfanumerica 
			ORDER	BY
					GO1.cod_operacion,
					GGR.numero_finca,
					GGR.cod_grado,
					GGR.cod_clase_bien,
					GGR.num_placa_bien,
					GRO.cod_tipo_documento_legal DESC,
					VGR.fecha_valuacion DESC	
			
			CREATE CLUSTERED INDEX AUX_GARANTIAS_REALES_GRC_IX_01 ON dbo.AUX_GARANTIAS_REALES_GRC (cod_usuario ASC, cod_tipo_operacion ASC) ON [PRIMARY]
			CREATE NONCLUSTERED INDEX AUX_GARANTIAS_REALES_GRC_IX_02 ON dbo.AUX_GARANTIAS_REALES_GRC (cod_oficina ASC, cod_moneda ASC, cod_producto ASC, operacion ASC, cod_tipo_garantia_real ASC, cod_tipo_operacion ASC) ON [PRIMARY]
			CREATE NONCLUSTERED INDEX AUX_GARANTIAS_REALES_GRC_IX_03 ON dbo.AUX_GARANTIAS_REALES_GRC (cod_usuario ASC, cod_tipo_operacion ASC, cod_tipo_garantia ASC, cod_clase_garantia ASC) ON [PRIMARY]

			

			/*Se eliminan los registros incompletos*/
			DELETE	FROM dbo.AUX_GARANTIAS_REALES_GRC
			WHERE	cod_usuario = @psCedula_Usuario
				AND cod_tipo_operacion = 2
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
				FROM	dbo.AUX_GARANTIAS_REALES_GRC
				WHERE	cod_usuario = @psCedula_Usuario
					AND cod_tipo_operacion = 2
					AND cod_tipo_garantia = 2
					AND cod_clase_garantia >= 10 
					AND cod_clase_garantia <= 17
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
				FROM	dbo.AUX_GARANTIAS_REALES_GRC
				WHERE	cod_usuario = @psCedula_Usuario
					AND cod_tipo_operacion = 2
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
				FROM	dbo.AUX_GARANTIAS_REALES_GRC
				WHERE	cod_usuario = @psCedula_Usuario
					AND cod_tipo_operacion = 2
					AND cod_tipo_garantia = 2
					AND cod_clase_garantia >= 20 
					AND cod_clase_garantia <= 29
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
				FROM	dbo.AUX_GARANTIAS_REALES_GRC
				WHERE	cod_usuario = @psCedula_Usuario
					AND cod_tipo_operacion = 2
					AND cod_tipo_garantia = 2
					AND cod_clase_garantia >= 30 
					AND cod_clase_garantia <= 69
			)
			DELETE
			FROM CTE
			WHERE cantidadRegistrosDuplicados > 1

		
		END	
		IF(@piEjecutar_Parte = 3)
		BEGIN
	
			DECLARE @vbIndicador_Borrar_Registros BIT,
					@vdtFecha_Actual DATE

			SET @vdtFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		
			--INICIO RQ: 2016012710534870

			SET	@vdtFecha_Actual = GETDATE()

			--Se define si se debe eliminar el contenido de las estructuras para SICAD involucradas
			SET	@vbIndicador_Borrar_Registros = (SELECT	CASE	
															WHEN FECHA_PROCESO IS NULL THEN 1
															WHEN FECHA_PROCESO < @vdtFecha_Actual THEN 1
															ELSE 0
														END
												 FROM	dbo.SICAD_GAROPER
												 GROUP BY FECHA_PROCESO)
	
			--SE ELIMINAN LAS GARANTIAS FIDUCIARIAS
			DELETE FROM dbo.SICAD_FIDUCIARIAS WHERE @vbIndicador_Borrar_Registros = 1
	
			--SE ELIMINAN LAS GARANTIAS REALES
			DELETE FROM dbo.SICAD_REALES WHERE @vbIndicador_Borrar_Registros = 1
			DELETE FROM dbo.SICAD_REALES_POLIZA WHERE @vbIndicador_Borrar_Registros = 1
			DELETE FROM dbo.SICAD_GAROPER_GRAVAMEN WHERE @vbIndicador_Borrar_Registros = 1

			--SE ELIMINAN LAS GARANTIAS VALOR
			DELETE FROM dbo.SICAD_VALORES WHERE @vbIndicador_Borrar_Registros = 1
	
			--SE ELIMINAN LOS DATOS COMUNES
			DELETE FROM dbo.SICAD_GAROPER WHERE  @vbIndicador_Borrar_Registros = 1
			DELETE FROM dbo.SICAD_GAROPER_LISTA WHERE @vbIndicador_Borrar_Registros = 1

			--FIN RQ: 2016012710534870

			

			/*TABLA AUXILIAR DE PORCENTAJES DE ACEPTACION CALCULADOS*/
			IF OBJECT_ID('dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO') IS NOT NULL
				DROP TABLE dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO
																

			/*Esta tabla almacenará los porcentajes de aceptacion calculados*/
			CREATE TABLE dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
			(	
				Cod_Operacion BIGINT NOT NULL,
				Cod_Garantia_Real BIGINT NOT NULL,
				Porcentaje_Aceptacion DECIMAL(5, 2) NOT NULL,
				Porcentaje_Calculado_Original DECIMAL(5, 2) NOT NULL,
				Fecha_Valuacion DATETIME NOT NULL,
				Fecha_Ultimo_Seguimiento DATETIME NOT NULL,
				Cod_Tipo_Garantia_Real SMALLINT NOT NULL,
				Cod_Tipo_Bien SMALLINT NOT NULL,
				Monto_Ultima_Tasacion_No_Terreno DECIMAL(18, 2) NOT NULL,
				Cod_Usuario VARCHAR(30) NOT NULL,
				Deudor_Habita_Vivienda BIT NOT NULL
			) ON [PRIMARY]			
			

			INSERT INTO dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
			(           
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

			 SELECT	TGR.cod_operacion,
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
			 FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR   
				INNER JOIN  dbo.CAT_PORCENTAJE_ACEPTACION CPA
				ON CPA.Codigo_Tipo_Garantia = 2 
				AND CPA.Codigo_Tipo_Mitigador = TGR.cod_tipo_mitigador
				INNER JOIN dbo.GAR_GARANTIA_REAL GGR
				ON GGR.cod_garantia_real = TGR.cod_garantia_real 
			 WHERE	TGR.cod_usuario = @psCedula_Usuario	   
				AND TGR.cod_tipo_operacion = 2
				AND TGR.cod_tipo_bien >= 1 
				AND TGR.cod_tipo_bien <= 4
			GROUP BY TGR.cod_operacion,
					TGR.cod_garantia_real,
					CPA.Porcentaje_Aceptacion,  
					CPA.Porcentaje_Aceptacion,
					TGR.fecha_valuacion,
					TGR.fecha_ultimo_seguimiento,
					TGR.cod_tipo_garantia_real,
					TGR.cod_tipo_bien,
					TGR.monto_ultima_tasacion_no_terreno, 
					GGR.Indicador_Vivienda_Habitada_Deudor			
			
		
			---------------------------------------------------------------------------------
			/*ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDaCIONES */ 
			---------------------------------------------------------------------------------

			/*SE ACTUALIZAN ALGUNOS DATOS CON EL FIN DE FACILITAR LA OBTENCION DE REGISTROS*/
			UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
			SET		fecha_presentacion = '19000101'
			WHERE	cod_usuario = @psCedula_Usuario	
				AND cod_tipo_operacion = 2
				AND fecha_presentacion IS NULL

			UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
			SET		fecha_constitucion = '19000101'
			WHERE	cod_usuario = @psCedula_Usuario	
				AND cod_tipo_operacion = 2
				AND fecha_constitucion IS NULL
		
			UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
			SET		cod_inscripcion = -1
			WHERE	cod_usuario = @psCedula_Usuario	
				AND cod_tipo_operacion = 2
				AND cod_inscripcion IS NULL

			------------------------------
			--INDICAROD DE INSCRIPCION
			------------------------------

				--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
				--que no poseen asignado el indicador de inscripción. 
					WITH PORCENTAJE_CALCULADO AS 
					(
						SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, Cod_Usuario
						FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						WHERE	Cod_Usuario = @psCedula_Usuario
					)
					UPDATE	PAC 
					SET		Porcentaje_Aceptacion = 0
					FROM	PORCENTAJE_CALCULADO AS  PAC  
						INNER JOIN dbo.AUX_GARANTIAS_REALES_GRC AS TGR 
						ON TGR.cod_operacion = PAC.Cod_Operacion
						AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
						AND TGR.cod_usuario = PAC.Cod_Usuario
					WHERE	TGR.cod_usuario = @psCedula_Usuario
						AND TGR.cod_tipo_operacion = 2
						AND TGR.fecha_presentacion > '19000101'
						AND TGR.cod_inscripcion = -1;


				--Se actualiza el indicador de inconsistencia de inscripcion a 1 , de la información de las garantías reales asociadas a las operaciones 
				--que poseen asignado el indicador de inscripción "Anotada", pero cuya fecha de proceso (fecha actual) 
				--supera la fecha resultante de sumarle 60 días a la fecha de constitución. 
						
					WITH PORCENTAJE_CALCULADO AS 
					(
						SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, Cod_Usuario
						FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						WHERE	Cod_Usuario = @psCedula_Usuario
					)
					UPDATE	PAC 
					SET		Porcentaje_Aceptacion = 0
					FROM	PORCENTAJE_CALCULADO AS  PAC  
						INNER JOIN dbo.AUX_GARANTIAS_REALES_GRC AS TGR 
						ON TGR.cod_operacion = PAC.Cod_Operacion
						AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
						AND TGR.cod_usuario = PAC.Cod_Usuario
					WHERE	TGR.cod_usuario = @psCedula_Usuario
						AND TGR.cod_tipo_operacion = 2
						AND TGR.fecha_presentacion > '19000101'
						AND TGR.cod_inscripcion = 2
						AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 60, TGR.fecha_constitucion);
				

				--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
				--que poseen asignado el indicador de inscripción "No Anotada/No Inscrita", pero cuya fecha de proceso 
				--(fecha actual) supera, o es igual a, la fecha resultante de sumarle 30 días a la fecha de constitución.  
		    			
					WITH PORCENTAJE_CALCULADO AS 
					(
						SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, Cod_Usuario
						FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						WHERE	Cod_Usuario = @psCedula_Usuario
					)
					UPDATE	PAC 
					SET		Porcentaje_Aceptacion = 0
					FROM	PORCENTAJE_CALCULADO AS  PAC  
						INNER JOIN dbo.AUX_GARANTIAS_REALES_GRC AS TGR 
						ON TGR.cod_operacion = PAC.Cod_Operacion
						AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
						AND TGR.cod_usuario = PAC.Cod_Usuario
					WHERE	TGR.cod_usuario = @psCedula_Usuario
						AND TGR.cod_tipo_operacion = 2
						AND TGR.fecha_presentacion > '19000101'
						AND TGR.cod_inscripcion = 1
						AND @vdtFecha_Actual_Sin_Hora > DATEADD(DAY, 30, TGR.fecha_constitucion);
				
						

				--Se actualiza el indicador de inconsistencia de inscripcion a 1, de la información de las garantías reales asociadas a las operaciones 
				--que poseen asignado el indicador de inscripción "No Aplica", pero que poseen un tipo de bien
				--diferente a "Otros tipos de bienes". 
				
					WITH PORCENTAJE_CALCULADO AS 
					(
						SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, Cod_Usuario
						FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						WHERE	Cod_Usuario = @psCedula_Usuario
					)
					UPDATE	PAC 
					SET		Porcentaje_Aceptacion = 0
					FROM	PORCENTAJE_CALCULADO AS  PAC  
						INNER JOIN dbo.AUX_GARANTIAS_REALES_GRC AS TGR 
						ON TGR.cod_operacion = PAC.Cod_Operacion
						AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
						AND TGR.cod_usuario = PAC.Cod_Usuario
					WHERE	TGR.cod_usuario = @psCedula_Usuario
						AND TGR.cod_tipo_operacion = 2
						AND TGR.cod_inscripcion = 0
						AND ((TGR.cod_tipo_bien < 14) OR (TGR.cod_tipo_bien > 14));	

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
						WITH PORCENTAJE_CALCULADO AS 
						(
							SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real
							FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
							WHERE	Cod_Usuario = @psCedula_Usuario
								AND ((Cod_Tipo_Garantia_Real = 1) OR (Cod_Tipo_Garantia_Real = 2))	
								AND Cod_Tipo_Bien = 1
						)
						UPDATE	PAC 
						SET		Porcentaje_Aceptacion = 0
						FROM	PORCENTAJE_CALCULADO AS  PAC  
							INNER JOIN dbo.GAR_POLIZAS_RELACIONADAS GPR
							ON GPR.cod_operacion = PAC.Cod_Operacion
							AND GPR.cod_garantia_real = PAC.Cod_Garantia_Real						
							INNER JOIN dbo.GAR_POLIZAS GPO
							ON GPO.Codigo_SAP = GPR.Codigo_SAP
							AND GPO.cod_operacion = GPR.cod_operacion				
						WHERE	GPO.Estado_Registro = 1
							AND GPR.Estado_Registro = 1;
	
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
						--AND  DATEDIFF(YEAR,TPAC.Fecha_Ultimo_Seguimiento, @vdtFecha_Actual_Sin_Hora) > 1 
						--AND TPAC.Cod_Usuario =  @psCedula_Usuario	
		        
					--------------
					--VALUACION
					--------------	
					
						--FECHA VALUACION MAYOR A 5 AÑOS
					
						--WITH PORCENTAJE_CALCULADO AS 
						--(
						--	SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real
						--	FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						--	WHERE	Cod_Usuario = @psCedula_Usuario
						--		AND Cod_Tipo_Garantia_Real = 3
						--		AND Cod_Tipo_Bien = 3
						--		AND DATEDIFF(YEAR, Fecha_Valuacion, @vdtFecha_Actual_Sin_Hora) > 5	
						--)
						--UPDATE	PAC 
						--SET		Porcentaje_Aceptacion = 0
						--FROM	PORCENTAJE_CALCULADO AS  PAC;


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
						WITH PORCENTAJE_CALCULADO AS 
						(
							SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
							FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
							WHERE	Cod_Usuario = @psCedula_Usuario
								AND Cod_Tipo_Bien = 1	
								AND ((Cod_Tipo_Garantia_Real = 1) OR (Cod_Tipo_Garantia_Real = 2))
								AND DATEDIFF(YEAR, Fecha_Ultimo_Seguimiento, @vdtFecha_Actual_Sin_Hora) > 1
								AND Porcentaje_Aceptacion > 0     
						)
						UPDATE PC1 
						SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						FROM PORCENTAJE_CALCULADO AS PC1;


					--------------
					--VALUACION
					--------------
				
						--FECHA VALUACION MAYOR A 5 AÑOS	
						WITH PORCENTAJE_CALCULADO AS 
						(
							SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
							FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
							WHERE	Cod_Usuario = @psCedula_Usuario
								AND Cod_Tipo_Bien = 1	
								AND ((Cod_Tipo_Garantia_Real = 1) OR (Cod_Tipo_Garantia_Real = 2))
								AND Porcentaje_Aceptacion > 0
								AND DATEDIFF(YEAR, Fecha_Valuacion, @vdtFecha_Actual_Sin_Hora) > 5	     
						)
						UPDATE PC1 
						SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						FROM PORCENTAJE_CALCULADO AS PC1;
					
					
			-------------------
			--TIPO DE BIEN: 2
			-------------------
					--------------
					--VALUACION
					--------------
				
					--FECHA VALUACION MAYOR A 5 AÑOS FECHA SISTEMA				
					
						--WITH PORCENTAJE_CALCULADO AS 
						--(
						--	SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
						--	FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						--	WHERE	Cod_Usuario = @psCedula_Usuario
						--		AND Cod_Tipo_Bien = 2	
						--		AND ((Cod_Tipo_Garantia_Real = 1) OR (Cod_Tipo_Garantia_Real = 2))
						--		AND Porcentaje_Aceptacion > 0
						--		AND DATEDIFF(YEAR, Fecha_Valuacion, @vdtFecha_Actual_Sin_Hora) > 5	     
						--)
						--UPDATE PC1 
						--SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						--FROM PORCENTAJE_CALCULADO AS PC1;

					
					---------------
					--SEGUIMIENTO
					---------------
				
						--FECHA SEGUIMIENTO MAYOR A UN AÑO CONTRA SISTEMA
						WITH PORCENTAJE_CALCULADO AS 
						(
							SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
							FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
							WHERE	Cod_Usuario = @psCedula_Usuario
								AND Cod_Tipo_Bien = 2	
								AND ((Cod_Tipo_Garantia_Real = 1) OR (Cod_Tipo_Garantia_Real = 2))
								AND Porcentaje_Aceptacion > 0
								AND DATEDIFF(YEAR, Fecha_Ultimo_Seguimiento, @vdtFecha_Actual_Sin_Hora) > 1  
								AND COALESCE(Deudor_Habita_Vivienda, 0) = 0  
						)
						UPDATE PC1 
						SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						FROM PORCENTAJE_CALCULADO AS PC1;


					--------------
					--POLIZA
					--------------
						--NO TIENE POLIZA ASOCIADA			
					
						--UPDATE  TPAC
						--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)			
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
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
						--	AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
						--	AND TPAC.Porcentaje_Aceptacion > 0
						--	AND TPAC.Cod_Usuario = @psCedula_Usuario	   
					
						--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
						--UPDATE  TPAC
						--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
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
						--	AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
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
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC				
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
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC
						--	INNER JOIN dbo.AUX_GARANTIAS_REALES_GRC TMGR
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
						--	AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
						--	AND TPAC.Porcentaje_Aceptacion > 0  
						--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 
					
						--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
						--UPDATE  TPAC
						--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC								
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
						--	AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
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
					
						WITH PORCENTAJE_CALCULADO AS 
						(
							SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
							FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
							WHERE	Cod_Usuario = @psCedula_Usuario
								AND Cod_Tipo_Bien = 4	
								AND Cod_Tipo_Garantia_Real = 3
								AND Porcentaje_Aceptacion > 0
								AND DATEDIFF(MONTH, Fecha_Ultimo_Seguimiento, @vdtFecha_Actual_Sin_Hora) > 6 
						)
						UPDATE PC1 
						SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						FROM PORCENTAJE_CALCULADO AS PC1;
										
					--------------
					--VALUACION
					--------------	
				
						--FECHA VALUACION MAYOR A 5 AÑOS
					
						--WITH PORCENTAJE_CALCULADO AS 
						--(
						--	SELECT	Porcentaje_Aceptacion, Porcentaje_Calculado_Original
						--	FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO 
						--	WHERE	Cod_Usuario = @psCedula_Usuario
						--		AND Cod_Tipo_Bien = 4	
						--		AND Cod_Tipo_Garantia_Real = 3
						--		AND Porcentaje_Aceptacion > 0
						--		AND DATEDIFF(YEAR, Fecha_Valuacion, @vdtFecha_Actual_Sin_Hora) > 5
						--)
						--UPDATE PC1 
						--SET Porcentaje_Aceptacion = (PC1.Porcentaje_Calculado_Original / 2)
						--FROM PORCENTAJE_CALCULADO AS PC1;


					--------------
					--POLIZA
					--------------
					--NO TIENE POLIZA ASOCIADA			
					
						--UPDATE  TPAC
						--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)			
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC					
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
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
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
						--	AND GPO.Fecha_Vencimiento < @vdtFecha_Actual_Sin_Hora	
						--	AND TPAC.Porcentaje_Aceptacion > 0  
						--	AND TPAC.Cod_Usuario = @psCedula_Usuario	 
					
						--POLIZA ASOCIADA CON FECHA VENCIMIENTO MAYOR A LA FECHA DE PROCESO Y MONTO DE POLIZA NO CUBRE EL MONTO DE ULTIMA TASACION NO TERRENO	
					
						--UPDATE  TPAC
						--SET		TPAC.Porcentaje_Aceptacion = (TPAC.Porcentaje_Calculado_Original / 2)
						--FROM	dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO TPAC							
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
						--	AND GPO.Fecha_Vencimiento > @vdtFecha_Actual_Sin_Hora	
						--	AND GPO.Monto_Poliza_Colonizado < TPAC.Monto_Ultima_Tasacion_No_Terreno
						--	AND TPAC.Porcentaje_Aceptacion > 0 
						--	AND TPAC.Cod_Usuario = @psCedula_Usuario	  
					
			---------------------------------------------------------------------------------
			/* FIN ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION CON LAS VALIDaCIONES */
			---------------------------------------------------------------------------------

			/* ACTUALIZACION DEL CAMPO DE PORCENTAJE DE ACEPTACION DE LA TABLA TEMPORAL PRINCIPAL */ 

				UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
				SET		Porcentaje_Aceptacion = 0
				WHERE	cod_usuario = @psCedula_Usuario
					AND cod_tipo_operacion = 2
					AND Porcentaje_Aceptacion IS NULL

			
				WITH GARANTIAS_REALES AS 
				(
					SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, cod_usuario
					FROM	dbo.AUX_GARANTIAS_REALES_GRC 
					WHERE	cod_usuario = @psCedula_Usuario
						AND cod_tipo_operacion = 2
						AND Porcentaje_Aceptacion = 0)
				UPDATE	TGR
				SET Porcentaje_Aceptacion = PAC.Porcentaje_Aceptacion
				FROM GARANTIAS_REALES AS TGR  
					INNER JOIN dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO AS PAC 
					ON TGR.cod_operacion = PAC.Cod_Operacion
					AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
					AND TGR.cod_usuario = PAC.Cod_Usuario
				WHERE PAC.Cod_Usuario = @psCedula_Usuario;
			

				WITH GARANTIAS_REALES AS 
				(
					SELECT	Porcentaje_Aceptacion, cod_operacion, cod_garantia_real, cod_usuario
					FROM	dbo.AUX_GARANTIAS_REALES_GRC 
					WHERE	cod_usuario = @psCedula_Usuario
						AND cod_tipo_operacion = 2
				)
				UPDATE TGR 
				SET Porcentaje_Aceptacion = PAC.Porcentaje_Aceptacion
				FROM GARANTIAS_REALES AS TGR  
					INNER JOIN dbo.TMP_PORCENTAJE_ACEPTACION_CALCULADO AS PAC 
					ON TGR.cod_operacion = PAC.Cod_Operacion
					AND TGR.cod_garantia_real = PAC.Cod_Garantia_Real
					AND TGR.cod_usuario = PAC.Cod_Usuario
				WHERE PAC.Cod_Usuario = @psCedula_Usuario
					AND TGR.Porcentaje_Aceptacion > PAC.Porcentaje_Aceptacion;

			
		/*SE RESTAURAN LOS VALORES SETEADOS AL INICIO DE ESTE CALCULO*/
		UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
		SET		fecha_presentacion = NULL
		WHERE	cod_usuario =  @psCedula_Usuario	
			AND cod_tipo_operacion = 2
			AND fecha_presentacion = '19000101'

		UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
		SET		fecha_constitucion = NULL
		WHERE	cod_usuario =  @psCedula_Usuario	
			AND cod_tipo_operacion = 2
			AND fecha_constitucion = '19000101'
			
		UPDATE	dbo.AUX_GARANTIAS_REALES_GRC
		SET		cod_inscripcion = NULL
		WHERE	cod_usuario =  @psCedula_Usuario	
			AND cod_tipo_operacion = 2
			AND cod_inscripcion = -1

	/***************************************************************************************************************************************************/
	
		--INICIO RQ: RQ_MANT_2015062410418218_00090
	
		--SE ACTUALIZA LA INFORMACIÓN DE LA PÓLIZA
		UPDATE	TGR
		SET		TGR.Codigo_SAP = GPR.Codigo_SAP,
				TGR.Monto_Poliza_Colonizado = GPO.Monto_Poliza_Colonizado,
				TGR.Fecha_Vencimiento_Poliza = GPO.Fecha_Vencimiento,
				TGR.Codigo_Tipo_Poliza_Sugef = TPB.Codigo_Tipo_Poliza_Sugef,
				TGR.Indicador_Poliza = 'S'
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
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
			AND TGR.cod_tipo_operacion = 2
			AND GPO.Estado_Registro = 1
			AND GPR.Estado_Registro = 1


		/*TABLA AUXILIAR DE COBERTURAS POR ASIGNAR*/
		IF OBJECT_ID('dbo.AUX_COBERTURAS_ASIGNAR') IS NOT NULL
			DROP TABLE dbo.AUX_COBERTURAS_ASIGNAR
													

		/*Esta tabla almacenará las coberturas obligatorias por asignar de las pólizas*/
		CREATE TABLE dbo.AUX_COBERTURAS_ASIGNAR 
		(	
			Codigo_SAP	NUMERIC(8,0),
			Codigo_Tipo_Poliza NUMERIC(3,0),
			Codigo_Tipo_Cobertura NUMERIC(3,0),
			Cantidad_Coberturas_Obligatorias INT
		) ON [PRIMARY]
		 
		 

		--SE OBTIENEN LAS COBERTURAS OBLIGATORIAS POR ASIGNAR A LA POLIZA
		INSERT	INTO dbo.AUX_COBERTURAS_ASIGNAR (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura, Cantidad_Coberturas_Obligatorias)
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


		CREATE INDEX AUX_COBERTURAS_ASIGNAR_IX_01 ON dbo.AUX_COBERTURAS_ASIGNAR (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura)
		


		/*TABLA AUXILIAR DE COBERTURAS ASIGNADAS*/
		IF OBJECT_ID('dbo.AUX_COBERTURAS_ASIGNADAS') IS NOT NULL
			DROP TABLE dbo.AUX_COBERTURAS_ASIGNADAS

		/*Esta tabla almacenará las coberturas obligatorias asignadas de las pólizas*/
		CREATE TABLE dbo.AUX_COBERTURAS_ASIGNADAS (	Codigo_SAP	NUMERIC(8,0),
													Codigo_Tipo_Poliza NUMERIC(3,0),
													Codigo_Tipo_Cobertura NUMERIC(3,0),
													Cantidad_Coberturas_Obligatorias INT)
		 
		--SE OBTIENEN LAS COBERTURAS OBLIGATORIAS ASIGNADAS A LA POLIZA
		INSERT	INTO dbo.AUX_COBERTURAS_ASIGNADAS (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura, Cantidad_Coberturas_Obligatorias)
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


		CREATE INDEX AUX_COBERTURAS_ASIGNADAS_IX_01 ON dbo.AUX_COBERTURAS_ASIGNADAS (Codigo_SAP, Codigo_Tipo_Poliza, Codigo_Tipo_Cobertura)

	
		--SE ACTUALIZA EL INDICADOR DE SI LA POLIZA POSEE TODAS LAS COBERTURAS OBLIGATORIAS ASIGNADAS
		UPDATE	TGR
		SET		TGR.Indicador_Coberturas_Obligatorias = CASE 
															WHEN CP2.Codigo_SAP IS NULL THEN 'NO'
															WHEN CP1.Cantidad_Coberturas_Obligatorias = CP2.Cantidad_Coberturas_Obligatorias THEN 'SI'
															ELSE 'NO'
														END
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.AUX_COBERTURAS_ASIGNAR CP1
			ON CP1.Codigo_SAP = TGR.Codigo_SAP
			LEFT OUTER JOIN dbo.AUX_COBERTURAS_ASIGNADAS CP2
			ON CP2.Codigo_SAP = TGR.Codigo_SAP
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
		
		--SE ASIGNA EL VALOR NULL A LOS CAMPOS DE LOS PORCENTAJES QUE SEAN MENORES O IGUALES A -1
		UPDATE	TGR
		SET		TGR.Porcentaje_Aceptacion_Terreno = NULL
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.Porcentaje_Aceptacion_Terreno <= -1

		UPDATE	TGR
		SET		TGR.Porcentaje_Aceptacion_No_Terreno = NULL
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.Porcentaje_Aceptacion_No_Terreno <= -1

		UPDATE	TGR
		SET		TGR.Porcentaje_Aceptacion_Terreno_Calculado = NULL
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.Porcentaje_Aceptacion_Terreno_Calculado <= -1

		UPDATE	TGR
		SET		TGR.Porcentaje_Aceptacion_No_Terreno_Calculado = NULL
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.Porcentaje_Aceptacion_No_Terreno_Calculado <= -1

		--FIN RQ: RQ_MANT_2015062410418218_00090

		UPDATE	TGR
		SET		TGR.porcentaje_responsabilidad = NULL
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.porcentaje_responsabilidad <= -1

		UPDATE	TGR
		SET		TGR.Porcentaje_Aceptacion = 0
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.Porcentaje_Aceptacion <= -1

	/***************************************************************************************************************************************************/

		--INICIO RQ: 2016012710534870
		UPDATE	TGR
		SET		TGR.fecha_ultimo_seguimiento = ''
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND TGR.fecha_ultimo_seguimiento IS NULL

		INSERT INTO dbo.SICAD_REALES (	ID_GARANTIA_REAL, TIPO_BIEN_GARANTIA_REAL, ID_BIEN, MONTO_ULTIMA_TASACION_TERRENO, MONTO_ULTIMA_TASACION_NO_TERRENO, 
										FECHA_ULTIMA_TASACION_GARANTIA, MONTO_TASACION_ACTUALIZADA_TERRENO, MONTO_TASACION_ACTUALIZADA_NO_TERRENO, 
										FECHA_ULTIMO_SEGUIMIENTO_GARANTIA, FECHA_CONSTRUCCION, TIPO_PERSONA_TASADOR, ID_TASADOR, TIPO_PERSONA_EMPRESA_TASADORA, 
										ID_EMPRESA_TASADORA, CODIGO_EMPRESA)
		SELECT	TGR.cod_bien AS ID_GARANTIA_REAL,
				COALESCE(TGR.cod_tipo_bien, 1) AS TIPO_BIEN_GARANTIA_REAL,
				TGR.cod_bien AS ID_BIEN, 
				COALESCE(TGR.monto_ultima_tasacion_terreno, 0) AS MONTO_ULTIMA_TASACION_TERRENO,
				COALESCE(TGR.monto_ultima_tasacion_no_terreno, 0) AS MONTO_ULTIMA_TASACION_NO_TERRENO,
				CASE 
					WHEN LEN(TGR.fecha_valuacion) = 0 THEN '19000101'
					ELSE TGR.fecha_valuacion
				END AS FECHA_ULTIMA_TASACION_GARANTIA,
				COALESCE(TGR.monto_tasacion_actualizada_terreno, 0) AS MONTO_TASACION_ACTUALIZADA_TERRENO,
				COALESCE(TGR.monto_tasacion_actualizada_no_terreno, 0) AS MONTO_TASACION_ACTUALIZADA_NO_TERRENO,
				CASE
					WHEN ((LEN(TGR.fecha_ultimo_seguimiento) = 0) AND (LEN(TGR.fecha_valuacion) > 0))  THEN TGR.fecha_valuacion
					WHEN ((LEN(TGR.fecha_ultimo_seguimiento) = 0) AND (LEN(TGR.fecha_valuacion) = 0))  THEN '19000101'
					WHEN ((TGR.fecha_ultimo_seguimiento LIKE '19000101') AND (LEN(TGR.fecha_valuacion) > 0)) THEN TGR.fecha_valuacion
					ELSE TGR.fecha_ultimo_seguimiento
				END AS FECHA_ULTIMO_SEGUIMIENTO_GARANTIA,
				CASE 
					WHEN LEN(TGR.fecha_construccion) = 0 THEN NULL
					WHEN TGR.fecha_construccion LIKE '19000101' THEN NULL
					ELSE TGR.fecha_construccion 
				END AS FECHA_CONSTRUCCION,
				COALESCE(TGR.cod_tipo_perito, -1) AS TIPO_PERSONA_TASADOR,
				COALESCE(TGR.cedula_perito, '-1') AS ID_TASADOR,
				TGR.cod_tipo_empresa AS TIPO_PERSONA_EMPRESA_TASADORA,
				TGR.cedula_empresa AS ID_EMPRESA_TASADORA,
				1 AS CODIGO_EMPRESA
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident
			LEFT OUTER JOIN dbo.SICAD_REALES SR1
			ON SR1.ID_GARANTIA_REAL = TGR.cod_bien
			AND SR1.TIPO_BIEN_GARANTIA_REAL = COALESCE(TGR.cod_tipo_bien, 1)
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'  
			AND	SR1.ID_GARANTIA_REAL IS NULL
			AND SR1.TIPO_BIEN_GARANTIA_REAL IS NULL

		INSERT INTO dbo.SICAD_GAROPER (ID_OPERACION, CODIGO_EMPRESA, FECHA_PROCESO)
		SELECT  CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)) AS ID_OPERACION,
				1 AS CODIGO_EMPRESA,
				GETDATE() AS FECHA_PROCESO
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident
			LEFT OUTER JOIN dbo.SICAD_GAROPER SG1
			ON SG1.ID_OPERACION = (CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)))
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'
			AND SG1.ID_OPERACION IS NULL

	
		INSERT INTO dbo.SICAD_GAROPER_LISTA ( ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, 
											  INDICADOR_INSCRIPCION_GARANTIA, FECHA_PRESENTACION_REGISTRO_GARANTIA, PORCENTAJE_RESPONSABILIDAD_GARANTIA, 
											  VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION, FECHA_CONSTITUCION_GARANTIA, 
											  FECHA_VENCIMIENTO_GARANTIA, CODIGO_EMPRESA)
		SELECT  CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)) AS ID_OPERACION,
				2 AS TIPO_GARANTIA,
				TGR.cod_bien AS ID_GARANTIA,
				COALESCE(TGR.cod_tipo_mitigador, -1) AS TIPO_MITIGADOR,
				COALESCE(TGR.cod_tipo_documento_legal, -1) AS TIPO_DOCUMENTO_LEGAL,
				COALESCE(TGR.monto_mitigador, 0) AS MONTO_MITIGADOR,
				COALESCE(TGR.cod_inscripcion, -1) AS INDICADOR_INSCRIPCION_GARANTIA,
				COALESCE(TGR.fecha_presentacion, '19000101') AS FECHA_PRESENTACION_REGISTRO_GARANTIA,
				COALESCE(TGR.porcentaje_responsabilidad, 0)  AS PORCENTAJE_RESPONSABILIDAD_GARANTIA,
				COALESCE(TGR.monto_total_avaluo, 0) AS VALOR_NOMINAL_GARANTIA,
				1 AS TIPO_MONEDA_VALOR_NOMINAL_GARANTIA,
				COALESCE(TGR.Porcentaje_Aceptacion, 0) AS PORCENTAJE_ACEPTACION,
				COALESCE(TGR.fecha_constitucion, '19000101') AS FECHA_CONSTITUCION_GARANTIA,
				MAX(COALESCE(TGR.fecha_vencimiento, '19000101')) AS FECHA_VENCIMIENTO_GARANTIA,
				1 AS CODIGO_EMPRESA
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident
			LEFT OUTER JOIN dbo.SICAD_GAROPER_LISTA SGL
			ON SGL.ID_OPERACION = (CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)))
			AND SGL.ID_GARANTIA = TGR.cod_bien
			AND SGL.TIPO_GARANTIA = 2
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'
			AND SGL.ID_OPERACION IS NULL
			AND SGL.ID_GARANTIA IS NULL
			AND SGL.TIPO_GARANTIA IS NULL
		GROUP BY
			TGR.cod_oficina, 
			TGR.cod_moneda, 
			TGR.cod_producto, 
			TGR.operacion, 
			TGR.cod_bien,
			TGR.cod_tipo_mitigador, 
			TGR.cod_tipo_documento_legal, 
			TGR.monto_mitigador,
			TGR.fecha_presentacion, 
			TGR.cod_inscripcion, 
			TGR.fecha_constitucion, 
			TGR.porcentaje_responsabilidad,	
			TGR.Porcentaje_Aceptacion,	
			TGR.monto_total_avaluo


		INSERT INTO dbo.SICAD_REALES_POLIZA ( ID_GARANTIA_REAL, TIPO_POLIZA_GARANTIA_REAL, MONTO_POLIZA_GARANTIA_REAL, 
											  FECHA_VENCIMIENTO_POLIZA_GARANTIA_REAL, IND_COBERTURA_POLIZA, TIPO_PERSONA_BENEFICIARIO, 
											  ID_BENEFICIARIO, CODIGO_EMPRESA)
		SELECT	TGR.cod_bien AS ID_GARANTIA_REAL,
				TGR.Codigo_Tipo_Poliza_Sugef AS TIPO_POLIZA_GARANTIA_REAL,
				TGR.Monto_Poliza_Colonizado AS MONTO_POLIZA_GARANTIA_REAL,
				TGR.Fecha_Vencimiento_Poliza AS FECHA_VENCIMIENTO_POLIZA_GARANTIA_REAL,
				CASE
					WHEN TGR.Indicador_Coberturas_Obligatorias IS NULL THEN 'N'
					WHEN TGR.Indicador_Coberturas_Obligatorias = 'NO' THEN 'N'
					WHEN TGR.Indicador_Coberturas_Obligatorias = 'SI' THEN 'S'
					ELSE 'N'
				END AS IND_COBERTURA_POLIZA,
				2 AS TIPO_PERSONA_BENEFICIARIO,
				'4000000019' AS ID_BENEFICIARIO,
				1 AS CODIGO_EMPRESA
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident  
			LEFT OUTER JOIN dbo.SICAD_REALES_POLIZA SRP
			ON SRP.ID_GARANTIA_REAL = TGR.cod_bien
			AND SRP.TIPO_POLIZA_GARANTIA_REAL = TGR.Codigo_Tipo_Poliza_Sugef
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'
			AND COALESCE(TGR.Codigo_SAP, -1) > -1
			AND	SRP.ID_GARANTIA_REAL IS NULL
			AND SRP.TIPO_POLIZA_GARANTIA_REAL IS NULL


		INSERT INTO dbo.SICAD_GAROPER_GRAVAMEN ( ID_OPERACION, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, GRADO_GRAVAMENES, 
												 TIPO_PERSONA_ACREEDOR, ID_ACREEDOR, MONTO_GRADO_GRAVAMEN, TIPO_MONEDA_MONTO_GRADO_GRAVAMEN, 
												 CODIGO_EMPRESA)
		SELECT  CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)) AS ID_OPERACION,
				TGR.cod_bien AS ID_GARANTIA,
				COALESCE(TGR.cod_tipo_mitigador, -1) AS TIPO_MITIGADOR,
				COALESCE(TGR.cod_tipo_documento_legal, -1) TIPO_DOCUMENTO_LEGAL,
				COALESCE(TGR.cod_grado_gravamen, -1) GRADO_GRAVAMENES,
				TGR.cod_tipo_acreedor AS TIPO_PERSONA_ACREEDOR,
				TGR.cedula_acreedor AS ID_ACREEDOR,
				COALESCE(TGR.monto_total_avaluo, 0) AS MONTO_GRADO_GRAVAMEN,
				1 AS TIPO_MONEDA_MONTO_GRADO_GRAVAMEN,
				1 AS CODIGO_EMPRESA
		FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
			INNER JOIN dbo.GAR_DEUDOR GD1
			ON TGR.cedula_deudor = GD1.cedula_deudor
			INNER JOIN dbo.GAR_SICC_BSMPC MPC
			ON GD1.Identificacion_Sicc = MPC.bsmpc_sco_ident    
			LEFT OUTER JOIN dbo.SICAD_GAROPER_GRAVAMEN SGG
			ON SGG.ID_OPERACION = (CAST(TGR.cod_oficina AS VARCHAR(5)) + CAST(TGR.cod_moneda AS VARCHAR(5)) + CAST(TGR.operacion AS VARCHAR(20)))
			AND SGG.ID_GARANTIA = TGR.cod_bien
			AND SGG.TIPO_DOCUMENTO_LEGAL = COALESCE(TGR.cod_tipo_documento_legal, -1)
			AND SGG.GRADO_GRAVAMENES = COALESCE(TGR.cod_grado_gravamen, -1)
		WHERE	TGR.cod_usuario = @psCedula_Usuario
			AND TGR.cod_tipo_operacion = 2
			AND MPC.bsmpc_estado = 'A'
			AND SGG.ID_OPERACION IS NULL
			AND SGG.ID_GARANTIA IS NULL
			AND SGG.TIPO_DOCUMENTO_LEGAL IS NULL
			AND SGG.GRADO_GRAVAMENES IS NULL


		/*Se eliminan los registros de duplicados*/
		WITH GARANTIAS_REALES (ID_GARANTIA_REAL, TIPO_BIEN_GARANTIA_REAL, ID_BIEN, MONTO_ULTIMA_TASACION_TERRENO, MONTO_ULTIMA_TASACION_NO_TERRENO, 
							   FECHA_ULTIMA_TASACION_GARANTIA, MONTO_TASACION_ACTUALIZADA_TERRENO, MONTO_TASACION_ACTUALIZADA_NO_TERRENO, 
							   FECHA_ULTIMO_SEGUIMIENTO_GARANTIA, FECHA_CONSTRUCCION, TIPO_PERSONA_TASADOR, ID_TASADOR, TIPO_PERSONA_EMPRESA_TASADORA, 
							   ID_EMPRESA_TASADORA, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	ID_GARANTIA_REAL, TIPO_BIEN_GARANTIA_REAL, ID_BIEN, MONTO_ULTIMA_TASACION_TERRENO, MONTO_ULTIMA_TASACION_NO_TERRENO, 
					FECHA_ULTIMA_TASACION_GARANTIA, MONTO_TASACION_ACTUALIZADA_TERRENO, MONTO_TASACION_ACTUALIZADA_NO_TERRENO, 
					FECHA_ULTIMO_SEGUIMIENTO_GARANTIA, FECHA_CONSTRUCCION, TIPO_PERSONA_TASADOR, ID_TASADOR, TIPO_PERSONA_EMPRESA_TASADORA, 
					ID_EMPRESA_TASADORA, 
					ROW_NUMBER() OVER(PARTITION BY ID_GARANTIA_REAL, TIPO_BIEN_GARANTIA_REAL, ID_BIEN, MONTO_ULTIMA_TASACION_TERRENO, MONTO_ULTIMA_TASACION_NO_TERRENO, 
										FECHA_ULTIMA_TASACION_GARANTIA, MONTO_TASACION_ACTUALIZADA_TERRENO, MONTO_TASACION_ACTUALIZADA_NO_TERRENO, 
										FECHA_ULTIMO_SEGUIMIENTO_GARANTIA, FECHA_CONSTRUCCION, TIPO_PERSONA_TASADOR, ID_TASADOR, TIPO_PERSONA_EMPRESA_TASADORA, 
										ID_EMPRESA_TASADORA 
									ORDER BY ID_GARANTIA_REAL, TIPO_BIEN_GARANTIA_REAL, ID_BIEN, MONTO_ULTIMA_TASACION_TERRENO, MONTO_ULTIMA_TASACION_NO_TERRENO, 
										FECHA_ULTIMA_TASACION_GARANTIA, MONTO_TASACION_ACTUALIZADA_TERRENO, MONTO_TASACION_ACTUALIZADA_NO_TERRENO, 
										FECHA_ULTIMO_SEGUIMIENTO_GARANTIA, FECHA_CONSTRUCCION, TIPO_PERSONA_TASADOR, ID_TASADOR, TIPO_PERSONA_EMPRESA_TASADORA, 
										ID_EMPRESA_TASADORA) AS cantidadRegistrosDuplicados
			FROM	dbo.SICAD_REALES
		)
		DELETE
		FROM GARANTIAS_REALES
		WHERE cantidadRegistrosDuplicados > 1;


		WITH GAROPER (ID_OPERACION, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	ID_OPERACION, 
					ROW_NUMBER() OVER(PARTITION BY ID_OPERACION  ORDER BY ID_OPERACION) AS cantidadRegistrosDuplicados
			FROM	dbo.SICAD_GAROPER
		)
		DELETE
		FROM GAROPER
		WHERE cantidadRegistrosDuplicados > 1;

		WITH GAROPER_LISTA (ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, 
							VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION,
					ROW_NUMBER() OVER(PARTITION BY ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION  ORDER BY ID_OPERACION, TIPO_GARANTIA, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, MONTO_MITIGADOR, VALOR_NOMINAL_GARANTIA, TIPO_MONEDA_VALOR_NOMINAL_GARANTIA, PORCENTAJE_ACEPTACION) AS cantidadRegistrosDuplicados
			FROM	dbo.SICAD_GAROPER_LISTA
			WHERE	TIPO_GARANTIA = 2
		)
		DELETE
		FROM GAROPER_LISTA
		WHERE cantidadRegistrosDuplicados > 1;

		WITH POLIZAS_GARANTIAS_REALES (ID_GARANTIA_REAL, TIPO_POLIZA_GARANTIA_REAL, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	ID_GARANTIA_REAL, TIPO_POLIZA_GARANTIA_REAL, 
					ROW_NUMBER() OVER(PARTITION BY ID_GARANTIA_REAL, TIPO_POLIZA_GARANTIA_REAL ORDER BY ID_GARANTIA_REAL, TIPO_POLIZA_GARANTIA_REAL) AS cantidadRegistrosDuplicados
			FROM	dbo.SICAD_REALES_POLIZA
		)
		DELETE
		FROM POLIZAS_GARANTIAS_REALES
		WHERE cantidadRegistrosDuplicados > 1;

		WITH GRAVAMENES_GARANTIAS_REALES (ID_OPERACION, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, GRADO_GRAVAMENES, cantidadRegistrosDuplicados)
		AS
		(
			SELECT	ID_OPERACION, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, GRADO_GRAVAMENES, 
					ROW_NUMBER() OVER(PARTITION BY ID_OPERACION, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, GRADO_GRAVAMENES ORDER BY ID_OPERACION, ID_GARANTIA, TIPO_MITIGADOR, TIPO_DOCUMENTO_LEGAL, GRADO_GRAVAMENES) AS cantidadRegistrosDuplicados
			FROM	dbo.SICAD_GAROPER_GRAVAMEN
		)
		DELETE
		FROM GRAVAMENES_GARANTIAS_REALES
		WHERE cantidadRegistrosDuplicados > 1;

		--FIN RQ: 2016012710534870


	/***************************************************************************************************************************************************/


			/*Se seleccionan los datos de salida para el usuario que genera la información*/
			SELECT	TGR.cod_contabilidad AS CONTABILIDAD,
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
					COALESCE((CONVERT(VARCHAR(50), TGR.Porcentaje_Aceptacion)), '') AS PORCENTAJE_ACEPTACION, --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
					COALESCE((CONVERT(VARCHAR(100), TGR.Codigo_SAP)), '') AS CODIGO_SAP,
					COALESCE((CONVERT(VARCHAR(100), TGR.Monto_Poliza_Colonizado)), '') AS MONTO_POLIZA,
						COALESCE((CONVERT(VARCHAR(10), TGR.Fecha_Vencimiento_Poliza, 103)), '') AS FECHA_VENCIMIENTO_POLIZA,
					COALESCE((CONVERT(VARCHAR(5), TGR.Codigo_Tipo_Poliza_Sugef)), '') AS TIPO_POLIZA_SUGEF,
					TGR.Indicador_Poliza AS INDICADOR_POLIZA,
					--INICIO RQ: RQ_MANT_2015062410418218_00090
					COALESCE((CONVERT(VARCHAR(100), TGR.Porcentaje_Aceptacion_Terreno)), '') AS '%_ACEPTACION_TERRENO',
					COALESCE((CONVERT(VARCHAR(100), TGR.Porcentaje_Aceptacion_No_Terreno)), '') AS '%_ACEPTACION_NO_TERRENO',
					COALESCE((CONVERT(VARCHAR(100), TGR.Porcentaje_Aceptacion_Terreno_Calculado)), '') AS '%_ACEPTACION_TERRENO_CALCULADO',
					COALESCE((CONVERT(VARCHAR(100), TGR.Porcentaje_Aceptacion_No_Terreno_Calculado)), '') AS '%_ACEPTACION_NO_TERRENO_CALCULADO',
					COALESCE((CONVERT(VARCHAR(100), TGR.Indicador_Coberturas_Obligatorias)), '') AS COBERTURA_DE_BIEN,
					--FIN RQ: RQ_MANT_2015062410418218_00090	
					COALESCE((CONVERT(VARCHAR(50), TGR.porcentaje_responsabilidad)), '') AS PORCENTAJE_RESPONSABILIDAD	
			FROM	dbo.AUX_GARANTIAS_REALES_GRC TGR
				INNER JOIN dbo.GAR_SICC_BSMPC MPC
				ON TGR.cedula_deudor = CONVERT(VARCHAR(30), MPC.bsmpc_sco_ident)
				INNER JOIN dbo.GAR_DEUDOR GD1
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
				TGR.Porcentaje_Aceptacion,  --RQ_MANT_2015111010495738_00610: Se agrega este campo.
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
				TGR.Codigo_SAP,
				TGR.Monto_Poliza_Colonizado,
				TGR.Fecha_Vencimiento_Poliza,
				TGR.Codigo_Tipo_Poliza_Sugef,
				TGR.Indicador_Poliza,
				--INICIO RQ: RQ_MANT_2015062410418218_00090
				TGR.Porcentaje_Aceptacion_Terreno,
				TGR.Porcentaje_Aceptacion_No_Terreno,
				TGR.Porcentaje_Aceptacion_Terreno_Calculado,
				TGR.Porcentaje_Aceptacion_No_Terreno_Calculado,
				TGR.Indicador_Coberturas_Obligatorias,
				--FIN RQ: RQ_MANT_2015062410418218_00090
				TGR.porcentaje_responsabilidad --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			ORDER BY TGR.operacion
		END

	END TRY
	BEGIN CATCH
		
		DECLARE @vsMensaje_Error NVARCHAR(4000);
		DECLARE @viNumero_Error INT;
		DECLARE @viSeveridad_Error INT;
		DECLARE @viEstado_Error INT;
		
		SELECT @vsMensaje_Error = ERROR_MESSAGE(),
			   @viNumero_Error = ERROR_NUMBER(),
			   @viSeveridad_Error = ERROR_SEVERITY(),
			   @viEstado_Error = ERROR_STATE();

		RAISERROR (@vsMensaje_Error,
				   @viSeveridad_Error,
				   @viEstado_Error,
				   @viNumero_Error);
		
	END CATCH
END
