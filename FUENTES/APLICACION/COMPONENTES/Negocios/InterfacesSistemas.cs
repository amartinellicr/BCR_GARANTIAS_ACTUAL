using System;
using System.Data;
using System.Xml;
using System.Configuration;
using System.Net.Sockets;
using System.Net;

using Negocios.BCR.MQ.Servicios;
using Negocios.BCCR.IndicadoresEconomicos;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Comun;

namespace Negocios
{
    /// <summary>
    /// Clase que maneja la comunicación con otros sistemas
    /// </summary>
    public class InterfacesSistemas
    {
        #region Variables Globales

        WSMQ BCRMQServicios;
        wsIndicadoresEconomicos BCCRServicios;

        #endregion Variables Globales

        #region Constructores de la clase

        /// <summary>
        /// Constructor de la clase
        /// </summary>
        public InterfacesSistemas()
        {
        }

        /// <summary>
        /// Constructor de la clase
        /// </summary>
        /// <param name="codInterfaz">Código del sistema con el que se desea establecer la comunicación</param>
        public InterfacesSistemas(int codInterfaz)
        {
            switch (codInterfaz)
            {
                case 0:
                    BCRMQServicios = new WSMQ();
                    BCRMQServicios.Url = ConfigurationManager.AppSettings.Get("WSMQSERVICIOS_URL");
                    BCRMQServicios.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;
                    BCRMQServicios.Timeout = -1;
                    break;
                case 1:
                    BCCRServicios = new wsIndicadoresEconomicos();
                    BCCRServicios.Url = ConfigurationManager.AppSettings.Get("WSBCCR_URL");
                    BCCRServicios.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;
                    BCCRServicios.Timeout = -1;
                    break;
                default:
                    break;
            }
        }

        #endregion Constructores de la clase

        #region Métodos públicos

        #region Métodos validar tarjetas

        #region Método ValidarTarjetaSISTAR: valida que el número de tarjeta ingresado exista en SISTAR

        /// <summary>
        /// Valida que el número de tarjeta ingresado exista en SISTAR y modifica el tipo de garantía en caso de ser necesario
        /// </summary>
        /// <param name="strTarjeta">
        /// Número de tarjeta que será modificada
        /// </param>
        /// <param name="strTipoGarantia">
        /// Tipo de garantía que a la que se actualizará la tarjeta
        /// </param>
        /// <returns>
        /// Trama de respuesta obtenida en la consulta con MQ a SISTAR
        /// </returns>
        public string ValidarTarjetaSISTAR(string strTarjeta, string strTipoGarantia)
        {
            try
            {
                /*valida que los parámetros de entrada no sean nulos*/
                string _numeroTarjeta = (strTarjeta != null) ? strTarjeta : String.Empty;
                string _tipoGarantia = (strTipoGarantia != null) ? strTipoGarantia : String.Empty;

                /*variable para almacenar la trama de respuesta de MQ*/
                string _tramaRespuesta = String.Empty;

                /*obtiene la trama de consulta para MQ*/
                string _tramaTarjetaSISTAR = new CreaXML().creaXMLConsultaTarjetaSISTAR(_numeroTarjeta, _tipoGarantia);

                /*obtiene la trama de respuesta de MQ para la consulta realizada*/
                _tramaRespuesta = BCRMQServicios.MQSistar(_tramaTarjetaSISTAR);

                /*retorna la trama de respuesta obtenida*/
                return _tramaRespuesta;
            }
            catch (SocketException objExcepcion)
            {
                throw new Exception((Mensajes.Obtener(Mensajes._errorConexionWebServicesDetalle, "MQ - SISTAR", Mensajes.ASSEMBLY)), objExcepcion.InnerException);
            }
            catch (WebException objExcepcion)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorConexionWebServicesDetalle, "MQ - SISTAR", Mensajes.ASSEMBLY)), objExcepcion.InnerException);
            }
            catch (Exception e)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorValidandoTarjeta, Mensajes.ASSEMBLY)), e);
            }
        }/*fin del método */

        #endregion Método ValidarTarjetaSISTAR: valida que el número de tarjeta ingresado exista en SISTAR

        #endregion Métodos validar tarjetas

        #region Tipos de Cambio

        /// <summary>
        /// Obtiene el tipo de cambio para moneda en fecha determinada
        /// </summary>
        /// <param name="moneda">
        /// Tipo de moneda para la cual se solicitará el tipo de cambio
        /// </param>
        /// <param name="fecha">
        /// Fecha para la cual se solicitará el tipo de cambio
        /// </param>
        /// <returns>
        /// Decimal con el tipo de cambio para la fecha y moneda solicitadas
        /// </returns>
        public decimal ObtenerTipoCambioCompra(Enumeradores.Monedas moneda, DateTime fecha)
        {
            try
            {
                decimal _tipoCambio = 0;

                _tipoCambio = ObtenerTipoCambioCompra(moneda, fecha, fecha);

                return _tipoCambio;
            }
            catch (ExcepcionBase eb)
            {
                throw eb;
            }
            catch (Exception e)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoTipoCambioBCCR, Mensajes.ASSEMBLY)), e);
            }
        }/*fin del método ObtenerTipoCambio*/

        public decimal ObtenerTipoCambioCompra(Enumeradores.Monedas moneda, DateTime fechaInicial, DateTime fechaFinal)
        {
            try
            {
                decimal _tipoCambio = 0;

                if (fechaInicial > fechaFinal)
                {
                    throw new ExcepcionBase(Mensajes.Obtener(Mensajes._errorObteniendoTipoCambioBCCRFechas, Mensajes.ASSEMBLY));
                }

                string _nombre = "BCR";
                string _subNiveles = "N";
                string _fechaInicial = fechaInicial.ToShortDateString();
                string _fechaFinal = fechaFinal.ToShortDateString();
                string _indicador = String.Empty;

                string _xmlTipoCambio = string.Empty;
                DataTable _dtTipoCambio = new DataTable();

                switch (moneda)
                {
                    case Enumeradores.Monedas.Dolares:
                        _indicador = "317";
                        break;

                    case Enumeradores.Monedas.Euros:
                        _indicador = "333";
                        break;

                    case Enumeradores.Monedas.UDES:
                        _indicador = "347";
                        break;

                    default:
                        _tipoCambio = 1;
                        break;
                }/*fin del switch (moneda)*/

                if (!String.IsNullOrEmpty(_indicador))
                {
                    BCCRServicios.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;
                    _xmlTipoCambio = BCCRServicios.ObtenerIndicadoresEconomicosXML(_indicador, _fechaInicial, _fechaFinal, _nombre, _subNiveles);

                    /*recorre la trama para obtener la información correspondiente*/
                    if (_xmlTipoCambio != string.Empty)
                    {
                        XmlDocument docTrama = new XmlDocument();

                        docTrama.LoadXml(_xmlTipoCambio);

                        /*obtiene la información almacenada en el nodo TramaXML y que es el que contiene toda la información*/
                        XmlNode oNodoTrama = docTrama.SelectSingleNode("string");

                        /*obtiene la información almacenada en el nodo cabecera del XML*/
                        XmlNode oNodoDatos = oNodoTrama.SelectSingleNode("Datos_de_INGC011_CAT_INDICADORECONOMIC");

                        XmlNode oNodoIndicadoresEconomicos = oNodoDatos.SelectSingleNode("INGC011_CAT_INDICADORECONOMIC");

                        if (oNodoIndicadoresEconomicos.HasChildNodes)
                        {
                            XmlNode oNodoTipoCambio = oNodoIndicadoresEconomicos.SelectSingleNode("NUM_VALOR");
                            _tipoCambio = Convert.ToDecimal(oNodoTipoCambio.InnerText);

                        }/*fin del if(oNodoCodigoRespuesta.HasChildNodes)*/

                    }/*fin del if (_xmlTipoCambio != string.Empty)*/

                }/*fin del if (!String.IsNullOrEmpty(_indicador))*/

                return _tipoCambio;
            }
            catch (ExcepcionBase eb)
            {
                throw eb;
            }
            catch (SocketException objExcepcion)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorConexionWebServicesDetalle, "BCCR", Mensajes.ASSEMBLY)), objExcepcion.InnerException);
            }
            catch (WebException objExcepcion)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorConexionWebServicesDetalle, "BCCR", Mensajes.ASSEMBLY)), objExcepcion.InnerException);
            }
            catch (Exception e)
            {
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes._errorObteniendoTipoCambioBCCRFechas, Mensajes.ASSEMBLY)), e);
            }

        }/*fin del método ObtenerTipoCambio*/

        #endregion Tipos de Cambio

        #endregion Métodos públicos
    }
}
