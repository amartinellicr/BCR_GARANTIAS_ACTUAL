using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Xml;
using System.Web;
using System.IO;
using LiderSoft.FrameWork.Comun;
using BCRGarantias.Contenedores;
using System.Threading;

namespace BCRGARANTIAS.Negocios
{
    //Clase que crea un xml de consulta genérico 
    public class CreaXML
    {
        #region Crear Xml Consulta Tarjeta SISTAR
        /// <summary>
        /// Método que crea un xml para realizar la consulta de una tarjetaen SISTAR.
        /// </summary>
        /// <param name="strTarjeta">Número de la tarjeta a consultar</param>
        /// <returns>String con la trama formada</returns>
        public string creaXMLConsultaTarjetaSISTAR(string strTarjeta, string strTipoGarantia)
        {   
            string trama = string.Empty;

            MemoryStream stream = new MemoryStream(200000);

            //Crea un escritor de XML con el path y el formato
            XmlTextWriter objEscritor = new XmlTextWriter(stream , Encoding.UTF8);

            //Se inicializa para que idente el archivo
            objEscritor.Formatting = Formatting.None;

            //Inicializa el Documento XML
            objEscritor.WriteStartDocument();

            //Inicializa el nodo raiz
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoTramaXML"].ToString());

            //Inicializa el nodo header
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoCabecera"].ToString());

            //Crea el nodo referencia
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoReferencia"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["REFERENCIA"]);
            objEscritor.WriteEndElement();

            //Crea el nodo del canal de comunicacion
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoCanal"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["CANAL"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo TRANS
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoTransaccion"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["TRANS"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo ACCION
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoAccion"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["ACCION"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo usuario
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoUsuario"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["USUARIO"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo OFICINAORIGEN
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoOficinaOrigen"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["OFICINAORIGEN"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo ESTACION
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoEstacion"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["ESTACION"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo fecha hora
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoFechaHora"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["FECHAHORA"].ToString());
            objEscritor.WriteEndElement();

            objEscritor.WriteEndElement();

            //Inicializa el nodo SISTAR
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoSistar"].ToString());

            //Crea el nodo del canal de comunicacion
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoCanal"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["CANAL"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo del tipo de transacción
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoTransaccion"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["TRANS"].ToString());
            objEscritor.WriteEndElement();
            
            //Crea el nodo de la acción
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoAccion"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["ACCION"].ToString());
            objEscritor.WriteEndElement();

            //Crea el nodo del tipo de movimiento
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoTipoMovimiento"].ToString());
            objEscritor.WriteString(ConfigurationManager.AppSettings["TIPO_MOVIMIENTO"].ToString());
            objEscritor.WriteEndElement();


            //Crea el nodo del número de tarjeta
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoNumeroTarjeta"].ToString());
            objEscritor.WriteString(strTarjeta);
            objEscritor.WriteEndElement();

            //Crea el nodo del tipo de garantía
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoTipoGarantia"].ToString());
            objEscritor.WriteString(strTipoGarantia);
            objEscritor.WriteEndElement();

            //Crea el nodo del estado de la tarjeta
            objEscritor.WriteStartElement(ConfigurationManager.AppSettings["nodoEstadoTarjeta"].ToString());
            objEscritor.WriteString(string.Empty);
            objEscritor.WriteEndElement();

            objEscritor.WriteEndElement();

            //Final de la raiz
            objEscritor.WriteEndElement();

            //Final del documento
            objEscritor.WriteEndDocument();

            //Flush
            objEscritor.Flush();

            trama = GetStringFromStream(stream);

            //Cierre del xml document
            objEscritor.Close();

            return trama;
        }
    #endregion

        #region Métodos Generales
        private string GetStringFromStream(Stream stream)
        {
            stream.Position = 0;
            if ((stream != null) && (stream.Length > 0))
            {
                using (StreamReader reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
            else
                return null;
        }

        #endregion
    }
}
