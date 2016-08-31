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
    public partial class frmPerfiles : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;

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
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el perfil seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el perfil seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_PERFILES"].ToString())))
                    {
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
                if (ValidarPerfiles())
                {
                    //					if (strPerfil.Length == 0)
                    //						strPerfil = txtPerfil.Text;

                    Gestor.CrearPerfil(txtPerfil.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El perfil de seguridad se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPerfiles.aspx");
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + "No se pudo insertar el perfil de seguridad." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPerfiles.aspx");
                }
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                txtPerfil.Text = "";
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
                if (ValidarPerfiles())
                {
                    Gestor.ModificarPerfil(int.Parse(Session["Perfil"].ToString()), txtPerfil.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "El perfil de seguridad se modificó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPerfiles.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la información del perfil de seguridad." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPerfiles.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarPerfil(int.Parse(Session["Perfil"].ToString()), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + "El perfil de seguridad se eliminó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmPerfiles.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar el perfil de seguridad. Por favor verifique si hay Perfiles relacionados a este perfil." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmPerfiles.aspx");
                }
            }
        }

        #endregion
                
        #region Métodos GridView

        protected void gdvPerfiles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvPerfiles = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedPerfil"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvPerfiles.SelectedIndex = rowIndex;

                        if ((gdvPerfiles.SelectedDataKey[0].ToString() != null) && ((gdvPerfiles.SelectedDataKey[1].ToString() != null)))
                            try
                            {
                                //			strPerfil = txtPerfil.Text;
                                Session["Perfil"] = int.Parse(gdvPerfiles.SelectedDataKey[0].ToString());

                                txtPerfil.Text = gdvPerfiles.SelectedDataKey[1].ToString();
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
        
        protected void gdvPerfiles_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvPerfiles.SelectedIndex = -1;
            this.gdvPerfiles.PageIndex = e.NewPageIndex;
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
                System.Data.DataSet dsPerfiles = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT COD_PERFIL, DES_PERFIL FROM SEG_PERFIL ORDER BY DES_PERFIL", oleDbConnection1);
                cmdConsulta.Fill(dsPerfiles, "Perfiles");

                if ((dsPerfiles != null) && (dsPerfiles.Tables.Count > 0) && (dsPerfiles.Tables["Perfiles"].Rows.Count > 0))
                {

                    if (!dsPerfiles.Tables["Perfiles"].Rows[0].IsNull("DES_PERFIL"))
                    {
                        this.gdvPerfiles.DataSource = dsPerfiles.Tables["Perfiles"].DefaultView;
                        this.gdvPerfiles.DataBind();
                    }
                    else
                    {
                        dsPerfiles.Tables["Perfiles"].Rows.Add(dsPerfiles.Tables["Perfiles"].NewRow());
                        this.gdvPerfiles.DataSource = dsPerfiles;
                        this.gdvPerfiles.DataBind();

                        int TotalColumns = this.gdvPerfiles.Rows[0].Cells.Count;
                        this.gdvPerfiles.Rows[0].Cells.Clear();
                        this.gdvPerfiles.Rows[0].Cells.Add(new TableCell());
                        this.gdvPerfiles.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvPerfiles.Rows[0].Cells[0].Text = "No existen registros";
                        this.gdvPerfiles.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
                    }
                }
                else
                {
                    dsPerfiles.Tables["Perfiles"].Rows.Add(dsPerfiles.Tables["Perfiles"].NewRow());
                    this.gdvPerfiles.DataSource = dsPerfiles;
                    this.gdvPerfiles.DataBind();

                    int TotalColumns = this.gdvPerfiles.Rows[0].Cells.Count;
                    this.gdvPerfiles.Rows[0].Cells.Clear();
                    this.gdvPerfiles.Rows[0].Cells.Add(new TableCell());
                    this.gdvPerfiles.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvPerfiles.Rows[0].Cells[0].Text = "No existen registros";
                    this.gdvPerfiles.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Metodo de validación de Perfiles
        /// </summary>
        /// <returns></returns>
        private bool ValidarPerfiles()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                if (txtPerfil.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la descripción del perfil.";
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