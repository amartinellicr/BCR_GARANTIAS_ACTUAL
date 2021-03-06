SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_ConsultarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_ConsultarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_ConsultarGarantiaReal]
	@nOperacion bigint,
	@nGarantia bigint
AS

/******************************************************************
<Nombre>pa_ConsultarAvanceXOficina</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite consultar la información perteneciente a una garantía real.</Descripción>
<Entradas>
	@nOperacion = Código de la operación a consultar.
	@nGarantia	= Código de la garantía real.
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
		<Requerimiento></Requerimiento>
		<Fecha>02/12/2010</Fecha>
		<Descripción>Debido a las actualizaciones sufridas en otros procedimientos almacenados, en donde se logra determinar 
			con mayor certeza las garantías asociadas a operaciones o contratos, se elimina el uso del indicador "cod_estado", 
            esto debido a que no permite modificar las garantías cuyo estado es 2 pero que ya se determinó que deben estar activas.
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

BEGIN 

select 
	a.cod_operacion, 
	a.cod_garantia_real, 
	b.cod_tipo_garantia, 
	b.cod_clase_garantia, 
	b.cod_tipo_garantia_real, 
	c.cat_descripcion as tipo_garantia_real, 
	case b.cod_tipo_garantia_real 
		when 1 then 'Partido: ' + ISNULL(convert(varchar(2), b.cod_partido),'') + ' - Finca: ' + ISNULL(b.numero_finca,'')  
		when 2 then 'Partido: ' + ISNULL(convert(varchar(2), b.cod_partido),'') + ' - Finca: ' + ISNULL(b.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2),b.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2),b.cedula_hipotecaria),'') 
		when 3 then 'Clase Bien: ' + ISNULL(b.cod_clase_bien,'') + ' - Número Placa: ' + ISNULL(b.num_placa_bien,'') 
	end as Garantia_Real, 
	b.cod_partido, 
	isnull(b.numero_finca,'') as numero_finca, 
	isnull(b.cod_grado,'') as cod_grado, 
	isnull(b.cedula_hipotecaria,'') as cedula_hipotecaria, 
	isnull(b.cod_clase_bien,'') as cod_clase_bien, 
	isnull(b.num_placa_bien,'') as num_placa_bien, 
	isnull(b.cod_tipo_bien,-1) as cod_tipo_bien, 
	isnull(a.cod_tipo_mitigador,-1) as cod_tipo_mitigador, 
	isnull(a.cod_tipo_documento_legal,-1) as cod_tipo_documento_legal, 
	isnull(a.monto_mitigador,0) as monto_mitigador, 
	isnull(a.cod_inscripcion,-1) as cod_inscripcion, 
	isnull(a.fecha_presentacion,'1900-01-01') as fecha_presentacion, 
	isnull(a.porcentaje_responsabilidad,0) as porcentaje_responsabilidad, 
	case 
		when a.cod_grado_gravamen is null then -1 
		when a.cod_grado_gravamen > 3 then 4 
		when a.cod_grado_gravamen < 1 then -1 
		else a.cod_grado_gravamen 
	end as cod_grado_gravamen, 
	isnull(a.cod_operacion_especial,0) as cod_operacion_especial, 
	isnull(a.fecha_constitucion,'1900-01-01') as fecha_constitucion, 
	isnull(a.fecha_vencimiento,'1900-01-01') as fecha_vencimiento, 
	case a.cod_tipo_acreedor 
		when null then 2 
		when -1 then 2 
		else a.cod_tipo_acreedor 
	end as cod_tipo_acreedor, 
	isnull(a.cedula_acreedor,'') as cedula_acreedor, 
	case a.cod_liquidez 
		when null then -1 
		when 0 then -1 
		else a.cod_liquidez 
	end as cod_liquidez, 
	isnull(a.cod_tenencia,-1) as cod_tenencia, 
	isnull(a.cod_moneda,-1) as cod_moneda, 
	isnull(a.fecha_prescripcion,'1900-01-01') as fecha_prescripcion,
	a.cod_estado
from 
	GAR_GARANTIAS_REALES_X_OPERACION a
	inner join GAR_GARANTIA_REAL b
	on a.cod_garantia_real = b.cod_garantia_real
	inner join CAT_ELEMENTO c
	on b.cod_tipo_garantia_real = c.cat_campo
	and c.cat_catalogo = 23
where
	a.cod_operacion = @nOperacion
	and a.cod_garantia_real = @nGarantia
	--and a.cod_estado = 1 /*Se elimina pues a este punto ya se ha determinado que la garantía está activa, según lo existente en PRMGT y que pudo ser comparado. Esto en procesos anteriores a este. AMM 02/12/2010*/

END
