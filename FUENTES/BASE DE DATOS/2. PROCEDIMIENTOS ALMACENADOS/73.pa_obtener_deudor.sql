SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.pa_Obtener_Deudor

	@psCedula_Deudor		VARCHAR(30),
	@piCatalogoElemento		INT,
	@psRespuesta			VARCHAR(1000) output
	
AS
BEGIN

/******************************************************************
	<Nombre>Obtener_Deudor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que obtienen los datos referentes al deudor específicado.
	</Descripción>
	<Entradas>
			@psCedula_Deudor	= Identificación del deudor/codeudor. Este el dato llave usado para la búsqueda.
			@piCatalogoElemento = Código del catálogo de donde se obtiene la descripción del códigode capacidad de pago.
	</Entradas>
	<Salidas>
			@psRespuesta		= Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>07/05/2012</Fecha>
	<Requerimiento>Codeudores</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
******************************************************************/

	SET NOCOUNT ON;
	
	/*Variable para el manejo del error en la transacción*/
	DECLARE @viError INT,
			@vsCapacidadesPago VARCHAR(7000)

	
	IF NOT EXISTS (	SELECT	1 
					FROM	dbo.GAR_DEUDOR
					WHERE	cedula_deudor	= @psCedula_Deudor
				  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Se ha producido un fallo en la obtención de los datos: </MENSAJE><DETALLE>El deudor/codeudor no se encuentra registrado dentro de este sistema.</DETALLE></RESPUESTA>'
		

		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'1'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'Obtener_Deudor'			AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'Se ha producido un fallo en la obtención de los datos: '		AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!] 
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
				'El deudor/codeudor no se encuentra registrado dentro de este sistema.'	AS [DETALLE!2!] 
				FOR		XML EXPLICIT
		RETURN 1
	END
	ELSE
	BEGIN
		SELECT DISTINCT	
				1							AS Tag,
				NULL						AS Parent,
				'0'							AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				'Obtener_Deudor'			AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				'La obtención de datos fue satisfactoria' AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Deudor!3!cedula_deudor!element], 
				NULL						AS [Deudor!3!nombre_deudor!element], 
				NULL						AS [Deudor!3!cod_tipo_deudor!element], 
				NULL						AS [Deudor!3!cod_condicion_especial!element], 
				NULL						AS [Deudor!3!cod_tipo_asignacion!element], 
				NULL						AS [Deudor!3!cod_generador_divisas!element], 
				NULL						AS [Deudor!3!cod_vinculado_entidad!element], 
				NULL						AS [Deudor!3!cod_tipo_registro!element], 
				NULL						AS [Deudor!3!des_tipo_registro!element],
				NULL						AS [CAPACIDADES!4!],
				NULL						AS [CAPACIDAD!5!fecha_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!cod_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!sensibilidad_tipo_cambio!element],
				NULL						AS [CAPACIDAD!5!des_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!fecha_ordenar!hide]
		FROM	dbo.GAR_DEUDOR 
		WHERE	cedula_deudor			=  @psCedula_Deudor
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
				NULL						AS [Deudor!3!cedula_deudor!element], 
				NULL						AS [Deudor!3!nombre_deudor!element], 
				NULL						AS [Deudor!3!cod_tipo_deudor!element], 
				NULL						AS [Deudor!3!cod_condicion_especial!element], 
				NULL						AS [Deudor!3!cod_tipo_asignacion!element], 
				NULL						AS [Deudor!3!cod_generador_divisas!element], 
				NULL						AS [Deudor!3!cod_vinculado_entidad!element], 
				NULL						AS [Deudor!3!cod_tipo_registro!element], 
				NULL						AS [Deudor!3!des_tipo_registro!element],
				NULL						AS [CAPACIDADES!4!],
				NULL						AS [CAPACIDAD!5!fecha_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!cod_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!sensibilidad_tipo_cambio!element],
				NULL						AS [CAPACIDAD!5!des_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!fecha_ordenar!hide]
		FROM	dbo.GAR_DEUDOR 
		WHERE	cedula_deudor			=  @psCedula_Deudor
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
				A.cedula_deudor				AS [Deudor!3!cedula_deudor!element], 
				A.nombre_deudor				AS [Deudor!3!nombre_deudor!element], 
				ISNULL(A.cod_tipo_deudor, -1)			AS [Deudor!3!cod_tipo_deudor!element], 
				ISNULL(A.cod_condicion_especial, -1)	AS [Deudor!3!cod_condicion_especial!element], 
				ISNULL(A.cod_tipo_asignacion, 2)		AS [Deudor!3!cod_tipo_asignacion!element], 
				ISNULL(A.cod_generador_divisas, -1)		AS [Deudor!3!cod_generador_divisas!element], 
				ISNULL(A.cod_vinculado_entidad, 2)		AS [Deudor!3!cod_vinculado_entidad!element], 
				A.cod_tipo_registro			AS [Deudor!3!cod_tipo_registro!element], 
				CASE WHEN A.cod_tipo_registro = 0 THEN 'Deudor'
					 WHEN A.cod_tipo_registro = 1 THEN 'Codeudor'
					 WHEN A.cod_tipo_registro = 2 THEN 'Deudor/Codeudor'
					 ELSE 'Indef'
				END							AS [Deudor!3!des_tipo_registro!element],
				NULL						AS [CAPACIDADES!4!],
				NULL						AS [CAPACIDAD!5!fecha_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!cod_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!sensibilidad_tipo_cambio!element],
				NULL						AS [CAPACIDAD!5!des_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!fecha_ordenar!hide]
		FROM	dbo.GAR_DEUDOR A
		WHERE	cedula_deudor			=  @psCedula_Deudor
		UNION ALL
		SELECT	DISTINCT
				4							AS Tag,
				3							AS Parent,
				NULL						AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				NULL						AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Deudor!3!cedula_deudor!element], 
				NULL						AS [Deudor!3!nombre_deudor!element], 
				NULL						AS [Deudor!3!cod_tipo_deudor!element], 
				NULL						AS [Deudor!3!cod_condicion_especial!element], 
				NULL						AS [Deudor!3!cod_tipo_asignacion!element], 
				NULL						AS [Deudor!3!cod_generador_divisas!element], 
				NULL						AS [Deudor!3!cod_vinculado_entidad!element], 
				NULL						AS [Deudor!3!cod_tipo_registro!element], 
				NULL						AS [Deudor!3!des_tipo_registro!element],
				NULL						AS [CAPACIDADES!4!],
				NULL						AS [CAPACIDAD!5!fecha_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!cod_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!sensibilidad_tipo_cambio!element],
				NULL						AS [CAPACIDAD!5!des_capacidad_pago!element],
				NULL						AS [CAPACIDAD!5!fecha_ordenar!hide]
		FROM	dbo.GAR_DEUDOR 
		WHERE	cedula_deudor			=  @psCedula_Deudor
		UNION ALL
		SELECT	DISTINCT
				5							AS Tag,
				4							AS Parent,
				NULL						AS [RESPUESTA!1!CODIGO!element], 
				NULL						AS [RESPUESTA!1!NIVEL!element], 
				NULL						AS [RESPUESTA!1!ESTADO!element], 
				NULL						AS [RESPUESTA!1!PROCEDIMIENTO!element], 
				NULL						AS [RESPUESTA!1!LINEA!element], 
				NULL						AS [RESPUESTA!1!MENSAJE!element], 
				NULL						AS [DETALLE!2!], 
				NULL						AS [Deudor!3!cedula_deudor!element], 
				NULL						AS [Deudor!3!nombre_deudor!element], 
				NULL						AS [Deudor!3!cod_tipo_deudor!element], 
				NULL						AS [Deudor!3!cod_condicion_especial!element], 
				NULL						AS [Deudor!3!cod_tipo_asignacion!element], 
				NULL						AS [Deudor!3!cod_generador_divisas!element], 
				NULL						AS [Deudor!3!cod_vinculado_entidad!element], 
				NULL						AS [Deudor!3!cod_tipo_registro!element], 
				NULL						AS [Deudor!3!des_tipo_registro!element],
				NULL						AS [CAPACIDADES!4!],
				(CONVERT(VARCHAR(10),A.fecha_capacidad_pago,103))	AS [CAPACIDAD!5!fecha_capacidad_pago!element],
				ISNULL(A.cod_capacidad_pago, -1)					AS [CAPACIDAD!5!cod_capacidad_pago!element],
				A.sensibilidad_tipo_cambio							AS [CAPACIDAD!5!sensibilidad_tipo_cambio!element],
				ISNULL(B.cat_descripcion, '')						AS [CAPACIDAD!5!des_capacidad_pago!element],
				(CONVERT(int, CONVERT(varchar(8), (CONVERT(DATETIME,CAST(A.fecha_capacidad_pago AS VARCHAR(11)),101)), 112))) AS [CAPACIDAD!5!fecha_ordenar!hide]
		FROM	dbo.GAR_CAPACIDAD_PAGO A
		LEFT JOIN CAT_ELEMENTO B 
		ON ISNULL(A.cod_capacidad_pago,-1)	= B.cat_campo
		AND B.cat_catalogo					= @piCatalogoElemento
		WHERE	cedula_deudor				=  @psCedula_Deudor
		ORDER BY Tag, Parent, [CAPACIDAD!5!fecha_ordenar!hide] DESC
		FOR		XML EXPLICIT

		SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Obtener_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>La obtención de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

		RETURN 0
	END
END
GO
