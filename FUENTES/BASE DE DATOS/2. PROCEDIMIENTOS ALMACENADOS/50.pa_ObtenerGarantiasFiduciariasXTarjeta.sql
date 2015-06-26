SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ObtenerGarantiasFiduciariasXTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ObtenerGarantiasFiduciariasXTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_ObtenerGarantiasFiduciariasXTarjeta]
	@strTarjeta varchar(16)
AS

/******************************************************************
<Nombre>pa_ObtenerGarantiasFiduciariasXTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener las garantías fiduciarias que posee una tarjeta.</Descripción>
<Entradas>
	@strTarjeta = Número de la tarjeta a consultar.
</Entradas>
<Salidas></Salidas>
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

SET NOCOUNT ON

SELECT DISTINCT 
	d.cat_descripcion as tipo_persona, 
	c.cedula_fiador, 
	c.nombre_fiador, 
	isnull(c.cod_tipo_fiador,-1) as cod_tipo_fiador, 
	isnull(b.cod_tipo_mitigador,-1) as cod_tipo_mitigador, 
	isnull(b.cod_tipo_documento_legal,-1) as cod_tipo_documento_legal, 
	b.monto_mitigador, 
	isnull(b.porcentaje_responsabilidad,0) as porcentaje_responsabilidad, 
	isnull(b.cod_operacion_especial,0) as cod_operacion_especial, 
	case b.cod_tipo_acreedor 
		when null then 2 
		when -1 then 2 
		else b.cod_tipo_acreedor 
	end as cod_tipo_acreedor, 
	isnull(b.cedula_acreedor,'') as cedula_acreedor, 
	b.cod_tarjeta as cod_operacion, 
	b.cod_garantia_fiduciaria,
	isnull(b.fecha_expiracion,'1900-01-01') as fecha_expiracion, 
	isnull(b.monto_cobertura, 0) as monto_cobertura,
	1 as cod_estado,
    isnull(b.des_observacion,'') as des_observacion
FROM 
	TAR_TARJETA a, 
	TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA b, 
	TAR_GARANTIA_FIDUCIARIA c, 
	CAT_ELEMENTO d
WHERE 
	a.cod_tarjeta = b.cod_tarjeta
	and b.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria  
	and c.cod_tipo_fiador *= d.cat_campo  
	and d.cat_catalogo= 1 
	and a.num_tarjeta = @strTarjeta

