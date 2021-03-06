SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_EliminarGarantiaFiduciariaTarjeta', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_EliminarGarantiaFiduciariaTarjeta;
GO

CREATE PROCEDURE [dbo].[pa_EliminarGarantiaFiduciariaTarjeta]
	@nGarantiaFiduciaria bigint,
	@nTarjeta int,
	--Bitacora
	@strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina smallint = NULL
AS

/******************************************************************
<Nombre>pa_EliminarGarantiaFiduciariaTarjeta</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite eliminar la información de una garantía fiduciaria de una 
             tarjeta, de la base de datos GARANTIAS.
</Descripción>
<Entradas>
	@nGarantiaFiduciaria	= Código de la garantía fiduciaria
	@nTarjeta				= Consecutivo interno de la tarjeta
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

	DELETE TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA
	WHERE cod_tarjeta = @nTarjeta AND cod_garantia_fiduciaria = @nGarantiaFiduciaria

COMMIT TRANSACTION
RETURN 0
