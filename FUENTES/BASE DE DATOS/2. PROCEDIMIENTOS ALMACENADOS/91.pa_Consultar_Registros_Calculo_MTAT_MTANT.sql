USE [GARANTIAS]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('Consultar_Registros_Calculo_MTAT_MTANT', 'P') IS NOT NULL
	DROP PROCEDURE Consultar_Registros_Calculo_MTAT_MTANT;
GO

CREATE PROCEDURE [dbo].[Consultar_Registros_Calculo_MTAT_MTANT]
AS
BEGIN

/*****************************************************************************************************************************************************
	<Nombre>Consultar_Registros_Calculo_MTAT_MTANT</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>
		Procedimiento almacenado que obtiene la información referente a los registros generados por el cálculo de los montos de las tasaciones 
		actualizadas del tereeno y no terreno.
	</Descripción>
	<Entradas>
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>04/11/2013</Fecha>
	<Requerimiento>Req_027 Cálculo de Campo Terreno Actualizado, Siebel No. 1-24077731</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, GrupoMas S.A.</Autor>
			<Requerimiento>RQ_MANT_2015062410418218_00025 Segmentación campos % aceptacion Terreno y No terreno</Requerimiento>
			<Fecha>21/09/2015</Fecha>
			<Descripción>
				Se incorpora la obtención de los campos referentes al porcentaje de aceptación del terreno, porcentaje de aceptación del no terreno,
				porcentaje de aceptación del terreno calculado y el porcentaje de aceptación del no terreno calculado.
			</Descripción>
		</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripción></Descripción>
		</Cambio>
	</Historial>
*****************************************************************************************************************************************************/

	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET DATEFORMAT dmy

	SELECT	COALESCE(CONVERT(VARCHAR(30), Fecha_Hora, 109), '') AS FECHA_HORA, 
			COALESCE(Id_Garantia, '') AS ID_GARANTIA,
			COALESCE(CONVERT(VARCHAR(5), Tipo_Garantia_Real), '') AS TIPO_GARANTIA_REAL,
			COALESCE(CONVERT(VARCHAR(5), Clase_Garantia), '') AS CLASE_GARANTIA,
			COALESCE(CONVERT(VARCHAR(10), Semestre_Calculado, 103), '') AS SEMESTRE_CALCULADO,
			COALESCE(CONVERT(VARCHAR(10), Fecha_Valuacion, 103), '') AS FECHA_VALUACION,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(MONEY, Monto_Ultima_Tasacion_Terreno)), 1), '') AS MTO_ULTIMA_TASACION_TERRENO,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(MONEY, Monto_Ultima_Tasacion_No_Terreno)), 1), '') AS MTO_ULTIMA_TASACION_NO_TERRENO,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(DECIMAL(18,2), Tipo_Cambio)), 1), '') AS TIPO_CAMBIO,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(DECIMAL(18,2), Indice_Precios_Consumidor)), 1), '') AS IPC,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(DECIMAL(18,2), Tipo_Cambio_Anterior)), 1), '') AS TIPO_CAMBIO_ANTERIOR, 
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(DECIMAL(18,2), Indice_Precios_Consumidor_Anterior)), 1), '') AS IPC_ANTERIOR,
			COALESCE(CONVERT(VARCHAR(100), Factor_Tipo_Cambio, 1), '') AS FACTOR_TIPO_CAMBIO,
			COALESCE(CONVERT(VARCHAR(100), Factor_IPC, 1), '') AS FACTOR_IPC,
			COALESCE(CONVERT(VARCHAR(100), Porcentaje_Depreciacion_Semestral), '') AS PORCENTAJE_DEPRECIACION_SEMESTRAL,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(MONEY, Monto_Tasacion_Actualizada_Terreno)), 1), '') AS MTO_TASACION_ACTUALIZADA_TERRENO,
			COALESCE(CONVERT(VARCHAR(100), (CONVERT(MONEY, Monto_Tasacion_Actualizada_No_Terreno)), 1), '') AS MTO_TASACION_ACTUALIZADA_NO_TERRENO, 
			COALESCE(CONVERT(VARCHAR(100), Numero_Registro), '') AS NUMERO_REGISTRO,
			COALESCE(CONVERT(VARCHAR(100), Codigo_Operacion), '') AS CODIGO_OPERACION,
			COALESCE(CONVERT(VARCHAR(100), Codigo_Garantia), '') AS CODIGO_GARANTIA,
			COALESCE(CONVERT(VARCHAR(100), Tipo_Bien), '') AS TIPO_BIEN,
			COALESCE(CONVERT(VARCHAR(100), Total_Semestres_Calcular), '') AS TOTAL_SEMESTRES_CALCULAR,
			COALESCE(Usuario, '') AS USUARIO,
			
			--INICIO RQ: RQ_MANT_2015062410418218_00025, Se obtienen campos nuevos
			
			COALESCE(CONVERT(VARCHAR(10), Porcentaje_Aceptacion_Base), '') AS PORCENTAJE_ACEPTACION_BASE,
			COALESCE(CONVERT(VARCHAR(10), Porcentaje_Aceptacion_Terreno), '') AS PORCENTAJE_ACEPTACION_TERRENO,
			COALESCE(CONVERT(VARCHAR(10), Porcentaje_Aceptacion_No_Terreno), '') AS PORCENTAJE_ACEPTACION_NO_TERRENO,
			COALESCE(CONVERT(VARCHAR(10), Porcentaje_Aceptacion_Terreno_Calculado), '') AS PORCENTAJE_ACEPTACION_TERRENO_CALCULADO,
			COALESCE(CONVERT(VARCHAR(10), Porcentaje_Aceptacion_No_Terreno_Calculado), '') AS PORCENTAJE_ACEPTACION_NO_TERRENO_CALCULADO
		
			--FIN RQ: RQ_MANT_2015062410418218_00025, Se obtienen campos nuevos
			
	FROM	dbo.TMP_CALCULO_MTAT_MTANT
	
END