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
    public partial class frmMantenimientoCatalogos : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;

        private int nCatalogo;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnRegresar.Click +=new EventHandler(btnRegresar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            //txtCodigo.Attributes["onblur"] = "javascript:EsNumerico(this);";

            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el campo seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el campo seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_CATALOGOS"].ToString())))
                    {
                        nCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
                        lblCatalogo.Text = "Catálogo de " + Request.QueryString["strCatalogo"].ToString();

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
                if (ValidarDatos())
                {
                    Gestor.CrearCampoCatalogo(int.Parse(Request.QueryString["nCatalogo"].ToString()), txtCodigo.Text,
                                              txtDescripcion.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El campo del catálogo se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + "No se pudo insertar el campo del catálogo." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                txtCodigo.Text = "";
                txtDescripcion.Text = "";
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
                if (ValidarDatos())
                {
                    //Gestor.ModificarCampoCatalogo(nElemento,nCampo, strCampo);
                    Gestor.ModificarCampoCatalogo(int.Parse(lblElemento.Text), txtCodigo.Text,
                                                  txtDescripcion.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=0" +
                        "&strTitulo=" + "Modificación Exitosa" +
                        "&strMensaje=" + "El campo del catálogo se modificó satisfactoriamente." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Modificando Registro" +
                        "&strMensaje=" + "No se pudo modificar la información del campo del catálogo." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
        }

        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmCatalogos.aspx");
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarCampoCatalogo(int.Parse(lblElemento.Text), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Eliminación Exitosa" +
                    "&strMensaje=" + "El campo del catálogo se eliminó satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Eliminando Registro" +
                        "&strMensaje=" + "No se pudo eliminar el campo del catálogo." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
        }

        #endregion
                
        #region Métodos GridView

        protected void gdvCatalogos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvCatalogos = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedCatalogo"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvCatalogos.SelectedIndex = rowIndex;

                        try
                        {
                            if (gdvCatalogos.SelectedDataKey[2].ToString() != null)
                                txtCodigo.Text = gdvCatalogos.SelectedDataKey[2].ToString();
                            else
                                txtCodigo.Text = "";

                            if (gdvCatalogos.SelectedDataKey[3].ToString() != null)
                                txtDescripcion.Text = gdvCatalogos.SelectedDataKey[3].ToString().Trim();
                            else
                                txtDescripcion.Text = "";

                            if (gdvCatalogos.SelectedDataKey[0].ToString() != null)
                                lblElemento.Text = gdvCatalogos.SelectedDataKey[0].ToString();
                            else
                                lblElemento.Text = "";

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
        
        protected void gdvCatalogos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvCatalogos.SelectedIndex = -1;
            this.gdvCatalogos.PageIndex = e.NewPageIndex;

            if (nCatalogo <= 0)
            {
                nCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
            }

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
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_elemento, cat_catalogo, cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + nCatalogo + " ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Catalogo");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Catalogo"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Catalogo"].Rows[0].IsNull("cat_campo")) &&
                        (!dsDatos.Tables["Catalogo"].Rows[0].IsNull("cat_descripcion")))
                    {
                        this.gdvCatalogos.DataSource = dsDatos.Tables["Catalogo"].DefaultView;
                        this.gdvCatalogos.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Catalogo"].Rows.Add(dsDatos.Tables["Catalogo"].NewRow());
                        this.gdvCatalogos.DataSource = dsDatos;
                        this.gdvCatalogos.DataBind();

                        int TotalColumns = this.gdvCatalogos.Rows[0].Cells.Count;
                        this.gdvCatalogos.Rows[0].Cells.Clear();
                        this.gdvCatalogos.Rows[0].Cells.Add(new TableCell());
                        this.gdvCatalogos.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvCatalogos.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables["Catalogo"].Rows.Add(dsDatos.Tables["Catalogo"].NewRow());
                    this.gdvCatalogos.DataSource = dsDatos;
                    this.gdvCatalogos.DataBind();

                    int TotalColumns = this.gdvCatalogos.Rows[0].Cells.Count;
                    this.gdvCatalogos.Rows[0].Cells.Clear();
                    this.gdvCatalogos.Rows[0].Cells.Add(new TableCell());
                    this.gdvCatalogos.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvCatalogos.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
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
                if (bRespuesta && txtCodigo.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código del campo.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtDescripcion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la descripción del campo.";
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
