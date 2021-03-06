SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerNombreCliente', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerNombreCliente;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerNombreCliente] 
	@strCedula varchar(12),
	@strNombre varchar(150) output
AS

/******************************************************************
<Nombre>pa_ObtenerNombreCliente</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener el nombre del cliente apartir del número de cédula.</Descripción>
<Entradas>
	@strCedula = Número de cédula del cliente
</Entradas>
<Salidas>
	@strNombre = Nombre realcionado al número de cédula
</Salidas>
<Autor>Roger Rodríguez, Lidersoft Internacional S.A.</Autor>
<Fecha>07/05/2008</Fecha>
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

declare @nTipoID tinyint

select @strNombre = nombre_deudor
from GAR_DEUDOR
where cedula_deudor = @strCedula

if ((@strNombre = NULL) OR (@strNombre = '')) begin
	select 
		@strNombre = bsmcl_sno_clien, 
		@nTipoID = case bsmcl_scotipide
			when 1 then 1
			when 2 then 2
			when 3 then 3
			when 4 then 5
			when 5 then null
			when 6 then case bsmcl_scosececo when 55 then 4 else null end
		end
	from GAR_SICC_BSMCL
	where bsmcl_sco_ident = CONVERT(decimal(12,0), @strCedula) and bsmcl_estado = 'A'

	insert into GAR_DEUDOR (cedula_deudor, nombre_deudor, cod_tipo_deudor, cod_estado)
	values (@strCedula, @strNombre, @nTipoID, 1)
end



