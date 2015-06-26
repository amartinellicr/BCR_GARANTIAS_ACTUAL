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
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que actualiza los datos de los deudores/codeudores seg�n los 
				 criterios emitidos por el usuario
	</Descripci�n>
	<Entradas>@psCedula_Deudor		= Identificaci�n del deudor/codeudor. Este el dato llave usado para la b�squeda.
  			  @piTipo_Deudor		= Tipo de persona del deudor/codeudor
			  @piCondicion_Especial = Indicador de condici�n especial.
			  @piTipo_Asignacion	= Indicador del tipo de asginaci�n.
			  @piGenerador_Divisas	= Indicador que determina si es o no generador de divisas.
			  @piVinculado_Entidad	= Indicador de vinculado a la entidad.
	</Entradas>
	<Salidas>
			  @psRespuesta  = Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>07/05/2012</Fecha>
	<Requerimiento>Codeudores</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
******************************************************************/

	SET NOCOUNT ON;
	
	/*Variable para el manejo del error en la transacci�n*/
	DECLARE @viError INT



	IF NOT EXISTS (	SELECT	1 
					FROM	dbo.GAR_DEUDOR
					WHERE	cedula_deudor	= @psCedula_Deudor
				  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Se ha producido un fallo en la actualizaci�n de los datos.</MENSAJE><DETALLE>El deudor/codeudor ''' +  @psCedula_Deudor + ''' no existe dentro del cat�logo del sistema</DETALLE></RESPUESTA>'

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
								'<MENSAJE>Se ha producido un fallo en la actualizaci�n de los datos del deudor/codeudor ''' + @psCedula_Deudor + '''.</MENSAJE><DETALLE>El c�digo de error reportado por la base de datos es ' + CONVERT(VARCHAR, @viError)  +'.</DETALLE></RESPUESTA>'
			ROLLBACK TRANSACTION
			RETURN -1
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION

			SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Modificar_Deudor</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>La actualizaci�n de los datos fue satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
		
			RETURN 0
		END
	END
END
GO
