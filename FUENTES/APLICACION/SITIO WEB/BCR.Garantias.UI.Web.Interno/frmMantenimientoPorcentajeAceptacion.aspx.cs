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


public partial class frmMantenimientoPorcentajeAceptacion : BCR.Web.SystemFramework.PaginaPersistente
{


    #region Constantes

    private const string LLAVE_CODIGO_CATALOGO = "LLAVE_CODIGO_CATALOGO";
    private const string LLAVE_REGISTRO_CONSULTADO = "LLAVE_REGISTRO_CONSULTADO";
    private const string LLAVE_REGISTRO_DUPLICADO = "LLAVE_REGISTRO_DUPLICADO";
    private const string LLAVE_INDICE_REGISTRO_DUPLICADO = "LLAVE_INDICE_REGISTRO_DUPLICADO";

    #endregion Constantes

    #region Variables Globales

    private int nCatalogo;
    private clsPorcentajeAceptacion porcentajeAceptacionConsultado = new clsPorcentajeAceptacion();
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
    /// Se almacena y se obtiene la entidad del registro consultado inicialmente
    /// </summary>
    public clsPorcentajeAceptacion RegistroInicialConsultado
    {
        get
        {

            if (ViewState[LLAVE_REGISTRO_CONSULTADO] != null)
            {
                return ((clsPorcentajeAceptacion)ViewState[LLAVE_REGISTRO_CONSULTADO]);
            }
            else
            {
                return new clsPorcentajeAceptacion();
            }
        }

        set
        {
            ViewState.Add(LLAVE_REGISTRO_CONSULTADO, value);
        }
    }


    #endregion

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

        txtPorcentajeAceptacion.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtPorcentajeAceptacion.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true);");

        txtPorcentajeCeroTres.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtPorcentajeCuatro.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtPorcentajeCinco.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtPorcentajeSeis.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");

        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_CATALOGOS"].ToString())))
                {
                    CodigoCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
                    lblCatalogo.Text = "Catálogo de " + Request.QueryString["strCatalogo"].ToString();

                    CargarCatalogos();
                    CargarGrid(null);
                    btnModificar.Enabled = false;
                    btnEliminar.Enabled = false;

                    txtFechaCambio.Text = System.DateTime.Now.ToShortDateString();

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
                CargarGrid(null);
            }
        }
    }

    private void btnInsertar_Click(object sender, System.EventArgs e)
    {
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
        clsPorcentajeAceptacion porcentajeAceptacion;

        try
        {
            if (ValidarDatos())
            {
                porcentajeAceptacion = new clsPorcentajeAceptacion();

                porcentajeAceptacion.CodigoTipoGarantia = int.Parse(cboTipoGarantia.SelectedItem.Value);
                porcentajeAceptacion.CodigoTipoMitigador = int.Parse(cboTipoMitigador.SelectedItem.Value);
                porcentajeAceptacion.IndicadorSinCalificacion = rdbListaClasificacion.Items[0].Selected;//rdbSinCalificacion.Checked;
                porcentajeAceptacion.PorcentajeAceptacion = decimal.Parse(txtPorcentajeAceptacion.Text);
                porcentajeAceptacion.PorcentajeCeroTres =  (txtPorcentajeCeroTres.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCeroTres.Text);
                porcentajeAceptacion.PorcentajeCuatro = (txtPorcentajeCuatro.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCuatro.Text);
                porcentajeAceptacion.PorcentajeCinco = (txtPorcentajeCinco.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCinco.Text);
                porcentajeAceptacion.PorcentajeSeis = (txtPorcentajeSeis.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeSeis.Text);

                Gestor.InsertarPorcentajeAceptacion(porcentajeAceptacion, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                 Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Inserción Exitosa" +
                                "&strMensaje=" + "El campo del catálogo se insertó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

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
                            "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

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
                                "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

            }
        }
    }

    private void btnLimpiar_Click(object sender, System.EventArgs e)
    {
        try
        {
            cboTipoGarantia.SelectedIndex = -1;
            cboTipoMitigador.SelectedIndex = -1;
            txtPorcentajeAceptacion.Text = string.Empty;
            txtPorcentajeCeroTres.Text = string.Empty;
            txtPorcentajeCuatro.Text = string.Empty;
            txtPorcentajeCinco.Text = string.Empty;
            txtPorcentajeSeis.Text = string.Empty;
            //rdbNoCalificacion.Checked = false;
            //rdbSinCalificacion.Checked = false;
            rdbListaClasificacion.ClearSelection();

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
        clsPorcentajeAceptacion porcentajeAceptacion;

        try
        {
            if (ValidarDatos())
            {
                porcentajeAceptacion = new clsPorcentajeAceptacion();

                porcentajeAceptacion.CodigoPorcentajeAceptacion = RegistroInicialConsultado.CodigoPorcentajeAceptacion;
                porcentajeAceptacion.CodigoTipoGarantia = int.Parse(cboTipoGarantia.SelectedItem.Value);
                porcentajeAceptacion.CodigoTipoMitigador = int.Parse(cboTipoMitigador.SelectedItem.Value);
                porcentajeAceptacion.IndicadorSinCalificacion = rdbListaClasificacion.Items[0].Selected; //rdbSinCalificacion.Checked;
                porcentajeAceptacion.PorcentajeAceptacion = decimal.Parse(txtPorcentajeAceptacion.Text);
                porcentajeAceptacion.PorcentajeCeroTres = (txtPorcentajeCeroTres.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCeroTres.Text);
                porcentajeAceptacion.PorcentajeCuatro = (txtPorcentajeCuatro.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCuatro.Text);
                porcentajeAceptacion.PorcentajeCinco = (txtPorcentajeCinco.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCinco.Text);
                porcentajeAceptacion.PorcentajeSeis = (txtPorcentajeSeis.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeSeis.Text);

                Gestor.ModificarPorcentajeAceptacion(porcentajeAceptacion, RegistroInicialConsultado, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

             
                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Modificación Exitosa" +
                    "&strMensaje=" + "El campo del catálogo se modificó satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
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
                            "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

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
                    "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
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
            clsPorcentajeAceptacion porcentajeAceptacion = new clsPorcentajeAceptacion();

            porcentajeAceptacion.CodigoPorcentajeAceptacion = RegistroInicialConsultado.CodigoPorcentajeAceptacion;
            porcentajeAceptacion.CodigoTipoGarantia = RegistroInicialConsultado.CodigoTipoGarantia;
            porcentajeAceptacion.CodigoTipoMitigador = RegistroInicialConsultado.CodigoTipoMitigador;
            porcentajeAceptacion.IndicadorSinCalificacion = RegistroInicialConsultado.IndicadorSinCalificacion;

            Gestor.EliminarPorcentajeAceptacion(porcentajeAceptacion, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

            Response.Redirect("frmMensaje.aspx?" +
                "bError=0" +
                "&strTitulo=" + "Eliminación Exitosa" +
                "&strMensaje=" + "El campo del catálogo se eliminó satisfactoriamente." +
                "&bBotonVisible=1" +
                "&strTextoBoton=Regresar" +
                "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
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
                    "&strHref=frmMantenimientoPorcentajeAceptacion.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
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

        try
        {
            switch (e.CommandName)
            {
                case ("SelectedCatalogo"):
                    rowIndex = (int.Parse(e.CommandArgument.ToString()));

                    gdvCatalogos.SelectedIndex = rowIndex;

                    try
                    {
                        cboTipoGarantia.ClearSelection();
                        cboTipoMitigador.ClearSelection();
                        //rdbNoCalificacion.Checked = false;
                        //rdbSinCalificacion.Checked = false;

                        rdbListaClasificacion.ClearSelection();

                        if (gdvCatalogos.SelectedDataKey[1].ToString() != null)
                            cboTipoGarantia.Items.FindByValue(gdvCatalogos.SelectedDataKey[1].ToString()).Selected = true;
                        else
                            cboTipoGarantia.SelectedIndex = -1;

                  

                        if (gdvCatalogos.SelectedDataKey[2].ToString() != null)
                            cboTipoMitigador.Items.FindByValue(gdvCatalogos.SelectedDataKey[2].ToString()).Selected = true;
                        else
                            cboTipoMitigador.SelectedIndex = -1;


                        if (gdvCatalogos.SelectedDataKey[3].ToString() != null)
                        {
                            if (gdvCatalogos.SelectedDataKey[3].ToString().Equals("Si"))
                            {
                                //rdbSinCalificacion.Checked = true;
                                //rdbNoCalificacion.Checked = false;
                                rdbListaClasificacion.Items[0].Selected = true;
                                rdbListaClasificacion.Items[1].Selected = false;
                            }
                            else
                            {
                                //rdbSinCalificacion.Checked = false;
                                //rdbNoCalificacion.Checked = true;
                                rdbListaClasificacion.Items[0].Selected = false;
                                rdbListaClasificacion.Items[1].Selected = true;
                            }
                        }
                        else
                        {
                            //rdbSinCalificacion.Checked = false;
                            //rdbNoCalificacion.Checked = false;
                            rdbListaClasificacion.ClearSelection();
                        }                            

                        if (gdvCatalogos.SelectedDataKey[4].ToString() != null)
                            txtPorcentajeAceptacion.Text = gdvCatalogos.SelectedDataKey[4].ToString();
                        else
                            txtPorcentajeAceptacion.Text = string.Empty;

                        if (gdvCatalogos.SelectedDataKey[5].ToString() != null)
                            txtPorcentajeCeroTres.Text = gdvCatalogos.SelectedDataKey[5].ToString();
                        else
                            txtPorcentajeCeroTres.Text = string.Empty;

                        if (gdvCatalogos.SelectedDataKey[6].ToString() != null)
                            txtPorcentajeCuatro.Text = gdvCatalogos.SelectedDataKey[6].ToString();
                        else
                            txtPorcentajeCuatro.Text = string.Empty;

                        if (gdvCatalogos.SelectedDataKey[7].ToString() != null)
                            txtPorcentajeCinco.Text = gdvCatalogos.SelectedDataKey[7].ToString();
                        else
                            txtPorcentajeCinco.Text = string.Empty;

                        if (gdvCatalogos.SelectedDataKey[8].ToString() != null)
                            txtPorcentajeSeis.Text = gdvCatalogos.SelectedDataKey[8].ToString();
                        else
                            txtPorcentajeSeis.Text = string.Empty;


                        if (gdvCatalogos.SelectedDataKey[9].ToString() != null)
                        {                     

                            if (! Convert.ToDateTime(gdvCatalogos.SelectedDataKey[9].ToString()).ToShortDateString().Equals("01/01/1900"))
                            {
                                txtFechaCambio.Text = Convert.ToDateTime(gdvCatalogos.SelectedDataKey[9].ToString()).ToShortDateString();
                            }
                            else
                            {
                                txtFechaCambio.Text = System.DateTime.Now.ToShortDateString();
                            }
                        }
                        else
                        {
                            txtFechaCambio.Text = System.DateTime.Now.ToShortDateString();
                        }
                           


                        if (gdvCatalogos.SelectedDataKey[0].ToString() != null)
                            lblElemento.Text = gdvCatalogos.SelectedDataKey[0].ToString();
                        else
                            lblElemento.Text = "";


                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;
                        
                        porcentajeAceptacionConsultado = new clsPorcentajeAceptacion();


                        porcentajeAceptacionConsultado.CodigoPorcentajeAceptacion = ((int.TryParse(lblElemento.Text, out consecutivoRegistro)) ? consecutivoRegistro : -1);
                        porcentajeAceptacionConsultado.CodigoTipoGarantia = int.Parse(cboTipoGarantia.SelectedItem.Value);
                        porcentajeAceptacionConsultado.CodigoTipoMitigador = int.Parse(cboTipoMitigador.SelectedItem.Value);
                        porcentajeAceptacionConsultado.IndicadorSinCalificacion = rdbListaClasificacion.Items[0].Selected;  //rdbSinCalificacion.Checked;
                        porcentajeAceptacionConsultado.PorcentajeAceptacion = decimal.Parse(txtPorcentajeAceptacion.Text);
                        porcentajeAceptacionConsultado.PorcentajeCeroTres = (txtPorcentajeCeroTres.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCeroTres.Text);
                        porcentajeAceptacionConsultado.PorcentajeCuatro = (txtPorcentajeCuatro.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCuatro.Text);
                        porcentajeAceptacionConsultado.PorcentajeCinco = (txtPorcentajeCinco.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeCinco.Text);
                        porcentajeAceptacionConsultado.PorcentajeSeis = (txtPorcentajeSeis.Text.Length == 0) ? 0 : decimal.Parse(txtPorcentajeSeis.Text);

                        RegistroInicialConsultado = porcentajeAceptacionConsultado;
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

        CargarGrid(null);
    }

    private void CargarGrid(int? codigoPorcentajeAceptacion)
    {
        try
        {
            DataSet oDatosPorcentaje = Gestor.ObtenerDatosPorcentajeAceptacion(codigoPorcentajeAceptacion,null,null,1);

            if ((oDatosPorcentaje != null) && (oDatosPorcentaje.Tables.Count > 0))
            {
                gdvCatalogos.DataSource = oDatosPorcentaje;
                gdvCatalogos.DataBind();
            }
            else
            {
                lblMensaje.Text = "No existen registros.";
            }

        }//fin del try
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(ex.Message, EventLogEntryType.Error);
            lblMensaje.Text = ex.Message;
        }//fin del cath   

    }
    #endregion


    #region Metodos Privados

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

            if (bRespuesta && cboTipoGarantia.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el Tipo de Garantía.";
                bRespuesta = false;
            }

            if (bRespuesta && cboTipoMitigador.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el Tipo de Mitigador.";
                bRespuesta = false;
            }

            if (bRespuesta && (!rdbListaClasificacion.Items[0].Selected) && (!rdbListaClasificacion.Items[1].Selected))
            {
                lblMensaje.Text = "Debe seleccionar la opción de Sin Calificación o N/A Calificación.";
                bRespuesta = false;
            }

            if (bRespuesta && txtPorcentajeAceptacion.Text.Equals(string.Empty))
            {
                lblMensaje.Text = "Debe ingresar el porcentaje.";
                bRespuesta = false;
            }

            if (bRespuesta && (decimal.Parse(txtPorcentajeAceptacion.Text) >= 100))
            {
                lblMensaje.Text = "El Porcentaje debe ser menor a 100.";
                bRespuesta = false;
            }


            if (bRespuesta && (decimal.Parse(txtPorcentajeAceptacion.Text) < 0))
            {
                lblMensaje.Text = "El Porcentaje no puede ser negativo.";
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
        CargarTiposGarantia();       
        CargarTiposMitigador();
    }


    
    /// <summary>
    /// Carga la lista de tipos garantia
    /// </summary>
    private void CargarTiposGarantia()
    {
        try
        {
            string catalogoTipoGarantia = "|" + Application["CAT_TIPO_GARANTIA"].ToString() + "|";
            List<clsCatalogo> catalogoTiposGarantia = Gestor.ObtenerCatalogos(catalogoTipoGarantia).Items((int.Parse(Application["CAT_TIPO_GARANTIA"].ToString())));

            cboTipoGarantia.DataSource = null;
            cboTipoGarantia.DataSource = catalogoTiposGarantia;
            cboTipoGarantia.DataValueField = "CodigoElemento";
            cboTipoGarantia.DataTextField = "DescripcionCodigoElemento";
            cboTipoGarantia.DataBind();
            cboTipoGarantia.ClearSelection();

        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

      /// <summary>
    /// Carga la lista de tipos mitigador
    /// </summary>
    private void CargarTiposMitigador()
    {
        try
        {
            string catalogoTipoMitigador = "|" + Application["CAT_TIPO_MITIGADOR"].ToString() + "|";
            List<clsCatalogo> catalogoTiposMitigador = Gestor.ObtenerCatalogos(catalogoTipoMitigador).Items((int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString())));

            cboTipoMitigador.DataSource = null;
            cboTipoMitigador.DataSource = catalogoTiposMitigador;
            cboTipoMitigador.DataValueField = "CodigoElemento";
            cboTipoMitigador.DataTextField = "DescripcionCodigoElemento";
            cboTipoMitigador.DataBind();
            cboTipoMitigador.ClearSelection();

        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }




    #endregion
    
}

}