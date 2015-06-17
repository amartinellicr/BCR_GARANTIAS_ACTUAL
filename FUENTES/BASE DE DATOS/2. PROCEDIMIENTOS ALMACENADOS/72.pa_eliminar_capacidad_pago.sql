SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.pa_Eliminar_Capacidad_Pago

	@psCedula_Deudor			VARCHAR(30),
	@pdtFecha_Capacidad_Pago	DATETIME,
	@psRespuesta				VARCHAR(4000) output
	
AS
BEGIN

/******************************************************************
	<Nombre>Eliminar_Capacidad_Pago</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que elimina una capacidad de pago espec�fica.
	</Descripci�n>
	<Entradas>@psCedula_Deudor				= Identificaci�n del deudor/codeudor. Este el dato llave usado para la b�squeda.
  			  @pdtFecha_Capacidad_Pago		= Fecha en que se registr� la capacidad de pago.
	</Entradas>
	<Salidas>
			  @psRespuesta  = Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada.  
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

	SET NOCOUNT ON
	SET dateformat ymd

	/*Variable para el manejo del error en la transacci�n*/
	DECLARE @viError			INT,
			@vdtHoySinHora		DATETIME,
			@viFechaEntero		INT


	SET @vdtHoySinHora = CONVERT(DATETIME,CAST(@pdtFecha_Capacidad_Pago AS VARCHAR(11)),101)
	--SET @viFechaEntero =  CONVERT(int, CONVERT(VARCHAR(8), @vdtHoySinHora, 112))
		
	IF NOT EXISTS (	SELECT	1 
					FROM	dbo.GAR_DEUDOR
					WHERE	cedula_deudor	= @psCedula_Deudor
				  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Se ha producido un fallo en la eliminaci�n de la capacidad de pago.</MENSAJE><DETALLE>El deudor/codeudor no existe dentro del cat�logo del sistema</DETALLE></RESPUESTA>'

		RETURN 1
	END
	ELSE
	BEGIN
		IF NOT EXISTS (	SELECT	1
						FROM	dbo.GAR_CAPACIDAD_PAGO
						WHERE	cedula_deudor			= @psCedula_Deudor
						AND		fecha_capacidad_pago	= @vdtHoySinHora
					  )
		BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se ha producido un fallo en la eliminaci�n de los datos.</MENSAJE><DETALLE>El registro de capacidad de pago a eliminar no existe.</DETALLE></RESPUESTA>'
			RETURN 1
		END
		ELSE
		BEGIN

			BEGIN TRANSACTION

			DELETE	dbo.GAR_CAPACIDAD_PAGO
			WHERE	cedula_deudor			= @psCedula_Deudor
			AND		fecha_capacidad_pago 	= @vdtHoySinHora

			/*Evalua si se produjo un error*/
			SET @viError = @@Error
			IF(@viError <> 0)
			BEGIN
				SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Se ha producido un fallo en la eliminaci�n del a capacidad de pago espec�ficada.</MENSAJE><DETALLE>El c�digo de error reportado por la base de datos es ' + CONVERT(VARCHAR, @viError)  +'.</DETALLE></RESPUESTA>'
				ROLLBACK TRANSACTION
				RETURN -1
			END
			ELSE
			BEGIN
				COMMIT TRANSACTION

				SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Eliminar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>La eliminaci�n de los datos fue satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
			
				RETURN 0
			END
		END
	END
END
GO
