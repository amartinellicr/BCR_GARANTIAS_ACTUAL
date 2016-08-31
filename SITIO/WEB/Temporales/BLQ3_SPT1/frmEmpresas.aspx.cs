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

namespace BCRGARANTIAS.Forms
{
    public partial class frmEmpresas : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.DropDownList cbTipo;
        protected System.Web.UI.WebControls.DropDownList cbCodigoEmpresa;

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
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea eliminar la empresa consultora seleccionada?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea modificar la empresa consultora seleccionada?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_EMPRESA"].ToString())))
                    {
                        lblCatalogo.Text = "Empresas";
                        CargarGrid();
                        txtCedula.Enabled = true;
                        btnModificar.Enabled = false;
                        btnEliminar.Enabled = false;
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta p�gina
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Acceso Denegado" +
                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta p�gina." +
                            "&bBotonVisible=0");
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando P�gina" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=0");
                }
            }
        }

        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    if (ValidarLlave())
                    {
                        Gestor.CrearEmpresa(txtCedula.Text, txtNombre.Text, txtTelefono.Text.Trim(),
                                            txtEmail.Text.Trim(), txtDireccion.Text, Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString());

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserci�n Exitosa" +
                                        "&strMensaje=" + "La empresa se insert� satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmEmpresas.aspx");
                    }
                    else
                    {
                        lblMensaje.Text = "Ya existe esta c�dula jur�dica. Por favor verifique...";
                    }
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Insertando Registro" +
                        "&strMensaje=" + "No se pudo insertar la empresa." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmEmpresas.aspx");
                }
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                txtCedula.Text = "";
                txtNombre.Text = "";
                txtTelefono.Text = "";
                txtEmail.Text = "";
                txtDireccion.Text = "";
                txtCedula.Enabled = true;
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                lblMensaje.Text = "";
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
                if (ValidarDatos())
                {
                    //Gestor.ModificarEmpresa(strCedula, strNombre, strTelefono, strEmail, strDireccion);
                    Gestor.ModificarEmpresa(txtCedula.Text, txtNombre.Text, txtTelefono.Text.Trim(),
                                            txtEmail.Text.Trim(), txtDireccion.Text, Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificaci�n Exitosa" +
                                    "&strMensaje=" + "La empresa se modific� satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmEmpresas.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la informaci�n de la empresa." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmEmpresas.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarEmpresa(txtCedula.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminaci�n Exitosa" +
                                "&strMensaje=" + "La empresa se elimin� satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmEmpresas.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar la empresa." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmEmpresas.aspx");
                }
            }
        }

        #endregion
                
        #region M�todos GridView

        protected void gdvEmpresas_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvEmpresas = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedEmpresa"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvEmpresas.SelectedIndex = rowIndex;

                        if (gdvEmpresas.SelectedDataKey[0].ToString() != null)
                            txtCedula.Text = gdvEmpresas.SelectedDataKey[0].ToString();
                        else
                            txtCedula.Text = "";

                        if (gdvEmpresas.SelectedDataKey[1].ToString() != null)
                            txtNombre.Text = gdvEmpresas.SelectedDataKey[1].ToString();
                        else
                            txtNombre.Text = "";

                        if (gdvEmpresas.SelectedDataKey[2].ToString() != null)
                            txtTelefono.Text = gdvEmpresas.SelectedDataKey[2].ToString();
                        else
                            txtTelefono.Text = "";

                        if (gdvEmpresas.SelectedDataKey[3].ToString() != null)
                            txtEmail.Text = gdvEmpresas.SelectedDataKey[3].ToString();
                        else
                            txtEmail.Text = "";

                        if (gdvEmpresas.SelectedDataKey[4].ToString() != null)
                            txtDireccion.Text = gdvEmpresas.SelectedDataKey[4].ToString();
                        else
                            txtDireccion.Text = "";

                        txtCedula.Enabled = false;
                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;


                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
        
        protected void gdvEmpresas_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvEmpresas.SelectedIndex = -1;
            this.gdvEmpresas.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        #endregion

        #region M�todos Privados
        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "a.cedula_empresa, " +
                                    "a.des_empresa, " +
                                    "a.des_telefono, " +
                                    "a.des_email, " +
                                    "a.des_direccion " +
                                "FROM " +
                                    "gar_empresa a " +
                                "ORDER BY " +
                                    "a.cedula_empresa";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Empresas");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Empresas"].Rows.Count > 0))
                {
                    if ((!dsDatos.Tables["Empresas"].Rows[0].IsNull("cedula_empresa")) &&
                        (!dsDatos.Tables["Empresas"].Rows[0].IsNull("des_empresa")) &&
                        (!dsDatos.Tables["Empresas"].Rows[0].IsNull("des_telefono")) &&
                        (!dsDatos.Tables["Empresas"].Rows[0].IsNull("des_email")) &&
                        (!dsDatos.Tables["Empresas"].Rows[0].IsNull("des_direccion")))
                    {
                        this.gdvEmpresas.DataSource = dsDatos.Tables["Empresas"].DefaultView;
                        this.gdvEmpresas.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Empresas"].Rows.Add(dsDatos.Tables["Empresas"].NewRow());
                        this.gdvEmpresas.DataSource = dsDatos;
                        this.gdvEmpresas.DataBind();

                        int TotalColumns = this.gdvEmpresas.Rows[0].Cells.Count;
                        this.gdvEmpresas.Rows[0].Cells.Clear();
                        this.gdvEmpresas.Rows[0].Cells.Add(new TableCell());
                        this.gdvEmpresas.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvEmpresas.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables["Empresas"].Rows.Add(dsDatos.Tables["Empresas"].NewRow());
                    this.gdvEmpresas.DataSource = dsDatos;
                    this.gdvEmpresas.DataBind();

                    int TotalColumns = this.gdvEmpresas.Rows[0].Cells.Count;
                    this.gdvEmpresas.Rows[0].Cells.Clear();
                    this.gdvEmpresas.Rows[0].Cells.Add(new TableCell());
                    this.gdvEmpresas.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvEmpresas.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Metodo de validaci�n de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;

            try
            {
                lblMensaje.Text = "";
                if (bRespuesta && txtCedula.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la c�dula de la empresa.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombre.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el nombre de la empresa.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtDireccion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la direcci�n de la empresa.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        /// <summary>
        /// Metodo de validaci�n de datos de la llave
        /// </summary>
        /// <returns></returns>
        private bool ValidarLlave()
        {
            bool bRespuesta = true;
            try
            {
                string strSQL = "SELECT " +
                    "cedula_empresa " +
                    "FROM " +
                    "dbo.GAR_EMPRESA " +
                    "WHERE " +
                    "cedula_empresa = '" + txtCedula.Text + "'";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if (dsDatos.Tables["Datos"].Rows.Count > 0)
                    bRespuesta = false;
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
