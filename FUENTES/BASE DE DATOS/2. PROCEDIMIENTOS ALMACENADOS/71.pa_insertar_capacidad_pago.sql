SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Insertar_Capacidad_Pago', 'P') IS NOT NULL
	DROP PROCEDURE pa_Insertar_Capacidad_Pago;
GO

CREATE PROCEDURE dbo.pa_Insertar_Capacidad_Pago

	@psCedula_Deudor			VARCHAR(30),
	@piCapacidad_Pago			SMALLINT,
	@pdSensibilidad_Tipo_Cambio	DECIMAL(5,2),
	@psRespuesta				VARCHAR(4000) output
	
AS
BEGIN

/******************************************************************
	<Nombre>Insertar_Capacidad_Pago</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Procedimiento almacenado que inserta una capacidad de pago espec�fica.
	</Descripci�n>
	<Entradas>@psCedula_Deudor				= Identificaci�n del deudor/codeudor. Este el dato llave usado para la b�squeda.
  			  @piCapacidad_Pago				= C�digo de la copacidad de pago.
  			  @pnSensibilidad_Tipo_Cambio	= Porcentaje de sensibilidad al tipo de cambio.
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

	SET NOCOUNT ON;
	
	SET dateformat ymd

	/*Variable para el manejo del error en la transacci�n*/
	DECLARE @viError			INT,
			@vdtHoySinHora		DATETIME,
			@viFechaEntero		INT


	SET @vdtHoySinHora = CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101)
	--SET @viFechaEntero =  CONVERT(int, CONVERT(VARCHAR(8), @vdtHoySinHora, 112))

	IF NOT EXISTS (	SELECT	1 
					FROM	dbo.GAR_DEUDOR
					WHERE	cedula_deudor	= @psCedula_Deudor
				  )
	BEGIN
		SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
							'<MENSAJE>Se ha producido un fallo en la inserci�n de los datos.</MENSAJE><DETALLE>El deudor/codeudor no existe dentro del cat�logo del sistema.</DETALLE></RESPUESTA>'

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
			BEGIN TRANSACTION

			INSERT INTO dbo.GAR_CAPACIDAD_PAGO
			(	cedula_deudor,
				fecha_capacidad_pago,
				cod_capacidad_pago,
				sensibilidad_tipo_cambio
			)
			VALUES
			(
				@psCedula_Deudor,
				CONVERT(DATETIME,CAST(GETDATE() AS VARCHAR(11)),101),
				@piCapacidad_Pago,
				@pdSensibilidad_Tipo_Cambio
			)
				
			/*Evalua si se produjo un error*/
			SET @viError = @@Error
			IF(@viError <> 0)
			BEGIN
				SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>Se ha producido un fallo en la inserci�n de los datos.</MENSAJE><DETALLE>El c�digo de error reportado por la base de datos es ' + CONVERT(VARCHAR, @viError)  +'.</DETALLE></RESPUESTA>'
				ROLLBACK TRANSACTION
				RETURN -1
			END
			ELSE
			BEGIN
				COMMIT TRANSACTION

				SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
									'<MENSAJE>La inserci�n de los datos fue satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'
			
				RETURN 0
			END
		END
		ELSE
		BEGIN
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Capacidad_Pago</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Se ha producido un fallo en la inserci�n de los datos.</MENSAJE><DETALLE>Ya existe un registro de capacidad de pago para este deudor/codeudor en este d�a.</DETALLE></RESPUESTA>'

			RETURN 1
		END
	END
END
GO
