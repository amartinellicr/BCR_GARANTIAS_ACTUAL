USE [GARANTIAS]
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_EliminarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_EliminarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_EliminarGarantiaReal]
	@pbConsecutivo_Garantia_Real BIGINT,
	@pbConsecutivo_Operacion BIGINT
AS
BEGIN
/******************************************************************
<Nombre>pa_EliminarGarantiaReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite eliminar la información de una garantía real 
             (hipoteca, cédula hipotecaria, prenda) de la base de datos GARANTIAS.
</Descripción>
<Entradas>
	@pbConsecutivo_Garantia_Real	= Código de la garantía real
	@pbConsecutivo_Operacion		= Consecutivo interno de la operación crediticia o del contrato
</Entradas>
<Salidas>
	En caso de que la inserción se lleve acabo de forma correcta se retorna el valor 0 (cero), caso contrario se retorna el código de error 
	y la descripción del mismo. 
</Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>02/12/2015</Fecha>
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

	DECLARE @viCantidadRegistros_Existentes INT

	BEGIN TRANSACTION Eli_Gar_Real

		BEGIN TRY

			DELETE	FROM dbo.GAR_GARANTIAS_REALES_X_OPERACION
			WHERE	cod_operacion = @pbConsecutivo_Operacion 
				AND cod_garantia_real = @pbConsecutivo_Garantia_Real

			--Inicia RQ_MANT_2015111010495738_00610
			DELETE	FROM dbo.GAR_POLIZAS_RELACIONADAS
			WHERE	cod_operacion = @pbConsecutivo_Operacion 
				AND cod_garantia_real = @pbConsecutivo_Garantia_Real
			--Finaliza RQ_MANT_2015111010495738_00610

		    SET @viCantidadRegistros_Existentes = (	SELECT	COUNT(*) 
													FROM	dbo.GAR_GARANTIAS_REALES_X_OPERACION 
													WHERE	cod_garantia_real = @pbConsecutivo_Garantia_Real)

			IF (@viCantidadRegistros_Existentes = 0) 
			BEGIN

				DELETE	FROM dbo.GAR_VALUACIONES_REALES 
				WHERE	cod_garantia_real = @pbConsecutivo_Garantia_Real

				DELETE	FROM dbo.GAR_GARANTIA_REAL 
				WHERE	cod_garantia_real = @pbConsecutivo_Garantia_Real
			END

		END TRY
		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION Eli_Gar_Real

			SELECT	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;

		END CATCH	

	IF (@@TRANCOUNT > 0)
		COMMIT TRANSACTION Eli_Gar_Real
	RETURN 0
END
