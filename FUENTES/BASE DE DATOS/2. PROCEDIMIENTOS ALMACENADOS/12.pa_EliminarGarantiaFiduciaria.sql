SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pa_EliminarGarantiaFiduciaria]
	@nGarantiaFiduciaria bigint,
	@nOperacion bigint,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_EliminarGarantiaFiduciaria</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite eliminar la información de una garantía fiduciaria de la 
             base de datos GARANTIAS.
</Descripción>
<Entradas>
	@nGarantiaFiduciaria	= Código de la garantía fiduciaria
	@nOperacion				= Consecutivo interno de la operación crediticia o del contrato
	@strUsuario				= Usuario que realiza la transacción
	@strIP					= IP de la máquina donde se realiza la transacción
	@nOficina				= Oficina donde se realiza la transacción
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

	DELETE GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
	WHERE cod_operacion = @nOperacion AND cod_garantia_fiduciaria = @nGarantiaFiduciaria

COMMIT TRANSACTION
RETURN 0

