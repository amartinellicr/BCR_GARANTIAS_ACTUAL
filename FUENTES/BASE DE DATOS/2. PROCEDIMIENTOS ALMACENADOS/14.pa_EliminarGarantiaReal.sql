SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_EliminarGarantiaReal', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_EliminarGarantiaReal;
GO

CREATE PROCEDURE [dbo].[pa_EliminarGarantiaReal]
	@nGarantiaReal bigint,
	@nOperacion bigint,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_EliminarGarantiaReal</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite eliminar la información de una garantía real 
             (hipoteca, cédula hipotecaria, prenda) de la base de datos GARANTIAS.
</Descripción>
<Entradas>
	@nGarantiaReal	= Código de la garantía real
	@nOperacion		= Consecutivo interno de la operación crediticia o del contrato
	@strUsuario		= Usuario que realiza la transacción
	@strIP			= IP de la máquina donde se realiza la transacción
	@nOficina		= Oficina donde se realiza la transacción
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

DECLARE @nVeces int

BEGIN TRANSACTION	

	DELETE GAR_GARANTIAS_REALES_X_OPERACION
	WHERE cod_operacion = @nOperacion AND cod_garantia_real = @nGarantiaReal

	SELECT @nVeces = count(*) FROM gar_garantias_reales_x_operacion WHERE cod_garantia_real = @nGarantiaReal

	IF (@nVeces = 0) BEGIN

		DELETE GAR_VALUACIONES_REALES WHERE cod_garantia_real = @nGarantiaReal

		DELETE GAR_GARANTIA_REAL WHERE cod_garantia_real = @nGarantiaReal
	END

COMMIT TRANSACTION
RETURN 0
