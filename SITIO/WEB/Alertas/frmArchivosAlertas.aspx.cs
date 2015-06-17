using System;
using System.Collections.Generic;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Data.OleDb;
using System.IO;
using System.Net;
using System.Security.AccessControl;
using System.Security.Principal;
using Excel;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Utilidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Forms
{
    public partial class Alertas_frmArchivosAlertas : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;
        protected Button Button1;
        protected decimal nTipoCambio = 0;
        private BCR.Seguridad.Cryptography.TripleDES oSeguridad = new BCR.Seguridad.Cryptography.TripleDES();

        private ZipUtil zUtil = new ZipUtil();

        /// <summary>
        /// Listade los archivos que pueden ser descargados
        /// </summary>
        private List<string>  ListaArchivos;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnGenerarDescargar.Click += new EventHandler(btnGenerarDescargar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnGenerarDescargar.Attributes["onclick"] = "javascript:return confirm('Este proceso puede tardar algunos minutos... ¿Está seguro que desea generar los archivos seleccionados?')";

            ListaArchivos = new List<string>();
            
            if (!IsPostBack)
            {
                try
                {
                    if (Global.UsuarioSistema.Length > 0)
                    {
                        int numRol = int.Parse(((Application["MNU_GENERAR_ARCHIVO_ALERTAS"].ToString()).Length > 0 ? Application["MNU_GENERAR_ARCHIVO_ALERTAS"].ToString() : "-1"));

                        if (numRol != -1)
                        {
                            if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GENERAR_ARCHIVO_ALERTAS"].ToString())))
                            {
                                //El usuario no tiene acceso a esta página
                                throw new Exception("ACCESO DENEGADO");
                            }
                        }
                        else
                        {
                            UtilitariosComun.RegistraEventLog("El rol es erróneo.", System.Diagnostics.EventLogEntryType.Error);
                        }
                    }
                    else
                    {
                        UtilitariosComun.RegistraEventLog("El usuario está vacío", System.Diagnostics.EventLogEntryType.Error);
                    }
                }
                catch (Exception ex)
                {
                    string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                    strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Alertas"));

                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_GENERAL_APLICACION_DETALLE, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);


                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Acceso Denegado" +
                                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                                        "&bBotonVisible=0", true);
                    else
                        Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando Página" +
                                        "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_GENERAL_APLICACION, Mensajes.ASSEMBLY) +
                                        "&bBotonVisible=0", true);
                }
            }
        }

        private void btnGenerarDescargar_Click(object sender, System.EventArgs e)
        {
            WindowsImpersonationContext _objContext = null;
            string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
            string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
            string dominio = Application["DOMINIO_DEFAULT"].ToString();
            string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();
            int codCataloIndIns = Convert.ToInt32(Application["CAT_INSCRIPCION"].ToString());

            _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio);

            if (_objContext != null)
            {
                try
                {
                    if (ValidarDatos())
                    {
                        btnGenerarDescargar.Enabled = false;


                        //Genera el archivo de alertas sobre los indicadores de inscripción que se ajustarán
                        if (chkAlertaInscripcion.Checked)
                        {
                            EliminarArchivos("Indicadores de Inscripción por Cambiar");
                            Gestor.GenerarAlertasInscripcionTXT(strRuta, Global.UsuarioSistema, codCataloIndIns, false);
                            ComprimirArchivo(strRuta, "Indicadores de Inscripción por Cambiar.txt", strRuta + "Indicadores de Inscripción por Cambiar.zip");

                            ListaArchivos.Add("Indicadores de Inscripción por Cambiar.zip");
                        }

                        DescargarArchivos(strRuta);
                    }
                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos solicitados. Por favor reintente. Detalle:" + ex.Message), EventLogEntryType.Error);

                    lblMensaje.Text = "Se presentaron problemas generando los archivos solicitados. Por favor reintente.";
                }
                finally
                {
                    btnGenerarDescargar.Enabled = true;
                    _objContext.Undo();
                }
            }
            else
            {
                lblMensaje.Text = "La impersonalización es nula";
                lblMensaje.Visible = true;
            }
        }

        #endregion

        #region Métodos Privados

        private bool ValidarDatos()
        {
            lblMensaje.Text = "";
            if (!chkAlertaInscripcion.Checked)
            {
                lblMensaje.Text = "Debe seleccionar algún archivo para generar.";
                return false;
            }

            return true;
        }

        private void ComprimirArchivo(string strRutaOrigen, string strArchivoOrigen, string strArchivoDestino)
        {
            ZipOutputStream zipOut = new ZipOutputStream(File.Create(strArchivoDestino));

            string strArchOrigen = Path.Combine(strRutaOrigen, strArchivoOrigen);

            FileInfo fi = new FileInfo(strArchOrigen);
            ZipEntry entry = new ZipEntry(fi.Name);
            FileStream sReader = File.OpenRead(strArchOrigen);
            byte[] buff = new byte[Convert.ToInt32(sReader.Length)];
            sReader.Read(buff, 0, (int)sReader.Length);
            entry.DateTime = fi.LastWriteTime;
            entry.Size = sReader.Length;
            sReader.Close();
            zipOut.PutNextEntry(entry);
            zipOut.Write(buff, 0, buff.Length);
            zipOut.Finish();
            zipOut.Close();
        }

        private void EliminarArchivos(string strNombreArchivo)
        {
            try
            {
                string strRutaArchivos = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

                DirectoryInfo di = new DirectoryInfo(strRutaArchivos);

                FileInfo[] rgFiles = di.GetFiles(strNombreArchivo + ".*");
                foreach (FileInfo fi in rgFiles)
                {
                    fi.Delete();
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
                Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos solicitados. Detalle:" + ex.Message), EventLogEntryType.Error);
            }
        }

        private void EliminarArchivosXLS()
        {

            string strRutaArchivos = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

            DirectoryInfo di = new DirectoryInfo(strRutaArchivos);

            FileInfo[] rgFiles = di.GetFiles("*.xls");
            foreach (FileInfo fi in rgFiles)
            {
                fi.Delete();
            }

            rgFiles = di.GetFiles("*.xlsx");
            foreach (FileInfo fi in rgFiles)
            {
                fi.Delete();
            }
        }

        /// <summary>
        /// Permite descargar los archivos una vez que han sido generados
        /// </summary>
        /// <param name="strRuta">Ruta del archivo a descargar</param>
        private void DescargarArchivos(string strRuta)
        {
            string strNombreArchivo = string.Empty;
            
            try
            {
                if (ListaArchivos.Count > 0)
                {
                    DirectoryInfo di = new DirectoryInfo(strRuta);

                    foreach (string archivo in ListaArchivos)
                    {
                        FileInfo[] rgFiles = di.GetFiles((archivo + "*"));

                        foreach (FileInfo fi in rgFiles)
                        {
                            strNombreArchivo = fi.Name.ToString();

                            if (File.Exists(fi.FullName.ToString()))
                            {
                                //Crea una instancia del objeto Response
                                Response.Clear();
                                Response.HeaderEncoding = System.Text.Encoding.Default;
                                Response.AddHeader("Content-Disposition", "attachment; filename=" + fi.Name.ToString());
                                Response.AddHeader("Content-Length", fi.Length.ToString());
                                Response.ContentType = RetornaTipoContenido(fi.Extension.ToString());//"application/octet-stream";
                                Response.WriteFile(fi.FullName.ToString());
                                Response.Flush();
                                Response.Close();
                            }
                            else
                            {
                                //lblMensaje.Text = Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertas, strNombreArchivo, Mensajes.ASSEMBLY);
                                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertasDetalle, strNombreArchivo, "El archivo no existe.", Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                            }
                        }
                    }
                }
                else
                {
                    lblMensaje.Text = "No existen archivos que descargar";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertas, strNombreArchivo, Mensajes.ASSEMBLY);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertasDetalle, strNombreArchivo, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
        }

        /// <summary>
        /// Retorna el tip ode contenido, de acuerdo a la extensión del archivo
        /// </summary>
        /// <param name="strExtensionArchivo">Estensión del archivo del cual se requiere el tipo de contenido</param>
        /// <returns>Cadena con el tipo de contenido</returns>
        private string RetornaTipoContenido(string strExtensionArchivo)
        {
            switch (strExtensionArchivo)
            {
                case ".htm":
                case ".html":
                case ".log":
                    return "text/HTML";
                case ".txt":
                    return "text/plain";
                case ".doc":
                    return "application/ms-word";
                case ".tiff":
                case ".tif":
                    return "image/tiff";
                case ".asf":
                    return "video/x-ms-asf";
                case ".avi":
                    return "video/avi";
                case ".zip":
                    return "application/zip";
                case ".xls":
                case ".csv":
                    return "application/vnd.ms-excel";
                case ".gif":
                    return "image/gif";
                case ".jpg":
                case "jpeg":
                    return "image/jpeg";
                case ".bmp":
                    return "image/bmp";
                case ".wav":
                    return "audio/wav";
                case ".mp3":
                    return "audio/mpeg3";
                case ".mpg":
                case "mpeg":
                    return "video/mpeg";
                case ".rtf":
                    return "application/rtf";
                case ".asp":
                    return "text/asp";
                case ".pdf":
                    return "application/pdf";
                case ".fdf":
                    return "application/vnd.fdf";
                case ".ppt":
                    return "application/mspowerpoint";
                case ".dwg":
                    return "image/vnd.dwg";
                case ".msg":
                    return "application/msoutlook";
                case ".xml":
                case ".sdxl":
                    return "application/xml";
                case ".xdp":
                    return "application/vnd.adobe.xdp+xml";
                default:
                    return "application/octet-stream";
            }
        }
        #endregion
    }
}
