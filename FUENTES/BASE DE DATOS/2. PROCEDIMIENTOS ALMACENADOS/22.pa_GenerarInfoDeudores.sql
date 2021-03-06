
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GenerarInfoDeudores', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GenerarInfoDeudores;
GO

CREATE PROCEDURE [dbo].[pa_GenerarInfoDeudores] AS

	-- =============================================
	-- Autor:		Javier Chaves Alvarado, BCR
	-- Fecha:		22/08/2006
	-- Versión:		1.0
	-- Descripción:	Obtiene la información que requiere el archivo de deudores que genera el sistema. 
	-- Sistemas:	BCRGARANTIAS.
	-- =============================================
	--				HISTORIAL DE CAMBIOS
	-- =============================================
	-- Autor:	Arnoldo Martinelli M., Lidersoft Internacional S.A.				
	-- Fecha Modificación:	04/05/2012
	-- Versión:	1.1						
	-- Descripción:	Se agrega el campo correspondiente al tipo de deudor, indicadon si se trata de un 
	--              deudor (0), codeudor (1) o ambos (2).
	-- =============================================
	-- Autor:					
	-- Fecha Modificación:	 
	-- Versión:							
	-- Descripción:				
	-- =============================================

BEGIN
	
	SET NOCOUNT ON;

    SELECT 
	a.cedula_deudor as CEDULA_DEUDOR,
	a.cod_tipo_deudor as TIPO_PERSONA_DEUDOR,
	a.cod_condicion_especial as CONDICIONES_ESPECIALES,
	a.cod_tipo_asignacion as TIPO_ASIGNACION,
	b.cod_capacidad_pago as NIVEL_CAPACIDAD_PAGO,
	a.cod_generador_divisas as INDICADOR_GENERADOR_DIVISAS,
	a.cod_vinculado_entidad as INDICADOR_VINCULADO_ENTIDAD,
	b.sensibilidad_tipo_cambio as SENSIBILIDAD_TIPO_CAMBIO,
	substring(convert(varchar(10),b.fecha_capacidad_pago,103),1,2) + '/' + 
	substring(convert(varchar(10),b.fecha_capacidad_pago,103),4,2) + '/' + 
	substring(convert(varchar(10),b.fecha_capacidad_pago,103),7,4) as FECHA_VALUACION
FROM 
	GAR_DEUDOR a 
	LEFT OUTER JOIN GAR_CAPACIDAD_PAGO b 
	ON a.cedula_deudor = b.cedula_deudor 
	AND b.fecha_capacidad_pago = (SELECT MAX(fecha_capacidad_pago) FROM GAR_CAPACIDAD_PAGO WHERE cedula_deudor = a.cedula_deudor) 
ORDER BY 
	convert(decimal(18),a.cedula_deudor)
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

