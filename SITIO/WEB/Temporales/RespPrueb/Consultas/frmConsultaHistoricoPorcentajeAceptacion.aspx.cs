using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;
using System.Security.AccessControl;
using System.Security.Principal;

using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


public partial class Consultas_frmConsultaHistoricoPorcentajeAceptacion : BCR.Web.SystemFramework.PaginaPersistente 
{
    #region Variables Globales

    protected DataSet oDatosPorcentajeAceptacion;

    #endregion

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);    

       btnConsultar.Click += new EventHandler(btnConsultar_Click);
       btnLimpiar.Click += new EventHandler(btnLimpiar_Click);     
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        txtCodigoUsuario.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");

        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_HISTORICO_PORCENTAJE_ACEPTACION"].ToString())))
                {
                    LimpiarCampos();
                    txtCodigoUsuario.Visible = true;
                    txtCodigoUsuario.Focus();
                    ScriptManager1.SetFocus(txtCodigoUsuario);
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
                string rutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                rutaActual = rutaActual.Remove(rutaActual.IndexOf("/Consultas"));

                if (ex.Message.StartsWith("ACCESO DENEGADO"))
                    Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Acceso Denegado" +
                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                        "&bBotonVisible=0");
                else
                    Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Página" +
                        "&strMensaje=" + ex.Message +
                        "&bBotonVisible=0");
            }
        }
    }

    void btnConsultar_Click(object sender, EventArgs e)
    {       
        if(ValidarDatos())
        {
            CargarGrid();
        }
       
    }

    private void btnLimpiar_Click(object sender, System.EventArgs e)
    {
        LimpiarCampos();
        gdvPorcentajeAceptacion.DataSource = null;
        gdvPorcentajeAceptacion.DataBind();
    }

    private void CargarGrid()
    {
        try
        {
            clsHistoricoPorcentajeAceptacion eHistorico = new clsHistoricoPorcentajeAceptacion();
            eHistorico.CodigoUsuario = txtCodigoUsuario.Text;
            eHistorico.CodigoTipoGarantia = int.Parse(cboTipoGarantia.SelectedItem.Value);
            eHistorico.CodigoTipoMitigador = int.Parse(cboTipoMitigador.SelectedItem.Value);
            eHistorico.CodigoCatalogoGarantia = int.Parse(Application["CAT_TIPO_GARANTIA"].ToString());
            eHistorico.CodigoCatalogoMitigador = int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString());

            oDatosPorcentajeAceptacion = Gestor.ObtenerDatosHistoricoPorcentajeAceptacion(eHistorico, DateTime.Parse(txtFechaInicial.Text), DateTime.Parse(txtFechaFinal.Text));

            if ((oDatosPorcentajeAceptacion != null) && (oDatosPorcentajeAceptacion.Tables[0].Rows.Count > 0))
            {
                gdvPorcentajeAceptacion.DataSource = oDatosPorcentajeAceptacion;
                gdvPorcentajeAceptacion.DataBind();

          
            }
            else
            {
                lblMensaje.Text = "No existen cambios de los datos seleccionados";
                gdvPorcentajeAceptacion.DataSource = null;
                gdvPorcentajeAceptacion.DataBind();
            }

        }//fin del try
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(ex.Message, EventLogEntryType.Error);
            lblMensaje.Text = "Ha ocurrido un error en la consulta de los datos seleccionados.";
        }//fin del cath   

    }

    #endregion

    #region Metodos Grid

    protected void gdvPorcentajeAceptacion_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        try
        {
            this.gdvPorcentajeAceptacion.SelectedIndex = -1;
            this.gdvPorcentajeAceptacion.PageIndex = e.NewPageIndex;
           
            CargarGrid();
        }
        catch (Exception ex)
        {
            string v = ex.Message;
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }

    }//fin del metodo gdvCambioGarantia_PageIndexChanging


    #endregion

    #region Métodos Privados

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

    private void LimpiarCampos() 
    {
        txtCodigoUsuario.Text = string.Empty;
        txtFechaFinal.Text = string.Empty;
        txtFechaInicial.Text = string.Empty;
        cboTipoGarantia.SelectedIndex = -1;
        cboTipoMitigador.SelectedIndex = -1;     
        lblMensaje.Text = string.Empty;
    }

    private bool ValidarDatos() 
    {
        lblMensaje.Text = "";


        if (string.IsNullOrEmpty(txtFechaInicial.Text))
        {
            lblMensaje.Text = "Debe seleccionar la Fecha Desde";
            return false;
        }
        if (string.IsNullOrEmpty(txtFechaFinal.Text))
        {
            lblMensaje.Text = "Debe seleccionar la Fecha Hasta";
            return false;
        }

        if (string.IsNullOrEmpty(txtFechaInicial.Text) && string.IsNullOrEmpty(txtFechaFinal.Text))
        {
            lblMensaje.Text = "Debe seleccionar un Rando de Fechas";
            return false;
        }
        else
        {
            DateTime dFI = new DateTime();
            DateTime dFF = new DateTime();

            //if ((!DateTime.TryParse(txtFechaInicial.Text, out dFI)) && (!DateTime.TryParse(txtFechaFinal.Text, out dFF)))
            //{
            //    lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
            //    return false;
            //}

            if (!DateTime.TryParse(txtFechaInicial.Text, out dFI) )
            {
                lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
                return false;
            }

            if ( !DateTime.TryParse(txtFechaFinal.Text, out dFF))
            {
                lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
                return false;
            }

        }

        if (DateTime.Parse(txtFechaInicial.Text) > DateTime.Parse(txtFechaFinal.Text))
        {
            lblMensaje.Text = "La Fecha Desde debe ser menor a la Fecha Hasta";
            return false;
        }

        return true;
    }

    #endregion

}