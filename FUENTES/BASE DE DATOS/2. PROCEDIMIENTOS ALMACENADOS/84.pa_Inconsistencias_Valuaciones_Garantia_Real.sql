USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Inconsistencias_Valuaciones_Garantia_Real', 'P') IS NOT NULL
	DROP PROCEDURE dbo.Inconsistencias_Valuaciones_Garantia_Real;
GO

CREATE PROCEDURE [dbo].[Inconsistencias_Valuaciones_Garantia_Real]
	@psCedula_Usuario VARCHAR(30),
	@psRespuesta	  VARCHAR(1000) OUTPUT
AS
/*****************************************************************************************************************************************************
	<Nombre>Inconsistencias_Valuaciones_Garantia_Real</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que obtiene las inconsistencias referentes a los aval�os de las garant�as reales.
	</Descripci�n>
	<Entradas>
		@psCedula_Usuario	= Identificaci�n del usuario que realiza la consulta. 
                                  	  Este es dato llave usado para la b�squeda de los registros que deben 
                                  	  ser eliminados de la tabla temporal.
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>05/11/2012</Fecha>
	<Requerimiento>Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-21537427</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
					Actualizacion de procedimientos almacenados, Siebel No. 1-24307807.
			</Requerimiento>
			<Fecha>13/05/2014</Fecha>
			<Descripci�n>
					Se elimina la referencia al BNX, mediante el uso del link server, por la referencia a una base de datos local. 
			</Descripci�n>
		</Cambio>
			<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>
				Req Bcr Garantias Migraci�n, Siebel No.1-24015441
			</Requerimiento>
			<Fecha>13/02/2014</Fecha>
			<Descripci�n>
				Se eliminan las referencias al BNX.
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, GrupoMas</Autor>
			<Requerimiento>Requerimiento de Placas Alfaum�ricas</Requerimiento>
			<Fecha>02/07/2015</Fecha>
			<Descripci�n>
				Se ajusta el subproceso #5. El cambio es referente a la implementaci�n de placas alfanum�ricas, 
				por lo que se modifica la forma en como se liga con la tabla PRMGT cuando la clase de garant�a es 
				11, 38 o 43. 
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Mar�n, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creaci�n nuevo campo en mantenimiento de garant�as</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripci�n>
				El cambio es referente a la implementaci�n del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptaci�n, este campo reemplazar� al campo porcentaje de responsabilidad dentro de 
				cualquier l�gica existente.  
			</Descripci�n>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/
BEGIN

	SET NOCOUNT ON
	SET DATEFORMAT dmy

	--Declaraci�n de variables locales
	DECLARE		@vsIdentificacion_Usuario	VARCHAR(30), --Identificaci�n del usuario que ejecuta el proceso.
				@viEjecucion_Exitosa		INT --Valor de retorno producto de la ejecuci�n de un procedimiento almacenado.
				
	DECLARE		@TMP_VALUACIONES TABLE (
					Codigo_Contabilidad						TINYINT ,
					Codigo_Oficina							SMALLINT,
					Codigo_Moneda							TINYINT ,
					Codigo_Producto							TINYINT ,
					Operacion								DECIMAL (7,0),
					Codigo_Garantia_Real					BIGINT	,
					Monto_Ultima_Tasacion_Terreno			MONEY	,
					Monto_Ultima_Tasacion_No_Terreno		MONEY	,
					Monto_Tasacion_Actualizada_Terreno		MONEY	,
					Monto_Tasacion_Actualizada_No_Terreno	MONEY	,
					Fecha_Ultimo_Seguimiento				DATETIME,
					Fecha_Valuacion							DATETIME,
					Fecha_Construccion						DATETIME,
					Fecha_Constitucion						DATETIME,
					Fecha_Presentacion						DATETIME,
					Codigo_Tipo_Operacion					TINYINT	,
					Codigo_Bien								VARCHAR (25)	COLLATE database_default,
					Codigo_Tipo_Bien						SMALLINT,
					Codigo_Tipo_Garantia_Real				TINYINT ,
					Codigo_Clase_Garantia					SMALLINT,
					Codigo_Partido							SMALLINT,
					Numero_Finca							VARCHAR (25)	COLLATE database_default,
					Numero_Placa_Bien						VARCHAR (25)	COLLATE database_default,
					Porcentaje_Aceptacion					DECIMAL(5,2),
					Monto_Total_Avaluo						MONEY   ,
					Antiguedad_Annos_Avaluo					INT		,
					Tamanno_Finca							INT		,
					Tamanno_Placa							INT		,
					Codigo_Usuario							VARCHAR (30)	COLLATE database_default
			) --Alamacenar� la informaci�n requerida de los aval�os asociados a las garant�as valoradas.
					
	DECLARE		@TMP_INCONSISTENCIAS TABLE (
					Contabilidad							TINYINT			,
					Oficina									SMALLINT		,
					Moneda									TINYINT			,
					Producto								TINYINT			,
					Operacion								DECIMAL(7, 0)	,
					Contrato								DECIMAL(7, 0)	,
					Tipo_Garantia_Real						TINYINT			,
					Garantia_Real							VARCHAR(30)		COLLATE database_default, 
					Clase_Garantia							SMALLINT		,
					Porcentaje_Aceptacion					DECIMAL(5,2)	,
					Fecha_Valuacion							DATETIME		,
					Fecha_Presentacion						DATETIME		,
					Fecha_Ultimo_Seguimiento				DATETIME		,
					Monto_Total_Avaluo						MONEY			,
					Monto_Ultima_Tasacion_Terreno			MONEY			,
					Monto_Tasacion_Actualizada_Terreno		MONEY			,
					Monto_Ultima_Tasacion_No_Terreno		MONEY			,
					Monto_Tasacion_Actualizada_No_Terreno	MONEY			,
					Tipo_Inconsistencia						VARCHAR(100)	COLLATE database_default,
					Usuario									VARCHAR(30)		COLLATE database_default 
			) --Almacenar� la informaci�n de las inconsistencias obtenidas.

	DECLARE		@TMP_BNX_PRMGT TABLE (
					prmgt_pco_conta	TINYINT		,
					prmgt_pco_ofici SMALLINT	,
					prmgt_pco_moned TINYINT		,
					prmgt_pco_produ TINYINT		,
					prmgt_pnu_oper  INT			,
					prmgt_pcoclagar TINYINT		,
					prmgt_pcotengar	TINYINT		,
					prmgt_pnu_part  TINYINT		,
					prmgt_pnuidegar	VARCHAR(25)	COLLATE database_default,
					prmgt_pmoavaing	DECIMAL(14,2)
			) --Almacenar� la informaci�n de las garant�as reales del BNX


	--Inicializaci�n de variables locales
	SET @vsIdentificacion_Usuario = @psCedula_Usuario

	/************************************************************************************************
	 *                                                                                              * 
	 *		     INICIO DEL FILTRADO DE LAS GARANTIAS REALES										*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	--Se ejecuta el procedimiento almacenado que obtiene las garant�as a ser valoradas
	EXEC	@viEjecucion_Exitosa = [dbo].[Obtener_Garantias_Reales_A_Validar]
					@psCedula_Usuario = @vsIdentificacion_Usuario

	--Se eval�a el resultado obtenido de la ejecuci�n del procedimiento almacenado
	IF(@viEjecucion_Exitosa <> 0)
	BEGIN
		SET	@psRespuesta = N'<RESPUESTA>' +
						'<CODIGO>-1</CODIGO>' + 
						'<NIVEL></NIVEL>' +
						'<ESTADO></ESTADO>' +
						'<PROCEDIMIENTO>Inconsistencias_Valuaciones_Garantia_Real</PROCEDIMIENTO>' +
						'<LINEA></LINEA>' + 
						'<MENSAJE>Se produjo un error al obtener las inconsistencias de los aval�os.</MENSAJE>' +
						'<DETALLE>El problema se produjo al ejecutar el procedimiento almacenado "Obtener_Garantias_Reales_A_Validar",' + 
                                                          ' que obtiene las garant�as a ser valoradas.' +
   						'</DETALLE>' +
					'</RESPUESTA>'

		RETURN -1
	END
	/************************************************************************************************
	 *                                                                                              * 
	 *		      FIN DEL FILTRADO DE LAS GARANTIAS REALES 					*
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *              INICIO DEL FILTRADO DE LAS VALUACIONES DE LAS GARANTIAS REALES                  *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/* Se obtienen todos los val�os que posee cada una de las garant�as*/
	INSERT	INTO @TMP_VALUACIONES (
			Codigo_Contabilidad,
			Codigo_Oficina,
			Codigo_Moneda,
			Codigo_Producto,
			Operacion,
			Codigo_Garantia_Real,
			Monto_Ultima_Tasacion_Terreno,
			Monto_Ultima_Tasacion_No_Terreno,
			Monto_Tasacion_Actualizada_Terreno,
			Monto_Tasacion_Actualizada_No_Terreno,
			Fecha_Ultimo_Seguimiento,
			Fecha_Valuacion,
			Fecha_Construccion,
			Fecha_Constitucion,
			Fecha_Presentacion,
			Codigo_Tipo_Operacion,
			Codigo_Bien,
			Codigo_Tipo_Bien,
			Codigo_Tipo_Garantia_Real,
			Codigo_Clase_Garantia,
			Codigo_Partido,
			Numero_Finca,
			Numero_Placa_Bien,
			Porcentaje_Aceptacion,
			Monto_Total_Avaluo,
			Antiguedad_Annos_Avaluo,
			Tamanno_Finca,
			Tamanno_Placa,
			Codigo_Usuario
								 )
	SELECT	DISTINCT 
			GRO.Codigo_Contabilidad,
			GRO.Codigo_Oficina,
			GRO.Codigo_Moneda,
			GRO.Codigo_Producto,
			GRO.Operacion,
			GRO.Codigo_Garantia_Real,
			NULL AS monto_ultima_tasacion_terreno,
			NULL AS monto_ultima_tasacion_no_terreno,
			NULL AS monto_tasacion_actualizada_terreno,
			NULL AS monto_tasacion_actualizada_no_terreno,
			NULL AS fecha_ultimo_seguimiento,
			NULL AS Fecha_Valuacion,
			NULL AS fecha_construccion,
			GRO.Fecha_Constitucion,
			GRO.Fecha_Presentacion,
			GRO.Codigo_Tipo_Operacion,
			GRO.Codigo_Bien,
			GRO.Codigo_Tipo_Bien,
			GRO.Codigo_Tipo_Garantia_Real,
			GRO.Codigo_Clase_Garantia,
			GRO.Codigo_Partido,
			GRO.Numero_Finca,
			GRO.Numero_Placa_Bien,
			COALESCE(GRO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se modifica el cmapo fuente utilizado.
			NULL AS Monto_Total_Avaluo,
			NULL AS Antiguedad_Annos_Avaluo, 
			LEN(GRO.Numero_Finca) AS Tamanno_Finca,
			LEN(GRO.Numero_Placa_Bien) AS Tamanno_Placa,
			GRO.Codigo_Usuario
	FROM	dbo.TMP_GARANTIAS_REALES_X_OPERACION GRO
	WHERE	GRO.Codigo_Usuario = @vsIdentificacion_Usuario
	
	--Se actualizan aquellos aval�os cuya fecha de valuaci�n es igual al a registrada en el SICC
	UPDATE	@TMP_VALUACIONES
	SET		Monto_Ultima_Tasacion_Terreno = COALESCE(GVR.monto_ultima_tasacion_terreno, 0),
			Monto_Ultima_Tasacion_No_Terreno = COALESCE(GVR.monto_ultima_tasacion_no_terreno, 0),
			Monto_Tasacion_Actualizada_Terreno = COALESCE(GVR.monto_tasacion_actualizada_terreno, 0),
			Monto_Tasacion_Actualizada_No_Terreno = COALESCE(GVR.monto_tasacion_actualizada_no_terreno, 0),
			Fecha_Ultimo_Seguimiento = COALESCE(GVR.fecha_ultimo_seguimiento, '19000101'),
			Fecha_Valuacion = GVR.fecha_valuacion,
			Fecha_Construccion = COALESCE(GVR.fecha_construccion, '19000101'),
			Monto_Total_Avaluo = (COALESCE(GVR.monto_ultima_tasacion_terreno, 0) + COALESCE(GVR.monto_ultima_tasacion_no_terreno, 0)),
			Antiguedad_Annos_Avaluo = (DATEDIFF(year, GVR.fecha_valuacion, GETDATE()))
	FROM	@TMP_VALUACIONES TMP
		INNER JOIN	dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TMP.Codigo_Garantia_Real
	WHERE	GVR.Indicador_Tipo_Registro = 2

	--Se actualizan aquellos aval�os cuya fecha de valuaci�n es igual al a registrada en el SICC
	UPDATE	@TMP_VALUACIONES
	SET		Monto_Ultima_Tasacion_Terreno = COALESCE(GVR.monto_ultima_tasacion_terreno, 0),
			Monto_Ultima_Tasacion_No_Terreno = COALESCE(GVR.monto_ultima_tasacion_no_terreno, 0),
			Monto_Tasacion_Actualizada_Terreno = COALESCE(GVR.monto_tasacion_actualizada_terreno, 0),
			Monto_Tasacion_Actualizada_No_Terreno = COALESCE(GVR.monto_tasacion_actualizada_no_terreno, 0),
			Fecha_Ultimo_Seguimiento = COALESCE(GVR.fecha_ultimo_seguimiento, '19000101'),
			Fecha_Valuacion = GVR.fecha_valuacion,
			Fecha_Construccion = COALESCE(GVR.fecha_construccion, '19000101'),
			Monto_Total_Avaluo = (COALESCE(GVR.monto_ultima_tasacion_terreno, 0) + COALESCE(GVR.monto_ultima_tasacion_no_terreno, 0)),
			Antiguedad_Annos_Avaluo = (DATEDIFF(year, GVR.fecha_valuacion, GETDATE()))
	FROM	@TMP_VALUACIONES TMP
		INNER JOIN	dbo.GAR_VALUACIONES_REALES GVR
		ON GVR.cod_garantia_real = TMP.Codigo_Garantia_Real
	WHERE	GVR.Indicador_Tipo_Registro = 1
	
	--Se cargan las hipotecas del BNX
	INSERT	INTO @TMP_BNX_PRMGT (
		prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		prmgt_pnuidegar	,
		prmgt_pmoavaing)
	SELECT	prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		CONVERT(VARCHAR(25), prmgt_pnuidegar),
		prmgt_pmoavaing	
	FROM	dbo.GAR_SICC_PRMGT
	WHERE	prmgt_estado = 'A'
		AND prmgt_pcoclagar IN (10, 12, 13, 14, 15, 16, 17, 18, 19)

	UNION ALL

	SELECT	prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		CASE 
			WHEN prmgt_pnuide_alf IS NULL THEN CONVERT(VARCHAR(25), prmgt_pnuidegar)
			ELSE COALESCE(prmgt_pnuide_alf, '') 
		END AS prmgt_pnuidegar,
		prmgt_pmoavaing	
	FROM	dbo.GAR_SICC_PRMGT
	WHERE	prmgt_estado = 'A'
		AND prmgt_pcoclagar = 11

	UNION ALL
	
	SELECT	prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		CONVERT(VARCHAR(25), prmgt_pnuidegar),
		prmgt_pmoavaing	
	FROM	dbo.GAR_SICC_PRMGT
	WHERE	prmgt_estado = 'A'
		AND prmgt_pcoclagar BETWEEN 20 AND 29
		AND prmgt_pcotengar = 1

	UNION ALL

	SELECT	prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		CONVERT(VARCHAR(25), prmgt_pnuidegar),
		prmgt_pmoavaing	
	FROM	dbo.GAR_SICC_PRMGT
	WHERE	prmgt_estado = 'A'
		AND ((prmgt_pcoclagar BETWEEN 30 AND 37)
			OR (prmgt_pcoclagar BETWEEN 39 AND 42)
			OR (prmgt_pcoclagar BETWEEN 44 AND 69))
			
	UNION ALL

	SELECT	prmgt_pco_conta	,
		prmgt_pco_ofici ,
		prmgt_pco_moned ,
		prmgt_pco_produ ,
		prmgt_pnu_oper  ,
		prmgt_pcoclagar ,
		prmgt_pcotengar	,
		prmgt_pnu_part  ,
		CASE 
			WHEN prmgt_pnuide_alf IS NULL THEN CONVERT(VARCHAR(25), prmgt_pnuidegar)
			ELSE COALESCE(prmgt_pnuide_alf, '') 
		END AS prmgt_pnuidegar,
		prmgt_pmoavaing	
	FROM	dbo.GAR_SICC_PRMGT
	WHERE	prmgt_estado = 'A'
		AND ((prmgt_pcoclagar = 38)
			OR (prmgt_pcoclagar = 43))


	/************************************************************************************************
	 *                                                                                              * 
	 *                 FIN DEL FILTRADO DE LAS VALUACIONES DE LAS GARANTIAS REALES                  *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/

	/************************************************************************************************
	 *                                                                                              * 
	 *                         INICIO DE LA SELECCI�N DE INCONSISTENCIAS                            *
	 *                                                                                              *
	 *                                                                                              *
	 ************************************************************************************************/
		
	/*INCONSISTENCIAS DEL CAMPO: FECHA DEL ULTIMO SEGUIMIENTO*/

	--Se obtienen las garant�as reales cuyo aval�o posea una fecha de siguimiento inv�lida
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_�ltimo_seguimiento', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Fecha_Ultimo_Seguimiento > Fecha_Constitucion
		AND Codigo_Tipo_Operacion = 1
		AND Fecha_Ultimo_Seguimiento <> '19000101'

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_�ltimo_seguimiento', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Fecha_Ultimo_Seguimiento > Fecha_Constitucion
		AND Codigo_Tipo_Operacion = 2
		AND Fecha_Ultimo_Seguimiento <> '19000101'

	UNION ALL
	
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_�ltimo_seguimiento', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Fecha_Ultimo_Seguimiento > Fecha_Presentacion
		AND Codigo_Tipo_Operacion = 1
		AND Fecha_Ultimo_Seguimiento <> '19000101'

	UNION ALL
	
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_�ltimo_seguimiento', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Fecha_Ultimo_Seguimiento > Fecha_Presentacion
		AND Codigo_Tipo_Operacion = 2
		AND Fecha_Ultimo_Seguimiento <> '19000101'


	/*INCONSISTENCIAS DEL CAMPO: FECHA DE CONSTRUCCION*/

	/*Se obtienen las garant�as reales cuyo aval�o posea una fecha de construcci�n inv�lida, seg�n el 
	  tipo de bien*/
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_construcci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Codigo_Tipo_Operacion = 1
		AND Fecha_Construccion <> '19000101'

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_construcci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Codigo_Tipo_Operacion = 2
		AND Fecha_Construccion <> '19000101'

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_construcci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 2
		AND Fecha_Construccion = '19000101'
		AND Codigo_Tipo_Operacion = 1

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Fecha_construcci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 2
		AND Fecha_Construccion = '19000101'
		AND Codigo_Tipo_Operacion = 2

	/*INCONSISTENCIAS DEL CAMPO: TIPO DE BIEN*/
	
	/*Se obtienen las garant�as reales cuyo aval�o posea datos en los campos del monto de �ltima tasaci�n no terreno,
	  monto tasaci�n actualizada del no terreno y fecha de construcci�n, s�lo cuando el tipo de bien es igual a 1*/
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Tipo_de_bien', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Monto_Ultima_Tasacion_No_Terreno > 0
		AND Codigo_Tipo_Operacion = 1

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Tipo_de_bien', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Monto_Ultima_Tasacion_No_Terreno > 0
		AND Codigo_Tipo_Operacion = 2

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Tipo_de_bien', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Monto_Tasacion_Actualizada_No_Terreno > 0
		AND Codigo_Tipo_Operacion = 1

	UNION ALL

	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Tipo_de_bien', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Monto_Tasacion_Actualizada_No_Terreno > 0
		AND Codigo_Tipo_Operacion = 2
	

	/*INCONSISTENCIAS DEL CAMPO: FECHA DE VALUACI�N DIFERENTE ENTRE OPERACIONES QUE POSEEN UNA MISMA GARANTIA*/
	
	--Se obtienen los aval�os, de una misma garant�a real, que posea una fecha de valuaci�n diferente, entre operaciones
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, TV1.Operacion AS Operacion, NULL AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Error_en_Fecha_de_Valuaci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1, 
		(SELECT		Codigo_Clase_Garantia, Codigo_Bien, Fecha_Valuacion
		 FROM		@TMP_VALUACIONES 
		 GROUP		BY Codigo_Clase_Garantia, Codigo_Bien, Fecha_Valuacion) TV2
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND	TV1.Codigo_Clase_Garantia = TV2.Codigo_Clase_Garantia
		AND TV1.Codigo_Bien = TV2.Codigo_Bien
		AND TV1.Codigo_Tipo_Operacion = 1
		AND ((TV1.Fecha_Valuacion < TV2.Fecha_Valuacion)
			OR (TV1.Fecha_Valuacion > TV2.Fecha_Valuacion))

	UNION ALL
	
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, NULL AS Operacion, TV1.Operacion AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Error_en_Fecha_de_Valuaci�n', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1, 
		(SELECT		Codigo_Clase_Garantia, Codigo_Bien, Fecha_Valuacion
		 FROM		@TMP_VALUACIONES 
		 GROUP		BY Codigo_Clase_Garantia, Codigo_Bien, Fecha_Valuacion) TV2
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND	TV1.Codigo_Clase_Garantia = TV2.Codigo_Clase_Garantia
		AND TV1.Codigo_Bien = TV2.Codigo_Bien
		AND TV1.Codigo_Tipo_Operacion = 2
		AND ((TV1.Fecha_Valuacion < TV2.Fecha_Valuacion)
			OR (TV1.Fecha_Valuacion > TV2.Fecha_Valuacion))
		
	/*INCONSISTENCIAS DEL CAMPO: MONTO TOTAL DEL AVALUO*/
	
	--Se obtienen las garant�as reales que posea un monto total del aval�o diferente al registrado en el SICC
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	--Se obtienen las hipotecas comunes asociadas a operaciones directas
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, TV1.Operacion, NULL AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = TV1.Codigo_Producto
		AND GSP.prmgt_pnu_oper	= TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 1
		AND TV1.Tamanno_Finca > 0
		AND TV1.Codigo_Tipo_Operacion = 1
		AND GSP.prmgt_pnuidegar	= TV1.Numero_Finca
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND GSP.prmgt_pnu_part = TV1.Codigo_Partido
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing	> TV1.Monto_Total_Avaluo))
									
	
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	--Se obtienen las hipotecas comunes asociadas a contratos
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, NULL AS Operacion, TV1.Operacion AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = 10
		AND GSP.prmgt_pnu_oper	= TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 1
		AND TV1.Tamanno_Finca > 0
		AND TV1.Codigo_Tipo_Operacion = 2
		AND GSP.prmgt_pnuidegar	= TV1.Numero_Finca
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND GSP.prmgt_pnu_part = TV1.Codigo_Partido
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing	> TV1.Monto_Total_Avaluo))

	
	--Se obtienen las garant�as reales que posea un monto total del aval�o diferente al registrado en el SICC
	--Se obtienen las c�dulas hipotecarias asociadas a operaciones directas
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, TV1.Operacion AS Operacion, NULL AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = TV1.Codigo_Producto
		AND GSP.prmgt_pnu_oper	= TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 2
		AND TV1.Tamanno_Finca > 0
		AND TV1.Codigo_Tipo_Operacion = 1
		AND GSP.prmgt_pnuidegar	= TV1.Numero_Finca
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND GSP.prmgt_pnu_part = TV1.Codigo_Partido
		AND GSP.prmgt_pcotengar = 1
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing > TV1.Monto_Total_Avaluo))
								

	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	--Se obtienen las c�dulas hipotecarias asociadas a contratos
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, NULL AS Operacion, TV1.Operacion AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = 10
		AND GSP.prmgt_pnu_oper = TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 2
		AND TV1.Tamanno_Finca > 0
		AND TV1.Codigo_Tipo_Operacion = 2
		AND GSP.prmgt_pnuidegar = TV1.Numero_Finca
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND GSP.prmgt_pnu_part = TV1.Codigo_Partido
		AND GSP.prmgt_pcotengar	= 1
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing > TV1.Monto_Total_Avaluo))
	
	
	--Se obtienen las garant�as reales que posea un monto total del aval�o diferente al registrado en el SICC
	--Se obtienen las prendas asociadas a operaciones directas
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, TV1.Operacion, NULL AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = TV1.Codigo_Producto
		AND GSP.prmgt_pnu_oper = TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 3
		AND TV1.Tamanno_Placa > 0
		AND TV1.Codigo_Tipo_Operacion = 1
		AND GSP.prmgt_pnuidegar = TV1.Numero_Placa_Bien
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing > TV1.Monto_Total_Avaluo))
								

	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato, 
					   Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
					   Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
					   Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
					   Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
					   Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
					   Tipo_Inconsistencia, Usuario
					  )
	--Se obtienen las prendas asociadas a contratos
	SELECT	1, TV1.Codigo_Oficina, TV1.Codigo_Moneda, TV1.Codigo_Producto, NULL AS Operacion, TV1.Operacion AS Contrato,
		TV1.Codigo_Tipo_Garantia_Real, TV1.Codigo_Bien, TV1.Codigo_Clase_Garantia,
		TV1.Porcentaje_Aceptacion, TV1.Fecha_Valuacion, TV1.Fecha_Presentacion, 
		TV1.Fecha_Ultimo_Seguimiento, TV1.Monto_Total_Avaluo,
		TV1.Monto_Ultima_Tasacion_Terreno, TV1.Monto_Tasacion_Actualizada_Terreno,
		TV1.Monto_Ultima_Tasacion_No_Terreno, TV1.Monto_Tasacion_Actualizada_No_Terreno,
		'Monto_aval�o_de_garant�a', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES TV1 
		INNER JOIN @TMP_BNX_PRMGT GSP
		ON GSP.prmgt_pco_conta = 1
		AND GSP.prmgt_pco_ofici = TV1.Codigo_Oficina
		AND GSP.prmgt_pco_moned = TV1.Codigo_Moneda
		AND GSP.prmgt_pco_produ = 10
		AND GSP.prmgt_pnu_oper = TV1.Operacion
	WHERE	TV1.Codigo_Usuario = @vsIdentificacion_Usuario
		AND TV1.Codigo_Tipo_Garantia_Real = 3
		AND TV1.Tamanno_Placa > 0
		AND TV1.Codigo_Tipo_Operacion = 2
		AND GSP.prmgt_pnuidegar = TV1.Numero_Placa_Bien
		AND GSP.prmgt_pcoclagar = TV1.Codigo_Clase_Garantia
		AND ((GSP.prmgt_pmoavaing < TV1.Monto_Total_Avaluo)
			OR (GSP.prmgt_pmoavaing > TV1.Monto_Total_Avaluo))

	
	/*INCONSISTENCIAS DEL CAMPO: VALIDEZ DEL MONTO DEL AVAL�O ACTUALIZADO TERRENO */
	
	--Se obtienen las garant�as reales que posea un porcentaje de aceptaci�n inv�lido para el tipo de bien 
	--y la antiguedad del aval�o  	
	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
			Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
			Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
			Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
			Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
			Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
			Tipo_Inconsistencia, Usuario
		)
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, NULL AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Validez_Monto_Aval�o_Actualizado_Terreno', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Codigo_Tipo_Operacion = 1
		AND Antiguedad_Annos_Avaluo > 5
		AND Porcentaje_Aceptacion > 40


	INSERT	INTO @TMP_INCONSISTENCIAS (Contabilidad, Oficina, Moneda, Producto, Operacion, Contrato,
			Tipo_Garantia_Real, Garantia_Real, Clase_Garantia, 
			Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion,
			Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo,
			Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
			Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
			Tipo_Inconsistencia, Usuario
		)
	SELECT	1, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, NULL AS Operacion, Operacion AS Contrato,
		Codigo_Tipo_Garantia_Real, Codigo_Bien, Codigo_Clase_Garantia,
		Porcentaje_Aceptacion, Fecha_Valuacion, Fecha_Presentacion, 
		Fecha_Ultimo_Seguimiento, Monto_Total_Avaluo, 
		Monto_Ultima_Tasacion_Terreno, Monto_Tasacion_Actualizada_Terreno,
		Monto_Ultima_Tasacion_No_Terreno, Monto_Tasacion_Actualizada_No_Terreno,
		'Validez_Monto_Aval�o_Actualizado_Terreno', @vsIdentificacion_Usuario
	FROM	@TMP_VALUACIONES 
	WHERE	Codigo_Usuario = @vsIdentificacion_Usuario
		AND Codigo_Tipo_Bien = 1
		AND Codigo_Tipo_Operacion = 2
		AND Antiguedad_Annos_Avaluo > 5
		AND Porcentaje_Aceptacion	> 40


 /************************************************************************************************
 *                                                                                              * 
 *                            FIN DE LA SELECCI�N DE INCONSISTENCIAS                            *
 *                                                                                              *
 *                                                                                              *
 ************************************************************************************************/

	UPDATE	@TMP_INCONSISTENCIAS
	SET	Fecha_Ultimo_Seguimiento = NULL
	WHERE	Fecha_Ultimo_Seguimiento = '19000101'

	UPDATE	@TMP_INCONSISTENCIAS
	SET	Fecha_Presentacion	= NULL
	WHERE	Fecha_Presentacion	= '19000101'

	


	SELECT 	DISTINCT	
		1							AS Tag,
		NULL						AS Parent,
		'0'							AS [RESPUESTA!1!CODIGO!element], 
		NULL						AS [RESPUESTA!1!NIVEL!element], 
		NULL						AS [RESPUESTA!1!ESTADO!element], 
		'Inconsistencias_Tipo_Garantia_Real'		AS [RESPUESTA!1!PROCEDIMIENTO!element], 
		NULL						AS [RESPUESTA!1!LINEA!element], 
		'La obtenci�n de datos fue satisfactoria'	AS [RESPUESTA!1!MENSAJE!element], 
		NULL						AS [DETALLE!2!], 
		NULL						AS [Inconsistencia!3!DATOS!element], 
		NULL						AS [Inconsistencia!3!Usuario!hide]

	UNION ALL

	SELECT	DISTINCT
		2							AS Tag,
		1							AS Parent,
		NULL						AS [RESPUESTA!1!CODIGO!element], 
		NULL						AS [RESPUESTA!1!NIVEL!element], 
		NULL						AS [RESPUESTA!1!ESTADO!element], 
		NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
		NULL						AS [RESPUESTA!1!LINEA!element], 
		NULL						AS [RESPUESTA!1!MENSAJE!element], 
		NULL						AS [DETALLE!2!], 
		NULL						AS [Inconsistencia!3!DATOS!element], 
		NULL						AS [Inconsistencia!3!Usuario!hide]

	UNION ALL

	SELECT	DISTINCT
		3							AS Tag,
		2							AS Parent,
		NULL						AS [RESPUESTA!1!CODIGO!element], 
		NULL						AS [RESPUESTA!1!NIVEL!element], 
		NULL						AS [RESPUESTA!1!ESTADO!element], 
		NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
		NULL						AS [RESPUESTA!1!LINEA!element], 
		NULL						AS [RESPUESTA!1!MENSAJE!element], 
		NULL						AS [DETALLE!2!], 
		(CONVERT(VARCHAR(5), Contabilidad) 		+ CHAR(9) + 
		CONVERT(VARCHAR(5), Oficina)      		+ CHAR(9) + 
 		CONVERT(VARCHAR(5), Moneda)	   			+ CHAR(9) +
		CONVERT(VARCHAR(5), Producto)	   		+ CHAR(9) + 
 		COALESCE(CONVERT(VARCHAR(20), Operacion), '')	+ CHAR(9) + 
 		COALESCE(CONVERT(VARCHAR(20), Contrato), '')	+ CHAR(9) + 
		CONVERT(VARCHAR(5), Tipo_Garantia_Real)	+ CHAR(9) +
	    Garantia_Real							+ CHAR(9) +
 		COALESCE(CONVERT(VARCHAR(5), Clase_Garantia), '')					+ CHAR(9) +
		CONVERT(VARCHAR(10), Porcentaje_Aceptacion)						+ CHAR(9) +
		CONVERT(VARCHAR(10), Fecha_Valuacion, 105)						+ CHAR(9) +
		COALESCE(CONVERT(VARCHAR(10), Fecha_Presentacion, 105), '')		+ CHAR(9) +
		COALESCE(CONVERT(VARCHAR(10), Fecha_Ultimo_Seguimiento, 105), '')	+ CHAR(9) +
		CONVERT(VARCHAR(100), (COALESCE(Monto_Total_Avaluo, 0)))			+ CHAR(9) +
		CONVERT(VARCHAR(100), (COALESCE(Monto_Ultima_Tasacion_Terreno, 0)))			+ CHAR(9) +
		CONVERT(VARCHAR(100), (COALESCE(Monto_Tasacion_Actualizada_Terreno, 0)))		+ CHAR(9) +
		CONVERT(VARCHAR(100), (COALESCE(Monto_Ultima_Tasacion_No_Terreno, 0)))		+ CHAR(9) +
		CONVERT(VARCHAR(100), (COALESCE(Monto_Tasacion_Actualizada_No_Terreno, 0)))	+ CHAR(9) +
		Tipo_Inconsistencia						+ CHAR(9)) AS [Inconsistencia!3!DATOS!element],
		Usuario									AS [Inconsistencia!3!Usuario!hide]
	FROM	@TMP_INCONSISTENCIAS 
	WHERE	Usuario	=  @vsIdentificacion_Usuario
	FOR	XML EXPLICIT

	SET	@psRespuesta = N'<RESPUESTA>' +
					'<CODIGO>0</CODIGO>' + 
					'<NIVEL></NIVEL>' +
					'<ESTADO></ESTADO>' +
					'<PROCEDIMIENTO>Inconsistencias_Valuaciones_Garantia_Real</PROCEDIMIENTO>' +
					'<LINEA></LINEA>' + 
				       '<MENSAJE>La obtenci�n de los datos ha sido satisfactoria.</MENSAJE>' +
					'<DETALLE></DETALLE>' +
				'</RESPUESTA>'

	RETURN 0
END