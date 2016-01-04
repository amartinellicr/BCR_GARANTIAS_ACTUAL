using System;
using System.Text;
using System.IO;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;

using BCR.GARANTIAS.Comun;

namespace BCR.GARANTIAS.Entidades
{
    public class clsBitacora
    {

        #region Constantes

        private const string _desTabla                      = "des_tabla";
        private const string _codUsuario                    = "cod_usuario";
        private const string _codIP                         = "cod_ip";
        private const string _codOficina                    = "cod_oficina";
        private const string _codOperacion                  = "cod_operacion";
        private const string _fechaHora                     = "fecha_hora";
        private const string _codConsulta                   = "cod_consulta";
        private const string _codTipoGarantia               = "cod_tipo_garantia";
        private const string _codGarantia                   = "cod_garantia";
        private const string _codOperacionCrediticia        = "cod_operacion_crediticia";
        private const string _codConsulta2                  = "cod_consulta2";
        private const string _desCampoAfectado              = "des_campo_afectado";
        private const string _estAnteriorCampoAfectado      = "est_anterior_campo_afectado";
        private const string _estActualCampoAfectado        = "est_actual_campo_afectado";
        private const string _nombreUsuarioModifico         = "Nombre_Usuario_Modifico";
        private const string _desTipoGarantia               = "Tipo_Garantia";
        private const string _accionRealizada               = "Accion_Realizada";

        //Tags especiales
        private const string _tagBitacora                   = "BITACORA";
        private const string _tagDatos                      = "DATOS";

        #endregion Constantes

        #region Variables

        /// <summary>
        /// Nombre de la tabla, a nivel de base datos, que fue afectada
        /// </summary>
        private string desTabla;

        /// <summary>
        /// Identificaci�n del usuario que realiza la acci�n
        /// </summary>
        private string codUsuario;

        /// <summary>
        /// Direcci�n IP de la m�quina del usuario que realiza la acci�n
        /// </summary>
        private string codIP;

        /// <summary>
        /// C�digo de la oficina desde donde se realiza la acci�n
        /// </summary>
        private int codOficina;

        /// <summary>
        /// C�digo del tipo de acci�n realizada, don de 1 = INS, 2 = MOD y 3 = BOR
        /// </summary>
        private Enumeradores.Tipos_Accion codTipoOperacion;

        /// <summary>
        /// Fecha y hora en que se realiza la acci�n
        /// </summary>
        private DateTime fechaHora;

        /// <summary>
        /// Sentencia SQL generada
        /// </summary>
        private string codConsulta;

        /// <summary>
        /// C�digo del tipo de garant�a
        /// </summary>
        private short codTipoGarantia;

        /// <summary>
        /// N�mero de garant�a
        /// </summary>
        private string codGarantia;

        /// <summary>
        /// N�mero de operaci�n, bajo el formato Contabilidad - Oficina - Moneda - Producto - Num Operaci�n / Num. Contrato
        /// </summary>
        private string codOperacionCrediticia;

        /// <summary>
        /// Sentencia SQL generada, en caso de que se requiera almacenar una segunda 
        /// </summary>
        private string codConsulta2;

        /// <summary>
        /// Nombre del campo, a nivel de base de datos, que fue afectado
        /// </summary>
        private string desCampoAfectado;

        /// <summary>
        /// Valor anterior del campo afectado
        /// </summary>
        private string estAnteriorCampoAfectado;

        /// <summary>
        /// Valor reciente del campo afectado
        /// </summary>
        private string estActualCampoAfectado;      

        /// <summary>
        /// Nombre del usuari que modific�
        /// </summary>
        private string nombreUsuarioModifico;

        /// <summary>
        /// Descripcion del tipo de garantia
        /// </summary>
        private string desTipoGarantia;

        /// <summary>
        /// Descripcion de la accion que se realiz�, insert, update, delte
        /// </summary>
        private string accionRealizada;

        #region Generales

        /// <summary>
        /// Indicador que determina si la entidad es v�lida o no
        /// </summary>
        private bool entidadValida;

        /// <summary>
        /// Descripci�n del error
        /// </summary>
        private string desError;

        /// <summary>
        /// Indicador de que se present� un error de datos
        /// </summary>
        private bool errorDatos;

        #endregion

        #endregion Variables

        #region Propiedades

        /// <summary>
        /// Propiedad que obtiene y establece el nombre de la tabla afectada
        /// </summary>
        public string DescripcionTabla
        {
            get { return desTabla; }
            set { desTabla = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la identificaci�n del usuario que realiz� la acci�n
        /// </summary>
        public string IdUsuario
        {
            get { return codUsuario; }
            set { codUsuario = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la direcci�n IP de la m�quina desde donde se realiz� la acci�n
        /// </summary>
        public string DireccionIP
        {
            get { return codIP; }
            set { codIP = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el c�digo de la oficina desde donde se realiz� la acci�n
        /// </summary>
        public int CodigoOficina
        {
            get { return codOficina; }
            set { codOficina = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el tipo de acci�n realizada
        /// </summary>
        public Enumeradores.Tipos_Accion TipoOperacion
        {
            get { return codTipoOperacion; }
            set { codTipoOperacion = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la fecha y hora en que se registra la acci�n
        /// </summary>
        public DateTime FechaHora
        {
            get { return fechaHora; }
            set { fechaHora = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la sentencia SQL de la acci�n realizada
        /// </summary>
        public string Consulta
        {
            get { return codConsulta; }
            set { codConsulta = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el nombre de la tabla afectada
        /// </summary>
        public short TipoGarantia
        {
            get { return codTipoGarantia; }
            set { codTipoGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el n�mero de la garant�a
        /// </summary>
        public string NumeroGarantia
        {
            get { return codGarantia; }
            set { codGarantia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el n�mero de la operaci�n o del contrato
        /// </summary>
        public string NumeroOperacion
        {
            get { return codOperacionCrediticia; }
            set { codOperacionCrediticia = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la sentencia SQL de la acci�n realizada
        /// </summary>
        public string Consulta2
        {
            get { return codConsulta2; }
            set { codConsulta2 = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece del nmobre del campo afectado
        /// </summary>
        public string NombreCampoAfectado
        {
            get { return desCampoAfectado; }
            set { desCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el valor anterior del campo afectado
        /// </summary>
        public string ValorAnterior
        {
            get { return estAnteriorCampoAfectado; }
            set { estAnteriorCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece valor actual del campo afectado
        /// </summary>
        public string ValorActual
        {
            get { return estActualCampoAfectado; }
            set { estActualCampoAfectado = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el indicador de si la entidad es v�lida o no
        /// </summary>
        public bool EntidadValida
        {
            get { return entidadValida; }
            set { entidadValida = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la descripci�n del error encontrado
        /// </summary>
        public string DescripcionError
        {
            get { return desError; }
            set { desError = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece el nombre del usuario que modifico
        /// </summary>
        public string NombreUsuarioModifico
        {
            get { return nombreUsuarioModifico; }
            set { nombreUsuarioModifico = value; }
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
        /// Propiedad que obtiene y establece la descripcion del tipo de garantia
        /// </summary>
        public string AccionRealizada
        {
            get { return accionRealizada; }
            set { accionRealizada = value; }
        }

        /// <summary>
        /// Propiedad que obtiene y establece la indicaci�n de que se present� un error por problema de datos
        /// </summary>
        public bool ErrorDatos
        {
            get { return errorDatos; }
            set { errorDatos = value; }
        }

        #endregion Propiedades

        #region Constructores

        /// <summary>
        /// Constructor base de la clase
        /// </summary>
        public clsBitacora()
        {
            desTabla                    = string.Empty;
            codUsuario                  = string.Empty;
            codIP                       = string.Empty;
            codOficina                  = -1;
            codTipoOperacion            = Enumeradores.Tipos_Accion.Ninguna;
            fechaHora                   = DateTime.MinValue;
            codConsulta                 = string.Empty;
            codTipoGarantia             = -1;
            codGarantia                 = string.Empty;
            codOperacionCrediticia      = string.Empty;
            codConsulta2                = string.Empty;
            desCampoAfectado            = string.Empty;
            estAnteriorCampoAfectado    = string.Empty;
            estActualCampoAfectado      = string.Empty;
            entidadValida               = false;
            desError                    = string.Empty;
        }

        /// <summary>
        /// Constructor sobrecargado de la clase
        /// </summary>
        /// <param name="nombreTabla">Nombre de la tabla afectada</param>
        /// <param name="idUsuario">Identificaci�n del usuario que hace la afectaci�n</param>
        /// <param name="dirIP">Direcci�n IP de la m�quina del usuario que hace la afectaci�n</param>
        public clsBitacora(string nombreTabla, string idUsuario, string dirIP)
        {
            desTabla                    = nombreTabla;
            codUsuario                  = idUsuario;
            codIP                       = dirIP;
            codOficina                  = -1;
            codTipoOperacion            = Enumeradores.Tipos_Accion.Ninguna;
            fechaHora                   = DateTime.Now;
            codConsulta                 = string.Empty;
            codTipoGarantia             = -1;
            codGarantia                 = string.Empty;
            codOperacionCrediticia      = string.Empty;
            codConsulta2                = string.Empty;
            desCampoAfectado            = string.Empty;
            estAnteriorCampoAfectado    = string.Empty;
            estActualCampoAfectado      = string.Empty;
            entidadValida               = false;
            desError                    = string.Empty;
        }

        /// <summary>
        /// Constructor sobrecargado de la clase
        /// </summary>
        /// <param name="tramaDatosCambioGarantia">Trama con los datos a consultar</param>

        public clsBitacora(string tramaDatosCambioGarantia) 
        {

            desCampoAfectado = string.Empty;
            estAnteriorCampoAfectado = string.Empty;
            estActualCampoAfectado = string.Empty;
            fechaHora = DateTime.MinValue;
            codUsuario = string.Empty;
            nombreUsuarioModifico = string.Empty;

            if (tramaDatosCambioGarantia.Length > 0)
            {
                XmlDocument xmlTrama = new XmlDocument();
                string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };            

                try
                {
                    xmlTrama.LoadXml(tramaDatosCambioGarantia);
                }
                catch (Exception ex)
                {
                    errorDatos = true;
                    //desError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                    StringCollection parametros = new StringCollection();
                    //parametros.Add(Garantia);
                    //parametros.Add(Operacion);
                    parametros.Add(("El error se da al cargar la trama: " + ex.Message));

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    return;
                }

                if (xmlTrama.SelectSingleNode("//" + _tagBitacora) != null)
                {
                    XmlDocument xmlDatosCambioGarantia = new XmlDocument();

                    try
                    {
                        xmlDatosCambioGarantia.LoadXml(xmlTrama.SelectSingleNode("//" + _tagBitacora).OuterXml);
                    }
                    catch (Exception ex)
                    {
                        errorDatos = true;
                        //descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                        StringCollection parametros = new StringCollection();
                        //parametros.Add(Garantia);
                        //parametros.Add(Operacion);
                        parametros.Add(("El error se da al cargar la trama de la garant�a: " + ex.Message));

                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                        return;
                    }
                    if (xmlDatosCambioGarantia != null)
                        {                          
                            DateTime sfechaHora;
                        
                            try
                            {
                                desCampoAfectado = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _desCampoAfectado) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _desCampoAfectado).InnerText : string.Empty);
                                estAnteriorCampoAfectado = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _estAnteriorCampoAfectado) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _estAnteriorCampoAfectado).InnerText : string.Empty);
                                estActualCampoAfectado = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _estActualCampoAfectado) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _estActualCampoAfectado).InnerText : string.Empty);                                                        
                                fechaHora = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _fechaHora) != null) ? ((DateTime.TryParse((xmlDatosCambioGarantia.SelectSingleNode("//" + _fechaHora).InnerText), out sfechaHora)) ? ((sfechaHora != (new DateTime(1900, 01, 01))) ? sfechaHora : DateTime.MinValue) : DateTime.MinValue) : DateTime.MinValue);
                                codUsuario = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _codUsuario) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _codUsuario).InnerText : string.Empty);
                                nombreUsuarioModifico = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _nombreUsuarioModifico) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _nombreUsuarioModifico).InnerText : string.Empty);
                                desTipoGarantia = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _desTipoGarantia) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _desTipoGarantia).InnerText : string.Empty);
                                accionRealizada = ((xmlDatosCambioGarantia.SelectSingleNode("//" + _accionRealizada) != null) ? xmlDatosCambioGarantia.SelectSingleNode("//" + _accionRealizada).InnerText : string.Empty);

                            }
                            catch (Exception ex)
                            {
                                errorDatos = true;
                                // descripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, Garantia, Operacion, Mensajes.ASSEMBLY);

                                StringCollection parametros = new StringCollection();
                                //parametros.Add(Garantia);
                                //parametros.Add(Operacion);
                                parametros.Add(("El error se da al cargar los datos de la garant�a: " + ex.Message));

                                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_GARANTIAS, parametros, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                                return;
                            }
                        }//fin (xmlGarantia != null)

                  }// FIN xmlTrama.SelectSingleNode("//" + _tagBitacora) != null)

            } //fin  (tramaDatosCambioGarantia.Length > 0)

            //if (tramaInicial.Length == 0)
            //{
            //    tramaInicial = ConvertirAXML();
            //}

          //  tramaInicial = ConvertirAXML();

        }


        #endregion Constructores

        #region M�todos P�blicos

        //revisar si se utiliza este metodo
        public override string ToString()
        {
            string tramaDatosAInsertar = string.Empty;

            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el foemato
            XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.UTF8);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo raiz
            objEscritor.WriteStartElement("DATOS");

            //Inicializa el nodo que poseer� los datos que ser�n insertados en la bit�cora
            objEscritor.WriteStartElement("BITACORA");

            //Crea el nodo del nombre de la tabla
            objEscritor.WriteStartElement(_desTabla);
            objEscritor.WriteString(desTabla);
            objEscritor.WriteEndElement();

            //Crea el nodo de la identificaci�n del usuario que realiza la acci�n
            objEscritor.WriteStartElement(_codUsuario);
            objEscritor.WriteString(codUsuario);
            objEscritor.WriteEndElement();

            //Crea el nodo de la direcci�n ip desde donde se realiza la acci�n
            objEscritor.WriteStartElement(_codIP);
            objEscritor.WriteString(codIP);
            objEscritor.WriteEndElement();

            //Crea el nodo del c�digo de la oficina desde donde se realiza la acci�n
            objEscritor.WriteStartElement(_codOficina);
            objEscritor.WriteString((codOficina != -1) ? codOficina.ToString() : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del c�digo del tipo de la operaci�n realizada
            objEscritor.WriteStartElement(_codOperacion);
            objEscritor.WriteString((codTipoOperacion != Enumeradores.Tipos_Accion.Ninguna) ? ((int)codTipoOperacion).ToString() : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del c�digo de la fecha y hora en que se realiza la acci�n
            objEscritor.WriteStartElement(_fechaHora);
            objEscritor.WriteString((fechaHora != DateTime.MinValue) ? fechaHora.ToString("yyyyMMdd") : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del query sql de la acci�n
            objEscritor.WriteStartElement(_codConsulta);
            objEscritor.WriteString((codConsulta.Length > 0) ? codConsulta : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del c�digo del tipo de la garant�a
            objEscritor.WriteStartElement(_codTipoGarantia);
            objEscritor.WriteString((codTipoGarantia != -1) ? codTipoGarantia.ToString() : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del n�mero de la garant�a
            objEscritor.WriteStartElement(_codGarantia);
            objEscritor.WriteString((codGarantia.Length > 0) ? codGarantia : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del n�mero de la operaci�n crediticia
            objEscritor.WriteStartElement(_codOperacionCrediticia);
            objEscritor.WriteString((codOperacionCrediticia.Length > 0) ? codOperacionCrediticia : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del query sql de la segunda acci�n
            objEscritor.WriteStartElement(_codConsulta2);
            objEscritor.WriteString((codConsulta2.Length > 0) ? codConsulta2 : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del nombre del campo afectado
            objEscritor.WriteStartElement(_desCampoAfectado);
            objEscritor.WriteString((desCampoAfectado.Length > 0) ? desCampoAfectado : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del valor anterior del campo afectado
            objEscritor.WriteStartElement(_estAnteriorCampoAfectado);
            objEscritor.WriteString((estAnteriorCampoAfectado.Length > 0) ? estAnteriorCampoAfectado : "NULL");
            objEscritor.WriteEndElement();

            //Crea el nodo del valor anterior del campo afectado
            objEscritor.WriteStartElement(_estActualCampoAfectado);
            objEscritor.WriteString((estActualCampoAfectado.Length > 0) ? estActualCampoAfectado : "NULL");
            objEscritor.WriteEndElement();

            //Final del taga BITACORA
            objEscritor.WriteEndElement();

            //Final del tag DATOS
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            tramaDatosAInsertar = UtilitariosComun.GetStringFromStream(stream);

            //Cierre del xml document
            objEscritor.Close();

            return tramaDatosAInsertar;
        }

        public string ToString(bool camposComoPropiedades)
        {
            string tramaDatosAInsertar = string.Empty;
            XmlDocument xmlParteBitacora = new XmlDocument();

            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el foemato
            XmlTextWriter objEscritor = new XmlTextWriter(stream, Encoding.UTF8);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo raiz
            objEscritor.WriteStartElement("DATOS");

            //Inicializa el nodo que poseer� los datos que ser�n insertados en la bit�cora
            objEscritor.WriteStartElement(_tagBitacora);

            //Crea el nodo del nombre de la tabla
            objEscritor.WriteAttributeString(_desTabla, desTabla);

            //Crea el nodo de la identificaci�n del usuario que realiza la acci�n
            objEscritor.WriteAttributeString(_codUsuario, codUsuario);

            //Crea el nodo de la direcci�n ip desde donde se realiza la acci�n
            objEscritor.WriteAttributeString(_codIP, codIP);

            //Crea el nodo del c�digo de la oficina desde donde se realiza la acci�n
            if (codOficina != -1)
            {
                objEscritor.WriteAttributeString(_codOficina, codOficina.ToString());
            }

            //Crea el nodo del c�digo del tipo de la operaci�n realizada}
            if (codTipoOperacion != Enumeradores.Tipos_Accion.Ninguna)
            {
                objEscritor.WriteAttributeString(_codOperacion, ((int)codTipoOperacion).ToString());
            }

            //Crea el nodo del c�digo de la fecha y hora en que se realiza la acci�n
            if (fechaHora != DateTime.MinValue)
            {
                objEscritor.WriteAttributeString(_fechaHora, fechaHora.ToString("yyyyMMdd hh:mm:ss tt"));
            }
            //Crea el nodo del query sql de la acci�n
            if (codConsulta.Length > 0)
            {
                objEscritor.WriteAttributeString(_codConsulta, codConsulta);
            }

            //Crea el nodo del c�digo del tipo de la garant�a
            if (codTipoGarantia != -1)
            {
                objEscritor.WriteAttributeString(_codTipoGarantia, codTipoGarantia.ToString());
            }

            //Crea el nodo del n�mero de la garant�a
            if (codGarantia.Length > 0)
            {
                objEscritor.WriteAttributeString(_codGarantia, codGarantia);
            }

            //Crea el nodo del n�mero de la operaci�n crediticia
            if (codOperacionCrediticia.Length > 0)
            {
                objEscritor.WriteAttributeString(_codOperacionCrediticia, codOperacionCrediticia);
            }

            //Crea el nodo del query sql de la segunda acci�n
            if (codConsulta2.Length > 0)
            {
                objEscritor.WriteAttributeString(_codConsulta2, codConsulta2);
            }

            //Crea el nodo del nombre del campo afectado
            if (desCampoAfectado.Length > 0)
            {
                objEscritor.WriteAttributeString(_desCampoAfectado, desCampoAfectado);
            }

            //Crea el nodo del valor anterior del campo afectado
            if (estAnteriorCampoAfectado.Length > 0)
            {
                objEscritor.WriteAttributeString(_estAnteriorCampoAfectado, estAnteriorCampoAfectado);
            }

            //Crea el nodo del valor anterior del campo afectado
            if (estActualCampoAfectado.Length > 0)
            {
                objEscritor.WriteAttributeString(_estActualCampoAfectado, estActualCampoAfectado);
            }

            //Final del taga BITACORA
            objEscritor.WriteEndElement();

            //Final del tag DATOS
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            tramaDatosAInsertar = UtilitariosComun.GetStringFromStream(stream);

            //Cierre del xml document
            objEscritor.Close();


            xmlParteBitacora.LoadXml(tramaDatosAInsertar);

            tramaDatosAInsertar = xmlParteBitacora.SelectSingleNode("//" + _tagBitacora).OuterXml;

            return tramaDatosAInsertar;
        }

        #endregion M�todos P�blicos

        #region M�todos Privados

        private bool ValidarDatos()
        {
            entidadValida = true;

            if (desTabla.Length == 0)
            {
                entidadValida = false;
                desError = Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA, codGarantia, codOperacionCrediticia, Mensajes.ASSEMBLY);

                StringCollection parametros = new StringCollection();
                parametros.Add(codGarantia);
                parametros.Add(codOperacionCrediticia);
                parametros.Add("El nombre de la tabla no fue suministrada");

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA_DETALLE, parametros, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
            else if ((entidadValida) && (codIP.Length == 0))
            {
                entidadValida = false;
                desError = Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA, codGarantia, codOperacionCrediticia, Mensajes.ASSEMBLY);

                StringCollection parametros = new StringCollection();
                parametros.Add(codGarantia);
                parametros.Add(codOperacionCrediticia);
                parametros.Add("La direcci�n IP no fue suministrada");

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA_DETALLE, parametros, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
            else if ((entidadValida) && (codUsuario.Length == 0))
            {
                entidadValida = false;
                desError = Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA, codGarantia, codOperacionCrediticia, Mensajes.ASSEMBLY);

                StringCollection parametros = new StringCollection();
                parametros.Add(codGarantia);
                parametros.Add(codOperacionCrediticia);
                parametros.Add("La identificaci�n dle usuario no fue suministrada");

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA_DETALLE, parametros, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
            else if ((entidadValida) && (codTipoOperacion == Enumeradores.Tipos_Accion.Ninguna))
            {
                entidadValida = false;
                desError = Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA, codGarantia, codOperacionCrediticia, Mensajes.ASSEMBLY);

                StringCollection parametros = new StringCollection();
                parametros.Add(codGarantia);
                parametros.Add(codOperacionCrediticia);
                parametros.Add("El tipo de operaci�n no fue suministrado");

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA_DETALLE, parametros, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
            else if ((entidadValida) && (fechaHora == DateTime.MinValue))
            {
                entidadValida = false;
                desError = Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA, codGarantia, codOperacionCrediticia, Mensajes.ASSEMBLY);

                StringCollection parametros = new StringCollection();
                parametros.Add(codGarantia);
                parametros.Add(codOperacionCrediticia);
                parametros.Add("La fecha actual no fue suministrada");

                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_ALMACENANDO_BITACORA_DETALLE, parametros, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }

            return entidadValida;
        }


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
                objEscritor.WriteStartElement(_tagBitacora);

                //Crea el nodo de la descripcion del campo afectado
                objEscritor.WriteStartElement(_desCampoAfectado);
                objEscritor.WriteString(desCampoAfectado.ToString());
                objEscritor.WriteEndElement();

                //Crea el nodo de la estado anterior del campo afectado
                objEscritor.WriteStartElement(_estAnteriorCampoAfectado);
                objEscritor.WriteString(estAnteriorCampoAfectado.ToString());
                objEscritor.WriteEndElement();

                //Crea el nodo de la estado actual del campo afectado
                objEscritor.WriteStartElement(_estActualCampoAfectado);
                objEscritor.WriteString(estActualCampoAfectado.ToString());
                objEscritor.WriteEndElement();

                //Crea el nodo de la fecha de modificacion 
                objEscritor.WriteStartElement(_fechaHora);
                objEscritor.WriteString(fechaHora.ToString("yyyyMMdd"));
                objEscritor.WriteEndElement();

                //Crea el nodo de la cedula del usuario que modifico 
                objEscritor.WriteStartElement(_codUsuario);
                objEscritor.WriteString(codUsuario.ToString());
                objEscritor.WriteEndElement();

                //Crea el nodo del nombre del usuario que modifico 
                objEscritor.WriteStartElement(_nombreUsuarioModifico);
                objEscritor.WriteString(nombreUsuarioModifico.ToString());
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

        #endregion M�todos Privados
    }
}
