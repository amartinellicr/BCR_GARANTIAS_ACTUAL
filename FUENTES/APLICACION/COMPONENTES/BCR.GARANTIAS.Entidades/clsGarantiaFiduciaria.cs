using System;
using System.Web;

namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsGarantiaFiduciaria
    {
        #region Constantes
        public const string _entidadGarantiaFiduciaria = "GAR_GARANTIA_FIDUCIARIA";
        public const string _entidadGarantiaFiduciariaXOperacion = "GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION";
 
        //Campos de la tabla de garantía fiduciaria
        public const string _codigoTipoGarantia = "cod_tipo_garantia";
        public const string _codigoClaseGarantia = "cod_clase_garantia";
        public const string _cedulaFiador = "cedula_fiador";
        public const string _nombreFiador = "nombre_fiador";
        public const string _codigoTipoPersonaFiador = "cod_tipo_fiador";
        public const string _rucCedulaFiador = "ruc_cedula_fiador";
        public const string _cedulaFiadorSugef = "cedula_fiador_sugef";
        public const string _indicadorActualizoCedulaSugef = "ind_actualizo_cedulasugef";
        public const string _codigoTipoPersonaSugef = "tipo_id_sugef";
        public const string _identificacionSicc = "Identificacion_Sicc";
        

        //Campos de la tabla de la relación
        public const string _consecutivoOperacion = "cod_operacion";
        public const string _codigoTipoMitigador = "cod_tipo_mitigador";
        public const string _codigoTipoDocumentoLegal = "cod_tipo_documento_legal";
        public const string _montoMitigador = "monto_mitigador";
        public const string _porcentajeResponsabilidad = "porcentaje_responsabilidad";
        public const string _codigoOperacionEspecial = "cod_operacion_especial";
        public const string _codigoTipoPersonaAcreedor = "cod_tipo_acreedor";
        public const string _cedulaAcreedor = "cedula_acreedor";
        public const string _indicadorEstadoRegistro = "cod_estado";
        public const string _porcentajeAceptacion = "Porcentaje_Aceptacion";

        //Campos comunes entre las tablas
        public const string _consecutivoGarantiaFiduciaria = "cod_garantia_fiduciaria";
        public const string _usuarioModifico = "Usuario_Modifico";
        public const string _fechaModifico = "Fecha_Modifico";
        public const string _fechaInserto = "Fecha_Inserto";
        public const string _fechaReplica = "Fecha_Replica";

        #endregion Constantes

        #region Propiedades

        //Datos de la operación
        public int TipoOperacion { get; set; }
        public int Contabilidad { get; set; }
        public int Oficina { get; set; }
        public int Moneda { get; set; }
        public int Producto { get; set; }
        public long Numero { get; set; }

        //Datos de la garantía y la relación
        public long ConsecutivoGarantiaFiduciaria { get; set; }
        public int CodigoTipoGarantia { get; set; }
        public int CodigoClaseGarantia { get; set; }
        public string CedulaFiador { get; set; }
        public string NombreFiador { get; set; }
        public int CodigoTipoPersonaFiador { get; set; }
        public string RucCedulaFiador { get; set; }
        public string CedulaFiadorSugef { get; set; }
        public bool IndicadorActualizoCedulaSugef { get; set; }
        public decimal TipoPersonaSugef { get; set; }
        public decimal IndentificacionSicc { get; set; }
        public string UsuarioModifico { get; set; }
        public DateTime FechaModifico { get; set; }
        public DateTime FechaInserto { get; set; }
        public DateTime FechaReplica { get; set; }
        public long ConsecutivoOperacion { get; set; }
        public int CodigoTipoMitigador { get; set; }
        public int CodigoTipoDocumentoLegal { get; set; }
        public decimal MontoMitigador { get; set; }
        public decimal PorcentajeResponsabilidad { get; set; }
        public int CodigoOperacionEspecial { get; set; }
        public int CodigoTipoPersonaAcreedor { get; set; }
        public string CedulaAcreedor { get; set; }
        public int IndicadorEstadoRegistro { get; set; }
        public decimal PorcentajeAceptacion { get; set; }

        //Datos de la tarjeta
        public DateTime FechaExpiracion { get; set; }
        public decimal MontoCobertura { get; set; }
        public string Tarjeta { get; set; }
        public string Observacion { get; set; }


        #endregion Propiedades

        #region Constructor
        public clsGarantiaFiduciaria()
        {
            CodigoClaseGarantia = -1;
            CodigoTipoMitigador = -1;
            CodigoOperacionEspecial = -1;
        }
        #endregion Constructor

        /// <summary>
		/// Metodo que retorna el objeto garantía actual en la session
		/// </summary>
		public static clsGarantiaFiduciaria Current
        {
            get
            {
                //Obtiene el objeto CGarantiaFiduciaria del Session
                clsGarantiaFiduciaria oCurrent = HttpContext.Current.Session["clsGarantiaFiduciaria"] as clsGarantiaFiduciaria;
                
                if (oCurrent == null)
                {
                    //si no existe crea el objeto en el session
                    oCurrent = new clsGarantiaFiduciaria();
                    HttpContext.Current.Session["clsGarantiaFiduciaria"] = oCurrent;
                }
                return oCurrent;
            }
        }
    }
}
