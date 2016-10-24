USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Normalizar_Avaluo_Garantias_Reales', 'P') IS NOT NULL
	DROP PROCEDURE Normalizar_Avaluo_Garantias_Reales;
GO

CREATE PROCEDURE [dbo].[Normalizar_Avaluo_Garantias_Reales]
	@psCedula_Usuario				VARCHAR(30),
	@psIP							VARCHAR(20),
	@piConsecutivo_Operacion		BIGINT,
	@piConsecutivo_Garantia_Real	BIGINT,
	@psFecha_Valuacion				VARCHAR(10),
	@piTipo_Bien					SMALLINT,
	@piTipo_Mitigador				SMALLINT,
	@psCodigo_Bien					VARCHAR(30),
	@psCodigo_Operacion				VARCHAR(30),
	@psListaCodigosOperaciones		VARCHAR(1000),
	@psRespuesta					VARCHAR(1000) OUTPUT
	
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Normalizar_Avaluo_Garantias_Reales</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que normaliza la valuación entre todas aquellos registros e una misma finca o prenda.
	</Descripción>
	<Entradas>
			@psCedula_Usuario				= Identificación del usuario que realiza la consulta. 
											  Este es dato llave usado para la búsqueda de los registros que deben 
											  ser eliminados de la tabla temporal.
			@psIP							= Dirección IP de la máquina desde donde se hace el ajuste.
            @piConsecutivo_Operacion		= Consecutivo de la operación a la que está asociada la garantía real
			@piConsecutivo_Garantia_Real	= Consecutivo de la garantía real afectada.
			@psFecha_Valuacion				= Fecha del avalúo a ser normalizado.
			@piTipo_Bien					= Código del tipo de bien asignado a la garantía afectada.
			@piTipo_Mitigador				= Código del tipo de mitigadorde riesgo asignado a la garantía afectada.
			@psCodigo_Bien					= Código del bien, bajo el formato [HC/CH/P] Partido/Clase de bien – Finca/Placa).
			@psCodigo_Operacion				= Código de la operación, bajo el formato oficina-moneda-producto-operación/contrato.
			@psListaCodigosOperaciones		= Lista de consecutivos de las operaciones asociadas.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>18/03/2014</Fecha>
	<Requerimiento>
		Req_Cmabios en la Extracción de los campo % de Aceptación,Indicador de Inscripción y  
		Actualización de Fecha de Valuación en Garantías Relacionadas, Siebel No. 1-24206841
	</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfauméricas</Requerimiento>
			<Fecha>02/07/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación de placas alfanuméricas, 
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

		--Declaración de variables locales
		DECLARE		@vsIdentificacion_Usuario	VARCHAR(30),  --Identificación del usuario que ejecuta el proceso.
					@viEjecucion_Exitosa		INT,		  --Valor de retorno producto de la ejecución de un procedimiento almacenado.
					@vbTipo_Garantia_Real		BIT,		  --Se identifica si el tipo de garantía es hipotecaria (0) o prendaria (1).
					@viCantidad_Registros		BIGINT,		  --Cantidad de garantías cuyo avalúo debe ser normalizado.
					@vsTexto_Consulta			VARCHAR(1000),--Texto que será grabado en la bitácora, debido a la normalización que se lleve acabo
					@viCatalogo_RP				INT,		  --Catálogo del indicador de recomendación del perito.
					@viCatalogo_IMTM			INT, 		  --Catálogo del indicador de inspección menor a tres meses.
					@viCatalogo_TB				SMALLINT,	  --Catálogo del tipo de bienes.
					@viCatalogo_TM				SMALLINT,	  --Catálogo del tipo de mitigador de riesgo.
					@viCatalogo_M				SMALLINT,	  --Catálogo del tipo de monedas.
					@vdFecha_Avaluo_Reciente	DATETIME,	  --Fecha de valaución más reciente registrada a las garantías a ser normalizadas.
					@viError					INT,		  --Variable para el manejo del error en la transacción.
					@viConsecutivo				BIGINT,		  --Se usa para generar los códigos de la tabla temporal de números.
					@vdFecha_Valuacion			DATETIME,	  --Variable que almacenará la fecha del avalúo.
					@vsDelimitador				CHAR(1),	  --Se usa para guardar el delimitador de la lista de consecutivos de las operaciones relacionadas.
					@viClaseGarantia			SMALLINT,     --Clase de la garantía fuente.
					@viPartido					SMALLINT,     --Partido de la garantía fuente.
					@vsIdentificacionGarantia	VARCHAR(25),  --Número de la finca, o placa del bien, de la garantía fuente.
					@viFechaActualEntera		INT, --Corresponde al a fecha actual en formato numérico.
					@viContador					TINYINT
	
		DECLARE @NUMEROS TABLE (Consecutivo BIGINT IDENTITY(1,1),
								Campo_vacio	CHAR(8)
								PRIMARY KEY (Consecutivo)) --Se utilizará para generar los semestres a ser calculados
						
	
		DECLARE @TMP_OPERACIONES_RELACIONADAS TABLE (Consecutivo_Operacion	BIGINT) --Almacenará los consecutivos de las operaciones relacionadas
	
		DECLARE	@TMP_AVALUOS_NORMALIZADOS TABLE (
													Consecutivo_Garantia_Real				BIGINT,
													Fecha_Valuacion							DATETIME		,
													Cedula_Empresa							VARCHAR(30)		COLLATE database_default,
													Cedula_Perito							VARCHAR(30)		COLLATE database_default,
													Monto_Ultima_Tasacion_Terreno			MONEY			,
													Monto_Ultima_Tasacion_No_Terreno		MONEY			,
													Monto_Tasacion_Actualizada_Terreno		MONEY			,
													Monto_Tasacion_Actualizada_No_Terreno	MONEY			,
													Fecha_Ultimo_Seguimiento				DATETIME		,
													Monto_Total_Avaluo						MONEY			,
													Recomendacion_Perito					SMALLINT		,
													Inspeccion_Menor_Tres_Meses				SMALLINT		,
													Fecha_Construccion						DATETIME		,
													Indicador_Tipo_Registro					TINYINT			,
													Indicador_Actualizado_Calculo			BIT				,
													Fecha_Semestre_Calculado				DATETIME		,
													Tipo_Bien								SMALLINT		,
													Tipo_Mitigador_Riesgo					SMALLINT		,	
													Codigo_Bien_Bitacora					VARCHAR(30)		COLLATE database_default,
													Sentencia_Consulta_Ins					VARCHAR(1000)	COLLATE database_default,
													Sentencia_Consulta_Act					VARCHAR(1000)	COLLATE database_default,
													Tipo_Operacion							SMALLINT		,
													Usuario									VARCHAR(30)		COLLATE database_default,
													Tipo_Moneda_Tasacion					SMALLINT        , --PBI 13977: Se agrega este campo
													Monto_Total_Avaluo_Colonizado			MONEY           ,--PBI 13977: Se agrega este campo
													Tipo_Cambio								DECIMAL(18,2)       													 
												) --Almacenará la información de la valuación a ser replicada a cada una de las garantías obtenidas.


		DECLARE	@TMP_AVALUOS_ACTUALES TABLE (
												Consecutivo_Garantia_Real				BIGINT,
												Fecha_Valuacion							DATETIME		,
												Cedula_Empresa							VARCHAR(30)		COLLATE database_default,
												Cedula_Perito							VARCHAR(30)		COLLATE database_default,
												Monto_Ultima_Tasacion_Terreno			MONEY			,
												Monto_Ultima_Tasacion_No_Terreno		MONEY			,
												Monto_Tasacion_Actualizada_Terreno		MONEY			,
												Monto_Tasacion_Actualizada_No_Terreno	MONEY			,
												Fecha_Ultimo_Seguimiento				DATETIME		,
												Monto_Total_Avaluo						MONEY			,
												Recomendacion_Perito					SMALLINT		,
												Inspeccion_Menor_Tres_Meses				SMALLINT		,
												Fecha_Construccion						DATETIME		,
												Indicador_Tipo_Registro					TINYINT			,
												Indicador_Actualizado_Calculo			BIT				,
												Fecha_Semestre_Calculado				DATETIME		,
												Usuario									VARCHAR(30)		COLLATE database_default,
												Tipo_Moneda_Tasacion					SMALLINT        , --PBI 13977: Se agrega este campo
												Monto_Total_Avaluo_Colonizado			MONEY     --PBI 13977: Se agrega este campo      	
											) --Almacenará la información de la valuación a ser actualizada.



		DECLARE	@TMP_GARANTIAS_HIPOTECARIAS_DUPLICADAS TABLE (
																Clase_Garantia		SMALLINT,
																Codigo_Partido		SMALLINT,
																Numero_Finca		VARCHAR (25)	COLLATE database_default
															 ) --Almacenará la información de las garantías hipotecarias que deben ser normalizadas.


		DECLARE	@TMP_GARANTIAS_PRENDARIAS_DUPLICADAS TABLE (
																Clase_Garantia		SMALLINT,
																Numero_Placa_Bien	VARCHAR (25)	COLLATE database_default
														   ) --Almacenará la información de las garantías prendarias que deben ser normalizadas.



		DECLARE	@TMP_HIPOTECAS_DUPLICADAS TABLE (
													Consecutivo_Garantia_Real	BIGINT,
													Codigo_Bien_Bitacora		VARCHAR(30)		COLLATE database_default
												) --Almacenará la información de las garantías hipotecarias que deben ser normalizadas.


		DECLARE	@TMP_PRENDAS_DUPLICADAS TABLE (
													Consecutivo_Garantia_Real	BIGINT,
													Codigo_Bien_Bitacora		VARCHAR(30)		COLLATE database_default
											   ) --Almacenará la información de las garantías prendarias que deben ser normalizadas.


		DECLARE @TMP_OPERACIONES_RESPALDADAS TABLE (
														Consecutivo_Operacion		BIGINT,
														Codigo_Operacion			VARCHAR(30) COLLATE database_default,
														Tipo_Bien					SMALLINT,
														Tipo_Mitigador				SMALLINT,
														Consecutivo_Garantia_Real	BIGINT
													) --Almacenará la información sobre las operaciones a relacionadas a las garantías.
	
		DECLARE	@TMP_BITACORA TABLE (
										Descripcion_Tabla				VARCHAR(50)	COLLATE database_default,
										Codigo_Usuario					VARCHAR(30)	COLLATE database_default,
										Cod_IP							VARCHAR(20)	COLLATE database_default,
										Codigo_Oficina					INT			,
										Cod_Operacion					SMALLINT	,
										Fecha_Hora						DATETIME	,
										Codigo_Consulta					TEXT		,
										Codigo_Tipo_Garantia			SMALLINT	,
										Codigo_Garantia					VARCHAR(30)	COLLATE database_default,
										Codigo_Operacion_Crediticia		VARCHAR(30)	COLLATE database_default,
										Codigo_Consulta2				TEXT		,
										Descripcion_Campo_Afectado		VARCHAR(50)	COLLATE database_default,
										Estado_Anterior_Campo_Afectado	VARCHAR(100)COLLATE database_default,
										Estado_Actual_Campo_Afectado	VARCHAR(100) COLLATE database_default
									) --Almacenará la información que será almacenada en la bitácora de pistas de auditoria.

	
	
		--Inicialización de variables locales
		SET @vsIdentificacion_Usuario	= @psCedula_Usuario
		SET	@vsTexto_Consulta	= 'El registro fue ajustado de forma automática cuando se modificó la garantía ' + @psCodigo_Bien + ' asociada a la operación ' + @psCodigo_Operacion + '.'
		SET	@viCatalogo_RP		= 16
		SET	@viCatalogo_IMTM	= 17
		SET @viCatalogo_TB		= 12
		SET @viCatalogo_TM		= 22
		SET	@vdFecha_Valuacion	= CONVERT(DATETIME, @psFecha_Valuacion)	
		SET @viCatalogo_M = 15 
	
		SELECT	@vbTipo_Garantia_Real		=	CASE
													WHEN cod_tipo_garantia_real = 3 THEN 1
													ELSE 0
												END,
				@viClaseGarantia			= cod_clase_garantia,
				@viPartido					= cod_partido,
				@vsIdentificacionGarantia	=	CASE
													WHEN cod_tipo_garantia_real = 3 THEN num_placa_bien
													ELSE numero_finca
												END
		FROM	dbo.GAR_GARANTIA_REAL 
		WHERE	cod_garantia_real = @piConsecutivo_Garantia_Real

		SET	@psRespuesta = N'<RESPUESTA>' +
								'<CODIGO>0</CODIGO>' + 
								'<NIVEL></NIVEL>' +
								'<ESTADO></ESTADO>' +
								'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
								'<LINEA></LINEA>' + 
								   '<MENSAJE>La replicación de avalúos ha sido satisfactoria.</MENSAJE>' +
								'<DETALLE></DETALLE>' +
							'</RESPUESTA>'
	
		--Se establece el delimitador
		SET @vsDelimitador = '|'
					
		--Inicialización de variables
		SET	@viConsecutivo = 1
	
		SET @viFechaActualEntera = CONVERT(INT, CONVERT(VARCHAR(8), (CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)), 112))

		--Se carga la tabla temporal de consecutivos
		WHILE	@viConsecutivo <=20000
		BEGIN
			INSERT INTO @NUMEROS (Campo_vacio) VALUES(@viConsecutivo)
			SET @viConsecutivo = @viConsecutivo + 1
		END
	
		--Se carga la tabla de los consecutivos de las operaciones relacionadas
		INSERT INTO @TMP_OPERACIONES_RELACIONADAS(Consecutivo_Operacion)
		SELECT SUBSTRING('|' + @psListaCodigosOperaciones + '|', Consecutivo + 1,
						CHARINDEX('|', '|' + @psListaCodigosOperaciones + '|', Consecutivo + 1) - Consecutivo - 1)
					 AS Value
		FROM	@NUMEROS
		WHERE	Consecutivo <= LEN('|' + @psListaCodigosOperaciones + '|') - 1
			AND SUBSTRING('|' + @psListaCodigosOperaciones + '|', Consecutivo, 1) = '|'
	
		DELETE	FROM @TMP_OPERACIONES_RELACIONADAS
		WHERE	Consecutivo_Operacion = 0
									
		/************************************************************************************************
		 *                                                                                              * 
		 *                INICIO DE LA NORMALIZACION DEL AVALUO DE LAS GARANTIAS REALES                 *
		 *                                                                                              *
		 *                                                                                              *
		 ************************************************************************************************/
		--Se aplica la normalización a aquellas garantías hipotecarias
		IF(@vbTipo_Garantia_Real = 0)
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

	
			--Se selecciona el consecutivo de aquellas fincas que se encuentran duplicadas
			INSERT INTO @TMP_HIPOTECAS_DUPLICADAS (
				Consecutivo_Garantia_Real,
				Codigo_Bien_Bitacora)
			SELECT	DISTINCT
				GGR.cod_garantia_real,
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN '[H] '  + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN '[CH] ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (CGV.Ind_Clase_Alfanumerica = 0)) THEN '[P] '  + COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (CGV.Ind_Clase_Alfanumerica = 1)) THEN '[P] '  + COALESCE(GGR.num_placa_bien,'') 
					ELSE '[-] ' + @psCodigo_Bien
				END	AS Codigo_Bien_Bitacora
			FROM	dbo.GAR_GARANTIA_REAL GGR 
				INNER JOIN dbo.AUX_CLASES_GAR_VALIDAS CGV
				ON CGV.Tipo_Garantia_Real = GGR.cod_tipo_garantia_real
				AND CGV.Codigo_Clase_Garantia = GGR.cod_clase_garantia
			WHERE	GGR.cod_clase_garantia	= @viClaseGarantia 
				AND GGR.cod_partido			= @viPartido 
				AND GGR.numero_finca		= @vsIdentificacionGarantia
				AND EXISTS (SELECT	1	
							FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								INNER JOIN @TMP_OPERACIONES_RELACIONADAS TMP
								ON GRO.cod_operacion = TMP.Consecutivo_Operacion
							WHERE	GRO.cod_garantia_real = GGR.cod_garantia_real)


			SET		@viCantidad_Registros = (SELECT COUNT(*) FROM @TMP_HIPOTECAS_DUPLICADAS)
		
			IF(@viCantidad_Registros > 0)
			BEGIN
			
				--Se obtiene la fecha de valuación más reciente registrada para las garantías a ser normalizadas
				SELECT	@vdFecha_Avaluo_Reciente = MAX(GVR.fecha_valuacion)
				FROM	dbo.GAR_VALUACIONES_REALES GVR 
					INNER JOIN @TMP_HIPOTECAS_DUPLICADAS THD
					ON THD.Consecutivo_Garantia_Real = GVR.cod_garantia_real
				WHERE	GVR.Indicador_Tipo_Registro = 1
				GROUP BY GVR.fecha_valuacion
			
				--Se verifica que no exista una fecha de valuación mayor a la tomada como base para la normalización
				IF(COALESCE(@vdFecha_Avaluo_Reciente, @vdFecha_Valuacion) <= @vdFecha_Valuacion)
				BEGIN
			
					--Se obtiene la información del avalúo a ser ingresado
					INSERT INTO @TMP_AVALUOS_NORMALIZADOS (
						Consecutivo_Garantia_Real,
						Fecha_Valuacion,
						Cedula_Empresa,
						Cedula_Perito,
						Monto_Ultima_Tasacion_Terreno,
						Monto_Ultima_Tasacion_No_Terreno,
						Monto_Tasacion_Actualizada_Terreno,
						Monto_Tasacion_Actualizada_No_Terreno,
						Fecha_Ultimo_Seguimiento,
						Monto_Total_Avaluo,
						Recomendacion_Perito,
						Inspeccion_Menor_Tres_Meses,
						Fecha_Construccion,
						Indicador_Tipo_Registro,
						Indicador_Actualizado_Calculo,
						Fecha_Semestre_Calculado,
						Tipo_Bien,
						Tipo_Mitigador_Riesgo,	
						Codigo_Bien_Bitacora,
						Sentencia_Consulta_Ins,
						Sentencia_Consulta_Act,
						Tipo_Operacion,
						Usuario,
						Tipo_Moneda_Tasacion,
						Monto_Total_Avaluo_Colonizado,
						Tipo_Cambio)
					SELECT	DISTINCT
						THD.Consecutivo_Garantia_Real,
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
						GVR.Indicador_Tipo_Registro,
						GVR.Indicador_Actualizado_Calculo,
						GVR.Fecha_Semestre_Calculado,
						@piTipo_Bien AS Tipo_Bien,
						@piTipo_Mitigador AS Tipo_Mitigador_Riesgo,
						THD.Codigo_Bien_Bitacora AS Codigo_Bien_Bitacora,
						('INSERT INTO GAR_VALUACIONES_REALES (cod_garantia_real,fecha_valuacion,cedula_empresa,cedula_perito,monto_ultima_tasacion_terreno,monto_ultima_tasacion_no_terreno,monto_tasacion_actualizada_terreno,monto_tasacion_actualizada_no_terreno,fecha_ultimo_seguimiento,monto_total_avaluo,cod_recomendacion_perito,cod_inspeccion_menor_tres_meses,fecha_construccion) VALUES(' +
						CAST(THD.Consecutivo_Garantia_Real AS VARCHAR(100)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_valuacion, 101) + ',' +
						COALESCE(GVR.cedula_empresa, '') + ',' +
						COALESCE(GVR.cedula_perito, '') + ',' +
						CAST(GVR.monto_ultima_tasacion_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_ultima_tasacion_no_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_tasacion_actualizada_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_tasacion_actualizada_no_terreno AS VARCHAR(100)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_ultimo_seguimiento, 101) + ',' +
						CAST(GVR.monto_total_avaluo AS VARCHAR(100)) + ',' +
						CAST(GVR.cod_recomendacion_perito AS VARCHAR(5)) + ',' +
						CAST(GVR.cod_inspeccion_menor_tres_meses AS VARCHAR(5)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_construccion, 101) + ')') AS Sentencia_Consulta_Ins,
						('UPDATE GAR_VALUACIONES_REALES SET cedula_perito = ' + CHAR(39) + 
						 +  COALESCE(GVR.cedula_perito, '') + CHAR(39) + 
						 ', monto_ultima_tasacion_terreno = convert(decimal(18,2), ' + CHAR(39) + 
						 CAST(GVR.monto_ultima_tasacion_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_ultima_tasacion_no_terreno = convert(decimal(18,2), ' + CHAR(39) +  
						 CAST(GVR.monto_ultima_tasacion_no_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_tasacion_actualizada_terreno = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_tasacion_actualizada_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_tasacion_actualizada_no_terreno = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_tasacion_actualizada_no_terreno AS VARCHAR(100)) + CHAR(39) +
						 '), fecha_ultimo_seguimiento = ' + CHAR(39) +
						 CONVERT(VARCHAR(10), GVR.fecha_ultimo_seguimiento, 101) + CHAR(39) +
						 ', monto_total_avaluo = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_total_avaluo AS VARCHAR(100)) + CHAR(39) +
						 '), cod_recomendacion_perito = ' + CAST(GVR.cod_recomendacion_perito AS VARCHAR(5)) +
						 ', cod_inspeccion_menor_tres_meses = ' + CAST(GVR.cod_inspeccion_menor_tres_meses AS VARCHAR(5)) + 
						 ', fecha_construccion ='  + CHAR(39) + 
						 CONVERT(VARCHAR(10), GVR.fecha_construccion, 101) + CHAR(39) +
						 ' WHERE cod_garantia_real = ' + CAST(THD.Consecutivo_Garantia_Real AS VARCHAR(100)) + 
						 ' AND fecha_valuacion = ' + CHAR(39) +
						 CONVERT(VARCHAR(10), GVR.fecha_valuacion, 101) + CHAR(39)) AS Sentencia_Consulta_Act,
						NULL AS Tipo_Operacion,
						@vsIdentificacion_Usuario AS Usuario,
						GVR.Tipo_Moneda_Tasacion,
						GVR.Monto_Total_Avaluo_Colonizado,
						NULL
					FROM	@TMP_HIPOTECAS_DUPLICADAS THD,
						dbo.GAR_VALUACIONES_REALES GVR 
					WHERE GVR.cod_garantia_real = @piConsecutivo_Garantia_Real
						AND GVR.fecha_valuacion = @vdFecha_Valuacion
				
					--Se actualiza el campo correspondiente al tipo de operación, asignando 1 si se trata de inserción de registro
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 1
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND NOT EXISTS (SELECT	1
										FROM	dbo.GAR_VALUACIONES_REALES GVR 
										WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
											AND GVR.fecha_valuacion		= @vdFecha_Valuacion)
				
					--Se actualiza el campo correspondiente al tipo de operación, asignando 2 si se trata de modificación de registro
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 2
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_VALUACIONES_REALES GVR 
									WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
										AND GVR.fecha_valuacion		= @vdFecha_Valuacion)

					--Se actualiza el campo correspondiente al tipo de operación, asignando 0 si existe algún registro cuya fecha de avalúo sea mayor a la referente
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 0
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND TA1.Fecha_Valuacion < (	SELECT	TOP 1 
															MAX(GVR.fecha_valuacion)
													FROM	dbo.GAR_VALUACIONES_REALES GVR 
													WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
													GROUP	BY GVR.fecha_valuacion)

					--Se obtienen los avalúos existentes que deberán de ser actualizados
					INSERT INTO @TMP_AVALUOS_ACTUALES (
						Consecutivo_Garantia_Real,
						Fecha_Valuacion,
						Cedula_Empresa,
						Cedula_Perito,
						Monto_Ultima_Tasacion_Terreno,
						Monto_Ultima_Tasacion_No_Terreno,
						Monto_Tasacion_Actualizada_Terreno,
						Monto_Tasacion_Actualizada_No_Terreno,
						Fecha_Ultimo_Seguimiento,
						Monto_Total_Avaluo,
						Recomendacion_Perito,
						Inspeccion_Menor_Tres_Meses,
						Fecha_Construccion,
						Indicador_Tipo_Registro,
						Indicador_Actualizado_Calculo,
						Fecha_Semestre_Calculado,
						Usuario,
						Tipo_Moneda_Tasacion,
						Monto_Total_Avaluo_Colonizado)
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
						0 AS Indicador_Tipo_Registro,
						GVR.Indicador_Actualizado_Calculo,
						GVR.Fecha_Semestre_Calculado,
						TA1.Usuario,
						GVR.Tipo_Moneda_Tasacion,
						GVR.Monto_Total_Avaluo_Colonizado
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
						ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
						AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND TA1.Usuario			= @vsIdentificacion_Usuario
				
				
					--Se actualiza el indicador del tipo de registro del avalúo, se obtienen los avalúos más recientes
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Indicador_Tipo_Registro = 2
					FROM	@TMP_AVALUOS_ACTUALES TMP
						INNER JOIN dbo.GAR_VALUACIONES_REALES GV1
						ON GV1.cod_garantia_real = TMP.Consecutivo_Garantia_Real
						INNER JOIN 
						(SELECT		cod_garantia_real, fecha_valuacion = MAX([fecha_valuacion])
						 FROM		dbo.GAR_VALUACIONES_REALES
						 GROUP		BY cod_garantia_real) GV2
							ON	GV2.cod_garantia_real	= GV1.cod_garantia_real
							AND GV2.fecha_valuacion		= GV1.fecha_valuacion

					--Se obtienen los penúltimos avalúos
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Indicador_Tipo_Registro = 3
					FROM	@TMP_AVALUOS_ACTUALES TMP
						INNER JOIN dbo.GAR_VALUACIONES_REALES GV1
						ON GV1.cod_garantia_real = TMP.Consecutivo_Garantia_Real
						INNER JOIN 
						(SELECT		cod_garantia_real, fecha_valuacion = MAX([fecha_valuacion])
						 FROM		dbo.GAR_VALUACIONES_REALES
						 WHERE		Indicador_Tipo_Registro = 0
						 GROUP		BY cod_garantia_real) GV2
							ON	GV2.cod_garantia_real	= GV1.cod_garantia_real
						AND GV2.fecha_valuacion		= GV1.fecha_valuacion
				
					--Se obtienen los avalúos que son iguales a los registrados en el SICC de las hipotecas comunes, con clase distinta a 11
					UPDATE	@TMP_AVALUOS_ACTUALES 
					SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
							Indicador_Tipo_Registro = 1
					FROM	@TMP_AVALUOS_ACTUALES GV1
											INNER JOIN (
						SELECT	DISTINCT 
							GGR.cod_garantia_real, 
							CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
							GHC.monto_total_avaluo 
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN (	SELECT	TOP 100 PERCENT 
												GGR.cod_clase_garantia,
												GGR.cod_partido,
												GGR.Identificacion_Sicc,
												MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
												MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo
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
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
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
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
																MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing
															FROM	
															(		SELECT	MG1.prmgt_pcoclagar,
																		MG1.prmgt_pnu_part,
																		MG1.prmgt_pnuidegar,
																		CASE 
																			WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																			WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																			ELSE '19000101'
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 19)
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
															GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing) MG3
											ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
											AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
											AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
											AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
											WHERE	GGR.cod_clase_garantia IN (10, 12, 13, 14, 15, 16, 17, 19)
											GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc
										) GHC
							ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
							AND GHC.cod_partido = GGR.cod_partido
							AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
						WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
					AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
				
				
					--Se obtienen los avalúos que son iguales a los registrados en el SICC de las hipotecas comunes, con clase igual a 11
					UPDATE	@TMP_AVALUOS_ACTUALES 
					SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
							Indicador_Tipo_Registro = 1,
							Tipo_Moneda_Tasacion	= TMP.Tipo_Moneda_Tasacion
					FROM	@TMP_AVALUOS_ACTUALES GV1
					INNER JOIN (
						SELECT	DISTINCT 
							GGR.cod_garantia_real, 
							CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
							GHC.monto_total_avaluo ,
							ghc.Tipo_Moneda_Tasacion
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN (	SELECT	TOP 100 PERCENT 
												GGR.cod_clase_garantia,
												GGR.cod_partido,
												GGR.Identificacion_Sicc,
												GGR.Identificacion_Alfanumerica_Sicc,
												MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
												MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo,
												MG3.prmgt_pco_mongar AS Tipo_Moneda_Tasacion
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
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
																MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing, MG2.prmgt_pco_mongar
															FROM	
															(		SELECT	MG1.prmgt_pcoclagar,
																		MG1.prmgt_pnu_part,
																		MG1.prmgt_pnuidegar,
																		MG1.prmgt_pnuide_alf,
																		CASE 
																			WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																			WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																			ELSE '19000101'
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcoclagar = 11
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcoclagar = 11
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
															GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing, MG2.prmgt_pco_mongar) MG3
											ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
											AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
											AND COALESCE(MG3.prmgt_pnuidegar, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
											AND COALESCE(MG3.prmgt_pnuide_alf, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
											AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
											WHERE	GGR.cod_clase_garantia = 11
											GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc, MG3.prmgt_pco_mongar
										) GHC
							ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
							AND GHC.cod_partido = GGR.cod_partido
							AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
							AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
						WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
					AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
					
				
				
				
					--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía 18
					UPDATE	@TMP_AVALUOS_ACTUALES 
					SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
							Indicador_Tipo_Registro = 1,
							Tipo_Moneda_Tasacion	= TMP.Tipo_Moneda_Tasacion
					FROM	@TMP_AVALUOS_ACTUALES GV1
						INNER JOIN (
							SELECT	DISTINCT 
								GGR.cod_garantia_real, 
								CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
								GHC.monto_total_avaluo,
								GHC.Tipo_Moneda_Tasacion
							FROM	dbo.GAR_GARANTIA_REAL GGR
								INNER JOIN (	SELECT	TOP 100 PERCENT 
													GGR.cod_clase_garantia,
													GGR.cod_partido,
													GGR.numero_finca,
													MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
													MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo,
													MG3.prmgt_pco_mongar AS Tipo_Moneda_Tasacion
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
																							AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																							AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
												INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
																	MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing, MG2.prmgt_pco_mongar
																FROM	
																(		SELECT	MG1.prmgt_pcoclagar,
																			MG1.prmgt_pnu_part,
																			MG1.prmgt_pnuidegar,
																			CASE 
																				WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																				WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																				ELSE '19000101'
																			END AS prmgt_pfeavaing,
																			MG1.prmgt_pmoavaing,
																			MG1.prmgt_pco_mongar
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
																			END AS prmgt_pfeavaing,
																			MG1.prmgt_pmoavaing,
																			MG1.prmgt_pco_mongar
																		FROM	dbo.GAR_SICC_PRMGT MG1
																		WHERE	MG1.prmgt_pcoclagar = 18
																			AND MG1.prmgt_estado = 'A'
																			AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMCA MCA
																						WHERE	MCA.prmca_estado = 'A'
																							AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																			END AS prmgt_pfeavaing,
																			MG1.prmgt_pmoavaing,
																			MG1.prmgt_pco_mongar
																		FROM	dbo.GAR_SICC_PRMGT MG1
																		WHERE	MG1.prmgt_pcoclagar = 18
																			AND MG1.prmgt_estado = 'A'
																			AND EXISTS (SELECT	1
																						FROM	dbo.GAR_SICC_PRMCA MCA
																						WHERE	MCA.prmca_estado = 'A'
																							AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
																GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing, MG2.prmgt_pco_mongar) MG3
												ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
												AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
												AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
												AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
												WHERE	GGR.cod_clase_garantia = 18
												GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca, MG3.prmgt_pco_mongar
											) GHC
								ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
								AND GHC.cod_partido = GGR.cod_partido
								AND GHC.numero_finca = GGR.numero_finca
							WHERE	GHC.fecha_valuacion > '19000101') TMP
						ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
						AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
						
	
				--Se asigna el mínimo monto de la fecha del avlaúo más reciente para cédulas hipotecarias con clase de garantía diferente a 18
				UPDATE	@TMP_AVALUOS_ACTUALES 
				SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
						Indicador_Tipo_Registro = 1,
						Tipo_Moneda_Tasacion	= TMP.Tipo_Moneda_Tasacion
				FROM	@TMP_AVALUOS_ACTUALES GV1
					INNER JOIN (
						SELECT	DISTINCT 
							GGR.cod_garantia_real, 
							CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
							GHC.monto_total_avaluo,
							GHC.Tipo_Moneda_Tasacion
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN (	SELECT	TOP 100 PERCENT 
												GGR.cod_clase_garantia,
												GGR.cod_partido,
												GGR.numero_finca,
												MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
												MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo,
												MG3.prmgt_pco_mongar AS Tipo_Moneda_Tasacion
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
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, 
																MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing, MG2.prmgt_pco_mongar
															FROM	
															(		SELECT	MG1.prmgt_pcoclagar,
																		MG1.prmgt_pnu_part,
																		MG1.prmgt_pnuidegar,
																		CASE 
																			WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																			WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																			ELSE '19000101'
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcotengar = 1
																		AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	MG1.prmgt_pcotengar = 1
																		AND MG1.prmgt_pcoclagar BETWEEN 20 AND 29
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
															GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnu_part, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing, MG2.prmgt_pco_mongar) MG3
											ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
											AND MG3.prmgt_pnu_part = MGT.prmgt_pnu_part
											AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
											AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
											WHERE	GGR.cod_clase_garantia BETWEEN 20 AND 29
											GROUP BY GGR.cod_clase_garantia, GGR.cod_partido, GGR.numero_finca, MG3.prmgt_pco_mongar
										) GHC
							ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
							AND GHC.cod_partido = GGR.cod_partido
							AND GHC.numero_finca = GGR.numero_finca
						WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
					AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
				
					--Se obtienen las operaciones a las cuales están asociadas las garantías
					INSERT INTO @TMP_OPERACIONES_RESPALDADAS (
						Consecutivo_Operacion, 
						Codigo_Operacion,
						Tipo_Bien,
						Tipo_Mitigador,
						Consecutivo_Garantia_Real)
					SELECT	DISTINCT
						GRO.Codigo_Operacion,
						(CAST(GRO.Codigo_Oficina AS VARCHAR(5))  + '-' + 
						 CAST(GRO.Codigo_Moneda AS VARCHAR(5))   + '-' + 
						 CAST(GRO.Codigo_Producto AS VARCHAR(5)) + '-' + 
						 CAST(GRO.Operacion AS VARCHAR(20))) AS Codigo_Operacion,
						GRO.Codigo_Tipo_Bien,
						GRO.Codigo_Tipo_Mitigador,
						GRO.Codigo_Garantia_Real
					FROM	@TMP_HIPOTECAS_DUPLICADAS THD
						INNER JOIN	dbo.TMP_GARANTIAS_REALES_X_OPERACION GRO 
						ON GRO.Codigo_Garantia_Real = THD.Consecutivo_Garantia_Real
				
					--Se generan las pistas de auditoría que se ingresarán en la bitácora transaccional
					INSERT INTO @TMP_BITACORA (
						Descripcion_Tabla, Codigo_Usuario, Cod_IP, Codigo_Oficina, Cod_Operacion, Fecha_Hora,
						Codigo_Consulta, Codigo_Tipo_Garantia, Codigo_Garantia, Codigo_Operacion_Crediticia,
						Codigo_Consulta2, Descripcion_Campo_Afectado, Estado_Anterior_Campo_Afectado,
						Estado_Actual_Campo_Afectado)
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_valuacion', '-', CONVERT(VARCHAR(10), TA1.Fecha_Valuacion, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion = 1
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_empresa', '-', TA1.Cedula_Empresa
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion = 1
						AND TA1.Cedula_Empresa IS NOT NULL	
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
					
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_perito', '-', TA1.Cedula_Perito
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion	= 1
						AND TA1.Cedula_Perito	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion					= 1
						AND TA1.Monto_Ultima_Tasacion_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_no_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion						= 1
						AND TA1.Monto_Ultima_Tasacion_No_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion						= 1
						AND TA1.Monto_Tasacion_Actualizada_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_no_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion							= 1
						AND TA1.Monto_Tasacion_Actualizada_No_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_ultimo_seguimiento', '-', CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion				= 1
						AND TA1.Fecha_Ultimo_Seguimiento	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_total_avaluo', '-', CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion		= 1
						AND TA1.Monto_Total_Avaluo	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_recomendacion_perito', '-', COALESCE(cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real,
						dbo.CAT_ELEMENTO 	
					WHERE	TA1.Tipo_Operacion			= 1
						AND TA1.Recomendacion_Perito	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND cat_catalogo				= @viCatalogo_RP
						AND cat_campo					= CONVERT(VARCHAR(5), TA1.Recomendacion_Perito)
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_inspeccion_menor_tres_meses', '-', COALESCE(cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real,
						dbo.CAT_ELEMENTO 	
					WHERE	TA1.Tipo_Operacion				= 1
						AND TA1.Inspeccion_Menor_Tres_Meses IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND cat_catalogo					= @viCatalogo_IMTM
						AND cat_campo						= CONVERT(VARCHAR(5), TA1.Inspeccion_Menor_Tres_Meses)

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_construccion', '-', CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion		= 1
						AND TA1.Fecha_Construccion	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
								
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_empresa', COALESCE(TAA.Cedula_Empresa, '-'), COALESCE(TA1.Cedula_Empresa, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion = 2
						AND COALESCE(TA1.Cedula_Empresa, '-') <> COALESCE(TAA.Cedula_Empresa, '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
					
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_perito', COALESCE(TAA.Cedula_Perito, '-'), COALESCE(TA1.Cedula_Perito, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(TA1.Cedula_Perito, '-')	<> COALESCE(TAA.Cedula_Perito, '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_no_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_No_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_No_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_no_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_No_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_No_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_ultimo_seguimiento', COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Ultimo_Seguimiento, 101), '-'), COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101), '-') <> COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Ultimo_Seguimiento, 101), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_total_avaluo', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Total_Avaluo), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Total_Avaluo), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_recomendacion_perito', COALESCE(CE2.cat_descripcion, '-'), COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real 
						LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1	
						ON CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Recomendacion_Perito)
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
						LEFT OUTER JOIN  dbo.CAT_ELEMENTO CE2	 
						ON CE2.cat_campo = CONVERT(VARCHAR(5), TAA.Recomendacion_Perito)
					WHERE	TA1.Tipo_Operacion			= 2
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND CE1.cat_catalogo				= @viCatalogo_RP
						AND CE2.cat_catalogo				= @viCatalogo_RP
						AND COALESCE(CE1.cat_descripcion, '-') <> COALESCE(CE2.cat_descripcion, '-')

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_inspeccion_menor_tres_meses', COALESCE(CE2.cat_descripcion, '-'), COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1 	
						ON CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Inspeccion_Menor_Tres_Meses)
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
						LEFT OUTER JOIN  dbo.CAT_ELEMENTO CE2 	
						ON CE2.cat_campo = CONVERT(VARCHAR(5), TAA.Inspeccion_Menor_Tres_Meses)
					WHERE	TA1.Tipo_Operacion				= 2
						AND TA1.Inspeccion_Menor_Tres_Meses IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND CE1.cat_catalogo				= @viCatalogo_IMTM
						AND CE2.cat_catalogo				= @viCatalogo_IMTM
						AND COALESCE(CE1.cat_descripcion, '-') <> COALESCE(CE2.cat_descripcion, '-')

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_construccion', COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Construccion, 101), '-'), COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion		= 2
						AND COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101), '-') <> COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Construccion, 101), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL

					SELECT	
						'GAR_GARANTIA_REAL' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), 
						'UPDATE GAR_GARANTIA_REAL SET cod_tipo_bien = ' + CONVERT(VARCHAR(5), @piTipo_Bien) + ' WHERE cod_garantia_real = ' + CONVERT(VARCHAR(100), TOR.Consecutivo_Garantia_Real), 
						2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion, @vsTexto_Consulta, 'cod_tipo_bien', COALESCE(CE2.cat_descripcion, '-'), 
						COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE1 
						ON	CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Tipo_Bien)
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE2 
						ON CE2.cat_catalogo = CONVERT(VARCHAR(5), TOR.Tipo_Bien)
					WHERE	CE1.cat_catalogo	= @viCatalogo_TB
						AND CE1.cat_campo		= CONVERT(VARCHAR(5), @piTipo_Bien)
						AND CE2.cat_catalogo	= @viCatalogo_TB
						AND CE1.cat_campo		<> CE2.cat_campo

					UNION ALL
				
					SELECT	
						'GAR_GARANTIAS_REALES_X_OPERACION' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), 
						'UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador = ' + CONVERT(VARCHAR(5), @piTipo_Mitigador) + ' WHERE cod_operacion =' + CONVERT(VARCHAR(100), TOR.Consecutivo_Operacion) + 'AND cod_garantia_real = ' + CONVERT(VARCHAR(100), TOR.Consecutivo_Garantia_Real), 
						2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion, @vsTexto_Consulta, 'cod_tipo_mitigador', COALESCE(CE2.cat_descripcion, '-'), 
						COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE1 
						ON	CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Tipo_Mitigador_Riesgo)
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE2 
						ON CE2.cat_catalogo = CONVERT(VARCHAR(5), TOR.Tipo_Mitigador)
					WHERE	CE1.cat_catalogo	= @viCatalogo_TM
						AND CE1.cat_campo		= CONVERT(VARCHAR(5), @piTipo_Mitigador)
						AND CE2.cat_catalogo	= @viCatalogo_TM
						AND CE1.cat_campo		<> CE2.cat_campo

					--Se insertan los valúos nuevos
					BEGIN TRANSACTION TRA_Ins_Valuacion
				
						INSERT INTO dbo.GAR_VALUACIONES_REALES
							  (cod_garantia_real, fecha_valuacion, cedula_empresa, cedula_perito, 
							  monto_ultima_tasacion_terreno, monto_ultima_tasacion_no_terreno, 
							  monto_tasacion_actualizada_terreno, monto_tasacion_actualizada_no_terreno, 
							  fecha_ultimo_seguimiento, monto_total_avaluo, cod_recomendacion_perito, 
							  cod_inspeccion_menor_tres_meses, fecha_construccion, Indicador_Tipo_Registro, 
							  Indicador_Actualizado_Calculo, Fecha_Semestre_Calculado, Tipo_Moneda_Tasacion)
						SELECT	 DISTINCT
							Consecutivo_Garantia_Real,
							Fecha_Valuacion,
							Cedula_Empresa,
							Cedula_Perito,
							Monto_Ultima_Tasacion_Terreno,
							Monto_Ultima_Tasacion_No_Terreno,
							Monto_Tasacion_Actualizada_Terreno,
							Monto_Tasacion_Actualizada_No_Terreno,
							Fecha_Ultimo_Seguimiento,
							Monto_Total_Avaluo,
							Recomendacion_Perito,
							Inspeccion_Menor_Tres_Meses,
							Fecha_Construccion,
							Indicador_Tipo_Registro,
							Indicador_Actualizado_Calculo,
							Fecha_Semestre_Calculado,
							Tipo_Moneda_Tasacion
						FROM	@TMP_AVALUOS_NORMALIZADOS
						WHERE	Tipo_Operacion = 1
							AND ((Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
								OR  (Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
						SET @viError = @@Error
					
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-1</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, se presentó un problema al insertar los avalúos.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -1
							
								ROLLBACK TRANSACTION TRA_Ins_Valuacion
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Ins_Valuacion
				
						
					/*SE OBTIENE EL TIPO DE CAMBIO APLICABLE A LA FECHA DEL AVALUO*/
					UPDATE TMP
					SET TMP.Tipo_Cambio = CIA.Tipo_Cambio
					FROM @TMP_AVALUOS_NORMALIZADOS TMP
						INNER JOIN (SELECT	MAX(CI1.Fecha_Hora) AS Fecha_Hora, TM1.Consecutivo_Garantia_Real
									FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CI1
										INNER JOIN @TMP_AVALUOS_NORMALIZADOS TM1
										ON CONVERT(DATE, TM1.Fecha_Valuacion) = CONVERT(DATE, CI1.Fecha_Hora)
									GROUP BY TM1.Consecutivo_Garantia_Real) TM2
						ON TM2.Consecutivo_Garantia_Real = TMP.Consecutivo_Garantia_Real
						INNER JOIN dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA
						ON CONVERT(DATE, CIA.Fecha_Hora) = CONVERT(DATE, TM2.Fecha_Hora)

						

					--Se actualizan los valúos existentes
					BEGIN TRANSACTION TRA_Act_Valuacion
				
						UPDATE	GVR
						SET		GVR.cedula_empresa						= TA1.Cedula_Empresa,
							GVR.cedula_perito							= TA1.Cedula_Perito,
							GVR.monto_ultima_tasacion_terreno			= TA1.Monto_Ultima_Tasacion_Terreno,
							GVR.monto_ultima_tasacion_no_terreno		= TA1.Monto_Ultima_Tasacion_No_Terreno,
							GVR.monto_tasacion_actualizada_terreno		= TA1.Monto_Tasacion_Actualizada_Terreno,
							GVR.monto_tasacion_actualizada_no_terreno	= TA1.Monto_Tasacion_Actualizada_No_Terreno,
							GVR.fecha_ultimo_seguimiento				= TA1.Fecha_Ultimo_Seguimiento,
							GVR.monto_total_avaluo						= TA1.Monto_Total_Avaluo,
							GVR.cod_recomendacion_perito				= TA1.Recomendacion_Perito,
							GVR.cod_inspeccion_menor_tres_meses			= TA1.Inspeccion_Menor_Tres_Meses,
							GVR.fecha_construccion						= TA1.Fecha_Construccion,
							GVR.Indicador_Tipo_Registro					= TA1.Indicador_Tipo_Registro,
							GVR.Indicador_Actualizado_Calculo			= TA1.Indicador_Actualizado_Calculo,
							GVR.Fecha_Semestre_Calculado				= TA1.Fecha_Semestre_Calculado,
							GVR.Tipo_Moneda_Tasacion					= TA1.Tipo_Moneda_Tasacion
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Operacion		= 2
							AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
								OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-2</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, se presentó un problema al actualizar los avalúos.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -2
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion
					

					/*SE COLONIZA EL MONTO TOTAL DEL AVALUO: MONEDA COLONES*/
					BEGIN TRANSACTION TRA_Act_Valuacion_MTA_MC
										
						UPDATE	GVR
						SET		GVR.Monto_Total_Avaluo_Colonizado = TA1.Monto_Total_Avaluo
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Moneda_Tasacion = 1
						
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-3</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible colonizar el monto total del avalúo, se presentó un problema en el cálculo (moneda colones).</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -3
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion_MTA_MC
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion_MTA_MC


					/*SE COLONIZA EL MONTO TOTAL DEL AVALUO: MONEDA DOLARES*/
					BEGIN TRANSACTION TRA_Act_Valuacion_MTA_MD
										
						UPDATE	GVR
						SET		GVR.Monto_Total_Avaluo_Colonizado = CONVERT(MONEY, ISNULL((TA1.Monto_Total_Avaluo * TA1.Tipo_Cambio), 0))
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Moneda_Tasacion = 2
						
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-3</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible colonizar el monto total del avalúo, se presentó un problema en el cálculo (moneda dólares).</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -3
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion_MTA_MD
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion_MTA_MD

					
					--Se actualiza el tipo de bien y el tipo de mitigador
					BEGIN TRANSACTION TRA_Act_Gar
				
					UPDATE	GGR
					SET		GGR.cod_tipo_bien = TA1.Tipo_Bien
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN @TMP_AVALUOS_NORMALIZADOS TA1
						ON TA1.Consecutivo_Garantia_Real = GGR.cod_garantia_real
				
					UPDATE	GRO
					SET		GRO.cod_tipo_mitigador = TA1.Tipo_Mitigador_Riesgo
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
						INNER JOIN	@TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Operacion = GRO.cod_operacion
						AND TOR.Consecutivo_Garantia_Real = GRO.cod_garantia_real
						INNER JOIN @TMP_AVALUOS_NORMALIZADOS TA1
						ON TA1.Consecutivo_Garantia_Real = TOR.Consecutivo_Garantia_Real
				
					SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-3</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible actualizar el tipo de bien y el tipo de mitigador de riesgo.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -3
							
								ROLLBACK TRANSACTION TRA_Act_Gar
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Gar
				
					--Se insertan las pistas de auditoria
					BEGIN TRANSACTION TRA_Ins_Bita
				
						INSERT INTO dbo.GAR_BITACORA
						  (des_tabla, cod_usuario, cod_ip, cod_oficina, cod_operacion, fecha_hora, cod_consulta, 
						   cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, cod_consulta2, 
						   des_campo_afectado, est_anterior_campo_afectado, est_actual_campo_afectado)
						SELECT	 Descripcion_Tabla, 
							Codigo_Usuario, 
							Cod_IP, 
							Codigo_Oficina, 
							Cod_Operacion, 
							Fecha_Hora,
							Codigo_Consulta, 
							Codigo_Tipo_Garantia, 
							Codigo_Garantia, 
							Codigo_Operacion_Crediticia,
							Codigo_Consulta2, 
							Descripcion_Campo_Afectado, 
							Estado_Anterior_Campo_Afectado,
							Estado_Actual_Campo_Afectado		
						FROM	@TMP_BITACORA
				
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-4</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible insertar las pistas de auditoria.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -4
							
								ROLLBACK TRANSACTION TRA_Ins_Bita
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Ins_Bita
				END
				ELSE
				BEGIN
					SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-5</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, debido a que existe una fecha de valuación más reciente.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

					RETURN -5
				END
			END
		END
		ELSE --Se aplica la normalización a aquellas garantías prendarias
		BEGIN

			--Se selecciona el consecutivo de aquellas prendas que se encuentran duplicadas
			INSERT INTO @TMP_PRENDAS_DUPLICADAS (
				Consecutivo_Garantia_Real,
				Codigo_Bien_Bitacora)
			SELECT	DISTINCT
				GGR.cod_garantia_real,
				CASE 
					WHEN GGR.cod_tipo_garantia_real = 1 THEN '[H] '  + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')  
					WHEN GGR.cod_tipo_garantia_real = 2 THEN '[CH] ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_partido),'') + '-' + COALESCE(GGR.numero_finca,'')
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND (GGR.cod_clase_garantia <> 38) AND (GGR.cod_clase_garantia <> 43)) THEN '[P] '  + COALESCE(GGR.cod_clase_bien,'') + '-' + COALESCE(GGR.num_placa_bien,'') 
					WHEN ((GGR.cod_tipo_garantia_real = 3) AND ((GGR.cod_clase_garantia = 38) OR (GGR.cod_clase_garantia = 43))) THEN '[P] '  + COALESCE(GGR.num_placa_bien,'') 
					ELSE '[-] ' + @psCodigo_Bien
				END	AS Codigo_Bien_Bitacora
			FROM	dbo.GAR_GARANTIA_REAL GGR 
			WHERE	GGR.cod_clase_garantia	= @viClaseGarantia 
				AND GGR.num_placa_bien		= @vsIdentificacionGarantia
				AND EXISTS (SELECT	1	
							FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO
								INNER JOIN @TMP_OPERACIONES_RELACIONADAS TMP
								ON GRO.cod_operacion = TMP.Consecutivo_Operacion
							WHERE	GRO.cod_garantia_real = GGR.cod_garantia_real)
		
			--Se elimina el registro del avalúo de la garantía afectada
			DELETE	FROM @TMP_PRENDAS_DUPLICADAS
			WHERE	Consecutivo_Garantia_Real = @piConsecutivo_Garantia_Real
		
			SET		@viCantidad_Registros = (SELECT COUNT(*) FROM @TMP_PRENDAS_DUPLICADAS)
		
			IF(@viCantidad_Registros > 0)
			BEGIN
			
				--Se obtiene la fecha de valuación más reciente registrada para las garantías a ser normalizadas
				SELECT	@vdFecha_Avaluo_Reciente = MAX(GVR.fecha_valuacion)
				FROM	dbo.GAR_VALUACIONES_REALES GVR 
					INNER JOIN @TMP_PRENDAS_DUPLICADAS TPD
					ON TPD.Consecutivo_Garantia_Real = GVR.cod_garantia_real
				WHERE	GVR.Indicador_Tipo_Registro = 1
				GROUP BY GVR.fecha_valuacion
			
				--Se verifica que no exista una fecha de valuación mayor a la tomada como base para la normalización
				IF(COALESCE(@vdFecha_Avaluo_Reciente, @vdFecha_Valuacion) <= @vdFecha_Valuacion)
				BEGIN
			
					--Se obtiene la información del avalúo a ser ingresado
					INSERT INTO @TMP_AVALUOS_NORMALIZADOS (
						Consecutivo_Garantia_Real,
						Fecha_Valuacion,
						Cedula_Empresa,
						Cedula_Perito,
						Monto_Ultima_Tasacion_Terreno,
						Monto_Ultima_Tasacion_No_Terreno,
						Monto_Tasacion_Actualizada_Terreno,
						Monto_Tasacion_Actualizada_No_Terreno,
						Fecha_Ultimo_Seguimiento,
						Monto_Total_Avaluo,
						Recomendacion_Perito,
						Inspeccion_Menor_Tres_Meses,
						Fecha_Construccion,
						Indicador_Tipo_Registro,
						Indicador_Actualizado_Calculo,
						Fecha_Semestre_Calculado,
						Tipo_Bien,
						Tipo_Mitigador_Riesgo,	
						Codigo_Bien_Bitacora,
						Sentencia_Consulta_Ins,
						Sentencia_Consulta_Act,
						Tipo_Operacion,
						Usuario,
						Tipo_Moneda_Tasacion,
						Monto_Total_Avaluo_Colonizado,
						Tipo_Cambio)
					SELECT	DISTINCT
						TPD.Consecutivo_Garantia_Real,
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
						GVR.Indicador_Tipo_Registro,
						GVR.Indicador_Actualizado_Calculo,
						GVR.Fecha_Semestre_Calculado,
						@piTipo_Bien AS Tipo_Bien,
						@piTipo_Mitigador AS Tipo_Mitigador_Riesgo,
						TPD.Codigo_Bien_Bitacora AS Codigo_Bien_Bitacora,
						('INSERT INTO GAR_VALUACIONES_REALES (cod_garantia_real,fecha_valuacion,cedula_empresa,cedula_perito,monto_ultima_tasacion_terreno,monto_ultima_tasacion_no_terreno,monto_tasacion_actualizada_terreno,monto_tasacion_actualizada_no_terreno,fecha_ultimo_seguimiento,monto_total_avaluo,cod_recomendacion_perito,cod_inspeccion_menor_tres_meses,fecha_construccion) VALUES(' +
						CAST(TPD.Consecutivo_Garantia_Real AS VARCHAR(100)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_valuacion, 101) + ',' +
						COALESCE(GVR.cedula_empresa, '') + ',' +
						COALESCE(GVR.cedula_perito, '') + ',' +
						CAST(GVR.monto_ultima_tasacion_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_ultima_tasacion_no_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_tasacion_actualizada_terreno AS VARCHAR(100)) + ',' +
						CAST(GVR.monto_tasacion_actualizada_no_terreno AS VARCHAR(100)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_ultimo_seguimiento, 101) + ',' +
						CAST(GVR.monto_total_avaluo AS VARCHAR(100)) + ',' +
						CAST(GVR.cod_recomendacion_perito AS VARCHAR(5)) + ',' +
						CAST(GVR.cod_inspeccion_menor_tres_meses AS VARCHAR(5)) + ',' +
						CONVERT(VARCHAR(10), GVR.fecha_construccion, 101) + ')') AS Sentencia_Consulta_Ins,
						('UPDATE GAR_VALUACIONES_REALES SET cedula_perito = ' + CHAR(39) + 
						 +  COALESCE(GVR.cedula_perito, '') + CHAR(39) + 
						 ', monto_ultima_tasacion_terreno = convert(decimal(18,2), ' + CHAR(39) + 
						 CAST(GVR.monto_ultima_tasacion_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_ultima_tasacion_no_terreno = convert(decimal(18,2), ' + CHAR(39) +  
						 CAST(GVR.monto_ultima_tasacion_no_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_tasacion_actualizada_terreno = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_tasacion_actualizada_terreno AS VARCHAR(100)) + CHAR(39) + 
						 '), monto_tasacion_actualizada_no_terreno = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_tasacion_actualizada_no_terreno AS VARCHAR(100)) + CHAR(39) +
						 '), fecha_ultimo_seguimiento = ' + CHAR(39) +
						 CONVERT(VARCHAR(10), GVR.fecha_ultimo_seguimiento, 101) + CHAR(39) +
						 ', monto_total_avaluo = convert(decimal(18,2), ' + CHAR(39) +
						 CAST(GVR.monto_total_avaluo AS VARCHAR(100)) + CHAR(39) +
						 '), cod_recomendacion_perito = ' + CAST(GVR.cod_recomendacion_perito AS VARCHAR(5)) +
						 ', cod_inspeccion_menor_tres_meses = ' + CAST(GVR.cod_inspeccion_menor_tres_meses AS VARCHAR(5)) + 
						 ', fecha_construccion ='  + CHAR(39) + 
						 CONVERT(VARCHAR(10), GVR.fecha_construccion, 101) + CHAR(39) +
						 ' WHERE cod_garantia_real = ' + CAST(TPD.Consecutivo_Garantia_Real AS VARCHAR(100)) + 
						 ' AND fecha_valuacion = ' + CHAR(39) +
						 CONVERT(VARCHAR(10), GVR.fecha_valuacion, 101) + CHAR(39)) AS Sentencia_Consulta_Act,
						NULL AS Tipo_Operacion,
						@vsIdentificacion_Usuario AS Usuario,
						GVR.Tipo_Moneda_Tasacion,
						GVR.Monto_Total_Avaluo_Colonizado,
						NULL
					FROM	@TMP_PRENDAS_DUPLICADAS TPD,
						dbo.GAR_VALUACIONES_REALES GVR 
					WHERE GVR.cod_garantia_real = @piConsecutivo_Garantia_Real
						AND GVR.fecha_valuacion = @vdFecha_Valuacion

					--Se actualiza el campo correspondiente al tip ode operación, asignando 1 si se trata de inserción de registro
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 1
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND NOT EXISTS (SELECT	1
										FROM	dbo.GAR_VALUACIONES_REALES GVR 
										WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
											AND GVR.fecha_valuacion		= @vdFecha_Valuacion)
				
					--Se actualiza el campo correspondiente al tip ode operación, asignando 2 si se trata de modificación de registro
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 2
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND EXISTS (SELECT	1
									FROM	dbo.GAR_VALUACIONES_REALES GVR 
									WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
										AND GVR.fecha_valuacion		= @vdFecha_Valuacion)

					--Se actualiza el campo correspondiente al tipo de operación, asignando 0 si existe algún registro cuya fecha de avalúo sea mayor a la referente
					UPDATE	TA1
					SET		TA1.Tipo_Operacion = 0
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
					WHERE	TA1.Usuario	= @vsIdentificacion_Usuario
						AND TA1.Fecha_Valuacion < (	SELECT	TOP 1
															MAX(GVR.fecha_valuacion)
													FROM	dbo.GAR_VALUACIONES_REALES GVR 
													WHERE	GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
													GROUP	BY GVR.fecha_valuacion)

				
					--Se obtienen los avalúos existentes que deberán de ser actualizados
					INSERT INTO @TMP_AVALUOS_ACTUALES (
						Consecutivo_Garantia_Real,
						Fecha_Valuacion,
						Cedula_Empresa,
						Cedula_Perito,
						Monto_Ultima_Tasacion_Terreno,
						Monto_Ultima_Tasacion_No_Terreno,
						Monto_Tasacion_Actualizada_Terreno,
						Monto_Tasacion_Actualizada_No_Terreno,
						Fecha_Ultimo_Seguimiento,
						Monto_Total_Avaluo,
						Recomendacion_Perito,
						Inspeccion_Menor_Tres_Meses,
						Fecha_Construccion,
						Indicador_Tipo_Registro,
						Indicador_Actualizado_Calculo,
						Fecha_Semestre_Calculado,
						Usuario,
						Tipo_Moneda_Tasacion,
						Monto_Total_Avaluo_Colonizado)
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
						0 AS Indicador_Tipo_Registro,
						GVR.Indicador_Actualizado_Calculo,
						GVR.Fecha_Semestre_Calculado,
						TA1.Usuario,
						GVR.Tipo_Moneda_Tasacion,
						GVR.Monto_Total_Avaluo_Colonizado
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN dbo.GAR_VALUACIONES_REALES GVR 
						ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
						AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND TA1.Usuario			= @vsIdentificacion_Usuario
				
				
					--Se actualiza el indicador del tipo de registro del avalúo, se obtienen los avalúos más recientes
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Indicador_Tipo_Registro = 2
					FROM	@TMP_AVALUOS_ACTUALES TMP
						INNER JOIN dbo.GAR_VALUACIONES_REALES GV1
						ON GV1.cod_garantia_real = TMP.Consecutivo_Garantia_Real
						INNER JOIN 
						(SELECT		cod_garantia_real, fecha_valuacion = MAX([fecha_valuacion])
						 FROM		dbo.GAR_VALUACIONES_REALES
						 GROUP		BY cod_garantia_real) GV2
							ON	GV2.cod_garantia_real	= GV1.cod_garantia_real
							AND GV2.fecha_valuacion		= GV1.fecha_valuacion

					--Se obtienen los penúltimos avalúos
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Indicador_Tipo_Registro = 3
					FROM	@TMP_AVALUOS_ACTUALES TMP
						INNER JOIN dbo.GAR_VALUACIONES_REALES GV1
						ON GV1.cod_garantia_real = TMP.Consecutivo_Garantia_Real
						INNER JOIN 
						(SELECT		cod_garantia_real, fecha_valuacion = MAX([fecha_valuacion])
						 FROM		dbo.GAR_VALUACIONES_REALES
						 WHERE		Indicador_Tipo_Registro = 0
						 GROUP		BY cod_garantia_real) GV2
							ON	GV2.cod_garantia_real	= GV1.cod_garantia_real
						AND GV2.fecha_valuacion		= GV1.fecha_valuacion
				
					--Se obtienen los avalúos que son iguales a los registrados en el SICC
					--Se asigna el mínimo monto de la fecha del avalúo más reciente para prendas, con clase distinta a 38 o 43
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
							Indicador_Tipo_Registro = 1,
							Tipo_Moneda_Tasacion	= TMP.Tipo_Moneda_Tasacion
					FROM	@TMP_AVALUOS_ACTUALES GV1
						INNER JOIN (
						SELECT	DISTINCT 
							GGR.cod_garantia_real, 
							CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
							GHC.monto_total_avaluo,
							GHC.Tipo_Moneda_Tasacion
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN (	SELECT	TOP 100 PERCENT 
												GGR.cod_clase_garantia,
												GGR.Identificacion_Sicc,
												MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
												MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo,
												MG3.prmgt_pco_mongar AS Tipo_Moneda_Tasacion
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
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, 
																MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing, MG2.prmgt_pco_mongar
															FROM	
															(		SELECT	MG1.prmgt_pcoclagar,
																		MG1.prmgt_pnuidegar,
																		CASE 
																			WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																			WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																			ELSE '19000101'
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																				OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																				OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	((MG1.prmgt_pcoclagar BETWEEN 30 AND 37)
																				OR (MG1.prmgt_pcoclagar BETWEEN 39 AND 42)
																				OR (MG1.prmgt_pcoclagar BETWEEN 44 AND 69))
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
															GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pfeavaing, MG2.prmgt_pco_mongar) MG3
											ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
											AND MG3.prmgt_pnuidegar = MGT.prmgt_pnuidegar
											AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
											WHERE	((GGR.cod_clase_garantia BETWEEN 30 AND 37)
														OR (GGR.cod_clase_garantia BETWEEN 39 AND 42)
														OR (GGR.cod_clase_garantia BETWEEN 44 AND 69))
											GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, MG3.prmgt_pco_mongar
										) GHC
							ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
							AND GHC.Identificacion_Sicc = GGR.Identificacion_Sicc
						WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
					AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)

				
				
					--Se asigna el mínimo monto de la fecha del avalúo más reciente para prendas, con clase igual a 38 o 43
					UPDATE	@TMP_AVALUOS_ACTUALES
					SET		Monto_Total_Avaluo		= TMP.monto_total_avaluo,
							Indicador_Tipo_Registro = 1,
							Tipo_Moneda_Tasacion    = TMP.Tipo_Moneda_Tasacion
					FROM	@TMP_AVALUOS_ACTUALES GV1
						INNER JOIN (
						SELECT	DISTINCT 
							GGR.cod_garantia_real, 
							CONVERT(DATETIME, GHC.fecha_valuacion) AS fecha_valuacion, 
							GHC.monto_total_avaluo,
							GHC.Tipo_Moneda_Tasacion 
						FROM	dbo.GAR_GARANTIA_REAL GGR
							INNER JOIN (	SELECT	TOP 100 PERCENT 
												GGR.cod_clase_garantia,
												GGR.Identificacion_Sicc,
												GGR.Identificacion_Alfanumerica_Sicc,
												MAX(MGT.prmgt_pfeavaing) AS fecha_valuacion,
												MIN(MG3.prmgt_pmoavaing) AS monto_total_avaluo,
												MG3.prmgt_pco_mongar AS Tipo_Moneda_Tasacion
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
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
											INNER JOIN (SELECT	MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, 
																MG2.prmgt_pfeavaing, MIN(MG2.prmgt_pmoavaing) AS prmgt_pmoavaing, MG2.prmgt_pco_mongar
															FROM	
															(		SELECT	MG1.prmgt_pcoclagar,
																		MG1.prmgt_pnuidegar,
																		MG1.prmgt_pnuide_alf,
																		CASE 
																			WHEN MG1.prmgt_pfeavaing = 0 THEN '19000101' 
																			WHEN ISDATE(CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing)) = 1 THEN CONVERT(VARCHAR(10), MG1.prmgt_pfeavaing,103)
																			ELSE '19000101'
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	((MG1.prmgt_pcoclagar = 38)
																				OR (MG1.prmgt_pcoclagar = 43))
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin >= @viFechaActualEntera
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
																		END AS prmgt_pfeavaing,
																		MG1.prmgt_pmoavaing,
																		MG1.prmgt_pco_mongar
																	FROM	dbo.GAR_SICC_PRMGT MG1
																	WHERE	((MG1.prmgt_pcoclagar = 38)
																				OR (MG1.prmgt_pcoclagar = 43))
																		AND MG1.prmgt_estado = 'A'
																		AND EXISTS (SELECT	1
																					FROM	dbo.GAR_SICC_PRMCA MCA
																					WHERE	MCA.prmca_estado = 'A'
																						AND MCA.prmca_pfe_defin < @viFechaActualEntera
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
															GROUP BY MG2.prmgt_pcoclagar, MG2.prmgt_pnuidegar, MG2.prmgt_pnuide_alf, MG2.prmgt_pfeavaing, MG2.prmgt_pco_mongar) MG3
											ON MG3.prmgt_pcoclagar = MGT.prmgt_pcoclagar
											AND COALESCE(MG3.prmgt_pnuidegar, 0) = COALESCE(MGT.prmgt_pnuidegar, 0)
											AND COALESCE(MG3.prmgt_pnuide_alf, '') = COALESCE(MGT.prmgt_pnuide_alf, '')
											AND MG3.prmgt_pfeavaing = MGT.prmgt_pfeavaing
											WHERE	((GGR.cod_clase_garantia = 38)
														OR (GGR.cod_clase_garantia = 43))
											GROUP BY GGR.cod_clase_garantia, GGR.Identificacion_Sicc, GGR.Identificacion_Alfanumerica_Sicc, MG3.prmgt_pco_mongar
										) GHC
							ON GHC.cod_clase_garantia = GGR.cod_clase_garantia
							AND COALESCE(GHC.Identificacion_Sicc, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
							AND COALESCE(GHC.Identificacion_Alfanumerica_Sicc, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
						WHERE	GHC.fecha_valuacion > '19000101') TMP
					ON TMP.cod_garantia_real = GV1.Consecutivo_Garantia_Real
					AND GV1.Fecha_Valuacion = CONVERT(DATETIME, TMP.fecha_valuacion)
				
					--Se obtienen las operaciones a las cuales están asociadas las garantías
					INSERT INTO @TMP_OPERACIONES_RESPALDADAS (
						Consecutivo_Operacion, 
						Codigo_Operacion,
						Tipo_Bien,
						Tipo_Mitigador,
						Consecutivo_Garantia_Real)
					SELECT	DISTINCT
						GRO.Codigo_Operacion,
						(CAST(GRO.Codigo_Oficina AS VARCHAR(5))  + '-' + 
						 CAST(GRO.Codigo_Moneda AS VARCHAR(5))   + '-' + 
						 CAST(GRO.Codigo_Producto AS VARCHAR(5)) + '-' + 
						 CAST(GRO.Operacion AS VARCHAR(20))) AS Codigo_Operacion,
						GRO.Codigo_Tipo_Bien,
						GRO.Codigo_Tipo_Mitigador,
						GRO.Codigo_Garantia_Real
					FROM	@TMP_PRENDAS_DUPLICADAS TPD
						INNER JOIN	dbo.TMP_GARANTIAS_REALES_X_OPERACION GRO 
						ON GRO.Codigo_Garantia_Real = TPD.Consecutivo_Garantia_Real
				
					--Se generan las pistas de auditoría que se ingresarán en la bitácora transaccional
					INSERT INTO @TMP_BITACORA (
						Descripcion_Tabla, Codigo_Usuario, Cod_IP, Codigo_Oficina, Cod_Operacion, Fecha_Hora,
						Codigo_Consulta, Codigo_Tipo_Garantia, Codigo_Garantia, Codigo_Operacion_Crediticia,
						Codigo_Consulta2, Descripcion_Campo_Afectado, Estado_Anterior_Campo_Afectado,
						Estado_Actual_Campo_Afectado)
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_valuacion', '-', CONVERT(VARCHAR(10), TA1.Fecha_Valuacion, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion = 1
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_empresa', '-', TA1.Cedula_Empresa
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion = 1
						AND TA1.Cedula_Empresa IS NOT NULL	
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
					
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_perito', '-', TA1.Cedula_Perito
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion	= 1
						AND TA1.Cedula_Perito	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion					= 1
						AND TA1.Monto_Ultima_Tasacion_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_no_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion						= 1
						AND TA1.Monto_Ultima_Tasacion_No_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion						= 1
						AND TA1.Monto_Tasacion_Actualizada_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_no_terreno', '-', CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion							= 1
						AND TA1.Monto_Tasacion_Actualizada_No_Terreno	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_ultimo_seguimiento', '-', CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion				= 1
						AND TA1.Fecha_Ultimo_Seguimiento	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_total_avaluo', '-', CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion		= 1
						AND TA1.Monto_Total_Avaluo	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_recomendacion_perito', '-', COALESCE(cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real,
						dbo.CAT_ELEMENTO 	
					WHERE	TA1.Tipo_Operacion			= 1
						AND TA1.Recomendacion_Perito	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND cat_catalogo				= @viCatalogo_RP
						AND cat_campo					= CONVERT(VARCHAR(5), TA1.Recomendacion_Perito)

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_inspeccion_menor_tres_meses', '-', COALESCE(cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real,
						dbo.CAT_ELEMENTO 	
					WHERE	TA1.Tipo_Operacion				= 1
						AND TA1.Inspeccion_Menor_Tres_Meses IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND cat_catalogo					= @viCatalogo_IMTM
						AND cat_campo						= CONVERT(VARCHAR(5), TA1.Inspeccion_Menor_Tres_Meses)

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), TA1.Sentencia_Consulta_Ins, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_construccion', '-', CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101)
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
					WHERE	TA1.Tipo_Operacion		= 1
						AND TA1.Fecha_Construccion	IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_empresa', COALESCE(TAA.Cedula_Empresa, '-'), COALESCE(TA1.Cedula_Empresa, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion = 2
						AND COALESCE(TA1.Cedula_Empresa, '-') <> COALESCE(TAA.Cedula_Empresa, '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
					
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cedula_perito', COALESCE(TAA.Cedula_Perito, '-'), COALESCE(TA1.Cedula_Perito, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(TA1.Cedula_Perito, '-')	<> COALESCE(TAA.Cedula_Perito, '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_ultima_tasacion_no_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_No_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Ultima_Tasacion_No_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Ultima_Tasacion_No_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_tasacion_actualizada_no_terreno', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_No_Terreno), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Tasacion_Actualizada_No_Terreno), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Tasacion_Actualizada_No_Terreno), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_ultimo_seguimiento', COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Ultimo_Seguimiento, 101), '-'), COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Ultimo_Seguimiento, 101), '-') <> COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Ultimo_Seguimiento, 101), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'monto_total_avaluo', COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Total_Avaluo), '-'), COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion	= 2
						AND COALESCE(CONVERT(VARCHAR(100), TA1.Monto_Total_Avaluo), '-') <> COALESCE(CONVERT(VARCHAR(100), TAA.Monto_Total_Avaluo), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_recomendacion_perito', COALESCE(CE2.cat_descripcion, '-'), COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real 
						LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1 	
						ON CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Recomendacion_Perito)
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
						LEFT OUTER JOIN  dbo.CAT_ELEMENTO CE2 	
						ON CE2.cat_campo = CONVERT(VARCHAR(5), TAA.Recomendacion_Perito)
					WHERE	TA1.Tipo_Operacion			= 2
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND CE1.cat_catalogo				= @viCatalogo_RP
						AND CE2.cat_catalogo				= @viCatalogo_RP
						AND COALESCE(CE1.cat_descripcion, '-') <> COALESCE(CE2.cat_descripcion, '-')

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'cod_inspeccion_menor_tres_meses', COALESCE(CE2.cat_descripcion, '-'), COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN dbo.CAT_ELEMENTO CE1 	
						ON CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Inspeccion_Menor_Tres_Meses)
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
						LEFT OUTER JOIN  dbo.CAT_ELEMENTO CE2 	
						ON CE2.cat_campo = CONVERT(VARCHAR(5), TAA.Inspeccion_Menor_Tres_Meses)
					WHERE	TA1.Tipo_Operacion				= 2
						AND TA1.Inspeccion_Menor_Tres_Meses IS NOT NULL
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						AND CE1.cat_catalogo				= @viCatalogo_IMTM
						AND CE2.cat_catalogo				= @viCatalogo_IMTM
						AND COALESCE(CE1.cat_descripcion, '-') <> COALESCE(CE2.cat_descripcion, '-')

					UNION ALL
				
					SELECT	
						'GAR_VALUACIONES_REALES' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 2, GETDATE(), TA1.Sentencia_Consulta_Act, 2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion,
						@vsTexto_Consulta, 'fecha_construccion', COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Construccion, 101), '-'), COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101), '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						INNER JOIN @TMP_AVALUOS_ACTUALES TAA
						ON TAA.Consecutivo_Garantia_Real	= TA1.Consecutivo_Garantia_Real
						AND TAA.Fecha_Valuacion				= TA1.Fecha_Valuacion
					WHERE	TA1.Tipo_Operacion		= 2
						AND COALESCE(CONVERT(VARCHAR(10), TA1.Fecha_Construccion, 101), '-') <> COALESCE(CONVERT(VARCHAR(10), TAA.Fecha_Construccion, 101), '-')
						AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
							OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))

					UNION ALL

					SELECT	
						'GAR_GARANTIA_REAL' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), 
						'UPDATE GAR_GARANTIA_REAL SET cod_tipo_bien = ' + CONVERT(VARCHAR(5), @piTipo_Bien) + ' WHERE cod_garantia_real = ' + CONVERT(VARCHAR(100), TOR.Consecutivo_Garantia_Real), 
						2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion, @vsTexto_Consulta, 'cod_tipo_bien', COALESCE(CE2.cat_descripcion, '-'), 
						COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE1 
						ON	CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Tipo_Bien)
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE2 
						ON CE2.cat_catalogo = CONVERT(VARCHAR(5), TOR.Tipo_Bien)
					WHERE	CE1.cat_catalogo	= @viCatalogo_TB
						AND CE1.cat_campo		= CONVERT(VARCHAR(5), @piTipo_Bien)
						AND CE2.cat_catalogo	= @viCatalogo_TB
						AND CE1.cat_campo		<> CE2.cat_campo

					UNION ALL
				
					SELECT	
						'GAR_GARANTIAS_REALES_X_OPERACION' AS Descripcion_Tabla, @vsIdentificacion_Usuario, @psIP,
						NULL, 1, GETDATE(), 
						'UPDATE GAR_GARANTIAS_REALES_X_OPERACION SET cod_tipo_mitigador = ' + CONVERT(VARCHAR(5), @piTipo_Mitigador) + ' WHERE cod_operacion =' + CONVERT(VARCHAR(100), TOR.Consecutivo_Operacion) + 'AND cod_garantia_real = ' + CONVERT(VARCHAR(100), TOR.Consecutivo_Garantia_Real), 
						2, TA1.Codigo_Bien_Bitacora, TOR.Codigo_Operacion, @vsTexto_Consulta, 'cod_tipo_mitigador', COALESCE(CE2.cat_descripcion, '-'), 
						COALESCE(CE1.cat_descripcion, '-')
					FROM	@TMP_AVALUOS_NORMALIZADOS TA1
						INNER JOIN @TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Garantia_Real = TA1.Consecutivo_Garantia_Real
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE1 
						ON	CE1.cat_campo = CONVERT(VARCHAR(5), TA1.Tipo_Mitigador_Riesgo)
						LEFT OUTER JOIN	dbo.CAT_ELEMENTO CE2 
						ON CE2.cat_catalogo = CONVERT(VARCHAR(5), TOR.Tipo_Mitigador)
					WHERE	CE1.cat_catalogo	= @viCatalogo_TM
						AND CE1.cat_campo		= CONVERT(VARCHAR(5), @piTipo_Mitigador)
						AND CE2.cat_catalogo	= @viCatalogo_TM
						AND CE1.cat_campo		<> CE2.cat_campo

					--Se insertan los valúos nuevos
					BEGIN TRANSACTION TRA_Ins_Valuacion
				
						INSERT INTO dbo.GAR_VALUACIONES_REALES
							  (cod_garantia_real, fecha_valuacion, cedula_empresa, cedula_perito, 
							  monto_ultima_tasacion_terreno, monto_ultima_tasacion_no_terreno, 
							  monto_tasacion_actualizada_terreno, monto_tasacion_actualizada_no_terreno, 
							  fecha_ultimo_seguimiento, monto_total_avaluo, cod_recomendacion_perito, 
							  cod_inspeccion_menor_tres_meses, fecha_construccion, Indicador_Tipo_Registro, 
							  Indicador_Actualizado_Calculo, Fecha_Semestre_Calculado)
						SELECT	 DISTINCT
							Consecutivo_Garantia_Real,
							Fecha_Valuacion,
							Cedula_Empresa,
							Cedula_Perito,
							Monto_Ultima_Tasacion_Terreno,
							Monto_Ultima_Tasacion_No_Terreno,
							Monto_Tasacion_Actualizada_Terreno,
							Monto_Tasacion_Actualizada_No_Terreno,
							Fecha_Ultimo_Seguimiento,
							Monto_Total_Avaluo,
							Recomendacion_Perito,
							Inspeccion_Menor_Tres_Meses,
							Fecha_Construccion,
							Indicador_Tipo_Registro,
							Indicador_Actualizado_Calculo,
							Fecha_Semestre_Calculado
						FROM	@TMP_AVALUOS_NORMALIZADOS
						WHERE	Tipo_Operacion = 1
							AND ((Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
								OR  (Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
				
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-6</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, se presentó un problema al insertar los avalúos.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -6
							
								ROLLBACK TRANSACTION TRA_Ins_Valuacion
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Ins_Valuacion
				
					
					/*SE OBTIENE EL TIPO DE CAMBIO APLICABLE A LA FECHA DEL AVALUO*/
					UPDATE TMP
					SET TMP.Tipo_Cambio = CIA.Tipo_Cambio
					FROM @TMP_AVALUOS_NORMALIZADOS TMP
						INNER JOIN (SELECT	MAX(CI1.Fecha_Hora) AS Fecha_Hora, TM1.Consecutivo_Garantia_Real
									FROM	dbo.CAT_INDICES_ACTUALIZACION_AVALUO CI1
										INNER JOIN @TMP_AVALUOS_NORMALIZADOS TM1
										ON CONVERT(DATE, TM1.Fecha_Valuacion) = CONVERT(DATE, CI1.Fecha_Hora)
									GROUP BY TM1.Consecutivo_Garantia_Real) TM2
						ON TM2.Consecutivo_Garantia_Real = TMP.Consecutivo_Garantia_Real
						INNER JOIN dbo.CAT_INDICES_ACTUALIZACION_AVALUO CIA
						ON CONVERT(DATE, CIA.Fecha_Hora) = CONVERT(DATE, TM2.Fecha_Hora)
						

					--Se actualizan los avalúos existentes
					BEGIN TRANSACTION TRA_Act_Valuacion
				
						UPDATE	GVR
						SET		GVR.cedula_empresa						= TA1.Cedula_Empresa,
							GVR.cedula_perito							= TA1.Cedula_Perito,
							GVR.monto_ultima_tasacion_terreno			= TA1.Monto_Ultima_Tasacion_Terreno,
							GVR.monto_ultima_tasacion_no_terreno		= TA1.Monto_Ultima_Tasacion_No_Terreno,
							GVR.monto_tasacion_actualizada_terreno		= TA1.Monto_Tasacion_Actualizada_Terreno,
							GVR.monto_tasacion_actualizada_no_terreno	= TA1.Monto_Tasacion_Actualizada_No_Terreno,
							GVR.fecha_ultimo_seguimiento				= TA1.Fecha_Ultimo_Seguimiento,
							GVR.monto_total_avaluo						= TA1.Monto_Total_Avaluo,
							GVR.cod_recomendacion_perito				= TA1.Recomendacion_Perito,
							GVR.cod_inspeccion_menor_tres_meses			= TA1.Inspeccion_Menor_Tres_Meses,
							GVR.fecha_construccion						= TA1.Fecha_Construccion,
							GVR.Indicador_Tipo_Registro					= TA1.Indicador_Tipo_Registro,
							GVR.Indicador_Actualizado_Calculo			= TA1.Indicador_Actualizado_Calculo,
							GVR.Fecha_Semestre_Calculado				= TA1.Fecha_Semestre_Calculado,
							GVR.Tipo_Moneda_Tasacion					= TA1.Tipo_Moneda_Tasacion
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Operacion		= 2
							AND ((TA1.Consecutivo_Garantia_Real < @piConsecutivo_Garantia_Real)
								OR  (TA1.Consecutivo_Garantia_Real > @piConsecutivo_Garantia_Real))
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-7</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, se presentó un problema al actualizar los avalúos.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -7
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion
					
					/*SE COLONIZA EL MONTO TOTAL DEL AVALUO: MONEDA COLONES*/
					BEGIN TRANSACTION TRA_Act_Valuacion_MTA_MC
										
						UPDATE	GVR
						SET		GVR.Monto_Total_Avaluo_Colonizado = TA1.Monto_Total_Avaluo
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Moneda_Tasacion = 1
						
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-8</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible colonizar el monto total del avalúo, se presentó un problema en el cálculo (moneda colones).</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -8
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion_MTA_MC
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion_MTA_MC


					/*SE COLONIZA EL MONTO TOTAL DEL AVALUO: MONEDA DOLARES*/
					BEGIN TRANSACTION TRA_Act_Valuacion_MTA_MD
										
						UPDATE	GVR
						SET		GVR.Monto_Total_Avaluo_Colonizado = CONVERT(MONEY, ISNULL((TA1.Monto_Total_Avaluo * TA1.Tipo_Cambio), 0))
						FROM	dbo.GAR_VALUACIONES_REALES GVR 
							INNER JOIN	@TMP_AVALUOS_NORMALIZADOS TA1
							ON GVR.cod_garantia_real	= TA1.Consecutivo_Garantia_Real
							AND GVR.fecha_valuacion		= TA1.Fecha_Valuacion
						WHERE	TA1.Tipo_Moneda_Tasacion = 2
						
						
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-8</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible colonizar el monto total del avalúo, se presentó un problema en el cálculo (moneda dólares).</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -8
							
								ROLLBACK TRANSACTION TRA_Act_Valuacion_MTA_MD
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Valuacion_MTA_MD



					--Se actualiza el tipo de bien y el tipo de mitigador
					BEGIN TRANSACTION TRA_Act_Gar
				
					UPDATE	GGR
					SET		GGR.cod_tipo_bien = TA1.Tipo_Bien
					FROM	dbo.GAR_GARANTIA_REAL GGR 
						INNER JOIN @TMP_AVALUOS_NORMALIZADOS TA1
						ON TA1.Consecutivo_Garantia_Real = GGR.cod_garantia_real
				
					UPDATE	GRO
					SET		GRO.cod_tipo_mitigador = TA1.Tipo_Mitigador_Riesgo
					FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO 
						INNER JOIN	@TMP_OPERACIONES_RESPALDADAS TOR
						ON TOR.Consecutivo_Operacion = GRO.cod_operacion
						AND TOR.Consecutivo_Garantia_Real = GRO.cod_garantia_real
						INNER JOIN @TMP_AVALUOS_NORMALIZADOS TA1
						ON TA1.Consecutivo_Garantia_Real = TOR.Consecutivo_Garantia_Real
				
					SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-9</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible actualizar el tipo de bien y el tipo de mitigador de riesgo.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -9
							
								ROLLBACK TRANSACTION TRA_Act_Gar
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Act_Gar
				
					--Se insertan las pistas de auditoria
					BEGIN TRANSACTION TRA_Ins_Bita
				
						INSERT INTO dbo.GAR_BITACORA
						  (des_tabla, cod_usuario, cod_ip, cod_oficina, cod_operacion, fecha_hora, cod_consulta, 
						   cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, cod_consulta2, 
						   des_campo_afectado, est_anterior_campo_afectado, est_actual_campo_afectado)
						SELECT	 Descripcion_Tabla, 
							Codigo_Usuario, 
							Cod_IP, 
							Codigo_Oficina, 
							Cod_Operacion, 
							Fecha_Hora,
							Codigo_Consulta, 
							Codigo_Tipo_Garantia, 
							Codigo_Garantia, 
							Codigo_Operacion_Crediticia,
							Codigo_Consulta2, 
							Descripcion_Campo_Afectado, 
							Estado_Anterior_Campo_Afectado,
							Estado_Actual_Campo_Afectado		
						FROM	@TMP_BITACORA
				
						SET @viError = @@Error
						IF(@viError <> 0) 
							BEGIN
								SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-10</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible insertar las pistas de auditoria.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

								RETURN -10
							
								ROLLBACK TRANSACTION TRA_Ins_Bita
							END
						
					--Finaliza la transacción
					COMMIT TRANSACTION TRA_Ins_Bita
				END
				ELSE
				BEGIN
					SET		@psRespuesta = N'<RESPUESTA>' +
									'<CODIGO>-11</CODIGO>' + 
									'<NIVEL></NIVEL>' +
									'<ESTADO></ESTADO>' +
									'<PROCEDIMIENTO>Normalizar_Avaluo_Garantias_Reales</PROCEDIMIENTO>' +
									'<LINEA></LINEA>' + 
									'<MENSAJE>No es posible replicar el avalúo, debido a que existe una fecha de valuación más reciente.</MENSAJE>' +
									'<DETALLE></DETALLE>' +
								'</RESPUESTA>'

					RETURN -11
				END
			END
		END

		RETURN 0

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