using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Xml;

namespace BCR.GARANTIAS.Comun
{
	/// <summary>
	/// Clases con métodos especiales para el proyecto.
	/// </summary>
	/// <remarks>
	/// Esta clase implementa métodos 
	/// </remarks>
	public static class UtilitariosComun
	{
		public static void RegistraEventLog(string Mensaje, System.Diagnostics.EventLogEntryType Level)
		{
			try
			{
				string logsource = ConfigurationManager.AppSettings.Get("LOGSOURCE");
				string eventlog = ConfigurationManager.AppSettings.Get("LOG");
				//eventlog=null; // solo para probar si el eventlog diese error comentar en produccion
				if (!EventLog.SourceExists(logsource))
				{
					EventLog.CreateEventSource(logsource, eventlog);
				}
				EventLog Log = new EventLog(eventlog);
				Log.Source = logsource;
				Log.WriteEntry(Mensaje, Level);
			}
			catch (Exception exp)
			{
				try
				{
					String rootPath = System.Web.HttpContext.Current.Request.PhysicalApplicationPath;
					string pathLog = ConfigurationManager.AppSettings.Get("PATHLOG");
					if (!string.IsNullOrEmpty(pathLog))
					{
						string strNombreArchivo = "Log" + DateTime.Now.ToString("yyyyMMdd") + ".txt";
						pathLog = Path.Combine(rootPath, pathLog);
						pathLog = Path.Combine(pathLog, strNombreArchivo);

						if (!File.Exists(pathLog))
						{
							using (StreamWriter sw = File.CreateText(pathLog))
							{
								sw.WriteLine("Archivo creado " + DateTime.Now.ToString());
								sw.WriteLine();
							}
						}

						using (StreamWriter sw = File.AppendText(pathLog))
						{
							sw.WriteLine("");
							sw.WriteLine("NUEVO EVENTO______Fecha y Hora:" + DateTime.Now.ToString() + "   -   Tipo: " + Level.ToString());
							sw.WriteLine("");
							sw.WriteLine("DESCRIPCION:");
							sw.WriteLine("");
							sw.Write(Mensaje);
							sw.WriteLine("");
							sw.WriteLine("");
						}
					}
				}
				catch (Exception ex)
				{
					string strMensaje = "Primer Error: " + exp.Message + " . Segundo Error: " + ex.Message + " Primer StackTrace: " + exp.StackTrace + " Segundo StackTrace: " + ex.StackTrace;
					throw (new Exception(strMensaje));
					//throw (new Exception(ex.Message + "\n Error Original: \n" + Mensaje));
				}
			}
		}


        /// <summary>
        /// Elimina los encabezados de la trama. Deja sólo el contenido del tag "DETALLE"
        /// </summary>
        /// <param name="strTramaXML">Trama a la que se le debe eliminar el encabezado.</param>
        /// <returns>Trama contenida en el tag "DETALLE"</returns>
        public static string QuitarEncabezados(string strTramaXML)
        {
            string strTramaRetornada = strTramaXML;

            if (!string.IsNullOrEmpty(strTramaXML.Trim()))
            {
                XmlNode nodoLista = null;
                XmlNode nodoDetalle = null;

                XmlDocument xmlDocumento = new XmlDocument();

                xmlDocumento.LoadXml(strTramaXML);

                //Se verifica si la trama brindada posee el tag DETALLE, de ser así, obtiene su contenido
                nodoDetalle = xmlDocumento.SelectSingleNode("//DETALLE");

                if (nodoDetalle != null)
                {
                    nodoLista = nodoDetalle.FirstChild;

                    if (nodoLista != null)
                    {
                        strTramaRetornada = nodoLista.OuterXml;
                    }
                }
            }

            return strTramaRetornada;
        }

        /// <summary>
        /// Obtiene el código y la descripción de la trama de respuesta
        /// </summary>
        /// <param name="strTramaXML">Trama a la que se le debe obtener el código y descripción de respuesta.</param>
        /// <returns>Arreglo de string con el código y la descripción</returns>
        public static string[] ObtenerCodigoMensaje(string strTramaXML)
        {
            string[] respuest = new string[4] { string.Empty, string.Empty, string.Empty, string.Empty };

            if (!string.IsNullOrEmpty(strTramaXML.Trim()))
            {
                XmlNode nodoCodigo = null;
                XmlNode nodoDescripcion = null;
                XmlNode nodoDetalle = null;
                XmlNode nodoLinea = null;

                XmlDocument xmlDocumento = new XmlDocument();

                xmlDocumento.LoadXml(strTramaXML);

                nodoCodigo = xmlDocumento.SelectSingleNode("//CODIGO");
                nodoDescripcion = xmlDocumento.SelectSingleNode("//MENSAJE");
                nodoDetalle = xmlDocumento.SelectSingleNode("//DETALLE");
                nodoLinea = xmlDocumento.SelectSingleNode("//LINEA");

                //agregar otro nodo

                if (nodoCodigo != null)
                    respuest[0] = nodoCodigo.InnerText;


                if (nodoDescripcion != null)
                    respuest[1] = nodoDescripcion.InnerText;

                if (nodoDetalle != null)
                    respuest[2] = nodoDetalle.InnerText;


                if (nodoLinea != null)
                    respuest[3] = nodoLinea.InnerText;

            }

            return respuest;
        }

		#region Método para simular el Datediff
		/// <summary>
		/// Devuelve la diferecia entre dos fechas segun se indique en howtocompare
		/// </summary>
		/// <param name="howtocompare">Y=Años, M=meses, D=Días, h=Horas, mi=minutos, s=segundos</param>
		/// <param name="startDate">fecha menor en el rango a comparar en la operacio</param>
		/// <param name="endDate">fecha mayor en el rango a comparar en la operacion</param>
		/// <returns>Diferencia entre las fechas</returns>
		public static double DateDiff(string howtocompare, System.DateTime startDate, System.DateTime endDate)
		{
			double diff = 0;
			System.TimeSpan TS = new System.TimeSpan(endDate.Ticks - startDate.Ticks);

			switch (howtocompare.ToLower())
			{
				case "y":
					diff = Convert.ToDouble(TS.TotalDays / 365);
					break;
				case "m":
					diff = Convert.ToDouble((TS.TotalDays / 365) * 12);
					break;
				case "d":
					diff = Convert.ToDouble(TS.TotalDays);
					break;
				case "h":
					diff = Convert.ToDouble(TS.TotalHours);
					break;
				case "mi":
					diff = Convert.ToDouble(TS.TotalMinutes);
					break;
				case "s":
					diff = Convert.ToDouble(TS.TotalSeconds);
					break;
			}

			return diff;
		}
		#endregion

        #region Método para tratar los caracteres especiales para le formato JSON

        /// <summary>
        /// Modifica los caracteres especiales de la cadena entrante, esto para el formato JSON
        /// </summary>
        /// <param name="texto">Texto al cual se le modificarán los caracteres especiales</param>
        /// <returns>Cadena formateada para JSON</returns>
        public static string EnquoteJSON(string texto)
        {
            if (texto == null || texto.Length == 0)
            {
                return "\"\"";
            }
            char caracter;
            int i;
            int len = texto.Length;
            StringBuilder sb = new StringBuilder(len + 4);
            string t;

            sb.Append('"');
            for (i = 0; i < len; i += 1)
            {
                caracter = texto[i];
                if ((caracter == '\\') || (caracter == '"') || (caracter == '>'))
                {
                    sb.Append('\\');
                    sb.Append('\\');
                    sb.Append(caracter);
                }
                else if (caracter == '\b')
                    sb.Append("\\\\b");
                else if (caracter == '\t')
                    sb.Append("\\\\t");
                else if (caracter == '\n')
                    sb.Append("\\\\n");
                else if (caracter == '\f')
                    sb.Append("\\\\f");
                else if (caracter == '\r')
                    sb.Append("\\\\r");
                else
                {
                    if (caracter < ' ')
                    {
                        //t = "000" + Integer.toHexString(c); 
                        string tmp = new string(caracter, 1);
                        t = "000" + int.Parse(tmp, System.Globalization.NumberStyles.HexNumber);
                        sb.Append("\\\\u" + t.Substring(t.Length - 4));
                    }
                    else
                    {
                        sb.Append(caracter);
                    }
                }
            }
            sb.Append('"');
            return sb.ToString();
        } 

        #endregion

        public static string GetStringFromStream(Stream stream)
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
                return string.Empty;
        }
	}
}

