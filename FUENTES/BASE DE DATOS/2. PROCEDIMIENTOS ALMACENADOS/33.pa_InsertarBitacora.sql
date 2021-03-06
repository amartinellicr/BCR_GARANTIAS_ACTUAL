SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_InsertarBitacora', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_InsertarBitacora;
GO

CREATE PROCEDURE [dbo].[pa_InsertarBitacora]
	@strTabla varchar(50),
    @strUsuario varchar(30),
	@strIP varchar(20),
	@nOficina int = NULL,
    @nOperacion smallint = NULL,
	@nTipoGarantia smallint = NULL,
	@strGarantia varchar(30) = NULL,
	@strOperacionCrediticia varchar(30) = NULL,
	@strConsulta text = NULL,
	@strConsulta2 text = NULL,
    @strCampoAfectado varchar(50) = NULL,
    @strEstadoAnteriorCampoAfectado varchar(100) = NULL,
	@strEstadoActualCampoAfectado varchar(100) = NULL
AS

/******************************************************************
<Nombre>pa_InsertarBitacora</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Procedimiento que se encarga de insertar los datos requeridos en la tabla Bitacora.</Descripción>
<Entradas>
	@strTabla						= Nombre de la tabla que fue afectada.
	@strUsuario						= Usuario que realiza la transacción.
	@strIP							= IP de la máquina donde se realiza la transacción.
	@nOficina						= Oficina donde se realiza la transacción.
	@nOperacion						= Código de la operación realizada, 1 = Insertar, 2 = Modificar y 3 = Borrar.
	@nTipoGarantia					= Código del tipo de la garantía tratada, 1 = Fiduciaria, 2 = Real y 3 = Valor.
	@strGarantia					= Es información relacionada con la grantía tratada, si es Fiduciaria se guarda el número de cédula del fiador, si es Real se almacena el número de finca y el partido (o clase de bien y número de placa) según sea el tipo y si es de Valor, se guarda el número de seguridad.
	@strOperacionCrediticia			= Es una cadena de caracteres que contiene, el número de contabilidad, el número de oficina, el código de la moneda, el código del producto (si aplica) y el código de la operación tratada. En caso de que sea una Garantía Fiduciaria de Tarjeta, se guerda el número de la tarjeta.
	@strConsulta					= Consulta SQL que fue ejecutada
	@strConsulta2					= Consulta SQL que fue ejecutada
	@strCampoAfectado				= Nombre del campo que ha sido afectado. 
	@strEstadoAnteriorCampoAfectado = Contenido que posee el campo antes del cambio.
	@strEstadoActualCampoAfectado	= Último contenido asignado al campo.
</Entradas>
<Salidas></Salidas>
<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
<Fecha>31/01/2008</Fecha>
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
	INSERT INTO GAR_BITACORA
	(
		des_tabla, 
		cod_usuario,
		cod_ip,
		cod_oficina,
		cod_operacion,
		fecha_hora,
		cod_tipo_garantia,
		cod_garantia,
		cod_operacion_crediticia,
		cod_consulta,
		cod_consulta2,
        des_campo_afectado,
		est_anterior_campo_afectado,
		est_actual_campo_afectado
	)
	VALUES
	(
		@strTabla,
		@strUsuario,
		@strIP,
		@nOficina,
		@nOperacion,
		GETDATE(),
		@nTipoGarantia,
		@strGarantia,
		@strOperacionCrediticia,
		@strConsulta,
		@strConsulta2,
		@strCampoAfectado,
		@strEstadoAnteriorCampoAfectado,
		@strEstadoActualCampoAfectado
	)

COMMIT TRANSACTION
RETURN 0


