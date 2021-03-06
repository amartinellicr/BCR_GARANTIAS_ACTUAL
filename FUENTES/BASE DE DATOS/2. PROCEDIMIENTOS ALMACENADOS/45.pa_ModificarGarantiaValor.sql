USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ModificarGarantiaValor', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ModificarGarantiaValor;
GO

CREATE PROCEDURE [dbo].[pa_ModificarGarantiaValor]
	--Garantia valor
	@piConsecutivo_Garantia_Valor BIGINT,
	@piTipo_Garantia SMALLINT,
	@piClase_Garantia SMALLINT,
	@psNumero_Seguridad VARCHAR(30),
	@pdtFecha_Constitucion DATETIME = NULL,
	@pdtFecha_Vencimiento DATETIME = NULL,
	@piCodigo_Clasificacion SMALLINT = NULL,
	@psCodigo_Instrumento VARCHAR(25) = NULL,
	@psNumero_Serie VARCHAR(25) = NULL,
	@piTipo_Emisor SMALLINT = NULL,
	@psCedula_Emisor VARCHAR(30) = NULL,
	@pdPorcentaje_Premio DECIMAL(5,2) = NULL,
	@psCodigo_ISIN VARCHAR(25) = NULL,
	@pdValor_Facial DECIMAL(18,2) = NULL,
	@piMoneda_Valor_Facial SMALLINT = NULL,
	@pdValor_Mercado DECIMAL(18,2) = NULL,
	@piMoneda_Valor_Mercado SMALLINT = NULL,
	@piCodigo_Tenencia SMALLINT = NULL,
	@pdtFecha_Prescripcion DATETIME = NULL,
	--Garantia valor X Operacion
	@piConsecutivo_Operacion BIGINT,
	@piTipo_Mitigador SMALLINT = NULL,
	@piTipo_Documento_Legal SMALLINT = NULL,
	@pdMonto_Mitigador DECIMAL(18,2) = NULL,
	@piCodigo_Inscripcion SMALLINT = NULL,
	@pdPorcentaje_Responsabilidad DECIMAL(5,2) = -1,
	@piGrado_Gravamen SMALLINT = NULL,
	@piGrado_Prioridades SMALLINT = NULL,
	@pdMonto_Prioridades DECIMAL(18,2) = NULL,
	@piOperacion_Especial SMALLINT = NULL,
	@piTipo_Acreedor SMALLINT = NULL,
	@psCedula_Acreedor VARCHAR(30) = NULL,
	--Bitacora
	@psCedula_Usuario VARCHAR(30),
	@pdPorcentaje_Aceptacion DECIMAL(5,2) --RQ_MANT_2015111010495738_00610: Se agrega este campo.
AS
BEGIN
/******************************************************************
	<Nombre>pa_ModificarGarantiaValor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Procedimiento almacenado que actualiza los datos de una garantía de valor específica.
	</Descripción>
	<Entradas>
  			@piConsecutivo_Garantia_Valor				= Consecutivo de la garantía real consultada. Este el dato llave usado para la búsqueda.
			@piTipo_Garantia				= Código del tipo de garantía.
			@piClase_Garantia				= Código de la clase de garantía.
			@psNumero_Seguridad			= Número de seguridad de la garantía.
			@pdtFecha_Constitucion			= Fecha de constitución de la garantía.
			@pdtFecha_Vencimiento			= Fecha de vencimiento de la garantía.
			@piCodigo_Clasificacion				= Código de la clasificación del instrumento.
			@psCodigo_Instrumento				= Identificación del instrumento.
			@psNumero_Serie					= Serie del instrumento.
			@piTipo_Emisor				= Código del tipo de persona del emisor del instrumento.
			@psCedula_Emisor			= Identificación del emisor del instrumento.
			@pdPorcentaje_Premio					= Porcentaje del premio asignado al instrumento.
			@psCodigo_ISIN					= Código ISIN del instrumento.
			@pdValor_Facial				= Monto del valor facial del instrumento.
			@piMoneda_Valor_Facial			= Código de la moneda del valor facial del instrumento.
			@pdValor_Mercado				= Monto del valor mercado del instrumento.
			@piMoneda_Valor_Mercado		= Código de la moneda del valor mercado del instrumento.
			@piCodigo_Tenencia					= Código de tenencia de la garantía.
			@pdtFecha_Prescripcion			= Fecha de prescripción de la garantía.
			@piConsecutivo_Operacion					= Consecutivo de la operación al a que está asociada la garantía real consultada. Este el dato llave usado para la búsqueda.
			@piTipo_Mitigador				= Código del tipo de mitigador de riesgo de la garantía.
			@piTipo_Documento_Legal		= Código del tipo de documento legal de la garantía.
			@pdMonto_Mitigador			= Monto mitigador asignado a la garantía.
			@piCodigo_Inscripcion				= Código del indicador de inscripción.
			@pdPorcentaje_Responsabilidad				= Porcentaje de responsabilidad asignado a la garantía.
			@piGrado_Gravamen				= Código del grado de gravamen de la garantía.
			@piGrado_Prioridades			= Código del grado de prioridad de la garantía.
			@pdMonto_Prioridades			= Monto de la prioridad de la garantía.
			@piOperacion_Especial			= Código de la operación especial de la garantía.
			@piTipo_Acreedor				= Código del tipo de persona del acreedor.
			@psCedula_Acreedor			= Identificación del acreedor.
			@psCedula_Usuario					= Identificación del usuario que realiza la actualización.
			@strIP						= Dirección IP de la máquina desde donde se realiza la actualización.
			@nOficina					= Código de la oficina desde donde se realiza la actualización.
			@pdPorcentaje_Aceptacion	= Porcentaje de aceptación asignado a la garantía.
	</Entradas>
	<Salidas>
		En caso de que la inserción se lleve acabo de forma correcta se retorna el valor 0 (cero), caso contrario se retorna el código de error 
		y la descripción del mismo. 
	</Salidas>
	<Autor>Javier Chaves Alvarado, BCR</Autor>
	<Fecha>22/08/2006</Fecha>
	<Requerimiento></Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>009 Req_Validaciones Indicador Inscripción, Siebel No. 1-21317176 (Correo electrónico enviado el 25/09/2012)</Requerimiento>
			<Fecha>28/09/2012</Fecha>
			<Descripción>
				Debido al ajuste aplicado, en virtud de la atención del requerimiento #009 (Siebel No. 1-21317176), 
				se detecta que la fecha de presentación siempre será reportada enel archivo de inconsistencias,
				sin que le usuario pueda realizar el ajuste del a misma desde la aplicación, por ende, 
				el usuario solicita que esta fecha se igual con la fecha de constitución de la garantía.
		</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Leonardo Cortes Mora, Lidersoft Internacional S.A</Autor>
			<Requerimiento>
				Actualizacion de procedimientos almacenado, Siebel No. 1-24350791.	
			</Requerimiento>
			<Fecha>23/06/2014</Fecha>
			<Descripción>
					Se agregan los campos de Usuario_Modifico, Fecha_Modificacion
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
			<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
			<Fecha>03/12/2015</Fecha>
			<Descripción>
				El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
				crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
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
******************************************************************/

	BEGIN TRANSACTION Act_Gar_Valor	

		BEGIN TRY

			UPDATE	dbo.GAR_GARANTIA_VALOR
			SET		fecha_constitucion = @pdtFecha_Constitucion,
					fecha_vencimiento_instrumento = @pdtFecha_Vencimiento,
					cod_clasificacion_instrumento = @piCodigo_Clasificacion,
					des_instrumento = @psCodigo_Instrumento,
					des_serie_instrumento = @psNumero_Serie,
					cod_tipo_emisor = @piTipo_Emisor,
					cedula_emisor = @psCedula_Emisor,
					premio = @pdPorcentaje_Premio,
					cod_isin = @psCodigo_ISIN,
					valor_facial = @pdValor_Facial,
					cod_moneda_valor_facial = @piMoneda_Valor_Facial, 
					valor_mercado = @pdValor_Mercado,
					cod_moneda_valor_mercado = @piMoneda_Valor_Mercado,
					cod_tenencia = @piCodigo_Tenencia,
					fecha_prescripcion = @pdtFecha_Prescripcion,
					Usuario_Modifico = @psCedula_Usuario,
					Fecha_Modifico = GETDATE()
			WHERE	cod_garantia_valor = @piConsecutivo_Garantia_Valor

	
			UPDATE  dbo.GAR_GARANTIAS_VALOR_X_OPERACION
			SET		cod_tipo_mitigador = @piTipo_Mitigador,
					cod_tipo_documento_legal = @piTipo_Documento_Legal,
					monto_mitigador = @pdMonto_Mitigador,
					cod_inscripcion = @piCodigo_Inscripcion,
					fecha_presentacion_registro = @pdtFecha_Constitucion,
					porcentaje_responsabilidad = @pdPorcentaje_Responsabilidad, 
					cod_grado_gravamen = @piGrado_Gravamen,
					cod_grado_prioridades = @piGrado_Prioridades,
					monto_prioridades = @pdMonto_Prioridades,
					cod_operacion_especial = @piOperacion_Especial,
					cod_tipo_acreedor = @piTipo_Acreedor,
					cedula_acreedor = @psCedula_Acreedor,
					Usuario_Modifico = @psCedula_Usuario,
					Fecha_Modifico = GETDATE(),
					Porcentaje_Aceptacion = @pdPorcentaje_Aceptacion --RQ_MANT_2015111010495738_00610: Se agrega este campo.
			WHERE	cod_operacion = @piConsecutivo_Operacion
				AND cod_garantia_valor = @piConsecutivo_Garantia_Valor

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION Act_Gar_Valor

		SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

	END CATCH	

IF (@@TRANCOUNT > 0)
	COMMIT TRANSACTION Act_Gar_Valor
RETURN 0
END