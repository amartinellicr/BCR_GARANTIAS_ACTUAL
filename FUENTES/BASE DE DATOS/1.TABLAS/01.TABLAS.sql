
CREATE TABLE dbo.BCR_OFICINAS
(
	COD_OFICINA           int  NOT NULL ,
	DES_OFICINA           varchar(100)  NOT NULL ,
	COD_OFICINA_ASIGNADA  int  NULL ,
	COD_INDICADOR         tinyint  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.CAT_CATALOGO
(
	cat_catalogo          int  IDENTITY (1,1) ,
	cat_descripcion       varchar(100)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.CAT_ELEMENTO
(
	cat_elemento          int  IDENTITY (1,1) ,
	cat_catalogo          int  NOT NULL ,
	cat_campo             varchar(5)  NOT NULL ,
	cat_descripcion       varchar(150)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.CAT_INDICES_ACTUALIZACION_AVALUO
(
	Fecha_Hora            datetime  NOT NULL 
	CONSTRAINT DF_CAT_INDICES_ACTUALIZACION_AVALUOS_Fecha_Hora
		 DEFAULT  CURRENT_TIMESTAMP ,
	Tipo_Cambio           decimal(18,2)  NOT NULL 
	CONSTRAINT  CAT_INDICES_ACTUALIZACION_AVALUO_Tipo_Cambio_CK_01
		CHECK  ( [Tipo_Cambio] > 0 ) ,
	Indice_Precios_Consumidor  decimal(18,2)  NOT NULL 
	CONSTRAINT  CAT_INDICES_ACTUALIZACION_AVALUO_Indice_Precios_Consumidor_CK_01
		CHECK  ( [Indice_Precios_Consumidor] > 0 ) 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� los �ndices que ser�n utilizados para el c�culo de los montos de las tasaciones actualizadas del terreno y no terreno.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Este campo permitir� almacenar la fecha y hora en que se produjo el registro de la informaci�n.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Fecha_Hora'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el tipo de cambio del d�a.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Tipo_Cambio'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el �ndice de precios al consumidor.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Indice_Precios_Consumidor'
GO



CREATE TABLE dbo.CAT_INSTRUMENTOS
(
	cod_instrumento       varchar(25)  NOT NULL ,
	des_instrumento       varchar(150)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.CAT_ISIN
(
	cod_isin              varchar(25)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_BITACORA
(
	des_tabla             varchar(50)  NOT NULL ,
	cod_usuario           varchar(30)  NOT NULL ,
	cod_ip                varchar(20)  NOT NULL ,
	cod_oficina           int  NULL ,
	cod_operacion         smallint  NOT NULL ,
	fecha_hora            datetime  NOT NULL ,
	cod_consulta          text  NULL ,
	cod_tipo_garantia     smallint  NULL ,
	cod_garantia          varchar(30)  NULL ,
	cod_operacion_crediticia  varchar(30)  NULL ,
	cod_consulta2         text  NULL ,
	des_campo_afectado    varchar(50)  NULL ,
	est_anterior_campo_afectado  varchar(100)  NULL ,
	est_actual_campo_afectado  varchar(100)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_CAPACIDAD_PAGO
(
	cedula_deudor         varchar(30)  NOT NULL ,
	fecha_capacidad_pago  datetime  NOT NULL ,
	cod_capacidad_pago    smallint  NULL ,
	sensibilidad_tipo_cambio  decimal(5,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_DEUDOR
(
	cedula_deudor         varchar(30)  NOT NULL ,
	nombre_deudor         varchar(50)  NULL ,
	cod_tipo_deudor       smallint  NULL ,
	cod_condicion_especial  smallint  NULL ,
	cod_tipo_asignacion   smallint  NULL ,
	cod_generador_divisas  smallint  NULL ,
	cod_vinculado_entidad  smallint  NULL ,
	cod_estado            smallint  NOT NULL 
	CONSTRAINT DF_GAR_DEUDOR_cod_estado
		 DEFAULT  1 ,
	cedula_deudor_sugef   varchar(30)  NULL ,
	ind_actualizo_cedulasugef  bit  NOT NULL 
	CONSTRAINT DF_GAR_DEUDOR_ind_actualizo_cedulasugef
		 DEFAULT  0 ,
	tipo_id_sugef         numeric(2)  NULL ,
	Identificacion_Sicc DECIMAL(12, 0) NULL
)
 ON "PRIMARY"
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenar� la identificaci�n del deudor registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_DEUDOR', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO


CREATE TABLE dbo.GAR_EJECUCION_PROCESO
(
	conEjecucionProceso   int  IDENTITY (1,1) ,
	cocProceso            varchar(20)  NOT NULL ,
	fecEjecucion          datetime  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_EJECUCION_PROCESO_DETALLE
(
	conEjecucionProceso   int  NOT NULL ,
	conEjecucionProcesoDetalle  smallint  NOT NULL ,
	desObservacion        varchar(4000)  NOT NULL ,
	fecIngreso            datetime  NOT NULL 
	CONSTRAINT DF_GAR_EJECUCION_PROCESO_DETALLE_fecIngreso
		 DEFAULT  CURRENT_TIMESTAMP ,
	indError              bit  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_EMPRESA
(
	cedula_empresa        varchar(30)  NOT NULL ,
	des_empresa           varchar(45)  NOT NULL ,
	des_direccion         varchar(250)  NOT NULL ,
	des_telefono          varchar(15)  NOT NULL ,
	des_email             varchar(50)  NOT NULL ,
	cedula_empresa_sugef  varchar(30)  NULL ,
	ind_actualizo_cedulasugef  bit  NOT NULL 
	CONSTRAINT DF_GAR_EMPRESA_FIDUCIARIA_ind_actualizo_cedulasugef
		 DEFAULT  0 ,
	tipo_id_sugef         numeric(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_GARANTIA_FIDUCIARIA
(
	cod_garantia_fiduciaria  bigint  IDENTITY (1,1) ,
	cod_tipo_garantia     smallint  NOT NULL ,
	cod_clase_garantia    smallint  NOT NULL ,
	cedula_fiador         varchar(25)  NOT NULL ,
	nombre_fiador         varchar(50)  NULL ,
	cod_tipo_fiador       smallint  NULL ,
	ruc_cedula_fiador     varchar(30)  NULL ,
	cedula_fiador_sugef   varchar(30)  NULL ,
	ind_actualizo_cedulasugef  bit  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIA_FIDUCIARIA_ind_actualizo_cedulasugef
		 DEFAULT  0 ,
	tipo_id_sugef         numeric(2)  NULL ,
	Identificacion_Sicc	DECIMAL(12, 0) NULL,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL	
)
 ON "PRIMARY"
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenar� la identificaci�n del fiador registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_FIDUCIARIA', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Replica'
GO


CREATE TABLE dbo.GAR_GARANTIA_REAL
(
	cod_garantia_real     bigint  IDENTITY (1,1) ,
	cod_tipo_garantia     smallint  NOT NULL ,
	cod_clase_garantia    smallint  NOT NULL ,
	cod_tipo_garantia_real  smallint  NOT NULL ,
	cod_partido           smallint  NULL ,
	numero_finca          varchar(25)  NULL ,
	cod_grado             varchar(2)  NULL ,
	cedula_hipotecaria    varchar(2)  NULL ,
	cod_clase_bien        varchar(3)  NULL ,
	num_placa_bien        varchar(25)  NULL ,
	cod_tipo_bien         smallint  NULL,
	Identificacion_Sicc DECIMAL(12, 0) NULL,
	Identificacion_Alfanumerica_Sicc VARCHAR(25) NULL,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL,
	Indicador_Vivienda_Habitada_Deudor BIT NOT NULL CONSTRAINT [DF_GAR_GARANTIA_REAL_Indicador_Vivienda_Habitada_Deudor]  DEFAULT (0)	 
	 
)
 ON "PRIMARY"
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenar� la identificaci�n alfanum�rica del bien registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_REAL', @level2type=N'COLUMN',@level2name=N'Identificacion_Alfanumerica_Sicc'
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenar� la identificaci�n del bien registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_REAL', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Indica si la vivienda es habitada por el deudor.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Indicador_Vivienda_Habitada_Deudor'
GO


CREATE TABLE dbo.GAR_GARANTIA_VALOR
(
	cod_garantia_valor    bigint  IDENTITY (1,1) ,
	cod_tipo_garantia     smallint  NOT NULL ,
	cod_clase_garantia    smallint  NOT NULL ,
	numero_seguridad      varchar(25)  NOT NULL ,
	fecha_constitucion    datetime  NULL ,
	fecha_vencimiento_instrumento  datetime  NULL ,
	cod_clasificacion_instrumento  smallint  NULL ,
	des_instrumento       varchar(25)  NULL ,
	des_serie_instrumento  varchar(20)  NULL ,
	cod_tipo_emisor       smallint  NULL ,
	cedula_emisor         varchar(25)  NULL ,
	premio                decimal(18,2)  NULL ,
	cod_isin              varchar(25)  NULL ,
	valor_facial          decimal(18,2)  NULL ,
	cod_moneda_valor_facial  smallint  NULL ,
	valor_mercado         decimal(18,2)  NULL ,
	cod_moneda_valor_mercado  smallint  NULL ,
	cod_tenencia          smallint  NOT NULL ,
	fecha_prescripcion    datetime  NOT NULL ,
	Identificacion_Sicc DECIMAL(12, 0) NULL,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL	 
)
 ON "PRIMARY"
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenar� la identificaci�n de la seguridad registrada en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_VALOR', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Replica'
GO


CREATE TABLE dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION
(
	cod_operacion         bigint  NOT NULL ,
	cod_garantia_fiduciaria  bigint  NOT NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	cod_estado            smallint  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION_cod_estado
		 DEFAULT  1,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION_PorcentajeAceptacion
		 DEFAULT  -1,
	Indicador_Porcentaje_Responsabilidad_Maximo bit  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION_Indicador_Porcentaje_Responsabilidad_Maximo
		 DEFAULT  0	  
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador referente a si la garant�a posee asignado el 100% del porcentaje de responsabilidad. Donde:

0: El porcentaje de responsabilidad no es el           100%.
1: El porcentaje de responsabilidad es el               100%.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Indicador_Porcentaje_Responsabilidad_Maximo'
GO



CREATE TABLE dbo.GAR_GARANTIAS_REALES_X_OPERACION
(
	cod_operacion         bigint  NOT NULL ,
	cod_garantia_real     bigint  NOT NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	cod_inscripcion       smallint  NULL ,
	fecha_presentacion    datetime  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_operacion_especial  smallint  NULL ,
	fecha_constitucion    datetime  NULL ,
	fecha_vencimiento     datetime  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	cod_liquidez          smallint  NULL ,
	cod_tenencia          smallint  NULL ,
	cod_moneda            smallint  NULL ,
	fecha_prescripcion    datetime  NULL ,
	cod_estado            smallint  NOT NULL ,
	Fecha_Valuacion_SICC  datetime  NULL 
	CONSTRAINT DF_GAR_GARANTIAS_REALES_X_OPERACION_cod_estado
		 DEFAULT  1,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_REALES_X_OPERACION_PorcentajeAceptacion
		 DEFAULT  -1,
	Indicador_Porcentaje_Responsabilidad_Maximo bit  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_REALES_X_OPERACION_Indicador_Porcentaje_Responsabilidad_Maximo
		 DEFAULT  0	  
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Este campo alamacenar� la fecha del aval�o registrada en el SICC.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Valuacion_SICC'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_REALES_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador referente a si la garant�a posee asignado el 100% del porcentaje de responsabilidad. Donde:

0: El porcentaje de responsabilidad no es el           100%.

1: El porcentaje de responsabilidad es el               100%.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_REALES_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Indicador_Porcentaje_Responsabilidad_Maximo'
GO


CREATE TABLE dbo.GAR_GARANTIAS_VALOR_X_OPERACION
(
	cod_operacion         bigint  NOT NULL ,
	cod_garantia_valor    bigint  NOT NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	cod_inscripcion       smallint  NULL ,
	fecha_presentacion_registro  datetime  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_grado_prioridades  smallint  NULL ,
	monto_prioridades     decimal(18,2)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	cod_estado            smallint  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_VALOR_X_OPERACION_cod_estado
		 DEFAULT  1,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_VALOR_X_OPERACION_PorcentajeAceptacion
		 DEFAULT  -1,
	Indicador_Porcentaje_Responsabilidad_Maximo bit  NOT NULL 
	CONSTRAINT DF_GAR_GARANTIAS_VALOR_X_OPERACION_Indicador_Porcentaje_Responsabilidad_Maximo
		 DEFAULT  0	  
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_VALOR_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador referente a si la garant�a posee asignado el 100% del porcentaje de responsabilidad. Donde:

0: El porcentaje de responsabilidad no es el           100%.

1: El porcentaje de responsabilidad es el               100%.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GARANTIAS_VALOR_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Indicador_Porcentaje_Responsabilidad_Maximo'
GO


CREATE TABLE dbo.GAR_GARANTIAS_X_GIRO
(
	cod_operacion_giro    bigint  NOT NULL ,
	cod_operacion         bigint  NOT NULL ,
	cod_garantia          bigint  NOT NULL ,
	cod_tipo_garantia     smallint  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_GARANTIAS_x_PERFIL_X_TARJETA
(
	cod_tarjeta           int  NOT NULL ,
	observaciones         varchar(250)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_GIROS_GARANTIAS_FIDUCIARIAS
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(16)  NULL ,
	cedula_fiador         varchar(25)  NULL ,
	cod_tipo_fiador       smallint  NULL ,
	fecha_valuacion       varchar(10)  NULL ,
	ingreso_neto          decimal(18,2)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	nombre_fiador         varchar(50)  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	nombre_deudor         varchar(50)  NULL ,
	oficina_deudor        smallint  NULL ,
	cod_estado_tarjeta    varchar(1)  NULL  ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_FIDUCIARIAS_PorcentajeAceptacion
		 DEFAULT  -1
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GIROS_GARANTIAS_FIDUCIARIAS',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.GAR_GIROS_GARANTIAS_REALES
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(7)  NULL ,
	cod_tipo_bien         smallint  NULL ,
	cod_bien              varchar(25)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	fecha_presentacion    varchar(10)  NULL ,
	cod_inscripcion       smallint  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	fecha_constitucion    varchar(10)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	fecha_vencimiento     varchar(10)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	fecha_valuacion       varchar(10)  NULL ,
	cedula_empresa        varchar(30)  NULL ,
	cod_tipo_empresa      smallint  NULL ,
	cedula_perito         varchar(30)  NULL ,
	cod_tipo_perito       smallint  NULL ,
	monto_ultima_tasacion_terreno  decimal(18,2)  NULL ,
	monto_ultima_tasacion_no_terreno  decimal(18,2)  NULL ,
	monto_tasacion_actualizada_terreno  decimal(18,2)  NULL ,
	monto_tasacion_actualizada_no_terreno  decimal(18,2)  NULL ,
	fecha_ultimo_seguimiento  varchar(10)  NULL ,
	monto_total_avaluo    decimal(18,2)  NULL ,
	fecha_construccion    varchar(10)  NULL ,
	cod_grado             varchar(2)  NULL ,
	cedula_hipotecaria    varchar(2)  NULL ,
	cod_clase_garantia    smallint  NULL ,
	cod_operacion         bigint  NULL ,
	cod_garantia_real     bigint  NULL ,
	cod_tipo_garantia_real  tinyint  NULL ,
	numero_finca          varchar(25)  NULL ,
	num_placa_bien        varchar(25)  NULL ,
	cod_clase_bien        varchar(3)  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	cod_estado            smallint  NULL ,
	cod_llave             uniqueidentifier  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_REALES_codllave
		 DEFAULT  newid(),
	Porcentaje_Aceptacion_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_Terreno_Calculado  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno_Calculado  decimal(5,2) NULL  ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_REALES_PorcentajeAceptacion
		 DEFAULT  -1
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'GAR_GIROS_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'GAR_GIROS_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'GAR_GIROS_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'GAR_GIROS_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GIROS_GARANTIAS_REALES',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.GAR_GIROS_GARANTIAS_VALOR
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(7)  NULL ,
	numero_seguridad      varchar(25)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	fecha_presentacion    varchar(10)  NULL ,
	cod_inscripcion       smallint  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	fecha_constitucion    varchar(10)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_grado_prioridades  smallint  NULL ,
	monto_prioridades     decimal(18,2)  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	fecha_vencimiento     varchar(10)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	cod_clasificacion_instrumento  smallint  NULL ,
	des_instrumento       varchar(25)  NULL ,
	des_serie_instrumento  varchar(20)  NULL ,
	cod_tipo_emisor       smallint  NULL ,
	cedula_emisor         varchar(30)  NULL ,
	premio                decimal(18,2)  NULL ,
	cod_isin              varchar(25)  NULL ,
	valor_facial          decimal(18,2)  NULL ,
	cod_moneda_valor_facial  smallint  NULL ,
	valor_mercado         decimal(18,2)  NULL ,
	cod_moneda_valor_mercado  smallint  NULL ,
	monto_responsabilidad  decimal(18,2)  NULL ,
	cod_moneda_garantia   smallint  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	nombre_deudor         varchar(50)  NULL ,
	oficina_deudor        smallint  NULL ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_VALOR_PorcentajeAceptacion
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_GIROS_GARANTIAS_VALOR',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.GAR_MIG_DEUDORES
(
	cedula_deudor         varchar(30)  NULL ,
	DeudorCodeudor_cod_iddeudor  varchar(30)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_OPERACION
(
	cod_operacion         bigint  IDENTITY (1,1) ,
	cod_contabilidad      tinyint  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	cod_moneda            tinyint  NOT NULL ,
	cod_producto          tinyint  NULL ,
	num_operacion         decimal(7)  NULL ,
	num_contrato          decimal(7)  NULL ,
	fecha_constitucion    datetime  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	fecha_vencimiento     datetime  NULL ,
	monto_original        decimal(18,2)  NULL ,
	saldo_actual          decimal(18,2)  NULL ,
	cod_estado            smallint  NOT NULL 
	CONSTRAINT DF_GAR_OPERACION_cod_estado
		 DEFAULT  1 ,
	cod_oficon            smallint  NULL,
	Cuenta_Contable		  smallint  NOT NULL 
	CONSTRAINT  DF_GAR_OPERACION_Cuenta_Contable 
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
'MS_Description', 'Almacenar� el c�digo de cuenta mayor registrado en el SICC. En el caso de los contratos se asignar� el valor -1 por defecto.',
'user', 'dbo',
'table', 'GAR_OPERACION',
'column', 'Cuenta_Contable'
GO


CREATE TABLE dbo.GAR_PERITO
(
	cedula_perito         varchar(30)  NOT NULL ,
	des_perito            varchar(45)  NOT NULL ,
	cod_tipo_persona      tinyint  NOT NULL ,
	des_direccion         varchar(250)  NOT NULL ,
	des_telefono          varchar(15)  NOT NULL ,
	des_email             varchar(50)  NOT NULL ,
	cedula_perito_sugef   varchar(30)  NULL ,
	ind_actualizo_cedulasugef  bit  NOT NULL 
	CONSTRAINT DF_GAR_PERITO_ind_actualizo_cedulasugef
		 DEFAULT  0 ,
	tipo_id_sugef         numeric(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_PROCESO
(
	cocProceso            varchar(20)  NOT NULL ,
	desProceso            varchar(60)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_BSMCL
(
	bsmcl_estado          varchar(1)  NULL ,
	bsmcl_sno_clien       varchar(45)  NULL ,
	bsmcl_sco_ident       decimal(12)  NULL ,
	bsmcl_sco_sexo        tinyint  NULL ,
	bsmcl_scoacteco       smallint  NULL ,
	bsmcl_scoautbpe       tinyint  NULL ,
	bsmcl_scoestciv       tinyint  NULL ,
	bsmcl_scopercli       int  NULL ,
	bsmcl_scosececo       tinyint  NULL ,
	bsmcl_scotipcli       tinyint  NULL ,
	bsmcl_scotipide       tinyint  NULL ,
	bsmcl_scotipper       tinyint  NULL ,
	bsmcl_sfe_nacim       int  NULL ,
	bsmcl_sseclict        tinyint  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_BSMPC
(
	bsmpc_estado          varchar(1)  NULL ,
	bsmpc_acoidereg       decimal(12)  NULL ,
	bsmpc_afe_trans       int  NULL ,
	bsmpc_afereltra       int  NULL ,
	bsmpc_afe1ind10       int  NULL ,
	bsmpc_aho_trans       int  NULL ,
	bsmpc_aseindi01       tinyint  NULL ,
	bsmpc_aseindi02       tinyint  NULL ,
	bsmpc_aseindi03       tinyint  NULL ,
	bsmpc_aseindi04       tinyint  NULL ,
	bsmpc_aseindi05       tinyint  NULL ,
	bsmpc_aseindi06       tinyint  NULL ,
	bsmpc_aseindi07       tinyint  NULL ,
	bsmpc_aseindi08       tinyint  NULL ,
	bsmpc_aseindi09       tinyint  NULL ,
	bsmpc_aseindi10       tinyint  NULL ,
	bsmpc_dco_ofici       smallint  NULL ,
	bsmpc_sco_ident       decimal(12)  NULL ,
	bsmpc_tmo_ponde       decimal(13,2)  NULL ,
	bsmpc_tmo1ind01       decimal(13,2)  NULL ,
	bsmpc_tmo1ind02       decimal(13,2)  NULL ,
	bsmpc_tmo1ind03       decimal(13,2)  NULL ,
	bsmpc_tmo1ind04       decimal(13,2)  NULL ,
	bsmpc_tmo1ind06       decimal(13,2)  NULL ,
	bsmpc_tmo1ind08       decimal(13,2)  NULL ,
	bsmpc_tmo1ind09       decimal(13,2)  NULL ,
	bsmpc_tmo2ind08       decimal(13,2)  NULL ,
	bsmpc_tmo2ind09       decimal(13,2)  NULL ,
	bsmpc_tmo3ind08       decimal(13,2)  NULL ,
	bsmpc_tmo3ind09       decimal(13,2)  NULL ,
	bsmpc_tmo4ind08       decimal(13,2)  NULL ,
	bsmpc_tmo4ind09       decimal(13,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRHCS
(
	prhcs_estado          varchar(1)  NULL ,
	prhcs_pco_calif       varchar(3)  NULL ,
	prhcs_pcoidesug       varchar(15)  NULL ,
	prhcs_pco_clien       decimal(12)  NULL ,
	prhcs_pcotipcal       tinyint  NULL ,
	prhcs_pcousureg       decimal(12)  NULL ,
	prhcs_pfe_regis       int  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRMCA
(
	prmca_estado          varchar(1)  NULL ,
	prmca_pco_aprob       smallint  NULL ,
	prmca_pco_apro2       smallint  NULL ,
	prmca_pco_conta       tinyint  NULL ,
	prmca_pco_ident       decimal(12)  NULL ,
	prmca_pco_moned       tinyint  NULL ,
	prmca_pco_num01       smallint  NULL ,
	prmca_pco_num02       smallint  NULL ,
	prmca_pco_num03       smallint  NULL ,
	prmca_pco_ofici       smallint  NULL ,
	prmca_pco_produc      tinyint  NULL ,
	prmca_pco_tipcre      tinyint  NULL ,
	prmca_pcoclacon       smallint  NULL ,
	prmca_pcoestcre       tinyint  NULL ,
	prmca_pcointflu       tinyint  NULL ,
	prmca_pcooficta       smallint  NULL ,
	prmca_pcotipcon       tinyint  NULL ,
	prmca_pfe_const       int  NULL ,
	prmca_pfe_defin       int  NULL ,
	prmca_pfe_regis       int  NULL ,
	prmca_pmo_maxim       decimal(14,2)  NULL ,
	prmca_pmo_mon01       decimal(14,2)  NULL ,
	prmca_pmo_mon02       decimal(14,2)  NULL ,
	prmca_pmo_mon03       decimal(14,2)  NULL ,
	prmca_pmo_reserv      decimal(14,2)  NULL ,
	prmca_pmo_utiliz      decimal(14,2)  NULL ,
	prmca_pnu_contr       int  NULL ,
	prmca_pnuctacte       int  NULL ,
	prmca_pnudigver       tinyint  NULL ,
	prmca_psa_conta       decimal(14,2)  NULL ,
	prmca_psa_discon      decimal(14,2)  NULL ,
	prmca_pse_contab      tinyint  NULL ,
	prmca_pse_val01       tinyint  NULL ,
	prmca_pse_val02       tinyint  NULL ,
	prmca_pse_val03       tinyint  NULL ,
	prmca_ptataspis       decimal(6,3)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRMGT
(
	prmgt_estado          varchar(1)  NULL ,
	prmgt_pco_adic1       smallint  NULL ,
	prmgt_pco_adic2       smallint  NULL ,
	prmgt_pco_conta       tinyint  NULL ,
	prmgt_pco_grado       tinyint  NULL ,
	prmgt_pco_moned       tinyint  NULL ,
	prmgt_pco_mongar      tinyint  NULL ,
	prmgt_pco_ofici       smallint  NULL ,
	prmgt_pco_produ       tinyint  NULL ,
	prmgt_pcoclagar       tinyint  NULL ,
	prmgt_pcoliqgar       tinyint  NULL ,
	prmgt_pcotengar       tinyint  NULL ,
	prmgt_pfe_adic1       int  NULL ,
	prmgt_pfe_prescr      int  NULL ,
	prmgt_pfeavaing       int  NULL ,
	prmgt_pfeultins       int  NULL ,
	prmgt_pmoavaing       decimal(14,2)  NULL ,
	prmgt_pmoresgar       decimal(14,2)  NULL ,
	prmgt_pnu_asien       int  NULL ,
	prmgt_pnu_folio       smallint  NULL ,
	prmgt_pnu_oper        int  NULL ,
	prmgt_pnu_part        tinyint  NULL ,
	prmgt_pnu_tomo        int  NULL ,
	prmgt_pnuidegar       decimal(12)  NULL ,
	prmgt_pse_adic1       tinyint  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRMOC
(
	prmoc_estado          varchar(1)  NULL ,
	prmoc_pcocaladi       varchar(3)  NULL ,
	prmoc_pcocalope       varchar(3)  NULL ,
	prmoc_pno_clien       varchar(45)  NULL ,
	prmoc_pnu_atras       varchar(36)  NULL ,
	prmoc_dco_ofici       smallint  NULL ,
	prmoc_pco_aprob       smallint  NULL ,
	prmoc_pco_conta       tinyint  NULL ,
	prmoc_pco_desti       tinyint  NULL ,
	prmoc_pco_divis       tinyint  NULL ,
	prmoc_pco_moned       tinyint  NULL ,
	prmoc_pco_ofici       smallint  NULL ,
	prmoc_pco_oficon      smallint  NULL ,
	prmoc_pco_plazo       tinyint  NULL ,
	prmoc_pco_poliz       tinyint  NULL ,
	prmoc_pco_produ       tinyint  NULL ,
	prmoc_pcoaltrie       tinyint  NULL ,
	prmoc_pcocalint       tinyint  NULL ,
	prmoc_pcoctamay       smallint  NULL ,
	prmoc_pcoestlog       tinyint  NULL ,
	prmoc_pcoestpres      tinyint  NULL ,
	prmoc_pcofreflu       smallint  NULL ,
	prmoc_pcogracon       tinyint  NULL ,
	prmoc_pcoinsagr       tinyint  NULL ,
	prmoc_pcointflu       tinyint  NULL ,
	prmoc_pcolincre       smallint  NULL ,
	prmoc_pcomonint       smallint  NULL ,
	prmoc_pditrapro       smallint  NULL ,
	prmoc_pfe_aprob       int  NULL ,
	prmoc_pfe_const       int  NULL ,
	prmoc_pfe_conta       int  NULL ,
	prmoc_pfe_defin       int  NULL ,
	prmoc_pfeconant       int  NULL ,
	prmoc_pfegentab       int  NULL ,
	prmoc_pfeintpag       int  NULL ,
	prmoc_pfelimide       int  NULL ,
	prmoc_pfeproflu       int  NULL ,
	prmoc_pfepropag       int  NULL ,
	prmoc_pferelint       int  NULL ,
	prmoc_pfeultact       int  NULL ,
	prmoc_pfeultcal       int  NULL ,
	prmoc_pfeultpag       int  NULL ,
	prmoc_pfevenabo       int  NULL ,
	prmoc_pfevenint       int  NULL ,
	prmoc_pfevigtas       int  NULL ,
	prmoc_pmo_girad       decimal(14,2)  NULL ,
	prmoc_pmo_origi       decimal(14,2)  NULL ,
	prmoc_pmocrepen       decimal(14,2)  NULL ,
	prmoc_pmodebpen       decimal(14,2)  NULL ,
	prmoc_pmointdia       decimal(14,2)  NULL ,
	prmoc_pmointgan       decimal(14,2)  NULL ,
	prmoc_pnu_contr       int  NULL ,
	prmoc_pnu_direc       tinyint  NULL ,
	prmoc_pnu_oper        int  NULL ,
	prmoc_pnu_solic       int  NULL ,
	prmoc_psa_actual      decimal(14,2)  NULL ,
	prmoc_psa_ayer        decimal(14,2)  NULL ,
	prmoc_psa_ideal       decimal(14,2)  NULL ,
	prmoc_psaactmea       decimal(14,2)  NULL ,
	prmoc_pse_base        tinyint  NULL ,
	prmoc_pse_cei         tinyint  NULL ,
	prmoc_pse_cerrar      tinyint  NULL ,
	prmoc_pse_emple       tinyint  NULL ,
	prmoc_pse_interv      tinyint  NULL ,
	prmoc_pse_proces      tinyint  NULL ,
	prmoc_pse_prorr       tinyint  NULL ,
	prmoc_pse_scacs       tinyint  NULL ,
	prmoc_psearrpag       tinyint  NULL ,
	prmoc_psecobaut       tinyint  NULL ,
	prmoc_psecomadm       tinyint  NULL ,
	prmoc_pseintade       tinyint  NULL ,
	prmoc_psepagpen       tinyint  NULL ,
	prmoc_pseprocj        tinyint  NULL ,
	prmoc_pserectab       tinyint  NULL ,
	prmoc_psesolarr       tinyint  NULL ,
	prmoc_pta_inter       decimal(6,3)  NULL ,
	prmoc_pta_plus        decimal(6,3)  NULL ,
	prmoc_ptacomadm       decimal(6,3)  NULL ,
	prmoc_pvacomadm       smallint  NULL ,
	prmoc_sco_ident       decimal(12)  NULL ,
	prmoc_scoanalis       decimal(12)  NULL ,
	prmoc_scoejecue       decimal(12)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRMRI
(
	my_aa                 char(12)  NOT NULL ,
	prmri_estado          char(1)  NULL ,
	prmri_pco_cod01       char(7)  NULL ,
	prmri_pno_comen       char(45)  NULL ,
	prmri_pnuide_alf      char(12)  NULL ,
	prmri_pco_conta       tinyint  NULL ,
	prmri_pco_moned       tinyint  NULL ,
	prmri_pco_ofici       smallint  NULL ,
	prmri_pco_produ       smallint  NULL ,
	prmri_pcoclagar       tinyint  NULL ,
	prmri_pcoestins       tinyint  NULL ,
	prmri_pcoofireg       smallint  NULL ,
	prmri_pcousureg       numeric(12)  NULL ,
	prmri_pfe_regis       int  NULL ,
	prmri_pferegins       int  NULL ,
	prmri_pnu_asien       int  NULL ,
	prmri_pnu_consec      int  NULL ,
	prmri_pnu_opera       int  NULL ,
	prmri_pnu_part        tinyint  NULL ,
	prmri_pnu_tomo        int  NULL ,
	prmri_pnuidegar       numeric(12)  NULL ,
	prmri_pnusecuen       smallint  NULL ,
	prmri_pnusubsec       smallint  NULL ,
	prmri_sco_ident       numeric(12)  NULL ,
	prmri_scoideabo       numeric(12)  NULL ,
	prmri_scoidedue       numeric(12)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_SICC_PRMSC
(
	prmsc_estado          char(1)  NULL ,
	prmsc_ppasercon       char(32)  NULL ,
	prmsc_pco_conta       tinyint  NULL ,
	prmsc_pco_ident       decimal(12)  NULL ,
	prmsc_pco_moned       tinyint  NULL ,
	prmsc_pco_msg1        smallint  NULL ,
	prmsc_pco_msg2        smallint  NULL ,
	prmsc_pco_ofici       smallint  NULL ,
	prmsc_pco_produ       tinyint  NULL ,
	prmsc_pco_usuar       decimal(12)  NULL ,
	prmsc_pcoestrel       tinyint  NULL ,
	prmsc_pcosercon       smallint  NULL ,
	prmsc_pfe_inici       int  NULL ,
	prmsc_pfe_msg1        int  NULL ,
	prmsc_pfe_msg2        int  NULL ,
	prmsc_pfe_regis       int  NULL ,
	prmsc_pfe_venci       int  NULL ,
	prmsc_pnu_oper        int  NULL ,
	prmsc_pnudocref       int  NULL ,
	prmsc_psesercon       tinyint  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.GAR_VALUACIONES_FIADOR
(
	cod_garantia_fiduciaria  bigint  NOT NULL ,
	fecha_valuacion       datetime  NOT NULL ,
	ingreso_neto          money  NOT NULL ,
	cod_tiene_capacidad_pago  smallint  NULL,
	Usuario_Modifico VARCHAR(30) NULL,
	Usuario_Inserto VARCHAR(30) COLLATE DATABASE_DEFAULT DEFAULT NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL	  
)
 ON "PRIMARY"
GO
EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la inserci�n del registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Usuario_Inserto'
GO




CREATE TABLE dbo.GAR_VALUACIONES_REALES
(
	cod_garantia_real     bigint  NOT NULL ,
	fecha_valuacion       datetime  NOT NULL ,
	cedula_empresa        varchar(30)  NULL ,
	cedula_perito         varchar(30)  NULL ,
	monto_ultima_tasacion_terreno  money  NULL ,
	monto_ultima_tasacion_no_terreno  money  NULL ,
	monto_tasacion_actualizada_terreno  money  NULL ,
	monto_tasacion_actualizada_no_terreno  money  NULL ,
	fecha_ultimo_seguimiento  datetime  NULL ,
	monto_total_avaluo    money  NOT NULL ,
	cod_recomendacion_perito  smallint  NULL ,
	cod_inspeccion_menor_tres_meses  smallint  NULL ,
	fecha_construccion    datetime  NULL ,
	Indicador_Tipo_Registro  tinyint  NOT NULL 
	CONSTRAINT DF_GAR_VALUACIONES_REALES_Indicador_Tipo_Registro
		 DEFAULT  0 ,
	Indicador_Actualizado_Calculo  bit  NOT NULL 
	CONSTRAINT DF_GAR_VALUACIONES_REALES_Indicador_Actualizado_Calculo
		 DEFAULT  0 ,
	Fecha_Semestre_Calculado  datetime  NULL,
	Usuario_Modifico VARCHAR(30) NULL,
	Fecha_Modifico DATETIME NULL,
	Fecha_Inserto DATETIME NULL,
	Fecha_Replica DATETIME NULL,
	Porcentaje_Aceptacion_Terreno  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_GAR_VALUACIONES_REALES_PorcentajeAceptacionTerreno
		 DEFAULT  -1,
	Porcentaje_Aceptacion_No_Terreno  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_GAR_VALUACIONES_REALES_PorcentajeAceptacionNoTerreno
		 DEFAULT  -1,
	Porcentaje_Aceptacion_Terreno_Calculado  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_GAR_VALUACIONES_REALES_PorcentajeAceptacionTerrenoCalculado
		 DEFAULT  -1,
	Porcentaje_Aceptacion_No_Terreno_Calculado  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_GAR_VALUACIONES_REALES_PorcentajeAceptacionNoTerrenoCalculado
		 DEFAULT  -1  
)
 ON "PRIMARY"
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica el tipo de fecha seg�n la siguiente clasificaci�n:
0: El registro es parte del hist�rico. Este es el valor por defecto del registro.
1: El registro corresponde al aval�o m�s reciente.
2: El registro corresponde al pen�ltimo aval�o.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Indicador_Tipo_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el monto de la tasaci�n actualizada del no terreno fue actualizado por el proceso del c�lculo. 
Tiene sentido si el valor del campo "Indicador_Tipo_Registro" tiene el valor 1 (uno). Los posibles valores son:
0: No fue actualizado. Este es el v' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Indicador_Actualizado_Calculo'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo alamacenar� la fecha del semestre calculado.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Semestre_Calculado'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'GAR_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'GAR_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'GAR_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'GAR_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno_Calculado'
GO



CREATE TABLE dbo.RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE
(
	fecha_corte           varchar(10)  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	des_oficina           varchar(100)  NOT NULL ,
	total_contratos       int  NULL ,
	total_contratos_completos  int  NULL ,
	total_contratos_pendientes  int  NULL ,
	porcentaje_total_contratos_completos  decimal(5,2)  NULL ,
	porcentaje_total_contratos_pendientes  decimal(5,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_AVANCE_OPERACION_X_OFICINA_CLIENTE
(
	fecha_corte           varchar(10)  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	des_oficina           varchar(100)  NOT NULL ,
	total_operaciones     int  NULL ,
	total_operaciones_completas  int  NULL ,
	total_operaciones_pendientes  int  NULL ,
	porcentaje_total_operaciones_completas  decimal(5,2)  NULL ,
	porcentaje_total_operaciones_pendientes  decimal(5,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_AVANCE_X_OFICINA_CLIENTE
(
	fecha_corte           varchar(10)  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	des_oficina           varchar(100)  NOT NULL ,
	total_garantias       int  NULL ,
	total_garantias_completas  int  NULL ,
	total_garantias_pendientes  int  NULL ,
	porcentaje_total_garantias_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_pendientes  decimal(5,2)  NULL ,
	total_garantias_fiduciarias  int  NULL ,
	total_garantias_fiduciarias_completas  int  NULL ,
	total_garantias_fiduciarias_pendientes  int  NULL ,
	porcentaje_total_garantias_fiduciarias_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_fiduciarias_pendientes  decimal(5,2)  NULL ,
	total_garantias_reales  int  NULL ,
	total_garantias_reales_completas  int  NULL ,
	total_garantias_reales_pendientes  int  NULL ,
	porcentaje_total_garantias_reales_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_reales_pendientes  decimal(5,2)  NULL ,
	total_garantias_valor  int  NULL ,
	total_garantias_valor_completas  int  NULL ,
	total_garantias_valor_pendientes  int  NULL ,
	porcentaje_total_garantias_valor_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_valor_pendientes  decimal(5,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
(
	fecha_corte           varchar(10)  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	des_oficina           varchar(100)  NOT NULL ,
	total_garantias       int  NULL ,
	total_garantias_completas  int  NULL ,
	total_garantias_pendientes  int  NULL ,
	porcentaje_total_garantias_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_pendientes  decimal(5,2)  NULL ,
	total_garantias_fiduciarias  int  NULL ,
	total_garantias_fiduciarias_completas  int  NULL ,
	total_garantias_fiduciarias_pendientes  int  NULL ,
	porcentaje_total_garantias_fiduciarias_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_fiduciarias_pendientes  decimal(5,2)  NULL ,
	total_garantias_reales  int  NULL ,
	total_garantias_reales_completas  int  NULL ,
	total_garantias_reales_pendientes  int  NULL ,
	porcentaje_total_garantias_reales_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_reales_pendientes  decimal(5,2)  NULL ,
	total_garantias_valor  int  NULL ,
	total_garantias_valor_completas  int  NULL ,
	total_garantias_valor_pendientes  int  NULL ,
	porcentaje_total_garantias_valor_completas  decimal(5,2)  NULL ,
	porcentaje_total_garantias_valor_pendientes  decimal(5,2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_CONTRATOS_DETALLE_X_GARANTIA
(
	cod_oficina_cliente   smallint  NULL ,
	des_oficina_cliente   varchar(100)  NULL ,
	oficina               varchar(100)  NULL ,
	contrato              varchar(100)  NULL ,
	tipo_garantia         varchar(50)  NULL ,
	garantia              varchar(150)  NULL ,
	pendiente             varchar(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_DETALLE_X_CONTRATO
(
	cod_oficina_cliente   smallint  NULL ,
	des_oficina_cliente   varchar(100)  NULL ,
	oficina               varchar(100)  NULL ,
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	num_operacion         decimal(7)  NULL ,
	num_contrato          decimal(7)  NULL ,
	prmca_pfe_const       int  NULL ,
	pendiente             varchar(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_DETALLE_X_GARANTIA
(
	cod_oficina_cliente   smallint  NULL ,
	des_oficina_cliente   varchar(100)  NULL ,
	oficina               varchar(100)  NULL ,
	operacion             varchar(100)  NULL ,
	tipo_garantia         varchar(50)  NULL ,
	garantia              varchar(150)  NULL ,
	pendiente             varchar(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.RPT_DETALLE_X_OPERACION
(
	cod_oficina_cliente   smallint  NULL ,
	des_oficina_cliente   varchar(100)  NULL ,
	oficina               varchar(100)  NULL ,
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	num_operacion         decimal(7)  NULL ,
	num_contrato          decimal(7)  NULL ,
	prmoc_psa_actual      decimal(18,2)  NULL ,
	prmoc_pfe_const       int  NULL ,
	prmoc_pfe_conta       int  NULL ,
	pendiente             varchar(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.SEG_PERFIL
(
	COD_PERFIL            int  IDENTITY (1,1) ,
	DES_PERFIL            varchar(100)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.SEG_ROL
(
	COD_ROL               int  NOT NULL ,
	DES_ROL               varchar(100)  NULL ,
	NOMBRE                varchar(100)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.SEG_ROLES_X_PERFIL
(
	COD_PERFIL            int  NOT NULL ,
	COD_ROL               int  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.SEG_USUARIO
(
	COD_USUARIO           varchar(30)  NOT NULL ,
	DES_USUARIO           varchar(100)  NULL ,
	COD_PERFIL            int  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TAR_BIN_SISTAR
(
	bin                   numeric(16)  NOT NULL ,
	fecingreso            datetime  NOT NULL 
	CONSTRAINT DF__TAR_BIN_S__fecin__723D9313
		 DEFAULT  CURRENT_TIMESTAMP 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TAR_GARANTIA_FIDUCIARIA
(
	cod_garantia_fiduciaria  bigint  IDENTITY (1,1) ,
	cod_tipo_garantia     smallint  NOT NULL ,
	cod_clase_garantia    smallint  NOT NULL ,
	cedula_fiador         varchar(25)  NOT NULL ,
	nombre_fiador         varchar(50)  NULL ,
	cod_tipo_fiador       smallint  NULL ,
	ruc_cedula_fiador     varchar(30)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA
(
	cod_tarjeta           int  NOT NULL ,
	cod_garantia_fiduciaria  bigint  NOT NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	fecha_expiracion      datetime  NULL ,
	monto_cobertura       money  NULL ,
	des_observacion       varchar(150)  NULL ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA_PorcentajeAceptacion
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TAR_GARANTIAS_FIDUCIARIAS_X_TARJETA',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA
(
	cod_tarjeta           int  NOT NULL ,
	observaciones         varchar(250)  NOT NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TAR_TARJETA
(
	cod_tarjeta           int  IDENTITY (1,1) ,
	cedula_deudor         varchar(30)  NOT NULL ,
	num_tarjeta           varchar(16)  NOT NULL ,
	cod_bin               int  NOT NULL ,
	cod_interno_sistar    int  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_oficina_registra  smallint  NULL ,
	cod_tipo_garantia     int  NOT NULL 
	CONSTRAINT DF_TAR_TARJETA_cod_tipo_garantia
		 DEFAULT  1 ,
	cod_estado_tarjeta    varchar(1)  NOT NULL 
	CONSTRAINT DF__TAR_TARJE__cod_e__7425DB85
		 DEFAULT  'H' 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Codigo del tipo de garant�a que le ha sido asignada' , 'user' , 'dbo' , 'table' , 'TAR_TARJETA', 'column' , 'cod_tipo_garantia'
GO



CREATE TABLE dbo.TAR_TARJETA_SICC
(
	num_tarjeta           varchar(16)  NOT NULL ,
	cedula_deudor         varchar(30)  NULL ,
	cod_bin               int  NULL ,
	monto_cobertura       money  NULL ,
	fecha_expiracion      datetime  NULL ,
	cedula_fiador         varchar(25)  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_oficina_registra  smallint  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TAR_TARJETA_SISTAR
(
	cedula                varchar(12)  NULL ,
	tarjeta               varchar(16)  NULL ,
	bin                   int  NULL ,
	codigo_interno        int  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TMP_ARCHIVO_CONTRATOS
(
	prmca_pco_ofici       smallint  NULL ,
	prmca_pco_moned       tinyint  NULL ,
	prmca_pco_produc      tinyint  NULL ,
	prmca_pnu_contr       int  NULL ,
	prmca_pmo_maxim       decimal(14,2)  NULL ,
	prmca_pmo_utiliz      decimal(14,2)  NULL ,
	prmca_pmo_reserv      decimal(14,2)  NULL ,
	prmca_psa_discon      decimal(14,2)  NULL ,
	prmca_psa_conta       decimal(14,2)  NULL ,
	saldo_actual_giros    decimal(14,2)  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	cod_usuario           varchar(30)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TMP_CALCULO_MTAT_MTANT
(
	Fecha_Hora            datetime  NOT NULL 
	CONSTRAINT DF_TMP_CALCULO_MTAT_MTANT_Fecha_Hora
		 DEFAULT  CURRENT_TIMESTAMP ,
	Id_Garantia           varchar(30)  NOT NULL ,
	Tipo_Garantia_Real    tinyint  NOT NULL ,
	Clase_Garantia        smallint  NOT NULL ,
	Semestre_Calculado    datetime  NOT NULL ,
	Fecha_Valuacion       datetime  NULL ,
	Monto_Ultima_Tasacion_Terreno  decimal(18,2)  NOT NULL ,
	Monto_Ultima_Tasacion_No_Terreno  decimal(18,2)  NOT NULL ,
	Tipo_Cambio           decimal(18,2)  NULL ,
	Indice_Precios_Consumidor  decimal(18,2)  NULL ,
	Tipo_Cambio_Anterior  decimal(18,2)  NULL ,
	Indice_Precios_Consumidor_Anterior  decimal(18,2)  NULL ,
	Factor_Tipo_Cambio    float  NULL ,
	Factor_IPC            float  NULL ,
	Porcentaje_Depreciacion_Semestral  float  NULL ,
	Monto_Tasacion_Actualizada_Terreno  float  NULL ,
	Monto_Tasacion_Actualizada_No_Terreno  float  NULL ,
	Numero_Registro       smallint  NOT NULL ,
	Codigo_Operacion      bigint  NOT NULL ,
	Codigo_Garantia       bigint  NOT NULL ,
	Tipo_Bien             tinyint  NOT NULL ,
	Total_Semestres_Calcular  smallint  NULL ,
	Usuario               varchar(30)  NOT NULL,
	Porcentaje_Aceptacion_Base  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_TMP_CALCULO_MTAT_MTANT_PorcentajeAceptacionBase
		 DEFAULT  0,
	Porcentaje_Aceptacion_Terreno  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_TMP_CALCULO_MTAT_MTANT_PorcentajeAceptacionTerreno
		 DEFAULT  0,
	Porcentaje_Aceptacion_No_Terreno  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_TMP_CALCULO_MTAT_MTANT_PorcentajeAceptacionNoTerreno
		 DEFAULT  0,
	Porcentaje_Aceptacion_Terreno_Calculado  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_TMP_CALCULO_MTAT_MTANT_PorcentajeAceptacionTerrenoCalculado
		 DEFAULT  0,
	Porcentaje_Aceptacion_No_Terreno_Calculado  decimal(5,2)  NOT NULL 
	CONSTRAINT  DF_TMP_CALCULO_MTAT_MTANT_PorcentajeAceptacionNoTerrenoCalculado
		 DEFAULT  0
)
 ON "PRIMARY"
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla alamcenar�, de forma temporal, los registros generados por el c�lculo del monto de la tasaci�n actualizada del terreno y no terreno. Cada registro corresponde a un semestre.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� la fecha y hora en que se incluye el registro.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Fecha_Hora'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� la identificaci�n de la garant�a, seg�n el tipo de garant�a real:

i. Hipoteca Com�n: Partido-Finca.
ii. C�dula Hipotecaria: Partido-Finca.
iii. Prenda: Clase de bien-Placa.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Id_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el tipo de garant�a real de la que se trata, a saber:

i. Hipoteca Com�n: 1.
ii. C�dula Hipotecaria: 2.
iii. Prenda: 3.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Garantia_Real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el c�digo de la clase de garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Clase_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� la fecha correspondiente al semestre calculado.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Semestre_Calculado'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo alamcenar� la fecha del aval�o calculado.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Fecha_Valuacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el monto de la �ltima tasaci�n del terreno.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Ultima_Tasacion_Terreno'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el monto de la �ltima tasaci�n del no terreno.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Ultima_Tasacion_No_Terreno'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el tipo de cambio usado para el c�lculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Cambio'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el �ndice de precios al consumidor usado por el c�lculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Indice_Precios_Consumidor'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el tipo de cambio usado para el c�lculo del semestre anterior. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Cambio_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el �ndice de precios al consumidor usado por el c�lculo del semestre anterior. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Indice_Precios_Consumidor_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el factor del tipo de cambio usado por el c�lculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Factor_Tipo_Cambio'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el factor del �ndice de precios al consumidor usado por el c�lculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Factor_IPC'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo guardar� el porcentaje de depreciaci�n semestral usado por el c�clulo del monto.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Porcentaje_Depreciacion_Semestral'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el monto de la tasaci�n actualizada del terrneo calculado, producto de la aplicaci�n de la f�rmula correspondiente.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Tasacion_Actualizada_Terreno'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el monto de la tasaci�n actualizada del no terrneo calculado, producto de la aplicaci�n de la f�rmula correspondiente.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Tasacion_Actualizada_No_Terreno'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el n�mero de registro, para una misma garant�a y una misma operaci�n.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Numero_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo asignado a la operaci�n al cual esta asociada la garant�a real cuya valuaci�n ser� trabajada.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Codigo_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo asignado a la garant�a real cuya valuaci�n ser� trabajada.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Codigo_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� el tipo de bien asignado a la garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Cantidad total de semestres que ser�n calculados.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Total_Semestres_Calcular'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Este campo almacenar� la identificaci�n del usuario que ejecuta el c�lculo del monto. En el caso del proceso diario se asigna el valor "UsuarioBD".' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Usuario'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_CALCULO_MTAT_MTANT',
'column', 'Porcentaje_Aceptacion_Terreno'
GO


EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_CALCULO_MTAT_MTANT',
'column', 'Porcentaje_Aceptacion_No_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_CALCULO_MTAT_MTANT',
'column', 'Porcentaje_Aceptacion_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_CALCULO_MTAT_MTANT',
'column', 'Porcentaje_Aceptacion_No_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n parametrizado, para el tipo de mitigador, al momento de aplicar el c�clulo.',
'user', 'dbo',
'table', 'TMP_CALCULO_MTAT_MTANT',
'column', 'Porcentaje_Aceptacion_Base'
GO



CREATE TABLE dbo.TMP_GAR_CONTRATOS
(
	cod_contabilidad      tinyint  NOT NULL ,
	cod_oficina           smallint  NOT NULL ,
	cod_moneda            tinyint  NOT NULL ,
	cod_producto          tinyint  NULL ,
	num_operacion         decimal(7)  NULL ,
	num_contrato          decimal(7)  NULL ,
	fecha_constitucion    datetime  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	fecha_vencimiento     datetime  NULL ,
	monto_original        decimal(18,2)  NULL ,
	saldo_actual          decimal(18,2)  NULL ,
	cod_estado            smallint  NOT NULL 
	CONSTRAINT DF1_TMP_GAR_CONTRATOS_cod_estado
		 DEFAULT  1 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TMP_GARANTIAS_FIDUCIARIAS
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(16)  NULL ,
	cedula_fiador         varchar(25)  NULL ,
	cod_tipo_fiador       smallint  NULL ,
	fecha_valuacion       varchar(10)  NULL ,
	ingreso_neto          decimal(18,2)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	nombre_fiador         varchar(50)  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	nombre_deudor         varchar(50)  NULL ,
	oficina_deudor        smallint  NULL ,
	cod_estado_tarjeta    varchar(1)  NULL ,
	cod_garantia_fiduciaria  bigint  NULL ,
	cod_operacion         bigint  NULL ,
	cod_tipo_operacion    tinyint  NOT NULL ,
	ind_operacion_vencida  tinyint  NULL ,
	ind_duplicidad        tinyint  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_FIDUCIARIAS_ind_duplicidad
		 DEFAULT  1 ,
	cod_usuario           varchar(30)  NOT NULL ,
	cod_llave             bigint  IDENTITY (1,1) ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_FIDUCIARIAS_PorcentajeAceptacion
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TMP_GARANTIAS_FIDUCIARIAS',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO



CREATE TABLE dbo.TMP_GARANTIAS_REALES
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(7)  NULL ,
	cod_tipo_bien         smallint  NULL ,
	cod_bien              varchar(25)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	fecha_presentacion    varchar(10)  NULL ,
	cod_inscripcion       smallint  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	fecha_constitucion    varchar(10)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	fecha_vencimiento     varchar(10)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	fecha_valuacion       varchar(10)  NULL ,
	cedula_empresa        varchar(30)  NULL ,
	cod_tipo_empresa      smallint  NULL ,
	cedula_perito         varchar(30)  NULL ,
	cod_tipo_perito       smallint  NULL ,
	monto_ultima_tasacion_terreno  decimal(18,2)  NULL ,
	monto_ultima_tasacion_no_terreno  decimal(18,2)  NULL ,
	monto_tasacion_actualizada_terreno  decimal(18,2)  NULL ,
	monto_tasacion_actualizada_no_terreno  decimal(18,2)  NULL ,
	fecha_ultimo_seguimiento  varchar(10)  NULL ,
	monto_total_avaluo    decimal(18,2)  NULL ,
	fecha_construccion    varchar(10)  NULL ,
	cod_grado             varchar(2)  NULL ,
	cedula_hipotecaria    varchar(2)  NULL ,
	cod_clase_garantia    smallint  NULL ,
	cod_operacion         bigint  NULL ,
	cod_garantia_real     bigint  NULL ,
	cod_tipo_garantia_real  tinyint  NULL ,
	numero_finca          varchar(25)  NULL ,
	num_placa_bien        varchar(25)  NULL ,
	cod_clase_bien        varchar(3)  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	cod_estado            smallint  NULL ,
	cod_liquidez          smallint  NULL ,
	cod_tenencia          smallint  NULL ,
	cod_moneda_garantia   smallint  NULL ,
	cod_partido           smallint  NULL ,
	cod_tipo_garantia     smallint  NULL ,
	Garantia_Real         varchar(150)  NULL ,
	fecha_prescripcion    varchar(10)  NULL ,
	cod_tipo_operacion    tinyint  NOT NULL ,
	ind_operacion_vencida  tinyint  NULL ,
	ind_duplicidad        tinyint  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_REALES_ind_duplicidad
		 DEFAULT  1 ,
	cod_usuario           varchar(30)  NOT NULL ,
	cod_llave             bigint  IDENTITY (1,1),
	Porcentaje_Aceptacion_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_Terreno_Calculado  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno_Calculado  decimal(5,2) NULL,
	Codigo_SAP numeric(8,0) NULL,
	Monto_Poliza_Colonizado numeric(16,2) NULL,
	Fecha_Vencimiento_Poliza datetime NULL,
	Codigo_Tipo_Poliza_Sugef  int NULL,
	Indicador_Poliza char(1) NULL,
	Indicador_Coberturas_Obligatorias  char(2) NULL ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_PorcentajeAceptacion
		 DEFAULT  -1
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'C�digo de la p�liza dentro del sistema de p�lizas (SAP).',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Codigo_SAP'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Guardar� el monto de la p�liza colonizado, para lo cual debe usar el tipo de cambio de compra del d�lar, almacenado en la tabla CAT_INDICES_ACTUALIZACION_AVALUO.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Monto_Poliza_Colonizado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Fecha de vencimiento de la p�liza.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Fecha_Vencimiento_Poliza'
GO

EXEC sp_addextendedproperty
'MS_Description', 'C�digo asignado al tipo de p�liza SUGEF.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Codigo_Tipo_Poliza_Sugef'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Indica si la garant�a posee una p�liza relacionada (S) o no (N).',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Indicador_Poliza'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Indica si la p�liza relacionada a la garant�a posee todas las coberturas obligatorias (SI) o no (NO).',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES',
'column', 'Indicador_Coberturas_Obligatorias'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TMP_GARANTIAS_REALES',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.TMP_GARANTIAS_REALES_OPERACIONES
(
	Codigo_Llave          bigint  IDENTITY (1,1) ,
	Codigo_Operacion      bigint  NOT NULL ,
	Codigo_Garantia_Real  bigint  NOT NULL ,
	Codigo_Contabilidad   tinyint  NOT NULL ,
	Codigo_Oficina        smallint  NOT NULL ,
	Codigo_Moneda         tinyint  NOT NULL ,
	Codigo_Producto       tinyint  NOT NULL ,
	Operacion             decimal(7)  NOT NULL ,
	Codigo_Tipo_Bien      smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Tipo_Bien
		 DEFAULT  (-1) ,
	Codigo_Tipo_Mitigador  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Tipo_Mitigador
		 DEFAULT  (-1) ,
	Codigo_Tipo_Documento_Legal  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Tipo_Documento_Legal
		 DEFAULT  (-1) ,
	Codigo_Inscripcion    smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Inscripcion
		 DEFAULT  (-1) ,
	Codigo_Tipo_Garantia_Real  tinyint  NOT NULL ,
	Codigo_Estado         smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Estado
		 DEFAULT  1 ,
	Codigo_Grado_Gravamen  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Grado_Gravamen
		 DEFAULT  (-1) ,
	Codigo_Clase_Garantia  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Clase_Garantia
		 DEFAULT  (-1) ,
	Codigo_Partido        tinyint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Partido
		 DEFAULT  0 ,
	Codigo_Tipo_Garantia  tinyint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Tipo_Garantia
		 DEFAULT  2 ,
	Codigo_Tipo_Operacion  tinyint  NOT NULL ,
	Indicador_Duplicidad  tinyint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Indicador_Duplicidad
		 DEFAULT  1 ,
	Porcentaje_Responsabilidad  decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Porcentaje_Responsabilidad
		 DEFAULT  0 ,
	Monto_Mitigador       decimal(18,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Monto_Mitigador
		 DEFAULT  0 ,
	Codigo_Grado          char(2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Grado
		 DEFAULT  '' ,
	Codigo_Clase_Bien     char(3)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Clase_Bien
		 DEFAULT  '' ,
	Cedula_Hipotecaria    char(2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Cedula_Hipotecaria
		 DEFAULT  '' ,
	Codigo_Bien           varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Codigo_Bien
		 DEFAULT  '-' ,
	Fecha_Presentacion    varchar(10)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Fecha_Presentacion
		 DEFAULT  '1900-01-01' ,
	Fecha_Constitucion    varchar(10)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Fecha_Constitucion
		 DEFAULT  '1900-01-01' ,
	Numero_Finca          varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Numero_Finca
		 DEFAULT  '' ,
	Numero_Placa_Bien     varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_Numero_Placa_Bien
		 DEFAULT  '' ,
	Codigo_Usuario        varchar(30)  NOT NULL,
	Indicador_Calcular_MTAT_MTANT  bit  NOT NULL 
	CONSTRAINT  DF_TMP_GARANTIAS_REALES_OPERACIONES_IndicadorCalcularMTATMTANT
		 DEFAULT  0,
	Indicador_Calcular_PATC  bit  NOT NULL 
	CONSTRAINT  DF_TMP_GARANTIAS_REALES_OPERACIONES_IndicadorCalcularPATC
		 DEFAULT  0,
	Indicador_Calcular_PANTC  bit  NOT NULL 
	CONSTRAINT  DF_TMP_GARANTIAS_REALES_OPERACIONES_IndicadorCalcularPANTC
		 DEFAULT  0,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_OPERACIONES_PorcentajeAceptacion
		 DEFAULT  -1
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Almacenar� las garant�as a ser filtradas durante el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo llave del registro.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Llave'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la garant�a real.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Garantia_Real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Contabilidad de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Contabilidad'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Oficina de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Oficina'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Moneda de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Producto de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Producto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de operaci�n o contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Mitigador'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de documento legal.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Documento_Legal'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indicador de inscripci�n.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Inscripcion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Tipo de garant�a real, siendo los valores: 
1 = Hipoteca Com�n.
2 = C�dula Hipotecaria.
3 = Prenda.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Garantia_Real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Estado del registro, siendo los valores: 1 = Activo y 2 = Inactivo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Estado'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del grado de gravamen.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Grado_Gravamen'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase de garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Clase_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del partido donde se encuentra la finca. Aplica para Hipoteca Com�n y C�dula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Partido'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Tipo de garant�a, por defecto el valor es 2.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de operaci�n, siendo los valores: 1 = Operaci�n Directa, 2 = Contrato y 3 = Giro de Contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo que indica si el registro se encuentra duplicado. Los valores son: 1 = Unico y 2 = Duplicado.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Indicador_Duplicidad'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Porcentaje de aceptaci�n asignado a la garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Porcentaje_Responsabilidad'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto del mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Monto_Mitigador'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Grado de la c�dula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Grado'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase del bien. Aplica s�lo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Clase_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de c�dula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Cedula_Hipotecaria'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del bien.
Este campo se compondr� de la siguiente forma, seg�n el tipo de garant�a real:

a) Hipotecas comunes: Partido � Finca.
b) C�dulas Hipotecarias: Partido � Finca.
c) Prendas: clase de bien � placa del bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de presentaci�n de la garant�a ante el Registro de la Propiedad.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Fecha_Presentacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de constituci�n de la garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Fecha_Constitucion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de la finca. Aplica para Hipoteca Com�n y C�dula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Numero_Finca'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de identificaci�n del bien. Aplica s�lo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Numero_Placa_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que ejecuta el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Usuario'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Indicador de que el registro participar� en el c�lculo autom�tico de los montos de las tasaciones actualizadas del terreno y no terreno.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES_OPERACIONES',
'column', 'Indicador_Calcular_MTAT_MTANT'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Indicador de que el registro participar� en el c�lculo autom�tico del porcentaje de aceptaci�n del terreno calculado.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES_OPERACIONES',
'column', 'Indicador_Calcular_PATC'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Indicador de que el registro participar� en el c�lculo autom�tico del porcentaje de aceptaci�n del no terreno calculado.',
'user', 'dbo',
'table', 'TMP_GARANTIAS_REALES_OPERACIONES',
'column', 'Indicador_Calcular_PANTC'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TMP_GARANTIAS_REALES_OPERACIONES',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.TMP_GARANTIAS_REALES_X_OPERACION
(
	Codigo_Operacion      bigint  NOT NULL ,
	Codigo_Garantia_Real  bigint  NOT NULL ,
	Codigo_Contabilidad   tinyint  NOT NULL ,
	Codigo_Oficina        smallint  NOT NULL ,
	Codigo_Moneda         tinyint  NOT NULL ,
	Codigo_Producto       tinyint  NOT NULL ,
	Operacion             decimal(7)  NOT NULL ,
	Codigo_Tipo_Bien      smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Tipo_Bien
		 DEFAULT  (-1) ,
	Codigo_Tipo_Mitigador  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Tipo_Mitigador
		 DEFAULT  (-1) ,
	Codigo_Tipo_Documento_Legal  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Tipo_Documento_Legal
		 DEFAULT  (-1) ,
	Codigo_Inscripcion    smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Inscripcion
		 DEFAULT  (-1) ,
	Codigo_Tipo_Garantia_Real  tinyint  NOT NULL ,
	Codigo_Grado_Gravamen  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Grado_Gravamen
		 DEFAULT  (-1) ,
	Codigo_Clase_Garantia  smallint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Clase_Garantia
		 DEFAULT  (-1) ,
	Codigo_Partido        tinyint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Partido
		 DEFAULT  0 ,
	Codigo_Tipo_Garantia  tinyint  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Tipo_Garantia
		 DEFAULT  2 ,
	Codigo_Tipo_Operacion  tinyint  NOT NULL ,
	Porcentaje_Responsabilidad  decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Porcentaje_Responsabilidad
		 DEFAULT  0 ,
	Monto_Mitigador       decimal(18,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Monto_Mitigador
		 DEFAULT  0 ,
	Codigo_Grado          char(2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Grado
		 DEFAULT  '' ,
	Codigo_Clase_Bien     char(3)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Clase_Bien
		 DEFAULT  '' ,
	Cedula_Hipotecaria    char(2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Cedula_Hipotecaria
		 DEFAULT  '' ,
	Codigo_Bien           varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Codigo_Bien
		 DEFAULT  '-' ,
	Fecha_Constitucion    varchar(10)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Fecha_Constitucion
		 DEFAULT  '1900-01-01' ,
	Fecha_Presentacion    varchar(10)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Fecha_Presentacion
		 DEFAULT  '1900-01-01' ,
	Numero_Finca          varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Numero_Finca
		 DEFAULT  '' ,
	Numero_Placa_Bien     varchar(25)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_Numero_Placa_Bien
		 DEFAULT  '' ,
	Codigo_Usuario        varchar(30)  NOT NULL ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_REALES_X_OPERACION_PorcentajeAceptacion
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Almacenar� las garant�as que ser�n validadas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la garant�a real.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Garantia_Real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Contabilidad de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Contabilidad'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Oficina de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Oficina'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Moneda de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Producto de la operaci�n, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Producto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de operaci�n o contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Mitigador'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de documento legal.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Documento_Legal'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indicador de inscripci�n.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Inscripcion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Tipo de garant�a real, siendo los valores: 
1 = Hipoteca Com�n.
2 = C�dula Hipotecaria.
3 = Prenda.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Garantia_Real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del grado de gravamen.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Grado_Gravamen'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase de garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Clase_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del partido donde se encuentra la finca. Aplica para Hipoteca Com�n y C�dula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Partido'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Tipo de garant�a, por defecto el valor es 2.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Garantia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de operaci�n, siendo los valores: 1 = Operaci�n Directa, 2 = Contrato y 3 = Giro de Contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Porcentaje de aceptaci�n asignado a la garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Porcentaje_Responsabilidad'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto del mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Monto_Mitigador'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Grado de la c�dula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Grado'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase del bien. Aplica s�lo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Clase_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de c�dula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Cedula_Hipotecaria'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del bien.
Este campo se compondr� de la siguiente forma, seg�n el tipo de garant�a real:

a) Hipotecas comunes: Partido � Finca.
b) C�dulas Hipotecarias: Partido � Finca.
c) Prendas: clase de bien � placa del bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de constituci�n de la garant�a.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Constitucion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de presentaci�n de la garant�a ante el Registro de la Propiedad.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Presentacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de la finca. Aplica para Hipoteca Com�n y C�dula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Numero_Finca'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de identificaci�n del bien. Aplica s�lo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Numero_Placa_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que ejecuta el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Usuario'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TMP_GARANTIAS_REALES_X_OPERACION',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.TMP_GARANTIAS_VALOR
(
	cod_contabilidad      tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(7)  NULL ,
	numero_seguridad      varchar(25)  NULL ,
	cod_tipo_mitigador    smallint  NULL ,
	cod_tipo_documento_legal  smallint  NULL ,
	monto_mitigador       decimal(18,2)  NULL ,
	fecha_presentacion    varchar(10)  NULL ,
	cod_inscripcion       smallint  NULL ,
	porcentaje_responsabilidad  decimal(5,2)  NULL ,
	fecha_constitucion    varchar(10)  NULL ,
	cod_grado_gravamen    smallint  NULL ,
	cod_grado_prioridades  smallint  NULL ,
	monto_prioridades     decimal(18,2)  NULL ,
	cod_tipo_acreedor     smallint  NULL ,
	cedula_acreedor       varchar(30)  NULL ,
	fecha_vencimiento     varchar(10)  NULL ,
	cod_operacion_especial  smallint  NULL ,
	cod_clasificacion_instrumento  smallint  NULL ,
	des_instrumento       varchar(25)  NULL ,
	des_serie_instrumento  varchar(20)  NULL ,
	cod_tipo_emisor       smallint  NULL ,
	cedula_emisor         varchar(30)  NULL ,
	premio                decimal(18,2)  NULL ,
	cod_isin              varchar(25)  NULL ,
	valor_facial          decimal(18,2)  NULL ,
	cod_moneda_valor_facial  smallint  NULL ,
	valor_mercado         decimal(18,2)  NULL ,
	cod_moneda_valor_mercado  smallint  NULL ,
	monto_responsabilidad  decimal(18,2)  NULL ,
	cod_moneda_garantia   smallint  NULL ,
	cedula_deudor         varchar(30)  NULL ,
	nombre_deudor         varchar(50)  NULL ,
	oficina_deudor        smallint  NULL ,
	cod_tipo_garantia     smallint  NULL ,
	cod_clase_garantia    smallint  NULL ,
	cod_tenencia          smallint  NULL ,
	fecha_prescripcion    varchar(10)  NULL ,
	cod_garantia_valor    bigint  NULL ,
	cod_operacion         bigint  NULL ,
	cod_estado            smallint  NULL ,
	cod_tipo_operacion    tinyint  NOT NULL ,
	ind_operacion_vencida  tinyint  NULL ,
	ind_duplicidad        tinyint  NOT NULL 
	CONSTRAINT DF_GAR_GIROS_GARANTIAS_VALOR_ind_duplicidad
		 DEFAULT  1 ,
	cod_usuario           varchar(30)  NOT NULL ,
	cod_llave             bigint  IDENTITY (1,1) ,
	Porcentaje_Aceptacion decimal(5,2)  NOT NULL 
	CONSTRAINT DF_TMP_GARANTIAS_VALOR_PorcentajeAceptacion
		 DEFAULT  -1 
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Porcentaje de aceptaci�n de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'TMP_GARANTIAS_VALOR',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Aceptacion'
GO


CREATE TABLE dbo.TMP_OPERACIONES
(
	cod_operacion         bigint  NULL ,
	cod_garantia          bigint  NULL ,
	cod_tipo_garantia     tinyint  NULL ,
	cod_tipo_operacion    tinyint  NULL ,
	ind_contrato_vencido  tinyint  NULL ,
	ind_contrato_vencido_giros_activos  tinyint  NULL ,
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	num_operacion         decimal(7)  NULL ,
	num_contrato          decimal(7)  NULL ,
	cod_oficina_contrato  smallint  NULL ,
	cod_moneda_contrato   tinyint  NULL ,
	cod_producto_contrato  tinyint  NULL ,
	cod_estado_garantia   bit  NULL 
	CONSTRAINT DF_TMP_OPERACIONES_codestadogarantia
		 DEFAULT  0 ,
	cod_usuario           varchar(30)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TMP_OPERACIONES_DUPLICADAS
(
	cod_oficina           smallint  NULL ,
	cod_moneda            tinyint  NULL ,
	cod_producto          tinyint  NULL ,
	operacion             decimal(7)  NULL ,
	cod_tipo_operacion    tinyint  NULL ,
	cod_garantia_sicc     varchar(30)  NULL ,
	cod_tipo_garantia     tinyint  NULL ,
	cod_usuario           varchar(30)  NULL ,
	cod_garantia          bigint  NULL ,
	cod_grado             varchar(2)  NULL 
)
 ON "PRIMARY"
GO



CREATE TABLE dbo.TMP_VALUACIONES_REALES
(
	cod_garantia_real     bigint  NULL ,
	fecha_valuacion       datetime  NULL ,
	cedula_empresa        varchar(30)  NULL ,
	cedula_perito         varchar(30)  NULL ,
	monto_ultima_tasacion_terreno  money  NULL ,
	monto_ultima_tasacion_no_terreno  money  NULL ,
	monto_tasacion_actualizada_terreno  money  NULL ,
	monto_tasacion_actualizada_no_terreno  money  NULL ,
	fecha_ultimo_seguimiento  datetime  NULL ,
	monto_total_avaluo    money  NULL ,
	cod_recomendacion_perito  smallint  NULL ,
	cod_inspeccion_menor_tres_meses  smallint  NULL ,
	fecha_construccion    datetime  NULL ,
	cod_tipo_bien         smallint  NULL ,
	ind_avaluo_completo   tinyint  NULL 
	CONSTRAINT DF_TMP_VALUACIONES_REALES_ind_avaluo_completo
		 DEFAULT  1 ,
	cod_usuario           varchar(30)  NULL,
	Porcentaje_Aceptacion_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno  decimal(5,2) NULL,
	Porcentaje_Aceptacion_Terreno_Calculado  decimal(5,2) NULL,
	Porcentaje_Aceptacion_No_Terreno_Calculado  decimal(5,2) NULL
)
 ON "PRIMARY"
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno, ingresado por el usuario.',
'user', 'dbo',
'table', 'TMP_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_Terreno_Calculado'
GO

EXEC sp_addextendedproperty
'MS_Description', 'Porcentaje de aceptaci�n del no terreno calculado, es definido por el sistema.',
'user', 'dbo',
'table', 'TMP_VALUACIONES_REALES',
'column', 'Porcentaje_Aceptacion_No_Terreno_Calculado'
GO



CREATE TABLE dbo.GAR_SICC_DAMHT
(
	my_aa varchar(12) NOT NULL,
	damht_aco_estado varchar(1) NULL,
	damht_dcatraefe int NULL,
	damht_dcatrasol int NULL,
	damht_dco_moned tinyint NULL,
	damht_dcoclacam tinyint NULL,
	damht_dcoidereg decimal(12, 0) NULL,
	damht_dcotipcam tinyint NULL,
	damht_dfe_inic int NULL,
	damht_dfe_regis int NULL,
	damht_dferelini int NULL,
	damht_dferelreg int NULL,
	damht_dfeultact int NULL,
	damht_dho_inic int NULL,
	damht_dho_regis int NULL,
	damht_dhoultact int NULL,
	damht_dmotraefe decimal(12, 2) NULL,
	damht_dmotrasol decimal(12, 2) NULL,
	damht_dva_camb decimal(10, 4) NULL
) ON "PRIMARY"

GO

CREATE TABLE dbo.CAT_TIPOS_POLIZAS_SUGEF
(
	Codigo_Tipo_Poliza_Sugef  integer  NOT NULL ,
	Nombre_Tipo_Poliza    varchar(50)  NOT NULL ,
	Descripcion_Tipo_Poliza  varchar(500)  NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenar� el cat�logo de tipos de p�lizas SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo asignado, como campo llave, al tipo de p�liza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Codigo_Tipo_Poliza_Sugef'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre del tipo de p�liza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Nombre_Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n del tipo de p�liza, este texto aparecer� por medio de tooltip en la interfaz de usuario.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Descripcion_Tipo_Poliza'
GO



CREATE TABLE dbo.CAT_TIPOS_POLIZAS_X_TIPO_BIEN
(
	Consecutivo_Relacion  integer  IDENTITY (1,1), 
	Codigo_Tipo_Poliza_Sap  integer  NOT NULL ,
	Codigo_Tipo_Poliza_Sugef  integer  NOT NULL ,
	Codigo_Tipo_Bien      integer  NOT NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que contendr� la relaci�n entre el tipo de p�liza SAP, el tipo de p�liza SUGEF y el tipo de bien.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del cat�logo de tipos de p�liza SAP.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Poliza_Sap'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del cat�logo del tipo de p�liza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Poliza_Sugef'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del cat�logo del tipo de bien.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Bien'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo, autoincremental, asignado al registro.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Consecutivo_Relacion'
GO


CREATE TABLE dbo.GAR_POLIZAS
(
	Codigo_SAP            numeric(8,0)  NOT NULL ,
	cod_operacion         bigint  NOT NULL ,
	Tipo_Poliza           numeric(3,0)  NOT NULL ,
	Monto_Poliza          numeric(16,2)  NOT NULL ,
	Moneda_Monto_Poliza   numeric(3,0)  NOT NULL ,
	Fecha_Vencimiento     datetime  NULL ,
	Cedula_Acreedor       varchar(30)  NOT NULL 
	CONSTRAINT DF_GAR_POLIZAS_Cedula_Acreedor
		 DEFAULT  '4000000019' ,
	Nombre_Acreedor       varchar(60)  NOT NULL 
	CONSTRAINT DF_GAR_POLIZAS_Nombre_Acreedor
		 DEFAULT  'Banco de Costa Rica' ,
	Descripcion_Moneda_Monto_Poliza  varchar(30) COLLATE SQL_Latin1_General_CP850_CS_AS NOT NULL ,
	Simbolo_Moneda        char(5)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL ,
	Detalle_Poliza        varchar(250)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL ,
	Estado_Poliza         char(3)  NOT NULL ,
	Estado_Registro       bit  NOT NULL ,
	Fecha_Inserto         datetime  NOT NULL ,
	Fecha_Replica         datetime  NOT NULL ,
	Monto_Poliza_Anterior  numeric(16,2)  NULL ,
	Fecha_Vencimiento_Anterior  datetime  NULL ,
	Cedula_Acreedor_Anterior  varchar(30)  NULL,
	Nombre_Acreedor_Anterior  varchar(60)  NULL,
	Monto_Poliza_Colonizado  numeric(16,2)  NOT NULL 
	CONSTRAINT DF_GAR_POLIZAS_MontoPolizaColonizado
		 DEFAULT  0,
	Indicador_Poliza_Externa  BIT  NULL,
	Codigo_Partido  numeric(1,0)  NULL,
	Identificacion_Bien  varchar(25)  NULL,
	Codigo_Tipo_Cobertura  numeric(3,0)  NULL,
	Codigo_Aseguradora  tinyint  NULL	 
)
 ON "PRIMARY"
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena la informaci�n de las p�lizas registradas en el sistema de seguros (SAP), requerida por el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza dentro del sistema de p�lizas (SAP).' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto asegurado.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n del c�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Descripcion_Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'S�mbolo asignado a la moneda del monto del a p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Simbolo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Vencimiento'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del acreedro de la p�liza. Por defecto se establece la c�dula 4000000019.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Cedula_Acreedor'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre del acreedor. Por defecto se estable como "Banco de Costa Rica".' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Nombre_Acreedor'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Observaciones que puede poseer la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Detalle_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del estado de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Estado_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Estado del registro. Se manejan los siguientes valores:

0 - Inactivo
1 - Activo' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Estado_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n a la cual est� asociada la p�liza y que se encuentra registrada en el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'cod_operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro la primera vez.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Inserto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se actualiz� la ultima vez por motivo de la r�plica.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Replica'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto del aval�o anterior, esto en caso de que haya sido modificado.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento anterior,  esto en caso de que haya sido modificada.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Vencimiento_Anterior'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n anterior del acreedor de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Cedula_Acreedor_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre anterior del acreedor.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Nombre_Acreedor_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Guardar� el monto de la p�liza colonizado, para lo cual debe usar el tipo de cambio de compra del d�lar, almacenado en la tabla CAT_INDICES_ACTUALIZACION_AVALUO.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza_Colonizado'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Indica si la p�liza es externa (1) o no (0).' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Indicador_Poliza_Externa'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del partido.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Codigo_Partido'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del bien.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Identificacion_Bien'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Codigo_Tipo_Cobertura'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la aseguradora.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Codigo_Aseguradora'
GO



CREATE TABLE dbo.GAR_POLIZAS_RELACIONADAS
(
	Codigo_SAP            numeric(8,0)  NOT NULL ,
	cod_operacion         bigint  NOT NULL ,
	cod_garantia_real     bigint  NOT NULL ,
	Estado_Registro       bit  NOT NULL ,
	Monto_Acreencia       numeric(16,2)  NOT NULL 
	CONSTRAINT DF_GARPOLIZASRELACIONADAS_Monto_Acreencia
		 DEFAULT  0 ,
	Fecha_Inserto         datetime  NOT NULL ,
	Usuario_Modifico      varchar(30)  NULL ,
	Fecha_Modifico        datetime  NULL ,
	Usuario_Inserto       varchar(30)  NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena la relaciones existentes entre una determina p�liza y una garant�a espec�fica de una operaci�n determinada.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza dentro del sistema de p�lizas (SAP).' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n a la cual est� asociada la p�liza y que se encuentra registrada en el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'cod_operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo del registro de la garant�a a la cual se le asocia la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'cod_garantia_real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Estado de la relaci�n. Se manejan los siguientes valores:

0 - Inactivo
1 - Activo' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Estado_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto de la acreencia digitado por el usuario.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Monto_Acreencia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro la primera vez.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Fecha_Inserto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Usuario_Modifico'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realiz� la �ltima modificaci�n.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Fecha_Modifico'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que provoc� la inserci�n del registro.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Usuario_Inserto'
GO

CREATE TABLE dbo.TMP_POLIZAS
(
	Codigo_SAP            numeric(8,0)  NOT NULL ,
	Tipo_Poliza           numeric(3,0)  NOT NULL ,
	Codigo_Oficina_Operacion  numeric(4,0)  NOT NULL ,
	Codigo_Moneda_Operacion  numeric(3,0)  NOT NULL ,
	Codigo_Producto_Operacion  numeric(2,0)  NOT NULL ,
	Numero_Operacion      numeric(7,0)  NOT NULL ,
	Numero_Contrato       varchar(10)  NOT NULL ,
	Consecutivo_Operacion_Garantias  bigint  NULL,
	Monto_Poliza          numeric(16,2)  NOT NULL ,
	Moneda_Monto_Poliza   numeric(3,0)  NOT NULL ,
	Estado_Poliza         char(3)  NOT NULL ,
	Simbolo_Moneda        char(5)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL ,
	Fecha_Vencimiento     datetime  NULL ,
	Descripcion_Moneda_Monto_Poliza  varchar(30)  COLLATE SQL_Latin1_General_CP850_CS_AS NOT NULL ,
	Detalle_Poliza        varchar(250)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL,
	Fecha_Replica	DATETIME NULL,
	Registro_Activo BIT NULL,
	Indicador_Poliza_Externa  BIT  NULL,
	Codigo_Partido  numeric(1,0)  NULL,
	Identificacion_Bien  varchar(25)  NULL,
	Codigo_Tipo_Cobertura  numeric(3,0)  NULL,
	Codigo_Aseguradora  tinyint  NULL
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena, de forma temporal, la informaci�n de las p�lizas registradas en el sistema de seguros (SAP), requerida por el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza dentro del sistema de p�lizas (SAP).' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto asegurado.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n del c�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Descripcion_Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'S�mbolo asignado a la moneda del monto del a p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Simbolo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Fecha_Vencimiento'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Observaciones que puede poseer la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Detalle_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del estado de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Estado_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda de la operaci�n o contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Moneda_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la oficina de la operaci�n o contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Oficina_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del producto de la operaci�n, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Producto_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de la operaci�n, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Numero_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero del contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Numero_Contrato'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n, registrada en el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Consecutivo_Operacion_Garantias'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue replicado.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el registro est� activo (1) para ser procesado o no (0)' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Registro_Activo'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Indica si la p�liza es externa (1) o no (0).' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Indicador_Poliza_Externa'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del partido.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Partido'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del bien.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Identificacion_Bien'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Tipo_Cobertura'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la aseguradora.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Aseguradora'
GO


CREATE TABLE [dbo].[CAT_PORCENTAJE_ACEPTACION](
	[Codigo_Porcentaje_Aceptacion] [int] IDENTITY(1,1) NOT NULL,
	[Codigo_Tipo_Garantia] [int] NOT NULL,
	[Codigo_Tipo_Mitigador] [int] NOT NULL,
	[Indicador_Sin_Calificacion] [bit] NOT NULL,
	[Porcentaje_Aceptacion] [decimal](5, 2) NOT NULL,
	[Porcentaje_Cero_Tres] [decimal](5, 2) NULL,
	[Porcentaje_Cuatro] [decimal](5, 2) NULL,
	[Porcentaje_Cinco] [decimal](5, 2) NULL,
	[Porcentaje_Seis] [decimal](5, 2) NULL,
	[Usuario_Inserto] [varchar](30) NOT NULL,
	[Fecha_Inserto] [datetime] NOT NULL,
	[Usuario_Modifico] [varchar](30) NULL,
	[Fecha_Modifico] [datetime] NULL,
 CONSTRAINT [PK_CAT_PORCENTAJE_ACEPTACION] PRIMARY KEY CLUSTERED 
(
	[Codigo_Porcentaje_Aceptacion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON "PRIMARY"
GO

--PREGUNTAR
EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenar� el cat�logo de Porcentaje de Aceptacion Calculado.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificador �nico del registro.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del cat�logo de tipo de garantia. 1: Fiduciaria 2: Real 3:Valor' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Tipo_Garantia'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del cat�logo de tipo de mitigador.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Tipo_Mitigador'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Hace referencia a la clasificaci�n del porcentaje  de aceptaci�n a registrar.
0:  No aplica calificaci�n 1: Sin Calificaci�n ' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Indicador_Sin_Calificacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'N�mero m�ximo digitado por el usuario para realizar la validaci�n en los mantenimientos de garant�as' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'N�mero m�ximo digitado por el usuario para realizar la validaci�n en los mantenimientos de garant�as cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cero_Tres'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'N�mero m�ximo digitado por el usuario para realizar la validaci�n en los mantenimientos de garant�as cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cuatro'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'N�mero m�ximo digitado por el usuario para realizar la validaci�n en los mantenimientos de garant�as cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cinco'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'N�mero m�ximo digitado por el usuario para realizar la validaci�n en los mantenimientos de garant�as cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Seis'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Usuario que insert� el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Usuario_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insert� el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Usuario que modific� el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se modifc� el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Fecha_Modifico'
GO

CREATE TABLE [dbo].[PORCENTAJE_ACEPTACION_HST](
	[Codigo_Usuario] [varchar](30) NOT NULL,
	[Codigo_Accion] [int] NOT NULL,
	[Codigo_Consulta] [text] NULL,
	[Codigo_Tipo_Garantia] [int] NOT NULL,
	[Codigo_Tipo_Mitigador] [int] NOT NULL,
	[Descripcion_Campo_Afectado] [varchar](30) NULL,
	[Estado_Anterior_Campo_Afectado] [varchar](30) NULL,
	[Estado_Actual_Campo_Afectado] [varchar](30) NULL,
	[Fecha_Hora] [datetime] NOT NULL
) ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenar� el hist�rico del cat�logo de Porcentaje de Aceptacion Calculado.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Identificaci�n del usuario que ejecut� la operaci�n.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Usuario'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la operaci�n ejecutada, ya sea consultar, agregar, modificar o borrar.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Accion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consulta SQL que fue ejecutada.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Consulta'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo del Tipo de Garantia
1: Fiduciaria 2: Real 3:Valor' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Tipo_Garantia'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo del Tipo de Mitigador' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Tipo_Mitigador'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Nombre del campo que ha sido afectado.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Descripcion_Campo_Afectado'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Contenido que posee el campo antes del cambio.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Estado_Anterior_Campo_Afectado'
GO

EXEC sp_addextendedproperty 'MS_Description' , '�ltimo contenido asignado al campo.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Estado_Actual_Campo_Afectado'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha y hora en que fue ejecutada la operaci�n.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Fecha_Hora'
GO


CREATE TABLE dbo.TMP_SAP_VWSGRPOLIZA(
	conpoliza NUMERIC(8, 0) NULL,
	cocpolizains VARCHAR(30) NULL,
	cocnumeropoliza VARCHAR(30) NULL,
	concliente NUMERIC(7, 0)  NULL,
	indcolectiva NUMERIC(1, 0)  NULL,
	cocgrupopoliza VARCHAR(1) NULL,
	cocpolizasola VARCHAR(30) NULL,
	conclasepoliza NUMERIC(3,0) NOT NULL,
	contipopoliza NUMERIC(3, 0) NULL,
	cocsimbologia VARCHAR(4) NULL,
	indnumanterior NUMERIC(1, 0) NULL,
	nummodulo NUMERIC(3, 0) NULL,
	numsucursal NUMERIC(3, 0) NULL,
	conregion NUMERIC(2, 0) NULL,
	conagencia NUMERIC(4, 0) NULL,
	conagente NUMERIC(4, 0) NULL,
	conformapago NUMERIC(3, 0) NULL,
	conperiodicidadpoliza NUMERIC(2, 0) NULL,
	concanalizacioncobro NUMERIC(3, 0)  NULL,
	conmotivocancela NUMERIC(3, 0) NULL,
	fecemision DATETIME NULL,
	fecvigencia DATETIME NULL,
	fecvence DATETIME NULL,
	feccancelacion DATETIME NULL,
	fecproximopago DATETIME NULL,
	mtoasegurado NUMERIC(16, 2) NULL,
	mtoprimatotal NUMERIC(16, 2) NULL,
	mtoultimopago NUMERIC(16, 2) NULL,
	mtodeducible NUMERIC(10, 2) NULL,
	mtopagoperiodico NUMERIC(16,4) NULL,
	usrcancelo VARCHAR(35) NULL,
	memobservacion VARCHAR(250) NULL,
	desubicacionbien VARCHAR(250) NULL,
	desdetallebien VARCHAR(250) NULL,
	indexterna NUMERIC(1, 0) NULL,
	estpoliza VARCHAR(3)  NULL,
	codsenal NUMERIC(2, 0) NULL,
	conpolizamadre NUMERIC(8, 0) NULL,
	mtoprima NUMERIC(16, 2) NULL,
	concreditobancarioprincipal NUMERIC(10, 0) NULL,
	nummespoliza NUMERIC(2, 0) NULL,
	indrevisada NUMERIC(1, 0)  NULL,
	descoberturasasociadas VARCHAR(60) NULL,
	cocformacobropoliza VARCHAR(5) NULL,
	cocintencionalidad VARCHAR(20) NULL,
	desclasepoliza VARCHAR(60) NULL,
	destipopoliza VARCHAR(60) NULL,
	conmoneda NUMERIC(3, 0) NULL,
	indcobraimpuestorenta NUMERIC(1, 0) NULL, 
	nommoneda VARCHAR(30) NULL,
	monsigno VARCHAR(5) NULL,
	desformapago VARCHAR(60) NULL,
	nummeses NUMERIC(3, 0) NULL,
	dessiglas VARCHAR(30) NULL,
	contipocobertura NUMERIC(3, 0) NULL,
	codtiposiic VARCHAR(2) NULL,
	indesdesempleo NUMERIC(1, 0) NULL, 
	desunidadejecutora VARCHAR(60) NULL,
	cocpolizasicc VARCHAR(15) NULL,
	concanalventa SMALLINT NULL,
	cocestadopoliza VARCHAR(3) NULL,
	feccambioestadopoliza DATETIME NULL,
	conaseguradora TINYINT NULL,
	nomaseguradora VARCHAR(60) NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

CREATE TABLE dbo.TMP_SAP_VWSGRPOLIZACREDITOBANCARIO(
	conpoliza NUMERIC(8, 0) NOT NULL,
	concreditobancario NUMERIC(10, 0) NOT NULL,
	codsenalcredito NUMERIC(2, 0) NOT NULL,
	cocfrecuenciacobrosicc VARCHAR(1)  NULL,
	indcodeudor NUMERIC(1, 0) NOT NULL,
	estpolizacreditobancario VARCHAR(3) NOT NULL,
	feccancelacioncredito DATETIME NULL,
	fecatraso DATETIME NULL,
	fecpagadohasta DATETIME NULL,
	fecvencecredito DATETIME NULL,
	indprimadevuelta NUMERIC(1, 0) NOT NULL,
	fecdevolucionprima DATETIME NULL,
	usrdevolvioprima VARCHAR(35) NULL,
	codcontabilidad NUMERIC(2, 0) NOT NULL,
	codue NUMERIC(4, 0) NOT NULL,
	conmoneda NUMERIC(3, 0) NOT NULL,
	codproducto NUMERIC(2, 0) NOT NULL,
	numoperacion NUMERIC(7, 0) NOT NULL,
	concontratocredito NUMERIC(10, 0) NULL,
	estcreditobancario VARCHAR(3) NOT NULL,
	coccreditobancario VARCHAR(55) NULL,
	Es_Giro BIT NOT NULL,
	Consecutivo_Contrato BIGINT NOT NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

CREATE TABLE dbo.TMP_SAP_VWSGRPOLIZACONTRATOCREDITO(
	conpoliza NUMERIC(8, 0) NOT NULL,
	concontratocredito NUMERIC(10, 0)  NOT NULL,
	estpolizacontratocredito VARCHAR(3)  NOT NULL,
	feccancelacioncontrato DATETIME NULL,
	fecpagadohasta DATETIME NULL,
	codsenal NUMERIC(2, 0)  NULL,
	cocfrecuenciacobrosicc VARCHAR(1)  NULL,
	fecvencecredito DATETIME NULL,
	codue NUMERIC(4, 0)  NOT NULL,
	codcontabilidad NUMERIC(2, 0)  NOT NULL,
	conmoneda NUMERIC(3, 0)  NOT NULL,
	coccontratocredito VARCHAR(10) NOT NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

CREATE TABLE dbo.TMP_SAP_POLIZASEXTERNAS(
	conpoliza NUMERIC(8, 0) NOT NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL 
) ON [PRIMARY]

GO

CREATE TABLE dbo.TMP_SAP_VWSGRPOLIZAAUTO(
	conpoliza NUMERIC(8, 0) NOT NULL,
	cocplaca VARCHAR(15) NOT NULL,
	conestiloauto NUMERIC(3,0) NULL,
	conmarcaauto NUMERIC(3,0) NULL,
	contipocombustion NUMERIC(2,0) NOT NULL,
	desmodelo VARCHAR(35) NULL,
	descolor VARCHAR(20) NULL,
	numpeso NUMERIC(9,2) NULL,
	numcubicaje NUMERIC(4,0) NULL,
	numcapacidad NUMERIC(3,0) NULL,
	numcilindros NUMERIC(2,0) NULL,
	desnumeromotor VARCHAR(20) NULL,
	desnumerochasis VARCHAR(20) NOT NULL,
	mtovalorauto NUMERIC(16,2) NULL,
	porrecargobonificacion NUMERIC(7,4) NULL,
	contipovehiculo NUMERIC(6,0) NULL,
	desestadobien VARCHAR(3000) NULL,
	numanoauto NUMERIC(4,0) NULL,
	tipmodalidadaseguramiento NUMERIC(10,0) NULL,
	codestilocarroceria NUMERIC(2,0) NULL,
	indplacatemporal TINYINT NOT NULL,
	concliente NUMERIC(7,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	mtoasegurado NUMERIC(16,2) NULL,
	contipopoliza NUMERIC(3,0) NULL,
	desestiloauto VARCHAR(60) NULL,
	desmarcaauto VARCHAR(60) NULL,
	mtoprimatotal NUMERIC(16,2) NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	desestilocarroceria VARCHAR(60) NOT NULL,
	destipovehiculo VARCHAR(80) NOT NULL,
	destipocombustion VARCHAR(60) NOT NULL,
	desmodalidadaseguramiento VARCHAR(11) NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL 
) ON [PRIMARY]

GO


CREATE TABLE dbo.TMP_SAP_SGRPOLIZAOTRO(
	conpoliza NUMERIC(8,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	concliente NUMERIC(7,0) NOT NULL,
	contipopoliza NUMERIC(3, 0) NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	mtoasegurado NUMERIC(16, 2) NULL,
	mtoprimatotal NUMERIC(16, 2) NULL,
	desobservacion VARCHAR(1500) NULL,
	cocplaca VARCHAR(15) NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO 


CREATE TABLE dbo.TMP_SAP_SGRPOLIZAPATRIMONIAL(
	concliente NUMERIC(7,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	mtoaseguradototal NUMERIC(16,2) NULL,
	mtoprimatotal NUMERIC(16,2) NULL,
	contipopoliza NUMERIC(3,0) NULL,
	conpoliza NUMERIC(8,0) NOT NULL,
	conzonariesgo SMALLINT NOT NULL,
	conprovincia NUMERIC(1,0) NULL,
	concanton NUMERIC(2,0) NULL,
	condistrito NUMERIC(2,0) NULL,
	desnumerofinca VARCHAR(20) NULL,
	mtoasegurado NUMERIC(16,2) NULL,
	porparticipacion NUMERIC(7,4) NULL,
	pordeducible NUMERIC(7,4) NULL,
	mtodeduccibleminimo NUMERIC(16,2) NULL,
	memobservacion VARCHAR(200) NULL,
	desocupacion VARCHAR(20) NULL,
	cococupacionrobo VARCHAR(3) NULL,
	codclasetarifaria NUMERIC(2,0) NULL,
	codrecargoprr NUMERIC(3,0) NULL,
	conclaseconstruccion NUMERIC(8,0) NULL,
	conporcentajepci NUMERIC(2,0) NULL,
	contipocomercio NUMERIC(8,0) NULL,
	desdireccioninmuble VARCHAR(250) NULL,
	desfolioreal VARCHAR(20) NULL,
	mtoconstruccion NUMERIC(16,4) NULL,
	mtogarantia NUMERIC(16,4) NULL,
	numgradohipoteca NUMERIC(2,0) NULL,
	numpisos NUMERIC(3,0) NULL,
	portarifa NUMERIC(7,4) NULL,
	portarifab NUMERIC(7,4) NULL,
	mtovalorterreno NUMERIC(16,4) NULL,
	mtoaseguradomenaje NUMERIC(16,4) NULL,
	codparticipacionasegurado TINYINT NULL,
	concreditobancario NUMERIC(10,0) NULL,
	mtoprimaparcial NUMERIC(16,2) NOT NULL,
	tiptramiteregistro TINYINT NOT NULL,
	mtoprimaparcialsicc NUMERIC(10,2) NOT NULL,
	cochorizontal CHAR(1) NULL,
	desprovincia VARCHAR(35) NOT NULL,
	descanton VARCHAR(45) NOT NULL,
	desdistrito VARCHAR(45) NOT NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL 
) ON [PRIMARY]

GO 

CREATE TABLE dbo.TMP_SAP_VWSGRCONTRATOCREDITO(
	concontratocredito NUMERIC(10,0) NOT NULL,
	codcontabilidad NUMERIC(2,0) NOT NULL,
	codue NUMERIC(4,0) NOT NULL,
	conmoneda NUMERIC(3,0) NOT NULL,
	coccontratocredito VARCHAR(10) NOT NULL,
	coccontratocreditolargo VARCHAR(55) NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL 
) ON [PRIMARY]

GO 

CREATE TABLE dbo.TMP_SAP_VWSGRCREDITOBANCARIO(
	concreditobancario NUMERIC(10,0) NOT NULL,
	codcontabilidad NUMERIC(2,0) NOT NULL,
	codue NUMERIC(4,0) NOT NULL,
	conmoneda NUMERIC(3,0) NOT NULL,
	codproducto NUMERIC(2,0) NOT NULL,
	numoperacion NUMERIC(7,0) NOT NULL,
	indrequierepoliza NUMERIC(1,0) NULL,
	concreditobancarioprincipal NUMERIC(10,0) NOT NULL,
	estcreditobancario VARCHAR(3) NOT NULL,
	coccreditobancario VARCHAR(55) NULL,
	fecconstitucion DATETIME NULL,
	mtoprincipal NUMERIC(16,2) NULL,
	Es_Giro BIT NOT NULL,
	Consecutivo_Contrato BIGINT NOT NULL,
	Fecha_Replica DATETIME NULL,
	Registro_Activo BIT NULL 
) ON [PRIMARY]

GO 

CREATE TABLE dbo.TMP_GIROS_CONTRATOS(
	Consecutivo_Giro BIGINT NOT NULL,
	Contabilidad_Giro TINYINT NOT NULL,
	Oficina_Giro SMALLINT NOT NULL,
	Moneda_Giro TINYINT NOT NULL,
	Producto_Giro TINYINT NOT NULL,
	Numero_Giro DECIMAL(7, 0) NOT NULL,
	Consecutivo_Contrato BIGINT NOT NULL,
	Contabilidad_Contrato TINYINT NOT NULL,
	Oficina_Contrato SMALLINT NOT NULL,
	Moneda_Contrato TINYINT NOT NULL,
	Producto_Contrato TINYINT NOT NULL,
	Numero_Contrato DECIMAL(7, 0) NOT NULL,
	Fecha_Pagado_Hasta DATETIME NULL,
	Codigo_SAP NUMERIC(8,0) NULL,
	Fecha_Vencimiento_Poliza DATETIME NULL,
	Usuario VARCHAR(30) NOT NULL,
	Fecha_Replica DATETIME NOT NULL,
	Registro_Activo BIT NOT NULL 
) ON [PRIMARY]

GO

CREATE TABLE dbo.GAR_COBERTURAS
(
	Codigo_Tipo_Cobertura  numeric(3,0)  NOT NULL ,
	Codigo_Cobertura      numeric(2,0)  NOT NULL ,
	Codigo_Tipo_Poliza    numeric(3,0)  NOT NULL ,
	Codigo_Clase_Poliza   numeric(3,0)  NOT NULL ,
	Codigo_Grupo_Poliza   varchar(1)  NOT NULL ,
	Codigo_Moneda_Tipo_Poliza  numeric(3,0)  NULL ,
	Codigo_Aseguradora    tinyint  NOT NULL ,
	Descripcion_Cobertura  varchar(250)  NOT NULL ,
	Descripcion_Corta_Cobertura  varchar(12)  NOT NULL ,
	Indicador_Obligatoria  numeric(1,0)  NOT NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar�  la informaci�n de las coberturas y los tipos de p�lizas, extra�da del SAP.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Tipo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n de la cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Descripcion_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n corta de la cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Descripcion_Corta_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si la cobertura es obligatoria o no.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Indicador_Obligatoria'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del Tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase de p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Clase_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del grupo de la p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Grupo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la aseguradora.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Aseguradora'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda asignada al tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS', 'column' , 'Codigo_Moneda_Tipo_Poliza'
GO


CREATE TABLE dbo.GAR_COBERTURAS_POLIZAS
(
	Codigo_SAP            numeric(8)  NOT NULL ,
	cod_operacion         bigint  NOT NULL ,
	Codigo_Tipo_Cobertura  numeric(3,0)  NOT NULL ,
	Codigo_Cobertura      numeric(2,0)  NOT NULL ,
	Codigo_Tipo_Poliza    numeric(3,0)  NOT NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar�  la informaci�n de las coberturas asociadas a las p�lizas, extra�da del SAP.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS', 'column' , 'Codigo_Tipo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la cobertura.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS', 'column' , 'Codigo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza a nivel del SAP.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n a la cual est� asociada la p�liza y que se encuentra registrada en el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS', 'column' , 'cod_operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del Tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'GAR_COBERTURAS_POLIZAS', 'column' , 'Codigo_Tipo_Poliza'
GO

CREATE TABLE dbo.TMP_SAP_COBERTURAS_POLIZAS
(
	Codigo_SAP            numeric(8,0)  NOT NULL ,
	Codigo_Cobertura      numeric(2,0)  NULL ,
	Codigo_Tipo_Cobertura  numeric(3,0)  NOT NULL ,
	Descripcion_Corta_Cobertura  varchar(12)  NULL ,
	Fecha_Ingreso datetime NULL,
	Fecha_Modificacion datetime NULL,
    Fecha_Replica         datetime  NOT NULL 
	CONSTRAINT DF_TMP_SAP_COBERTURAS_POLIZAS_FEcha_Replica
		 DEFAULT  GETDATE() ,
	Registro_Activo       bit  NOT NULL 
	CONSTRAINT DF_TMP_SAP_COBERTURAS_POLIZAS_Registro_Activo
		 DEFAULT  1 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� de forma temporal e hist�rica la informaci�n de las coberturas asociadas a las p�lizas, extra�das del SAP.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Codigo_Tipo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue replicado.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Fecha_Replica'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el registro est� activo (1) para ser procesado o no (0).' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Registro_Activo'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Codigo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n corta de la cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_COBERTURAS_POLIZAS', 'column' , 'Descripcion_Corta_Cobertura'
GO



CREATE TABLE dbo.TMP_SAP_SGRCOBERTURAS
(
	Codigo_Tipo_Cobertura  numeric(3,0)  NOT NULL ,
	Codigo_Cobertura      numeric(2,0)  NOT NULL ,
	Descripcion_Cobertura  varchar(250)  NOT NULL ,
	Descripcion_Corta_Cobertura  varchar(12)  NOT NULL ,
	Indicador_Obligatoria  numeric(1,0)  NOT NULL ,
	Usuario_Ingreso  VARCHAR(35)  NULL,
	Fecha_Ingreso	DATETIME NULL,
    Usuario_Modifico VARCHAR(35) NULL,
    Fecha_Modificacion DATETIME NULL,
	Fecha_Replica         datetime  NOT NULL 
	CONSTRAINT DF_TMP_SAP_SGRCOBERTURAS_Fecha_Replica
		 DEFAULT  GETDATE() ,
	Registro_Activo       bit  NOT NULL 
	CONSTRAINT DF_TMP_SAP_SGRCOBERTURAS_Registro_Activo
		 DEFAULT  1
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� de forma temporal e hist�rica la informaci�n de las coberturas extra�da del SAP.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Codigo_Tipo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Codigo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n de la cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Descripcion_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n corta de la cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Descripcion_Corta_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si la cobertura es obligatoria o no.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Indicador_Obligatoria'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue replicado.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Fecha_Replica'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el registro est� activo (1) para ser procesado o no (0).' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRCOBERTURAS', 'column' , 'Registro_Activo'
GO



CREATE TABLE dbo.TMP_SAP_SGRTIPOS_POLIZA
(
	Codigo_Tipo_Cobertura  numeric(3,0)  NOT NULL ,
	Codigo_Tipo_Poliza    numeric(3,0)  NOT NULL ,
	Codigo_Clase_Poliza   numeric(3,0)  NOT NULL ,
	Codigo_Grupo_Poliza   varchar(1)  NOT NULL ,
	Codigo_Aseguradora    tinyint  NOT NULL ,
	Codigo_Moneda         numeric(3,0)  NULL ,
	Descripcion_Tipo_Poliza  varchar(60)  NOT NULL ,
	Usuario_Ingreso  VARCHAR(35)  NULL,
	Fecha_Ingreso	DATETIME NULL,
    Usuario_Modifico VARCHAR(35) NULL,
    Fecha_Modificacion DATETIME NULL,
	Fecha_Replica         datetime  NOT NULL 
	CONSTRAINT DF_TMP_SAP_SGRTIPOS_POLIZA_Fecha_Replica
		 DEFAULT  GETDATE() ,
	Registro_Activo       bit  NOT NULL 
	CONSTRAINT DF_TMP_SAP_SGRTIPOS_POLIZA_Registro_Activo
		 DEFAULT  1
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� de forma temporal e hist�rica la informaci�n de los tipos de p�liza extra�da del SAP.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de cobertura.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Tipo_Cobertura'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n del tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Descripcion_Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue replicado.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Fecha_Replica'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el registro est� activo (1) para ser procesado o no (0).' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Registro_Activo'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del Tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la clase de p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Clase_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del grupo de la p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Grupo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la aseguradora.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Aseguradora'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda asignado al tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'TMP_SAP_SGRTIPOS_POLIZA', 'column' , 'Codigo_Moneda'
GO


CREATE TABLE dbo.SAP_VWSGRPOLIZA_HST(
	conpoliza NUMERIC(8, 0) NULL,
	cocpolizains VARCHAR(30) NULL,
	cocnumeropoliza VARCHAR(30) NULL,
	concliente NUMERIC(7, 0)  NULL,
	indcolectiva NUMERIC(1, 0)  NULL,
	cocgrupopoliza VARCHAR(1) NULL,
	cocpolizasola VARCHAR(30) NULL,
	conclasepoliza NUMERIC(3,0) NOT NULL,
	contipopoliza NUMERIC(3, 0) NULL,
	cocsimbologia VARCHAR(4) NULL,
	indnumanterior NUMERIC(1, 0) NULL,
	nummodulo NUMERIC(3, 0) NULL,
	numsucursal NUMERIC(3, 0) NULL,
	conregion NUMERIC(2, 0) NULL,
	conagencia NUMERIC(4, 0) NULL,
	conagente NUMERIC(4, 0) NULL,
	conformapago NUMERIC(3, 0) NULL,
	conperiodicidadpoliza NUMERIC(2, 0) NULL,
	concanalizacioncobro NUMERIC(3, 0)  NULL,
	conmotivocancela NUMERIC(3, 0) NULL,
	fecemision DATETIME NULL,
	fecvigencia DATETIME NULL,
	fecvence DATETIME NULL,
	feccancelacion DATETIME NULL,
	fecproximopago DATETIME NULL,
	mtoasegurado NUMERIC(16, 2) NULL,
	mtoprimatotal NUMERIC(16, 2) NULL,
	mtoultimopago NUMERIC(16, 2) NULL,
	mtodeducible NUMERIC(10, 2) NULL,
	mtopagoperiodico NUMERIC(16,4) NULL,
	usrcancelo VARCHAR(35) NULL,
	memobservacion VARCHAR(250) NULL,
	desubicacionbien VARCHAR(250) NULL,
	desdetallebien VARCHAR(250) NULL,
	indexterna NUMERIC(1, 0) NULL,
	estpoliza VARCHAR(3)  NULL,
	codsenal NUMERIC(2, 0) NULL,
	conpolizamadre NUMERIC(8, 0) NULL,
	mtoprima NUMERIC(16, 2) NULL,
	concreditobancarioprincipal NUMERIC(10, 0) NULL,
	nummespoliza NUMERIC(2, 0) NULL,
	indrevisada NUMERIC(1, 0)  NULL,
	descoberturasasociadas VARCHAR(60) NULL,
	cocformacobropoliza VARCHAR(5) NULL,
	cocintencionalidad VARCHAR(20) NULL,
	desclasepoliza VARCHAR(60) NULL,
	destipopoliza VARCHAR(60) NULL,
	conmoneda NUMERIC(3, 0) NULL,
	indcobraimpuestorenta NUMERIC(1, 0) NULL, 
	nommoneda VARCHAR(30) NULL,
	monsigno VARCHAR(5) NULL,
	desformapago VARCHAR(60) NULL,
	nummeses NUMERIC(3, 0) NULL,
	dessiglas VARCHAR(30) NULL,
	contipocobertura NUMERIC(3, 0) NULL,
	codtiposiic VARCHAR(2) NULL,
	indesdesempleo NUMERIC(1, 0) NULL, 
	desunidadejecutora VARCHAR(60) NULL,
	cocpolizasicc VARCHAR(15) NULL,
	concanalventa SMALLINT NULL,
	cocestadopoliza VARCHAR(3) NULL,
	feccambioestadopoliza DATETIME NULL,
	conaseguradora TINYINT NULL,
	nomaseguradora VARCHAR(60) NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de las p�lizas de la tabla TMP_SAP_VWSGRPOLIZA.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRPOLIZA_HST'
GO


CREATE TABLE dbo.SAP_VWSGRPOLIZACREDITOBANCARIO_HST(
	conpoliza NUMERIC(8, 0) NOT NULL,
	concreditobancario NUMERIC(10, 0) NOT NULL,
	codsenalcredito NUMERIC(2, 0) NOT NULL,
	cocfrecuenciacobrosicc VARCHAR(1)  NULL,
	indcodeudor NUMERIC(1, 0) NOT NULL,
	estpolizacreditobancario VARCHAR(3) NOT NULL,
	feccancelacioncredito DATETIME NULL,
	fecatraso DATETIME NULL,
	fecpagadohasta DATETIME NULL,
	fecvencecredito DATETIME NULL,
	indprimadevuelta NUMERIC(1, 0) NOT NULL,
	fecdevolucionprima DATETIME NULL,
	usrdevolvioprima VARCHAR(35) NULL,
	codcontabilidad NUMERIC(2, 0) NOT NULL,
	codue NUMERIC(4, 0) NOT NULL,
	conmoneda NUMERIC(3, 0) NOT NULL,
	codproducto NUMERIC(2, 0) NOT NULL,
	numoperacion NUMERIC(7, 0) NOT NULL,
	concontratocredito NUMERIC(10, 0) NULL,
	estcreditobancario VARCHAR(3) NOT NULL,
	coccreditobancario VARCHAR(55) NULL,
	Es_Giro BIT NOT NULL,
	Consecutivo_Contrato BIGINT NOT NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_VWSGRPOLIZACREDITOBANCARIO.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRPOLIZACREDITOBANCARIO_HST'
GO

CREATE TABLE dbo.SAP_VWSGRPOLIZACONTRATOCREDITO_HST(
	conpoliza NUMERIC(8, 0) NOT NULL,
	concontratocredito NUMERIC(10, 0)  NOT NULL,
	estpolizacontratocredito VARCHAR(3)  NOT NULL,
	feccancelacioncontrato DATETIME NULL,
	fecpagadohasta DATETIME NULL,
	codsenal NUMERIC(2, 0)  NULL,
	cocfrecuenciacobrosicc VARCHAR(1)  NULL,
	fecvencecredito DATETIME NULL,
	codue NUMERIC(4, 0)  NOT NULL,
	codcontabilidad NUMERIC(2, 0)  NOT NULL,
	conmoneda NUMERIC(3, 0)  NOT NULL,
	coccontratocredito VARCHAR(10) NOT NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_VWSGRPOLIZACONTRATOCREDITO.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRPOLIZACONTRATOCREDITO_HST'
GO


CREATE TABLE dbo.SAP_POLIZASEXTERNAS_HST(
	conpoliza NUMERIC(8, 0) NOT NULL,
	Fecha_Replica DATETIME NULL
) ON [PRIMARY]

GO

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_POLIZASEXTERNAS.' , 'user' , 'dbo' , 'table' , 'SAP_POLIZASEXTERNAS_HST'
GO


CREATE TABLE dbo.SAP_VWSGRPOLIZAAUTO_HST(
	conpoliza NUMERIC(8, 0) NOT NULL,
	cocplaca VARCHAR(15) NOT NULL,
	conestiloauto NUMERIC(3,0) NULL,
	conmarcaauto NUMERIC(3,0) NULL,
	contipocombustion NUMERIC(2,0) NOT NULL,
	desmodelo VARCHAR(35) NULL,
	descolor VARCHAR(20) NULL,
	numpeso NUMERIC(9,2) NULL,
	numcubicaje NUMERIC(4,0) NULL,
	numcapacidad NUMERIC(3,0) NULL,
	numcilindros NUMERIC(2,0) NULL,
	desnumeromotor VARCHAR(20) NULL,
	desnumerochasis VARCHAR(20) NOT NULL,
	mtovalorauto NUMERIC(16,2) NULL,
	porrecargobonificacion NUMERIC(7,4) NULL,
	contipovehiculo NUMERIC(6,0) NULL,
	desestadobien VARCHAR(3000) NULL,
	numanoauto NUMERIC(4,0) NULL,
	tipmodalidadaseguramiento NUMERIC(10,0) NULL,
	codestilocarroceria NUMERIC(2,0) NULL,
	indplacatemporal TINYINT NOT NULL,
	concliente NUMERIC(7,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	mtoasegurado NUMERIC(16,2) NULL,
	contipopoliza NUMERIC(3,0) NULL,
	desestiloauto VARCHAR(60) NULL,
	desmarcaauto VARCHAR(60) NULL,
	mtoprimatotal NUMERIC(16,2) NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	desestilocarroceria VARCHAR(60) NOT NULL,
	destipovehiculo VARCHAR(80) NOT NULL,
	destipocombustion VARCHAR(60) NOT NULL,
	desmodalidadaseguramiento VARCHAR(11) NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_VWSGRPOLIZAAUTO.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRPOLIZAAUTO_HST'
GO


CREATE TABLE dbo.SAP_SGRPOLIZAOTRO_HST(
	conpoliza NUMERIC(8,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	concliente NUMERIC(7,0) NOT NULL,
	contipopoliza NUMERIC(3, 0) NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	mtoasegurado NUMERIC(16, 2) NULL,
	mtoprimatotal NUMERIC(16, 2) NULL,
	desobservacion VARCHAR(1500) NULL,
	cocplaca VARCHAR(15) NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO 

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_SGRPOLIZAOTRO.' , 'user' , 'dbo' , 'table' , 'SAP_SGRPOLIZAOTRO_HST'
GO


CREATE TABLE dbo.SAP_SGRPOLIZAPATRIMONIAL_HST(
	concliente NUMERIC(7,0) NOT NULL,
	cocpolizains VARCHAR(30) NULL,
	mtoaseguradototal NUMERIC(16,2) NULL,
	mtoprimatotal NUMERIC(16,2) NULL,
	contipopoliza NUMERIC(3,0) NULL,
	conpoliza NUMERIC(8,0) NOT NULL,
	conzonariesgo SMALLINT NOT NULL,
	conprovincia NUMERIC(1,0) NULL,
	concanton NUMERIC(2,0) NULL,
	condistrito NUMERIC(2,0) NULL,
	desnumerofinca VARCHAR(20) NULL,
	mtoasegurado NUMERIC(16,2) NULL,
	porparticipacion NUMERIC(7,4) NULL,
	pordeducible NUMERIC(7,4) NULL,
	mtodeduccibleminimo NUMERIC(16,2) NULL,
	memobservacion VARCHAR(200) NULL,
	desocupacion VARCHAR(20) NULL,
	cococupacionrobo VARCHAR(3) NULL,
	codclasetarifaria NUMERIC(2,0) NULL,
	codrecargoprr NUMERIC(3,0) NULL,
	conclaseconstruccion NUMERIC(8,0) NULL,
	conporcentajepci NUMERIC(2,0) NULL,
	contipocomercio NUMERIC(8,0) NULL,
	desdireccioninmuble VARCHAR(250) NULL,
	desfolioreal VARCHAR(20) NULL,
	mtoconstruccion NUMERIC(16,4) NULL,
	mtogarantia NUMERIC(16,4) NULL,
	numgradohipoteca NUMERIC(2,0) NULL,
	numpisos NUMERIC(3,0) NULL,
	portarifa NUMERIC(7,4) NULL,
	portarifab NUMERIC(7,4) NULL,
	mtovalorterreno NUMERIC(16,4) NULL,
	mtoaseguradomenaje NUMERIC(16,4) NULL,
	codparticipacionasegurado TINYINT NULL,
	concreditobancario NUMERIC(10,0) NULL,
	mtoprimaparcial NUMERIC(16,2) NOT NULL,
	tiptramiteregistro TINYINT NOT NULL,
	mtoprimaparcialsicc NUMERIC(10,2) NOT NULL,
	cochorizontal CHAR(1) NULL,
	desprovincia VARCHAR(35) NOT NULL,
	descanton VARCHAR(45) NOT NULL,
	desdistrito VARCHAR(45) NOT NULL,
	destipopoliza VARCHAR(60) NOT NULL,
	Fecha_Replica DATETIME NULL,
	usringreso  VARCHAR(35)  NULL,
	fecingreso	DATETIME NULL,
    usrmodifico VARCHAR(35) NULL,
    fecmodificacion DATETIME NULL
) ON [PRIMARY]

GO 

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_SGRPOLIZAPATRIMONIAL.' , 'user' , 'dbo' , 'table' , 'SAP_SGRPOLIZAPATRIMONIAL_HST'
GO


CREATE TABLE dbo.SAP_VWSGRCONTRATOCREDITO_HST(
	concontratocredito NUMERIC(10,0) NOT NULL,
	codcontabilidad NUMERIC(2,0) NOT NULL,
	codue NUMERIC(4,0) NOT NULL,
	conmoneda NUMERIC(3,0) NOT NULL,
	coccontratocredito VARCHAR(10) NOT NULL,
	coccontratocreditolargo VARCHAR(55) NULL,
	Fecha_Replica DATETIME NULL
) ON [PRIMARY]

GO 

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_VWSGRCONTRATOCREDITO.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRCONTRATOCREDITO_HST'
GO


CREATE TABLE dbo.SAP_VWSGRCREDITOBANCARIO_HST(
	concreditobancario NUMERIC(10,0) NOT NULL,
	codcontabilidad NUMERIC(2,0) NOT NULL,
	codue NUMERIC(4,0) NOT NULL,
	conmoneda NUMERIC(3,0) NOT NULL,
	codproducto NUMERIC(2,0) NOT NULL,
	numoperacion NUMERIC(7,0) NOT NULL,
	indrequierepoliza NUMERIC(1,0) NULL,
	concreditobancarioprincipal NUMERIC(10,0) NOT NULL,
	estcreditobancario VARCHAR(3) NOT NULL,
	coccreditobancario VARCHAR(55) NULL,
	fecconstitucion DATETIME NULL,
	mtoprincipal NUMERIC(16,2) NULL,
	Es_Giro BIT NOT NULL,
	Consecutivo_Contrato BIGINT NOT NULL,
	Fecha_Replica DATETIME NULL
) ON [PRIMARY]

GO 

EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenar� el hist�rico de la informaci�n de la tabla TMP_SAP_VWSGRCREDITOBANCARIO.' , 'user' , 'dbo' , 'table' , 'SAP_VWSGRCREDITOBANCARIO_HST'
GO


CREATE TABLE dbo.POLIZAS_HST
(
	Codigo_SAP            numeric(8,0)  NOT NULL ,
	Tipo_Poliza           numeric(3,0)  NOT NULL ,
	Codigo_Oficina_Operacion  numeric(4,0)  NOT NULL ,
	Codigo_Moneda_Operacion  numeric(3,0)  NOT NULL ,
	Codigo_Producto_Operacion  numeric(2,0)  NOT NULL ,
	Numero_Operacion      numeric(7,0)  NOT NULL ,
	Numero_Contrato       varchar(10)  NOT NULL ,
	Consecutivo_Operacion_Garantias  bigint  NOT NULL,
	Monto_Poliza          numeric(16,2)  NOT NULL ,
	Moneda_Monto_Poliza   numeric(3,0)  NOT NULL ,
	Estado_Poliza         char(3)  NOT NULL ,
	Simbolo_Moneda        char(5)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL ,
	Fecha_Vencimiento     datetime  NULL ,
	Descripcion_Moneda_Monto_Poliza  varchar(30)  COLLATE SQL_Latin1_General_CP850_CS_AS NOT NULL ,
	Detalle_Poliza        varchar(250)  COLLATE SQL_Latin1_General_CP850_CS_AS NULL,
	Fecha_Replica datetime NULL,
	Indicador_Poliza_Externa bit NULL,
	Codigo_Partido numeric(1, 0) NULL,
	Identificacion_Bien varchar(25) NULL,
	Codigo_Tipo_Cobertura numeric(3, 0) NULL,
	Codigo_Aseguradora tinyint NULL
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena el hist�rico de la informaci�n de las p�lizas registradas en la tabla TMP_POLIZAS.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la p�liza dentro del sistema de p�lizas (SAP).' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del tipo de p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto asegurado.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripci�n del c�digo de la moneda del monto de la p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Descripcion_Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'S�mbolo asignado a la moneda del monto del a p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Simbolo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento de la p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Fecha_Vencimiento'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Observaciones que puede poseer la p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Detalle_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del estado de la p�liza.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Estado_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la moneda de la operaci�n o contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Codigo_Moneda_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo de la oficina de la operaci�n o contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Codigo_Oficina_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'C�digo del producto de la operaci�n, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Codigo_Producto_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero de la operaci�n, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Numero_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'N�mero del contrato, dentro del sistema de p�lizas.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Numero_Contrato'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operaci�n, registrada en el sistema de garant�as.' , 'user' , 'dbo' , 'table' , 'POLIZAS_HST', 'column' , 'Consecutivo_Operacion_Garantias'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que el registro fue replicado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Fecha_Replica'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si la p�liza es externa (1) o no (0).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Indicador_Poliza_Externa'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'C�digo del partido.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Codigo_Partido'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Identificaci�n del bien.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Identificacion_Bien'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'C�digo del tipo de cobertura.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Codigo_Tipo_Cobertura'
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'C�digo de la aseguradora.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POLIZAS_HST', @level2type=N'COLUMN',@level2name=N'Codigo_Aseguradora'
GO


CREATE TABLE dbo.GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD
( 
	Consecutivo_Operacion bigint  NOT NULL ,
	Consecutivo_Garantia bigint  NOT NULL ,
	Codigo_Tipo_Garantia smallint  NOT NULL ,
	Saldo_Actual_Ajustado decimal(18,2)  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Saldo_Actual_Ajustado
		 DEFAULT  -1,
	Porcentaje_Responsabilidad_Ajustado decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Porcentaje_Responsabilidad_Ajustado
		 DEFAULT  -1,
	Porcentaje_Responsabilidad_Calculado decimal(5,2)  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Porcentaje_Responsabilidad_Calculado
		 DEFAULT  -1,
	Indicador_Excluido   bit  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Indicador_Exlcuido
		 DEFAULT  0,
	Indicador_Ajuste_Saldo_Actual bit  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Indicador_Ajuste_Saldo_Actual
		 DEFAULT  0,
	Indicador_Ajuste_Porcentaje bit  NOT NULL 
	CONSTRAINT DF_GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD_Indicador_Ajuste_Porcentaje
		 DEFAULT  0,
	Usuario_Inserto      varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
	Usuario_Modifico     varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
	Usuario_Elimino      varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
	Fecha_Inserto        datetime  NULL ,
	Fecha_Modifico       datetime  NULL ,
	Fecha_Elimino        datetime  NULL ,
	Fecha_Replica        datetime  NULL 
)
GO


EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Esta tabla almacenar� los registros de aquellas operaciones y garant�as que participan en la distribuci�n del porcentaje de responsabilidad.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el consecutivo de la operaci�n, contrato o giro de contrato.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Consecutivo_Operacion'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el consecutivo de la garant�a.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Consecutivo_Garantia'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el c�digo del tipo de garant�a, donde:
  1: Garant�a Fiduciaria.
  2: Garant�a Real.
  3: Garant�a Valor.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Codigo_Tipo_Garantia'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el saldo actual ingresado por el usuario.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Saldo_Actual_Ajustado'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el porcentaje de responsabilidad definido por el usuario.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Responsabilidad_Ajustado'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el porcentaje de responsabilidad calculado por el sistema.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Porcentaje_Responsabilidad_Calculado'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador de si el registro fue eliminado por el usuario, donde:

0: El registro no ha sido excluido.
1: El registro fue excluido.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Indicador_Excluido'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador de si el saldo actual fue ingresado por el usuario, donde:

0: El saldo no ha sido ajustado.
1: El saldo fue ajustado.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Indicador_Ajuste_Saldo_Actual'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Almacenar� el indicador de si el porcentaje de responsabilidad fue ingresado por el usuario, donde:

0: El porcentaje no ha sido ajustado.
1: El porcentaje fue ajustado.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Indicador_Ajuste_Porcentaje'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Identificaci�n del usuario que realiz� la inclusi�n de un registro excluido.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Usuario_Inserto'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Identificaci�n del usuario que realiz� la �ltima modificaci�n.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Usuario_Modifico'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Identificaci�n del usuario que elimin� el registro.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Usuario_Elimino'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Fecha en que se insert� el registro.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Fecha_Inserto'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Fecha en que se realiz� la �ltima modificaci�n.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Fecha_Modifico'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Fecha en que se elimin� el registro.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Fecha_Elimino'
GO

EXEC sp_addextendedproperty
@name = N'MS_Description', @value = N'Fecha en que el registro fue ajustado por alg�n proceso de r�plica.',
@level0type = N'SCHEMA', @level0name = N'dbo',
@level1type = N'TABLE', @level1name = N'GAR_SALDOS_TOTALES_PORCENTAJES_RESPONSABILIDAD',
@level2type = N'COLUMN', @level2name = N'Fecha_Replica'
GO

