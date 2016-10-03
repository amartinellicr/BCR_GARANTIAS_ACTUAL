using System;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Class1.
    /// </summary>
    public class Utilitarios
	{
        #region Constantes
            private const string BACKSLASH = "\\";
            private const string SLASH = "/";
        #endregion

		/// <summary>
		/// Función que da el focus al control indicado en el parametro oCtrl
		/// </summary>
		/// <param name="oCtrl">Control a dar el focus</param>
		/// <param name="oPage">Pagina donde se encuentra el control</param>
		public void SetFocus(System.Web.UI.Control oCtrl, System.Web.UI.Page oPage)
		{
			string strJava = "<SCRIPT language='javascript'>" + "document.getElementById('" + oCtrl.ID + "').focus() </SCRIPT>";
  
			oPage.ClientScript.RegisterStartupScript(oPage.GetType(),"focus", strJava);
		
		}//SetFocus

		/// <summary>
		/// Función que da el focus al control indicado en el parametro oCtrl
		/// </summary>
		/// <param name="oCtrl">Control a dar el focus</param>
		/// <param name="oPage">Pagina donde se encuentra el control</param>
		public void SetFocus(System.Web.UI.UserControl oCtrl, System.Web.UI.Page oPage)
		{
			string strJava = "<SCRIPT language='javascript'>" + "document.getElementById('" + oCtrl.ID + "_COMBO').focus() </SCRIPT>";

            oPage.ClientScript.RegisterStartupScript(oPage.GetType(), "focus", strJava);
		
		}//SetFocus

		/// <summary>
		/// Función que valida si una fecha es válida o no.
		/// </summary>
		/// <param name="nAnno">Año de la fecha</param>
		/// <param name="nMes">Mes de la fecha</param>
		/// <param name="nDia">Día de la fecha</param>
		/// <returns>True si la fecha es valida</returns>
		public bool EsFechaValida(int nAnno, int nMes, int nDia)
		{
			DateTime dtFecha;
			try
			{
				dtFecha = new DateTime(nAnno, nMes, nDia);
				return true;
			}
			catch
			{
				return false;
			}
		}

		/// <summary>
		/// Función que valida si un objeto es nulo o no.
		/// </summary>
		/// <param name="oValor"></param>
		/// <param name="oNull"></param>
		/// <returns></returns>
		public object IsNull(object oValor, object oNull)
		{
			if (oValor==null || oValor.GetType().Name=="DBNull")
				return oNull;
			else
				return oValor;
		}

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
                    string rootPath = string.Empty;

                    if ((System.Web.HttpContext.Current != null) && (System.Web.HttpContext.Current.Request != null))
                    {
                        rootPath = System.Web.HttpContext.Current.Request.PhysicalApplicationPath;
                    }
                    else
                    {
                        Assembly assembly = Assembly.GetExecutingAssembly();
                        string rutaLibreria = assembly.CodeBase;
                        rutaLibreria = rutaLibreria.Substring(8, rutaLibreria.Length - 8);
                        rutaLibreria = rutaLibreria.Replace(SLASH, BACKSLASH);
                        rutaLibreria = rutaLibreria.Substring(0, rutaLibreria.LastIndexOf(BACKSLASH));
                        rootPath = rutaLibreria;
                    }

                    string pathLog = ConfigurationManager.AppSettings.Get("PATHLOG");

                    if (pathLog.Length > 0)
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

	}
}
