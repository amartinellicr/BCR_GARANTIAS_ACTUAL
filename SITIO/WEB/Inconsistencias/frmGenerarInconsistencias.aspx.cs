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
using System.IO;
using System.Net;
using System.Security.AccessControl;
using System.Security.Principal;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Utilidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Forms
{
    public partial class Inconsistencias_frmGenerarInconsistencias : BCR.Web.SystemFramework.PaginaPersistente
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

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnGenerar.Click += new EventHandler(btnGenerar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnGenerar.Attributes["onclick"] = "javascript:return confirm('Este proceso puede tardar algunos minutos... ¿Está seguro que desea generar los archivos seleccionados?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Global.UsuarioSistema.Length > 0)
                    {
                        int numRol = int.Parse(((Application["MNU_GENERAR_ARCHIVO_INCONSISTENCIAS"].ToString()).Length > 0 ? Application["MNU_GENERAR_ARCHIVO_INCONSISTENCIAS"].ToString() : "-1"));

                        if (numRol != -1)
                        {
                            if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GENERAR_ARCHIVO_INCONSISTENCIAS"].ToString())))
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

        private void btnGenerar_Click(object sender, System.EventArgs e)
        {
            WindowsImpersonationContext _objContext = null;
            string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
            string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
            string dominio = Application["DOMINIO_DEFAULT"].ToString();
            string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

            _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio);

            if (_objContext != null)
            {
                try
                {
                    bool bError = true;

                    if (ValidarDatos())
                    {
                        btnGenerar.Enabled = false;


                        //Genera el archivo de inconsistencias referentes al indicador de inscripción
                        if (chkErrorInscripcion.Checked)
                        {
                            //strRutaArchivos = AppDomain.CurrentDomain.BaseDirectory + "\\Temporales\\";// init the path 
                            EliminarArchivos("Error de Inscripción");
                            Gestor.GenerarErrorInscripcionTXT(strRuta, Global.UsuarioSistema, false);
                            ComprimirArchivo(strRuta, "Error de Inscripción.txt", strRuta + "Error de Inscripción.zip");
                        }

                        //Genera el archivo de inconsistencias referentes al partido y la finca
                        if (chkErrorPartidoFinca.Checked)
                        {
                            EliminarArchivos("Error Partido y Finca");
                            Gestor.GenerarErrorPartidoyFincaTXT(strRuta, Global.UsuarioSistema, false);
                            ComprimirArchivo(strRuta, "Error Partido y Finca.txt", strRuta + "Error Partido y Finca.zip");
                        }

                        //Genera el archivo de inconsistencias referentes al tipo de garantía real
                        if (chkErrorTipoGarantiaReal.Checked)
                        {
                            EliminarArchivos("Error Tipo Garantía Real");
                            Gestor.GenerarErrorTipoGarantiaRealTXT(strRuta, Global.UsuarioSistema, false);
                            ComprimirArchivo(strRuta, "Error Tipo Garantía Real.txt", strRuta + "Error Tipo Garantía Real.zip");
                        }

                        //Genera el archivo de inconsistencias referentes a los avalúos
                        if (chkErrorValuaciones.Checked)
                        {
                            EliminarArchivos("Error de Valuaciones");
                            Gestor.GenerarErrorValuacionesTXT(strRuta, Global.UsuarioSistema, false);
                            ComprimirArchivo(strRuta, "Error de Valuaciones.txt", strRuta + "Error de Valuaciones.zip");
                        }

                        //Genera el archivo de inconsistencias referentes a las clases de garantías reales
                        if (chkClasesGarantiaReal.Checked)
                        {
                            EliminarArchivos("Error en Clase de Garantía");
                            Gestor.GenerarErrorClaseGarantiaRealTXT(strRuta, Global.UsuarioSistema, false);
                            ComprimirArchivo(strRuta, "Error en Clase de Garantía.txt", strRuta + "Error en Clase de Garantía.zip");
                        }

                        if (bError)
                        {
                            string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                            strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Inconsistencias"));


                            Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                                            "bError=0" +
                                            "&strTitulo=" + "Generación Exitosa" +
                                            "&strMensaje=" + "Los archivos se generaron satisfactoriamente." +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=" + strRutaActual + "/Inconsistencias/frmGenerarInconsistencias.aspx", true);
                        }
                        else
                            lblMensaje.Text = "Se presentaron problemas generando los archivos solicitados. Por favor reintente.";
                    }
                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos solicitados. Por favor reintente. Detalle:" + ex.Message), EventLogEntryType.Error);

                    lblMensaje.Text = "Se presentaron problemas generando los archivos solicitados. Por favor reintente.";
                }
                finally
                {
                    btnGenerar.Enabled = true;
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
            if (!chkErrorInscripcion.Checked && !chkErrorPartidoFinca.Checked && !chkErrorTipoGarantiaReal.Checked
                && !chkErrorValuaciones.Checked && !chkClasesGarantiaReal.Checked)
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

        #endregion
    }
}