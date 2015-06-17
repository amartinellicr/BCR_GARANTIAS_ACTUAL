USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Insertar_Registro_Calculo_MTAT_MTANT', 'P') IS NOT NULL
	DROP PROCEDURE Insertar_Registro_Calculo_MTAT_MTANT;
GO

CREATE PROCEDURE [dbo].[Insertar_Registro_Calculo_MTAT_MTANT]
	@psTrama			NTEXT,
	@psCedula_Usuario	VARCHAR(30),
	@psRespuesta		VARCHAR(1000) OUTPUT
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Insertar_Registro_Calculo_MTAT_MTANT</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>
		Procedimiento almacenado que se encarga de insertar la informaci�n generada por la aplicaci�n del c�lculo de los montos de tasaci�n 
		actualizada de terrenos y no terrenos, esto por cada semestre.
	</Descripci�n>
	<Entradas>
		@psTrama						= Trama que contiene la informaci�n a ser registrada.
		@psCedula_Usuario				= Identificaci�n del usuario que realiza la consulta. 
                                  			
	</Entradas>
	<Salidas>
			@psRespuesta	= Respuesta que se retorna al aplicativo, seg�n el estado de la transacci�n realizada  
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>04/11/2013</Fecha>
	<Requerimiento>Req_027 C�lculo de Campo Terreno Actualizado, Siebel No. 1-24077731</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy
	SET LANGUAGE Spanish

	DECLARE @viControladorDocXML INT

	EXEC sp_xml_preparedocument @viControladorDocXML OUTPUT, @psTrama

	BEGIN TRANSACTION TRA_Ins_Cal_MTAT_MTANT --Inicio
	
	INSERT	INTO dbo.TMP_CALCULO_MTAT_MTANT (
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
		SELECT	
			datosCalculo.Fecha_Hora, 
			datosCalculo.Id_Garantia, 
			datosCalculo.Tipo_Garantia_Real, 
			datosCalculo.Clase_Garantia, 
			datosCalculo.Semestre_Calculado, 
			datosCalculo.Fecha_Valuacion, 
			datosCalculo.Monto_Ultima_Tasacion_Terreno, 
			datosCalculo.Monto_Ultima_Tasacion_No_Terreno, 
			datosCalculo.Tipo_Cambio, 
			datosCalculo.Indice_Precios_Consumidor, 
			datosCalculo.Tipo_Cambio_Anterior, 
			datosCalculo.Indice_Precios_Consumidor_Anterior, 
			datosCalculo.Factor_Tipo_Cambio, 
			datosCalculo.Factor_IPC, 
			datosCalculo.Porcentaje_Depreciacion_Semestral, 
			datosCalculo.Monto_Tasacion_Actualizada_Terreno, 
			datosCalculo.Monto_Tasacion_Actualizada_No_Terreno, 
			datosCalculo.Numero_Registro, 
			datosCalculo.Codigo_Operacion, 
			datosCalculo.Codigo_Garantia, 
			datosCalculo.Tipo_Bien, 
			datosCalculo.Total_Semestres_Calcular, 
			@psCedula_Usuario
		FROM	OPENXML(@viControladorDocXML, 'DATOS/SEMESTRES_A_CALCULAR/SEMESTRE', 2)
			WITH (Fecha_Hora DATETIME, Id_Garantia VARCHAR(30), Tipo_Garantia_Real TINYINT,
				  Clase_Garantia SMALLINT, Semestre_Calculado DATETIME, Fecha_Valuacion DATETIME,
				  Monto_Ultima_Tasacion_Terreno DECIMAL(18, 2), 
				  Monto_Ultima_Tasacion_No_Terreno DECIMAL(18, 2), Tipo_Cambio DECIMAL(18, 2),
				  Indice_Precios_Consumidor DECIMAL(18, 2), Tipo_Cambio_Anterior DECIMAL(18, 2),
				  Indice_Precios_Consumidor_Anterior DECIMAL(18, 2), Factor_Tipo_Cambio FLOAT,
				  Factor_IPC FLOAT, Porcentaje_Depreciacion_Semestral FLOAT, 
				  Monto_Tasacion_Actualizada_Terreno FLOAT, 
				  Monto_Tasacion_Actualizada_No_Terreno FLOAT, Numero_Registro SMALLINT,
				  Codigo_Operacion BIGINT, Codigo_Garantia BIGINT, Tipo_Bien TINYINT,
				  Total_Semestres_Calcular SMALLINT) datosCalculo              
		
		IF (@@ERROR <> 0) 
		BEGIN 
			ROLLBACK TRANSACTION TRA_Ins_Cal_MTAT_MTANT -- Error
			SET @psRespuesta = N'<RESPUESTA><CODIGO>1</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Registro_Calculo_MTAT_MTANT</PROCEDIMIENTO><LINEA></LINEA>' + 
								'<MENSAJE>Problema al insertar el registro.</MENSAJE><DETALLE>Se produjo un error al insertar los datos del c�lculo de los montos de la tasaci�n actualizada del terreno y no terreno. El c�digo obtenido es: ' + CONVERT(VARCHAR(1000), @@ERROR) + '</DETALLE></RESPUESTA>'

			RETURN 1 
		END
	
	COMMIT TRANSACTION TRA_Ins_Cal_MTAT_MTANT --Fin	
	
	EXEC sp_xml_removedocument @viControladorDocXML

	SET @psRespuesta = N'<RESPUESTA><CODIGO>0</CODIGO><NIVEL></NIVEL><ESTADO></ESTADO><PROCEDIMIENTO>Insertar_Registro_Calculo_MTAT_MTANT</PROCEDIMIENTO><LINEA></LINEA>' + 
						'<MENSAJE>La inserci�n de los datos ha sido satisfactoria.</MENSAJE><DETALLE></DETALLE></RESPUESTA>'

	SELECT @psRespuesta

	RETURN 0
END