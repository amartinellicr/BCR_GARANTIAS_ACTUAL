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
using BCRGARANTIAS.Negocios;
using System.Web.Security;

namespace BCRGARANTIAS
{
    public partial class frmLogin : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
           
            this.cmdIngresar.Click += new EventHandler(cmdIngresar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //			Response.AppendHeader( "Cache-Control", "no-cache, must-revalidate" );
                //			Response.AppendHeader( "Pragma", "no-cache" );
                //			Response.Expires = -1;

                try
                {
                    Utilitarios oUtilitarios = new Utilitarios();
                    oUtilitarios.SetFocus(txtUsuario, this.Page);
                    oUtilitarios = null;

                    string m_Usuario;
                    int m_pos;

                    m_Usuario = User.Identity.Name;
                    m_pos = m_Usuario.IndexOf(@"\");

                    if (m_pos != -1)//Revisa si el index de la identidad de usuario es distinto de -1
                    {
                        //Asigna a la caja de texto el nombre del usuario logueado en dicha máquina
                        m_Usuario = m_Usuario.Substring(m_pos + 1).ToUpper();
                        txtUsuario.Text = m_Usuario;
                        txtClave.Focus();
                    }

                    lblMensaje.Text = "Ingrese su usuario y clave de dominio BCR";
                    LimpiarSession();

                    HttpContext.Current.Session.Timeout = int.Parse(Application["TIME_OUT"].ToString());
                }
                catch (Exception ex)
                {
                    lblMensaje.Text = ex.Message;
                }
            }

        }

        private void cmdIngresar_Click(object sender, System.EventArgs e)
        {

            try
            {
                if (ValidarDatos())
                {
                    if (Gestor.ValidarUsuario(txtUsuario.Text, txtClave.Text))
                    {
                        Session["strUSER"] = txtUsuario.Text.Trim().ToString();
                        Response.Redirect("frmPrincipal.aspx");
                    }
                    else
                    {
                        lblMensaje.Text = "El usuario no tiene permisos de acceso a este sistema.";
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #endregion

        #region Métodos Privados

        private void LimpiarObjetosSession()
        {
            try
            {
                LimpiarGarantiaFiduciaria();
                LimpiarGarantiaReal();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void LimpiarGarantiaFiduciaria()
        {
            try
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
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void LimpiarGarantiaReal()
        {
            try
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
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void LimpiarSession()
        {
            try
            {
                Session["strUSER"] = "";
                Session["Accion"] = "";
                Session["AccionVal"] = "";
                Session["EsOperacionValida"] = false;
                Session["EsOperacionValidaReal"] = false;
                Session["EsOperacionValidaValor"] = false;
                Session["EsCambioTipoGarantia"] = false;
                Session["TipoGarantia"] = "";
                Session["strDireccion"] = "DIRECTO";

                LimpiarObjetosSession();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Método que valida si los datos de una pantalla determinada 
        /// son válidos o no.
        /// </summary>
        /// <returns>True si los datos son válidos</returns>
        private bool ValidarDatos()
        {
            bool bValido = true;
            try
            {
                Utilitarios oUtilitarios = new Utilitarios();

                //valida el usuario	
                if (bValido && txtUsuario.Text.Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar su usuario de dominio";
                    oUtilitarios.SetFocus(txtUsuario, this.Page);
                    bValido = false;
                }

                //valida la contraseña
                if (bValido && txtClave.Text.Length == 0 && bValido)
                {
                    lblMensaje.Text = "Debe ingresar su clave de dominio";
                    oUtilitarios.SetFocus(txtClave, this.Page);
                    bValido = false;
                }

                oUtilitarios = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bValido;
        }

        #endregion
    }
}
