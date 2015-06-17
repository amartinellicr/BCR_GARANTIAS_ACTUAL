using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;
using System.Collections.Specialized;
using System.Reflection;
using System.Configuration;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;
using System.Globalization;

namespace BCR.GARANTIAS.Entidades
{
    [Serializable]
    public class clsHistoricoPorcentajeAceptacion
    {

        #region Constantes
       
        private const string _codigoUsuario                  = "Codigo_Usuario";
        private const string _codigoAccion                   = "Codigo_Accion";
        private const string _codigoConsulta                 = "Codigo_Consulta";
        private const string _codigoTipoGarantia             = "Codigo_Tipo_Garantia";
        private const string _codigoTipoMitigador            = "Codigo_Tipo_Mitigador";
        private const string _descripcionCampoAfectado       = "Descripcion_Campo_Afectado";
        private const string _estadoAnteriorCampoAfectado    = "Estado_Anterior_Campo_Afectado";
        private const string _estadoActualCampoAfectado      = "Estado_Actual_Campo_Afectado";
        private const string _fechaHora                      = "Fecha_Hora";
        private const string _nombreUsuario                  = "NOMBRE_USUARIO";
        private const string _desTipoGarantia                = "TIPO_GARANTIA";
        private const string _desTipoMitigador               = "TIPO_MITIGADOR";
        private const string _desAccionRealizada             = "ACCION_REALIZADA";

        //Tags especiales
        private const string _tagHistorial = "HISTORIAL";
        private const string _tagDatos = "DATOS";

        #endregion

        #region Variables


        /// <summary>
        /// Identificación del usuario que realiza la acción
        /// </summary>
        private string codigoUsuario;     

        /// <summary>
        /// Código del tipo de acción realizada, don de 1 = INS, 2 = MOD y 3 = BOR
        /// </summary>
        private Enumeradores.Tipos_Accion codigoAcccion;

        /// <summary>
        /// Sentencia SQL generada
        /// </summary>
        private string codigoConsulta;

        /// <summary>
        /// Codigo tipo de garantia
        /// </summary>
        private int? codigoTipoGarantia;

        /// <summary>
        /// Codigo tipo de mitigador de riesgo
        /// </summary>
        private int? codigoTipoMitigador;

        /// <summary>
        /// Codigo tipo del catalogo de garantia
        /// </summary>
        private int codigoCatalogoGarantia;

      

        /// <summary>
        /// Codigo tipo del catalogo de mitigador
        /// </summary>
        private int codigoCatalogoMitigador;
   

        /// <summary>
        /// Nombre del campo, a nivel de base de datos, que fue afectado
        /// </summary>
        private string descripcionCampoAfectado;

        /// <summary>
        /// Valor anterior del campo afectado
        /// </summary>
        private string estadoAnteriorCampoAfectado;

        /// <summary>
        /// Valor reciente del campo afectado
        /// </summary>
        private string estadoActualCampoAfectado;    

        /// <summary>
        /// Fecha y hora en que se realiza la acción
        /// </summary>
        private DateTime fechaHora;   


        /// <summary>
        /// Nombre del usuario que modificó
        /// </summary>
        private string nombreUsuario;   

        /// <summary>
        /// Descripcion del tipo de garantia
        /// </summary>
        private string desTipoGarantia;      

        /// <summary>
        /// Descripcion del tipo de garantia
        /// </summary>
        private string desTipoMitigador;    

        /// <summary>
        /// Descripcion de la accion que se realizó, insert, update, delte
        /// </summary>
        private string desAccionRealizada;     

        /// <summary>
        /// Indicador que determina si la entidad es válida o no
        /// </summary>
        private bool entidadValida;

        /// <summary>
        /// Descripción del error
        /// </summary>
        private string desError;

        /// <summary>
        /// Indicador de que se presentó un error de datos
        /// </summary>
        private bool errorDatos;


        #endregion

        #region Propiedades

        /// <summary>
        /// Propiedad que obtiene y establece la identificación del usuario que realizó la acción
        /// </summary>
        public string CodigoUsuario
        {
            get { return codigoUsuario; }
            set { codigoUsuario = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de acción realizada
        /// </summary>
        public Enumeradores.Tipos_Accion CodigoAcccion
        {
            get { return codigoAcccion; }
            set { codigoAcccion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la sentencia SQL de la acción realizada
        /// </summary>
        public string CodigoConsulta
        {
            get { return codigoConsulta; }
            set { codigoConsulta = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el codigo del tipo de garantia
        /// </summary>
        public int? CodigoTipoGarantia
        {
            get { return codigoTipoGarantia; }
            set { codigoTipoGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el codigo del tipo de mitigador
        /// </summary>
        public int? CodigoTipoMitigador
        {
            get { return codigoTipoMitigador; }
            set { codigoTipoMitigador = value; }
        }

        public int CodigoCatalogoGarantia
        {
            get { return codigoCatalogoGarantia; }
            set { codigoCatalogoGarantia = value; }
        }

        public int CodigoCatalogoMitigador
        {
            get { return codigoCatalogoMitigador; }
            set { codigoCatalogoMitigador = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece del nombre del campo afectado
        /// </summary>
        public string DescripcionCampoAfectado
        {
            get { return descripcionCampoAfectado; }
            set { descripcionCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece valor anterior del campo afectado
        /// </summary>
        public string EstadoAnteriorCampoAfectado
        {
            get { return estadoAnteriorCampoAfectado; }
            set { estadoAnteriorCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece valor actual del campo afectado
        /// </summary>
        public string EstadoActualCampoAfectado
        {
            get { return estadoActualCampoAfectado; }
            set { estadoActualCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha y hora en que se registra la acción
        /// </summary>
        public DateTime FechaHora
        {
            get { return fechaHora; }
            set { fechaHora = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el nombre del usuario que realizó la acción
        /// </summary>
        public string NombreUsuario
        {
            get { return nombreUsuario; }
            set { nombreUsuario = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripcion del tipo de garantia
        /// </summary>
        public string DesTipoGarantia
        {
            get { return desTipoGarantia; }
            set { desTipoGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el codigo del tipo de mitigador
        /// </summary>
        public string DesTipoMitigador
        {
            get { return desTipoMitigador; }
            set { desTipoMitigador = value; }
        }
        /// <summary>
        /// Propiedad que obtiene y establece la descripcion de la acción realizada
        /// </summary>
        public string DesAccionRealizada
        {
            get { return desAccionRealizada; }
            set { desAccionRealizada = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el indicador de si la entidad es válida o no
        /// </summary>
        public bool EntidadValida
        {
            get { return entidadValida; }
            set { entidadValida = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripción del error encontrado
        /// </summary>
        public string DesError
        {
            get { return desError; }
            set { desError = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicación de que se presentó un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        #endregion

        #region Constructores

        /// <summary>
        /// Constructor base de la clase
        /// </summary>
        public clsHistoricoPorcentajeAceptacion()
        {
            codigoUsuario = string.Empty;
            codigoAcccion = Enumeradores.Tipos_Accion.Ninguna; ;
            codigoConsulta = string.Empty;
            codigoTipoGarantia = -1;
            codigoTipoMitigador = -1;         
            descripcionCampoAfectado = string.Empty;
            estadoAnteriorCampoAfectado = string.Empty;
            estadoActualCampoAfectado = string.Empty;
            fechaHora = DateTime.MinValue;
            nombreUsuario = string.Empty;
            desTipoGarantia = string.Empty;
            desTipoMitigador = string.Empty;
            desAccionRealizada = string.Empty;
            entidadValida = false;
            desError = string.Empty;        
        }


         /// <summary>
        /// Constructor de la clase que carga los datos que posee la trama recibida
        /// </summary>
        /// <param name="tramaPorcentajeAceptacion">Trama que posee los datos sobre los porcentajes de aceptacion</param>
        public clsHistoricoPorcentajeAceptacion(string tramaHistorialPorcentaje)
        {
            codigoUsuario = string.Empty;
            codigoAcccion = Enumeradores.Tipos_Accion.Ninguna; ;
            codigoConsulta = string.Empty;
            codigoTipoGarantia = -1;
            codigoTipoMitigador = -1;
            descripcionCampoAfectado = string.Empty;
            estadoAnteriorCampoAfectado = string.Empty;
            estadoActualCampoAfectado = string.Empty;
            fechaHora = DateTime.MinValue;
            nombreUsuario = string.Empty;
            desTipoGarantia = string.Empty;
            desTipoMitigador = string.Empty;

            if (tramaHistorialPorcentaje.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

                try
                {
                    xmlTrama.LoadXml(tramaHistorialPorcentaje);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    desError = Mensajes.Obtener(Mensajes._errorCargaHistorialPorcentajeAceptacion, Mensajes.ASSEMBLY);

                    string descError = "Error al cargar la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaHistorialPorcentajeAceptacionDetalle, descError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama != null)
                {                  
                   
                    DateTime  sfechaHora;

                    try
                    {
                        codigoUsuario = ((xmlTrama.SelectSingleNode("//" + _codigoUsuario) != null) ? xmlTrama.SelectSingleNode("//" + _codigoUsuario).InnerText : string.Empty); ;
                        descripcionCampoAfectado = ((xmlTrama.SelectSingleNode("//" + _descripcionCampoAfectado) != null) ? xmlTrama.SelectSingleNode("//" + _descripcionCampoAfectado).InnerText : string.Empty);
                        estadoAnteriorCampoAfectado = ((xmlTrama.SelectSingleNode("//" + _estadoAnteriorCampoAfectado) != null) ? xmlTrama.SelectSingleNode("//" + _estadoAnteriorCampoAfectado).InnerText : string.Empty);
                        estadoActualCampoAfectado = ((xmlTrama.SelectSingleNode("//" + _estadoActualCampoAfectado) != null) ? xmlTrama.SelectSingleNode("//" + _estadoActualCampoAfectado).InnerText : string.Empty);
                        fechaHora = ((xmlTrama.SelectSingleNode("//" + _fechaHora) != null) ? ((DateTime.TryParse((xmlTrama.SelectSingleNode("//" + _fechaHora).InnerText), out sfechaHora)) ? ((sfechaHora != (new DateTime(1900, 01, 01))) ? sfechaHora : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);

                        nombreUsuario = ((xmlTrama.SelectSingleNode("//" + _nombreUsuario) != null) ? xmlTrama.SelectSingleNode("//" + _nombreUsuario).InnerText : string.Empty);
                        desTipoGarantia = ((xmlTrama.SelectSingleNode("//" + _desTipoGarantia) != null) ? xmlTrama.SelectSingleNode("//" + _desTipoGarantia).InnerText : string.Empty);
                        desTipoMitigador = ((xmlTrama.SelectSingleNode("//" + _desTipoMitigador) != null) ? xmlTrama.SelectSingleNode("//" + _desTipoMitigador).InnerText : string.Empty);
                        desAccionRealizada = ((xmlTrama.SelectSingleNode("//" + _desAccionRealizada) != null) ? xmlTrama.SelectSingleNode("//" + _desAccionRealizada).InnerText : string.Empty);                                               
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        desError = Mensajes.Obtener(Mensajes._errorCargaPorcentajeAceptacion, Mensajes.ASSEMBLY);

                        string descrError = "El error se da al cargar los datos del Historial de Porcentaje de Aceptación: " + ex.Message;
                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaHistorialPorcentajeAceptacionDetalle, descrError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                }
            }                        
        }
        #endregion

        #region Metodos Privados

        /// <summary>
        /// Convierte los datos relevantes dela entidad en formato xml
        /// </summary>       
        /// <returns>Trama xml con los datos que posee la entidad</returns>
        private string ConvertirAXML()
        {

            string tramaGenerada = string.Empty;


            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el formato
            XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.Unicode);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo raiz
            objEscritor.WriteStartElement(_tagDatos);

            #region Bitacora

            //Inicializa el nodo que poseer los datos de la bitacora
            objEscritor.WriteStartElement(_tagHistorial);

            //Crea el nodo de la descripcion del campo afectado
            objEscritor.WriteStartElement(_descripcionCampoAfectado);
            objEscritor.WriteString(this.descripcionCampoAfectado.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la estado anterior del campo afectado
            objEscritor.WriteStartElement(_estadoAnteriorCampoAfectado);
            objEscritor.WriteString(this.estadoAnteriorCampoAfectado.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la estado actual del campo afectado
            objEscritor.WriteStartElement(_estadoActualCampoAfectado);
            objEscritor.WriteString(this.estadoActualCampoAfectado.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la fecha de modificacion 
            objEscritor.WriteStartElement(_fechaHora);
            objEscritor.WriteString(this.fechaHora.ToString("yyyyMMdd"));
            objEscritor.WriteEndElement();

            //Crea el nodo de la cedula del usuario que modifico 
            objEscritor.WriteStartElement(_codigoUsuario);
            objEscritor.WriteString(this.codigoUsuario.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo del nombre del usuario que modifico 
            objEscritor.WriteStartElement(_nombreUsuario);
            objEscritor.WriteString(this.nombreUsuario.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la descripcion del tipo de garantia
            objEscritor.WriteStartElement(_desTipoGarantia);
            objEscritor.WriteString(this.desTipoGarantia.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la descripcion del tipo de mitigador
            objEscritor.WriteStartElement(_desTipoMitigador);
            objEscritor.WriteString(this.desTipoMitigador.ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo de la descripcion de la accion realizada
            objEscritor.WriteStartElement(_desAccionRealizada);
            objEscritor.WriteString(this.desAccionRealizada.ToString());
            objEscritor.WriteEndElement();


            #endregion

            //Final del tag DATOS
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            tramaGenerada = UtilitariosComun.GetStringFromStream(stream).Replace("&lt;", "<").Replace("&gt;", ">"); ;

            //Cierre del xml document
            objEscritor.Close();


            return tramaGenerada;
        }

        #endregion


    }//FIN
}//FIN
