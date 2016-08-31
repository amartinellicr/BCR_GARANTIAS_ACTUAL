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
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Presentacion
{
    public partial class frmAccesoDenegado : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        
        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            this.cmdAccion.Click += new EventHandler(cmdAccion_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblTitulo.Text = "Acceso Denegado";
                lblMensaje.Text = "La sesión que estaba utilizando está vencida. Por favor ingrese nuevamente al sistema.";
                Session.Abandon();

                
            }
        }

        private void cmdAccion_Click(object sender, System.EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Session.RemoveAll();

            if (base.ArchivoPerdido)
            {
                base.Eliminar_Archivo_VS();

                Response.Redirect("frmLogin.aspx", true);
            }
            else
            {
                if (Request.Cookies["ASP.NET_SessionId"] != null)
                {
                    Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
                    Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-20);
                }

                base.Eliminar_Archivo_VS();

                Response.Redirect("frmLogin.aspx", true);
            }
        }

        #endregion
    }
}
