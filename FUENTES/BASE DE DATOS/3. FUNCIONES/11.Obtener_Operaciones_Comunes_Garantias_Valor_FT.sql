USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('Obtener_Operaciones_Comunes_Garantias_Valor_FT') IS NOT NULL 
    DROP FUNCTION Obtener_Operaciones_Comunes_Garantias_Valor_FT;
GO


CREATE FUNCTION [dbo].[Obtener_Operaciones_Comunes_Garantias_Valor_FT] 
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
	<Nombre>Obtener_Operaciones_Comunes_Garantias_Valor_FT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Función que se encarga de obtener las operaciones, contratos y giros de contrato de una misma garantía valor, así mismo los consecutivos de las
		garantías que sean de la misma seguridad.
	</Descripción>
	<Entradas>		
		
		@piConsecutivo_Operacion		= Consecutivo de la operación. En caso de suministrar este valor, se retornarán los consecutivos de las garantías relacionadas a esa operación, 
										  caso contrario se retornarán todas las operaciones respaldadas por la misma garantía.
		@piConsecutivo_Garantia			= Consecutivo de la garantía fiduciaria con la que se inicia la consulta.
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
	
	DECLARE		@vdtFecha_Hoy_Sin_Hora		DATETIME,
				@viFecha_Entero				INT,
				@vbEsta_Contrato_Vencido	BIT,
				@viIdentificacion_Garantia	DECIMAL(12,0)
				

	--Se convierte la fecha actual a número, para así poder determinar si un contrato está vencido o no.
	SET		@vdtFecha_Hoy_Sin_Hora	= CONVERT(DATETIME,CAST(@pdtFecha_Actual AS VARCHAR(11)),101)
	SET		@viFecha_Entero			= CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Hoy_Sin_Hora, 112))
	SET		@viIdentificacion_Garantia = (	SELECT	Identificacion_Sicc
											FROM	dbo.GAR_GARANTIA_VALOR
											WHERE	cod_garantia_valor = @piConsecutivo_Garantia)
	

	--Se obtien las operaciones comunes
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	1 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGV.cod_garantia_valor
	FROM	dbo.GAR_GARANTIA_VALOR GGV WITH(NOLOCK) 
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO WITH(NOLOCK)
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK)
		ON GVO.cod_operacion = GO1.cod_operacion
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
		AND MGT.prmgt_estado = 'A'
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
	WHERE	GGV.Identificacion_Sicc = @viIdentificacion_Garantia
		AND GO1.num_contrato = 0
		AND MOC.prmoc_pse_proces = 1	--Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay > 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND ((MGT.prmgt_pcotengar = 6) 
			OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
						
	--Se obtien los contratos vigentes comunes
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGV.cod_garantia_valor
	FROM	dbo.GAR_GARANTIA_VALOR GGV WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO WITH(NOLOCK)
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GVO.cod_operacion = GO1.cod_operacion
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
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
	WHERE	GGV.Identificacion_Sicc = @viIdentificacion_Garantia
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin >= @viFecha_Entero
		AND ((MGT.prmgt_pcotengar = 6) 
			OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))


	--Se obtien los contratos vencidos con giros activos comunes
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	2 AS Tipo_Operacion,
			GO1.cod_operacion,
			GGV.cod_garantia_valor
	FROM	dbo.GAR_GARANTIA_VALOR GGV WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO WITH(NOLOCK)
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GVO.cod_operacion = GO1.cod_operacion
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
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
		INNER JOIN dbo.GAR_SICC_PRMOC MOC WITH(NOLOCK) 
		ON  MOC.prmoc_pco_oficon = MCA.prmca_pco_ofici
		AND MOC.prmoc_pcomonint = MCA.prmca_pco_moned
		AND MOC.prmoc_pnu_contr = MCA.prmca_pnu_contr
	WHERE	GGV.Identificacion_Sicc = @viIdentificacion_Garantia
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND MCA.prmca_pfe_defin < @viFecha_Entero
		AND ((MGT.prmgt_pcotengar = 6) 
			OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'


	--Se obtien los giros activos comunes
	INSERT	INTO @ptbOperaciones_Comunes (Tipo_Operacion, Consecutivo_Operacion, Consecutivo_Garantia)
	SELECT	3 AS Tipo_Operacion,
			GO2.cod_operacion,
			GGV.cod_garantia_valor
	FROM	dbo.GAR_GARANTIA_VALOR GGV WITH(NOLOCK)
		INNER JOIN dbo.GAR_GARANTIAS_VALOR_X_OPERACION GVO WITH(NOLOCK)
		ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
		INNER JOIN dbo.GAR_OPERACION GO1 WITH(NOLOCK) 
		ON GVO.cod_operacion = GO1.cod_operacion
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
		AND MGT.prmgt_pnuidegar = GGV.Identificacion_Sicc
		AND MGT.prmgt_pcoclagar = GGV.cod_clase_garantia
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
	WHERE	GGV.Identificacion_Sicc = @viIdentificacion_Garantia
		AND GO1.num_contrato > 0
		AND COALESCE(GO1.num_operacion, -1) = -1
		AND MCA.prmca_estado = 'A'
		AND ((MGT.prmgt_pcotengar = 6) 
			OR ((MGT.prmgt_pcotengar >= 2) AND (MGT.prmgt_pcotengar <= 4)))		
		AND MOC.prmoc_pse_proces = 1 --Operaciones activas
		AND ((MOC.prmoc_pcoctamay < 815)
			OR (MOC.prmoc_pcoctamay	> 815))	--Operaciones no insolutas
		AND MOC.prmoc_estado = 'A'
		AND GO2.num_contrato > 0
		AND COALESCE(GO2.num_operacion, -1) > -1;



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

