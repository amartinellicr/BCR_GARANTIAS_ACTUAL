USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('Obtener_Operaciones_Comunes_Garantias_Reales_FT') IS NOT NULL 
    DROP FUNCTION Obtener_Operaciones_Comunes_Garantias_Reales_FT;
GO


CREATE FUNCTION [dbo].[Obtener_Operaciones_Comunes_Garantias_Reales_FT] 
(
	@piConsecutivo_Operacion	BIGINT = NULL,
	@piConsecutivo_Garantia		BIGINT,
	@pdtFecha_Actual			DATETIME,
	@pbExcluir_Operacion		BIT
)
RETURNS @ptbOperaciones_Comunes TABLE(
			Tipo_Operacion			TINYINT,
			Consecutivo_Operacion	BIGINT,
			Consecutivo_Garantia	BIGINT)
AS

/*****************************************************************************************************************************************************
	<Nombre>Obtener_Operaciones_Comunes_Garantias_Reales_FT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Función que se encarga de obtener las operaciones, contratos y giros de contrato de una mismas garantía real, así mismo los consecutivos de las
		garantías que sean de la misma finca o prenda.
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Operacion		= Consecutivo de la operación. En caso de suministrar este valor, se retornarán los consecutivos de las garantías relacionadas a esa operación, 
										  caso contrario se retornarán todas las operaciones respaldadas por la misma garantía.
		@piConsecutivo_Garantia			= Consecutivo de la garantía real con la que se inicia la consulta.
		@pdtFecha_Actual				= Fecha actual.
		@pbExcluir_Operacion			= Indica si la operación proporcinada debe ser excluida (1) o no (0) del resultado final.
		
	</Entradas>
	<Salidas>
			@ptbOperaciones_Comunes		= Tabla con las operaciones y garantías comunes recopiladas.
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, GrupoMAS S.A.</Autor>
	<Fecha>08/03/2016</Fecha>
	<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

BEGIN
	
	DECLARE		@vdtFecha_Hoy_Sin_Hora			DATETIME,
				@viFecha_Entero					INT,
				@vbEsta_Contrato_Vencido		BIT,
				@vdIdentificacion_Garantia		DECIMAL(12,0),
				@viCodigo_Partido				SMALLINT,
				@viCodigo_Grado_Garantia		TINYINT,
				@vsIdentificacion_Bien			VARCHAR(25),
				@piCodigo_Clase_Garantia		SMALLINT,
				@vsCodigo_Grado					VARCHAR(2)
			

	--Se convierte la fecha actual a número, para así poder determinar si un contrato está vencido o no.
	SET		@vdtFecha_Hoy_Sin_Hora	= CONVERT(DATETIME,CAST(@pdtFecha_Actual AS VARCHAR(11)),101)
	SET		@viFecha_Entero			= CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Hoy_Sin_Hora, 112))
	
	SELECT	@piCodigo_Clase_Garantia = cod_clase_garantia,
			@vdIdentificacion_Garantia = Identificacion_Sicc,
			@vsIdentificacion_Bien =	CASE
											WHEN (cod_clase_garantia = 11)  THEN Identificacion_Alfanumerica_Sicc
											WHEN (cod_clase_garantia = 38)  THEN Identificacion_Alfanumerica_Sicc
											WHEN (cod_clase_garantia = 43)  THEN Identificacion_Alfanumerica_Sicc
											ELSE NULL
										END,
			@viCodigo_Partido = CASE		
									WHEN (@piCodigo_Clase_Garantia >= 30) THEN NULL
									ELSE  cod_partido
								END,
			@viCodigo_Grado_Garantia =	CASE
											WHEN (cod_clase_garantia = 18) THEN CAST(cod_grado AS TINYINT)
											WHEN (cod_clase_garantia >= 20) AND (cod_clase_garantia <= 29) THEN CAST(cod_grado AS TINYINT)
											ELSE NULL
										END,
			@vsCodigo_Grado =	CASE
									WHEN (cod_clase_garantia = 18) THEN cod_grado
									WHEN (cod_clase_garantia >= 20) AND (cod_clase_garantia <= 29) THEN cod_grado 
									ELSE NULL
								END

	FROM	dbo.GAR_GARANTIA_REAL
	WHERE	cod_garantia_real = @piConsecutivo_Garantia


	--Se obtien las operaciones comunes
/***********************************************************************************************************************************************/
	--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND ((GGR.cod_clase_garantia = 10)
			OR (GGR.cod_clase_garantia >= 12) AND (GGR.cod_clase_garantia <= 17))
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'

	--HIPOTECAS COMUNES CON CLASE IGUAL A 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_clase_garantia = 11
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'


	--CEDULAS HIPOTECARIAS CON CLASE IGUAL A 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia = 18
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'

	
	--CEDULAS HIPOTECARIAS CON CLASE DISTINTA DE 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia >= 20 
		AND GGR.cod_clase_garantia <= 29
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND MGT.prmgt_pcotengar = 1
		
	
	--PRENDAS CON CLASE DISTINTA DE 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND (((GGR.cod_clase_garantia >= 30) AND (GGR.cod_clase_garantia<= 37))
			OR ((GGR.cod_clase_garantia >= 39) AND (GGR.cod_clase_garantia <= 42))
			OR ((GGR.cod_clase_garantia >= 44) AND (GGR.cod_clase_garantia <= 69)))
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'



	--PRENDAS CON CLASE IGUAL A 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK)
		ON MOC.prmoc_pnu_oper = GO1.num_operacion
		AND MOC.prmoc_pco_ofici = GO1.cod_oficina
		AND MOC.prmoc_pco_moned = GO1.cod_moneda 
		AND MOC.prmoc_pco_produ = GO1.cod_producto
		AND MOC.prmoc_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MOC.prmoc_pnu_oper
		AND MGT.prmgt_pco_ofici = MOC.prmoc_pco_ofici
		AND MGT.prmgt_pco_moned = MOC.prmoc_pco_moned
		AND MGT.prmgt_pco_produ = MOC.prmoc_pco_produ
		AND MGT.prmgt_pco_conta = MOC.prmoc_pco_conta
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia <= 43))
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'

/***********************************************************************************************************************************************/
						
	--Se obtien los contratos vigentes comunes

/***********************************************************************************************************************************************/

	--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND ((GGR.cod_clase_garantia = 10)
			OR (GGR.cod_clase_garantia >= 12) AND (GGR.cod_clase_garantia <= 17))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero


	--HIPOTECAS COMUNES CON CLASE IGUAL A 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_clase_garantia = 11
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero


	--CEDULAS HIPOTECARIAS CON CLASE IGUAL A 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia = 18
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero


	--CEDULAS HIPOTECARIAS CON CLASE DISTINTA DE 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia >= 20 
		AND GGR.cod_clase_garantia <= 29
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero
		AND MGT.prmgt_pcotengar = 1
		


	--PRENDAS CON CLASE DISTINTA DE 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND (((GGR.cod_clase_garantia >= 30) AND (GGR.cod_clase_garantia<= 37))
			OR ((GGR.cod_clase_garantia >= 39) AND (GGR.cod_clase_garantia <= 42))
			OR ((GGR.cod_clase_garantia >= 44) AND (GGR.cod_clase_garantia <= 69)))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero



	--PRENDAS CON CLASE IGUAL A 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia <= 43))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero


/***********************************************************************************************************************************************/

	--Se obtien los contratos vencidos con giros activos comunes

/***********************************************************************************************************************************************/

	--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND ((GGR.cod_clase_garantia = 10)
			OR (GGR.cod_clase_garantia >= 12) AND (GGR.cod_clase_garantia <= 17))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'


	--HIPOTECAS COMUNES CON CLASE IGUAL A 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_clase_garantia = 11
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'


	--CEDULAS HIPOTECARIAS CON CLASE IGUAL A 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia = 18
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'


	--CEDULAS HIPOTECARIAS CON CLASE DISTINTA DE 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia >= 20 
		AND GGR.cod_clase_garantia <= 29
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MGT.prmgt_pcotengar = 1
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'



	--PRENDAS CON CLASE DISTINTA DE 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND (((GGR.cod_clase_garantia >= 30) AND (GGR.cod_clase_garantia<= 37))
			OR ((GGR.cod_clase_garantia >= 39) AND (GGR.cod_clase_garantia <= 42))
			OR ((GGR.cod_clase_garantia >= 44) AND (GGR.cod_clase_garantia <= 69)))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'



	--PRENDAS CON CLASE IGUAL A 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia <= 43))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'



/***********************************************************************************************************************************************/

	--Se obtien los giros activos comunes

/***********************************************************************************************************************************************/

	--HIPOTECAS COMUNES CON CLASE DISTINTA DE 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND ((GGR.cod_clase_garantia = 10)
			OR (GGR.cod_clase_garantia >= 12) AND (GGR.cod_clase_garantia <= 17))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


	--HIPOTECAS COMUNES CON CLASE IGUAL A 11
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_clase_garantia = 11
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


	--CEDULAS HIPOTECARIAS CON CLASE IGUAL A 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia = 18
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


	--CEDULAS HIPOTECARIAS CON CLASE DISTINTA DE 18
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnu_part = GGR.cod_partido
		AND MGT.prmgt_pco_grado = GGR.cod_grado
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND GGR.cod_partido = @viCodigo_Partido
		AND GGR.cod_grado = @vsCodigo_Grado
		AND GGR.cod_clase_garantia >= 20 
		AND GGR.cod_clase_garantia <= 29
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MGT.prmgt_pcotengar = 1
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


	--PRENDAS CON CLASE DISTINTA DE 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND (((GGR.cod_clase_garantia >= 30) AND (GGR.cod_clase_garantia<= 37))
			OR ((GGR.cod_clase_garantia >= 39) AND (GGR.cod_clase_garantia <= 42))
			OR ((GGR.cod_clase_garantia >= 44) AND (GGR.cod_clase_garantia <= 69)))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


	--PRENDAS CON CLASE IGUAL A 38 Y 43
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGR.cod_garantia_real
	FROM	dbo.GAR_GARANTIA_REAL GGR WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO WITH(NOLOCK)
		ON GRO.cod_garantia_real = GGR.cod_garantia_real
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GRO.cod_operacion = GO1.cod_operacion
		INNER JOIN dbo.GAR_SICC_PRMCA MCA WITH(NOLOCK) 
		ON MCA.prmca_pnu_contr = GO1.num_contrato
		AND MCA.prmca_pco_ofici = GO1.cod_oficina
		AND MCA.prmca_pco_moned = GO1.cod_moneda 
		AND MCA.prmca_pco_produc = GO1.cod_producto
		AND MCA.prmca_pco_conta = GO1.cod_contabilidad
		INNER JOIN dbo.GAR_SICC_PRMGT MGT WITH(NOLOCK) 
		ON	MGT.prmgt_pnu_oper = MCA.prmca_pnu_contr
		AND MGT.prmgt_pco_ofici = MCA.prmca_pco_ofici
		AND MGT.prmgt_pco_moned = MCA.prmca_pco_moned
		AND MGT.prmgt_pco_produ = 10
		AND MGT.prmgt_pco_conta = MCA.prmca_pco_conta
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
		INNER JOIN dbo.GAR_OPERACION GO2 WITH(NOLOCK) 
		ON GO2.num_operacion = MOC.prmoc_pnu_oper
		AND GO2.cod_oficina = MOC.prmoc_pco_ofici
		AND GO2.cod_moneda = MOC.prmoc_pco_moned
		AND GO2.cod_producto = MOC.prmoc_pco_produ
		AND GO2.cod_contabilidad = MOC.prmoc_pco_conta
	WHERE	GGR.cod_clase_garantia = @piCodigo_Clase_Garantia
		AND GGR.Identificacion_Sicc = @vdIdentificacion_Garantia
		AND LTRIM(RTRIM(GGR.Identificacion_Alfanumerica_Sicc)) = LTRIM(RTRIM(@vsIdentificacion_Bien))
		AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia <= 43))
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;


/***********************************************************************************************************************************************/

	/*SE ELIMINAN LOS REGISTROS DUPLICADOS*/
	WITH DUPLICADOS_OPERACIONES (Consecutivo_Operacion, Consecutivo_Garantia, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Consecutivo_Operacion, Consecutivo_Garantia, 
				ROW_NUMBER() OVER(PARTITION BY Consecutivo_Operacion, Consecutivo_Garantia  ORDER BY Consecutivo_Operacion, Consecutivo_Garantia) AS cantidadRegistrosDuplicados
		FROM	@ptbOperaciones_Comunes
	)
	DELETE
	FROM DUPLICADOS_OPERACIONES
	WHERE cantidadRegistrosDuplicados > 1;

	--SE EXCLUYEN TODAS LAS OPERACIONES EXCEPTO LA ESPECIFICADA
	DELETE	FROM @ptbOperaciones_Comunes
	WHERE	COALESCE(@piConsecutivo_Operacion, -1) > -1
		AND @pbExcluir_Operacion = 0
		AND ((Consecutivo_Operacion < @piConsecutivo_Operacion) 
			OR (Consecutivo_Operacion > @piConsecutivo_Operacion))

	--SE EXCLUYE LA OPERACION ESPECIFICADA
	DELETE	FROM @ptbOperaciones_Comunes
	WHERE	COALESCE(@piConsecutivo_Operacion, -1) > -1
		AND @pbExcluir_Operacion = 1
		AND Consecutivo_Operacion = @piConsecutivo_Operacion

	RETURN
END
GO

