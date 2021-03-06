USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Consulta_Info_Garantia_Eliminar', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Consulta_Info_Garantia_Eliminar;
GO

CREATE PROCEDURE [dbo].[pa_Consulta_Info_Garantia_Eliminar]

@piCodigo_Catalogo INT,
@pnNumero_Tarjeta NUMERIC(16),
@piCodigo_Tipo_Garantia INT

AS

/******************************************************************
<Nombre>pa_Consulta_Info_Garantia_Eliminar</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar la información que se va a eliminar de garantías 
             por perfil o de garantía fiduciaria, según la garantía seleccionada para la tarjeta.
</Descripción>
<Entradas>
	@piCodigo_Catalogo		= Número del catálogo donde se encuentran almacenados los tipo de garantía por perfil
	@pnNumero_Tarjeta		= Número de tarjeta a la cual se le está realizando el cambio de tipo de garantía
	@piCodigo_Tipo_Garantia	= Código de garantía que se le va a asignar a la tarjeta
	@piCodigo_Tarjeta			= Variable interna que se utiliza para almacenar el codigo asignado a la tarjeta
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>04/12/2015</Fecha>
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

/*Variable que almacena el código de la tarjeta*/
DECLARE @piCodigo_Tarjeta INT;

SET @piCodigo_Tarjeta = (	SELECT	cod_tarjeta
							FROM	dbo.Tar_tarjeta
							WHERE	num_tarjeta = @pnNumero_Tarjeta)

IF(EXISTS (	SELECT  1
			FROM	dbo.CAT_ELEMENTO
			WHERE	cat_catalogo = @piCodigo_Catalogo
				AND cat_campo= @piCodigo_Tipo_Garantia))
BEGIN
	SELECT	GFT.cod_tarjeta, GFT.cod_garantia_fiduciaria, GFT.cod_tipo_mitigador,
			GFT.cod_tipo_documento_legal, GFT.monto_mitigador, GFT.porcentaje_responsabilidad,
			GFT.cod_operacion_especial, GFT.cod_tipo_acreedor, GFT.cedula_acreedor, 
			GFT.fecha_expiracion, GFT.monto_cobertura, GFT.des_observacion, 
			GFT.Porcentaje_Aceptacion, --RQ_MANT_2015111010495738_00610: Se agrega este campo
			TT1.cod_tipo_garantia
	FROM	dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA GFT
		INNER JOIN dbo.TAR_TARJETA TT1
		ON TT1.cod_tarjeta = GFT.cod_tarjeta
	WHERE	GFT.cod_tarjeta = @piCodigo_Tarjeta
END
ELSE
BEGIN
	SELECT	GPT.observaciones, TT1.cod_tipo_garantia
	FROM	dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA GPT
		INNER JOIN dbo.TAR_TARJETA TT1
		ON TT1.cod_tarjeta = GPT.cod_tarjeta
	WHERE GPT.cod_tarjeta = @piCodigo_Tarjeta
END
