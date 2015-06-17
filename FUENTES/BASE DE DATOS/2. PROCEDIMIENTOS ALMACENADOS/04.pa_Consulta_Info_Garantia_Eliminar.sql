SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_Consulta_Info_Garantia_Eliminar]

@codigo_catalogo int,
@numero_tarjeta numeric(16),
@codigo_tipo_garantia int

AS

/******************************************************************
<Nombre>pa_Consulta_Info_Garantia_Eliminar</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar la información que se va a eliminar de garantías 
             por perfil o de garantía fiduciaria, según la garantía seleccionada para la tarjeta.
</Descripción>
<Entradas>
	@codigo_catalogo		= Número del catálogo donde se encuentran almacenados los tipo de garantía por perfil
	@numero_tarjeta			= Número de tarjeta a la cual se le está realizando el cambio de tipo de garantía
	@codigo_tipo_garantia	= Código de garantía que se le va a asignar a la tarjeta
	@codigo_tarjeta			= Variable interna que se utiliza para almacenar el codigo asignado a la tarjeta
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
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

/*Variable que almacena el código de la tarjeta*/
declare @codigo_tarjeta int;
set @codigo_tarjeta = (select cod_tarjeta
					   from dbo.Tar_tarjeta
					   where num_tarjeta = @numero_tarjeta)

if(@codigo_tipo_garantia in (select cat_campo 
							 from Cat_Elemento 
							 where cat_catalogo = @codigo_catalogo))
begin
	select gft.cod_tarjeta, gft.cod_garantia_fiduciaria, gft.cod_tipo_mitigador,
		   gft.cod_tipo_documento_legal, gft.monto_mitigador, gft.porcentaje_responsabilidad,
		   gft.cod_operacion_especial, gft.cod_tipo_acreedor, gft.cedula_acreedor, 
		   gft.fecha_expiracion, gft.monto_cobertura, gft.des_observacion,
		   t.cod_tipo_garantia

	from dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA gft

	inner join dbo.TAR_TARJETA t
	on t.cod_tarjeta = gft.cod_tarjeta

	where gft.cod_tarjeta = @codigo_tarjeta
end
else
begin
	select gpt.observaciones, t.cod_tipo_garantia
	from dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA gpt

	inner join dbo.TAR_TARJETA t
	on t.cod_tarjeta = gpt.cod_tarjeta

	where gpt.cod_tarjeta = @codigo_tarjeta
end
