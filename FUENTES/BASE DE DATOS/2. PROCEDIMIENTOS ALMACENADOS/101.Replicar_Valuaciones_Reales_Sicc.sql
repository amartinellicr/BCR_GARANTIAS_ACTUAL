USE [GARANTIAS]
GO

ALTER PROCEDURE [dbo].[Replicar_Valuaciones_Reales_Sicc]
	@piIndicadorProceso		TINYINT,
	@psCodigoProceso		VARCHAR(20)	
AS
BEGIN
/******************************************************************
	<Nombre>Replicar_Valuaciones_Reales_Sicc</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Migra la información de las valuaciones de las garantías reales, del 
			     SICC a la base de datos GARANTIAS. 
	</Descripción>
	<Entradas>
			@piIndicadorProceso		= Indica la parte del proceso que será ejecutada.
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
			<Fecha>29/06/2015</Fecha>
			<Descripción>
				Se ajusta el subproceso #1, #4, #5, #6, #11, #12 y #13. El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>PBI 13977: Mantenimientos Garantías Reales</Requerimiento>
			<Fecha>Febrero - 2017</Fecha>
			<Descripción>Se ajusta la forma de seleccionar las garantías prendarias de acuerdo al código de la clase de garantía.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>PBI 26539: Mantenimientos Garantías Reales</Requerimiento>
			<Fecha>Febrero - 2017</Fecha>
			<Descripción>
					Se realiza el ajuste de asignar el valor 0 (cero) a los montos del avalúo, según el tipo de bien que tengan asignado.
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

	BEGIN TRY

			DECLARE	 @vdFecha_Actual_Sin_Hora DATETIME, -- Fecha actual sin hora, utilizada en las comparaciones de las validaciones.
				@viFecha_Actual_Entera INT, --Corresponde al a fecha actual en formato numérico.
				@vsDescripcion_Error VARCHAR(1000), --Descripción del error capturado.
				@vsDescripcion_Bitacora_Errores VARCHAR(5000), --Descripción del error que será guardado en la bitácora de errores.
				@viContador	TINYINT

			--Se inicializan las variables
			SET	@vdFecha_Actual_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	
			SET @viFecha_Actual_Entera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
		----------------------------------------------------------------------
		--CARGA VALUACIONES DE GARANTIAS REALES
		----------------------------------------------------------------------
		--Se asigna la fecha del avalúo más reciente para hipotecas comunes
		IF(@piIndicadorProceso = 1)
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
				WHERE	@viContador = 19
					OR ((@viContador >= 10)	AND (@viContador <= 17))
					
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
				prmgt_pcoclagar TINYINT,
				prmgt_pnu_part  TINYINT,
				prmgt_pnuidegar DECIMAL(12,0),
				prmgt_pfeavaing INT,
				prmgt_pco_mongar TINYINT,
				prmgt_pmoavaing DECIMAL(14, 2),
				Indicador_Fecha_Mayor BIT,
				Fecha_Valuacion DATETIME,
				Monto_Total_Avaluo DECIMAL(14, 2)
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
					
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT	MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
					
			INSERT	INTO dbo.AUX_GAR_HIPOTECAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT	MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0
				
			DELETE FROM dbo.AUX_GAR_HIPOTECAS_SICC 
			WHERE  Fecha_Valuacion = '19000101' 	
				
			CREATE INDEX AUX_GAR_HIPOTECAS_SICC_IX_01 ON dbo.AUX_GAR_HIPOTECAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) ON [PRIMARY]


			/*TABLA AUXILIAR DE GARANTIAS HIPOTECARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_HIPOTECAS_ALF_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_HIPOTECAS_ALF_SICC
	

			/*Esta tabla almacenará las garantías hipotecarias alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_HIPOTECAS_ALF_SICC 
			(	
				prmgt_pcoclagar TINYINT,
				prmgt_pnu_part  TINYINT,
				prmgt_pnuidegar DECIMAL(12,0),
				prmgt_pnuide_alf CHAR(12),
				prmgt_pfeavaing	INT,
				prmgt_pco_mongar TINYINT,
				prmgt_pmoavaing DECIMAL(14, 2),
				Indicador_Fecha_Mayor BIT,
				Fecha_Valuacion DATETIME,
				Monto_Total_Avaluo DECIMAL(14, 2)
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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

			
			DELETE FROM  dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			WHERE  Fecha_Valuacion = '19000101'

			CREATE INDEX AUX_GAR_HIPOTECAS_ALF_SICC_IX_01 ON dbo.AUX_GAR_HIPOTECAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf) ON [PRIMARY]


			/*TABLA AUXILIAR DE CEDULAS HIPOTECARIAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_CEDULAS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_CEDULAS_SICC
	
			/*Esta tabla almacenará las garantías hipotecarias no alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_CEDULAS_SICC 
			(	
				prmgt_pcoclagar TINYINT,
				prmgt_pnu_part  TINYINT,
				prmgt_pnuidegar DECIMAL(12,0),
				prmgt_pfeavaing INT,
				prmgt_pco_mongar TINYINT,
				prmgt_pmoavaing DECIMAL(14, 2),
				prmgt_pco_grado TINYINT,
				Indicador_Fecha_Mayor BIT,
				Fecha_Valuacion DATETIME,
				Monto_Total_Avaluo DECIMAL(14, 2)
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_OPERACIONES_SICC MOC
				ON MOC.prmoc_pco_ofici = MG1.prmgt_pco_ofici
				AND MOC.prmoc_pco_moned = MG1.prmgt_pco_moned
				AND MOC.prmoc_pco_produ = MG1.prmgt_pco_produ
				AND MOC.prmoc_pnu_oper = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_CONTRATOS_VIGENTES_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
					0 AS Monto_Total_Avaluo
			FROM	dbo.GAR_SICC_PRMGT MG1
				INNER JOIN dbo.AUX_GIROS_ACTIVOS_SICC MCA
				ON MCA.prmca_pco_ofici = MG1.prmgt_pco_ofici
				AND MCA.prmca_pco_moned = MG1.prmgt_pco_moned
				AND MCA.prmca_pco_produc = MG1.prmgt_pco_produ
				AND MCA.prmca_pnu_contr = MG1.prmgt_pnu_oper																
			WHERE	MG1.prmgt_estado = 'A'
				AND MG1.prmgt_pcoclagar = 18
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0		
		
		
			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND MG1.prmgt_pcotengar = 1
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND MG1.prmgt_pcotengar = 1
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

			INSERT	INTO dbo.AUX_GAR_CEDULAS_SICC(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnu_part,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					MG1.prmgt_pco_grado,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
				AND MG1.prmgt_pcotengar = 1
				AND ISNULL(MG1.prmgt_pfeavaing, 0) > 0
				AND CGV.Ind_Clase_Alfanumerica = 0

			DELETE FROM dbo.AUX_GAR_CEDULAS_SICC
			WHERE Fecha_Valuacion = '19000101'

			CREATE INDEX AUX_GAR_CEDULAS_SICC_IX_01 ON dbo.AUX_GAR_CEDULAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar) ON [PRIMARY]



			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS NO ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_PRENDAS_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_PRENDAS_SICC

			/*Esta tabla almacenará las garantías prendarias no alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_PRENDAS_SICC 
			(	
				prmgt_pcoclagar TINYINT,
				prmgt_pnuidegar DECIMAL(12,0),
				prmgt_pfeavaing INT,
				prmgt_pco_mongar TINYINT,
				prmgt_pmoavaing DECIMAL(14, 2),
				Indicador_Fecha_Mayor BIT,
				Fecha_Valuacion DATETIME,
				Monto_Total_Avaluo DECIMAL(14, 2)
			) ON [PRIMARY]
		 
			--INICIO PBI 13977: Ajuste al 08/02/2017	
			/*Se obtienen las prendas no alfanuméricas relacionadas a operaciones y contratos*/
		
			INSERT	INTO dbo.AUX_GAR_PRENDAS_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
			SELECT	MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
			SELECT	MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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

			--FIN PBI 13977: Ajuste al 08/02/2017

			DELETE FROM dbo.AUX_GAR_PRENDAS_SICC
			WHERE Fecha_Valuacion = '19000101'
					
			CREATE INDEX AUX_GAR_PRENDAS_SICC_IX_01 ON dbo.AUX_GAR_PRENDAS_SICC (prmgt_pcoclagar, prmgt_pnuidegar) ON [PRIMARY]

			
			/*TABLA AUXILIAR DE GARANTIAS PRENDARIAS ALFANUMERICAS PARA ESTE ARCHIVO*/
			IF OBJECT_ID('dbo.AUX_GAR_PRENDAS_ALF_SICC') IS NOT NULL
				DROP TABLE dbo.AUX_GAR_PRENDAS_ALF_SICC

			/*Esta tabla almacenará las garantías prendarias alfanuméricas del SICC que estén activas*/
			CREATE TABLE dbo.AUX_GAR_PRENDAS_ALF_SICC 
			(	
				prmgt_pcoclagar TINYINT,
				prmgt_pnuidegar DECIMAL(12,0),
				prmgt_pnuide_alf CHAR(12),
				prmgt_pfeavaing INT,
				prmgt_pco_mongar TINYINT,
				prmgt_pmoavaing DECIMAL(14, 2),
				Indicador_Fecha_Mayor BIT,
				Fecha_Valuacion DATETIME,
				Monto_Total_Avaluo DECIMAL(14, 2)
			) ON [PRIMARY]
		 
			--INICIO PBI 13977: Ajuste al 08/02/2017
			/*Se obtienen las prendas alfanuméricas relacionadas a operaciones y contratos*/
			INSERT	INTO dbo.AUX_GAR_PRENDAS_ALF_SICC(prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo)
			SELECT  MG1.prmgt_pcoclagar,
					MG1.prmgt_pnuidegar,
					MG1.prmgt_pnuide_alf,
					MG1.prmgt_pfeavaing,
					MG1.prmgt_pco_mongar,
					MG1.prmgt_pmoavaing,
					0 AS Indicador_Fecha_Mayor,
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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
					CASE WHEN ISDATE(CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) = 0 THEN '19000101'
					ELSE CONVERT(DATETIME,CONVERT(CHAR(8), MG1.prmgt_pfeavaing)) END AS Fecha_Valuacion,
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

			--FIN PBI 13977: Ajuste al 08/02/2017

			DELETE FROM  dbo.AUX_GAR_PRENDAS_ALF_SICC
			WHERE Fecha_Valuacion = '19000101'

			CREATE INDEX AUX_GAR_PRENDAS_ALF_SICC_IX_01 ON dbo.AUX_GAR_PRENDAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf) ON [PRIMARY]


			/*SE OBTIENE LA FECHA MÁS RECIENTE POR CADA GARANTÍA*/

			;WITH HIPOTECAS_COMUNES AS  (
				SELECT prmgt_pfeavaing, Monto_Total_Avaluo, prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, 
				   RANK() OVER( PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar ORDER BY prmgt_pmoavaing, prmgt_pfeavaing DESC) AS Rnk
				FROM dbo.AUX_GAR_HIPOTECAS_SICC
			)
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1,
					Monto_Total_Avaluo = HC1.Monto_Total_Avaluo
			FROM	dbo.AUX_GAR_HIPOTECAS_SICC TMP
				INNER JOIN HIPOTECAS_COMUNES HC1
				ON HC1.prmgt_pcoclagar = TMP.prmgt_pcoclagar
				AND HC1.prmgt_pnu_part = TMP.prmgt_pnu_part
				AND HC1.prmgt_pnuidegar = TMP.prmgt_pnuidegar
				AND HC1.prmgt_pfeavaing = TMP.prmgt_pfeavaing


			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_SICC
			WHERE	prmgt_pfeavaing = 19000101
			
			;WITH HIPOTECAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, cantidadRegistrosDuplicados)
			AS
			(
				SELECT	prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, 
						ROW_NUMBER() OVER(PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing  ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo) AS cantidadRegistrosDuplicados
				FROM	dbo.AUX_GAR_HIPOTECAS_SICC
			)
			DELETE
			FROM HIPOTECAS_SICC
			WHERE cantidadRegistrosDuplicados > 1;

			;WITH HIPOTECAS_COMUNES_ALF AS  (
				SELECT prmgt_pfeavaing, Monto_Total_Avaluo, prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf,
				   RANK() OVER( PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf ORDER BY prmgt_pmoavaing, prmgt_pfeavaing DESC) AS Rnk
				FROM dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			)
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1,
					Monto_Total_Avaluo = HC1.Monto_Total_Avaluo
			FROM	dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
				INNER JOIN HIPOTECAS_COMUNES_ALF HC1
				ON HC1.prmgt_pcoclagar = TMP.prmgt_pcoclagar
				AND HC1.prmgt_pnu_part = TMP.prmgt_pnu_part
				AND HC1.prmgt_pnuidegar = TMP.prmgt_pnuidegar
				AND HC1.prmgt_pnuide_alf = TMP.prmgt_pnuide_alf
				AND HC1.prmgt_pfeavaing = TMP.prmgt_pfeavaing

			

			
			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			WHERE	prmgt_pfeavaing = 19000101

			;WITH HIPOTECAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, cantidadRegistrosDuplicados)
			AS
			(
				SELECT	prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, 
						ROW_NUMBER() OVER(PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing  ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo) AS cantidadRegistrosDuplicados
				FROM	dbo.AUX_GAR_HIPOTECAS_ALF_SICC
			)
			DELETE
			FROM HIPOTECAS_ALF_SICC
			WHERE cantidadRegistrosDuplicados > 1;


			;WITH CEDULAS_HIPOTECARIAS AS  (
				SELECT prmgt_pfeavaing, Monto_Total_Avaluo, prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, 
				   RANK() OVER( PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar ORDER BY prmgt_pmoavaing, prmgt_pfeavaing DESC) AS Rnk
				FROM dbo.AUX_GAR_CEDULAS_SICC
			)
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1,
					Monto_Total_Avaluo = CH1.Monto_Total_Avaluo
			FROM	dbo.AUX_GAR_CEDULAS_SICC TMP
				INNER JOIN CEDULAS_HIPOTECARIAS CH1
				ON CH1.prmgt_pcoclagar = TMP.prmgt_pcoclagar
				AND CH1.prmgt_pnu_part = TMP.prmgt_pnu_part
				AND CH1.prmgt_pnuidegar = TMP.prmgt_pnuidegar
				AND CH1.prmgt_pfeavaing = TMP.prmgt_pfeavaing
			

			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_CEDULAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_CEDULAS_SICC
			WHERE	prmgt_pfeavaing = 19000101

			;WITH CEDULAS_SICC (prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, cantidadRegistrosDuplicados)
			AS
			(
				SELECT	prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, 
						ROW_NUMBER() OVER(PARTITION BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing  ORDER BY prmgt_pcoclagar, prmgt_pnu_part, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, prmgt_pco_grado, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo) AS cantidadRegistrosDuplicados
				FROM	dbo.AUX_GAR_CEDULAS_SICC
			)
			DELETE
			FROM CEDULAS_SICC
			WHERE cantidadRegistrosDuplicados > 1;


			;WITH PRENDAS AS  (
				SELECT prmgt_pfeavaing, Monto_Total_Avaluo, prmgt_pcoclagar, prmgt_pnuidegar, 
				   RANK() OVER( PARTITION BY prmgt_pcoclagar, prmgt_pnuidegar ORDER BY prmgt_pmoavaing, prmgt_pfeavaing DESC) AS Rnk
				FROM dbo.AUX_GAR_PRENDAS_SICC
			)
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1,
					Monto_Total_Avaluo = PRD.Monto_Total_Avaluo
			FROM	dbo.AUX_GAR_PRENDAS_SICC TMP
				INNER JOIN PRENDAS PRD
				ON PRD.prmgt_pcoclagar = TMP.prmgt_pcoclagar
				AND PRD.prmgt_pnuidegar = TMP.prmgt_pnuidegar
				AND PRD.prmgt_pfeavaing = TMP.prmgt_pfeavaing


			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_SICC
			WHERE	prmgt_pfeavaing = 19000101

			;WITH PRENDAS_SICC (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, cantidadRegistrosDuplicados)
			AS
			(
				SELECT	prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, 
						ROW_NUMBER() OVER(PARTITION BY prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing  ORDER BY prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo) AS cantidadRegistrosDuplicados
				FROM	dbo.AUX_GAR_PRENDAS_SICC
			)
			DELETE
			FROM PRENDAS_SICC
			WHERE cantidadRegistrosDuplicados > 1;


			;WITH PRENDAS_ALF AS  (
				SELECT prmgt_pfeavaing, Monto_Total_Avaluo, prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, 
				   RANK() OVER( PARTITION BY prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf ORDER BY prmgt_pmoavaing, prmgt_pfeavaing DESC) AS Rnk
				FROM dbo.AUX_GAR_PRENDAS_ALF_SICC
			)
			UPDATE	TMP
			SET		Indicador_Fecha_Mayor = 1,
					Monto_Total_Avaluo = PRD.Monto_Total_Avaluo
			FROM	dbo.AUX_GAR_PRENDAS_ALF_SICC TMP
				INNER JOIN PRENDAS_ALF PRD
				ON PRD.prmgt_pcoclagar = TMP.prmgt_pcoclagar
				AND PRD.prmgt_pnuidegar = TMP.prmgt_pnuidegar
				AND PRD.prmgt_pnuide_alf = TMP.prmgt_pnuide_alf
				AND PRD.prmgt_pfeavaing = TMP.prmgt_pfeavaing


			/*Se eliminan los registros cuya fecha de valuación no es la más reciente*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_ALF_SICC
			WHERE	Indicador_Fecha_Mayor = 0
		
			/*Se eliminan los registros que no poseen una fecha de valuación*/
			DELETE	FROM dbo.AUX_GAR_PRENDAS_ALF_SICC
			WHERE	prmgt_pfeavaing = 19000101

			WITH PRENDAS_ALF_SICC (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, cantidadRegistrosDuplicados)
			AS
			(
				SELECT	prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo, 
						ROW_NUMBER() OVER(PARTITION BY prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing  ORDER BY prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pfeavaing, prmgt_pco_mongar, prmgt_pmoavaing, Indicador_Fecha_Mayor, Fecha_Valuacion, Monto_Total_Avaluo) AS cantidadRegistrosDuplicados
				FROM	dbo.AUX_GAR_PRENDAS_ALF_SICC
			)
			DELETE
			FROM PRENDAS_ALF_SICC
			WHERE cantidadRegistrosDuplicados > 1;
	
			--Se insertan las valuaciones de hipotecas comunes con clase distinta a 11
			BEGIN TRANSACTION TRA_Ins_Vrhc
				BEGIN TRY

					INSERT INTO dbo.GAR_VALUACIONES_REALES
					(
						cod_garantia_real, 
						fecha_valuacion, 
						monto_total_avaluo,
						Fecha_Replica,
						Tipo_Moneda_Tasacion
					)
					SELECT	 
						GGR.cod_garantia_real, 
						MGT.Fecha_Valuacion AS fecha_valuacion, 
						MGT.Monto_Total_Avaluo AS monto_total_avaluo,
						GETDATE(),
						MGT.prmgt_pco_mongar
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.AUX_GAR_HIPOTECAS_SICC MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc 
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
						LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
						ON GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
					WHERE CGV.Ind_Clase_Alfanumerica = 0
						AND GVR.cod_garantia_real IS NULL
					GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar
	
				COMMIT TRANSACTION TRA_Ins_Vrhc

			END TRY
			BEGIN CATCH
				--IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION TRA_Ins_Vrhc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las hipotecas comunes (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
			
				
		
		
			--Se insertan las valuaciones de hipotecas comunes con clase igual a 11
			BEGIN TRANSACTION TRA_Ins_Vrhc11
				BEGIN TRY

					INSERT INTO dbo.GAR_VALUACIONES_REALES
					(
						cod_garantia_real, 
						fecha_valuacion, 
						monto_total_avaluo,
						Fecha_Replica,
						Tipo_Moneda_Tasacion
					)
					SELECT	 
						GGR.cod_garantia_real, 
						MGT.Fecha_Valuacion AS fecha_valuacion, 
						MGT.Monto_Total_Avaluo AS monto_total_avaluo,
						GETDATE(),
						MGT.prmgt_pco_mongar
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.AUX_GAR_HIPOTECAS_ALF_SICC MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND ISNULL(MGT.prmgt_pnuidegar, 0) = ISNULL(GGR.Identificacion_Sicc, 0)
						AND ISNULL(MGT.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '') 
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
						LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
						ON GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
					WHERE CGV.Ind_Clase_Alfanumerica = 1
						AND GVR.cod_garantia_real IS NULL
					GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar

					COMMIT TRANSACTION TRA_Ins_Vrhc11
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Ins_Vrhc11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las hipotecas comunes (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía 18
		IF(@piIndicadorProceso = 2)
		BEGIN
			BEGIN TRANSACTION TRA_Ins_Vrch18
				BEGIN TRY

					INSERT INTO dbo.GAR_VALUACIONES_REALES
					(
						cod_garantia_real, 
						fecha_valuacion, 
						monto_total_avaluo,
						Fecha_Replica,
						Tipo_Moneda_Tasacion
					)
					SELECT	 
						GGR.cod_garantia_real, 
						MGT.Fecha_Valuacion AS fecha_valuacion, 
						MGT.Monto_Total_Avaluo AS monto_total_avaluo,
						GETDATE(),
						MGT.prmgt_pco_mongar
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.AUX_GAR_CEDULAS_SICC MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
						LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
						ON GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
					WHERE GGR.cod_clase_garantia = 18
						AND CGV.Ind_Clase_Alfanumerica = 0
						AND GVR.cod_garantia_real IS NULL
					GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar

					COMMIT TRANSACTION TRA_Ins_Vrch18
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Ins_Vrch18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las cédulas hipotecarias con clase 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se asigna la fecha del avalúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
		IF(@piIndicadorProceso = 3)
		BEGIN
			BEGIN TRANSACTION TRA_Ins_Vrch
				BEGIN TRY

					INSERT INTO dbo.GAR_VALUACIONES_REALES
					(
						cod_garantia_real, 
						fecha_valuacion, 
						monto_total_avaluo,
						Fecha_Replica,
						Tipo_Moneda_Tasacion
					)
					SELECT	 
						GGR.cod_garantia_real, 
						MGT.Fecha_Valuacion AS fecha_valuacion, 
						MGT.Monto_Total_Avaluo AS monto_total_avaluo,
						GETDATE(),
						MGT.prmgt_pco_mongar
					FROM	dbo.GAR_GARANTIA_REAL GGR
						INNER JOIN dbo.AUX_GAR_CEDULAS_SICC MGT
						ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
						LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
						ON GVR.cod_garantia_real = GGR.cod_garantia_real
						AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
					WHERE GGR.cod_clase_garantia > 18
						AND CGV.Ind_Clase_Alfanumerica = 0
						AND GVR.cod_garantia_real IS NULL
					GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar

					COMMIT TRANSACTION TRA_Ins_Vrch
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Ins_Vrch

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las cédulas hipotecarias con clase diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se asigna la fecha del avalúo más reciente para prendas
		IF(@piIndicadorProceso = 4)
			BEGIN
	
				--Se insertan las valuaciones de prendas con clase distinta a 38 o 43
				BEGIN TRANSACTION TRA_Ins_Vrp
					BEGIN TRY
	
						INSERT INTO dbo.GAR_VALUACIONES_REALES
						(
							cod_garantia_real, 
							fecha_valuacion, 
							monto_total_avaluo,
							Fecha_Replica,
							Tipo_Moneda_Tasacion
						)
						SELECT	 
							GGR.cod_garantia_real, 
							MGT.Fecha_Valuacion AS fecha_valuacion, 
							MGT.Monto_Total_Avaluo AS monto_total_avaluo,
							GETDATE(),
							MGT.prmgt_pco_mongar
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN dbo.AUX_GAR_PRENDAS_SICC MGT
							ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
							AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
							INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
							ON 	CGV.Tipo_Garantia_Real = 3
							AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
							LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
							ON GVR.cod_garantia_real = GGR.cod_garantia_real
							AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
						WHERE CGV.Ind_Clase_Alfanumerica = 0
							AND GVR.cod_garantia_real IS NULL
						GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar

						COMMIT TRANSACTION TRA_Ins_Vrp
	
				END TRY
				BEGIN CATCH
					
					ROLLBACK TRANSACTION TRA_Ins_Vrp

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las prendas (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
		
			
			
				--Se insertan las valuaciones de prendas con clase distinta a 38 o 43
				BEGIN TRANSACTION TRA_Ins_Vrp3843
					BEGIN TRY
	
						INSERT INTO dbo.GAR_VALUACIONES_REALES
						(
							cod_garantia_real, 
							fecha_valuacion, 
							monto_total_avaluo,
							Fecha_Replica,
							Tipo_Moneda_Tasacion
						)
						SELECT	 
							GGR.cod_garantia_real, 
							MGT.Fecha_Valuacion AS fecha_valuacion, 
							MGT.Monto_Total_Avaluo AS monto_total_avaluo,
							GETDATE(),
							MGT.prmgt_pco_mongar
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN dbo.AUX_GAR_PRENDAS_ALF_SICC MGT
							ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
							AND ISNULL(MGT.prmgt_pnuidegar, 0) = ISNULL(GGR.Identificacion_Sicc, 0)
							AND ISNULL(MGT.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '')
							INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
							ON 	CGV.Tipo_Garantia_Real = 3
							AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
							LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
							ON GVR.cod_garantia_real = GGR.cod_garantia_real
							AND GVR.fecha_valuacion = MGT.Fecha_Valuacion
						WHERE CGV.Ind_Clase_Alfanumerica = 1
							AND GVR.cod_garantia_real IS NULL
						GROUP BY GGR.cod_garantia_real, MGT.Fecha_Valuacion, MGT.Monto_Total_Avaluo, MGT.prmgt_pco_mongar
	
						COMMIT TRANSACTION TRA_Ins_Vrp3843
				END TRY
				BEGIN CATCH
					
					ROLLBACK TRANSACTION TRA_Ins_Vrp3843

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al migrar los avalúos de las prendas (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH
		
			END	

		--Se actualiza el campo de la fecha de valuación registrada en el SICC, en la tabla de valuaciones.
		--Si la fecha de valuación del SICC es 01/01/1900 implica que el dato almacenado en el Maestro de Garantías (tabla PRMGT) no corresponde a una fecha.
		--Si la fecha de valuación dle SICC es igual a NULL es porque la garantía nunca fue encontrada en el Maestro de Garantías (tabla PRMGT).

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
		IF(@piIndicadorProceso = 5)
		BEGIN

			--Actualización del dato para hipotecas comunes con clase distinta a 11
			BEGIN TRANSACTION TRA_Act_Fvhcop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion 	= GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_operacion						
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = GO1.cod_producto
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 0

					COMMIT TRANSACTION TRA_Act_Fvhcop
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase distinta a 11) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
		
		
	
			--Actualización del dato para hipotecas comunes con clase igual a 11
			BEGIN TRANSACTION TRA_Act_Fvhcop11
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
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
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND ISNULL(MGT.prmgt_pnuidegar, 0) = ISNULL(GGR.Identificacion_Sicc, 0)
						AND ISNULL(MGT.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 1

					COMMIT TRANSACTION TRA_Act_Fvhcop11
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcop11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para hipotecas comunes
		IF(@piIndicadorProceso = 6)
		BEGIN

			--Actualización del dato para hipotecas comunes con clase distinta a 11
			BEGIN TRANSACTION TRA_Act_Fvhcc
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND CGV.Ind_Clase_Alfanumerica = 0

				COMMIT TRANSACTION TRA_Act_Fvhcc

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase distinta a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
		
		
			--Actualización del dato para hipotecas comunes con clase igual a 11
			BEGIN TRANSACTION TRA_Act_Fvhcc11
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND MGT.prmgt_pnuidegar > 0
						AND LEN(MGT.prmgt_pnuide_alf) > 0
						AND CGV.Ind_Clase_Alfanumerica = 1

					COMMIT TRANSACTION TRA_Act_Fvhcc11

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcc11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH

			BEGIN TRANSACTION TRA_Act_Fvhcc11_1
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND ISNULL(MGT.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND MGT.prmgt_pnuidegar = 0
						AND LEN(MGT.prmgt_pnuide_alf) = 0
						AND CGV.Ind_Clase_Alfanumerica = 1

					COMMIT TRANSACTION TRA_Act_Fvhcc11_1

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcc11_1

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH


			BEGIN TRANSACTION TRA_Act_Fvhcc11_2
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND ISNULL(MGT.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND MGT.prmgt_pnuidegar > 0
						AND LEN(MGT.prmgt_pnuide_alf) = 0
						AND CGV.Ind_Clase_Alfanumerica = 1

					COMMIT TRANSACTION TRA_Act_Fvhcc11_2

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcc11_2

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH


			BEGIN TRANSACTION TRA_Act_Fvhcc11_3
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND MGT.prmgt_pnuidegar = 0
						AND LEN(MGT.prmgt_pnuide_alf) > 0
						AND CGV.Ind_Clase_Alfanumerica = 1

					COMMIT TRANSACTION TRA_Act_Fvhcc11_3

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvhcc11_3

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada hipoteca común (con clase igual a 11) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
		IF(@piIndicadorProceso = 7)
		BEGIN
			BEGIN TRANSACTION TRA_Act_Fvch18op
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_operacion						
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = GO1.cod_producto
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia = 18	
						AND GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 0
					
					COMMIT TRANSACTION TRA_Act_Fvch18op
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvch18op

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase 18, asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
		IF(@piIndicadorProceso = 8)
		BEGIN
			BEGIN TRANSACTION TRA_Act_Fvch18c
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia = 18	
						AND GO1.num_operacion IS NULL
						AND CGV.Ind_Clase_Alfanumerica = 0
					
					COMMIT TRANSACTION TRA_Act_Fvch18c

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvch18c

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase 18, asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
	
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
		IF(@piIndicadorProceso = 9)
		BEGIN
			BEGIN TRANSACTION TRA_Act_Fvchop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_operacion						
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = GO1.cod_producto
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
						AND MGT.prmgt_pcotengar = 1
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia > 18	
						AND GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 0

					COMMIT TRANSACTION TRA_Act_Fvchop
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvchop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cédula hipotecaria, con clase diferente a 18, asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para cédulas hipotecarias
		IF(@piIndicadorProceso = 10)
		BEGIN
			BEGIN TRANSACTION TRA_Act_Fvchc
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnu_part = GGR.cod_partido
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND CONVERT(VARCHAR(2), MGT.prmgt_pco_grado) = GGR.cod_grado
						AND MGT.prmgt_pcotengar = 1
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia > 18	
						AND GO1.num_operacion IS NULL
						AND CGV.Ind_Clase_Alfanumerica = 0

					COMMIT TRANSACTION TRA_Act_Fvchc
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvchc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada cádula hipotecaria, con clase diferente a 18, asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y esa operación dentro del Maestro de Garantías del SICC, esto para prendas
		IF(@piIndicadorProceso = 11)
		BEGIN
	
			--Actualización del dato para prendas con clase distinta a 38 o 43
			BEGIN TRANSACTION TRA_Act_Fvpop
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_operacion						
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = GO1.cod_producto
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 0

					COMMIT TRANSACTION TRA_Act_Fvpop

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvpop

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase distinta a 38 o 43) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		
		
			--Actualización del dato para prendas con clase igual a 38 o 43
			BEGIN TRANSACTION TRA_Act_Fvpop3843
				BEGIN TRY

					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
							GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_operacion						
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ = GO1.cod_producto
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_contrato = 0
						AND CGV.Ind_Clase_Alfanumerica = 1			
					
					COMMIT TRANSACTION TRA_Act_Fvpop3843

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvpop3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase igual a 38 o 43) asociada a operaciones. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		END	

		--Se actualiza la fecha de valuación SICC con el dato almacenado para esa garantía y ese contrato dentro del Maestro de Garantías del SICC, esto para prendas
		IF(@piIndicadorProceso = 12)
		BEGIN
	
			--Actualización del dato para prendas con clase diferente a 38 o 43
			BEGIN TRANSACTION TRA_Act_Fvpc
				BEGIN TRY
	
					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
						GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ	= 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND MGT.prmgt_estado = 'A'
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND CGV.Ind_Clase_Alfanumerica = 0
					
					COMMIT TRANSACTION TRA_Act_Fvpc
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvpc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase diferente a 38 o 43) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
			
			
			--Actualización del dato para prendas con clase igual a 38 o 43
			BEGIN TRANSACTION TRA_Act_Fvpc3843
				BEGIN TRY
	
					UPDATE	GRO
					SET		GRO.Fecha_Valuacion_SICC =	CASE 
															WHEN MGT.prmgt_pfeavaing = 0 THEN '19000101' 
															WHEN ISDATE(CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MGT.prmgt_pfeavaing,103)
															ELSE '19000101'
														END,
						GRO.Fecha_Replica = GETDATE()
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
						INNER JOIN	dbo.GAR_GARANTIA_REAL GGR 
						ON GGR.cod_garantia_real = GRO.cod_garantia_real
						INNER JOIN dbo.GAR_OPERACION GO1 
						ON GO1.cod_operacion = GRO.cod_operacion
						INNER JOIN dbo.GAR_SICC_PRMGT MGT 
						ON MGT.prmgt_pnu_oper = GO1.num_contrato
						AND MGT.prmgt_pco_ofici = GO1.cod_oficina
						AND MGT.prmgt_pco_moned = GO1.cod_moneda
						AND MGT.prmgt_pco_produ	= 10
						AND MGT.prmgt_pco_conta = GO1.cod_contabilidad
						AND COALESCE(MGT.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
						AND MGT.prmgt_estado = 'A'
						AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GO1.num_operacion IS NULL
						AND COALESCE(MGT.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND CGV.Ind_Clase_Alfanumerica = 1			

					COMMIT TRANSACTION TRA_Act_Fvpc3843
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Fvpc3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la fecha de valuación del SICC para una determinada prenda (con clase igual a 38 o 43) asociada a contratos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				
		END	

		--Se inicializan todos los registros a 0 (cero)
		IF(@piIndicadorProceso = 13)
		BEGIN
	
			BEGIN TRANSACTION TRA_Act_Avaluos
				BEGIN TRY
	
					UPDATE	dbo.GAR_VALUACIONES_REALES
					SET		Indicador_Tipo_Registro = 0
					
					COMMIT TRANSACTION TRA_Act_Avaluos
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avaluos

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a cero, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
			

	
			--Se obtienen los avalúos más recientes
			BEGIN TRANSACTION TRA_Act_Avalrec
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.Indicador_Tipo_Registro = 2
					FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN  (SELECT		cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
								 FROM		dbo.GAR_VALUACIONES_REALES
								 GROUP		BY cod_garantia_real) GV2
					ON	GV2.cod_garantia_real = GV1.cod_garantia_real
					AND GV2.fecha_valuacion	= GV1.fecha_valuacion

					COMMIT TRANSACTION TRA_Act_Avaluos
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avaluos

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a dos, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH


		
			--Se obtienen los penúltimos avalúos
			BEGIN TRANSACTION TRA_Act_Avalpenul
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.Indicador_Tipo_Registro = 3
					FROM	dbo.GAR_VALUACIONES_REALES GV1
					INNER JOIN (SELECT	cod_garantia_real, fecha_valuacion = MAX(fecha_valuacion)
								FROM	dbo.GAR_VALUACIONES_REALES
								WHERE	Indicador_Tipo_Registro = 0
								GROUP	BY cod_garantia_real) GV2
					ON	GV2.cod_garantia_real = GV1.cod_garantia_real
					AND GV2.fecha_valuacion	= GV1.fecha_valuacion
		
					COMMIT TRANSACTION TRA_Act_Avalpenul
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalpenul

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a tres, el indicador del tipo de registro de los avalúos. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH

	
			
			--Se obtienen los avalúos que son iguales a los registrados en el SICC para operaciones
			--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes, con clase distinta a 11
			BEGIN TRANSACTION TRA_Act_Avalhc
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_HIPOTECAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnu_part = GGR.cod_partido
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE CGV.Ind_Clase_Alfanumerica = 0		
					
					COMMIT TRANSACTION TRA_Act_Avalhc
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalhc

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las hipotecas comunes (con clase distinta a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
				



			--Se asigna el mínimo monto de la fecha del avalúo más reciente para hipotecas comunes, con clase igual a 11
			BEGIN TRANSACTION TRA_Act_Avalhc11
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnu_part = GGR.cod_partido
						AND ISNULL(TMP.prmgt_pnuidegar, 0) = ISNULL(GGR.Identificacion_Sicc, 0)
						AND ISNULL(TMP.prmgt_pnuide_alf, '') = ISNULL(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE CGV.Ind_Clase_Alfanumerica = 1
		
					COMMIT TRANSACTION TRA_Act_Avalhc11
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalhc11

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las hipotecas comunes (con clase igual a 11). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		

			--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía 18
			BEGIN TRANSACTION TRA_Act_Avalch18
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_CEDULAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnu_part = GGR.cod_partido
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia = 18
						AND CGV.Ind_Clase_Alfanumerica = 0
					
					COMMIT TRANSACTION TRA_Act_Avalch18
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalch18

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las cédulas hipotecarias con clase 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		
			--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
			BEGIN TRANSACTION TRA_Act_Avalch
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar 
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_CEDULAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND CONVERT(VARCHAR(2), TMP.prmgt_pco_grado) = GGR.cod_grado
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	GGR.cod_clase_garantia > 18
						AND CGV.Ind_Clase_Alfanumerica = 0
					
					COMMIT TRANSACTION TRA_Act_Avalch
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalch

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las cédulas hipotecarias con clase diferente a 18. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		
			--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas, con clase diferente a 38 o 43
			BEGIN TRANSACTION TRA_Act_Avalp
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar 
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_PRENDAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	CGV.Ind_Clase_Alfanumerica = 0
		
					COMMIT TRANSACTION TRA_Act_Avalp
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalp

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las prendas (con clase distinta a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
			
			--Se asigna el mínimo monto de la fecha del avlaúo más reciente para prendas, con clase igual a 38 o 43
			BEGIN TRANSACTION TRA_Act_Avalp3843
				BEGIN TRY
		
					UPDATE	GV1
					SET		GV1.monto_total_avaluo = TMP.prmgt_pmoavaing,
							GV1.Indicador_Tipo_Registro = 1,
							GV1.Fecha_Replica = GETDATE(),
							GV1.Tipo_Moneda_Tasacion = TMP.prmgt_pco_mongar 
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_garantia_real = GV1.cod_garantia_real
						INNER JOIN dbo.AUX_GAR_PRENDAS_ALF_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND COALESCE(TMP.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
						AND COALESCE(TMP.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
						AND TMP.Fecha_Valuacion = GV1.fecha_valuacion
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
					WHERE	CGV.Ind_Clase_Alfanumerica = 1
					
					COMMIT TRANSACTION TRA_Act_Avalp3843
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_Avalp3843

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar, a uno, el indicador del tipo de registro de los avalúos y el monto total del avalúo de las prendas (con clase igual a 38 o 43). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		END

		--Se coloniza el monto total del avalúo
		IF(@piIndicadorProceso = 14)
		BEGIN

			/*TABLA AUXILIAR DE AVALUOS A SER COLONIZADOS*/
			IF OBJECT_ID('dbo.AUX_AVALUOS_COLONIZADOS') IS NOT NULL
				DROP TABLE dbo.AUX_AVALUOS_COLONIZADOS
	

			/*Esta tabla almacenará los avalúos que serán colonizados*/
			CREATE TABLE dbo.AUX_AVALUOS_COLONIZADOS 
			(	
				cod_garantia_real BIGINT,
				fecha_valuacion DATETIME,
				monto_total_avaluo DECIMAL(14, 2),
				Monto_Total_Avaluo_Colonizado DECIMAL(14, 2),
				Tipo_Cambio DECIMAL(18, 2)
			) ON [PRIMARY]

			--SE OBTIENEN LOS DATOS
			INSERT	INTO dbo.AUX_AVALUOS_COLONIZADOS(cod_garantia_real, fecha_valuacion, monto_total_avaluo, Monto_Total_Avaluo_Colonizado, Tipo_Cambio)
			SELECT	cod_garantia_real, fecha_valuacion, monto_total_avaluo, 0 AS Monto_Total_Avaluo_Colonizado, 0 AS Tipo_Cambio
			FROM	dbo.GAR_VALUACIONES_REALES 
			WHERE	Tipo_Moneda_Tasacion = 2


			CREATE INDEX AUX_AVALUOS_COLONIZADOS_IX_01 ON dbo.AUX_AVALUOS_COLONIZADOS (cod_garantia_real) ON [PRIMARY]

			--SE ACTUALIZA EL TIPO DE CAMBIO
			
			UPDATE	AAC
			SET		Tipo_Cambio = ISNULL(IAA.Tipo_Cambio, 0)
			FROM	dbo.AUX_AVALUOS_COLONIZADOS AAC	
				INNER JOIN dbo.CAT_INDICES_ACTUALIZACION_AVALUO IAA
				ON CONVERT(DATE, IAA.Fecha_Hora) = CONVERT(DATE, AAC.fecha_valuacion)
			WHERE ISNULL(AAC.Tipo_Cambio, 0) = 0

			UPDATE	AAC
			SET		Tipo_Cambio = ISNULL(IAA.Tipo_Cambio, 0)
			FROM dbo.AUX_AVALUOS_COLONIZADOS AAC
				INNER JOIN (
					SELECT TOP 1 TM2.cod_garantia_real, TM2.fecha_valuacion, TM1.Tipo_Cambio
					FROM  dbo.CAT_INDICES_ACTUALIZACION_AVALUO TM1
					INNER JOIN (
					SELECT cod_garantia_real, fecha_valuacion
					FROM dbo.AUX_AVALUOS_COLONIZADOS
					WHERE ISNULL(Tipo_Cambio, 0) = 0) TM2
					ON CONVERT(DATE, TM2.fecha_valuacion) > CONVERT(DATE, TM1.Fecha_Hora)
					ORDER BY TM1.Fecha_Hora DESC) IAA
				ON AAC.cod_garantia_real = IAA.cod_garantia_real
				AND AAC.fecha_valuacion = IAA.fecha_valuacion
			WHERE ISNULL(AAC.Tipo_Cambio, 0) = 0
		

			--Se coloniza el monto total del avaluo, tipo moneda: Colones
			BEGIN TRANSACTION TRA_Act_MTAC
				BEGIN TRY
		
					UPDATE	GV1
					SET	    GV1.Monto_Total_Avaluo_Colonizado =	GV1.monto_total_avaluo
					FROM	dbo.GAR_VALUACIONES_REALES GV1
					WHERE	GV1.Tipo_Moneda_Tasacion = 1
					
					COMMIT TRANSACTION TRA_Act_MTAC
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_MTAC

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al colonizar el monto total del avalúo (Moneda: Colones). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH

			--Se coloniza el monto total del avaluo, tipo moneda: Dolares
			BEGIN TRANSACTION TRA_Act_MTAC
				BEGIN TRY
		
					UPDATE	GV1
					SET	    GV1.Monto_Total_Avaluo_Colonizado =	(GV1.monto_total_avaluo * AAC.Tipo_Cambio)
					FROM	dbo.GAR_VALUACIONES_REALES GV1
						INNER JOIN dbo.AUX_AVALUOS_COLONIZADOS AAC	
						ON AAC.cod_garantia_real = GV1.cod_garantia_real
						AND AAC.fecha_valuacion = GV1.fecha_valuacion						
					WHERE	GV1.Tipo_Moneda_Tasacion = 2
					
					COMMIT TRANSACTION TRA_Act_MTAC
			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Act_MTAC

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al colonizar el monto total del avalúo (Moneda: Dólares). Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
		
		
		/***************************************************************************************************************************************************/

			--INICIO PBI: 26539
			BEGIN TRANSACTION TRA_Val_Act_Datos
				BEGIN TRY

					--SE AJUSTAN LAS GARANTIAS QUE POSEEN ASIGNADO EL TIPO DE BIEN IGULA A 1 (TERRENOS)
					UPDATE	GVR	
					SET		GVR.monto_ultima_tasacion_no_terreno = 0,
							GVR.monto_tasacion_actualizada_no_terreno = 0
					FROM	dbo.GAR_VALUACIONES_REALES GVR
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
							ON GGR.cod_garantia_real = GVR.cod_garantia_real
					WHERE	GGR.cod_tipo_bien = 1

					--SE AJUSTAN LAS GARANTIAS QUE POSEEN ASIGNADO EL TIPO DE BIEN IGULA A 2 (EDIFICACIONES)
					UPDATE	GVR	
					SET		GVR.monto_ultima_tasacion_terreno = ISNULL(GVR.monto_ultima_tasacion_terreno, 0),
							GVR.monto_tasacion_actualizada_terreno = ISNULL(GVR.monto_tasacion_actualizada_terreno, 0),
							GVR.monto_ultima_tasacion_no_terreno = ISNULL(GVR.monto_ultima_tasacion_no_terreno, 0),
							GVR.monto_tasacion_actualizada_no_terreno = ISNULL(GVR.monto_tasacion_actualizada_no_terreno, 0)
					FROM	dbo.GAR_VALUACIONES_REALES GVR
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
							ON GGR.cod_garantia_real = GVR.cod_garantia_real
					WHERE	GGR.cod_tipo_bien = 2


					--SE AJUSTAN LAS GARANTIAS QUE POSEEN ASIGNADO EL TIPO DE BIEN IGULA MAYORES O IGUALES A 3 Y MENORES O IGUALES A 14
					UPDATE	GVR	
					SET		GVR.monto_ultima_tasacion_terreno = 0,
							GVR.monto_tasacion_actualizada_terreno = 0
					FROM	dbo.GAR_VALUACIONES_REALES GVR
						INNER JOIN dbo.GAR_GARANTIA_REAL GGR
							ON GGR.cod_garantia_real = GVR.cod_garantia_real
					WHERE	GGR.cod_tipo_bien >= 3
						AND GGR.cod_tipo_bien <= 14

					COMMIT TRANSACTION TRA_Val_Act_Datos
				END TRY
				BEGIN CATCH
				
					ROLLBACK TRANSACTION TRA_Val_Act_Datos

					SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar los montos del terreno y no terreno, según el tipo de bien. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
					EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

				END CATCH

			--FIN PBI: 26539

		/***************************************************************************************************************************************************/



		
			/*CREACION DE TABLA TEMPORAL QUE SERA USADA EN LAS CONSULTA DE GARANTIUAS REALES DESDE LA APP*/
			BEGIN TRANSACTION TRA_Gar_Rea_Valid
				BEGIN TRY
					/*TABLA DE GARANTIAS REALES VALIDAS PARA CONSULTARLAS*/
					IF OBJECT_ID('dbo.TMP_GARANTIAS_REALES_VALIDAS') IS NOT NULL
						DROP TABLE dbo.TMP_GARANTIAS_REALES_VALIDAS


					CREATE TABLE dbo.TMP_GARANTIAS_REALES_VALIDAS(
						Codigo_Garantia_Real BIGINT NOT NULL,
						Tipo_Garantia_Real TINYINT NOT NULL,
						Codigo_Clase_Garantia TINYINT NOT NULL,
						Ind_Clase_Alfanumerica BIT NOT NULL,
						Codigo_Bien VARCHAR(30) NOT NULL,
						Fecha_Valuacion DATETIME NULL,
						Fecha_Valuacion_Entera INT NOT NULL,
						Monto_Total_Avaluo_SICC DECIMAL(14,2) NOT NULL,
						Monto_Total_Avaluo_Colonizado MONEY NOT NULL,
						Tipo_Moneda_Tasacion SMALLINT NOT NULL
					) ON [PRIMARY]


					--SE INSERTAN LOS DATOS DE LAS HIPOTECAS COMUNES CON IDENTIFICACION NO ALFANUMERICA
					INSERT dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real, Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica, Codigo_Bien, Fecha_Valuacion, Fecha_Valuacion_Entera, Monto_Total_Avaluo_SICC, Monto_Total_Avaluo_Colonizado, Tipo_Moneda_Tasacion)
					SELECT	GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							CASE 
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido) + '-' + GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) = 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) = 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido)
								ELSE ''
							END AS Codigo_Bien,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing, 103)
								ELSE NULL
							END AS Fecha_Valuacion,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN -1
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN TMP.prmgt_pfeavaing
								ELSE -1
							END AS Fecha_Valuacion_Entera,
							ISNULL(TMP.prmgt_pmoavaing, 0) AS Monto_Total_Avaluo_SICC,
							0 AS Monto_Total_Avaluo_Colonizado,
							ISNULL(TMP.prmgt_pco_mongar, 0) AS Tipo_Moneda_Tasacion
					FROM	dbo.GAR_SICC_PRMGT MGT
						INNER JOIN  dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
						AND GGR.cod_partido = MGT.prmgt_pnu_part				
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = MGT.prmgt_pcoclagar
						LEFT JOIN dbo.AUX_GAR_HIPOTECAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.prmgt_pnu_part = GGR.cod_partido
					WHERE CGV.Ind_Clase_Alfanumerica = 0
					GROUP BY GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							GGR.cod_partido, 
							GGR.numero_finca,
							TMP.prmgt_pfeavaing,
							TMP.prmgt_pmoavaing,
							TMP.prmgt_pco_mongar

					--SE INSERTAN LOS DATOS DE LAS HIPOTECAS COMUNES CON IDENTIFICACION ALFANUMERICA
					INSERT dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real, Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica, Codigo_Bien, Fecha_Valuacion, Fecha_Valuacion_Entera, Monto_Total_Avaluo_SICC, Monto_Total_Avaluo_Colonizado, Tipo_Moneda_Tasacion)
					SELECT	GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							CASE 
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido) + '-' + GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) = 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) = 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido)
								ELSE ''
							END AS Codigo_Bien,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing, 103)
								ELSE NULL
							END AS Fecha_Valuacion,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN -1
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN TMP.prmgt_pfeavaing
								ELSE -1
							END AS Fecha_Valuacion_Entera,
							ISNULL(TMP.prmgt_pmoavaing, 0) AS Monto_Total_Avaluo_SICC,
							0 AS Monto_Total_Avaluo_Colonizado,
							ISNULL(TMP.prmgt_pco_mongar, 0) AS Tipo_Moneda_Tasacion
					FROM	dbo.GAR_SICC_PRMGT MGT
						INNER JOIN  dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
						AND GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf
						AND GGR.cod_partido = MGT.prmgt_pnu_part				
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 1
						AND CGV.Codigo_Clase_Garantia = MGT.prmgt_pcoclagar
						LEFT JOIN dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
						AND TMP.prmgt_pnu_part = GGR.cod_partido
					WHERE CGV.Ind_Clase_Alfanumerica = 1


					--SE INSERTAN LOS DATOS DE LAS CEDULAS HIPOTECARIAS
					INSERT dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real, Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica, Codigo_Bien, Fecha_Valuacion, Fecha_Valuacion_Entera, Monto_Total_Avaluo_SICC, Monto_Total_Avaluo_Colonizado, Tipo_Moneda_Tasacion)
					SELECT	GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							CASE 
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido) + '-' + GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) = 0 AND LEN(ISNULL(GGR.numero_finca, '')) > 0 THEN GGR.numero_finca
								WHEN ISNULL(GGR.cod_partido, 0) > 0 AND LEN(ISNULL(GGR.numero_finca, '')) = 0 THEN CONVERT(VARCHAR(2), GGR.cod_partido)
								ELSE ''
							END AS Codigo_Bien,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing, 103)
								ELSE NULL
							END AS Fecha_Valuacion,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN -1
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN TMP.prmgt_pfeavaing
								ELSE -1
							END AS Fecha_Valuacion_Entera,
							ISNULL(TMP.prmgt_pmoavaing, 0) AS Monto_Total_Avaluo_SICC,
							0 AS Monto_Total_Avaluo_Colonizado,
							ISNULL(TMP.prmgt_pco_mongar, 0) AS Tipo_Moneda_Tasacion
					FROM	dbo.GAR_SICC_PRMGT MGT
						INNER JOIN  dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
						AND GGR.cod_partido = MGT.prmgt_pnu_part				
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 2
						AND CGV.Codigo_Clase_Garantia = MGT.prmgt_pcoclagar
						LEFT JOIN dbo.AUX_GAR_CEDULAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.prmgt_pnu_part = GGR.cod_partido
		
			
					--SE INSERTAN LOS DATOS DE LAS PRENDAS CON IDENTIFICACION NO ALFANUMERICA
					INSERT dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real, Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica, Codigo_Bien, Fecha_Valuacion, Fecha_Valuacion_Entera, Monto_Total_Avaluo_SICC, Monto_Total_Avaluo_Colonizado, Tipo_Moneda_Tasacion)
					SELECT	GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							CASE 
								WHEN LEN(ISNULL(GGR.cod_clase_bien, '')) > 0 AND LEN(ISNULL(GGR.num_placa_bien, '')) > 0 THEN CONVERT(VARCHAR(2), GGR.cod_clase_bien) + '-' + GGR.num_placa_bien
								WHEN LEN(ISNULL(GGR.cod_clase_bien, '')) = 0 AND LEN(ISNULL(GGR.num_placa_bien, '')) > 0 THEN GGR.num_placa_bien
								WHEN LEN(ISNULL(GGR.cod_clase_bien, '')) > 0 AND LEN(ISNULL(GGR.num_placa_bien, '')) = 0 THEN CONVERT(VARCHAR(2), GGR.cod_clase_bien)
								ELSE ''
							END AS Codigo_Bien,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing, 103)
								ELSE NULL
							END AS Fecha_Valuacion,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN -1
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN TMP.prmgt_pfeavaing
								ELSE -1
							END AS Fecha_Valuacion_Entera,
							ISNULL(TMP.prmgt_pmoavaing, 0) AS Monto_Total_Avaluo_SICC,
							0 AS Monto_Total_Avaluo_Colonizado,
							ISNULL(TMP.prmgt_pco_mongar, 0) AS Tipo_Moneda_Tasacion
					FROM	dbo.GAR_SICC_PRMGT MGT
						INNER JOIN  dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = MGT.prmgt_pcoclagar
						LEFT JOIN dbo.AUX_GAR_PRENDAS_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
					WHERE CGV.Ind_Clase_Alfanumerica = 0


					--SE INSERTAN LOS DATOS DE LAS PRENDAS CON IDENTIFICACION ALFANUMERICA
					INSERT dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real, Tipo_Garantia_Real, Codigo_Clase_Garantia, Ind_Clase_Alfanumerica, Codigo_Bien, Fecha_Valuacion, Fecha_Valuacion_Entera, Monto_Total_Avaluo_SICC, Monto_Total_Avaluo_Colonizado, Tipo_Moneda_Tasacion)
					SELECT	GGR.cod_garantia_real,
							GGR.cod_tipo_garantia_real,
							GGR.cod_clase_garantia,
							CGV.Ind_Clase_Alfanumerica,
							ISNULL(GGR.num_placa_bien, '') AS Codigo_Bien,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN NULL
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing, 103)
								ELSE NULL
							END AS Fecha_Valuacion,
							CASE 
								WHEN ISNULL(TMP.prmgt_pfeavaing, 0) = 0 THEN -1
								WHEN ISDATE(CONVERT(VARCHAR(10), TMP.prmgt_pfeavaing)) = 1 THEN TMP.prmgt_pfeavaing
								ELSE -1
							END AS Fecha_Valuacion_Entera,
							ISNULL(TMP.prmgt_pmoavaing, 0) AS Monto_Total_Avaluo_SICC,
							0 AS Monto_Total_Avaluo_Colonizado,
							ISNULL(TMP.prmgt_pco_mongar, 0) AS Tipo_Moneda_Tasacion
					FROM	dbo.GAR_SICC_PRMGT MGT
						INNER JOIN  dbo.GAR_GARANTIA_REAL GGR
						ON GGR.cod_clase_garantia = MGT.prmgt_pcoclagar
						AND GGR.Identificacion_Sicc = MGT.prmgt_pnuidegar
						AND GGR.Identificacion_Alfanumerica_Sicc = MGT.prmgt_pnuide_alf
						INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
						ON 	CGV.Tipo_Garantia_Real = 3
						AND CGV.Codigo_Clase_Garantia = MGT.prmgt_pcoclagar
						LEFT JOIN dbo.AUX_GAR_HIPOTECAS_ALF_SICC TMP
						ON TMP.prmgt_pcoclagar = GGR.cod_clase_garantia
						AND TMP.prmgt_pnuidegar = GGR.Identificacion_Sicc
						AND TMP.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
					WHERE CGV.Ind_Clase_Alfanumerica = 1



					CREATE CLUSTERED INDEX TMP_GARANTIAS_REALES_VALIDAS_IX_01 ON dbo.TMP_GARANTIAS_REALES_VALIDAS (Codigo_Garantia_Real) ON [PRIMARY]
					CREATE INDEX TMP_GARANTIAS_REALES_VALIDAS_IX_02 ON dbo.TMP_GARANTIAS_REALES_VALIDAS (Tipo_Garantia_Real, Codigo_Clase_Garantia, Codigo_Bien) ON [PRIMARY]


					UPDATE	TMP
					SET		TMP.Monto_Total_Avaluo_Colonizado = ISNULL(GVR.Monto_Total_Avaluo_Colonizado, 0)
					FROM	dbo.TMP_GARANTIAS_REALES_VALIDAS TMP
						LEFT JOIN dbo.GAR_VALUACIONES_REALES GVR
						ON GVR.cod_garantia_real = TMP.Codigo_Garantia_Real
						AND GVR.fecha_valuacion = TMP.Fecha_Valuacion
				
				COMMIT TRANSACTION TRA_Gar_Rea_Valid

			END TRY
			BEGIN CATCH
				
				ROLLBACK TRANSACTION TRA_Gar_Rea_Valid

				SELECT @vsDescripcion_Bitacora_Errores = 'Se produjo un error al actualizar la tabla temporal de garantías reales validas. Detalle Técnico: ' + ERROR_MESSAGE() + ('. Código de error: ' + CONVERT(VARCHAR(1000), ERROR_NUMBER()))
				EXEC dbo.pa_RegistroEjecucionProceso @psCodigoProceso, @vdFecha_Actual_Sin_Hora, @vsDescripcion_Bitacora_Errores, 1

			END CATCH
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
