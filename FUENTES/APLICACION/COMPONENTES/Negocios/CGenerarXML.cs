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

            string[] listaCampos = new string[] { strReferencia, strCanal, strTrans, strCodigoRespuesta, strDescripcion, strUsuario, strOficinaOrigen,
                                                  strEstacion, strFechaHora};

            string strXML = string.Format("<HEADER><REFERENCIA>{0}</REFERENCIA><CANAL>{1}</CANAL><TRANS>{2}</TRANS><CODIGORESPUESTA>{3}</CODIGORESPUESTA><DESCRIPCION>{4}</DESCRIPCION><USUARIO>{5}</USUARIO><OFICINAORIGEN>{6}</OFICINAORIGEN><ESTACION>{7}</ESTACION><FECHAHORA>{8}</FECHAHORA></HEADER>", listaCampos);

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
            string encabezadoTrama = GenerarHeaderXML(strReferencia, strCanal, strTrans,
                                                      strCodigoRespuesta, strDescripcion, strUsuario,
                                                      strOficinaOrigen, strEstacion, strFechaHora);

            string[] listaCampos = new string[] { encabezadoTrama, strIspec, strFijo, strProximo, strAyuda, strFecha, strContabilidad, strOficina,
                                                  strMoneda, strProducto, strOperacion, strClase, strNumero};

            string strXML = string.Format("<TRAMAXML>{0}<PRC18><ISPEC>{1}</ISPEC><FIJO>{2}</FIJO><PROXIMO>{3}</PROXIMO><AYUDA>{4}</AYUDA><FECHA>{5}</FECHA><PCO-CONT>{6}</PCO-CONT><PCO-OFIC>{7}</PCO-OFIC><PCO-MONE>{8}</PCO-MONE><PCO-PROD>{9}</PCO-PROD><PCO-OPERA>{10}</PCO-OPERA><CLASE>{11}</CLASE><NUMERO>{12}</NUMERO></PRC18></TRAMAXML>");

			return strXML;
		}
		#endregion

		#endregion
	}
}


