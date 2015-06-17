
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pa_Rpt_Bitacora]
	-- Add the parameters for the stored procedure here
	@strCodigoUsuario nvarchar(30) = NULL, 
	@dFechaInicial datetime = NULL,
	@dFechaFinal datetime = NULL,
	@nCodigoOperacion int = NULL,
	@strIP nvarchar(20) = NULL,
    @strDescTabla nvarchar(50) = NULL,
	@strCriterioOrden nvarchar(20) = 'cod_usuario'
	
AS

/******************************************************************
	<Nombre>Modificar_Deudor</Nombre>
	<Sistema>BCRGarantías</Sistema>
	<Descripción>Permite realizar la consulta de la bitácora, según los filtros dados y ordenados 
				 según el criterio solicitado
	</Descripción>
	<Entradas>@strCodigoUsuario		= Identificación del usuario que realizó una determinada transacción.
  			  @dFechaInicial		= Fecha desde la que se quiere generar el reporte.
			  @dFechaFinal			= Fecha límite en la que se desea culminar el reporte.
			  @nCodigoOperacion		= Indicador del tipo de operación realizada (es decir, si se trata 
                                      de una inserción, modificación o eliminación).
			  @strIP				= Dirección IP de la máquina desde la cual se realizó la transacción.
			  @strDescTabla			= Código del mantenimiento del cual se requiere la información.
			  @strCriterioOrden		= Código del tipo de criterio de orden que se desea aplicar a los datos obtenidos.
	</Entradas>
	<Salidas></Salidas>
	<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
	<Fecha>08/04/2008</Fecha>
	<Requerimiento>Codeudores</Requerimiento>
	<Versión>1.0</Versión>
	<Historial>
		<Cambio>
			<Autor>Arnoldo Martinelli Marín, Lidersoft Internacional S.A.</Autor>
			<Requerimiento>Codeudores</Requerimiento>
			<Fecha>15/05/2012</Fecha>
			<Descripción>Se inhabilitan las consultas sobre deudores. 
						 Se crea una nueva consulta que obtenga los registros de los deudores/codeudores
                         sin que tome en cuenta el tipo de garantía.
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

	SET NOCOUNT ON;

   DECLARE @VariableTabla TABLE(des_tabla varchar(50) NOT NULL, 
								 cod_usuario varchar(30) NOT NULL, 
								 cod_ip varchar(20) NOT NULL, 
								 cod_operacion smallint NOT NULL, 
								 fecha_hora datetime NOT NULL, 
                                 cod_tipo_garantia smallint NULL, 
                                 cod_garantia varchar(30) NULL, 
                                 cod_operacion_crediticia varchar(30) NULL, 
                                 des_campo_afectado varchar(50) NULL, 
			                     est_anterior_campo_afectado varchar(100) NULL, 
                                 est_actual_campo_afectado varchar(100) NULL,
								 fecha_corte datetime NULL,
								 des_operacion varchar(3) NULL,
								 des_tipo_garantia varchar(15) NULL)

	-- Se seleccionan todas las tablas
    IF(@strDescTabla = '-1')
	BEGIN

		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
	END
	ELSE IF(@strDescTabla = '1') -- Se seleccionan las garantías fiduciarias
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND ((des_tabla LIKE '%GAR_GARANTIA_FIDUCIARIA%') 
				OR (des_tabla LIKE '%GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION%'))
	END
	ELSE IF(@strDescTabla = '2') -- Se seleccionan las garantías fiduciarias de tarjetas
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND ((des_tabla LIKE '%TAR_GARANTIA_FIDUCIARIA%') 
				OR (des_tabla LIKE '%TAR_TARJETA%')
				OR (des_tabla LIKE '%TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA%')
				OR (des_tabla LIKE '%TAR_GARANTIAS_X_PERFIL_X_TARJETA%'))
	END
	ELSE IF(@strDescTabla = '3') -- Se seleccionan las garantías reales
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND ((des_tabla LIKE '%GAR_GARANTIA_REAL%') 
				OR (des_tabla LIKE '%GAR_GARANTIAS_REALES_X_OPERACION%'))
	END
	ELSE IF(@strDescTabla = '4') -- Se seleccionan las garantías de valor
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(CONVERT(datetime,@dFechaInicial), fecha_hora) AND ISNULL(CONVERT(datetime,@dFechaFinal), fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND ((des_tabla LIKE '%GAR_GARANTIA_VALOR%') 
				OR (des_tabla LIKE '%GAR_GARANTIAS_VALOR_X_OPERACION%'))
	END
	ELSE IF(@strDescTabla = '5') -- Se seleccionan las garantías por giro
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_GARANTIAS_X_GIRO%') 
	END
	ELSE IF(@strDescTabla = '6') -- Se selecciona la capacidad de pago
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 0 THEN 'DEUDOR'  
														  WHEN 1 THEN 'CODEUDOR'
													      WHEN 2 THEN 'DEUDOR/CODEUDOR'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_CAPACIDAD_PAGO%') 
	END
	ELSE IF(@strDescTabla = '7') -- Se seleccionan los deudores/codeudores
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 0 THEN 'DEUDOR'  
														  WHEN 1 THEN 'CODEUDOR'
													      WHEN 2 THEN 'DEUDOR/CODEUDOR'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_DEUDOR%') 
	END
--	ELSE IF(@strDescTabla = '7') -- Se seleccionan los deudores de garantías fiduciarias
--	BEGIN
--		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
--               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
--               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
--               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
--			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
--               fecha_corte = GETDATE(), 
--			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
--												  WHEN 2 THEN 'MOD'
--												  WHEN 3 THEN 'BOR'
--												  ELSE '-'
--							   END,
--			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
--														  WHEN 2 THEN 'REAL'
--													      WHEN 3 THEN 'VALOR'
--													      WHEN 4 THEN 'PERFIL'
--													      ELSE '-'
--							       END
--		FROM dbo.GAR_BITACORA
--		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
--			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
--			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
--			AND cod_ip = ISNULL(@strIP, cod_ip)
--			AND cod_tipo_garantia = 1
--			AND (des_tabla LIKE '%GAR_DEUDOR%') 
--	END
--	ELSE IF(@strDescTabla = '8') -- Se seleccionan los deudores de garantías reales
--	BEGIN
--		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
--               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
--               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
--               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
--			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
--               fecha_corte = GETDATE(), 
--			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
--												  WHEN 2 THEN 'MOD'
--												  WHEN 3 THEN 'BOR'
--												  ELSE '-'
--							   END,
--			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
--														  WHEN 2 THEN 'REAL'
--													      WHEN 3 THEN 'VALOR'
--													      WHEN 4 THEN 'PERFIL'
--													      ELSE '-'
--							       END
--		FROM dbo.GAR_BITACORA
--		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
--			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
--			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
--			AND cod_ip = ISNULL(@strIP, cod_ip)
--			AND cod_tipo_garantia = 2
--			AND (des_tabla LIKE '%GAR_DEUDOR%') 
--	END
--	ELSE IF(@strDescTabla = '9') -- Se seleccionan los deudores de garantías de valor
--	BEGIN
--		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
--               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
--               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
--               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
--			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
--               fecha_corte = GETDATE(), 
--			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
--												  WHEN 2 THEN 'MOD'
--												  WHEN 3 THEN 'BOR'
--												  ELSE '-'
--							   END,
--			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
--														  WHEN 2 THEN 'REAL'
--													      WHEN 3 THEN 'VALOR'
--													      WHEN 4 THEN 'PERFIL'
--													      ELSE '-'
--							       END
--		FROM dbo.GAR_BITACORA
--		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
--			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
--			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
--			AND cod_ip = ISNULL(@strIP, cod_ip)
--			AND cod_tipo_garantia = 3
--			AND (des_tabla LIKE '%GAR_DEUDOR%') 
--	END
	ELSE IF(@strDescTabla = '8') -- Se seleccionan las valuaciones de los fiadores
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_VALUACIONES_FIADOR%') 
	END
	ELSE IF(@strDescTabla = '9') -- Se seleccionan las valuaciones reales
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_VALUACIONES_REALES%') 
	END
	ELSE IF(@strDescTabla = '10') -- Se seleccionan los peritos
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_PERITO%') 
	END
	ELSE IF(@strDescTabla = '11') -- Se seleccionan las empresas
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%GAR_EMPRESA%') 
	END
	ELSE IF(@strDescTabla = '12') -- Se seleccionan los elementos de catálogos
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%CAT_ELEMENTO%') 
	END
	ELSE IF(@strDescTabla = '13') -- Se seleccionan los perfiles
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%SEG_PERFIL%') 
	END
	ELSE IF(@strDescTabla = '14') -- Se seleccionan los roles por perfil
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%SEG_ROLES_X_PERFIL%') 
	END
	ELSE IF(@strDescTabla = '15') -- Se seleccionan los usuarios
	BEGIN
		INSERT INTO @VariableTabla SELECT ISNULL(des_tabla, '-'), ISNULL(cod_usuario,'-'), 
               ISNULL(cod_ip, '-'), ISNULL(cod_operacion, '-'), ISNULL(fecha_hora, '-'), 
               ISNULL(cod_tipo_garantia, '-'), ISNULL(cod_garantia, '-'), 
               ISNULL(cod_operacion_crediticia, '-'), ISNULL(des_campo_afectado,'-'), 
			   ISNULL(est_anterior_campo_afectado,'-'), ISNULL(est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			  des_tipo_garantia = CASE cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA
		WHERE cod_usuario LIKE ISNULL('%' + @strCodigoUsuario + '%', cod_usuario)
			AND fecha_hora BETWEEN ISNULL(@dFechaInicial, fecha_hora) AND ISNULL(@dFechaFinal, fecha_hora)
			AND cod_operacion = ISNULL(@nCodigoOperacion, cod_operacion)
			AND cod_ip = ISNULL(@strIP, cod_ip)
			AND (des_tabla LIKE '%SEG_USUARIO%') 
	END

	UPDATE @VariableTabla SET fecha_corte = CONVERT(datetime,(SELECT TOP 1 fecha_hora
	FROM @VariableTabla
	ORDER BY fecha_hora DESC), 131)

	IF(@strCriterioOrden = 'cod_usuario')
	BEGIN
		SELECT des_tabla, cod_usuario, cod_ip, cod_operacion, fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, des_campo_afectado, 
			   est_anterior_campo_afectado, est_actual_campo_afectado, fecha_corte, des_operacion, des_tipo_garantia
		FROM @VariableTabla
		ORDER BY cod_usuario
	END
	ELSE IF(@strCriterioOrden = 'cod_ip')
	BEGIN
		SELECT des_tabla, cod_usuario, cod_ip, cod_operacion, fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, des_campo_afectado, 
			   est_anterior_campo_afectado, est_actual_campo_afectado, fecha_corte, des_operacion, des_tipo_garantia
		FROM @VariableTabla
		ORDER BY cod_ip
	END
	ELSE IF(@strCriterioOrden = 'cod_operacion')
	BEGIN
		SELECT des_tabla, cod_usuario, cod_ip, cod_operacion, fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, des_campo_afectado, 
			   est_anterior_campo_afectado, est_actual_campo_afectado, fecha_corte, des_operacion, des_tipo_garantia
		FROM @VariableTabla
		ORDER BY cod_operacion
	END
	ELSE IF(@strCriterioOrden = 'fecha_hora')
	BEGIN
		SELECT des_tabla, cod_usuario, cod_ip, cod_operacion, fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, des_campo_afectado, 
			   est_anterior_campo_afectado, est_actual_campo_afectado, fecha_corte, des_operacion, des_tipo_garantia
		FROM @VariableTabla
		ORDER BY fecha_hora
	END
	ELSE 
	BEGIN
		SELECT des_tabla, cod_usuario, cod_ip, cod_operacion, fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, des_campo_afectado, 
			   est_anterior_campo_afectado, est_actual_campo_afectado, fecha_corte, des_operacion, des_tipo_garantia
		FROM @VariableTabla
		ORDER BY cod_usuario
	END
	
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

