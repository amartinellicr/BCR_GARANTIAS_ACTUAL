using System;
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
using System.Security.AccessControl;
using System.Security.Principal;
using System.IO;
using System.Net;

using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Forms
{
    public partial class Inconsistencias_frmDescargarInconsistencias : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;
        private BCR.Seguridad.Cryptography.TripleDES oSeguridad = new BCR.Seguridad.Cryptography.TripleDES();
        private const string DATAVIEW_PAGINACION = "DATAVIEW_PAGINACION";

        #endregion

        #region Eventos

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GENERAR_ARCHIVO_INCONSISTENCIAS"].ToString())))
                    {
                        CargarGrid();
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta página
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                    strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Inconsistencias"));

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

        #endregion

        #region Métodos GridView

        protected void gdvArchivos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvArchivos = (GridView)sender;
            int rowIndex = 0;
            string strNombreArchivo = string.Empty;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedFile"):

                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvArchivos.SelectedIndex = rowIndex;

                        try
                        {
                            WindowsImpersonationContext _objContext = null;
                            string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
                            string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
                            string dominio = Application["DOMINIO_DEFAULT"].ToString();
                            string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

                            _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio); //UtilitarioImpersonificacion.ImpersonificarUsuario(usuario, password, dominio); 

                            if (_objContext != null)
                            {
                                try
                                {
                                    strNombreArchivo = gdvArchivos.SelectedDataKey[0].ToString();
                                    string strTamanoArchivo = gdvArchivos.SelectedDataKey[2].ToString();
                                    string strRutaArchivo = gdvArchivos.SelectedDataKey[1].ToString();
                                    string strExtension = gdvArchivos.SelectedDataKey[4].ToString();

                                    if (File.Exists(strRutaArchivo))
                                    {
                                        //Crea una instancia del objeto Response
                                        Response.Clear();
                                        Response.HeaderEncoding = System.Text.Encoding.Default;
                                        Response.AddHeader("Content-Disposition", "attachment; filename=" + strNombreArchivo);
                                        Response.AddHeader("Content-Length", strTamanoArchivo);
                                        Response.ContentType = RetornaTipoContenido(strExtension);//"application/octet-stream";
                                        Response.WriteFile(strRutaArchivo);
                                        Response.Flush();
                                        Response.Close();
                                    }
                                    else
                                    {
                                        lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS, strNombreArchivo, Mensajes.ASSEMBLY);
                                        UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE, strNombreArchivo, "El archivo no existe.", Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                                    }
                                }
                                catch (Exception ex)
                                {
                                    lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS, strNombreArchivo, Mensajes.ASSEMBLY);
                                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE, strNombreArchivo, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                                }
                                finally
                                {
                                    _objContext.Undo();
                                }
                            }
                            else
                            {
                                lblMensaje.Text = "La impersonalización es nula";
                                lblMensaje.Visible = true;
                            }
                        }
                        catch (Exception ex)
                        {
                            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS, strNombreArchivo, Mensajes.ASSEMBLY);
                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE, strNombreArchivo, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        }

                        break;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS, strNombreArchivo, Mensajes.ASSEMBLY);
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_DESCARGA_ARCHIVOS_INCONSISTENCIAS_DETALLE, strNombreArchivo, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
            }
        }

        protected void gdvArchivos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            if (e.NewPageIndex >= 0)
            {
                /*indica el numero de página a mostrar*/
                gdvArchivos.PageIndex = e.NewPageIndex;
            }

            CargarGrid();

            gdvArchivos.SelectedIndex = -1;
        }

        #endregion

        #region Metodos Privados

        private void CargarGrid()
        {
            WindowsImpersonationContext _objContext = null;
            string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
            string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
            string dominio = Application["DOMINIO_DEFAULT"].ToString();
            string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

            _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio); //UtilitarioImpersonificacion.ImpersonificarUsuario(usuario, password, dominio); 

            if (_objContext != null)
            {
                try
                {
                    DataSet ds = new DataSet();
                    DataTable dt = new DataTable("Files");
                    dt.Columns.Add("nombre", typeof(String));
                    dt.Columns.Add("url", typeof(String));
                    dt.Columns.Add("size", typeof(Int32));
                    dt.Columns.Add("date", typeof(DateTime));
                    dt.Columns.Add("type", typeof(String));
                    ds.Tables.Add(dt);

                    DirectoryInfo di = new DirectoryInfo(strRuta);
                    FileInfo[] rgFiles = di.GetFiles("*.zip");
                    foreach (FileInfo fi in rgFiles)
                    {
                        if (fi.Name.ToString().Trim().Contains("Error"))
                        {
                            DataRow dr;
                            dr = ds.Tables[0].NewRow();
                            dr["nombre"] = fi.Name.ToString();
                            dr["url"] = fi.FullName.ToString();//Application["DOWNLOAD"].ToString() + fi.Name.ToString();
                            dr["size"] = fi.Length;
                            dr["date"] = fi.LastWriteTime;
                            dr["type"] = fi.Extension.ToString();
                            ds.Tables["Files"].Rows.Add(dr);
                        }
                    }

                    if ((ds != null) && (ds.Tables.Count > 0) && ds.Tables[0].Rows.Count > 0)
                    {
                        gdvArchivos.DataSource = null;
                        gdvArchivos.DataSource = ds.Tables["Files"].DefaultView;
                        gdvArchivos.DataBind();
                    }
                    else
                    {
                        lblMensaje.Text = "No existen archivos que descargar";
                    }
                }
                catch (Exception ex)
                {
                    lblMensaje.Text = ex.Message.ToString();
                }
                finally
                {
                    _objContext.Undo();
                }
            }
            else
            {
                lblMensaje.Text = "La impersonalización es nula";
                lblMensaje.Visible = true;
            }
        }

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
