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

namespace BCRGARANTIAS.Presentacion
{
    public partial class frmMonitor : System.Web.UI.Page
    {
        #region Varables Globales
        #endregion

        #region Eventos

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                CargarValores();
        }

        private void btnRefrescar_Click(object sender, System.EventArgs e)
        {
            CargarValores();
        }

        #endregion

        #region Métodos Privados

        private void CargarValores()
        {
            Application.Lock();
            lblFechaHora.Text = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString();
            lblSesiones.Text = Application["SessionCounter"].ToString();
            Application.UnLock();
        }

        #endregion
    }

}
