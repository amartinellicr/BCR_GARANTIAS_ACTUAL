USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('dbo.pa_Rpt_Bitacora', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Bitacora;
GO


-- =============================================
-- Author:		Arnoldo Martinelli Marín, Lidersoft Internacional S.A.
-- Create date: 08/04/2008
-- Description:	Permite realizar la consulta de la bitácora, según los filtros dados y ordenados según el criterio solicitado
-- =============================================
--CONTROL DE CAMBIOS
-- =============================================
-- Author:		Leonardo Cortes Mora Lidersoft Internacional S.A.
-- Create modified: 07/10/2014
-- Description: Se cambia la forma de extracción de datos, se crea un indice a la tabla
-- =============================================

CREATE PROCEDURE [dbo].[pa_Rpt_Bitacora]
	-- Add the parameters for the stored procedure here
	@strCodigoUsuario nvarchar(30) = NULL, 
	@dFechaInicial datetime = NULL,
	@dFechaFinal datetime = NULL,
	@nCodigoOperacion int = NULL,
	@strIP nvarchar(20) = NULL,
    @strDescTabla nvarchar(50) = NULL,
	@strCriterioOrden nvarchar(20) = 'cod_usuario'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
		DECLARE @TablasConsulta TABLE(
										Nombre_Tabla VARCHAR(100),
										GrupoTabla VARCHAR(10))
											
	    -- 1: GARANTIAS FIDUCIARIAS
	    
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIA_FIDUCIARIA', '1')

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', '1')

		--2: GARANTIAS FIDUCIARIAS TARJETAS
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('TAR_GARANTIA_FIDUCIARIA', '2')

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('TAR_TARJETA', '2')

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA', '2')

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('TAR_GARANTIAS_X_PERFIL_X_TARJETA', '2')
			
		--3: GARANTIAS REALES
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIA_REAL', '3')
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIAS_REALES_X_OPERACION', '3')
		
		--4: GARANTIAS VALOR
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIA_VALOR', '4')
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIAS_VALOR_X_OPERACION', '4')
		
	    --5: GARANTIAS POR GIRO
				
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_GARANTIAS_X_GIRO', '5')
		
		--6: CAPACIDAD_PAGO
			
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_CAPACIDAD_PAGO', '6')
		
		--7: DEUDOR GARANTIAS FIDUCIARIAS
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_DEUDOR', '7')
		
		--8: DEUDOR GARANTIAS REALES
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_DEUDOR', '8')

		--9: DEUDOR GARANTIAS VALOR

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_DEUDOR', '9')

        --10: VALUACIONES FIADORES

		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_VALUACIONES_FIADOR', '10')
		
		--11: VALUACIONES REALES
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_VALUACIONES_REALES', '11')
		
		--12: PERITOS
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_PERITO', '12')
		
		--13: EMPRESAS
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('GAR_EMPRESA', '13')
		
		--14: ELEMENTOS CATÁLOGOS 
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('CAT_ELEMENTO', '14')
		
		--15: PERFILES
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('SEG_PERFIL', '15')
		
		--16: ROLES PERFIL
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('SEG_ROLES_X_PERFIL', '16')
		
		--17: USUARIOS
		
		INSERT INTO @TablasConsulta(Nombre_Tabla, GrupoTabla)
		VALUES ('SEG_USUARIO', '17')	
		
---------------------------------------------------------------------------------------------
	-- Se seleccionan todas las tablas
    IF(@strDescTabla = '-1')
	BEGIN

		--INSERT INTO @VariableTabla 
		  INSERT INTO @VariableTabla(
			des_tabla, cod_usuario, cod_ip, cod_operacion,fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, 
			des_campo_afectado, est_anterior_campo_afectado, est_actual_campo_afectado,fecha_corte ,des_operacion, des_tipo_garantia)
		
		SELECT COALESCE(GBI.des_tabla, '-'), COALESCE(GBI.cod_usuario,'-'), 
               COALESCE(GBI.cod_ip, '-'), COALESCE(GBI.cod_operacion, '-'), COALESCE(GBI.fecha_hora, '-'), 
               COALESCE(GBI.cod_tipo_garantia, '-'), COALESCE(GBI.cod_garantia, '-'), 
               COALESCE(GBI.cod_operacion_crediticia, '-'), COALESCE(GBI.des_campo_afectado,'-'), 
			   COALESCE(GBI.est_anterior_campo_afectado,'-'), COALESCE(GBI.est_actual_campo_afectado,'-'), 
               fecha_corte = GETDATE(), 
			   des_operacion = CASE GBI.cod_operacion WHEN 1 THEN 'INS'  
												  WHEN 2 THEN 'MOD'
												  WHEN 3 THEN 'BOR'
												  ELSE '-'
							   END,
			   des_tipo_garantia = CASE GBI.cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
														  WHEN 2 THEN 'REAL'
													      WHEN 3 THEN 'VALOR'
													      WHEN 4 THEN 'PERFIL'
													      ELSE '-'
							       END
		FROM dbo.GAR_BITACORA GBI
		WHERE cod_usuario LIKE COALESCE('%' + @strCodigoUsuario + '%', GBI.cod_usuario)
			AND GBI.fecha_hora BETWEEN COALESCE(@dFechaInicial, GBI.fecha_hora) AND COALESCE(@dFechaFinal, GBI.fecha_hora)
			AND GBI.cod_operacion = COALESCE(@nCodigoOperacion, GBI.cod_operacion)
			AND GBI.cod_ip = COALESCE(@strIP, GBI.cod_ip)
	END
	ELSE 
	BEGIN

		INSERT INTO @VariableTabla(
		des_tabla, cod_usuario, cod_ip, cod_operacion,fecha_hora, cod_tipo_garantia, cod_garantia, cod_operacion_crediticia, 
		des_campo_afectado, est_anterior_campo_afectado, est_actual_campo_afectado,fecha_corte,des_operacion, des_tipo_garantia)
		
		SELECT COALESCE(GBI.des_tabla, '-'), COALESCE(GBI.cod_usuario,'-'), 
				   COALESCE(GBI.cod_ip, '-'), COALESCE(GBI.cod_operacion, '-'), COALESCE(GBI.fecha_hora, '-'), 
				   COALESCE(GBI.cod_tipo_garantia, '-'), COALESCE(GBI.cod_garantia, '-'), 
				   COALESCE(GBI.cod_operacion_crediticia, '-'), COALESCE(GBI.des_campo_afectado,'-'), 
				   COALESCE(GBI.est_anterior_campo_afectado,'-'), COALESCE(GBI.est_actual_campo_afectado,'-'),               
				   fecha_corte = GETDATE(), 
				   des_operacion = CASE GBI.cod_operacion WHEN 1 THEN 'INS'  
													  WHEN 2 THEN 'MOD'
													  WHEN 3 THEN 'BOR'
													  ELSE '-'
								   END,
				   des_tipo_garantia = CASE GBI.cod_tipo_garantia WHEN 1 THEN 'FIDUCIARIA'  
															  WHEN 2 THEN 'REAL'
															  WHEN 3 THEN 'VALOR'
															  WHEN 4 THEN 'PERFIL'
															  ELSE '-'
									   END
			FROM dbo.GAR_BITACORA GBI
			WHERE GBI.fecha_hora BETWEEN @dFechaInicial AND @dFechaFinal
			AND EXISTS(
				SELECT TC.Nombre_Tabla
				FROM @TablasConsulta TC
				WHERE TC.Nombre_Tabla = GBI.des_tabla		
				AND TC.GrupoTabla = @strDescTabla
				)
			AND GBI.cod_usuario = COALESCE(@strCodigoUsuario, GBI.cod_usuario)
			
			AND GBI.cod_operacion = COALESCE(@nCodigoOperacion, GBI.cod_operacion)
			AND GBI.cod_ip = COALESCE(@strIP, GBI.cod_ip)	
			AND COALESCE(GBI.cod_tipo_garantia,-1) = CASE 
										WHEN @strDescTabla = '7' THEN 1
										WHEN @strDescTabla = '8' THEN 2
										WHEN @strDescTabla = '9' THEN 3												
										ELSE   COALESCE(GBI.cod_tipo_garantia,-1)
									END	
									
									
	END	
	
	DECLARE
		@vdtFechaCorte DATETIME
	
	SET @vdtFechaCorte = (SELECT TOP 1 fecha_hora
				    	FROM @VariableTabla
					    ORDER BY fecha_hora DESC)
	
	UPDATE @VariableTabla 
	SET fecha_corte = @vdtFechaCorte
	

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





