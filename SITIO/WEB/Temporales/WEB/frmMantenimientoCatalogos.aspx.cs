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
using System.Collections.Generic;

using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Forms
{
    public partial class frmMantenimientoCatalogos : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string _mensajeAlertaCatalogoTipoBien = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCatalogoTipoBien) !== 'undefined'){$MensajeCatalogoTipoBien.dialog('open');} </script>";
        private const string _mensajeAlertaCatalogoPorcentajeTipoGarantia = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCatalogoPorcentajeTipoGarantia) !== 'undefined'){$MensajeCatalogoPorcentajeTipoGarantia.dialog('open');} </script>";
        private const string _mensajeAlertaCatalogoPorcentajeTipoMitigador = "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeCatalogoPorcentajeTipoMitigador) !== 'undefined'){$MensajeCatalogoPorcentajeTipoMitigador.dialog('open');} </script>";

        private const string LLAVE_CODIGO_CATALOGO = "LLAVE_CODIGO_CATALOGO";

        #endregion Constantes

        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;

        private int nCatalogo;
        private ScriptManager requestSM;

        #endregion

        #region Propiedades

        /// <summary>
        /// Se almacena y se obtiene el código del catálogo que se está manipulando
        /// </summary>
        public int CodigoCatalogo
        {
            get
            {
                
                if ((ViewState[LLAVE_CODIGO_CATALOGO] != null) && (ViewState[LLAVE_CODIGO_CATALOGO].ToString().Trim().Length > 0))
                {
                    return ((int.TryParse(ViewState[LLAVE_CODIGO_CATALOGO].ToString(), out nCatalogo)) ? nCatalogo : -1);
                }
                else
                {
                    return -1;
                }
            }

            set
            {
                ViewState.Add(LLAVE_CODIGO_CATALOGO, value.ToString());
            }
        }

        #endregion Porpiedades

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
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el campo seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el campo seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_CATALOGOS"].ToString())))
                    {
                        nCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
                        CodigoCatalogo = nCatalogo;

                        lblCatalogo.Text = "Catálogo de " + Request.QueryString["strCatalogo"].ToString();

                        if (nCatalogo == int.Parse(Application["CAT_TIPOS_POLIZAS_SAP"].ToString()))
                        {
                            txtCodigo.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
                        }

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
            string CodigoElemento = string.Empty;

            try
            {
                if (ValidarDatos())
                {
                    CodigoElemento = txtCodigo.Text;

                    if (CodigoCatalogo == int.Parse(Application["CAT_TIPOS_POLIZAS_SAP"].ToString()))
                    {
                        CodigoElemento = int.Parse(txtCodigo.Text).ToString();
                    }

                    Gestor.CrearCampoCatalogo(int.Parse(Request.QueryString["nCatalogo"].ToString()), CodigoElemento,
                                              txtDescripcion.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El campo del catálogo se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }     

                CargarGrid();
                
            }
           catch (ExcepcionBase ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + ex.Message + "\r" +
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
                lblMensaje.Text = string.Empty;

                CargarGrid();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            bool modificarElemento = true;
            int elemento;
            string CodigoElemento = string.Empty;

            try
            {
                if (ValidarDatos())
                {
                    elemento = int.Parse(txtCodigo.Text);

                    if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_BIEN"].ToString()))
                    {
                        requestSM = ScriptManager.GetCurrent(this.Page);

                        string catalogoPolizasSap = Application["CAT_TIPOS_POLIZAS_SAP"].ToString();

                        clsTiposBienRelacionados<clsTipoBienRelacionado> relacionesTipoBien = Gestor.ObtenerTiposBienRelacionados(elemento, null, null, CodigoCatalogo.ToString(), catalogoPolizasSap);

                        modificarElemento = ((relacionesTipoBien.Count > 0) ? false : true);

                        //Se obtiene el error de la lista de errores
                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                        {
                            ScriptManager.RegisterClientScriptBlock(this,
                                                                    typeof(Page),
                                                                    Guid.NewGuid().ToString(),
                                                                    _mensajeAlertaCatalogoTipoBien,
                                                                    false);
                        }
                        else
                        {
                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                   Guid.NewGuid().ToString(),
                                                                   _mensajeAlertaCatalogoTipoBien,
                                                                   false);
                        }
                    }


                    #region Validacion Porcentaje Aceptacion

                    DataSet registroExistente = new DataSet();

                    if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_GARANTIA"].ToString()))
                    {
                        requestSM = ScriptManager.GetCurrent(this.Page);

                        registroExistente = Gestor.ObtenerDatosPorcentajeAceptacion(null, elemento, null, 2);

                        modificarElemento = ((registroExistente != null) && (registroExistente.Tables[0].Rows.Count > 0)) ? false : true;
                      
                        //Se obtiene el error de la lista de errores
                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                        {
                            ScriptManager.RegisterClientScriptBlock(this,
                                                                    typeof(Page),
                                                                    Guid.NewGuid().ToString(),
                                                                    _mensajeAlertaCatalogoPorcentajeTipoGarantia,
                                                                    false);
                        }
                        else
                        {
                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                   Guid.NewGuid().ToString(),
                                                                   _mensajeAlertaCatalogoPorcentajeTipoGarantia,
                                                                   false);
                        }
                    }

                    if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString()))
                    {
                        requestSM = ScriptManager.GetCurrent(this.Page);

                        registroExistente = Gestor.ObtenerDatosPorcentajeAceptacion(null, null, elemento, 3);

                        modificarElemento = ((registroExistente != null) && (registroExistente.Tables[0].Rows.Count > 0)) ? false : true;                    

                        //Se obtiene el error de la lista de errores
                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                        {
                            ScriptManager.RegisterClientScriptBlock(this,
                                                                    typeof(Page),
                                                                    Guid.NewGuid().ToString(),
                                                                    _mensajeAlertaCatalogoPorcentajeTipoMitigador,
                                                                    false);
                        }
                        else
                        {
                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                   Guid.NewGuid().ToString(),
                                                                   _mensajeAlertaCatalogoPorcentajeTipoMitigador,
                                                                   false);
                        }
                    }

                    #endregion


                    if (modificarElemento)
                    {
                        CodigoElemento = txtCodigo.Text;

                        if (CodigoCatalogo == int.Parse(Application["CAT_TIPOS_POLIZAS_SAP"].ToString()))
                        {
                            CodigoElemento = int.Parse(txtCodigo.Text).ToString();
                        }

                        Gestor.ModificarCampoCatalogo(int.Parse(lblElemento.Text), CodigoElemento,
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
            }
            catch (ExcepcionBase ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + ex.Message + "\r" +
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
            bool eliminarElemento = true;
            int elemento;
          

            try
            {
                elemento = int.Parse(txtCodigo.Text);

                if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_BIEN"].ToString()))
                {
                    requestSM = ScriptManager.GetCurrent(this.Page);

                    string catalogoPolizasSap = Application["CAT_TIPOS_POLIZAS_SAP"].ToString();

                    clsTiposBienRelacionados<clsTipoBienRelacionado> relacionesTipoBien = Gestor.ObtenerTiposBienRelacionados(elemento, null, null, CodigoCatalogo.ToString(), catalogoPolizasSap);

                    eliminarElemento = ((relacionesTipoBien.Count > 0) ? false : true);

                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                _mensajeAlertaCatalogoTipoBien,
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               _mensajeAlertaCatalogoTipoBien,
                                                               false);
                    }
                }

                #region Validacion Porcentaje Aceptacion 

                DataSet registroExistente =  new DataSet();

                if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_GARANTIA"].ToString()))
                {
                    requestSM = ScriptManager.GetCurrent(this.Page);

                    registroExistente = Gestor.ObtenerDatosPorcentajeAceptacion(null, elemento, null, 2);

                    eliminarElemento = ((registroExistente != null) && (registroExistente.Tables[0].Rows.Count > 0)) ? false : true;               
                  
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                _mensajeAlertaCatalogoPorcentajeTipoGarantia,
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               _mensajeAlertaCatalogoPorcentajeTipoGarantia,
                                                               false);
                    }
                }

                if (CodigoCatalogo == int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString()))
                {
                    requestSM = ScriptManager.GetCurrent(this.Page);

                    registroExistente = Gestor.ObtenerDatosPorcentajeAceptacion(null,null,elemento, 3);

                    eliminarElemento = ((registroExistente != null) && (registroExistente.Tables[0].Rows.Count > 0)) ? false : true;     
                  
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                _mensajeAlertaCatalogoPorcentajeTipoMitigador,
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               _mensajeAlertaCatalogoPorcentajeTipoMitigador,
                                                               false);
                    }
                }

                #endregion



                if (eliminarElemento)
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
            }
            catch (ExcepcionBase ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + ex.Message + "\r" +
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
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_elemento, cat_catalogo, cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + CodigoCatalogo + " ORDER BY cat_campo", oleDbConnection1);
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
