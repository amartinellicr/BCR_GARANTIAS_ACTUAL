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
using System.Data.OleDb;
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Forms
{
    public partial class frmCatalogos : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales
 
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnSiguiente.Click +=new EventHandler(btnSiguiente_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CATALOGOS"].ToString())))
                    {
                        //Carga el combo de Catálogos
                        CargarCatalogos();
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
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Acceso Denegado" +
                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                            "&bBotonVisible=0");
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando Página" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=0");
                }
            }
        }

        private void btnSiguiente_Click(object sender, System.EventArgs e)
        {
            if ((int.Parse(cbCatalogo.SelectedValue) != -1) && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_TIPOS_POLIZAS_BIENES_RELACIONADOS"].ToString()) != 0)
                && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_TIPOS_POLIZAS_SUGEF"].ToString()) != 0)
                && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_PORCENTAJE_ACEPTACION"].ToString()) != 0))
            {
                Response.Redirect("frmMantenimientoCatalogos.aspx?nCatalogo=" + cbCatalogo.SelectedValue.ToString() + "&strCatalogo=" + cbCatalogo.SelectedItem.Text);
            }
            else if ((int.Parse(cbCatalogo.SelectedValue) != -1) && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_TIPOS_POLIZAS_BIENES_RELACIONADOS"].ToString()) == 0))
            {
                Response.Redirect("frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + cbCatalogo.SelectedValue.ToString() + "&strCatalogo=" + cbCatalogo.SelectedItem.Text);
            }
            else if ((int.Parse(cbCatalogo.SelectedValue) != -1) && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_TIPOS_POLIZAS_SUGEF"].ToString()) == 0))
            {
                Response.Redirect("frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + cbCatalogo.SelectedValue.ToString() + "&strCatalogo=" + cbCatalogo.SelectedItem.Text);
            }
            else if ((int.Parse(cbCatalogo.SelectedValue) != -1) && (cbCatalogo.SelectedValue.CompareTo(Application["CAT_PORCENTAJE_ACEPTACION"].ToString()) == 0))
            {
                Response.Redirect("frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + cbCatalogo.SelectedValue.ToString() + "&strCatalogo=" + cbCatalogo.SelectedItem.Text);
            }
            else
                lblMensaje.Text = "Debe seleccionar un catálogo para continuar.";
        }

        #endregion

        #region Métodos Privados

        /// <summary>
        /// Método que carga el combo de catálogos.
        /// </summary>
        private void CargarCatalogos()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_catalogo, cat_descripcion FROM cat_catalogo UNION ALL SELECT -1, '' ORDER BY cat_descripcion", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Catalogos");
            cbCatalogo.DataSource = null;
            cbCatalogo.DataSource = dsDatos.Tables["Catalogos"].DefaultView;
            cbCatalogo.DataValueField = "cat_catalogo";
            cbCatalogo.DataTextField = "cat_descripcion";
            cbCatalogo.DataBind();

        }//CargarCombo

        #endregion
    }
}
