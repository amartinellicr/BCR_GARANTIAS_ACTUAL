
namespace BCR.GARANTIAS.Entidades
{
    public class clsGarantiaValor
    {
        #region Constantes
        public const string _entidadGarantiaValor = "GAR_GARANTIA_VALOR";
        public const string _entidadGarantiaValorXOperacion = "GAR_GARANTIAS_VALOR_X_OPERACION";

        //Campos de la tabla de garantía valor
       public const string _codigoTipoGarantia = "cod_tipo_garantia";
        public const string _codigoClaseGarantia = "cod_clase_garantia";
        public const string _numeroSeguridad = "numero_seguridad";
        public const string _fechaConstitucion = "fecha_constitucion";
        public const string _fechaVencimientoInstrumento = "fecha_vencimiento_instrumento";
        public const string _codigoClasificacionInstrumento = "cod_clasificacion_instrumento";
        public const string _descripcionInstrumento = "des_instrumento";
        public const string _serieInstrumento = "des_serie_instrumento";
        public const string _codigoTipoPersonaEmisor = "cod_tipo_emisor";
        public const string _cedulaEmisor = "cedula_emisor";
        public const string _porcentajePremio = "premio";
        public const string _codigoIsin = "cod_isin";
        public const string _montoValorFacial = "valor_facial";
        public const string _codigoMonedaValorFacial = "cod_moneda_valor_facial";
        public const string _montoValorMercado = "valor_mercado";
        public const string _codigoMonedaValorMercado = "cod_moneda_valor_mercado";
        public const string _codigoTenencia = "cod_tenencia";
        public const string _fechaPrescripcion = "fecha_prescripcion";

        //Campos de la tabla de la relación
        public const string _consecutivoOperacion = "cod_operacion";
        public const string _codigoTipoMitigador = "cod_tipo_mitigador";
        public const string _codigoTipoDocumentoLegal = "cod_tipo_documento_legal";
        public const string _montoMitigador = "monto_mitigador";
        public const string _codigoIndicadorInscripcion = "cod_inscripcion";
        public const string _fechaPresentacionRegistro = "fecha_presentacion_registro";
        public const string _porcentajeResponsabilidad = "porcentaje_responsabilidad";
        public const string _codigoGradoGravamen = "cod_grado_gravamen";
        public const string _codigoGradoPrioridades = "cod_grado_prioridades";
        public const string _montoPrioridades = "monto_prioridades";
        public const string _codigoOperacionEspecial = "cod_operacion_especial";
        public const string _codigoTipoPersonaAcreedor = "cod_tipo_acreedor";
        public const string _cedulaAcreedor = "cedula_acreedor";
        public const string _codigoEstadoRegistro = "cod_estado";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";

        //Campos comunes entre las tablas
        public const string _consecutivoGarantiaValor = "cod_garantia_valor";
        public const string _cedulaUsuarioModifico = "Usuario_Modifico";
        public const string _nombreUsuarioModifico = "Nombre_Usuario_Modifico";
        public const string _fechaModifico = "Fecha_Modifico";
        public const string _fechaInserto = "Fecha_Inserto";
        public const string _fechaReplica = "Fecha_Replica";

        #endregion
    }
}
