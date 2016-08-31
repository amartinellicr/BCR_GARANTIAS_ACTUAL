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
using System.IO;

namespace BCRGARANTIAS.Forms
{
    public partial class frmUsuarios : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnValidar.Click += new EventHandler(btnValidar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el usuario seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el usuario seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_USUARIO"].ToString())))
                    {
                        CargarComboPerfil();
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

        /// <summary>
        /// Metodo que permite la inserción de grupos de interes economicos
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    if (!Gestor.UsuarioExiste(txtID.Text))
                    {
                        Gestor.CrearUsuario(txtID.Text, txtNombre.Text, int.Parse(cbPerfil.SelectedValue.ToString()), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserción Exitosa" +
                                        "&strMensaje=" + "El usuario se insertó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmUsuarios.aspx");
                    }
                    else
                    {
                        lblMensaje.Text = "El usuario que intenta insertar ya existe";
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
                                    "&strMensaje=" + "No se puede insertar registros duplicados. Verifique el número de identificación del usuario." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmUsuarios.aspx");
                }
            }
        }

        /// <summary>
        /// Metodo que valida el usuario contra el Active Directory y obtiene el nombre del usuario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (txtID.Text.Trim().Length == 0)
                    lblMensaje.Text = "Debe ingresar el número de identificación del usuario.";
                else
                {
                    //string strNombre = Gestor.ObtenerNombreUsuario(txtID.Text);
					//BCR.ActiveDirectory.Objects.User oUser = new BCR.ActiveDirectory.Objects.User();
                    //oUser.GetUserInformation(txtID.Text);
					string strNombre = Gestor.ObtenerNombreUsuario(txtID.Text);//oUser.DisplayName;

                    if (strNombre.Length == 0)
                    {
                        lblMensaje.Text = "Usuario inválido.";
                        txtNombre.Text = "";
                    }
                    else
                        txtNombre.Text = strNombre;

                }
            }
            catch (Exception ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas Validando Usuario" +
                                "&strMensaje=" + "Este usuario no se encuentra registrado en el Active Directory. " + ex.Message.Replace("\n", string.Empty) + "\r" +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmUsuarios.aspx");
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                txtID.Text = "";
                txtNombre.Text = "";
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                lblMensaje.Text = string.Empty;
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
                    Gestor.ModificarUsuario(txtID.Text, txtNombre.Text, int.Parse(cbPerfil.SelectedValue.ToString()), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=0" +
                        "&strTitulo=" + "Modificación Exitosa" +
                        "&strMensaje=" + "La información del usuario se modificó satisfactoriamente." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmUsuarios.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Modificando Registro" +
                        "&strMensaje=" + "No se pudo modificar la información del usuario." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmUsuarios.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    Gestor.EliminarUsuario(txtID.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=0" +
                        "&strTitulo=" + "Eliminación Exitosa" +
                        "&strMensaje=" + "El usuario se eliminó satisfactoriamente." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmUsuarios.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Eliminando Registro" +
                        "&strMensaje=" + "No se pudo eliminar el usuario." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmUsuarios.aspx");
                }
            }
        }

        #endregion
              
        #region Métodos GridView

        protected void gdvUsuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvUsuarios = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedUsuario"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvUsuarios.SelectedIndex = rowIndex;

                        try
                        {
                            if (gdvUsuarios.SelectedDataKey[0].ToString() != null)
                                txtID.Text = gdvUsuarios.SelectedDataKey[0].ToString();
                            else
                                txtID.Text = "";

                            if (gdvUsuarios.SelectedDataKey[1].ToString() != null)
                                txtNombre.Text = gdvUsuarios.SelectedDataKey[1].ToString();
                            else
                                txtNombre.Text = "";

                            CargarComboPerfil();
                            cbPerfil.Items.FindByText(gdvUsuarios.SelectedDataKey[2].ToString()).Selected = true;

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
        
        protected void gdvUsuarios_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvUsuarios.SelectedIndex = -1;
            this.gdvUsuarios.PageIndex = e.NewPageIndex;
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT a.COD_USUARIO, a.DES_USUARIO, b.DES_PERFIL FROM SEG_USUARIO a INNER JOIN SEG_PERFIL b ON a.COD_PERFIL = b.COD_PERFIL ORDER BY DES_USUARIO", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Usuarios");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Usuarios"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Usuarios"].Rows[0].IsNull("COD_USUARIO")) &&
                        (!dsDatos.Tables["Usuarios"].Rows[0].IsNull("DES_USUARIO")) &&
                        (!dsDatos.Tables["Usuarios"].Rows[0].IsNull("DES_PERFIL")))
                    {
                        this.gdvUsuarios.DataSource = dsDatos.Tables["Usuarios"].DefaultView;
                        this.gdvUsuarios.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Usuarios"].Rows.Add(dsDatos.Tables["Usuarios"].NewRow());
                        this.gdvUsuarios.DataSource = dsDatos;
                        this.gdvUsuarios.DataBind();

                        int TotalColumns = this.gdvUsuarios.Rows[0].Cells.Count;
                        this.gdvUsuarios.Rows[0].Cells.Clear();
                        this.gdvUsuarios.Rows[0].Cells.Add(new TableCell());
                        this.gdvUsuarios.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvUsuarios.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables["Usuarios"].Rows.Add(dsDatos.Tables["Usuarios"].NewRow());
                    this.gdvUsuarios.DataSource = dsDatos;
                    this.gdvUsuarios.DataBind();

                    int TotalColumns = this.gdvUsuarios.Rows[0].Cells.Count;
                    this.gdvUsuarios.Rows[0].Cells.Clear();
                    this.gdvUsuarios.Rows[0].Cells.Add(new TableCell());
                    this.gdvUsuarios.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvUsuarios.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Metodo que carga el combo de perfiles
        /// </summary>
        private void CargarComboPerfil()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT COD_PERFIL, DES_PERFIL FROM SEG_PERFIL ORDER BY DES_PERFIL", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Perfiles");
            cbPerfil.DataSource = null;
            cbPerfil.DataSource = dsDatos.Tables["Perfiles"].DefaultView;
            cbPerfil.DataValueField = "COD_PERFIL";
            cbPerfil.DataTextField = "DES_PERFIL";
            cbPerfil.DataBind();
        }

        /// <summary>
        /// Metodo de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                if (bRespuesta && txtID.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el número de identificación del usuario.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombre.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe validar el usuario contra el Active Directory.";
                    bRespuesta = false;
                }
                if (bRespuesta && cbPerfil.SelectedIndex == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el perfil que desea asignarle al usuario.";
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
