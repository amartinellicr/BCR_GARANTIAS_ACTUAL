
using System;
using System.Web;

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

        #region Propiedades
        //Datos de la operación
        public int TipoOperacion { get; set; }
        public int Contabilidad { get; set; }
        public int Oficina { get; set; }
        public int Moneda { get; set; }
        public int Producto { get; set; }
        public long Numero { get; set; }

        //Datos de la garantía y la relación
        public long ConsecutivoGarantia { get; set; }
        public int CodigoTipoGarantia { get; set; }
        public int CodigoClaseGarantia { get; set; }
        public string NumeroSeguridad { get; set; }
        public DateTime FechaConstitucion { get; set; }
        public DateTime FechaVencimientoInstrumento { get; set; }
        public int CodigoClasificacionInstrumento { get; set; }
        public string DescripcionInstrumento { get; set; }
        public string SerieInstrumento { get; set; }
        public int CodigoTipoPersonaEmisor { get; set; }
        public string CedulaEmisor { get; set; }
        public decimal PorcentajePremio { get; set; }
        public string CodigoIsin { get; set; }
        public decimal MontoValorFacial { get; set; }
        public int CodigoMonedaValorFacial { get; set; }
        public decimal MontoValorMercado { get; set; }
        public int CodigoMonedaValorMercado { get; set; }
        public int CodigoTipoTenencia { get; set; }
        public DateTime FechaPrescripcion { get; set; }
        public long ConsecutivoOperacion { get; set; }
        public int CodigoTipoMitigador { get; set; }
        public int CodigoTipoDocumentoLegal { get; set; }
        public decimal MontoMitigiador { get; set; }
        public int CodigoIndicadorInscripcion { get; set; }
        public DateTime FechaPresentacion { get; set; }
        public decimal PorcentajeResponsabilidad { get; set; }
        public int CodigoGradoGravamen { get; set; }
        public int CodigoGradoPrioridad { get; set; }
        public decimal MontoPrioridad { get; set; }
        public int CodigoOperacionEspecial { get; set; }
        public int CodigoTipoPersonaAcreedor { get; set; }
        public string CedulaAcreedor { get; set; }
        public int IndicadorEstadoRegistro { get; set; }
        public decimal PorcentajeAceptacion { get; set; }
        public string UsuarioModifico { get; set; }
        public string NombreUsuarioModifico { get; set; }
        public DateTime FechaModifico { get; set; }
        public DateTime FechaInserto { get; set; }
        public DateTime FechaReplica { get; set; }

        #endregion Propiedades

        #region Constructor
        public clsGarantiaValor()
        {
            CodigoClaseGarantia = -1;
            CodigoTipoMitigador = -1;
            CodigoOperacionEspecial = -1;
        }
        #endregion Constructor

        #region Métodos Públicos

        /// <summary>
        /// Metodo que retorna el objeto garantía actual en la session
        /// </summary>
        public static clsGarantiaValor Current
        {
            get
            {
                //Obtiene el objeto clsGarantiaValor del Session
                clsGarantiaValor oCurrent = HttpContext.Current.Session["clsGarantiaValor"] as clsGarantiaValor;

                if (oCurrent == null)
                {
                    //si no existe crea el objeto en el session
                    oCurrent = new clsGarantiaValor();
                    HttpContext.Current.Session["clsGarantiaValor"] = oCurrent;
                }
                return oCurrent;
            }
        }

        #endregion Métodos Públicos

    }
}
