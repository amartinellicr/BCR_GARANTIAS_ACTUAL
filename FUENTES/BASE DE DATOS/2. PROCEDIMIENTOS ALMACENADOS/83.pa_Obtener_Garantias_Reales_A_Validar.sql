USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Obtener_Garantias_Reales_A_Validar', 'P') IS NOT NULL
	DROP PROCEDURE Obtener_Garantias_Reales_A_Validar;
GO

CREATE PROCEDURE [dbo].[Obtener_Garantias_Reales_A_Validar]
	@psCedula_Usuario		VARCHAR(30)
AS
/*****************************************************************************************************************************************************
	<Nombre>Obtener_Garantias_Reales_A_Validar</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtiene las garantías reales que serán utilizadas para la 
		aplicación de las diferentes reglas de validación.
	</Descripción>
	<Entradas>
			@psCedula_Usuario		= Identificación del usuario que realiza la consulta. 
									  Este es dato llave usado para la búsqueda de los registros que deben 
                                      ser eliminados de la tabla temporal.

	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>15/01/2013</Fecha>
	<Requerimiento>
			Req_Inconsistencias Cedula Hipotecarias, Siebel No.1-21474091,
			Req_Valuaciones Garantias Reales VRS4, Siebel No. 1-21537427,
			Req_Garantia real 2, Siebel No. 1-21537644
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

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE	FROM dbo.TMP_OPERACIONES_DUPLICADAS 
	WHERE	cod_usuario		= @psCedula_Usuario

	DELETE	FROM dbo.TMP_GARANTIAS_REALES_OPERACIONES 
	WHERE	Codigo_Usuario	= @psCedula_Usuario

	DELETE	FROM dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario	= @psCedula_Usuario

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
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '')  
			WHEN 2 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') 
			WHEN 3 THEN COALESCE(GGR.cod_clase_bien, '') + '-' + COALESCE(GGR.num_placa_bien, '')
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
		CASE GGR.cod_tipo_garantia_real  
			WHEN 1 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '')  
			WHEN 2 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') 
			WHEN 3 THEN COALESCE(GGR.cod_clase_bien, '') + '-' + COALESCE(GGR.num_placa_bien, '')
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
	WHERE	ROV.cod_tipo_operacion	= 2
		AND EXISTS	(	SELECT	1
						FROM	dbo.GAR_SICC_PRMGT GSP 
						WHERE	GSP.prmgt_pco_conta	 = 1
							AND GSP.prmgt_pco_ofici  = ROV.cod_oficina_contrato
							AND GSP.prmgt_pco_moned  = ROV.cod_moneda_contrato
							AND GSP.prmgt_pnu_oper   = ROV.num_contrato
							AND GSP.prmgt_pcoclagar  = GGR.cod_clase_garantia
							AND GSP.prmgt_pco_grado  = COALESCE(GGR.cod_grado, GSP.prmgt_pco_grado)
							AND GSP.prmgt_pnuidegar = CASE
														WHEN GGR.cod_clase_garantia = 11 THEN GSP.prmgt_pnuidegar
														WHEN GGR.cod_clase_garantia = 38 THEN GSP.prmgt_pnuidegar
														WHEN GGR.cod_clase_garantia = 43 THEN GSP.prmgt_pnuidegar
														ELSE GGR.Identificacion_Sicc
													  END
							AND COALESCE(GSP.prmgt_pnuide_alf, '') =	CASE
																			WHEN GGR.cod_clase_garantia = 11 THEN COALESCE(GGR.numero_finca, '')
																			WHEN GGR.cod_clase_garantia = 38 THEN COALESCE(GGR.num_placa_bien, '')
																			WHEN GGR.cod_clase_garantia = 43 THEN COALESCE(GGR.num_placa_bien, '')
																			ELSE COALESCE(GSP.prmgt_pnuide_alf, '')
																		END
							AND GSP.prmgt_pco_produ  = 10
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
		AND ((Codigo_Tipo_Operacion		= 1)
			OR (Codigo_Tipo_Operacion	= 2))
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
						WHERE	TGR.Codigo_Oficina				= TOD.cod_oficina
							AND TGR.Codigo_Moneda				= TOD.cod_moneda
							AND TGR.Codigo_Producto				= TOD.cod_producto
							AND TGR.Operacion					= TOD.operacion
							AND COALESCE(TGR.Codigo_Bien, '')		= COALESCE(TOD.cod_garantia_sicc, '')
							AND COALESCE(TGR.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
							AND ((TOD.cod_tipo_operacion		= 1)
								OR (TOD.cod_tipo_operacion		= 2))
							AND TOD.cod_tipo_garantia			= 2
							AND TGR.Codigo_Tipo_Documento_Legal	IS NULL
							AND TGR.Fecha_Presentacion			IS NULL
							AND TGR.Codigo_Tipo_Mitigador		IS NULL
							AND TGR.Codigo_Inscripcion			IS NULL)
			AND TGR.Codigo_Usuario			= @psCedula_Usuario
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
	WHERE	Codigo_Tipo_Garantia_Real	= 1 
		AND Codigo_Usuario				= @psCedula_Usuario
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
					WHERE	TGR.Codigo_Oficina				= TOD.cod_oficina
						AND TGR.Codigo_Moneda				= TOD.cod_moneda
						AND TGR.Codigo_Producto				= TOD.cod_producto
						AND TGR.Operacion					= TOD.operacion
						AND COALESCE(TGR.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
						AND TGR.Codigo_Tipo_Garantia_Real	= 1
						AND COALESCE(TGR.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
						AND ((TGR.Codigo_Tipo_Operacion		= 1)
							OR (TGR.Codigo_Tipo_Operacion	= 2))
						AND TOD.cod_tipo_garantia			= 2
						AND TGR.Codigo_Llave				<> TOD.cod_garantia)
		AND TGR.Codigo_Tipo_Garantia_Real	= 1
		AND TGR.Codigo_Usuario				= @psCedula_Usuario
		AND ((TGR.Codigo_Tipo_Operacion		= 1)
			OR (TGR.Codigo_Tipo_Operacion	= 2))


	/*Se eliminan los duplicados obtenidos*/
	DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
	WHERE	cod_usuario				= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 1

	DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
	WHERE	cod_usuario				= @psCedula_Usuario 
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
						WHERE	TGR.Codigo_Oficina				= TOD.cod_oficina
							AND TGR.Codigo_Moneda				= TOD.cod_moneda
							AND TGR.Codigo_Producto				= TOD.cod_producto
							AND TGR.Operacion					= TOD.operacion
							AND COALESCE(TGR.Numero_Finca, '')	= COALESCE(TOD.cod_garantia_sicc, '')
							AND TGR.Codigo_Grado				= TOD.cod_grado
							AND TGR.Codigo_Tipo_Garantia_Real	= 2
							AND COALESCE(TGR.Codigo_Usuario, '')	= COALESCE(TOD.cod_usuario, '')
							AND ((TGR.Codigo_Tipo_Operacion		= 1)
								OR (TGR.Codigo_Tipo_Operacion	= 2))
							AND TOD.cod_tipo_garantia			= 2
							AND TGR.Codigo_Llave				<> TOD.cod_garantia)
		AND TGR.Codigo_Tipo_Garantia_Real	= 2
		AND TGR.Codigo_Usuario				= @psCedula_Usuario
		AND ((TGR.Codigo_Tipo_Operacion		= 1)
			OR (TGR.Codigo_Tipo_Operacion	= 2))

	/*Se eliminan los duplicados obtenidos*/
	DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
	WHERE	cod_usuario				= @psCedula_Usuario 
			AND cod_tipo_garantia	= 2 
			AND cod_tipo_operacion	= 1

	DELETE	dbo.TMP_OPERACIONES_DUPLICADAS 
	WHERE	cod_usuario				= @psCedula_Usuario 
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
					WHERE	TGR.Codigo_Oficina					= TOD.cod_oficina
						AND TGR.Codigo_Moneda					= TOD.cod_moneda
						AND TGR.Codigo_Producto					= TOD.cod_producto
						AND TGR.Operacion						= TOD.operacion
						AND COALESCE(TGR.Numero_Placa_Bien, '')	= COALESCE(TOD.cod_garantia_sicc, '')
						AND TGR.Codigo_Tipo_Garantia_Real		= 3
						AND COALESCE(TGR.Codigo_Usuario, '')		= COALESCE(TOD.cod_usuario, '')
						AND ((TGR.Codigo_Tipo_Operacion			= 1)
							OR (TGR.Codigo_Tipo_Operacion		= 2))
						AND TOD.cod_tipo_garantia				= 2
						AND TGR.Codigo_Llave					<> TOD.cod_garantia)
		AND TGR.Codigo_Tipo_Garantia_Real	= 3
		AND TGR.Codigo_Usuario				= @psCedula_Usuario
		AND ((TGR.Codigo_Tipo_Operacion		= 1)
			OR (TGR.Codigo_Tipo_Operacion	= 2))


	/*Se eliminan los registros que se encuentran duplicados, esto para el usuario que genera la información*/
	DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
	WHERE	Codigo_Usuario				= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 1 
			AND Indicador_Duplicidad	= 2 

	DELETE	dbo.TMP_GARANTIAS_REALES_OPERACIONES 
	WHERE	Codigo_Usuario				= @psCedula_Usuario
			AND Codigo_Tipo_Operacion	= 2 
			AND Indicador_Duplicidad	= 2 

	/************************************************************************************************
	 *                                                                                              * 
	 *                         INICIO DE LA SELECCIÓN DE GARANTÍAS                                  *
	 *                   (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                          *
	 *                                                                                              *
	 ************************************************************************************************/

	INSERT	INTO dbo.TMP_GARANTIAS_REALES_X_OPERACION (Codigo_Operacion, Codigo_Garantia_Real, 
		Codigo_Contabilidad, Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Tipo_Bien, 
        Codigo_Tipo_Mitigador, Codigo_Tipo_Documento_Legal, Codigo_Inscripcion, Codigo_Tipo_Garantia_Real, 
		Codigo_Grado_Gravamen, Codigo_Clase_Garantia, Codigo_Partido, Codigo_Tipo_Garantia, 
		Codigo_Tipo_Operacion, Porcentaje_Responsabilidad, Monto_Mitigador, Codigo_Grado, Codigo_Clase_Bien, 
		Cedula_Hipotecaria, Codigo_Bien, Fecha_Constitucion, Fecha_Presentacion, Numero_Finca, 
		Numero_Placa_Bien, Codigo_Usuario)
	SELECT	DISTINCT
			TGR.Codigo_Operacion,
			GGR.cod_garantia_real,
			TGR.Codigo_Contabilidad, 
			TGR.Codigo_Oficina, 
			TGR.Codigo_Moneda, 
			TGR.Codigo_Producto, 
			TGR.Operacion, 
			COALESCE(GGR.cod_tipo_bien, -1) AS Codigo_Tipo_Bien, 
			COALESCE(GRO.cod_tipo_mitigador, -1) AS Codigo_Tipo_Mitigador, 
			COALESCE(GRO.cod_tipo_documento_legal, -1) AS Codigo_Tipo_Documento_Legal,
			COALESCE(GRO.cod_inscripcion, -1) AS Codigo_Inscripcion, 
			GGR.cod_tipo_garantia_real,
			TGR.Codigo_Grado_Gravamen,
			TGR.Codigo_Clase_Garantia,
			COALESCE(GGR.cod_partido, 0) AS Codigo_Partido,
			GGR.cod_tipo_garantia,
			TGR.Codigo_Tipo_Operacion,
			COALESCE(GRO.porcentaje_responsabilidad, 0) AS Porcentaje_Responsabilidad,
			COALESCE(GRO.monto_mitigador, 0) AS Monto_Mitigador,
			COALESCE(GGR.cod_grado,'') AS Codigo_Grado,
			COALESCE(GGR.cod_clase_bien,'') AS Codigo_Clase_Bien,
			COALESCE(GGR.cedula_hipotecaria,'') AS Cedula_Hipotecaria,
			CASE GGR.cod_tipo_garantia_real  
				WHEN 1 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '')  
				WHEN 2 THEN COALESCE((CONVERT(varchar(2),GGR.cod_partido)), '') + '-' + COALESCE(GGR.numero_finca, '') 
				WHEN 3 THEN COALESCE(GGR.cod_clase_bien, '') + '-' + COALESCE(GGR.num_placa_bien, '')
			END AS Codigo_Bien, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Constitucion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Presentacion,
			COALESCE(GGR.numero_finca,'') AS Numero_Finca,
			COALESCE(GGR.num_placa_bien,'') AS Numero_Placa_Bien,
			TGR.Codigo_Usuario
		
	FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO 
		ON GRO.cod_operacion		= TGR.Codigo_Operacion
		AND GRO.cod_garantia_real	= TGR.Codigo_Garantia_Real
		INNER JOIN GAR_GARANTIA_REAL GGR 
		ON GGR.cod_garantia_real	= TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario				= @psCedula_Usuario
		AND ((TGR.Codigo_Tipo_Operacion		= 1)
			OR (TGR.Codigo_Tipo_Operacion	= 2))

	/************************************************************************************************
	 *                                                                                              * 
	 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
	 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
	 *                                                                                              *
	 ************************************************************************************************/
	
END