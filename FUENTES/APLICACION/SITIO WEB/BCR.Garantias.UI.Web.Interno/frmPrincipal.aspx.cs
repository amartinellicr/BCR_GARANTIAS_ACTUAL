using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Data.OleDb;
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Presentacion
{
    public partial class frmPrincipal : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Label lblUsuario;
        protected System.Web.UI.WebControls.Label lblTexto;
        protected System.Web.UI.WebControls.Image Image2;
        protected System.Web.UI.WebControls.Label lblFecha;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Image Image1;
        private bool mbValido;

        private bool seRedirecciona = false;

        private string urlPaginaMensaje = string.Empty;

        #endregion

        #region Eventos

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_INICIO"].ToString())))
                    {
                        Session["EsOperacionValida"] = false;
                        Session["EsOperacionValidaReal"] = false;
                        Session["EsOperacionValidaValor"] = false;
                        LimpiarObjetosSession();
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta página
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                    {
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Acceso Denegado" +
                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                            "&bBotonVisible=0");
                    }
                    else
                    {
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando Página" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=0");
                    }
                }

                if (seRedirecciona)
                {
                    Response.Redirect(urlPaginaMensaje, true);
                }
            }
        }

        #endregion

        #region Métodos Privados
        private void LimpiarObjetosSession()
        {
            LimpiarGarantiaFiduciaria();
            LimpiarGarantiaReal();
        }

        private void LimpiarGarantiaFiduciaria()
        {
            CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;
            //Campos llave
            oGarantia.TipoOperacion = 0;
            oGarantia.Contabilidad = 0;
            oGarantia.Oficina = 0;
            oGarantia.Moneda = 0;
            oGarantia.Producto = 0;
            oGarantia.Numero = 0;
            oGarantia.ClaseGarantia = -1;
            //Informacion del fiador
            oGarantia.TipoFiador = 0;
            oGarantia.CedulaFiador = null;
            oGarantia.NombreFiador = null;
            //Informacion general de la garantia
            oGarantia.TipoDocumento = 0;
            oGarantia.MontoMitigador = 0;
            oGarantia.Inscripcion = 0;
            oGarantia.FechaRegistro = DateTime.Today;
            oGarantia.PorcentajeResposabilidad = 0;
            oGarantia.FechaConstitucion = DateTime.Today;
            oGarantia.TipoAcreedor = 0;
            oGarantia.CedulaAcreedor = null;
            oGarantia.OperacionEspecial = 0;
            oGarantia = null;
        }

        private void LimpiarGarantiaReal()
        {
            CGarantiaReal oGarantia = CGarantiaReal.Current;

            //Campos llave
            oGarantia.TipoOperacion = 0;
            oGarantia.Contabilidad = 0;
            oGarantia.Oficina = 0;
            oGarantia.Moneda = 0;
            oGarantia.Producto = 0;
            oGarantia.Numero = 0;
            oGarantia.ClaseGarantia = -1;
            oGarantia.Finca = 0;
            //Informacion general de la garantia
            oGarantia.TipoMitigador = -1;
            oGarantia.TipoDocumento = -1;
            oGarantia.MontoMitigador = 0;
            oGarantia.Inscripcion = 0;
            oGarantia.FechaPresentacion = DateTime.Today;
            oGarantia.PorcentajeResposabilidad = 0;
            oGarantia.FechaConstitucion = DateTime.Today;
            oGarantia.GradoGravamen = 0;
            oGarantia.TipoAcreedor = 0;
            oGarantia.CedulaAcreedor = null;
            oGarantia.FechaVencimientoInstrumento = DateTime.Today;
            oGarantia.OperacionEspecial = 0;
            oGarantia.TipoBien = 0;
            oGarantia.Partido = 0;
            oGarantia.Liquidez = 0;
            oGarantia.Tenencia = 0;
            oGarantia.MonedaValor = 0;
            oGarantia.FechaPrescripcion = DateTime.Today;

            oGarantia = null;
        }
        #endregion
    }
}
