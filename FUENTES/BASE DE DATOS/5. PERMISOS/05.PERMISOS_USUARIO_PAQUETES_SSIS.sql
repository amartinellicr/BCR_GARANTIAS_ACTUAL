USE [GARANTIAS]
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'RAP_AccesoIntegracion' AND type = 'R')
CREATE ROLE [RAP_AccesoIntegracion] AUTHORIZATION [dbo]
GO


GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIA_FIDUCIARIA TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIA_REAL TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIA_VALOR TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_DEUDOR TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_OPERACION TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_VALUACIONES_REALES TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIAS_VALOR_X_OPERACION TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIAS_REALES_X_OPERACION TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_BSMPC TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_BSMCL TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRMOC TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRMGT TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRHCS TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRMCA TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRMRI TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_DAMHT TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_SICC_PRMSC TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_POLIZAS TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.GAR_POLIZAS_RELACIONADAS TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT, UPDATE ON dbo.TMP_POLIZAS TO RAP_AccesoIntegracion
GO

GRANT SELECT, INSERT  ON dbo.GAR_EJECUCION_PROCESO TO RAP_AccesoIntegracion
GO
GRANT SELECT, INSERT ON dbo.GAR_EJECUCION_PROCESO_DETALLE TO RAP_AccesoIntegracion
GO

GRANT EXECUTE ON dbo.pa_RegistroEjecucionProceso TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Eliminar_Datos_Estructuras_SICC TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Migrar_Garantias_Sicc TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Actualizar_Registros_Garantias_Sicc TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Cargar_Contratos_Vencidos_Sicc TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Obtener_Resultado_Ejecucion_Procesos_Replica TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Replicar_Valuaciones_Reales_Sicc TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Replicar_Datos_Garantias_Reales_Sicc TO RAP_AccesoIntegracion
GO
GRANT EXECUTE ON dbo.Procesar_Polizas_Migradas TO RAP_AccesoIntegracion
GO


