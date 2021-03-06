SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_GarantiasXContrato', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_GarantiasXContrato;
GO

CREATE PROCEDURE [dbo].[pa_GarantiasXContrato]
	@nContabilidad tinyint,
	@nOficina smallint,
	@nMoneda tinyint,
	@nContrato decimal(7)
AS

/******************************************************************
<Nombre>pa_GarantiasXContrato</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Este procedimiento almacenado permite obtener las garantías que posee un contrato.</Descripción>
<Entradas>
	@nContabilidad	= Código de la contabilidad a la que pertenece el contrato
	@nOficina		= Oficina donde se realizó la transacción
	@nMoneda		= Código de la moneda en la que se encuentra el contrato
	@nContrato		= Código del contrato.
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

SET NOCOUNT ON

SELECT DISTINCT 
	b.cod_operacion,
	b.cod_garantia_fiduciaria,
	b.cod_tipo_documento_legal,
	'[Fiador] ' + c.cedula_fiador + ' - ' + c.nombre_fiador as garantia,
	b.cod_estado

INTO #TMP_GARANTIAS_FIDUCIARIAS

FROM 
	GAR_OPERACION a, 
	GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b, 
	GAR_GARANTIA_FIDUCIARIA c, 
	GAR_SICC_PRMCA d
WHERE 
	a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina 
	and a.cod_moneda = @nMoneda
	and a.num_operacion is null
	and a.num_contrato = @nContrato
	and a.cod_operacion = b.cod_operacion  
	and b.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria  
	and a.cod_estado = 1  
	and b.cod_estado = 1 
	and a.cod_contabilidad = d.prmca_pco_conta
	and a.cod_oficina = d.prmca_pco_ofici
	and a.cod_moneda = d.prmca_pco_moned
	and a.cod_producto = d.prmca_pco_produc
	and a.num_contrato = convert(decimal(7),d.prmca_pnu_contr)
	and d.prmca_estado = 'A' 
	--and convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4))
	and ((convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		or
		(convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) < convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		and d.prmca_pmo_utiliz > 0)

DECLARE 
	@nOperacion1 bigint,
	@nGarantia1 bigint,
	@nTipoDocumentoLegal1 smallint,
	@nGarantiaAnterior1 bigint

DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_operacion,
	cod_garantia_fiduciaria,
	cod_tipo_documento_legal
FROM 
	#TMP_GARANTIAS_FIDUCIARIAS
ORDER BY
	cod_operacion,
	cod_garantia_fiduciaria,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nOperacion1, @nGarantia1, @nTipoDocumentoLegal1

SET @nGarantiaAnterior1 = -1

WHILE @@FETCH_STATUS = 0 BEGIN
     	IF (@nGarantiaAnterior1 != @nGarantia1) BEGIN
		UPDATE #TMP_GARANTIAS_FIDUCIARIAS
		SET cod_estado = 1
		WHERE cod_garantia_fiduciaria = @nGarantia1
		AND cod_tipo_documento_legal = @nTipoDocumentoLegal1
	END
	ELSE BEGIN
		UPDATE #TMP_GARANTIAS_FIDUCIARIAS
		SET cod_estado = 2
		WHERE cod_garantia_fiduciaria = @nGarantia1
		AND cod_tipo_documento_legal = @nTipoDocumentoLegal1
	END
	
	SET @nGarantiaAnterior1 = @nGarantia1
      
      	FETCH NEXT FROM garantias_cursor INTO @nOperacion1, @nGarantia1, @nTipoDocumentoLegal1
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor


SELECT DISTINCT 
	b.cod_operacion,
	b.cod_garantia_real,
	b.cod_tipo_documento_legal,
	case c.cod_tipo_garantia_real  
		when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), c.cod_partido),'') + ' - Finca: ' + ISNULL(c.numero_finca,'')  
		when 2 then '[Cédula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), c.cod_partido),'') + ' - Finca: ' + ISNULL(c.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), c.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2), c.cedula_hipotecaria),'')  
		when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), c.cod_clase_bien),'') + ' - Placa: ' + ISNULL(c.num_placa_bien,'')  
	end as garantia, 
	c.cod_tipo_garantia_real,
	c.numero_finca,
	c.cod_grado,
	c.cod_clase_bien,
	c.num_placa_bien,
	b.cod_estado

INTO #TMP_GARANTIAS_REALES

FROM 
	GAR_OPERACION a 
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION b 
	ON a.cod_operacion = b.cod_operacion 
	INNER JOIN GAR_GARANTIA_REAL c 
	ON b.cod_garantia_real = c.cod_garantia_real 
	INNER JOIN GAR_SICC_PRMCA d
	on a.cod_contabilidad = d.prmca_pco_conta
	and a.cod_oficina = d.prmca_pco_ofici
	and a.cod_moneda = d.prmca_pco_moned
	and a.cod_producto = d.prmca_pco_produc
	and a.num_contrato = convert(decimal(7),d.prmca_pnu_contr)
WHERE  
	a.cod_estado = 1 
	and b.cod_estado = 1
	and d.prmca_estado = 'A' 
	--and convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4))
	and ((convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		or
		(convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) < convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		and d.prmca_pmo_utiliz > 0)
	and a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina
	and a.cod_moneda = @nMoneda
	and a.num_operacion is null
	and a.num_contrato = @nContrato

DECLARE 
	@nOperacion2 bigint,
	@nGarantia2 bigint,
	@nTipoGarantiaReal2 tinyint,
	@strFinca2 varchar(25),
	@strGrado2 varchar(2),
	@strPlacaBien2 varchar(25),
	@nTipoDocumentoLegal2 smallint,
	@strFincaAnterior2 varchar(25),
	@strGradoAnterior2 varchar(2),
	@strPlacaBienAnterior2 varchar(25)

DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_operacion,
	cod_garantia_real,
	cod_tipo_garantia_real,
	numero_finca,
	cod_grado,
	num_placa_bien,
	cod_tipo_documento_legal
FROM 
	#TMP_GARANTIAS_REALES
ORDER BY
	cod_operacion,
	numero_finca,
	cod_grado,
	cod_clase_bien,
	num_placa_bien,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia2, @nTipoGarantiaReal2, @strFinca2, @strGrado2, @strPlacaBien2, @nTipoDocumentoLegal2

SET @strFincaAnterior2 = ''
SET @strGradoAnterior2 = ''
SET @strPlacaBienAnterior2 = ''

IF (@@CURSOR_ROWS > 1) BEGIN
	WHILE @@FETCH_STATUS = 0 BEGIN
		--Hipotecas
		IF (@nTipoGarantiaReal2 = 1) BEGIN
		     	IF (@strFincaAnterior2 != @strFinca2) BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 1
				WHERE cod_garantia_real = @nGarantia2
				AND numero_finca = @strFinca2
			END
			ELSE BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 2
				WHERE cod_garantia_real = @nGarantia2
				AND numero_finca = @strFinca2
			END
		END
		--Cedulas Hipotecarias
		ELSE IF (@nTipoGarantiaReal2 = 2) BEGIN
		     	IF (@strFincaAnterior2 != @strFinca2) BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 1
				WHERE cod_garantia_real = @nGarantia2
				AND numero_finca = @strFinca2
				AND cod_grado = @strGrado2
			END
			ELSE IF ((@strFincaAnterior2 = @strFinca2) AND (@strGradoAnterior2 != @strGrado2)) BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 1
				WHERE cod_garantia_real = @nGarantia2
				AND numero_finca = @strFinca2
				AND cod_grado = @strGrado2
			END
			ELSE IF ((@strFincaAnterior2 = @strFinca2) AND (@strGradoAnterior2 = @strGrado2)) BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 2
				WHERE cod_garantia_real = @nGarantia2
				AND numero_finca = @strFinca2
				AND cod_grado = @strGrado2
			END
		END
		--Prendas
		ELSE IF (@nTipoGarantiaReal2 = 3) BEGIN
		     	IF (@strPlacaBienAnterior2 != @strPlacaBien2) BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 1
				WHERE cod_garantia_real = @nGarantia2
				AND num_placa_bien = @strPlacaBien2
			END
			ELSE BEGIN
				UPDATE #TMP_GARANTIAS_REALES
				SET cod_estado = 2
				WHERE cod_garantia_real = @nGarantia2
				AND num_placa_bien = @strPlacaBien2
			END
		END 
		
		SET @strFincaAnterior2 = @strFinca2
		SET @strGradoAnterior2 = @strGrado2
		SET @strPlacaBienAnterior2 = @strPlacaBien2
	      
	      	FETCH NEXT FROM garantias_cursor INTO @nOperacion2, @nGarantia2, @nTipoGarantiaReal2, @strFinca2, @strGrado2, @strPlacaBien2, @nTipoDocumentoLegal2
	END
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor


SELECT DISTINCT 
	b.cod_operacion,
	b.cod_garantia_valor,
	b.cod_tipo_documento_legal,	
	'[Número de Seguridad] ' + c.numero_seguridad as garantia,
	c.numero_seguridad,
	b.cod_estado

INTO #TMP_GARANTIAS_VALOR

FROM 
	GAR_OPERACION a, 
	GAR_GARANTIAS_VALOR_X_OPERACION b, 
	GAR_GARANTIA_VALOR c, 
	GAR_SICC_PRMCA d
WHERE 
	a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina
	and a.cod_moneda = @nMoneda
	and a.num_operacion is null
	and a.num_contrato = @nContrato
	and a.cod_operacion = b.cod_operacion  
	and b.cod_garantia_valor = c.cod_garantia_valor  
	and a.cod_estado = 1  
	and b.cod_estado = 1 
	and a.cod_contabilidad = d.prmca_pco_conta
	and a.cod_oficina = d.prmca_pco_ofici
	and a.cod_moneda = d.prmca_pco_moned
	and a.num_contrato = convert(decimal(7),d.prmca_pnu_contr)
	and d.prmca_estado = 'A' 
	--and convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4))
	and ((convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		or
		(convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) < convert(datetime,substring(convert(varchar(10),getdate(),111),9,2) + '/' + substring(convert(varchar(10),getdate(),111),6,2) + '/' + substring(convert(varchar(10),getdate(),111),1,4)))
		and d.prmca_pmo_utiliz > 0)

DECLARE 
	@nOperacion3 bigint,
	@nGarantia3 bigint,
	@strSeguridad3 varchar(25),
	@nTipoDocumentoLegal3 smallint,
	@nGarantiaAnterior3 bigint,
	@strSeguridadAnterior3 varchar(25)

DECLARE garantias_cursor CURSOR FOR 
SELECT 
	cod_operacion,
	cod_garantia_valor,
	numero_seguridad,
	cod_tipo_documento_legal
FROM 
	#TMP_GARANTIAS_VALOR
ORDER BY
	cod_operacion,
	numero_seguridad,
	cod_tipo_documento_legal DESC

OPEN garantias_cursor
FETCH NEXT FROM garantias_cursor INTO @nOperacion3, @nGarantia3, @strSeguridad3, @nTipoDocumentoLegal3

SET @nGarantiaAnterior3 = -1
SET @strSeguridadAnterior3 = ''

WHILE @@FETCH_STATUS = 0 BEGIN
     	IF (@strSeguridadAnterior3 != @strSeguridad3) BEGIN
		UPDATE #TMP_GARANTIAS_VALOR
		SET cod_estado = 1
		WHERE cod_garantia_valor = @nGarantia3
		AND cod_tipo_documento_legal = @nTipoDocumentoLegal3
	END
	ELSE BEGIN
		UPDATE #TMP_GARANTIAS_VALOR
		SET cod_estado = 2
		WHERE cod_garantia_valor = @nGarantia3
		AND cod_tipo_documento_legal = @nTipoDocumentoLegal3
	END
	
	SET @strSeguridadAnterior3 = @strSeguridad3
      
      	FETCH NEXT FROM garantias_cursor INTO @nOperacion3, @nGarantia3, @strSeguridad3, @nTipoDocumentoLegal3
END

CLOSE garantias_cursor
DEALLOCATE garantias_cursor


SELECT garantia
FROM #TMP_GARANTIAS_FIDUCIARIAS
WHERE cod_estado = 1
UNION ALL
SELECT garantia
FROM #TMP_GARANTIAS_REALES 
WHERE cod_estado = 1
UNION ALL
SELECT garantia
FROM #TMP_GARANTIAS_VALOR
WHERE cod_estado = 1
ORDER BY garantia




