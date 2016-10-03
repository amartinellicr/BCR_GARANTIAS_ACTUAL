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

namespace BCRGARANTIAS.Forms
{
    public partial class frmPeritos : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el perito seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el perito seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_EMPRESA"].ToString())))
                    {
                        lblCatalogo.Text = "Peritos";

                        txtCedula.Enabled = true;
                        CargarComboTipos();
                        CargarGrid();
                        btnModificar.Enabled = false;
                        btnEliminar.Enabled = false;
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

        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarPeritos())
                {
                    Gestor.CrearPerito(txtCedula.Text, txtNombre.Text, int.Parse(cbTipo.SelectedValue.ToString()),
                                       txtTelefono.Text.Trim(), txtEmail.Text.Trim(), txtDireccion.Text,
                                       Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El perito se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPeritos.aspx");
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + "No se pudo insertar el perito." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPeritos.aspx");
                }
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                CargarComboTipos();
                txtCedula.Text = "";
                txtNombre.Text = "";
                txtTelefono.Text = "";
                txtEmail.Text = "";
                txtDireccion.Text = "";
                txtCedula.Enabled = true;
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarPeritos())
                {
                    //Gestor.ModificarPerito(strCedula, strNombre, nTipo, strTelefono, strEmail, strDireccion);
                    Gestor.ModificarPerito(txtCedula.Text, txtNombre.Text, int.Parse(cbTipo.SelectedValue.ToString()), 
                                           txtTelefono.Text.Trim(), txtEmail.Text.Trim(), txtDireccion.Text,
                                           Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "El perito se modificó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPeritos.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la información del perito." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPeritos.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarPerito(txtCedula.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + "El perito se eliminó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmPeritos.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar el perito." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPeritos.aspx");
                }
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvPeritos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvPeritos = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedPerito"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvPeritos.SelectedIndex = rowIndex;

                        try
                        {
                            //			strCedula = txtCedula.Text;
                            //			strNombre = txtNombre.Text;
                            //			nTipo = int.Parse(cbTipo.SelectedValue.ToString());
                            //			strTelefono = txtTelefono.Text;
                            //			strEmail = txtEmail.Text;
                            //			strDireccion = txtDireccion.Text;

                            if (gdvPeritos.SelectedDataKey[2].ToString() != null)
                                txtCedula.Text = gdvPeritos.SelectedDataKey[2].ToString();
                            else
                                txtCedula.Text = "";

                            if (gdvPeritos.SelectedDataKey[3].ToString() != null)
                                txtNombre.Text = gdvPeritos.SelectedDataKey[3].ToString();
                            else
                                txtNombre.Text = "";

                            CargarComboTipos();
                            if (gdvPeritos.SelectedDataKey[0].ToString() != null)
                                cbTipo.Items.FindByValue(gdvPeritos.SelectedDataKey[0].ToString()).Selected = true;

                            if (gdvPeritos.SelectedDataKey[4].ToString() != null)
                                txtTelefono.Text = gdvPeritos.SelectedDataKey[4].ToString();
                            else
                                txtTelefono.Text = "";

                            if (gdvPeritos.SelectedDataKey[5].ToString() != null)
                                txtEmail.Text = gdvPeritos.SelectedDataKey[5].ToString();
                            else
                                txtEmail.Text = "";

                            if (gdvPeritos.SelectedDataKey[6].ToString() != null)
                                txtDireccion.Text = gdvPeritos.SelectedDataKey[6].ToString();
                            else
                                txtDireccion.Text = "";

                            txtCedula.Enabled = false;
                            btnInsertar.Enabled = false;
                            btnModificar.Enabled = true;
                            btnEliminar.Enabled = true;

                        }
                        catch (Exception ex)
                        {
                            lblMensaje.Text = ex.Message;
                        }


                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
        
        protected void gdvPeritos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvPeritos.SelectedIndex = -1;
            this.gdvPeritos.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        #endregion

        #region Métodos Privados
        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "a.cedula_perito, " +
                                    "a.des_perito, " +
                                    "a.cod_tipo_persona, " +
                                    "b.cat_descripcion as des_tipo_persona, " +
                                    "a.des_telefono, " +
                                    "a.des_email, " +
                                    "a.des_direccion " +
                                "FROM " +
                                    "gar_perito a " +
                                    "INNER JOIN cat_elemento b " +
                                    "ON b.cat_catalogo = " + int.Parse(Application["CAT_TIPO_PERSONA"].ToString()) +
                                    "AND a.cod_tipo_persona = b.cat_campo " +
                                "ORDER BY " +
                                    "a.cedula_perito";

                System.Data.DataSet dsPeritos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsPeritos, "Peritos");

                if ((dsPeritos != null) && (dsPeritos.Tables.Count > 0) && (dsPeritos.Tables["Peritos"].Rows.Count > 0))
                {

                    if ((!dsPeritos.Tables["Peritos"].Rows[0].IsNull("cedula_perito")) &&
                        (!dsPeritos.Tables["Peritos"].Rows[0].IsNull("des_perito")) &&
                        (!dsPeritos.Tables["Peritos"].Rows[0].IsNull("des_tipo_persona")) &&
                        (!dsPeritos.Tables["Peritos"].Rows[0].IsNull("des_telefono")) &&
                        (!dsPeritos.Tables["Peritos"].Rows[0].IsNull("des_email")) &&
                        (!dsPeritos.Tables["Peritos"].Rows[0].IsNull("des_direccion")))
                    {
                        this.gdvPeritos.DataSource = dsPeritos.Tables["Peritos"].DefaultView;
                        this.gdvPeritos.DataBind();
                    }
                    else
                    {
                        dsPeritos.Tables["Peritos"].Rows.Add(dsPeritos.Tables["Peritos"].NewRow());
                        this.gdvPeritos.DataSource = dsPeritos;
                        this.gdvPeritos.DataBind();

                        int TotalColumns = this.gdvPeritos.Rows[0].Cells.Count;
                        this.gdvPeritos.Rows[0].Cells.Clear();
                        this.gdvPeritos.Rows[0].Cells.Add(new TableCell());
                        this.gdvPeritos.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvPeritos.Rows[0].Cells[0].Text = "No existen registros";
                        this.gdvPeritos.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
                    }
                }
                else
                {
                    dsPeritos.Tables["Peritos"].Rows.Add(dsPeritos.Tables["Peritos"].NewRow());
                    this.gdvPeritos.DataSource = dsPeritos;
                    this.gdvPeritos.DataBind();

                    int TotalColumns = this.gdvPeritos.Rows[0].Cells.Count;
                    this.gdvPeritos.Rows[0].Cells.Clear();
                    this.gdvPeritos.Rows[0].Cells.Add(new TableCell());
                    this.gdvPeritos.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvPeritos.Rows[0].Cells[0].Text = "No existen registros";
                    this.gdvPeritos.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void CargarComboTipos()
        {
            System.Data.DataSet dsPeritos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_PERSONA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsPeritos, "Tipos");
            cbTipo.DataSource = null;
            cbTipo.DataSource = dsPeritos.Tables["Tipos"].DefaultView;
            cbTipo.DataValueField = "CAT_CAMPO";
            cbTipo.DataTextField = "CAT_DESCRIPCION";
            cbTipo.DataBind();
        }

        /// <summary>
        /// Metodo de validación de Peritos
        /// </summary>
        /// <returns></returns>
        private bool ValidarPeritos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                if (bRespuesta && txtCedula.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la cédula del perito.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombre.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el nombre del perito.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipo.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el tipo de persona del perito.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtDireccion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la dirección del perito.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }
        #endregion
    }
}
