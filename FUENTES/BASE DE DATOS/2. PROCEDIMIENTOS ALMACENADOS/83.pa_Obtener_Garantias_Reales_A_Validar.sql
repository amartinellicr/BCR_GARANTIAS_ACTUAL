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
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al campo porcentaje de responsabilidad dentro de 
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
	SET DATEFORMAT dmy

	/*Se elimina la información de las tablas temporales que hubiera generado el usuario previamente*/
	DELETE	FROM dbo.TMP_GARANTIAS_REALES_OPERACIONES 
	WHERE	Codigo_Usuario = @psCedula_Usuario

	DELETE	FROM dbo.TMP_GARANTIAS_REALES_X_OPERACION 
	WHERE	Codigo_Usuario = @psCedula_Usuario

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
		Numero_Placa_Bien, Codigo_Usuario, Porcentaje_Aceptacion)
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
		COALESCE(GRO.porcentaje_responsabilidad, -1) AS Porcentaje_Responsabilidad,
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
		@psCedula_Usuario AS Codigo_Usuario,
		COALESCE(GRO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.GARANTIAS_REALES_X_OPERACION_VW ROV 
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO  
		ON ROV.cod_operacion = GRO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR 
		ON GRO.cod_garantia_real = GGR.cod_garantia_real 
	WHERE	ROV.cod_tipo_operacion = 1
		AND GRO.cod_estado = 1
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
		Numero_Placa_Bien, Codigo_Usuario, Porcentaje_Aceptacion)
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
		COALESCE(GRO.porcentaje_responsabilidad, -1) AS Porcentaje_Responsabilidad,
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
		@psCedula_Usuario AS Codigo_Usuario,
		COALESCE(GRO.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.GARANTIAS_REALES_X_OPERACION_VW ROV  
		INNER JOIN dbo.GAR_GARANTIAS_REALES_X_OPERACION GRO  
		ON ROV.cod_operacion = GRO.cod_operacion 
		INNER JOIN dbo.GAR_GARANTIA_REAL GGR  
		ON GRO.cod_garantia_real = GGR.cod_garantia_real 
	WHERE	ROV.cod_tipo_operacion = 2
		AND EXISTS	(	SELECT	1
						FROM	dbo.GAR_SICC_PRMGT GSP 
						WHERE	GSP.prmgt_pco_conta = 1
							AND GSP.prmgt_pco_ofici = ROV.cod_oficina_contrato
							AND GSP.prmgt_pco_moned = ROV.cod_moneda_contrato
							AND GSP.prmgt_pnu_oper = ROV.num_contrato
							AND GSP.prmgt_pcoclagar = GGR.cod_clase_garantia
							AND GSP.prmgt_pco_grado = COALESCE(GGR.cod_grado, GSP.prmgt_pco_grado)
							AND COALESCE(GSP.prmgt_pnuidegar, 0) = COALESCE(GGR.Identificacion_Sicc, 0)
							AND COALESCE(GSP.prmgt_pnuide_alf, '') = COALESCE(GGR.Identificacion_Alfanumerica_Sicc, '')
							AND GSP.prmgt_pco_produ = 10
							AND GSP.prmgt_estado = 'A') /*Aquí se ha determinado si la garantía existente en BCRGarantías está activa en la estructura 
												   del SICC*/
	ORDER	BY
			ROV.cod_operacion,
			Numero_Finca,
			Codigo_Grado,
			Codigo_Clase_Bien,
			Numero_Placa_Bien,
			Codigo_Tipo_Documento_Legal DESC

	
	/*Se eliminan los registros incompletos*/
	DELETE	FROM dbo.TMP_GARANTIAS_REALES_OPERACIONES
	WHERE	Codigo_Usuario = @psCedula_Usuario
		AND Codigo_Tipo_Documento_Legal = -1
		AND Fecha_Presentacion = '19000101'
		AND Codigo_Tipo_Mitigador = -1
		AND Codigo_Inscripcion = -1

	/*Se eliminan los registros de hipotecas comunes duplicadas*/
	WITH CTE (Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Usuario, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion,
				Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Usuario,
				ROW_NUMBER() OVER(PARTITION BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Usuario  ORDER BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Usuario) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	Codigo_Usuario = @psCedula_Usuario
			AND Codigo_Clase_Garantia BETWEEN 10 AND 17
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se eliminan los registros de cédulas hipotecarias con clase 18 duplicadas*/
	WITH CTE (Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, 
				Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario,
				ROW_NUMBER() OVER(PARTITION BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario  ORDER BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	Codigo_Usuario = @psCedula_Usuario
			AND Codigo_Clase_Garantia = 18
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1


	/*Se eliminan los registros de cédulas hipotecarias con clase diferente 18 duplicadas*/
	WITH CTE (Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, 
				Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario,
				ROW_NUMBER() OVER(PARTITION BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario  ORDER BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Codigo_Partido, Numero_Finca, Codigo_Grado, Codigo_Usuario) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	Codigo_Usuario = @psCedula_Usuario
			AND Codigo_Clase_Garantia BETWEEN 20 AND 29
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1

	/*Se eliminan los registros de prendas duplicadas*/
	WITH CTE (Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Numero_Placa_Bien, Codigo_Usuario, cantidadRegistrosDuplicados)
	AS
	(
		SELECT	Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, 
				Codigo_Clase_Garantia, Numero_Placa_Bien, Codigo_Usuario,
				ROW_NUMBER() OVER(PARTITION BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Numero_Placa_Bien, Codigo_Usuario  ORDER BY Codigo_Oficina, Codigo_Moneda, Codigo_Producto, Operacion, Codigo_Clase_Garantia, Numero_Placa_Bien, Codigo_Usuario) AS cantidadRegistrosDuplicados
		FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES
		WHERE	Codigo_Usuario = @psCedula_Usuario
			AND Codigo_Clase_Garantia BETWEEN 30 AND 69
	)
	DELETE
	FROM CTE
	WHERE cantidadRegistrosDuplicados > 1



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
		Numero_Placa_Bien, Codigo_Usuario, Porcentaje_Aceptacion)
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
			COALESCE(GRO.porcentaje_responsabilidad, -1) AS Porcentaje_Responsabilidad,
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
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_constitucion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Constitucion, 
			CONVERT(VARCHAR(10), (CONVERT(DATETIME, CAST((COALESCE(GRO.fecha_presentacion, '1900-01-01')) AS VARCHAR(11)), 101)), 112) 
			AS Fecha_Presentacion,
			COALESCE(GGR.numero_finca,'') AS Numero_Finca,
			COALESCE(GGR.num_placa_bien,'') AS Numero_Placa_Bien,
			TGR.Codigo_Usuario,
			COALESCE(TGR.Porcentaje_Aceptacion, 0) AS Porcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
	FROM	dbo.TMP_GARANTIAS_REALES_OPERACIONES TGR 
		INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO 
		ON GRO.cod_operacion = TGR.Codigo_Operacion
		AND GRO.cod_garantia_real = TGR.Codigo_Garantia_Real
		INNER JOIN GAR_GARANTIA_REAL GGR 
		ON GGR.cod_garantia_real = TGR.Codigo_Garantia_Real
	WHERE	TGR.Codigo_Usuario = @psCedula_Usuario
		AND ((TGR.Codigo_Tipo_Operacion	= 1)
			OR (TGR.Codigo_Tipo_Operacion = 2))

	/************************************************************************************************
	 *                                                                                              * 
	 *                        FIN DE LA SELECCIÓN DE GARANTÍAS                                      *
	 *               (DE LA MISMA FORMA EN COMO LO HACE LA APLICACION)                              *
	 *                                                                                              *
	 ************************************************************************************************/
	
END