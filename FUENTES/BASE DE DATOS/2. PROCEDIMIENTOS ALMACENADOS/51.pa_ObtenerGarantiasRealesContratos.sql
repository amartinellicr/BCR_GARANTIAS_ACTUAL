USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasRealesContratos', 'P') IS NOT NULL
	DROP PROCEDURE pa_ObtenerGarantiasRealesContratos;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasRealesContratos]
	@piConsecutivo_Operacion BIGINT = NULL,
	@piCodigo_Contabilidad TINYINT,
	@piCodigo_Oficina SMALLINT,
	@piCodigo_Moneda TINYINT,
	@pdNumero_Contrato DECIMAL(7),
	@pbObtener_Solo_Codigo BIT = 0,
	@psCedula_Usuario VARCHAR(30) = NULL 
AS
BEGIN
/******************************************************************
	<Nombre>pa_ObtenerGarantiasRealesContratos</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a las garantías reales 
		relacionadas a los contratos vigentes.
	</Descripción>
	<Entradas>
		@piConsecutivo_Operacion	= Conseutivo del contrato, del cual se obtendrán las garantías reales asociadas. 
		@piCodigo_Contabilidad	= Código de la contabilidad del contrato.
		@piCodigo_Oficina		= Número de la oficina del contrato.
		@piCodigo_Moneda		= Código de la moneda del contrato.
		@pdNumero_Contrato		= Número del contrato.
		@pbObtener_Solo_Codigo	= Indica si se obtiene sólo la inforación referente al código del a garantía o la información completa.
		@psCedula_Usuario		= Identificación del usuario que realzia la consulta de la operación.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>N/A</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.6</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>N/A</Requerimiento>
			<Fecha>17/11/2010</Fecha>
			<Descripción>
				Se modifica radicalmente la forma en como se obtiene la información, se adapta a la lógica seguida 
				para generar el archivo de garantías reales ligadas a contratos.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Luis Diego Morera Cordero, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Mantenimiento Valuaciones, Sibel: 1-21537427</Requerimiento>
			<Fecha>27/06/2013</Fecha>
			<Descripción>
				Se agrega el campo que permite obtener la lista de garantías utilizadas por la consulta del histórico de valuaciones.
			</Descripción>
		</Cambio>
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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>07/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				Se realiza un ajuste general, en el que se eliminan aquellos campos que no son requeridos en la información retornada,
				también se optimizan los mecanismo empleados para la obtención de los registros y la eliminación de posibles duplicados. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00615, Mantenimiento de Saldos Totales y Procentajes de Responsabilidad</Requerimiento>
			<Fecha>10/03/2016</Fecha>
			<Descripción>
				El cambio es referente a la extracción de nuevos campos necesarios.
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

	/*Se declara la variable temporal tipo tabla que será utilizada como tabla maestra*/
	DECLARE @TMP_GARANTIAS_REALES_CONTRATOS TABLE (	cod_bien					VARCHAR (25)	COLLATE DATABASE_DEFAULT,
													cod_tipo_mitigador			SMALLINT,
													cod_tipo_documento_legal	SMALLINT,
													fecha_presentacion			VARCHAR (10)	COLLATE DATABASE_DEFAULT,
													cod_inscripcion				SMALLINT,
													cod_grado					VARCHAR (2)		COLLATE DATABASE_DEFAULT,
													cedula_hipotecaria			VARCHAR (2)		COLLATE DATABASE_DEFAULT,
													cod_clase_garantia			SMALLINT,
													cod_operacion				BIGINT,
													cod_garantia_real			BIGINT,
													cod_tipo_garantia_real		TINYINT,
													numero_finca				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
													num_placa_bien				VARCHAR (25)	COLLATE DATABASE_DEFAULT,
													cod_clase_bien				VARCHAR (3)		COLLATE DATABASE_DEFAULT,
													cod_partido					SMALLINT,
													cod_garantias_listado       VARCHAR (50)	COLLATE DATABASE_DEFAULT,
													Garantia_Real				VARCHAR (150)	COLLATE DATABASE_DEFAULT,
													cod_tipo_operacion			TINYINT,
													ind_duplicidad				TINYINT			DEFAULT (1)	,
													Identificacion_Bien			DECIMAL(12,0),
													Idendificacion_Alfanumerica_Bien VARCHAR(25) COLLATE DATABASE_DEFAULT,
													cod_usuario					VARCHAR (30)	COLLATE DATABASE_DEFAULT,
													Indicador_Porcentaje_Responsabilidad_Maximo BIT, --RQ_MANT_2015111010495738_00615: Se agrega este campo.
													Indicador_Cuenta_Contable_Especial  BIT, --RQ_MANT_2015111010495738_00615: Se agrega este campo.
													cod_llave					BIGINT			IDENTITY(1,1)
													PRIMARY KEY (cod_llave)
										)

	/*Se declaran las variables que se usuarna para trabajar la fecha actual como un entero*/
	DECLARE
		@vdtFecha_Hoy_Sin_Hora DATETIME,
		@viFecha_Entero INT,
		@viConsecutivo	BIGINT --Se usa para generar los códigos de la tabla temporal de números.

	DECLARE @CLASES_GARANTIAS_REALES TABLE (Consecutivo TINYINT
											PRIMARY KEY (Consecutivo)) --Se utilizará para generar los semestres a ser calculados

	SET @vdtFecha_Hoy_Sin_Hora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	SET @viFecha_Entero =  CONVERT(INT, CONVERT(VARCHAR(8), @vdtFecha_Hoy_Sin_Hora, 112))
	SET	@viConsecutivo = 1

	/*Esta tabla almacenará las garantías registradas en el sistema, según el tipo de garantía real*/
	CREATE TABLE #TEMP_PRMGT (	prmgt_pcoclagar TINYINT,
								prmgt_pnu_part TINYINT,
								prmgt_pco_grado TINYINT,
								prmgt_pnuidegar DECIMAL(12,0),
								prmgt_pnuide_alf CHAR(12),
								prmgt_pcotengar TINYINT)
		 
	CREATE INDEX TEMP_PRMGT_IX_01 ON #TEMP_PRMGT (prmgt_pcoclagar, prmgt_pnuidegar, prmgt_pnuide_alf)
	

		
	/*Se determina si se ha enviado el consecutivo del contrato*/
	IF(@piConsecutivo_Operacion IS NULL)
	BEGIN
		SET @piConsecutivo_Operacion = (	SELECT	cod_operacion 
									FROM	dbo.GAR_OPERACION
									WHERE	cod_contabilidad = @piCodigo_Contabilidad
										AND cod_oficina = @piCodigo_Oficina
										AND cod_moneda = @piCodigo_Moneda
										AND num_contrato = @pdNumero_Contrato
										AND num_operacion IS NULL)
	END

	--Se carga la tabla temporal de consecutivos
	WHILE	@viConsecutivo <= 69
	BEGIN
		INSERT INTO @CLASES_GARANTIAS_REALES (Consecutivo) VALUES(@viConsecutivo)
		SET @viConsecutivo = @viConsecutivo + 1
	END

	/*Se obtienen las garantías relacionadas al contrato*/
	INSERT	INTO #TEMP_PRMGT(prmgt_pcoclagar, prmgt_pnu_part, prmgt_pco_grado, prmgt_pnuidegar, prmgt_pnuide_alf, prmgt_pcotengar)
	SELECT  MGT.prmgt_pcoclagar,
			MGT.prmgt_pnu_part,
			MGT.prmgt_pco_grado,
			MGT.prmgt_pnuidegar,
			MGT.prmgt_pnuide_alf,
			MGT.prmgt_pcotengar
		FROM	dbo.GAR_SICC_PRMGT MGT
			INNER JOIN @CLASES_GARANTIAS_REALES CGR
			ON CGR.Consecutivo = MGT.prmgt_pcoclagar
		WHERE	MGT.prmgt_estado = 'A'
			AND MGT.prmgt_pnu_oper = @pdNumero_Contrato
			AND MGT.prmgt_pco_ofici = @piCodigo_Oficina
			AND MGT.prmgt_pco_moned = @piCodigo_Moneda
			AND MGT.prmgt_pco_produ = 10
			AND MGT.prmgt_pco_conta = @piCodigo_Contabilidad


	/*Se eliminan los registros con clase de garantía entre 20 y 29, pero con código de tenencia distinto de 1*/
	DELETE	FROM #TEMP_PRMGT
	WHERE	prmgt_pcoclagar BETWEEN 20 AND 29
		AND prmgt_pcotengar <> 1

	/*Se selecciona la información de la garantía real asociada a los contratos*/
	INSERT	INTO @TMP_GARANTIAS_REALES_CONTRATOS
	SELECT	DISTINCT 
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS cod_bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS cod_tipo_mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS cod_tipo_documento_legal,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) AS fecha_presentacion,
			COALESCE(GRO.cod_inscripcion, -1) AS cod_inscripcion, 
			COALESCE(GGR.cod_grado,'') AS cod_grado,
			COALESCE(GGR.cedula_hipotecaria,'') AS cedula_hipotecaria,
			GGR.cod_clase_garantia,
			GO1.cod_operacion,
			GGR.cod_garantia_real,
			GGR.cod_tipo_garantia_real,
			COALESCE(GGR.numero_finca,'') AS numero_finca,
			COALESCE(GGR.num_placa_bien,'') AS num_placa_bien,
			COALESCE(GGR.cod_clase_bien,'') AS cod_clase_bien,
			GGR.cod_partido,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END AS cod_garantias_listado,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN 'Partido: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(GGR.numero_finca,'') + ' - Grado: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cod_grado),'') + ' - Cédula Hipotecaria: ' + COALESCE(CONVERT(VARCHAR(2),GGR.cedula_hipotecaria),'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN 'Clase Bien: ' + COALESCE(GGR.cod_clase_bien,'') + ' - Número Placa: ' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN 'Número Placa: ' + COALESCE(GGR.num_placa_bien,'') 
			END	AS Garantia_Real,
			2 AS cod_tipo_operacion,
			1 AS ind_duplicidad,
			GGR.Identificacion_Sicc,
			GGR.Identificacion_Alfanumerica_Sicc,
			@psCedula_Usuario AS cod_usuario,
			GRO.Indicador_Porcentaje_Responsabilidad_Maximo, --RQ_MANT_2015111010495738_00615: Se agrega este campo.		
			0 AS Indicador_Cuenta_Contable_Especial --RQ_MANT_2015111010495738_00615: Se agrega este campo.	
	FROM	dbo.GAR_OPERACION GO1 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
		ON GO1.cod_operacion = GRO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR
		ON GRO.cod_garantia_real = GGR.cod_garantia_real 
		INNER JOIN #TEMP_PRMGT MGT
		ON MGT.prmgt_pcoclagar = GGR.cod_clase_garantia
		AND MGT.prmgt_pnuidegar = GGR.Identificacion_Sicc
		AND MGT.prmgt_pnuide_alf = GGR.Identificacion_Alfanumerica_Sicc COLLATE DATABASE_DEFAULT
	WHERE	GO1.cod_operacion = @piConsecutivo_Operacion
		AND MGT.prmgt_pco_grado = COALESCE(GGR.cod_grado, MGT.prmgt_pco_grado)
		AND MGT.prmgt_pnu_part = CASE 
									WHEN  GGR.cod_clase_garantia BETWEEN 30 AND 69 THEN MGT.prmgt_pnu_part
									ELSE  GGR.cod_partido
								  END
	ORDER BY
		numero_finca,
		cod_grado,
		cod_clase_bien,
		num_placa_bien,
		cod_tipo_documento_legal DESC


	/*Se eliminan los registros incompletos*/
	DELETE	FROM @TMP_GARANTIAS_REALES_CONTRATOS
	WHERE	cod_usuario = @psCedula_Usuario
		AND cod_tipo_documento_legal = -1
		AND fecha_presentacion = '19000101'
		AND cod_tipo_mitigador = -1
		AND cod_inscripcion = -1

	/*Se eliminan los registros de hipotecas comunes duplicadas*/
	WITH CTE (cod_clase_garantia, cod_partido, numero_finca, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	cod_clase_garantia, cod_partido, numero_finca,
				ROW_NUMBER() OVER(PARTITION BY cod_clase_garantia, cod_partido, numero_finca  ORDER BY cod_clase_garantia, cod_partido, numero_finca) AS cantidadRegistrosDuplicados
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS
		WHERE	cod_clase_garantia BETWEEN 10 AND 17
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
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS
		WHERE	cod_clase_garantia = 18
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
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS
		WHERE	cod_clase_garantia BETWEEN 20 AND 29
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
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS
		WHERE	cod_clase_garantia BETWEEN 30 AND 69
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


	IF(@pbObtener_Solo_Codigo = 1)
	BEGIN
		SELECT	DISTINCT CASE GRC.cod_tipo_garantia_real  
							WHEN 1 THEN '[Hipoteca] ' + COALESCE(GRC.Garantia_Real,'') 
							WHEN 2 THEN '[Cédula Hipotecaria] ' + COALESCE(GRC.Garantia_Real,'')
							WHEN 3 THEN '[Prenda] ' + COALESCE(GRC.Garantia_Real,'') 
						 END AS garantia
					
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS GRC
			INNER JOIN dbo.CAT_ELEMENTO CE1
			ON CE1.cat_campo = GRC.cod_tipo_garantia_real
		
		WHERE	GRC.cod_usuario = @psCedula_Usuario 
			AND CE1.cat_catalogo= 23 

		ORDER BY garantia
	END
	ELSE 
	BEGIN
		SELECT	GRC.cod_operacion, 
				GRC.cod_garantia_real, 
				GRC.cod_tipo_garantia_real, 
				CE1.cat_descripcion AS tipo_garantia_real, 
				GRC.cod_garantias_listado,
				GRC.Garantia_Real, 
				GRC.cod_grado, 
				GRC.cedula_hipotecaria,
				GRC.cod_clase_garantia,
				GRC.cod_partido,
				CASE 
					WHEN GRC.cod_clase_garantia = 11 THEN GRC.Idendificacion_Alfanumerica_Bien
					WHEN GRC.cod_clase_garantia = 38 THEN GRC.Idendificacion_Alfanumerica_Bien
					WHEN GRC.cod_clase_garantia = 43 THEN GRC.Idendificacion_Alfanumerica_Bien
					ELSE CONVERT(VARCHAR, GRC.Identificacion_Bien)
				END	AS Identificacion_Bien,
				GRC.Indicador_Porcentaje_Responsabilidad_Maximo, --RQ_MANT_2015111010495738_00615: Se agrega este campo.
				GRC.Indicador_Cuenta_Contable_Especial --RQ_MANT_2015111010495738_00615: Se agrega este campo.
		FROM	@TMP_GARANTIAS_REALES_CONTRATOS GRC
			INNER JOIN dbo.CAT_ELEMENTO CE1
			ON CE1.cat_campo = GRC.cod_tipo_garantia_real
		WHERE	GRC.cod_tipo_operacion = 2 
			AND GRC.cod_usuario = @psCedula_Usuario 
			AND CE1.cat_catalogo= 23 
		ORDER BY
			GRC.cod_tipo_garantia_real,
			GRC.cod_bien
	END

	--SE ELIMINAN LAS TABLAS TEMPORALES CREADAS
	DROP TABLE #TEMP_PRMGT
END

GO


