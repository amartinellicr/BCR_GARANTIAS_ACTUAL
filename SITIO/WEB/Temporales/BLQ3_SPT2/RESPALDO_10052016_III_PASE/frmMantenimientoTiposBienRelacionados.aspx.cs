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

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Forms
{

public partial class frmMantenimientoTiposBienRelacionados : BCR.Web.SystemFramework.PaginaPersistente
{
    #region Constantes

    private const string LLAVE_CODIGO_CATALOGO = "LLAVE_CODIGO_CATALOGO";
    private const string LLAVE_REGISTRO_CONSULTADO = "LLAVE_REGISTRO_CONSULTADO";
    private const string LLAVE_REGISTRO_DUPLICADO = "LLAVE_REGISTRO_DUPLICADO";
    private const string LLAVE_INDICE_REGISTRO_DUPLICADO = "LLAVE_INDICE_REGISTRO_DUPLICADO";

    #endregion Constantes

    #region Variables Globales

    private int nCatalogo;
    private clsTipoBienRelacionado tipoBienRelacionadoConsultado = new clsTipoBienRelacionado();
    private int consecutivoRelacion;
    private int indiceRegistroDuplicado;

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

    /// <summary>
    /// Se almacena y se obtiene el código del registro duplicado
    /// </summary>
    public int ConsecutivoRelacion
    {
        get
        {

            if ((ViewState[LLAVE_REGISTRO_DUPLICADO] != null) && (ViewState[LLAVE_REGISTRO_DUPLICADO].ToString().Trim().Length > 0))
            {
                return ((int.TryParse(ViewState[LLAVE_REGISTRO_DUPLICADO].ToString(), out consecutivoRelacion)) ? consecutivoRelacion : -1);
            }
            else
            {
                return -1;
            }
        }

        set
        {
            ViewState.Add(LLAVE_REGISTRO_DUPLICADO, value.ToString());
        }
    }

    /// <summary>
    /// Se almacena y se obtiene el índice dentro del grid del registro duplicado
    /// </summary>
    public int IndiceRegistroDuplicado
    {
        get
        {

            if ((ViewState[LLAVE_INDICE_REGISTRO_DUPLICADO] != null) && (ViewState[LLAVE_INDICE_REGISTRO_DUPLICADO].ToString().Trim().Length > 0))
            {
                return ((int.TryParse(ViewState[LLAVE_INDICE_REGISTRO_DUPLICADO].ToString(), out indiceRegistroDuplicado)) ? indiceRegistroDuplicado : -1);
            }
            else
            {
                return -1;
            }
        }

        set
        {
            ViewState.Add(LLAVE_INDICE_REGISTRO_DUPLICADO, value.ToString());
        }
    }

    /// <summary>
    /// Se almacena y se obtiene la entidad del registro consultado inicialmente
    /// </summary>
    public clsTipoBienRelacionado RegistroInicialConsultado
    {
        get
        {

            if (ViewState[LLAVE_REGISTRO_CONSULTADO] != null) 
            {
                return ((clsTipoBienRelacionado)ViewState[LLAVE_REGISTRO_CONSULTADO]);
            }
            else
            {
                return new clsTipoBienRelacionado();
            }
        }

        set
        {
            ViewState.Add(LLAVE_REGISTRO_CONSULTADO, value);
        }
    }


    #endregion Porpiedades

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        btnEliminar.Click += new EventHandler(btnEliminar_Click);
        btnInsertar.Click += new EventHandler(btnInsertar_Click);
        btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
        btnModificar.Click += new EventHandler(btnModificar_Click);
        btnRegresar.Click += new EventHandler(btnRegresar_Click);
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
                    CodigoCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
                    lblCatalogo.Text = "Catálogo de " + Request.QueryString["strCatalogo"].ToString();

                    CargarCatalogos();
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
        else
        {
            if ((Request.Form["__EVENTARGUMENT"] != null) && (Request.Form["__EVENTARGUMENT"].Length > 0) &&
                           (Request.Form["__EVENTARGUMENT"].CompareTo("Metodo") == 0))
            {
                CargarGrid();
            }
        }
    }

    private void btnInsertar_Click(object sender, System.EventArgs e)
    {
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
        clsTipoBienRelacionado tipoBienRelacionado;

        try
        {
            if (ValidarDatos())
            {
                tipoBienRelacionado  = new clsTipoBienRelacionado();

                tipoBienRelacionado.TipoBien = int.Parse(cbTipoBien.SelectedItem.Value);
                tipoBienRelacionado.TipoPolizaSap = int.Parse(cbTipoPolizaSap.SelectedItem.Value);
                tipoBienRelacionado.TipoPolizaSugef = int.Parse(cbTipoPolizaSugef.SelectedItem.Value);

                Gestor.CrearTipoBienRelacionado(tipoBienRelacionado, Session["strUSER"].ToString(), Request.UserHostAddress.ToString(),
                                                Application["CAT_TIPO_BIEN"].ToString(), Application["CAT_TIPOS_POLIZAS_SAP"].ToString());

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Inserción Exitosa" +
                                "&strMensaje=" + "El campo del catálogo se insertó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

            }
        }
        catch (ExcepcionBase ex)
        {
             tipoBienRelacionado  = new clsTipoBienRelacionado();
       
            //Se obtiene el error de la lista de errores
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        tipoBienRelacionado.MensajeRegistroDuplicado,
                                                        false);          
            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                        tipoBienRelacionado.MensajeRegistroDuplicado,
                                                       false);
            }

            ConsecutivoRelacion = Convert.ToInt16(ex.Message);

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
                                "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            
            }
        }
    }

    private void btnLimpiar_Click(object sender, System.EventArgs e)
    {
        try
        {
            cbTipoBien.SelectedIndex = -1;
            cbTipoPolizaSap.SelectedIndex = -1;
            cbTipoPolizaSugef.SelectedIndex = -1;

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
               clsTipoBienRelacionado tipoBienRelacionado = new clsTipoBienRelacionado();

        try
        {
            if (ValidarDatos())
            {
                tipoBienRelacionado = new clsTipoBienRelacionado();

                tipoBienRelacionado.ConsecutivoRelacion = RegistroInicialConsultado.ConsecutivoRelacion;
                tipoBienRelacionado.TipoBien = int.Parse(cbTipoBien.SelectedItem.Value);
                tipoBienRelacionado.TipoPolizaSap = int.Parse(cbTipoPolizaSap.SelectedItem.Value);
                tipoBienRelacionado.TipoPolizaSugef = int.Parse(cbTipoPolizaSugef.SelectedItem.Value);

                Gestor.ModificarTipoBienRelacionado(tipoBienRelacionado, RegistroInicialConsultado, Session["strUSER"].ToString(), Request.UserHostAddress.ToString(),
                                                    Application["CAT_TIPO_BIEN"].ToString(), Application["CAT_TIPOS_POLIZAS_SAP"].ToString());

                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Modificación Exitosa" +
                    "&strMensaje=" + "El campo del catálogo se modificó satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
        }
        catch (ExcepcionBase ex)
        {
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
            tipoBienRelacionado = new clsTipoBienRelacionado();

            //Se obtiene el error de la lista de errores
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        tipoBienRelacionado.MensajeRegistroDuplicado,
                                                        false);

            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                        tipoBienRelacionado.MensajeRegistroDuplicado,
                                                       false);
            }

            ConsecutivoRelacion = Convert.ToInt16(ex.Message); //RegistroInicialConsultado.RowIndex;        
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
                "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
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
            clsTipoBienRelacionado tipoBienRelacionado = new clsTipoBienRelacionado();

            tipoBienRelacionado.ConsecutivoRelacion = RegistroInicialConsultado.ConsecutivoRelacion;
            tipoBienRelacionado.TipoBien = int.Parse(cbTipoBien.SelectedItem.Value);
            tipoBienRelacionado.TipoPolizaSap = int.Parse(cbTipoPolizaSap.SelectedItem.Value);
            tipoBienRelacionado.TipoPolizaSugef = int.Parse(cbTipoPolizaSugef.SelectedItem.Value);

            Gestor.EliminarTipoBienRelacionado(tipoBienRelacionado, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

            Response.Redirect("frmMensaje.aspx?" +
                "bError=0" +
                "&strTitulo=" + "Eliminación Exitosa" +
                "&strMensaje=" + "El campo del catálogo se eliminó satisfactoriamente." +
                "&bBotonVisible=1" +
                "&strTextoBoton=Regresar" +
                "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
        }
        catch (ExcepcionBase exb)
        {
            Response.Redirect("frmMensaje.aspx?" +
                "bError=1" +
                "&strTitulo=" + "Problemas Eliminando Registro" +
                "&strMensaje=" + exb.Message + "\r" +
                "&bBotonVisible=1" +
                "&strTextoBoton=Regresar" +
                "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

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
                    "&strHref=frmMantenimientoTiposBienRelacionados.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
        }
    }

    #endregion

    #region Métodos GridView

    protected void gdvCatalogos_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        GridView gdvCatalogos = (GridView)sender;
        int rowIndex = 0;

        int consecutivoRegistro;
        int codigoTipoBien;
        int codigoTipoPolizaSugef;
        int cosigoTipopolizaSap;

        try
        {
            switch (e.CommandName)
            {
                case ("SelectedCatalogo"):
                    rowIndex = (int.Parse(e.CommandArgument.ToString()));
                    
                    gdvCatalogos.SelectedIndex = rowIndex;

                    try
                    {
                        cbTipoPolizaSap.ClearSelection();
                        cbTipoPolizaSugef.ClearSelection();
                        cbTipoBien.ClearSelection();

                        if (gdvCatalogos.SelectedDataKey[1].ToString() != null)
                            cbTipoPolizaSap.Items.FindByValue(gdvCatalogos.SelectedDataKey[1].ToString()).Selected = true;
                        else
                            cbTipoPolizaSap.SelectedIndex = -1;

                        if (gdvCatalogos.SelectedDataKey[2].ToString() != null)
                            cbTipoPolizaSugef.Items.FindByValue(gdvCatalogos.SelectedDataKey[2].ToString()).Selected = true;
                        else
                            cbTipoPolizaSugef.SelectedIndex = -1;

                        if (gdvCatalogos.SelectedDataKey[3].ToString() != null)
                            cbTipoBien.Items.FindByValue(gdvCatalogos.SelectedDataKey[3].ToString()).Selected = true;
                        else
                            cbTipoBien.SelectedIndex = -1;

                        if (gdvCatalogos.SelectedDataKey[0].ToString() != null)
                            lblElemento.Text = gdvCatalogos.SelectedDataKey[0].ToString();
                        else
                            lblElemento.Text = "";

                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;

                        tipoBienRelacionadoConsultado = new clsTipoBienRelacionado();

                        tipoBienRelacionadoConsultado.ConsecutivoRelacion = ((int.TryParse(lblElemento.Text, out consecutivoRegistro)) ? consecutivoRegistro : -1);
                        tipoBienRelacionadoConsultado.TipoBien = ((int.TryParse(cbTipoBien.SelectedItem.Value, out codigoTipoBien)) ? codigoTipoBien : -1);
                        tipoBienRelacionadoConsultado.TipoPolizaSap = ((int.TryParse(cbTipoPolizaSap.SelectedItem.Value, out cosigoTipopolizaSap)) ? cosigoTipopolizaSap : -1);
                        tipoBienRelacionadoConsultado.TipoPolizaSugef = ((int.TryParse(cbTipoPolizaSugef.SelectedItem.Value, out codigoTipoPolizaSugef)) ? codigoTipoPolizaSugef : -1);

                        tipoBienRelacionadoConsultado.RowIndex = rowIndex;

                        RegistroInicialConsultado = tipoBienRelacionadoConsultado;
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

        if (CodigoCatalogo <= 0)
        {
            CodigoCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
        }

        CargarGrid();
    }

    protected void gdvCatalogos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {       
            LinkButton tipoGarantiaSugef = ((LinkButton)e.Row.Cells[2].Controls[0]);
            tipoGarantiaSugef.ToolTip = ((clsTipoBienRelacionado) e.Row.DataItem).DescripcionTipoPolizaSugef;

            //agregar aqui el consecutivo retornado seleccionar el rowIndex, falta el pageIndex porque creo que esto es solo para la pagina principal

            try             
            {
                if (consecutivoRelacion > 0)
                {                    
                    int consecutivo = ((clsTipoBienRelacionado)e.Row.DataItem).ConsecutivoRelacion;

                    if (consecutivo == ConsecutivoRelacion)
                    {
                        IndiceRegistroDuplicado = e.Row.RowIndex;
                        ConsecutivoRelacion = -1;
                    }

                }
            
            }
            catch(Exception ex)
            {
                string m = ex.Message;
            }          

        }
        
    }

    protected void gdvCatalogos_DataBinding(object sender, EventArgs e)
    {
        
    }

    #endregion

    #region Métodos Privados
    /// <summary>
    /// Metodo que carga el grid con la informacion de grupos de interes economico
    /// </summary>
    private void CargarGrid()
    {
        clsTiposBienRelacionados<clsTipoBienRelacionado> tiposBienRelacionados = new clsTiposBienRelacionados<clsTipoBienRelacionado>();

        try
        {
            tiposBienRelacionados = Gestor.ObtenerTiposBienRelacionados(null, null, null, Application["CAT_TIPO_BIEN"].ToString(), Application["CAT_TIPOS_POLIZAS_SAP"].ToString());

            if ((tiposBienRelacionados != null) && (tiposBienRelacionados.Count > 0))
            {
                if (ConsecutivoRelacion > -1)
                {
                    int posicionContenedor = 0;
                    for (int indice = 0; indice <= tiposBienRelacionados.Count - 1; indice++)
                    {
                        if (tiposBienRelacionados.Item(indice).ConsecutivoRelacion == ConsecutivoRelacion)
                        {
                            posicionContenedor = indice;
                            break;
                        }
                    }

                    this.gdvCatalogos.PageIndex = posicionContenedor / this.gdvCatalogos.PageSize;
                    this.gdvCatalogos.SelectedIndex = (posicionContenedor - (this.gdvCatalogos.PageSize * this.gdvCatalogos.PageIndex));
                }

                this.gdvCatalogos.DataSource = tiposBienRelacionados;
                this.gdvCatalogos.DataBind();
            }
            else
            {
                this.gdvCatalogos.DataSource = null;
                this.gdvCatalogos.DataBind();
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
    /// <returns>True: Los datos son válidos. False: Falta algún dato.</returns>
    private bool ValidarDatos()
    {
        bool bRespuesta = true;

        try
        {
            lblMensaje.Text = "";
            if (bRespuesta && cbTipoPolizaSap.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el tipo de póliza SAP.";
                bRespuesta = false;
            }
            if (bRespuesta && cbTipoPolizaSugef.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el tipo de póliza SUGEF.";
                bRespuesta = false;
            }
            if (bRespuesta && cbTipoBien.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el tipo de bien.";
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
    /// Permite cargar los catálogos
    /// </summary>
    private void CargarCatalogos()
    {
        CargarTiposBien();
        CargarTiposPolizasSap();
        CargarTiposPolizasSugef();
    }


    /// <summary>
    /// Carga la lista de tipos de bien
    /// </summary>
    private void CargarTiposBien()
    {
        try
        {
            string catalogoTipoBien = "|" + Application["CAT_TIPO_BIEN"].ToString() + "|";
            List<clsCatalogo> catalogoTiposBien = Gestor.ObtenerCatalogos(catalogoTipoBien).Items((int.Parse(Application["CAT_TIPO_BIEN"].ToString())));

            cbTipoBien.DataSource = null;
            cbTipoBien.DataSource = catalogoTiposBien;
            cbTipoBien.DataValueField = "CodigoElemento";
            cbTipoBien.DataTextField = "DescripcionCodigoElemento";
            cbTipoBien.DataBind();
            cbTipoBien.ClearSelection();

        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    /// <summary>
    /// Carga la lista de tipos de pólizas SAP
    /// </summary>
    private void CargarTiposPolizasSap()
    {
        try
        {
            string catalogoTipoPolizaSap = "|" + Application["CAT_TIPOS_POLIZAS_SAP"].ToString() + "|";
            List<clsCatalogo> catalogoTiposPolizaSap = Gestor.ObtenerCatalogos(catalogoTipoPolizaSap).Items((int.Parse(Application["CAT_TIPOS_POLIZAS_SAP"].ToString())));

            cbTipoPolizaSap.DataSource = null;
            cbTipoPolizaSap.DataSource = catalogoTiposPolizaSap;
            cbTipoPolizaSap.DataValueField = "CodigoElemento";
            cbTipoPolizaSap.DataTextField = "DescripcionCodigoElemento";
            cbTipoPolizaSap.DataBind();
            cbTipoPolizaSap.ClearSelection();

        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    /// <summary>
    /// Carga la lista de tipos de pólizas SUGEF
    /// </summary>
    private void CargarTiposPolizasSugef()
    {
       int consecutivo;

        try
        {
            List<clsTipoPolizaSugef> catalogoTiposPolizaSugef = Gestor.ObtenerTiposPolizasSugef(null, true, out consecutivo).ListaOrdenada();

            cbTipoPolizaSugef.DataSource = null;
            cbTipoPolizaSugef.DataSource = catalogoTiposPolizaSugef;
            cbTipoPolizaSugef.DataValueField = "TipoPolizaSugef";
            cbTipoPolizaSugef.DataTextField = "NombreCodigoTipoPolizaSugef";
            cbTipoPolizaSugef.DataBind();
            cbTipoPolizaSugef.ClearSelection();
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    #endregion
   
}
}