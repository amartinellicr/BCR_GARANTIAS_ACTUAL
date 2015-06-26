SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Modificar_Deudor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Modificar_Deudor;
GO

CREATE PROCEDURE dbo.pa_Modificar_Deudor

	@psCedula_Deudor		VARCHAR(30),
	@piTipo_Deudor			SMALLINT,
	@piCondicion_Especial	SMALLINT = NULL,
	@piTipo_Asignacion		SMALLINT = NULL,
	@piGenerador_Divisas	SMALLINT,
	@piVinculado_Entidad	SMALLINT,
	@psRespuesta			VARCHAR(4000) output
	
AS
BEGIN

/******************************************************************
	<Nombre>Modificar_Deudor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que actualiza los datos de los deudores/codeudores según los 
				 criterios emitidos por el usuario
	</Descripción>
	<Entradas>@psCedula_Deudor		= Identificación del deudor/codeudor. Este el dato llave usado para la búsqueda.
  			  @piTipo_Deudor		= Tipo de persona del deudor/codeudor
			  @piCondicion_Especial = Indicador de condición especial.
			  @piTipo_Asignacion	= Indicador del tipo de asginación.
			  @piGenerador_Divisas	= Indicador que determina si es o no generador de divisas.
			  @piVinculado_Entidad	= Indicador de vinculado a la entidad.
	</Entradas>
	<Salidas>
			  @psRespuesta  = Respuesta que se retorna al aplicativo, según el estado de la transacción realizada  
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
	DECLARE @viError INT



	IF NOT EXISTS (	SELECT	1 
					FROM	dbo.GAR_DEUDOR
					WHERE	cedula_deudor	= @psCedula_Deudor
				  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Se ha producido un fallo en la actualización de los datos.</MENSAJE><DETALLE>El deudor/codeudor ''' +  @psCedula_Deudor + ''' no existe dentro del catálogo del sistema</DETALLE></RESPUESTA>'

		RETURN 1
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION

			UPDATE	dbo.GAR_DEUDOR
			SET		cod_tipo_deudor			= @piTipo_Deudor,
					cod_condicion_especial	= @piCondicion_Especial,
					cod_tipo_asignacion		= @piTipo_Asignacion,
					cod_generador_divisas	= @piGenerador_Divisas,
					cod_vinculado_entidad	= @piVinculado_Entidad
			
			WHERE	cedula_deudor			= @psCedula_Deudor


		/*Evalua si se produjo un error*/
		SET @viError = @@Error
		IF(@viError <> 0)
		BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se ha producido un fallo en la actualización de los datos del deudor/codeudor ''' + @psCedula_Deudor + '''.</MENSAJE><DETALLE>El código de error reportado por la base de datos es ' + CONVERT(VARCHAR, @viError)  +'.</DETALLE></RESPUESTA>'
			ROLLBACK TRANSACTION
			RETURN -1
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La actualización de los datos fue satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
		
			RETURN 0
		END
	END
END
GO
