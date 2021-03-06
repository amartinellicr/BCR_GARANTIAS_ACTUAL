SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_AsignarGarantiaGiro', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_AsignarGarantiaGiro;
GO

CREATE PROCEDURE [dbo].[pa_AsignarGarantiaGiro]
	@nGiro bigint,
	@nContrato bigint,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_AsignarGarantiaGiro</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite asignar las garantías de un contrato a un giro</Descripción>
<Entradas>
	@nGiro		= Consecutivo interno de la operación crediticia
	@nContrato	= Consecutivo interno del contrato
	@strUsuario = Usuario que realiza la transacción
	@strIP		= IP de la máquina donde se realiza la transacción
	@nOficina	= Oficina donde se realiza la transacción
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


BEGIN TRANSACTION	

	--Inserta las garantias fiduciarias
	INSERT INTO GAR_GARANTIAS_X_GIRO
	(
		cod_operacion_giro,
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia
	)
	SELECT
		@nGiro,
		@nContrato,
		b.cod_garantia_fiduciaria,
		b.cod_tipo_garantia
	FROM 
		GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION a,
		GAR_GARANTIA_FIDUCIARIA b
	WHERE
		a.cod_operacion = @nContrato
		AND a.cod_garantia_fiduciaria = b.cod_garantia_fiduciaria

	--Inserta las garantias reales
	INSERT INTO GAR_GARANTIAS_X_GIRO
	(
		cod_operacion_giro,
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia
	)
	SELECT
		@nGiro,
		@nContrato,
		b.cod_garantia_real,
		b.cod_tipo_garantia
	FROM 
		GAR_GARANTIAS_REALES_X_OPERACION a,
		GAR_GARANTIA_REAL b
	WHERE
		a.cod_operacion = @nContrato
		AND a.cod_garantia_real = b.cod_garantia_real

	--Inserta las garantias de valor
	INSERT INTO GAR_GARANTIAS_X_GIRO
	(
		cod_operacion_giro,
		cod_operacion,
		cod_garantia,
		cod_tipo_garantia
	)
	SELECT
		@nGiro,
		@nContrato,
		b.cod_garantia_valor,
		b.cod_tipo_garantia
	FROM 
		GAR_GARANTIAS_VALOR_X_OPERACION a,
		GAR_GARANTIA_VALOR b
	WHERE
		a.cod_operacion = @nContrato
		AND a.cod_garantia_valor = b.cod_garantia_valor

COMMIT TRANSACTION
RETURN 0

