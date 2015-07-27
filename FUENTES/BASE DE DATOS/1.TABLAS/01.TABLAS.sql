
CREATE TABLE dbo.BCR_OFICINAS
(
	COD_OFICINA           int  NOT NULL ,
	DES_OFICINA           varchar(100)  NOT NULL ,
	COD_OFICINA_ASIGNADA  int  NULL ,
	COD_INDICADOR         tinyint  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.CAT_CATALOGO
(
	cat_catalogo          int  IDENTITY (1,1) ,
	cat_descripcion       varchar(100)  NOT NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.CAT_ELEMENTO
(
	cat_elemento          int  IDENTITY (1,1) ,
	cat_catalogo          int  NOT NULL ,
	cat_campo             varchar(5)  NOT NULL ,
	cat_descripcion       varchar(150)  NOT NULL 
)
 ON "PRIMARY"
go



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
go



exec sp_addextendedproperty 'MS_Description' , 'Esta tabla almacenará los índices que serán utilizados para el cáculo de los montos de las tasaciones actualizadas del terreno y no terreno.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO'
go



exec sp_addextendedproperty 'MS_Description' , 'Este campo permitirá almacenar la fecha y hora en que se produjo el registro de la información.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Fecha_Hora'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el tipo de cambio del día.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Tipo_Cambio'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el índice de precios al consumidor.' , 'user' , 'dbo' , 'table' , 'CAT_INDICES_ACTUALIZACION_AVALUO', 'column' , 'Indice_Precios_Consumidor'
go



CREATE TABLE dbo.CAT_INSTRUMENTOS
(
	cod_instrumento       varchar(25)  NOT NULL ,
	des_instrumento       varchar(150)  NOT NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.CAT_ISIN
(
	cod_isin              varchar(25)  NOT NULL 
)
 ON "PRIMARY"
go



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
go



CREATE TABLE dbo.GAR_CAPACIDAD_PAGO
(
	cedula_deudor         varchar(30)  NOT NULL ,
	fecha_capacidad_pago  datetime  NOT NULL ,
	cod_capacidad_pago    smallint  NULL ,
	sensibilidad_tipo_cambio  decimal(5,2)  NULL 
)
 ON "PRIMARY"
go



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
go

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenará la identificación del deudor registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_DEUDOR', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO


CREATE TABLE dbo.GAR_EJECUCION_PROCESO
(
	conEjecucionProceso   int  IDENTITY (1,1) ,
	cocProceso            varchar(20)  NOT NULL ,
	fecEjecucion          datetime  NOT NULL 
)
 ON "PRIMARY"
go



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
go



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
go



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
go

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenará la identificación del fiador registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_FIDUCIARIA', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_FIDUCIARIA', 'column' , 'Fecha_Replica'
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

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenará la identificación alfanumérica del bien registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_REAL', @level2type=N'COLUMN',@level2name=N'Identificacion_Alfanumerica_Sicc'
GO

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenará la identificación del bien registrado en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_REAL', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_REAL', 'column' , 'Fecha_Replica'
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
go

EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'Este campo alamacenará la identificación de la seguridad registrada en el SICC.' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GAR_GARANTIA_VALOR', @level2type=N'COLUMN',@level2name=N'Identificacion_Sicc'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIA_VALOR', 'column' , 'Fecha_Replica'
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
	Fecha_Replica DATETIME NULL	  
)
 ON "PRIMARY"
go

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION', 'column' , 'Fecha_Replica'
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
	Fecha_Replica DATETIME NULL	  
)
 ON "PRIMARY"
go

exec sp_addextendedproperty 'MS_Description' , 'Este campo alamacenará la fecha del avalúo registrada en el SICC.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Valuacion_SICC'
go

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Replica'
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
	Fecha_Replica DATETIME NULL	  
)
 ON "PRIMARY"
go

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_GARANTIAS_VALOR_X_OPERACION', 'column' , 'Fecha_Replica'
GO

CREATE TABLE dbo.GAR_GARANTIAS_X_GIRO
(
	cod_operacion_giro    bigint  NOT NULL ,
	cod_operacion         bigint  NOT NULL ,
	cod_garantia          bigint  NOT NULL ,
	cod_tipo_garantia     smallint  NOT NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.GAR_GARANTIAS_x_PERFIL_X_TARJETA
(
	cod_tarjeta           int  NOT NULL ,
	observaciones         varchar(250)  NOT NULL 
)
 ON "PRIMARY"
go



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
	cod_estado_tarjeta    varchar(1)  NULL 
)
 ON "PRIMARY"
go



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
		 DEFAULT  newid() 
)
 ON "PRIMARY"
go



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
	oficina_deudor        smallint  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.GAR_MIG_DEUDORES
(
	cedula_deudor         varchar(30)  NULL ,
	DeudorCodeudor_cod_iddeudor  varchar(30)  NULL 
)
 ON "PRIMARY"
go



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
	cod_oficon            smallint  NULL 
)
 ON "PRIMARY"
go



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
go



CREATE TABLE dbo.GAR_PROCESO
(
	cocProceso            varchar(20)  NOT NULL ,
	desProceso            varchar(60)  NOT NULL 
)
 ON "PRIMARY"
go



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
go



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
go



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
go



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
go



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
go



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
go



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
go



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
go



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
go
EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la inserción del registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_FIADOR', 'column' , 'Usuario_Inserto'
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
	Fecha_Replica DATETIME NULL	  
)
 ON "PRIMARY"
go



exec sp_addextendedproperty 'MS_Description' , 'Indica el tipo de fecha según la siguiente clasificación:
0: El registro es parte del histórico. Este es el valor por defecto del registro.
1: El registro corresponde al avalúo más reciente.
2: El registro corresponde al penúltimo avalúo.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Indicador_Tipo_Registro'
go


exec sp_addextendedproperty 'MS_Description' , 'Indica si el monto de la tasación actualizada del no terreno fue actualizado por el proceso del cálculo. 
Tiene sentido si el valor del campo "Indicador_Tipo_Registro" tiene el valor 1 (uno). Los posibles valores son:
0: No fue actualizado. Este es el v' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Indicador_Actualizado_Calculo'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo alamacenará la fecha del semestre calculado.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Semestre_Calculado'
go

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue ajustado por algún proceso de réplica.' , 'user' , 'dbo' , 'table' , 'GAR_VALUACIONES_REALES', 'column' , 'Fecha_Replica'
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
go



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
go



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
go



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
go



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
go



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
go



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
go



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
go



CREATE TABLE dbo.SEG_PERFIL
(
	COD_PERFIL            int  IDENTITY (1,1) ,
	DES_PERFIL            varchar(100)  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.SEG_ROL
(
	COD_ROL               int  NOT NULL ,
	DES_ROL               varchar(100)  NULL ,
	NOMBRE                varchar(100)  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.SEG_ROLES_X_PERFIL
(
	COD_PERFIL            int  NOT NULL ,
	COD_ROL               int  NOT NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.SEG_USUARIO
(
	COD_USUARIO           varchar(30)  NOT NULL ,
	DES_USUARIO           varchar(100)  NULL ,
	COD_PERFIL            int  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.TAR_BIN_SISTAR
(
	bin                   numeric(16)  NOT NULL ,
	fecingreso            datetime  NOT NULL 
	CONSTRAINT DF__TAR_BIN_S__fecin__723D9313
		 DEFAULT  CURRENT_TIMESTAMP 
)
 ON "PRIMARY"
go



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
go



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
	des_observacion       varchar(150)  NULL 
)
 ON "PRIMARY"
go



CREATE TABLE dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA
(
	cod_tarjeta           int  NOT NULL ,
	observaciones         varchar(250)  NOT NULL 
)
 ON "PRIMARY"
go



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
go



exec sp_addextendedproperty 'MS_Description' , 'Codigo del tipo de garantía que le ha sido asignada' , 'user' , 'dbo' , 'table' , 'TAR_TARJETA', 'column' , 'cod_tipo_garantia'
go



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
go



CREATE TABLE dbo.TAR_TARJETA_SISTAR
(
	cedula                varchar(12)  NULL ,
	tarjeta               varchar(16)  NULL ,
	bin                   int  NULL ,
	codigo_interno        int  NULL 
)
 ON "PRIMARY"
go



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
go



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
	Usuario               varchar(30)  NOT NULL 
)
 ON "PRIMARY"
go



exec sp_addextendedproperty 'MS_Description' , 'Esta tabla alamcenará, de forma temporal, los registros generados por el cálculo del monto de la tasación actualizada del terreno y no terreno. Cada registro corresponde a un semestre.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT'
go



exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará la fecha y hora en que se incluye el registro.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Fecha_Hora'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará la identificación de la garantía, según el tipo de garantía real:

i. Hipoteca Común: Partido-Finca.
ii. Cédula Hipotecaria: Partido-Finca.
iii. Prenda: Clase de bien-Placa.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Id_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el tipo de garantía real de la que se trata, a saber:

i. Hipoteca Común: 1.
ii. Cédula Hipotecaria: 2.
iii. Prenda: 3.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Garantia_Real'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el código de la clase de garantía.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Clase_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará la fecha correspondiente al semestre calculado.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Semestre_Calculado'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo alamcenará la fecha del avalúo calculado.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Fecha_Valuacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el monto de la última tasación del terreno.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Ultima_Tasacion_Terreno'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el monto de la última tasación del no terreno.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Ultima_Tasacion_No_Terreno'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el tipo de cambio usado para el cálculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Cambio'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el índice de precios al consumidor usado por el cálculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Indice_Precios_Consumidor'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el tipo de cambio usado para el cálculo del semestre anterior. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Cambio_Anterior'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el índice de precios al consumidor usado por el cálculo del semestre anterior. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Indice_Precios_Consumidor_Anterior'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el factor del tipo de cambio usado por el cálculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Factor_Tipo_Cambio'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el factor del índice de precios al consumidor usado por el cálculo. Se define el valor -1 como valor por defecto, este es el equivalente al valor nulo.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Factor_IPC'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo guardará el porcentaje de depreciación semestral usado por el cáclulo del monto.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Porcentaje_Depreciacion_Semestral'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el monto de la tasación actualizada del terrneo calculado, producto de la aplicación de la fórmula correspondiente.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Tasacion_Actualizada_Terreno'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el monto de la tasación actualizada del no terrneo calculado, producto de la aplicación de la fórmula correspondiente.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Monto_Tasacion_Actualizada_No_Terreno'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el número de registro, para una misma garantía y una misma operación.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Numero_Registro'
go


exec sp_addextendedproperty 'MS_Description' , 'Consecutivo asignado a la operación al cual esta asociada la garantía real cuya valuación será trabajada.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Codigo_Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Consecutivo asignado a la garantía real cuya valuación será trabajada.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Codigo_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará el tipo de bien asignado a la garantía.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Tipo_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Cantidad total de semestres que serán calculados.' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Total_Semestres_Calcular'
go


exec sp_addextendedproperty 'MS_Description' , 'Este campo almacenará la identificación del usuario que ejecuta el cálculo del monto. En el caso del proceso diario se asigna el valor "UsuarioBD".' , 'user' , 'dbo' , 'table' , 'TMP_CALCULO_MTAT_MTANT', 'column' , 'Usuario'
go



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
go



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
	cod_llave             bigint  IDENTITY (1,1) 
)
 ON "PRIMARY"
go



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
	cod_llave             bigint  IDENTITY (1,1) 
)
 ON "PRIMARY"
go



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
	Codigo_Usuario        varchar(30)  NOT NULL 
)
 ON "PRIMARY"
go



exec sp_addextendedproperty 'MS_Description' , 'Almacenará las garantías a ser filtradas durante el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES'
go



exec sp_addextendedproperty 'MS_Description' , 'Consecutivo llave del registro.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Llave'
go


exec sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operación.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Consecutivo de la garantía real.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Garantia_Real'
go


exec sp_addextendedproperty 'MS_Description' , 'Contabilidad de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Contabilidad'
go


exec sp_addextendedproperty 'MS_Description' , 'Oficina de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Oficina'
go


exec sp_addextendedproperty 'MS_Description' , 'Moneda de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Moneda'
go


exec sp_addextendedproperty 'MS_Description' , 'Producto de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Producto'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de operación o contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Mitigador'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de documento legal.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Documento_Legal'
go


exec sp_addextendedproperty 'MS_Description' , 'Indicador de inscripción.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Inscripcion'
go


exec sp_addextendedproperty 'MS_Description' , 'Tipo de garantía real, siendo los valores: 
1 = Hipoteca Común.
2 = Cédula Hipotecaria.
3 = Prenda.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Garantia_Real'
go


exec sp_addextendedproperty 'MS_Description' , 'Estado del registro, siendo los valores: 1 = Activo y 2 = Inactivo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Estado'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del grado de gravamen.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Grado_Gravamen'
go


exec sp_addextendedproperty 'MS_Description' , 'Código de la clase de garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Clase_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del partido donde se encuentra la finca. Aplica para Hipoteca Común y Cédula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Partido'
go


exec sp_addextendedproperty 'MS_Description' , 'Tipo de garantía, por defecto el valor es 2.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de operación, siendo los valores: 1 = Operación Directa, 2 = Contrato y 3 = Giro de Contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Tipo_Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Código que indica si el registro se encuentra duplicado. Los valores son: 1 = Unico y 2 = Duplicado.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Indicador_Duplicidad'
go


exec sp_addextendedproperty 'MS_Description' , 'Porcentaje de aceptación asignado a la garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Porcentaje_Responsabilidad'
go


exec sp_addextendedproperty 'MS_Description' , 'Monto del mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Monto_Mitigador'
go


exec sp_addextendedproperty 'MS_Description' , 'Grado de la cédula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Grado'
go


exec sp_addextendedproperty 'MS_Description' , 'Código de la clase del bien. Aplica sólo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Clase_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de cédula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Cedula_Hipotecaria'
go


exec sp_addextendedproperty 'MS_Description' , 'Identificación del bien.
Este campo se compondrá de la siguiente forma, según el tipo de garantía real:

a) Hipotecas comunes: Partido – Finca.
b) Cédulas Hipotecarias: Partido – Finca.
c) Prendas: clase de bien – placa del bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Fecha de presentación de la garantía ante el Registro de la Propiedad.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Fecha_Presentacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Fecha de constitución de la garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Fecha_Constitucion'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de la finca. Aplica para Hipoteca Común y Cédula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Numero_Finca'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de identificación del bien. Aplica sólo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Numero_Placa_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que ejecuta el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_OPERACIONES', 'column' , 'Codigo_Usuario'
go



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
	Codigo_Usuario        varchar(30)  NOT NULL 
)
 ON "PRIMARY"
go



exec sp_addextendedproperty 'MS_Description' , 'Almacenará las garantías que serán validadas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION'
go



exec sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operación.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Consecutivo de la garantía real.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Garantia_Real'
go


exec sp_addextendedproperty 'MS_Description' , 'Contabilidad de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Contabilidad'
go


exec sp_addextendedproperty 'MS_Description' , 'Oficina de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Oficina'
go


exec sp_addextendedproperty 'MS_Description' , 'Moneda de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Moneda'
go


exec sp_addextendedproperty 'MS_Description' , 'Producto de la operación, contrato o giro de contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Producto'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de operación o contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Mitigador'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de documento legal.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Documento_Legal'
go


exec sp_addextendedproperty 'MS_Description' , 'Indicador de inscripción.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Inscripcion'
go


exec sp_addextendedproperty 'MS_Description' , 'Tipo de garantía real, siendo los valores: 
1 = Hipoteca Común.
2 = Cédula Hipotecaria.
3 = Prenda.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Garantia_Real'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del grado de gravamen.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Grado_Gravamen'
go


exec sp_addextendedproperty 'MS_Description' , 'Código de la clase de garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Clase_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del partido donde se encuentra la finca. Aplica para Hipoteca Común y Cédula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Partido'
go


exec sp_addextendedproperty 'MS_Description' , 'Tipo de garantía, por defecto el valor es 2.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Garantia'
go


exec sp_addextendedproperty 'MS_Description' , 'Código del tipo de operación, siendo los valores: 1 = Operación Directa, 2 = Contrato y 3 = Giro de Contrato.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Tipo_Operacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Porcentaje de aceptación asignado a la garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Porcentaje_Responsabilidad'
go


exec sp_addextendedproperty 'MS_Description' , 'Monto del mitigador de riesgo.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Monto_Mitigador'
go


exec sp_addextendedproperty 'MS_Description' , 'Grado de la cédula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Grado'
go


exec sp_addextendedproperty 'MS_Description' , 'Código de la clase del bien. Aplica sólo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Clase_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de cédula hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Cedula_Hipotecaria'
go


exec sp_addextendedproperty 'MS_Description' , 'Identificación del bien.
Este campo se compondrá de la siguiente forma, según el tipo de garantía real:

a) Hipotecas comunes: Partido – Finca.
b) Cédulas Hipotecarias: Partido – Finca.
c) Prendas: clase de bien – placa del bien.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Fecha de constitución de la garantía.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Constitucion'
go


exec sp_addextendedproperty 'MS_Description' , 'Fecha de presentación de la garantía ante el Registro de la Propiedad.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Fecha_Presentacion'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de la finca. Aplica para Hipoteca Común y Cédula Hipotecaria.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Numero_Finca'
go


exec sp_addextendedproperty 'MS_Description' , 'Número de identificación del bien. Aplica sólo para Prendas.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Numero_Placa_Bien'
go


exec sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que ejecuta el proceso.' , 'user' , 'dbo' , 'table' , 'TMP_GARANTIAS_REALES_X_OPERACION', 'column' , 'Codigo_Usuario'
go



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
	cod_llave             bigint  IDENTITY (1,1) 
)
 ON "PRIMARY"
go



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
go



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
go



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
	cod_usuario           varchar(30)  NULL 
)
 ON "PRIMARY"
go

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

go

CREATE TABLE dbo.CAT_TIPOS_POLIZAS_SUGEF
(
	Codigo_Tipo_Poliza_Sugef  integer  NOT NULL ,
	Nombre_Tipo_Poliza    varchar(50)  NOT NULL ,
	Descripcion_Tipo_Poliza  varchar(500)  NULL 
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenará el catálogo de tipos de pólizas SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Código asignado, como campo llave, al tipo de póliza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Codigo_Tipo_Poliza_Sugef'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre del tipo de póliza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Nombre_Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripción del tipo de póliza, este texto aparecerá por medio de tooltip en la interfaz de usuario.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_SUGEF', 'column' , 'Descripcion_Tipo_Poliza'
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



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que contendrá la relación entre el tipo de póliza SAP, el tipo de póliza SUGEF y el tipo de bien.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Código del catálogo de tipos de póliza SAP.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Poliza_Sap'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del catálogo del tipo de póliza SUGEF.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Poliza_Sugef'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del catálogo del tipo de bien.' , 'user' , 'dbo' , 'table' , 'CAT_TIPOS_POLIZAS_X_TIPO_BIEN', 'column' , 'Codigo_Tipo_Bien'
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
		 DEFAULT  0 
)
 ON "PRIMARY"
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena la información de las pólizas registradas en el sistema de seguros (SAP), requerida por el sistema de garantías.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Código de la póliza dentro del sistema de pólizas (SAP).' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del tipo de póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto asegurado.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código de la moneda del monto de la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripción del código de la moneda del monto de la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Descripcion_Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Símbolo asignado a la moneda del monto del a póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Simbolo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento de la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Vencimiento'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del acreedro de la póliza. Por defecto se establece la cédula 4000000019.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Cedula_Acreedor'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre del acreedor. Por defecto se estable como "Banco de Costa Rica".' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Nombre_Acreedor'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Observaciones que puede poseer la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Detalle_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del estado de la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Estado_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Estado del registro. Se manejan los siguientes valores:

0 - Inactivo
1 - Activo' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Estado_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operación a la cual está asociada la póliza y que se encuentra registrada en el sistema de garantías.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'cod_operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro la primera vez.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Inserto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se actualizó la ultima vez por motivo de la réplica.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Replica'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto del avalúo anterior, esto en caso de que haya sido modificado.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento anterior,  esto en caso de que haya sido modificada.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Fecha_Vencimiento_Anterior'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificación anterior del acreedor de la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Cedula_Acreedor_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Nombre anterior del acreedor.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Nombre_Acreedor_Anterior'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Guardará el monto de la póliza colonizado, para lo cual debe usar el tipo de cambio de compra del dólar, almacenado en la tabla CAT_INDICES_ACTUALIZACION_AVALUO.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS', 'column' , 'Monto_Poliza_Colonizado'
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



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena la relaciones existentes entre una determina póliza y una garantía específica de una operación determinada.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Código de la póliza dentro del sistema de pólizas (SAP).' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operación a la cual está asociada la póliza y que se encuentra registrada en el sistema de garantías.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'cod_operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo del registro de la garantía a la cual se le asocia la póliza.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'cod_garantia_real'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Estado de la relación. Se manejan los siguientes valores:

0 - Inactivo
1 - Activo' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Estado_Registro'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto de la acreencia digitado por el usuario.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Monto_Acreencia'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro la primera vez.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Fecha_Inserto'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Usuario_Modifico'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se realizó la última modificación.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Fecha_Modifico'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que provocó la inserción del registro.' , 'user' , 'dbo' , 'table' , 'GAR_POLIZAS_RELACIONADAS', 'column' , 'Usuario_Inserto'
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
	Registro_Activo BIT NULL	
)
 ON "PRIMARY"
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Esta tabla almacena, de forma temporal, la información de las pólizas registradas en el sistema de seguros (SAP), requerida por el sistema de garantías.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Código de la póliza dentro del sistema de pólizas (SAP).' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_SAP'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del tipo de póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Tipo_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Monto asegurado.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código de la moneda del monto de la póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Descripción del código de la moneda del monto de la póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Descripcion_Moneda_Monto_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Símbolo asignado a la moneda del monto del a póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Simbolo_Moneda'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Fecha de vencimiento de la póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Fecha_Vencimiento'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Observaciones que puede poseer la póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Detalle_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del estado de la póliza.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Estado_Poliza'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código de la moneda de la operación o contrato, dentro del sistema de pólizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Moneda_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código de la oficina de la operación o contrato, dentro del sistema de pólizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Oficina_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Código del producto de la operación, dentro del sistema de pólizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Codigo_Producto_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Número de la operación, dentro del sistema de pólizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Numero_Operacion'
GO


EXEC sp_addextendedproperty 'MS_Description' , 'Número del contrato, dentro del sistema de pólizas.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Numero_Contrato'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Consecutivo de la operación, registrada en el sistema de garantías.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Consecutivo_Operacion_Garantias'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que el registro fue replicado.' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Fecha_Replica'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Indica si el registro está activo (1) para ser procesado o no (0)' , 'user' , 'dbo' , 'table' , 'TMP_POLIZAS', 'column' , 'Registro_Activo'
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
EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenará el catálogo de Porcentaje de Aceptacion Calculado.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Identificador único del registro.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Código del catálogo de tipo de garantia. 1: Fiduciaria 2: Real 3:Valor' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Tipo_Garantia'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Código del catálogo de tipo de mitigador.' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Codigo_Tipo_Mitigador'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Hace referencia a la clasificación del porcentaje  de aceptación a registrar.
0:  No aplica calificación 1: Sin Calificación ' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Indicador_Sin_Calificacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Número máximo digitado por el usuario para realizar la validación en los mantenimientos de garantías' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Aceptacion'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Número máximo digitado por el usuario para realizar la validación en los mantenimientos de garantías cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cero_Tres'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Número máximo digitado por el usuario para realizar la validación en los mantenimientos de garantías cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cuatro'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Número máximo digitado por el usuario para realizar la validación en los mantenimientos de garantías cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Cinco'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Número máximo digitado por el usuario para realizar la validación en los mantenimientos de garantías cuando el indicador _Sin_Clasificacion es 1' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Porcentaje_Seis'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Usuario que insertó el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Usuario_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se insertó el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Fecha_Inserto'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Usuario que modificó el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Usuario_Modifico'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha en que se modifcó el registro' , 'user' , 'dbo' , 'table' , 'CAT_PORCENTAJE_ACEPTACION', 'column' , 'Fecha_Modifico'
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



EXEC sp_addextendedproperty 'MS_Description' , 'Tabla que almacenará el histórico del catálogo de Porcentaje de Aceptacion Calculado.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST'
GO



EXEC sp_addextendedproperty 'MS_Description' , 'Identificación del usuario que ejecutó la operación.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Usuario'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Código de la operación ejecutada, ya sea consultar, agregar, modificar o borrar.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Codigo_Accion'
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

EXEC sp_addextendedproperty 'MS_Description' , 'Último contenido asignado al campo.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Estado_Actual_Campo_Afectado'
GO

EXEC sp_addextendedproperty 'MS_Description' , 'Fecha y hora en que fue ejecutada la operación.' , 'user' , 'dbo' , 'table' , 'PORCENTAJE_ACEPTACION_HST', 'column' , 'Fecha_Hora'
GO
