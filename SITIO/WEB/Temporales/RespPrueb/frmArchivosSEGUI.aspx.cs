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
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;
using System.Net;
using System.Security.AccessControl;
using Excel;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Utilidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Forms
{
    public partial class frmArchivosSEGUI : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;
        protected Button Button1;
		protected decimal nTipoCambio = 0;

        private ZipUtil zUtil = new ZipUtil();

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnGenerar.Click +=new EventHandler(btnGenerar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
			btnGenerar.Attributes["onclick"] = "javascript:return confirm('Este proceso puede tardar algunos minutos... ¿Está seguro que desea generar los archivos seleccionados?')";

            if (!IsPostBack)
            {
                try
                {
                    if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_ARCHIVOS_SEGUI"].ToString())))
                    {
                        //El usuario no tiene acceso a esta página
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Acceso Denegado" +
                                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                                        "&bBotonVisible=0", true);
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando Página" +
                                        "&strMensaje=" + ex.Message +
                                        "&bBotonVisible=0", true);
                }
            }
        }

        private void btnGenerar_Click(object sender, System.EventArgs e)
        {
            bool mostrarLeyendaIconoFallido = false;
            bool mostrarLeyendaIconoExitoso = false;

            if (ValidarDatos())
            {
                btnGenerar.Enabled = false;

                string strRutaArchivos = Application["ARCHIVOS"].ToString();

                //Genera el archivo de deudores
                if (chkDeudor.Checked)
                {
                    try
                    {
                        //strRutaArchivos = AppDomain.CurrentDomain.BaseDirectory + "\\Temporales\\";// init the path 
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.Deudores, "Deudores");
                        Gestor.GenerarDeudoresTXT(strRutaArchivos, false);
                        ComprimirArchivo(strRutaArchivos, "Deudores.txt", strRutaArchivos + "Deudores.zip");
                        imgGeneracion_Exitosa_Deudor.Visible = true;
                        imgGeneracion_Exitosa_Deudor.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Deudor.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Deudor.Visible = false;
                        imgGeneracion_Fallida_Deudor.Visible = true;
                        imgGeneracion_Fallida_Deudor.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Deudor.Visible = false;
                    imgGeneracion_Fallida_Deudor.Visible = false;
                }

                //Genera el archivo de garantias fiduciarias
                if (chkGarantiasFiduciarias.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias, "GarantiasFiduciarias");
                        Gestor.GenerarGarantiasFiduciariasTXT(strRutaArchivos, false);
                        ComprimirArchivo(strRutaArchivos, "GarFid.txt", strRutaArchivos + "GarantiasFiduciarias.zip");
                        imgGeneracion_Exitosa_Garantias_Fiduciarias.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Fiduciarias.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Fiduciarias.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Fiduciarias.Visible = false;
                        imgGeneracion_Fallida_Garantias_Fiduciarias.Visible = true;
                        imgGeneracion_Fallida_Garantias_Fiduciarias.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Fiduciarias.Visible = false;
                    imgGeneracion_Fallida_Garantias_Fiduciarias.Visible = false;
                }

                //Genera el archivo de garantias reales
                if (chkGarantiasReales.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales, "GarantiasReales");
                        Gestor.GenerarGarantiasRealesTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarRea.txt", strRutaArchivos + "GarantiasReales.zip");
                        imgGeneracion_Exitosa_Garantias_Reales.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Reales.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Reales.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Reales.Visible = false;
                        imgGeneracion_Fallida_Garantias_Reales.Visible = true;
                        imgGeneracion_Fallida_Garantias_Reales.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Reales.Visible = false;
                    imgGeneracion_Fallida_Garantias_Reales.Visible = false;
                }

                //Genera el archivo de garantias de valor
                if (chkGarantiasValor.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor, "GarantiasValor");
                        Gestor.GenerarGarantiasValorTXT(strRutaArchivos, false);
                        ComprimirArchivo(strRutaArchivos, "GarVal.txt", strRutaArchivos + "GarantiasValor.zip");
                        imgGeneracion_Exitosa_Garantias_Valor.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Valor.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Valor.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Valor.Visible = false;
                        imgGeneracion_Fallida_Garantias_Valor.Visible = true;
                        imgGeneracion_Fallida_Garantias_Valor.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Valor.Visible = false;
                    imgGeneracion_Fallida_Garantias_Valor.Visible = false;
                }

                //Genera el archivo de garantias fiduciarias, con información completa
                if (chkGarantiasFiduciariasInfoCompleta.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasInfoCompleta, "GarantiasFiduciariasInfoCompleta");
                        Gestor.GenerarGarantiasFiduciariasInfoCompletaTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarantiasFiduciariasInfoCompleta.txt", strRutaArchivos + "GarantiasFiduciariasInfoCompleta.zip");
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Completa.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Completa.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Completa.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Completa.Visible = false;
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Completa.Visible = true;
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Completa.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Fiduciarias_Completa.Visible = false;
                    imgGeneracion_Fallida_Garantias_Fiduciarias_Completa.Visible = false;
                }

                //Genera el archivo de garantias reales, con información completa
                if (chkGarantiasRealesInfoCompleta.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesInfoCompleta, "GarantiasRealesInfoCompleta");
                        Gestor.GenerarGarantiasRealesInfoCompletaTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarantiasRealesInfoCompleta.txt", strRutaArchivos + "GarantiasRealesInfoCompleta.zip");
                        imgGeneracion_Exitosa_Garantias_Reales_Completa.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Reales_Completa.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Reales_Completa.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Reales_Completa.Visible = false;
                        imgGeneracion_Fallida_Garantias_Reales_Completa.Visible = true;
                        imgGeneracion_Fallida_Garantias_Reales_Completa.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Reales_Completa.Visible = false;
                    imgGeneracion_Fallida_Garantias_Reales_Completa.Visible = false;
                }

                //Genera el archivo de garantias de valor, con información completa
                if (chkGarantiasValorInfoCompleta.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorInfoCompleta, "GarantiasValorInfoCompleta");
                        Gestor.GenerarGarantiasValorInfoCompletaTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarantiasValorInfoCompleta.txt", strRutaArchivos + "GarantiasValorInfoCompleta.zip");
                        imgGeneracion_Exitosa_Garantias_Valor_Completa.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Valor_Completa.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Valor_Completa.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Valor_Completa.Visible = false;
                        imgGeneracion_Fallida_Garantias_Valor_Completa.Visible = true;
                        imgGeneracion_Fallida_Garantias_Valor_Completa.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Valor_Completa.Visible = false;
                    imgGeneracion_Fallida_Garantias_Valor_Completa.Visible = false;
                }

                //Genera el archivo de contratos
                if (chkContratos.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.Contratos, "Contratos");
                        Gestor.GenerarArchivoContratosTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "Contratos.txt", strRutaArchivos + "Contratos.zip");
                        imgGeneracion_Exitosa_Contratos.Visible = true;
                        imgGeneracion_Exitosa_Contratos.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Contratos.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Contratos.Visible = false;
                        imgGeneracion_Fallida_Contratos.Visible = true;
                        imgGeneracion_Fallida_Contratos.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Contratos.Visible = false;
                    imgGeneracion_Fallida_Contratos.Visible = false;
                }

                //Genera el archivo de giros
                if (chkGiros.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.Giros, "Giros");
                        Gestor.GenerarArchivoGirosTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "Giros.txt", strRutaArchivos + "Giros.zip");
                        imgGeneracion_Exitosa_Giros.Visible = true;
                        imgGeneracion_Exitosa_Giros.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Giros.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Giros.Visible = false;
                        imgGeneracion_Fallida_Giros.Visible = true;
                        imgGeneracion_Fallida_Giros.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Giros.Visible = false;
                    imgGeneracion_Fallida_Giros.Visible = false;
                }

                //Genera el archivo de garantias fiduciarias de contratos
                if (chkGarantiasFiduciariasContratos.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos, "GarantiasFiduciariasContratos");
                        Gestor.GenerarGarantiasFiduciariasContratosTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarFiaCo.txt", strRutaArchivos + "GarantiasFiduciariasContratos.zip");
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Contratos.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Contratos.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Contratos.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Fiduciarias_Contratos.Visible = false;
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Contratos.Visible = true;
                        imgGeneracion_Fallida_Garantias_Fiduciarias_Contratos.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Fiduciarias_Contratos.Visible = false;
                    imgGeneracion_Fallida_Garantias_Fiduciarias_Contratos.Visible = false;
                }

                //Genera el archivo de garantias reales de contratos
                if (chkGarantiasRealesContratos.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos, "GarantiasRealesContratos");
                        Gestor.GenerarGarantiasRealesContratosTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarReaCo.txt", strRutaArchivos + "GarantiasRealesContratos.zip");
                        imgGeneracion_Exitosa_Garantias_Reales_Contratos.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Reales_Contratos.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Reales_Contratos.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Reales_Contratos.Visible = false;
                        imgGeneracion_Fallida_Garantias_Reales_Contratos.Visible = true;
                        imgGeneracion_Fallida_Garantias_Reales_Contratos.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Reales_Contratos.Visible = false;
                    imgGeneracion_Fallida_Garantias_Reales_Contratos.Visible = false;
                }
                //Genera el archivo de garantias de valor de contratos
                if (chkGarantiasValorContratos.Checked)
                {
                    try
                    {
                        EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos, "GarantiasValorContratos");
                        Gestor.GenerarGarantiasValorContratosTXT(strRutaArchivos, Global.UsuarioSistema, false);
                        ComprimirArchivo(strRutaArchivos, "GarValCo.txt", strRutaArchivos + "GarantiasValorContratos.zip");
                        imgGeneracion_Exitosa_Garantias_Valor_Contratos.Visible = true;
                        imgGeneracion_Exitosa_Garantias_Valor_Contratos.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                        imgGeneracion_Fallida_Garantias_Valor_Contratos.Visible = false;
                        mostrarLeyendaIconoExitoso = true;
                    }
                    catch (Exception ex)
                    {
                        imgGeneracion_Exitosa_Garantias_Valor_Contratos.Visible = false;
                        imgGeneracion_Fallida_Garantias_Valor_Contratos.Visible = true;
                        imgGeneracion_Fallida_Garantias_Valor_Contratos.ToolTip = ObtenerMensaje(ex.Message);
                        mostrarLeyendaIconoFallido = true;
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Garantias_Valor_Contratos.Visible = false;
                    imgGeneracion_Fallida_Garantias_Valor_Contratos.Visible = false;
                }

                //Genera el archivo de fechas de capacidad de pago de deudores
                if (chkDeudorFCP.Checked)
                {
                    bool archivoSuministrado;

                    EliminarArchivosXLS();
                    DataSet dsXLS = CargarArchivo(out archivoSuministrado);
                    if (dsXLS != null)
                    {
                        try
                        {
                            EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI.DEUDORES_FCP, "DEUDORES_FCP");
                            Gestor.GenerarDeudoresFCPTXT(strRutaArchivos, dsXLS);
                            ComprimirArchivo(strRutaArchivos, "DEUDORES_FCP.txt", strRutaArchivos + "DEUDORES_FCP.zip");
                            imgGeneracion_Exitosa_Deudor_FCP.Visible = true;
                            imgGeneracion_Exitosa_Deudor_FCP.ToolTip = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                            imgGeneracion_Fallida_Deudor_FCP.Visible = false;
                            mostrarLeyendaIconoExitoso = true;
                        }
                        catch (Exception ex)
                        {
                            imgGeneracion_Exitosa_Deudor_FCP.Visible = false;
                            imgGeneracion_Fallida_Deudor_FCP.Visible = true;
                            imgGeneracion_Fallida_Deudor_FCP.ToolTip = ObtenerMensaje(ex.Message);
                            mostrarLeyendaIconoFallido = true;
                        }
                    }
                    else
                    {
                        imgGeneracion_Exitosa_Deudor_FCP.Visible = false;
                        imgGeneracion_Fallida_Deudor_FCP.Visible = true;
                        mostrarLeyendaIconoFallido = true;
                        lblMensaje.Text = string.Empty;

                        if (archivoSuministrado)
                        {
                            imgGeneracion_Fallida_Deudor_FCP.ToolTip = Mensajes.Obtener(Mensajes.ERROR_SUBIENDO_ARCHIVO_FUENTE, Mensajes.ASSEMBLY);
                        }
                        else
                        {
                            imgGeneracion_Fallida_Deudor_FCP.ToolTip = Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_NO_PORPORCIONADO, Mensajes.ASSEMBLY);
                        }
                    }
                }
                else
                {
                    imgGeneracion_Exitosa_Deudor_FCP.Visible = false;
                    imgGeneracion_Fallida_Deudor_FCP.Visible = false;
                }
            }

            lblGeneracionExitosa.Visible = mostrarLeyendaIconoExitoso;
            lblGeneracionFallida.Visible = mostrarLeyendaIconoFallido;
            btnGenerar.Enabled = true;
        }

        #endregion

        #region Métodos Privados

        private bool ValidarDatos()
        {
            lblMensaje.Text = "";
            if (!chkDeudor.Checked && !chkGarantiasFiduciarias.Checked &&
                !chkGarantiasReales.Checked && !chkGarantiasValor.Checked && 
				!chkContratos.Checked && !chkDeudor.Checked &&
				!chkGarantiasFiduciariasContratos.Checked && !chkGarantiasRealesContratos.Checked &&
				!chkGarantiasValorContratos.Checked && !chkGiros.Checked && !chkDeudorFCP.Checked &&
				!chkGarantiasFiduciariasInfoCompleta.Checked && !chkGarantiasRealesInfoCompleta.Checked &&
				!chkGarantiasValorInfoCompleta.Checked
				)
            {
                lblMensaje.Text = "Debe seleccionar algún archivo para generar.";
                return false;
            }

			//if ((chkContratos.Checked) || (chkGiros.Checked))
			//{
			//    if (txtTipoCambioContratos.Text.CompareTo(txtTipoCambioGiros.Text) != 0)
			//    {
			//        lblMensaje.Text = "El monto del tipo de cambio es diferente. Favor verifique.";
			//        return false;
			//    }
			//    else if ((txtTipoCambioContratos.Text.CompareTo("0.00") == 0) && (txtTipoCambioGiros.Text.CompareTo("0.00") == 0))
			//    {
			//        lblMensaje.Text = "Debe proporcionar un tipo de cambio mayor a 0.";
			//        return false;
			//    }
			//}

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

        private void EliminarArchivos(Enumeradores.Nombre_Archivos_SEGUI codigoArchivo, string strNombreArchivo)
        {
			try
			{
				string strRutaArchivos = Application["ARCHIVOS"].ToString();
                string[] listaArchivosEliminar = ObtenerArchivosEliminar(codigoArchivo, strNombreArchivo);

                foreach (string nombreArchivo in listaArchivosEliminar)
                {
				DirectoryInfo di = new DirectoryInfo(strRutaArchivos);

                    FileInfo[] rgFiles = di.GetFiles(nombreArchivo + ".*");
				foreach (FileInfo fi in rgFiles)
				{
					fi.Delete();
				}
			}
			}
			catch (Exception ex)
			{
				lblMensaje.Text = ex.Message;
			}
        }

		private void EliminarArchivosXLS()
		{

			string strRutaArchivos = Application["ARCHIVOS"].ToString();

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

		private DataSet CargarArchivo(out bool archivoSeleccionado)
		{
			DataSet dsResultado = null;
			bool bPoseeEncabezados = false;
            archivoSeleccionado = true;

			if ((fuDeudores.HasFile) && (fuDeudores.PostedFile != null))
			{
				try
				{
					string strExtensionArch = Path.GetExtension(fuDeudores.FileName);

					if ((strExtensionArch.ToLower().CompareTo(".xls") == 0) || (strExtensionArch.ToLower().CompareTo(".xlsx") == 0))
					{
						string strRutaArchivo = Path.Combine(Application["ARCHIVOS"].ToString(), fuDeudores.FileName);
						fuDeudores.SaveAs(strRutaArchivo);

						FileStream stream = File.Open(strRutaArchivo, FileMode.Open, FileAccess.Read);
						IExcelDataReader excelReader = null;

						if (strExtensionArch.ToLower().CompareTo(".xls") == 0)
						{
							excelReader = ExcelReaderFactory.CreateBinaryReader(stream);
						}
						else if (strExtensionArch.ToLower().CompareTo(".xlsx") == 0)
						{
							excelReader = ExcelReaderFactory.CreateOpenXmlReader(stream);
						}

						if (excelReader != null)
						{
							excelReader.IsFirstRowAsColumnNames = true;
							dsResultado = excelReader.AsDataSet();
						}
					}
					else
					{
                        lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_TIPO_ARCHIVO, "un Excel", Mensajes.ASSEMBLY);
 					}
				}
				catch (Exception ex)
				{
                    Utilitarios.RegistraEventLog((Mensajes.Obtener(Mensajes.ERROR_CARGANDO_ARCHIVO_DETALLE, ex.Message, Mensajes.ASSEMBLY)), EventLogEntryType.Error);
                    lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_CARGANDO_ARCHIVO, Mensajes.ASSEMBLY);
				}
			}
			else
			{
                archivoSeleccionado = false;
                return dsResultado;
			}

			if ((dsResultado != null) && (dsResultado.Tables.Count > 0))
			{
				foreach (DataTable dtDatos in dsResultado.Tables)
				{
                    if ((dtDatos.Columns.Contains("CEDULA")) && (dtDatos.Columns.Contains("NOMBRE")))
                    {
                        bPoseeEncabezados = true;
                        break;
                    }
                    else
                    {
                        if (dtDatos.Rows.Count <= 1)
                        {
                            bPoseeEncabezados = true;
                            dsResultado = null;
                            break;
                        }
                    }
				}

				if (!bPoseeEncabezados)
				{
					dsResultado = null;
                    lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_ENCABEZADOS_ARCHIVO_FUENTE, Mensajes.ASSEMBLY); 
				}
			}

			return dsResultado;
		}

        /// <summary>
        /// Se encarga de obtener el mensaje de error, esto en caso de que se pase un código de error
        /// </summary>
        /// <param name="codigoMensaje">Código del mensaje de error</param>
        /// <returns>Mensaje obtenido</returns>
        private string ObtenerMensaje(string codigoMensaje)
        {
            string mensajeRetornado = codigoMensaje;

            if (codigoMensaje.Length > 0)
            {
                if (codigoMensaje.CompareTo(Mensajes.CODIGO_ERROR_ARCHIVO_SEGUI_VACIO) == 0)
                {
                    mensajeRetornado = Mensajes.Obtener(Mensajes.ERROR_ARCHIVO_SEGUI_VACIO, Mensajes.ASSEMBLY);
                }
                else if (codigoMensaje.CompareTo(Mensajes.CODIGO_ERROR_CREANDO_ARCHIVO_SEGUI) == 0)
                {
                    mensajeRetornado = Mensajes.Obtener(Mensajes.ERROR_CREANDO_ARCHIVO_SEGUI, Mensajes.ASSEMBLY);
                }
                else if (codigoMensaje.CompareTo(Mensajes.CODIGO_ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI) == 0)
                {
                    mensajeRetornado = Mensajes.Obtener(Mensajes.ERROR_EXTRAYENDO_DATOS_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                }
                else if (codigoMensaje.CompareTo(Mensajes.CODIGO_ERROR_GENERAL_GENERANDO_ARCHIVOS_SEGUI) == 0)
                {
                    mensajeRetornado = Mensajes.Obtener(Mensajes.ERROR_GENERAL_GENERANDO_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                }
                else if (codigoMensaje.CompareTo(Mensajes.CODIGO_GENERACION_CORRECTA_ARCHIVOS_SEGUI) == 0)
                {
                    mensajeRetornado = Mensajes.Obtener(Mensajes.GENERACION_CORRECTA_ARCHIVOS_SEGUI, Mensajes.ASSEMBLY);
                }
            }

            return mensajeRetornado;
        }

        /// <summary>
        /// Obtiene los nombres de los archivos a ser eliminados, esto debido al cambio de nombrede alguno de ellos.
        /// </summary>
        /// <param name="codigoArchivo">Código del archivo SEGUI</param>
        /// <param name="nombreArchivo">Nombre del archivo .zip a ser eliminado</param>
        /// <returns>Arreglo con los nombres de los archivos a ser eliminados, donde la posición 0 = Archivo .zip y 1 = Archivo .txt</returns>
        private string[] ObtenerArchivosEliminar(Enumeradores.Nombre_Archivos_SEGUI codigoArchivo, string nombreArchivo)
        {
            string[] listaArchivosEliminar = { nombreArchivo, string.Empty };

            switch (codigoArchivo)
            {
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciarias: listaArchivosEliminar[1] = "GarFid";
                    break;
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasFiduciariasContratos: listaArchivosEliminar[1] = "GarFiaCo";
                    break;
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasReales: listaArchivosEliminar[1] = "GarRea";
                    break;
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasRealesContratos: listaArchivosEliminar[1] = "GarReaCo";
                    break;
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasValor: listaArchivosEliminar[1] = "GarVal";
                    break;
                case Enumeradores.Nombre_Archivos_SEGUI.GarantiasValorContratos: listaArchivosEliminar[1] = "GarValCo";
                    break;
                default:
                    break;
            }

            return listaArchivosEliminar;
        }

        #endregion
    }
}
