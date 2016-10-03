using System.Xml;

namespace BCR.GARANTIAS.Entidades
{
    public class clsDeudor
    {
        #region Constantes

        public const string _entidadDeudor              = "GAR_DEUDOR";

        private const string _codigo                    = "CODIGO";
        private const string _mensaje                   = "MENSAJE";
        public const string _cedulaDeudor               = "cedula_deudor";
        public const string _nombreDeudor               = "nombre_deudor";
        public const string _codTipoDeudor              = "cod_tipo_deudor";
        public const string _codCondicionEspecial       = "cod_condicion_especial";
        public const string _codTipoAsignacion          = "cod_tipo_asignacion";
        public const string _codGeneradorDivisas        = "cod_generador_divisas";
        public const string _codVinculadoEntidad        = "cod_vinculado_entidad";
        public const string _codTipoRegistro            = "cod_tipo_registro";
        public const string _desTipoRegistro            = "des_tipo_registro";
        private const string _capacidades               = "CAPACIDADES";
        private const string _capacidad                 = "CAPACIDAD";
        private const string _fechaCapacidadPago        = "fecha_capacidad_pago";
        private const string _codCapacidadPago          = "cod_capacidad_pago";
        private const string _porSensibilidadTipoCambio = "sensibilidad_tipo_cambio";
        private const string _desCapacidadPago          = "des_capacidad_pago";
        private const string _indicadorEstadoRegistro   = "cod_estado";
        private const string _cedulaDeudorSugef         = "cedula_deudor_sugef";
        private const string _indicadorActualizacionCedulaSugef = "ind_actualizo_cedulasugef";
        private const string _tipoIdentificacionSugef   = "tipo_id_sugef";
        public const string _identificacionSicc         = "Identificacion_Sicc";


        
      
      
      
      
        #endregion Constantes

        #region Variables

        /// <summary>
        /// Identificación del deudor/codeudor
        /// </summary>
        private string cedulaDeudor;

        /// <summary>
        /// Nombre completo del deudor/codeudor
        /// </summary>
        private string nombreDeudor;

        /// <summary>
        /// Tipo de identificación del deudor/codeudor
        /// </summary>
        private int codTipoDeudor;

        /// <summary>
        /// Condición especial del deudor/codeudor
        /// </summary>
        private int codCondicionEspecial;

        /// <summary>
        /// Tipo de asignación 
        /// </summary>
        private int codTipoAsignacion;

        /// <summary>
        /// Indicador de generador de divisas
        /// </summary>
        private int codGeneradorDivisas;

        /// <summary>
        /// Indicador de vinculado a la entidad
        /// </summary>
        private int codVinculadoEntidad;

        /// <summary>
        /// Código de estado del registro
        /// </summary>
        private int codEstado;

        /// <summary>
        /// Indicador del tipo de registro, es decir, si se trata de un deudor, codeudor o ambos
        /// </summary>
        private int codTipoRegistro;
            
        /// <summary>
        /// Descripción del tipo de registro
        /// </summary>
        private string desTipoRegistro;

        /// <summary>
        /// Lista de las capacidades de pago asociadas al deudor/codeudor
        /// </summary>
        private clsCapacidadesPago<clsCapacidadPago> listaCapacidadesPago;
        
        /// <summary>
        /// Código del estado de la consulta realizada
        /// </summary>
        private string codErrorObtenido;

        /// <summary>
        /// Descripción del estado de la consulta realizada
        /// </summary>
        private string mensErrorObtenido;

        /// <summary>
        /// Indica si la operación se realizó con éxito o no, según el código de error recibido
        /// </summary>
        private bool consultaExitosa;
    
        #endregion Variables

        #region Propiedades Públicas

        /// <summary>
        /// Obtiene o establece la identificación del deudor/codeudor
        /// </summary>
        public string CedulaDeudor
        {
            get { return cedulaDeudor; }
            set { cedulaDeudor = value; }
        }

        /// <summary>
        /// Obtiene el nombre del deudor/codeudor
        /// </summary>
        public string NombreDeudor
        {
            get { return nombreDeudor; }
        }

        /// <summary>
        /// Obtiene o establece el tipo de identificación del deudor/codeudor
        /// </summary>
        public int TipoDeudor
        {
            get { return codTipoDeudor; }
            set { codTipoDeudor = value; }
        }

        /// <summary>
        /// Obtiene o establece la condición especial
        /// </summary>
        public int CondicionEspecial
        {
            get {    return codCondicionEspecial; }
            set { codCondicionEspecial = value; }
        }

        /// <summary>
        /// Obtiene o establece el tipo de asignación
        /// </summary>
        public int TipoAsignacion
        {
            get { return codTipoAsignacion; }
            set { codTipoAsignacion = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de generador de divisas
        /// </summary>
        public int GeneradorDivisas
        {
            get { return codGeneradorDivisas; }
            set { codGeneradorDivisas = value; }
        }

        /// <summary>
        /// Obtiene o establece indicador de vinculado a la entidad
        /// </summary>
        public int VinculadoEntidad
        {
            get { return codVinculadoEntidad; }
            set { codVinculadoEntidad = value; }
        }

        /// <summary>
        /// Obtiene el estado del registro
        /// </summary>
        public int Estado
        {
            get { return codEstado; }
        }

        /// <summary>
        /// Obtiene el tipo de registro, es decir, si se trata de un deudor (0), codeudor (1) o ambos (2)
        /// </summary>
        public int TipoRegistro
        {
            get { return codTipoRegistro; }
        }

        /// <summary>
        /// Obtiene la descripción del tipo de registro
        /// </summary>
        public string DescripcionTipoRegistro
	    {
		    get { return desTipoRegistro;}
        }

        /// <summary>
        /// Obtiene o establece la lista de capacidades de pago asociadas al deudor/codeudor
        /// </summary>
        public clsCapacidadesPago<clsCapacidadPago> ListaCapacidadesPago
        {
            get { 
                return ((listaCapacidadesPago != null) ? listaCapacidadesPago : new clsCapacidadesPago<clsCapacidadPago>()); 
            }
            set { listaCapacidadesPago = value; }
        }

        /// <summary>
        /// Obtiene o establece el código de error que se obtuvo producto de la consulta realizada
        /// </summary>
        public string codigoErrorObtenido
        {
            get { return codErrorObtenido; }
            set { codErrorObtenido = value; }
        }

        /// <summary>
        /// Obtiene o establece la descripción del código de error que se obtuvo producto de la consulta realizada
        /// </summary>
        public string descErrorObtenido
        {
            get { return mensErrorObtenido; }
            set { mensErrorObtenido = value; }
        }

        /// <summary>
        /// Obtiene o establece el indicador de estado de la consulta, según el código de error recibido de la base de datos
        /// </summary>
        public bool ConsultaExitosa
        {
            get { return consultaExitosa; }
            set { consultaExitosa = value; }
        }

        #endregion Propiedades Públicas

        #region Constructores

        /// <summary>
        /// Constructor báciso de la clase
        /// </summary>
        public clsDeudor()
        {
            cedulaDeudor = string.Empty;
            nombreDeudor = string.Empty;
            codTipoDeudor = -1;
            codCondicionEspecial = -1;
            codTipoAsignacion = -1;
            codGeneradorDivisas = -1;
            codVinculadoEntidad = -1;
            codEstado = -1;
            codTipoRegistro = -1;
            ListaCapacidadesPago = null;
            consultaExitosa = false;
        }

        /// <summary>
        /// Constructor de la clase que setea los campos de acuerdo a los valores de la trama
        /// </summary>
        /// <param name="tramaDatos">Trama que posee los datos obtenidos de la bae de datos</param>
        public clsDeudor(string tramaDatos)
        {
            cedulaDeudor = string.Empty;
            nombreDeudor = string.Empty;
            codTipoDeudor = -1;
            codCondicionEspecial = -1;
            codTipoAsignacion = -1;
            codGeneradorDivisas = -1;
            codVinculadoEntidad = -1;
            codEstado = -1;
            codTipoRegistro = -1;
            ListaCapacidadesPago = null;
            consultaExitosa = false;

            if (tramaDatos.Length > 0)
            {
                /*
                 <RESPUESTA>
                  <CODIGO>0</CODIGO>
                  <PROCEDIMIENTO>Obtener_Deudor</PROCEDIMIENTO>
                  <MENSAJE>La obtención de datos fue satisfactoria</MENSAJE>
                  <DETALLE>
                    <Deudor>
                      <cedula_deudor>100000012297</cedula_deudor>
                      <nombre_deudor>LUCAS CAROLE YVONNE                          </nombre_deudor>
                      <cod_tipo_deudor>3</cod_tipo_deudor>
                      <cod_condicion_especial>5</cod_condicion_especial>
                      <cod_tipo_asignacion>2</cod_tipo_asignacion>
                      <cod_generador_divisas>3</cod_generador_divisas>
                      <cod_vinculado_entidad>2</cod_vinculado_entidad>
                      <cod_tipo_registro>0</cod_tipo_registro>
                      <des_tipo_registro>Deudor</des_tipo_registro>
                      <CAPACIDADES>
                        <CAPACIDAD>
                          <fecha_capacidad_pago>28/05/2007</fecha_capacidad_pago>
                          <cod_capacidad_pago>4</cod_capacidad_pago>
                          <sensibilidad_tipo_cambio>0.00</sensibilidad_tipo_cambio>
                        </CAPACIDAD>
                        <CAPACIDAD>
                          <fecha_capacidad_pago>05/03/2008</fecha_capacidad_pago>
                          <cod_capacidad_pago>2</cod_capacidad_pago>
                          <sensibilidad_tipo_cambio>50.00</sensibilidad_tipo_cambio>
                        </CAPACIDAD>
                      </CAPACIDADES>
                    </Deudor>
                  </DETALLE>
                </RESPUESTA>
                 */

                int nCodidoErrorObtenido;
                XmlDocument xmlTrama = new XmlDocument();
                XmlNode nodoCapacidades;
                int dato;

                xmlTrama.LoadXml(tramaDatos);

                codErrorObtenido = ((xmlTrama.SelectSingleNode("//" + _codigo) != null) ? xmlTrama.SelectSingleNode("//" + _codigo).InnerText : string.Empty);
                descErrorObtenido = ((xmlTrama.SelectSingleNode("//" + _mensaje) != null) ? xmlTrama.SelectSingleNode("//" + _mensaje).InnerText : string.Empty);
                cedulaDeudor = ((xmlTrama.SelectSingleNode("//" + _cedulaDeudor) != null) ? xmlTrama.SelectSingleNode("//" + _cedulaDeudor).InnerText : string.Empty);
                nombreDeudor = ((xmlTrama.SelectSingleNode("//" + _nombreDeudor) != null) ? xmlTrama.SelectSingleNode("//" + _nombreDeudor).InnerText : string.Empty);
                codTipoDeudor = ((xmlTrama.SelectSingleNode("//" + _codTipoDeudor) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codTipoDeudor).InnerText), out dato)) ? dato : -1) : -1);
                codCondicionEspecial = ((xmlTrama.SelectSingleNode("//" + _codCondicionEspecial) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codCondicionEspecial).InnerText), out dato)) ? dato : -1) : -1);
                codTipoAsignacion = ((xmlTrama.SelectSingleNode("//" + _codTipoAsignacion) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codTipoAsignacion).InnerText), out dato)) ? dato : -1) : -1);
                codGeneradorDivisas = ((xmlTrama.SelectSingleNode("//" + _codGeneradorDivisas) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codGeneradorDivisas).InnerText), out dato)) ? dato : -1) : -1);
                codVinculadoEntidad = ((xmlTrama.SelectSingleNode("//" + _codVinculadoEntidad) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codVinculadoEntidad).InnerText), out dato)) ? dato : -1) : -1);
                codTipoRegistro = ((xmlTrama.SelectSingleNode("//" + _codTipoRegistro) != null) ? ((int.TryParse((xmlTrama.SelectSingleNode("//" + _codTipoRegistro).InnerText), out dato)) ? dato : -1) : -1);
                desTipoRegistro = ((xmlTrama.SelectSingleNode("//" + _desTipoRegistro) != null) ? xmlTrama.SelectSingleNode("//" + _desTipoRegistro).InnerText : string.Empty);
                
                nodoCapacidades = xmlTrama.SelectSingleNode("//" + _capacidades);

                if ((nodoCapacidades != null) && (nodoCapacidades.HasChildNodes))
                {
                    clsCapacidadPago entidadCapacidadPago;
                    ListaCapacidadesPago = new clsCapacidadesPago<clsCapacidadPago>();

                    foreach (XmlNode nodoCapacidad in nodoCapacidades.ChildNodes)
                    {
                        entidadCapacidadPago = new clsCapacidadPago(nodoCapacidad.OuterXml);
                        entidadCapacidadPago.CedulaDeudor = cedulaDeudor;

                        ListaCapacidadesPago.Agregar(entidadCapacidadPago);
                    }
                }

                ConsultaExitosa = (((codErrorObtenido.Length > 0) && (int.TryParse(codErrorObtenido, out nCodidoErrorObtenido)) && (nCodidoErrorObtenido == 0)) ? true : false);
            }
        }

        #endregion Constructores

        #region Métodos Públicos

        #endregion Métodos Públicos

        #region Métodos Privados


        #endregion Métodos Privados

    }
}
