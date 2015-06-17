using System;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Text;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for CGenerarXML.
	/// </summary>
	public class CGenerarXML
	{
		#region Header
		/// <summary>
		/// Este método genera el encabezado de la trama XML
		/// </summary>
		/// <param name="strReferencia">Referencia</param>
		/// <param name="strCanal">Canal</param>
		/// <param name="strTrans">Trans</param>
		/// <param name="strCodigoRespuesta">Código de Respuesta</param>
		/// <param name="strDescripcion">Descripción</param>
		/// <param name="strUsuario">Usuario</param>
		/// <param name="strOficinaOrigen">Oficina Origen</param>
		/// <param name="strEstacion">Estación</param>
		/// <param name="strFechaHora">Fecha - Hora</param>
		/// <returns></returns>
		private string GenerarHeaderXML(string strReferencia, string strCanal, string strTrans, 
										string strCodigoRespuesta, string strDescripcion, 
										string strUsuario, string strOficinaOrigen, 
										string strEstacion, string strFechaHora)
		{
			string strXML;
			strXML = "<HEADER>";
			strXML = strXML + "<REFERENCIA>" + strReferencia + "</REFERENCIA>";
			strXML = strXML + "<CANAL>" + strCanal + "</CANAL>";
			strXML = strXML + "<TRANS>" + strTrans + "</TRANS>";
			strXML = strXML + "<CODIGORESPUESTA>" + strCodigoRespuesta + "</CODIGORESPUESTA>";
			strXML = strXML + "<DESCRIPCION>" + strDescripcion + "</DESCRIPCION>";
			strXML = strXML + "<USUARIO>" + strUsuario + "</USUARIO>";
			strXML = strXML + "<OFICINAORIGEN>" + strOficinaOrigen + "</OFICINAORIGEN>";
			strXML = strXML + "<ESTACION>" + strEstacion + "</ESTACION>";
			strXML = strXML + "<FECHAHORA>" + strFechaHora + "</FECHAHORA>";
			strXML = strXML + "</HEADER>";
			return strXML;
		}
		#endregion 

		#region Eventos Préstamos

		#region PRC18
		/// <summary>
		/// Este método permite obtener todas las garantías de una Operación Crediticia
		/// </summary>
		/// <param name="strReferencia"></param>
		/// <param name="strCanal"></param>
		/// <param name="strTrans"></param>
		/// <param name="strCodigoRespuesta"></param>
		/// <param name="strDescripcion"></param>
		/// <param name="strUsuario"></param>
		/// <param name="strOficinaOrigen"></param>
		/// <param name="strEstacion"></param>
		/// <param name="strFechaHora"></param>
		/// <param name="strIspec"></param>
		/// <param name="strFijo"></param>
		/// <param name="strProximo"></param>
		/// <param name="strAyuda"></param>
		/// <param name="strFecha"></param>
		/// <param name="strContabilidad"></param>
		/// <param name="strOficina"></param>
		/// <param name="strMoneda"></param>
		/// <param name="strProducto"></param>
		/// <param name="strOperacion"></param>
		/// <param name="strClase"></param>
		/// <param name="strNumero"></param>
		/// <returns></returns>
		public string PRC18(string strReferencia, string strCanal, string strTrans, string strCodigoRespuesta,
							string strDescripcion, string strUsuario, string strOficinaOrigen, string strEstacion,
							string strFechaHora, string strIspec, string strFijo, string strProximo,
							string strAyuda, string strFecha, string strContabilidad, string strOficina,
							string strMoneda, string strProducto, string strOperacion, string strClase,
							string strNumero)
		{
			string strXML;

			strXML = "<TRAMAXML>";

			strXML = strXML + GenerarHeaderXML(strReferencia, strCanal, strTrans, 
				strCodigoRespuesta, strDescripcion, strUsuario, 
				strOficinaOrigen, strEstacion, strFechaHora);

			strXML = strXML + "<PRC18>" + "<ISPEC>" + strIspec + "</ISPEC>";
			strXML = strXML + "<FIJO>" + strFijo + "</FIJO>";
			strXML = strXML + "<PROXIMO>" + strProximo + "</PROXIMO>";
			strXML = strXML + "<AYUDA>" + strAyuda + "</AYUDA>";
			strXML = strXML + "<FECHA>" + strFecha + "</FECHA>";
			strXML = strXML + "<PCO-CONT>" + strContabilidad + "</PCO-CONT>";
			strXML = strXML + "<PCO-OFIC>" + strOficina + "</PCO-OFIC>";
			strXML = strXML + "<PCO-MONE>" + strMoneda + "</PCO-MONE>";
			strXML = strXML + "<PCO-PROD>" + strProducto + "</PCO-PROD>";
			strXML = strXML + "<PCO-OPERA>" + strOperacion + "</PCO-OPERA>";
			strXML = strXML + "<CLASE>" + strClase + "</CLASE>";
			strXML = strXML + "<NUMERO>" + strNumero + "</NUMERO>";
			strXML = strXML + "</PRC18>";
			strXML = strXML + "</TRAMAXML>";

			return strXML;
		}
		#endregion

		#endregion
	}
}


