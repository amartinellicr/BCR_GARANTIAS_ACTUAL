USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Aplicar_Calculo_Avaluo_MTAT_MTANT', 'P') IS NOT NULL
	DROP PROCEDURE Aplicar_Calculo_Avaluo_MTAT_MTANT;
GO

CREATE PROCEDURE [dbo].[Aplicar_Calculo_Avaluo_MTAT_MTANT]
	@psCedula_Usuario	VARCHAR(30),
	@piIndicadorProceso	TINYINT,
	@psRespuesta		VARCHAR(1000) OUTPUT
	
AS
/*****************************************************************************************************************************************************
	<Nombre>Aplicar_Calculo_Avaluo_MTAT_MTANT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que aplica el cálculo del monto de la tasación actualizada del terreno y no terreno.
	</Descripción>
	<Entradas>
			@psCedula_Usuario		= Identificación del usuario que realiza la consulta. 
									  Este es dato llave usado para la búsqueda de los registros que deben 
                                      ser eliminados de la tabla temporal.
			@piIndicadorProceso		= Indica la parte del proceso que será ejecutada.

	</Entradas>
	<Salidas>
			@psRespuesta			= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>21/06/2013</Fecha>
	<Requerimiento>
			Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-21537427
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>01/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garantía es 
				11, 38 o 43. 
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Problemas en la acualización de campo calculados en el sistema BCRGarantías, Incidente: 2015081410448079</Requerimiento>
			<Fecha>18/08/2015</Fecha>
			<Descripción>
				Se realiza una ajuste con el fin de contemplar los registros que, según el tipo de bien, no se le ha calculado los montos.
				También se incorporan dos reglas de negocio que estaban contempladas en la aplicación, pero a nivel de este proceso no.  
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00025 Segmentación campos % aceptacion Terreno y No terreno</Requerimiento>
			<Fecha>21/09/2015</Fecha>
			<Descripción>
				Se incorpora el cálculo de los porcentajes de aceptación de terreno y no terreno calculado.
				Adicionalmente se agrega el parámetro de entrada "@piIndicadorProceso", se segmenta la ejecución del procedimiento almacenado
				y se elimina la parte referente a la actualización de datos del avalúo, esto porque el proceso de "CargarContratosVencidos" ejecuta 
				dicha parte, por lo que los datos al momento de ejecutarse este proceso ya se encuentran actualizados.
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
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish

	/*Se declaran las variables y se setean*/
	DECLARE	
			@viCatParametrosCalculo		SMALLINT, -- Catálogo de los parámetros usados para le cálculo del monto de la tasación actualizada del no terreno = 28.
			@vdPorcentajeInferior		DECIMAL(5,2), -- Porcentaje correpondiente al límite inferior.
			@vdPorcentajeIntermedio		DECIMAL(5,2), -- Porcentaje correpondiente al límite intermedio.
			@vdPorcentajeSuperior		DECIMAL(5,2), -- Porcentaje correpondiente al límite superior.
			@viAnnoInferior				SMALLINT, -- Año correpondiente al límite inferior.
			@viAnnoIntermedio			SMALLINT, -- Año correpondiente al límite intermedio.
			@vdtFechaActual				DATETIME, -- Corresponde a la fecha actual del sistema.
			@viCantidadRegistros		BIGINT,   -- Cantidad de registros que posee la estructura a la cual se recorrera.
			@viContador					BIGINT,   -- Contador utilizado dentro del ciclo que permite recorrer la estructura que posee los registros del cálculo de montos.
			@vdtFechaAvaluo				DATETIME, -- Fecha inicial de la función que obtene la lista de fechas de los semestres a evaluar.
			@vdtFechaFinal				DATETIME, -- Fecha final de la función que obtene la lista de fechas de los semestres a evaluar.
			@viGarantiaReal				BIGINT,	  -- Consecutivo de la garantía a la que se le obtendrá la lista de semestres a evaluar.
			@viEjecucionProceso			INT,		-- Consecutivo asignado al proceso ejecutado.
			@viEjecucionProcesoDetalle	SMALLINT,	-- Consecutivo asignado al detalle del proceso ejecutado.
			@vsCodigo_Proceso			VARCHAR(20), -- Código del proceso.
			@vbRegistroActivo			BIT, --Determina si el registro a evaluar se encuentra activo o no.
			@viConsecutivo				BIGINT, --Se usa para generar los códigos de la tabla temporal de números.
			@dtFechaMinimaAvaluo		DATETIME, --Fecha del avalúo más viejo.
			@dtFechaMaximaAvaluo		DATETIME, --FEcha del avalúo más reciente.
			@viMesesAgregar				INT, --Cantidad máxima de meses que serán agregados con el fin de obtener la lista de semestres involucrados en el cálculo.
			@viFechaActualEntera		INT, --Corresponde al a fecha actual en formato numérico.
			@vdtFechaActualHora			DATETIME --Corresponde a la fecha actual con hora.
			
	DECLARE @TMP_GARANTIAS_REALES_X_OPERACION TABLE (	Cod_Llave								BIGINT		IDENTITY(1,1),
														Cod_Contabilidad						TINYINT,
														Cod_Oficina								SMALLINT,
														Cod_Moneda								TINYINT,
														Cod_Producto							TINYINT,
														Operacion								DECIMAL (7,0),
														Cod_Operacion							BIGINT,
														Cod_Garantia_Real						BIGINT,
														Cod_Tipo_Garantia_real					TINYINT,
														Cod_Tipo_Operacion						TINYINT,
														Cod_Bien								VARCHAR(25)	COLLATE database_default,
														Codigo_Partido							SMALLINT,
														Numero_Finca							VARCHAR(25)	COLLATE database_default,
														Num_Placa_Bien							VARCHAR(25)	COLLATE database_default,
														Clase_Garantia							SMALLINT,
														Fecha_Valuacion							DATETIME,
														Monto_Ultima_Tasacion_Terreno			MONEY	,
														Monto_Ultima_Tasacion_No_Terreno		MONEY	,
														Monto_Tasacion_Actualizada_Terreno		MONEY	,
														Monto_Tasacion_Actualizada_No_Terreno	MONEY	,
														Monto_Total_Avaluo						MONEY	,
														Penultima_Fecha_Valuacion				DATETIME,
														Fecha_Actual							DATETIME,
														Fecha_Avaluo_SICC						DATETIME,
														Monto_Avaluo_SICC						DECIMAL(14,2),
														Fecha_Proximo_Calculo					DATETIME,
														Tipo_Bien								SMALLINT,
														Porcentaje_Aceptacion_Parametrizado		DECIMAL(5,2),
														Porcentaje_Aceptacion_Terreno			DECIMAL(5,2),
														Porcentaje_Aceptacion_No_Terreno		DECIMAL(5,2),
														Porcentaje_Aceptacion_Terreno_Calculado	DECIMAL(5,2),
														Porcentaje_Aceptacion_No_Terreno_Calculado	DECIMAL(5,2),
														Cod_Usuario								VARCHAR (30)	COLLATE database_default
														PRIMARY KEY (Cod_Llave)
													)


	DECLARE @ERRORES_TRANSACCIONALES TABLE	(
												Codigo_Error		TINYINT,
												Descripcion_Error	VARCHAR(4000) COLLATE database_default
											)

	DECLARE @NUMEROS TABLE (Consecutivo BIGINT IDENTITY(1,1),
							Campo_vacio	CHAR(8)
							PRIMARY KEY (Consecutivo)) --Se utilizará para generar los semestres a ser calculados
						
					
	--Inicialización de variables
	SET	@viConsecutivo = 1
	
	SET @viCatParametrosCalculo		= 28

	SET @vdPorcentajeInferior = (SELECT		MIN(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P','')))) 
								 FROM		dbo.CAT_ELEMENTO 
								 WHERE		cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%P')

	SET @vdPorcentajeSuperior = (SELECT		MAX(CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))))  
								 FROM		dbo.CAT_ELEMENTO 
								 WHERE		cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%P')

	SET @vdPorcentajeIntermedio = (SELECT	CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) 
								   FROM		dbo.CAT_ELEMENTO 
								   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) > @vdPorcentajeInferior
									AND CONVERT(DECIMAL(5,2), (REPLACE(RTRIM(LTRIM(cat_campo)),'P',''))) < @vdPorcentajeSuperior
									AND cat_campo LIKE '%P')


	SET @viAnnoInferior = (SELECT	MIN(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
						   FROM		dbo.CAT_ELEMENTO 
						   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%A')

	SET @viAnnoIntermedio = (SELECT	MAX(CONVERT(SMALLINT, (REPLACE(RTRIM(LTRIM(cat_campo)),'A','')))) 
						   FROM		dbo.CAT_ELEMENTO 
						   WHERE	cat_catalogo = @viCatParametrosCalculo
									AND cat_campo LIKE '%A')

	SET @vsCodigo_Proceso = 'CALCULAR_MTAT_MTANT'
	
	SET @vdtFechaActual = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)

	SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))
	
	SET @vdtFechaActualHora = GETDATE()
	
	--Se carga la tabla temporal de consecutivos
	WHILE	@viConsecutivo <=20000
	BEGIN
		INSERT INTO @NUMEROS (Campo_vacio) VALUES(@viConsecutivo)
		SET @viConsecutivo = @viConsecutivo + 1
	END

	---------------------------------------------------------------------------------------------------------------------------
	---- SE INICIALIZAN LAS ESTRUCTURAS FISICAS UTILIZADAS
	---------------------------------------------------------------------------------------------------------------------------
	IF(@piIndicadorProceso = 1)
	BEGIN

		/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
		DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario		= @psCedula_Usuario

		DELETE	FROM dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario	= @psCedula_Usuario

		DELETE	FROM dbo.TMP_GARANTIAS_REALES_X_OPERACION 
		WHERE	Codigo_Usuario	= @psCedula_Usuario

	END
	
	---------------------------------------------------------------------------------------------------------------------------
	---- SE OBTIENEN LOS REGISTROS QUE SERÁN CANDIDATOS AL CALCULO
	---------------------------------------------------------------------------------------------------------------------------
	IF(@piIndicadorProceso = 2)
	BEGIN	
		/************************************************************************************************
		 *                                                                                              * 
		 *                       INICIO DEL FILTRADO DE LAS GARANTIAS REALES                            *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/

		/*Se selecciona la información de la garantía real asociada a las operaciones*/
		INSERT INTO dbo.TMP_GARANTIAS_REALES_OPERACIONES (Codigo_Operacion, Codigo_Garantia_Real, Codigo_Contabilidad, 
			Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Tipo_Bien, Codigo_Tipo_Mitigador, 
			Codigo_Tipo_Documento_Legal, Codigo_Inscripcion, Codigo_Tipo_Garantia_Real, Codigo_Estado, 
			Codigo_Grado_Gravamen, Codigo_Clase_Garantia, Codigo_Partido, Codigo_Tipo_Garantia, Codigo_Tipo_Operacion, 
			Indicador_Duplicidad, Porcentaje_Responsabilidad, Monto_Mitigador, Codigo_Grado, Codigo_Clase_Bien, 
			Cedula_Hipotecaria, Codigo_Bien, Fecha_Presentacion, Fecha_Constitucion, Numero_Finca, 
			Numero_Placa_Bien, Codigo_Usuario)
		SELECT	DISTINCT 
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			1 AS Codigo_Contabilidad, 
			ROV.cod_oficina, 
			ROV.cod_moneda, 
			ROV.cod_producto, 
			ROV.num_operacion AS Operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS Codigo_Tipo_Bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS Codigo_Tipo_Mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS Codigo_Tipo_Documento_Legal,
			COALESCE(GRO.cod_inscripcion, -1) AS Codigo_Inscripcion, 
			GGR.cod_tipo_garantia_real,
			1 AS Codigo_Estado,
			COALESCE(GRO.cod_grado_gravamen, -1) AS Codigo_Grado_Gravamen,
			GGR.cod_clase_garantia,
			COALESCE(GGR.cod_partido, 0) AS Codigo_Partido,
			GGR.cod_tipo_garantia,
			1 AS Codigo_Tipo_Operacion,
			1 AS Indicador_Duplicidad,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS Porcentaje_Responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS Monto_Mitigador,
			COALESCE(GGR.cod_grado,'') AS Codigo_Grado,
			COALESCE(GGR.cod_clase_bien,'') AS Codigo_Clase_Bien,
			COALESCE(GGR.cedula_hipotecaria,'') AS Cedula_Hipotecaria,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END AS Codigo_Bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Presentacion,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Constitucion, 
			COALESCE(GGR.numero_finca,'') AS Numero_Finca,
			COALESCE(GGR.num_placa_bien,'') AS Numero_Placa_Bien,
			@psCedula_Usuario AS Codigo_Usuario
		FROM	dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO  
			ON ROV.cod_operacion		= GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR  
			ON GRO.cod_garantia_real	= GGR.cod_garantia_real 
		WHERE	ROV.cod_tipo_operacion	= 1
			AND GRO.cod_estado			= 1
		ORDER	BY
				ROV.cod_operacion,
				Numero_Finca,
				Codigo_Grado,
				Codigo_Clase_Bien,
				Numero_Placa_Bien,
				Codigo_Tipo_Documento_Legal DESC

		/*Se selecciona la información de la garantía real asociada a los contratos*/
		INSERT INTO dbo.TMP_GARANTIAS_REALES_OPERACIONES (Codigo_Operacion, Codigo_Garantia_Real, Codigo_Contabilidad, 
			Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Tipo_Bien, Codigo_Tipo_Mitigador, 
			Codigo_Tipo_Documento_Legal, Codigo_Inscripcion, Codigo_Tipo_Garantia_Real, Codigo_Estado, 
			Codigo_Grado_Gravamen, Codigo_Clase_Garantia, Codigo_Partido, Codigo_Tipo_Garantia, Codigo_Tipo_Operacion, 
			Indicador_Duplicidad, Porcentaje_Responsabilidad, Monto_Mitigador, Codigo_Grado, Codigo_Clase_Bien, 
			Cedula_Hipotecaria, Codigo_Bien, Fecha_Presentacion, Fecha_Constitucion, Numero_Finca, 
			Numero_Placa_Bien, Codigo_Usuario)
		SELECT	DISTINCT 
			ROV.cod_operacion,
			GGR.cod_garantia_real,
			1 AS Codigo_Contabilidad, 
			ROV.cod_oficina_contrato, 
			ROV.cod_moneda_contrato, 
			ROV.cod_producto_contrato, 
			ROV.num_contrato AS Operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS Codigo_Tipo_Bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS Codigo_Tipo_Mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS Codigo_Tipo_Documento_Legal,
			COALESCE(GRO.cod_inscripcion, -1) AS Codigo_Inscripcion, 
			GGR.cod_tipo_garantia_real,
			1 AS Codigo_Estado,
			COALESCE(GRO.cod_grado_gravamen, -1) AS Codigo_Grado_Gravamen,
			GGR.cod_clase_garantia,
			COALESCE(GGR.cod_partido, 0) AS Codigo_Partido,
			GGR.cod_tipo_garantia,
			2 AS Codigo_Tipo_Operacion,
			1 AS Indicador_Duplicidad,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS Porcentaje_Responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS Monto_Mitigador,
			COALESCE(GGR.cod_grado,'') AS Codigo_Grado,
			COALESCE(GGR.cod_clase_bien,'') AS Codigo_Clase_Bien,
			COALESCE(GGR.cedula_hipotecaria,'') AS Cedula_Hipotecaria,
			CASE 
				WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
				WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
				WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
			END	AS Codigo_Bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Presentacion,
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Constitucion, 
			COALESCE(GGR.numero_finca,'') AS Numero_Finca,
			COALESCE(GGR.num_placa_bien,'') AS Numero_Placa_Bien,
			@psCedula_Usuario AS Codigo_Usuario
		FROM	dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO  
			ON ROV.cod_operacion		= GRO.cod_operacion 
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR  
			ON GRO.cod_garantia_real	= GGR.cod_garantia_real 
		WHERE	ROV.cod_tipo_operacion = 2
			AND EXISTS	(	SELECT	1
							FROM	dbo.GAR_SICC_PRMGT GSP 
							WHERE	GSP.prmgt_pnu_oper   = ROV.num_contrato
								AND GSP.prmgt_pco_ofici  = ROV.cod_oficina_contrato
								AND GSP.prmgt_pco_moned  = ROV.cod_moneda_contrato
								AND GSP.prmgt_pco_produ  = 10
								AND GSP.prmgt_pco_conta	 = 1
								AND COALESCE(GSP.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
								AND COALESCE(GSP.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
								AND GSP.prmgt_pcoclagar  = GGR.cod_clase_garantia
								AND GSP.prmgt_pco_grado  = COALESCE(GGR.cod_grado, GSP.prmgt_pco_grado)
								AND GSP.prmgt_estado     = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura 
																  del SICC*/
		ORDER	BY
				ROV.cod_operacion,
				Numero_Finca,
				Codigo_Grado,
				Codigo_Clase_Bien,
				Numero_Placa_Bien,
				Codigo_Tipo_Documento_Legal DESC

		/*Se obtienen las operaciones duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion,
				Codigo_Tipo_Operacion, 
				Codigo_Bien AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@psCedula_Usuario AS cod_usuario,
				MAX(Codigo_Garantia_Real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario				= @psCedula_Usuario
			AND ((Codigo_Tipo_Operacion = 1) OR (Codigo_Tipo_Operacion = 2))
		GROUP	BY 
				Codigo_Oficina, 
				Codigo_Moneda,
				Codigo_Producto, 
				Operacion, 
				Codigo_Bien, 
				Codigo_Tipo_Operacion
		HAVING	COUNT(1) > 1

		/*Se cambia el código del campo ind_duplicidad a 2, indicando con esto que la operación se encuentra duplicada.
		  Se toma en cuenta el valor de varios campos para poder determinar si el registro se encuentra duplicado.*/
		UPDATE	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		SET		Indicador_Duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR
		WHERE	EXISTS	(	SELECT	1 
							FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD 
							WHERE	COALESCE(TGR.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
								AND TOD.cod_tipo_garantia			= 2
								AND ((TOD.cod_tipo_operacion		= 1)
									OR (TOD.cod_tipo_operacion		= 2))
								AND TGR.Codigo_Oficina				= TOD.cod_oficina
								AND TGR.Codigo_Moneda				= TOD.cod_moneda
								AND TGR.Codigo_Producto				= TOD.cod_producto
								AND TGR.Operacion					= TOD.operacion
								AND COALESCE(TGR.Codigo_Bien, '')		= COALESCE(TOD.cod_garantia_sicc, '')
								AND TGR.Codigo_Tipo_Documento_Legal	IS NULL
								AND TGR.Fecha_Presentacion			IS NULL
								AND TGR.Codigo_Tipo_Mitigador		IS NULL
								AND TGR.Codigo_Inscripcion			IS NULL)
			AND TGR.Codigo_Usuario				= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion		= 1)
				OR (TGR.Codigo_Tipo_Operacion	= 2))


		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario			= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 1 
			AND Indicador_Duplicidad	= 2 

		DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario			= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 2 
			AND Indicador_Duplicidad	= 2 

		/*Se eliminan los duplicados obtenidos*/
		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 1

		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 2


		/************************************************************************************************
		 *                                                                                              * 
		 *                       INICIO DE LA SELECCIÓN DE HIPOTECAS COMUNES                            *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/

		/*Se obtienen las garantías reales de hipoteca común duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion,
				Codigo_Tipo_Operacion, 
				Numero_Finca AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@psCedula_Usuario AS cod_usuario,
				MAX(Codigo_Garantia_Real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario				= @psCedula_Usuario 
			AND Codigo_Tipo_Garantia_Real	= 1
			AND ((Codigo_Tipo_Operacion		= 1)
				OR (Codigo_Tipo_Operacion	= 2))
		GROUP	BY 
				Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion, 
				Numero_Finca, 
				Codigo_Tipo_Operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
			cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = GR1.Codigo_Llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES_OPERACIONES GR1
			ON GR1.Codigo_Oficina				= TOD.cod_oficina
			AND GR1.Codigo_Moneda				= TOD.cod_moneda
			AND GR1.Codigo_Producto				= TOD.cod_producto
			AND GR1.Operacion					= TOD.operacion
			AND COALESCE(GR1.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	GR1.Codigo_Llave =	(	SELECT	MIN(GR2.Codigo_Llave)
										FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES GR2 
										WHERE	GR2.Codigo_Oficina				= TOD.cod_oficina
											AND GR2.Codigo_Moneda				= TOD.cod_moneda
											AND GR2.Codigo_Producto				= TOD.cod_producto
											AND GR2.Operacion					= TOD.operacion
											AND COALESCE(GR2.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
											AND GR2.Codigo_Tipo_Garantia_Real	= 1
											AND COALESCE(GR2.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
											AND ((GR2.Codigo_Tipo_Operacion		= 1)
												OR (GR2.Codigo_Tipo_Operacion	= 2))
											AND TOD.cod_tipo_garantia			= 2)
			AND GR1.Codigo_Tipo_Garantia_Real	= 1
			AND GR1.Codigo_Usuario				= @psCedula_Usuario
			AND ((GR1.Codigo_Tipo_Operacion		= 1)
				OR (GR1.Codigo_Tipo_Operacion	= 2))

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		SET		Indicador_Duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD 
						WHERE	COALESCE(TOD.cod_usuario, '')			= COALESCE(TGR.Codigo_Usuario, '')
							AND TOD.cod_tipo_garantia				= TGR.Codigo_Tipo_Garantia
							AND TOD.cod_tipo_operacion				= TGR.Codigo_Tipo_Operacion
							AND TOD.cod_oficina						= TGR.Codigo_Oficina
							AND TOD.cod_moneda						= TGR.Codigo_Moneda
							AND TOD.cod_producto					= TGR.Codigo_Producto
							AND TOD.operacion						= TGR.Operacion
							AND COALESCE(TOD.cod_garantia_sicc, '')	= COALESCE(TGR.Numero_Finca, '')
							AND TOD.cod_garantia					<> TGR.Codigo_Llave
							AND TGR.Codigo_Tipo_Garantia_Real		= 1)
			AND TGR.Codigo_Tipo_Garantia_Real		= 1
			AND TGR.Codigo_Usuario					= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion			= 1)
				OR (TGR.Codigo_Tipo_Operacion		= 2))

		/*Se eliminan los duplicados obtenidos*/
		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 1

		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 2


		/************************************************************************************************
		 *                                                                                              * 
		 *                     INICIO DE LA SELECCIÓN DE CEDULAS HIPOTECARIAS                           *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/

		/*Se obtienen las garantías reales de cédulas hipotecarias duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion,
				Codigo_Tipo_Operacion, 
				Numero_Finca AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@psCedula_Usuario AS cod_usuario,
				MAX(Codigo_Garantia_Real) AS cod_garantia,
				Codigo_Grado
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Tipo_Garantia_Real	= 2
			AND Codigo_Usuario				= @psCedula_Usuario
			AND ((Codigo_Tipo_Operacion		= 1)
				OR (Codigo_Tipo_Operacion	= 2))
		GROUP	BY 
				Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion, 
				Numero_Finca, 
				Codigo_Grado,
				Codigo_Tipo_Operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = GR1.Codigo_Llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES_OPERACIONES GR1 
			ON GR1.Codigo_Oficina				= TOD.cod_oficina
			AND GR1.Codigo_Moneda				= TOD.cod_moneda
			AND GR1.Codigo_Producto				= TOD.cod_producto
			AND GR1.Operacion					= TOD.operacion
			AND COALESCE(GR1.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
			AND GR1.Codigo_Grado				= TOD.cod_grado
		WHERE	GR1.Codigo_Llave =	(	SELECT	MIN(GR2.Codigo_Llave)
										FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES GR2 
										WHERE	GR2.Codigo_Oficina				= TOD.cod_oficina
											AND GR2.Codigo_Moneda				= TOD.cod_moneda
											AND GR2.Codigo_Producto				= TOD.cod_producto
											AND GR2.Operacion					= TOD.operacion
											AND COALESCE(GR2.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
											AND GR2.Codigo_Grado				= TOD.cod_grado
											AND GR2.Codigo_Tipo_Garantia_Real	= 2
											AND COALESCE(GR2.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
											AND ((GR2.Codigo_Tipo_Operacion		= 1)
												OR (GR2.Codigo_Tipo_Operacion	= 2))
											AND TOD.cod_tipo_garantia			= 2)
			AND GR1.Codigo_Tipo_Garantia_Real	= 2
			AND GR1.Codigo_Usuario				= @psCedula_Usuario
			AND ((GR1.Codigo_Tipo_Operacion		= 1)
				OR (GR1.Codigo_Tipo_Operacion	= 2))


		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		SET		Indicador_Duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR
		WHERE	EXISTS	(	SELECT	1 
							FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD 
							WHERE	COALESCE(TOD.cod_usuario, '')			= COALESCE(TGR.Codigo_Usuario, '')
								AND TOD.cod_tipo_garantia				= TGR.Codigo_Tipo_Garantia
								AND TOD.cod_tipo_operacion				= TGR.Codigo_Tipo_Operacion
								AND TOD.cod_oficina						= TGR.Codigo_Oficina
								AND TOD.cod_moneda						= TGR.Codigo_Moneda
								AND TOD.cod_producto					= TGR.Codigo_Producto
								AND TOD.operacion						= TGR.Operacion
								AND COALESCE(TOD.cod_garantia_sicc, '')	= COALESCE(TGR.Numero_Finca, '')
								AND TOD.cod_grado						= TGR.Codigo_Grado
								AND TOD.cod_garantia					<> TGR.Codigo_Llave
								AND TGR.Codigo_Tipo_Garantia_Real		= 2)
			AND TGR.Codigo_Tipo_Garantia_Real	= 2
			AND TGR.Codigo_Usuario				= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion		= 1)
				OR (TGR.Codigo_Tipo_Operacion	= 2))

		/*Se eliminan los duplicados obtenidos*/
		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 1

		DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
		WHERE	cod_usuario			= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 2

		/************************************************************************************************
		 *                                                                                              * 
		 *                              INICIO DE LA SELECCIÓN DE PRENDAS                               *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/

		/*Se obtienen las garantías reales de prenda duplicadas*/
		INSERT	INTO dbo.TMP_OPERACIONES_DUPLICADAS
		SELECT	Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion,
				Codigo_Tipo_Operacion, 
				Numero_Placa_Bien AS cod_garantia_sicc,
				2 AS cod_tipo_garantia,
				@psCedula_Usuario AS cod_usuario,
				MAX(Codigo_Garantia_Real) AS cod_garantia,
				NULL AS cod_grado
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Tipo_Garantia_Real	= 3
			AND Codigo_Usuario				= @psCedula_Usuario
			AND ((Codigo_Tipo_Operacion		= 1)
				OR (Codigo_Tipo_Operacion	= 2))
		GROUP	BY 
				Codigo_Oficina, 
				Codigo_Moneda, 
				Codigo_Producto, 
				Operacion, 
				Numero_Placa_Bien, 
				Codigo_Tipo_Operacion
		HAVING	COUNT(1) > 1

		/*Al estar ordenados los registros, se toma el que posee el valor autogenerado menor, ya que esto es lo que haría el 
		  cursor, tomaría el primer registro que encuentre y los demás los descarta.*/
		UPDATE	dbo.TMP_OPERACIONES_DUPLICADAS
		SET		cod_garantia = GR1.Codigo_Llave
		FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD
			INNER JOIN dbo.TMP_GARANTIAS_REALES_OPERACIONES GR1 
			ON GR1.Codigo_Oficina					= TOD.cod_oficina
			AND GR1.Codigo_Moneda					= TOD.cod_moneda
			AND GR1.Codigo_Producto					= TOD.cod_producto
			AND GR1.Operacion						= TOD.operacion
			AND COALESCE(GR1.Numero_Placa_Bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
		WHERE	GR1.Codigo_Llave =	(	SELECT	MIN(GR2.Codigo_Llave)
										FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES GR2 
										WHERE	GR2.Codigo_Oficina					= TOD.cod_oficina
											AND GR2.Codigo_Moneda					= TOD.cod_moneda
											AND GR2.Codigo_Producto					= TOD.cod_producto
											AND GR2.Operacion						= TOD.operacion
											AND COALESCE(GR2.Numero_Placa_Bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
											AND GR2.Codigo_Tipo_Garantia_Real		= 3
											AND COALESCE(GR2.Codigo_Usuario, '')		= COALESCE(TOD.cod_usuario, '')
											AND ((GR2.Codigo_Tipo_Operacion			= 1)
												OR (GR2.Codigo_Tipo_Operacion		= 2))
											AND TOD.cod_tipo_garantia				= 2)
			AND GR1.Codigo_Tipo_Garantia_Real	= 3
			AND GR1.Codigo_Usuario				= @psCedula_Usuario
			AND ((GR1.Codigo_Tipo_Operacion		= 1)
				OR (GR1.Codigo_Tipo_Operacion	= 2))

		/*Se eliminan los duplicados que sean diferentes al código de garantía actualizado anteriormente*/
		UPDATE	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		SET		Indicador_Duplicidad = 2
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR
		WHERE	EXISTS (SELECT	1 
						FROM	dbo.TMP_OPERACIONES_DUPLICADAS TOD 
						WHERE	COALESCE(TOD.cod_usuario, '')			= COALESCE(TGR.Codigo_Usuario, '')
							AND TOD.cod_tipo_garantia				= TGR.Codigo_Tipo_Garantia
							AND TOD.cod_tipo_operacion				= TGR.Codigo_Tipo_Operacion
							AND TOD.cod_oficina						= TGR.Codigo_Oficina
							AND TOD.cod_moneda						= TGR.Codigo_Moneda
							AND TOD.cod_producto					= TGR.Codigo_Producto
							AND TOD.operacion						= TGR.Operacion
							AND COALESCE(TOD.cod_garantia_sicc, '')	= COALESCE(TGR.Numero_Placa_Bien, '')
							AND TOD.cod_garantia					<> TGR.Codigo_Llave
							AND TGR.Codigo_Tipo_Garantia_Real		= 3)
			AND TGR.Codigo_Tipo_Garantia_Real	= 3
			AND TGR.Codigo_Usuario				= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion		= 1)
				OR (TGR.Codigo_Tipo_Operacion	= 2))

		/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
		DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario			= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 1 
			AND Indicador_Duplicidad	= 2 

		DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		WHERE	Codigo_Usuario			= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 2 
			AND Indicador_Duplicidad	= 2 
				
		/************************************************************************************************
		 *                                                                                              * 
		 *                         INICIO DE LA EXCLUSIÓN DE GARANTÍAS                                  *
		 *                                                                                              *
		 ************************************************************************************************/

		----Se excluyen aquellas garantías cuyo tipo de bien sea diferente de 1 (Terrenos) ó 2 (Edificaciones)
		--DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		--WHERE	Codigo_Usuario			= @psCedula_Usuario
		--	AND Codigo_Tipo_Operacion	= 1 
		--	AND ((Codigo_Tipo_Bien		< 1)
		--		OR (Codigo_Tipo_Bien	> 2))

		--DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
		--WHERE	Codigo_Usuario			= @psCedula_Usuario
		--	AND Codigo_Tipo_Operacion	= 2 
		--	AND ((Codigo_Tipo_Bien		< 1)
		--		OR (Codigo_Tipo_Bien	> 2))
		
		

		/************************************************************************************************
		 *                                                                                              * 
		 *                         INICIO DE LA SELECCIÓN DE GARANTÍAS                                  *
		 *                                                                                              *
		 ************************************************************************************************/
		--Se ingresan los datos de las garantías filtradas
		INSERT INTO @TMP_GARANTIAS_REALES_X_OPERACION 
		(Cod_Contabilidad, Cod_Oficina, Cod_Moneda, Cod_Producto, Operacion, Cod_Operacion, 
		 Cod_Garantia_Real, Cod_Tipo_Garantia_real, Cod_Tipo_Operacion, Cod_Bien, Codigo_Partido, Numero_Finca, 
		 Num_Placa_Bien, Clase_Garantia, Fecha_Valuacion, Monto_Ultima_Tasacion_Terreno, Monto_Ultima_Tasacion_No_Terreno,  
		 Monto_Tasacion_Actualizada_Terreno, Monto_Tasacion_Actualizada_No_Terreno, 
		 Monto_Total_Avaluo, Penultima_Fecha_Valuacion, Fecha_Actual, Fecha_Avaluo_SICC, Monto_Avaluo_SICC,
		 Fecha_Proximo_Calculo, Tipo_Bien, Cod_Usuario)
		SELECT	DISTINCT 
				TGR.Codigo_Contabilidad, 			
				TGR.Codigo_Oficina, 		
				TGR.Codigo_Moneda, 	
				TGR.Codigo_Producto, 		
				TGR.Operacion, 
				TGR.Codigo_Operacion,				
				GGR.cod_garantia_real, 			
				GGR.cod_tipo_garantia_real, 
				TGR.Codigo_Tipo_Operacion,		
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
				END														AS Cod_Bien, 
				COALESCE(GGR.cod_partido, 0)							AS Codigo_Partido, 
				COALESCE(GGR.numero_finca,'')							AS Numero_Finca, 
				COALESCE(GGR.num_placa_bien,'')							AS Num_Placa_Bien, 
				TGR.Codigo_Clase_Garantia								AS Clase_Garantia,
				COALESCE(GRV.fecha_valuacion,'19000101')				AS Fecha_Valuacion,
				COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS Monto_Ultima_Tasacion_Terreno,
				COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)		AS Monto_Ultima_Tasacion_No_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS Monto_Tasacion_Actualizada_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS Monto_Tasacion_Actualizada_No_Terreno,
				(COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))	
																		AS Monto_Total_Avaluo,
				NULL													AS Penultima_Fecha_Valuacion,
				GETDATE()												AS Fecha_Actual,
				GRO.Fecha_Valuacion_SICC,
				GRV.monto_total_avaluo,
				NULL,
				TGR.Codigo_Tipo_Bien,
				TGR.Codigo_Usuario
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GRO.cod_operacion		= TGR.Codigo_Operacion
			AND GRO.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GGR.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real = GRO.cod_garantia_real
		WHERE	TGR.Codigo_Usuario					= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion			= 1)
				OR (TGR.Codigo_Tipo_Operacion		= 2))
			AND ((TGR.Codigo_Tipo_Bien				= 1)
				OR (TGR.Codigo_Tipo_Bien			= 2))
			AND GRV.Indicador_Tipo_Registro			= 1
			AND GRV.fecha_valuacion					= GRO.Fecha_Valuacion_SICC
			AND GRV.Indicador_Actualizado_Calculo	= 0
			AND GRV.Fecha_Semestre_Calculado		IS NULL

		UNION ALL
			
		SELECT	DISTINCT
				TGR.Codigo_Contabilidad, 			
				TGR.Codigo_Oficina, 		
				TGR.Codigo_Moneda, 	
				TGR.Codigo_Producto, 		
				TGR.Operacion, 
				TGR.Codigo_Operacion,				
				GGR.cod_garantia_real, 			
				GGR.cod_tipo_garantia_real, 
				TGR.Codigo_Tipo_Operacion,		
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
				END	  													AS Cod_Bien, 
				COALESCE(GGR.cod_partido, 0)							AS Codigo_Partido, 
				COALESCE(GGR.numero_finca,'')							AS Numero_Finca, 
				COALESCE(GGR.num_placa_bien,'')							AS Num_Placa_Bien, 
				TGR.Codigo_Clase_Garantia								AS Clase_Garantia,
				COALESCE(GRV.fecha_valuacion,'19000101')				AS Fecha_Valuacion,
				COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS Monto_Ultima_Tasacion_Terreno,
				COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)		AS Monto_Ultima_Tasacion_No_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS Monto_Tasacion_Actualizada_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS Monto_Tasacion_Actualizada_No_Terreno,
				(COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))	
																		AS Monto_Total_Avaluo,
				NULL													AS Penultima_Fecha_Valuacion,
				GETDATE()												AS Fecha_Actual,
				GRO.Fecha_Valuacion_SICC,
				GRV.monto_total_avaluo,
				NULL,
				TGR.Codigo_Tipo_Bien,
				TGR.Codigo_Usuario
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GRO.cod_operacion		= TGR.Codigo_Operacion
			AND GRO.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GGR.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real	= GRO.cod_garantia_real
		WHERE	TGR.Codigo_Usuario					= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion			= 1)
				OR (TGR.Codigo_Tipo_Operacion		= 2))
			AND ((TGR.Codigo_Tipo_Bien				= 1)
				OR (TGR.Codigo_Tipo_Bien			= 2))
			AND GRV.Indicador_Tipo_Registro			= 1
			AND GRV.Indicador_Actualizado_Calculo	= 1
			AND GRV.fecha_valuacion					= GRO.Fecha_Valuacion_SICC
			AND GRV.Fecha_Semestre_Calculado		IS NOT NULL
			AND 6 <= dbo.ObtenerDiferenciaMeses(GRV.Fecha_Semestre_Calculado, @vdtFechaActual)

		UNION ALL
			
		SELECT	DISTINCT
				TGR.Codigo_Contabilidad, 			
				TGR.Codigo_Oficina, 		
				TGR.Codigo_Moneda, 	
				TGR.Codigo_Producto, 		
				TGR.Operacion, 
				TGR.Codigo_Operacion,				
				GGR.cod_garantia_real, 			
				GGR.cod_tipo_garantia_real, 
				TGR.Codigo_Tipo_Operacion,		
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
				END	  													AS Cod_Bien, 
				COALESCE(GGR.cod_partido, 0)							AS Codigo_Partido, 
				COALESCE(GGR.numero_finca,'')							AS Numero_Finca, 
				COALESCE(GGR.num_placa_bien,'')							AS Num_Placa_Bien, 
				TGR.Codigo_Clase_Garantia								AS Clase_Garantia,
				COALESCE(GRV.fecha_valuacion,'19000101')				AS Fecha_Valuacion,
				COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS Monto_Ultima_Tasacion_Terreno,
				COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)		AS Monto_Ultima_Tasacion_No_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS Monto_Tasacion_Actualizada_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS Monto_Tasacion_Actualizada_No_Terreno,
				(COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))	
																		AS Monto_Total_Avaluo,
				NULL													AS Penultima_Fecha_Valuacion,
				GETDATE()												AS Fecha_Actual,
				GRO.Fecha_Valuacion_SICC,
				GRV.monto_total_avaluo,
				NULL,
				TGR.Codigo_Tipo_Bien,
				TGR.Codigo_Usuario
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GRO.cod_operacion		= TGR.Codigo_Operacion
			AND GRO.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GGR.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real	= GRO.cod_garantia_real
		WHERE	TGR.Codigo_Usuario					= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion			= 1)
				OR (TGR.Codigo_Tipo_Operacion		= 2))
			AND TGR.Codigo_Tipo_Bien				= 1
			AND GRV.Indicador_Tipo_Registro			= 1
			AND GRV.Indicador_Actualizado_Calculo	= 1
			AND GRV.fecha_valuacion					= GRO.Fecha_Valuacion_SICC
			AND GRV.Fecha_Semestre_Calculado		IS NOT NULL
			AND 6 >= dbo.ObtenerDiferenciaMeses(GRV.Fecha_Semestre_Calculado, @vdtFechaActual)
			AND COALESCE(GRV.monto_tasacion_actualizada_terreno, 0) = 0
			
		UNION ALL
			
		SELECT	DISTINCT
				TGR.Codigo_Contabilidad, 			
				TGR.Codigo_Oficina, 		
				TGR.Codigo_Moneda, 	
				TGR.Codigo_Producto, 		
				TGR.Operacion, 
				TGR.Codigo_Operacion,				
				GGR.cod_garantia_real, 			
				GGR.cod_tipo_garantia_real, 
				TGR.Codigo_Tipo_Operacion,		
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN COALESCE(GGR.num_placa_bien,'') 
				END	  													AS Cod_Bien, 
				COALESCE(GGR.cod_partido, 0)							AS Codigo_Partido, 
				COALESCE(GGR.numero_finca,'')							AS Numero_Finca, 
				COALESCE(GGR.num_placa_bien,'')							AS Num_Placa_Bien, 
				TGR.Codigo_Clase_Garantia								AS Clase_Garantia,
				COALESCE(GRV.fecha_valuacion,'19000101')				AS Fecha_Valuacion,
				COALESCE(GRV.monto_ultima_tasacion_terreno, 0)			AS Monto_Ultima_Tasacion_Terreno,
				COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0)		AS Monto_Ultima_Tasacion_No_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_terreno, 0)		AS Monto_Tasacion_Actualizada_Terreno,
				COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0)	AS Monto_Tasacion_Actualizada_No_Terreno,
				(COALESCE(GRV.monto_ultima_tasacion_terreno, 0) + COALESCE(GRV.monto_ultima_tasacion_no_terreno, 0))	
																		AS Monto_Total_Avaluo,
				NULL													AS Penultima_Fecha_Valuacion,
				GETDATE()												AS Fecha_Actual,
				GRO.Fecha_Valuacion_SICC,
				GRV.monto_total_avaluo,
				NULL,
				TGR.Codigo_Tipo_Bien,
				TGR.Codigo_Usuario
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
			INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
			ON GRO.cod_operacion		= TGR.Codigo_Operacion
			AND GRO.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
			ON GGR.cod_garantia_real	= TGR.Codigo_Garantia_Real
			INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real	= GRO.cod_garantia_real
		WHERE	TGR.Codigo_Usuario					= @psCedula_Usuario
			AND ((TGR.Codigo_Tipo_Operacion			= 1)
				OR (TGR.Codigo_Tipo_Operacion		= 2))
			AND TGR.Codigo_Tipo_Bien				= 2
			AND GRV.Indicador_Tipo_Registro			= 1
			AND GRV.Indicador_Actualizado_Calculo	= 1
			AND GRV.fecha_valuacion					= GRO.Fecha_Valuacion_SICC
			AND GRV.Fecha_Semestre_Calculado		IS NOT NULL
			AND 6 >= dbo.ObtenerDiferenciaMeses(GRV.Fecha_Semestre_Calculado, @vdtFechaActual)
			AND ((COALESCE(GRV.monto_tasacion_actualizada_terreno, 0) = 0)
				OR (COALESCE(GRV.monto_tasacion_actualizada_no_terreno, 0) = 0)) 

		
		--Se actualiza la fecha de la penúltima valuación
		UPDATE	@TMP_GARANTIAS_REALES_X_OPERACION
		SET		Penultima_Fecha_Valuacion = COALESCE(GRV.fecha_valuacion,'19000101')
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
			INNER JOIN dbo.GAR_VALUACIONES_REALES GRV 
			ON GRV.cod_garantia_real = TGR.Cod_Garantia_Real
		WHERE	TGR.Cod_Usuario				= @psCedula_Usuario
			AND ((TGR.Cod_Tipo_Operacion	= 1)
				OR (TGR.Cod_Tipo_Operacion	= 2))
			AND GRV.Indicador_Tipo_Registro	= 3
		
	END
	
		
	--Se verifica que los parámetros escenciales se hayan podido obtener, caso contrario el proceso no es ejecutado
	IF((@vdPorcentajeInferior IS NULL) OR (@vdPorcentajeSuperior IS NULL) OR (@vdPorcentajeIntermedio IS NULL)
       OR (@viAnnoInferior IS NULL) OR (@viAnnoIntermedio IS NULL))
	BEGIN
		INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
		SELECT 2, 'Alguno de los parámetros usados por el cálculo del monto de la tasación actualizada del terreno y no terreno calculado no fue obtenido o está mal parametrizado.'
	END
	ELSE
	BEGIN

		/************************************************************************************************
		 *                                                                                              * 
		 *                         INICIO DE LA ACTUALIZACIÓN DE AVALUOS                                *
		 *              (LOS QUE NO CUMPLEN LAS CONDICIONES PARA APLICAR EL CALCULO)                    *
		 *                                                                                              *
		 ************************************************************************************************/

	BEGIN TRANSACTION TRA_Ajustar_Monto1

		--Se actualizan los avalúos cuyo monto de la última tasación del no terreno es igual a 0 (cero), esto para el tipo de bien 2
		UPDATE	dbo.GAR_VALUACIONES_REALES
		SET		monto_tasacion_actualizada_no_terreno = NULL,
				monto_tasacion_actualizada_terreno = NULL
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = TGR.Cod_Garantia_Real
			AND GVR.fecha_valuacion = TGR.Fecha_Valuacion
		WHERE	TGR.Tipo_Bien = 2
			AND COALESCE(TGR.Monto_Ultima_Tasacion_No_Terreno, 0) = 0
			AND TGR.Cod_Usuario = @psCedula_Usuario

		IF (@@ERROR <> 0)
		BEGIN 
			ROLLBACK TRANSACTION TRA_Ajustar_Monto1
			INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
			SELECT 1, 'Se produjo un error al asignar nulo al monto de la tasación actualizada del terreno y no terreno calculado.'
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION TRA_Ajustar_Monto1
		END


		BEGIN TRANSACTION TRA_Ajustar_Monto2

		--Se actualizan los avalúos cuyo monto de la última tasación del terreno es igual a 0 (cero), para los tipos de bien 1 y 2
		UPDATE	dbo.GAR_VALUACIONES_REALES
		SET		monto_tasacion_actualizada_no_terreno = NULL,
				monto_tasacion_actualizada_terreno = NULL
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real = TGR.Cod_Garantia_Real
			AND GVR.fecha_valuacion = TGR.Fecha_Valuacion
		WHERE	COALESCE(TGR.Monto_Ultima_Tasacion_Terreno, 0) = 0
			AND TGR.Cod_Usuario = @psCedula_Usuario

		IF (@@ERROR <> 0)
		BEGIN 
			ROLLBACK TRANSACTION TRA_Ajustar_Monto2
			INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
			SELECT 1, 'Se produjo un error al asignar nulo al monto de la tasación actualizada del terreno y no terreno calculado.'
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION TRA_Ajustar_Monto2
		END
		
		--Se actualizan los avalúos cuya fecha de valuación es diferente a la registrada en el SICC
		BEGIN TRANSACTION TRA_Ajustar_Monto2
		
		UPDATE	dbo.GAR_VALUACIONES_REALES
		SET		monto_tasacion_actualizada_no_terreno	= NULL,
				monto_tasacion_actualizada_terreno		= NULL
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real	= TGR.Cod_Garantia_Real
			AND GVR.fecha_valuacion		= TGR.Fecha_Valuacion
		WHERE	TGR.Cod_Usuario			= @psCedula_Usuario
			AND TGR.Fecha_Avaluo_SICC	IS NOT NULL
			AND TGR.Fecha_Valuacion		> '19000101'
			AND	((GVR.fecha_valuacion	< TGR.Fecha_Avaluo_SICC)
				OR (GVR.fecha_valuacion	> TGR.Fecha_Avaluo_SICC))

		IF (@@ERROR <> 0) 
		BEGIN 
			ROLLBACK TRANSACTION TRA_Ajustar_Monto2
			INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
			SELECT 1, 'Se produjo un error al asignar nulo al monto de la tasación actualizada del terreno y no terreno calculado.'
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION TRA_Ajustar_Monto2
		END
		
		--Se actualizan los avalúos cuyo monto total de la valuación es diferente a la registrada en el SICC
		BEGIN TRANSACTION TRA_Ajustar_Monto3
		
		UPDATE	dbo.GAR_VALUACIONES_REALES
		SET		monto_tasacion_actualizada_no_terreno	= NULL,
				monto_tasacion_actualizada_terreno		= NULL
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
			INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
			ON GVR.cod_garantia_real		= TGR.Cod_Garantia_Real
			AND GVR.fecha_valuacion			= TGR.Fecha_Valuacion
		WHERE	TGR.Cod_Usuario				= @psCedula_Usuario
			AND ((TGR.Monto_Total_Avaluo	< TGR.Monto_Avaluo_SICC)
				OR (TGR.Monto_Total_Avaluo	> TGR.Monto_Avaluo_SICC))

		IF (@@ERROR <> 0) 
		BEGIN 
			ROLLBACK TRANSACTION TRA_Ajustar_Monto3
			INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
			SELECT 1, 'Se produjo un error al asignar nulo al monto de la tasación actualizada del terreno y no terreno calculado.'
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION TRA_Ajustar_Monto3
		END
		

		/************************************************************************************************
		 *                                                                                              * 
		 *                         INICIO DE LA ELIMINACION DE REGISTROS                                *
		 *					 OBTENIDOS Y QUE NO SE LES PUEDE APLICAR EL CALCULO						    *
		 *                                                                                              *
		 ************************************************************************************************/

		DELETE FROM	@TMP_GARANTIAS_REALES_X_OPERACION
		WHERE	COALESCE(Monto_Ultima_Tasacion_Terreno, 0) = 0
			AND Cod_Usuario = @psCedula_Usuario
			
		DELETE FROM	@TMP_GARANTIAS_REALES_X_OPERACION
		WHERE	Tipo_Bien = 2
			AND COALESCE(Monto_Ultima_Tasacion_No_Terreno, 0) = 0
			AND Cod_Usuario = @psCedula_Usuario

		DELETE FROM	@TMP_GARANTIAS_REALES_X_OPERACION
		WHERE	Cod_Usuario			= @psCedula_Usuario
			AND Fecha_Avaluo_SICC	IS NOT NULL
			AND Fecha_Valuacion		> '19000101'
			AND	((Fecha_Valuacion	< Fecha_Avaluo_SICC)
				OR (Fecha_Valuacion	> Fecha_Avaluo_SICC))

		DELETE FROM	@TMP_GARANTIAS_REALES_X_OPERACION
		WHERE	Cod_Usuario				= @psCedula_Usuario	
			AND ((Monto_Total_Avaluo	< Monto_Avaluo_SICC)
				OR (Monto_Total_Avaluo	> Monto_Avaluo_SICC))
		
		/************************************************************************************************
		 *                                                                                              * 
		 *                         INICIO DEL CALCULO DE LOS MONTOS                                     *
		 *                                                                                              *
		 ************************************************************************************************/		
		--Se obtiene la fecha final en la que se debe generar lal ista de semestres, corresponde a la fecha en que se relaiza el cálculo
		SET @vdtFechaFinal = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
		
		--Se obtiene la fecha de valuación más antigua y más reciente
		SELECT	@dtFechaMinimaAvaluo = MIN(Fecha_Valuacion),
				@dtFechaMaximaAvaluo = MAX(Fecha_Valuacion)
		FROM	@TMP_GARANTIAS_REALES_X_OPERACION
		
		--Se obtiene la cantidad de meses máximos a agregar
		SET @viMesesAgregar = ((DATEDIFF(YEAR, @dtFechaMinimaAvaluo, @dtFechaMaximaAvaluo) * 2) + 10)

		--Se ingresan dentro de la tabla temporal, usada por el cálculo, los semestres obtenidos y otra información relevante
		INSERT INTO dbo.TMP_CALCULO_MTAT_MTANT(
				Fecha_Hora, 
				Id_Garantia, 
				Tipo_Garantia_Real, 
				Clase_Garantia, 
				Semestre_Calculado, 
				Fecha_Valuacion, 
				Monto_Ultima_Tasacion_Terreno, 
				Monto_Ultima_Tasacion_No_Terreno,
				Tipo_Cambio, 
				Indice_Precios_Consumidor, 
				Tipo_Cambio_Anterior, 
				Indice_Precios_Consumidor_Anterior, 
				Factor_Tipo_Cambio, 
				Factor_IPC, 
				Porcentaje_Depreciacion_Semestral,
				Monto_Tasacion_Actualizada_Terreno, 
				Monto_Tasacion_Actualizada_No_Terreno,
				Numero_Registro,
				Codigo_Operacion, 
				Codigo_Garantia, 
				Tipo_Bien,
				Total_Semestres_Calcular,
				Usuario)
			SELECT	DISTINCT
				GETDATE(),
				TGR.Cod_Bien,
				TGR.Cod_Tipo_Garantia_real,
				TGR.Clase_Garantia,
				TFS.Fecha_Semestre,
				TGR.Fecha_Valuacion,
				TGR.Monto_Ultima_Tasacion_Terreno,
				TGR.Monto_Ultima_Tasacion_No_Terreno,
				NULL AS Tipo_Cambio,
				NULL AS Indice_Precios_Consumidor,
				NULL AS Tipo_Cambio_Anterior,
				NULL AS Indice_Precios_Consumidor_Anterior,
				NULL AS Factor_Tipo_Cambio,
				NULL AS Factor_IPC,
				0 AS Porcentaje_Depreciacion_Semestral,
				0,
				0,
				TFS.Numero_Semestre AS Numero_Registro,
				TGR.Cod_Operacion,
				TGR.Cod_Garantia_Real,
				TGR.Tipo_Bien,
				NULL AS Total_Semestres_Calcular,
				TGR.Cod_Usuario
			FROM	@TMP_GARANTIAS_REALES_X_OPERACION TGR
				INNER JOIN ( SELECT	TF1.cod_operacion,	
									GRV.cod_garantia_real,
									GRV.fecha_valuacion,
									TF1.Numero_Semestre,
									TF1.Fecha_Semestre
							 FROM	dbo.GAR_VALUACIONES_REALES GRV 
								INNER JOIN
								(SELECT	GRO.cod_operacion,
										TMP.Consecutivo AS Numero_Semestre,	
										DATEADD(MONTH,(6*(TMP.Consecutivo-1)), GR1.fecha_valuacion) AS Fecha_Semestre,
										GR1.cod_garantia_real
								FROM		@NUMEROS TMP,
									dbo.GAR_VALUACIONES_REALES GR1 
									INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
									ON GRO.cod_garantia_real		= GR1.cod_garantia_real
									AND GRO.Fecha_Valuacion_SICC	= GR1.fecha_valuacion
								WHERE	GR1.Indicador_Tipo_Registro = 1
									AND TMP.Consecutivo <= @viMesesAgregar
									AND DATEADD(MONTH,6*(TMP.Consecutivo-1), GR1.fecha_valuacion) >= GR1.fecha_valuacion
									AND DATEADD(MONTH,6*(TMP.Consecutivo-1), GR1.fecha_valuacion) <= @vdtFechaFinal) AS TF1
							ON TF1.cod_garantia_real = GRV.cod_garantia_real
							WHERE	GRV.Indicador_Tipo_Registro = 1
							) TFS
				ON TFS.cod_operacion		= TGR.Cod_Operacion
				AND TFS.cod_garantia_real	= TGR.Cod_Garantia_Real
				AND TFS.fecha_valuacion		= TGR.Fecha_Avaluo_SICC
			
			--Se obtiene el tipo de cambio y el IPC para cada semestre
			UPDATE	TCM
			SET		TCM.Tipo_Cambio					= CIA.Tipo_Cambio,
					TCM.Indice_Precios_Consumidor	= CIA.Indice_Precios_Consumidor
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
				INNER JOIN dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA 
				ON CONVERT(DATETIME,CAST(CIA.Fecha_Hora AS VARCHAR(11)),101) = TCM.Semestre_Calculado
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				AND CIA.Fecha_Hora = (SELECT	MAX(CI1.Fecha_Hora) 
									FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CI1  
									WHERE	CONVERT(DATETIME,CAST(CI1.Fecha_Hora AS VARCHAR(11)),101) = TCM.Semestre_Calculado
									GROUP BY CONVERT(DATETIME,CAST(CI1.Fecha_Hora AS VARCHAR(11)),101))
			
			--Se obtienen los datos del semestre anterior
			UPDATE	TCM
			SET		TCM.Tipo_Cambio_Anterior				= CIA.Tipo_Cambio,
					TCM.Indice_Precios_Consumidor_Anterior	= CIA.Indice_Precios_Consumidor
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
				INNER JOIN dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA 
				ON CONVERT(DATETIME,CAST(CIA.Fecha_Hora AS VARCHAR(11)),101) = DATEADD(MONTH, -6, TCM.Semestre_Calculado)
				INNER JOIN (SELECT	MAX(CI1.Fecha_Hora) AS Fecha_Hora
									FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CI1  
									GROUP BY CONVERT(DATETIME,CAST(CI1.Fecha_Hora AS VARCHAR(11)),101)) CI2
				ON CI2.Fecha_Hora = CIA.Fecha_Hora
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se actualiza el dato del total de número de semestres
			UPDATE	TCM
			SET		TCM.Total_Semestres_Calcular	= TC1.Numero_Registro
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
				INNER JOIN (SELECT	MAX(Numero_Registro) AS Numero_Registro, Codigo_Operacion, Codigo_Garantia
							FROM	dbo.TMP_CALCULO_MTAT_MTANT  
							WHERE	Usuario = @psCedula_Usuario
								AND Fecha_Hora >= @vdtFechaActualHora
							GROUP BY Codigo_Operacion, Codigo_Garantia) TC1
				ON TC1.Codigo_Operacion = TCM.Codigo_Operacion
				AND TC1.Codigo_Garantia = TCM.Codigo_Garantia
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se establece el valor del factor del tipo de cambio
			UPDATE	TCM
			SET		TCM.Factor_Tipo_Cambio = CASE 
												WHEN ((TCM.Tipo_Cambio IS NULL) OR (TCM.Tipo_Cambio_Anterior IS NULL)) THEN NULL
												WHEN (TCM.Tipo_Cambio_Anterior = 0) THEN NULL
												ELSE CONVERT(FLOAT, (CONVERT(FLOAT,(TCM.Tipo_Cambio / TCM.Tipo_Cambio_Anterior)) - 1))
											 END
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se establece el valor del factor del IPC
			UPDATE	TCM
			SET		TCM.Factor_IPC = CASE 
										WHEN ((TCM.Indice_Precios_Consumidor IS NULL) OR (TCM.Indice_Precios_Consumidor_Anterior IS NULL)) THEN NULL
										WHEN (TCM.Indice_Precios_Consumidor_Anterior = 0) THEN NULL
										ELSE CONVERT(FLOAT, (CONVERT(FLOAT, (TCM.Indice_Precios_Consumidor / TCM.Indice_Precios_Consumidor_Anterior)) - 1))
									 END
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se establece el porcentaje de depreciación semestral aplicable a cada registro
			UPDATE	TCM
			SET		TCM.Porcentaje_Depreciacion_Semestral = CASE
																WHEN (TCM.Semestre_Calculado <= (DATEADD(YEAR, @viAnnoInferior, TCM.Fecha_Valuacion))) THEN CONVERT(FLOAT, (@vdPorcentajeInferior/100))
																WHEN ((TCM.Semestre_Calculado > (DATEADD(YEAR, @viAnnoInferior, TCM.Fecha_Valuacion))) 
																	AND (TCM.Semestre_Calculado <= (DATEADD(YEAR, @viAnnoIntermedio, TCM.Fecha_Valuacion)))) THEN CONVERT(FLOAT, (@vdPorcentajeIntermedio/100))
																ELSE CONVERT(FLOAT, (@vdPorcentajeSuperior/100))
															END
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
			WHERE	TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se igualan los montos a los correspondientes de la última tasación, esto sólo para el primer semestre 
			UPDATE	TCM
			SET		TCM.Monto_Tasacion_Actualizada_Terreno		= TCM.Monto_Ultima_Tasacion_Terreno,
					TCM.Monto_Tasacion_Actualizada_No_Terreno	= TCM.Monto_Ultima_Tasacion_No_Terreno
			FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
			WHERE	TCM.Numero_Registro = 1
				AND TCM.Usuario = @psCedula_Usuario
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				

			--Se asigna el valor NULL a los montos calculados en caso de que alguno de los factores sea igual a NULL.
			UPDATE TCM
			SET TCM.Monto_Tasacion_Actualizada_Terreno		= NULL,
				TCM.Monto_Tasacion_Actualizada_No_Terreno	= NULL
			FROM dbo.TMP_CALCULO_MTAT_MTANT TCM
			WHERE TCM.Numero_Registro > 1
				AND TCM.Usuario = @psCedula_Usuario
				AND ((TCM.Factor_Tipo_Cambio IS NULL) OR (TCM.Factor_IPC IS NULL))	
				AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
			--Se vuelven a obtener la cantidad de registros a los que se les debe aplicar el cálculo de los montos
			SET @viCantidadRegistros = (SELECT	MAX(Numero_Registro)
										FROM	dbo.TMP_CALCULO_MTAT_MTANT 
										WHERE	Usuario = @psCedula_Usuario
											AND Fecha_Hora >= @vdtFechaActualHora)
		
			--Se inicializa el contador del ciclo en 2, esto porque se debe obtener el semestre anterior 
			SET @viContador = 2	
			
			--Se inicia el ciclo que permitirá calcular los montos actualizados para cada registro evaluado
			WHILE @viContador <= @viCantidadRegistros
			BEGIN
				--Se calculan los montos usando como menor factor el tipo de cambio, para los registros que tengan más de un semestre por calcular
				UPDATE	TCM
				SET		TCM.Monto_Tasacion_Actualizada_Terreno		= dbo.ufn_RedondearValor_FV((CMM.MTAT_Anterior * (1 + TCM.Factor_Tipo_Cambio))),
						TCM.Monto_Tasacion_Actualizada_No_Terreno	= dbo.ufn_RedondearValor_FV((CMM.MTANT_Anterior * (1-TCM.Porcentaje_Depreciacion_Semestral) * (1 + TCM.Factor_Tipo_Cambio)))
				FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
					INNER JOIN (SELECT	TC1.Codigo_Operacion, TC1.Codigo_Garantia, TC1.Numero_Registro,
									TC1.Monto_Tasacion_Actualizada_Terreno AS MTAT_Anterior,
									TC1.Monto_Tasacion_Actualizada_No_Terreno AS MTANT_Anterior
								FROM	dbo.TMP_CALCULO_MTAT_MTANT TC1 
								WHERE	TC1.Numero_Registro = (@viContador - 1)
									AND TC1.Usuario = @psCedula_Usuario
									AND TC1.Fecha_Hora >= @vdtFechaActualHora) CMM
					ON	CMM.Codigo_Operacion = TCM.Codigo_Operacion
					AND CMM.Codigo_Garantia = TCM.Codigo_Garantia
				WHERE	TCM.Factor_Tipo_Cambio	IS NOT NULL
					AND TCM.Factor_IPC			IS NOT NULL
					AND TCM.Factor_Tipo_Cambio	<= TCM.Factor_IPC
					AND TCM.Numero_Registro		= @viContador
					AND TCM.Total_Semestres_Calcular > 1
					AND TCM.Usuario = @psCedula_Usuario
					AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
				--Se calculan los montos usando como menor factor el IPC, para los registros que tengan más de un semestre por calcular
				UPDATE	TCM
				SET		TCM.Monto_Tasacion_Actualizada_Terreno		= dbo.ufn_RedondearValor_FV((CMM.MTAT_Anterior *  (1 + TCM.Factor_IPC))),
						TCM.Monto_Tasacion_Actualizada_No_Terreno	= dbo.ufn_RedondearValor_FV((CMM.MTANT_Anterior * (1-TCM.Porcentaje_Depreciacion_Semestral) * (1 + TCM.Factor_IPC)))
				FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM
					INNER JOIN (SELECT	TC1.Codigo_Operacion, TC1.Codigo_Garantia, TC1.Numero_Registro,
									TC1.Monto_Tasacion_Actualizada_Terreno AS MTAT_Anterior,
									TC1.Monto_Tasacion_Actualizada_No_Terreno AS MTANT_Anterior
								FROM	dbo.TMP_CALCULO_MTAT_MTANT TC1 
								WHERE	TC1.Numero_Registro = (@viContador - 1)
									AND TC1.Usuario = @psCedula_Usuario
									AND TC1.Fecha_Hora >= @vdtFechaActualHora) CMM
					ON	CMM.Codigo_Operacion = TCM.Codigo_Operacion
					AND CMM.Codigo_Garantia = TCM.Codigo_Garantia
				WHERE	TCM.Factor_Tipo_Cambio	IS NOT NULL
					AND TCM.Factor_IPC			IS NOT NULL
					AND TCM.Factor_Tipo_Cambio	> TCM.Factor_IPC
					AND TCM.Numero_Registro		= @viContador
					AND TCM.Total_Semestres_Calcular > 1
					AND TCM.Usuario = @psCedula_Usuario
					AND TCM.Fecha_Hora >= @vdtFechaActualHora
				
				--Se aumenta el contador del cico
				SET @viContador = @viContador + 1
			END --Finaliza el ciclo que calcula los montos para cada registro evaluado
			
			--Se actualizan los montos por los calculados
			BEGIN TRANSACTION TRA_Act_Montoscal
			
			UPDATE 	GVR
			SET		GVR.monto_tasacion_actualizada_terreno	=	CASE 
																	WHEN (TMP.Monto_Tasacion_Actualizada_Terreno > 0) THEN TMP.Monto_Tasacion_Actualizada_Terreno
																	ELSE GVR.monto_tasacion_actualizada_terreno
																END,
					GVR.monto_tasacion_actualizada_no_terreno = CASE 
																	WHEN (TMP.Monto_Tasacion_Actualizada_No_Terreno > 0) THEN TMP.Monto_Tasacion_Actualizada_No_Terreno
																	ELSE GVR.monto_tasacion_actualizada_no_terreno
																END,
					GVR.Indicador_Actualizado_Calculo = 1,
					GVR.Fecha_Semestre_Calculado = TMP.Semestre_Calculado
			FROM	dbo.GAR_VALUACIONES_REALES GVR
				INNER JOIN 
				(SELECT	TCM.Codigo_Garantia, 
						COALESCE(TCM.Monto_Tasacion_Actualizada_Terreno, 0) AS Monto_Tasacion_Actualizada_Terreno, 
						COALESCE(TCM.Monto_Tasacion_Actualizada_No_Terreno, 0) AS Monto_Tasacion_Actualizada_No_Terreno, 
						TCM.Fecha_Valuacion,
						TCM.Semestre_Calculado
				FROM	dbo.TMP_CALCULO_MTAT_MTANT TCM 
				WHERE	TCM.Semestre_Calculado = (	SELECT	MAX(CM1.Semestre_Calculado)
													FROM	dbo.TMP_CALCULO_MTAT_MTANT CM1 
													WHERE	CM1.Codigo_Operacion	= TCM.Codigo_Operacion
														AND CM1.Codigo_Garantia		= TCM.Codigo_Garantia
														AND CM1.Usuario = @psCedula_Usuario
														AND CM1.Fecha_Hora >= @vdtFechaActualHora)
					AND TCM.Numero_Registro = (	SELECT	MAX(CM2.Numero_Registro)
												FROM	dbo.TMP_CALCULO_MTAT_MTANT CM2 
												WHERE	CM2.Codigo_Operacion	= TCM.Codigo_Operacion
													AND CM2.Codigo_Garantia		= TCM.Codigo_Garantia
													AND CM2.Usuario = @psCedula_Usuario
													AND CM2.Fecha_Hora >= @vdtFechaActualHora)
					AND TCM.Usuario = @psCedula_Usuario
					AND TCM.Fecha_Hora >= @vdtFechaActualHora) TMP
				ON TMP.Codigo_Garantia = GVR.cod_garantia_real
				AND TMP.Fecha_Valuacion = GVR.fecha_valuacion
			
			IF (@@ERROR <> 0)
			BEGIN 
				ROLLBACK TRANSACTION TRA_Act_Montoscal
				INSERT INTO @ERRORES_TRANSACCIONALES ( Codigo_Error, Descripcion_Error)
				SELECT 1, 'Se produjo un error al los montos calculados de las tasaciones actualizadas del terreno y no terreno.'
			END
			ELSE
			BEGIN
				COMMIT TRANSACTION TRA_Act_Montoscal
			END
			/************************************************************************************************
			 *                                                                                              * 
			 *                            FIN DEL CALCULO DE LOS MONTOS                                     *
			 *                                                                                              *
			 ************************************************************************************************/
		END

		/************************************************************************************************
		 *                                                                                              * 
		 *                    INICIO DE LA INSERCION DE ERRORES EN LA BITÁCORA                          *
		 *                                                                                              *
		 ************************************************************************************************/
		IF((SELECT	COUNT(*) FROM @ERRORES_TRANSACCIONALES) > 0)
		BEGIN
			--Se obtiene el código de ejecución del proceso del día actual
			SELECT	@viEjecucionProceso = MAX(conEjecucionProceso)
			FROM	dbo.GAR_EJECUCION_PROCESO 
			WHERE	cocProceso = @vsCodigo_Proceso
				AND CONVERT(DATETIME,CAST(fecEjecucion AS VARCHAR(11)),101) = @vdtFechaActual

			SELECT	@viEjecucionProcesoDetalle = COALESCE(MAX(conEjecucionProcesoDetalle), 0) + 1
			FROM	dbo.GAR_EJECUCION_PROCESO_DETALLE 
			WHERE	conEjecucionProceso = @viEjecucionProceso

			IF (@viEjecucionProceso IS NULL)
			BEGIN
				INSERT	INTO GAR_EJECUCION_PROCESO(cocProceso, fecEjecucion)
				VALUES	(@vsCodigo_Proceso, GETDATE())

				SET		@viEjecucionProceso = @@IDENTITY
			END

			--Se inserta una descripción global de error, que encierra el detalle
			INSERT INTO dbo.GAR_EJECUCION_PROCESO_DETALLE(
				conEjecucionProceso, 
				conEjecucionProcesoDetalle,
				desObservacion,
				indError)
			SELECT	@viEjecucionProceso, 
					@viEjecucionProcesoDetalle,
					'Se presentaron los siguientes problemas al ejecutar el proceso automático del cálculo del monto de la tasación actualizada del terreno y no terreno',
					1

			--Se inserta el detalle de los errores encontrados
			INSERT INTO dbo.GAR_EJECUCION_PROCESO_DETALLE(
				conEjecucionProceso, 
				conEjecucionProcesoDetalle,
				desObservacion,
				indError)
			SELECT	@viEjecucionProceso, 
					(@viEjecucionProcesoDetalle + 1),
					Descripcion_Error,
					1
			FROM	@ERRORES_TRANSACCIONALES
			ORDER	BY Codigo_Error

			SET @psRespuesta = N'<RESPUESTA>' +
							'<CODIGO>1</CODIGO>' +
							'<NIVEL></NIVEL>' +
							'<ESTADO></ESTADO>' +
							'<PROCEDIMIENTO>Aplicar_Calculo_MTANT</PROCEDIMIENTO>' +
							'<LINEA></LINEA>' + 
							'<MENSAJE>La aplicación del cálculo ha fallado.</MENSAJE>' +
							'<DETALLE></DETALLE>' +
						'</RESPUESTA>'

				RETURN 1
		END
		ELSE
		BEGIN
			SET @psRespuesta = N'<RESPUESTA>' +
						'<CODIGO>0</CODIGO>' +
						'<NIVEL></NIVEL>' +
						'<ESTADO></ESTADO>' +
						'<PROCEDIMIENTO>Aplicar_Calculo_MTANT</PROCEDIMIENTO>' +
						'<LINEA></LINEA>' + 
						'<MENSAJE>La aplicación del cálculo ha sido satisfactoria.</MENSAJE>' +
						'<DETALLE></DETALLE>' +
					'</RESPUESTA>'

			RETURN 0
		END
END