using System;
using System.Diagnostics;
using System.Web;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.Text;
using System.IO;
using System.Web.UI;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections.Specialized;

using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;
using BCRGARANTIAS.Negocios;


public partial class frmMantenimientoSaldosTotalesPorcentajeResponsabilidad : BCR.Web.SystemFramework.PaginaPersistente
{
    #region Variables Globales

    private bool seRedirecciona = false;
    private string urlPaginaMensaje = string.Empty;

    //private string strOperacionCrediticia = "-";
    //private string strGarantia = "-";
    //private string _contratoDelGiro = string.Empty;

    //private DataSet dsGarantiasReales = new DataSet("Garantías Reales");

    //private clsGarantiaReal entidadGarantia;

    //private decimal porcentajeAceptacionCalculado = 0;

    //private bool mostrarErrorRelacionPolizaGarantia = false;



    #endregion

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        txtSaldoAjustado.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtSaldoAjustado.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false);");
        txtSaldoAjustado.Attributes.Add("onchange", "javascript:FormatNumber(this,this.value,2,true,true,false)");
        txtPorcentajeResponsabilidad.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtPorcentajeResponsabilidad.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true); ValidarPorcentajeResponsabilidad();");
        txtPorcentajeResponsabilidad.Attributes.Add("onchange", "javascript:FormatNumber(this,this.value,2,true,true,true)");

        //txtCedulaFiador.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        //txtPartido.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");

        if (!IsPostBack)
        {
            try
            {
                hdnCatalogoGarantias.Value = Application["CAT_TIPO_GARANTIA"].ToString();
                hdnCatalogoTiposPersona.Value = Application["CAT_TIPO_PERSONA"].ToString();
                hdnCatalogoTiposGarantiaReal.Value = Application["CAT_TIPO_GARANTIA_REAL"].ToString();
                hdnCatalogoClasesGarantia.Value = Application["CAT_CLASE_GARANTIA"].ToString();
                hdnPerfilesPermitidos.Value = Application["PERFILES_PERMISO_EDICION_STPR"].ToString();
            }
            catch (ConfigurationErrorsException ex) {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "del mantenimiento de saldos totales y porcentaje de responsabilidad", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA, Mensajes.ASSEMBLY) +
                                    "&bBotonVisible=0");
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "del mantenimiento de saldos totales y porcentaje de responsabilidad", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA, Mensajes.ASSEMBLY) +
                                    "&bBotonVisible=0");
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        base.OnLoadComplete(e);

        if (!IsPostBack)
        {
            int tipoGarantia = int.Parse(((Request.QueryString != null) && (Request.QueryString["tipogarantia"] != null) && (Request.QueryString["tipogarantia"].ToString().Length > 0)) ? Request.QueryString["tipogarantia"].ToString() : "-1");
            if (tipoGarantia > 0)
            {
                string cadenaJson = CargarQueryString(Request.QueryString, tipoGarantia);
                Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                            Guid.NewGuid().ToString(),
                                                            "<script type=\"text/javascript\" language=\"javascript\">$(document).ready(function () { CargarPaginaSTPR(" + cadenaJson + ");});</script>",
                                                            false);
            }
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            int tipoGarantia = int.Parse(((Request.QueryString != null) && (Request.QueryString["tipogarantia"] != null) && (Request.QueryString["tipogarantia"].ToString().Length > 0)) ? Request.QueryString["tipogarantia"].ToString() : "-1");
            CargarGridVacio();
            gdvOperaciones.Style.Add("display", "none");

            switch (tipoGarantia)
            {
                case 1:
                    lknRetornar.HRef = "frmGarantiasFiduciaria.aspx";
                    break;
                case 2:
                    lknRetornar.HRef = "frmGarantiasReales.aspx";
                    break;
                case 3:
                    lknRetornar.HRef = "frmGarantiasValor.aspx";
                    break;
                default:
                    break;
            }
        }

        try
        {
            if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_SALDOS_TOTALES_PORCENTAJE_RESPONSABILIDAD"].ToString())))
            {
                //El usuario no tiene acceso a esta página
                throw new Exception("ACCESO DENEGADO");
            }
        }
        catch (ConfigurationErrorsException ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "del mantenimiento de saldos totales y porcentaje de responsabilidad", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        }
        catch (Exception ex)
        {
            if (ex.Message.StartsWith("ACCESO DENEGADO"))
            {
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Acceso Denegado" +
                                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_ACCESO_DENEGADO, Mensajes.ASSEMBLY) +
                                    "&bBotonVisible=0");
            }
            else
            {
                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "del mantenimiento de saldos totales y porcentaje de responsabilidad", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA, Mensajes.ASSEMBLY) +
                                    "&bBotonVisible=0");
            }
        }

        if (seRedirecciona)
        {
            Response.Redirect(urlPaginaMensaje, true);
        }
    }

    #endregion Eventos

    #region Métodos

    private void CargarGridVacio()
    {
        DataTable garantia = new DataTable();
        garantia.Columns.Add("OperacionLarga");
        garantia.Columns.Add("SaldoActual");
        garantia.Columns.Add("PorcentajeResponsabilidadCalculado");
        garantia.Columns.Add("CuentaContable");
        garantia.Columns.Add("TipoOperacion");
        garantia.Columns.Add("CodigoTipoOperacion");
        garantia.Columns.Add("ConsecutivoOperacion");
        garantia.Columns.Add("ConsecutivoGarantia");
        garantia.Columns.Add("CodigoTipoGarantia");
        garantia.Columns.Add("IndicadorExcluido");
        garantia.Rows.Add();
        gdvOperaciones.DataSource = garantia;
        gdvOperaciones.DataBind();
    }

    private string CargarQueryString(NameValueCollection queryString, int tipoGarantia)
    {
        StringBuilder formatoJSON = new StringBuilder("{");

        if ((queryString != null) && (queryString.Count > 0))
        {
            foreach (string llave in queryString.Keys)
            {
                //tipogarantia=1&tipofiador=" + encodeURIComponent(tipoPersona) + "&idfiador=" + encodeURIComponent(cedulaFiador);
                if (llave.CompareTo("tipogarantia") == 0)
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("tipogarantia");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 1) && (llave.CompareTo("tipofiador") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("tipofiador");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 1) && (llave.CompareTo("idfiador") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("idfiador");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append('"');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append('"');
                    formatoJSON.Append(",");

                }
                //tipogarantia=2&tipogarantiareal=" + encodeURIComponent(tipoGarantiaReal) + "&clase=" + encodeURIComponent(claseGarantia) + "&partido=" + encodeURIComponent(partido) + "&idgarantia=" + encodeURIComponent(numeroFinca) + "&grado=" + encodeURIComponent(grado);
                else if ((tipoGarantia == 2) && (llave.CompareTo("tipogarantiareal") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("tipogarantiareal");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 2) && (llave.CompareTo("clase") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("clase");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 2) && (llave.CompareTo("partido") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("partido");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 2) && (llave.CompareTo("idgarantia") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("idgarantia");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append('"');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append('"');
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 2) && (llave.CompareTo("grado") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("grado");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                //tipogarantia=3&claser=" + encodeURIComponent(claseGarantia) + "&numseguridad=" + encodeURIComponent(numeroSeguridad);
                else if ((tipoGarantia == 3) && (llave.CompareTo("clase") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("clase");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append(",");
                }
                else if ((tipoGarantia == 3) && (llave.CompareTo("numseguridad") == 0))
                {
                    formatoJSON.Append('"');
                    formatoJSON.Append("numseguridad");
                    formatoJSON.Append('"');
                    formatoJSON.Append(':');
                    formatoJSON.Append('"');
                    formatoJSON.Append(Server.HtmlDecode(queryString[llave]));
                    formatoJSON.Append('"');
                    formatoJSON.Append(",");
                }

            }
        }

        formatoJSON.Append('}');
        string datoRetornado = string.Format("'[{0}]'", formatoJSON.ToString().Replace(",}", "}"));
        return datoRetornado;
    }

    #endregion Métodos

    #region Métodos AJAX

    /// <summary>
    /// Se encarga de determinar si el usuario logueado tiene el perfil que permita habiliar los campos de la sección de ajustes.
    /// </summary>
    /// <returns>Devolverá un valor 1 si el usuario tiene permiso de edición y un 0 en caso contrario</returns>
    [System.Web.Services.WebMethod]
    public static string ValidarPermisoEdicionUsuario(string perfilesPermitodos)
    {
        string usuarioTienePermiso = "0";
        string[] datosRetornados = { string.Empty, string.Empty };
        string mensajeError = string.Empty;
        

        try
        {
            datosRetornados = Gestor.ObtenerPerfilUsuario(Global.UsuarioSistema);

            if ((datosRetornados != null) && (datosRetornados.Length > 0))
            {
                if (perfilesPermitodos.Length > 0)
                {
                    usuarioTienePermiso = (((perfilesPermitodos.Contains(datosRetornados[0])) || (perfilesPermitodos.Contains(datosRetornados[1]))) ? "1" : "0");
                }
            }
        }
        catch (Exception ex)
        {
            string error = string.Format("Se ha presnetado un problema al validar el perfil del usuario. frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx (Método: ValidarPermisoEdicionUsuario). Detalle:{0}", ex.Message);
            Utilitarios.RegistraEventLog(error, EventLogEntryType.Error);
         }

        return usuarioTienePermiso;
    }
    
    /// <summary>
    /// Se encarga de extraer la lista de datos del catálogo indicado.
    /// </summary>
    /// <param name="codigoCatologo">Código del catálogo</param>
    /// <returns>Lista, en formato JSON con la información del catálogo</returns>
    [System.Web.Services.WebMethod]
    public static string ExtraerCatalogo(string codigoCatologo)
    {
        string datosRetornados = string.Empty;
        string mensajeError = string.Empty;
        string listaCatalogo = string.Format("|{0}|", codigoCatologo);
        clsCatalogos<clsCatalogo> listaElementos = new clsCatalogos<clsCatalogo>();


        try
        {
            listaElementos = Gestor.ObtenerCatalogos(listaCatalogo);

            if ((listaElementos != null) && (listaElementos.Count > 0))
            {
                datosRetornados = listaElementos.ObtenerJSON();
            }
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA_DETALLE, "frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx (Método: ExtraerCatalogo, Catálogo:" + codigoCatologo + ")", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            datosRetornados = ("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas obteniendo datos del catálogo" +
                                "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_PAGINA, Mensajes.ASSEMBLY) +
                                "&bBotonVisible=0");
        }

        return datosRetornados;
    }
    
    /// <summary>
    /// Se encarga de realizar la validación de la operación, contrato o giro.
    /// </summary>
    /// <param name="codigoContabilidad">Código de la contabilidad</param>
    /// <param name="codigoOficina">Código de la oficina</param>
    /// <param name="codigoMoneda">Código de la moneda</param>
    /// <param name="codigoProducto">Código del producto</param>
    /// <param name="numeroOperacion">Número de la operación, contrato o giro de contrato</param>
    /// <returns>La identificación y nombre del deudor</returns>
    [System.Web.Services.WebMethod]
    public static string ValidarOperacion(string codigoContabilidad, string codigoOficina, string codigoMoneda, string codigoProducto, string numeroOperacion)
    {
        string datosRetornados = string.Format("0|{0}", string.Empty);
        string mensajeError = string.Empty;
        string datosDeudor = string.Empty;

        clsOperacionCrediticia operacionValidada;
        string numeroCompletoOperacion = string.Empty;

        numeroCompletoOperacion = ((codigoProducto.CompareTo("-1") != 0) ? (codigoContabilidad.ToString() + "-" + codigoOficina.ToString() + "-" + codigoMoneda.ToString() + "-" + codigoProducto.ToString() + "-" + numeroOperacion.ToString()) : (codigoContabilidad.ToString() + "-" + codigoOficina.ToString() + "-" + codigoMoneda.ToString() + "-" + numeroOperacion.ToString()));

        try
        {
            short codContabilidad = ((short.TryParse(codigoContabilidad, out codContabilidad)) ? codContabilidad : ((short)-1));
            short codOficina = ((short.TryParse(codigoOficina, out codOficina)) ? codOficina : ((short)-1));
            short codMoneda = ((short.TryParse(codigoMoneda, out codMoneda)) ? codMoneda : ((short)-1));
            short codProducto = ((short.TryParse(codigoProducto, out codProducto)) ? codProducto : ((short)-1));
            long numOperacion = ((long.TryParse(numeroOperacion, out numOperacion)) ? numOperacion : -1);

            operacionValidada = Gestor.ValidarOperacion(codContabilidad, codOficina, codMoneda, codProducto, numOperacion);

            operacionValidada.TipoOperacion = ((short) ((codProducto != -1) ? 1 : 2));

            datosRetornados = string.Format("0|{0}", operacionValidada.ConsecutivoOperacion.ToString());
 

            //if (operacionValidada.EsGiro)
            //{
            //    datosRetornados = string.Format("1|{0}", Mensajes.Obtener(Mensajes._errorConsultaGiro, operacionValidada.FormatoLargoContrato, Mensajes.ASSEMBLY));
            // }

            if (!operacionValidada.EsValida)
            {
                datosRetornados = string.Format("1|{0}", ((operacionValidada.TipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Directa)) ? "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique." : ((operacionValidada.TipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Contrato)) ? "El contrato no existe en el sistema o se encuentra cancelado. Por favor verifique." : string.Empty)));
            }
        }
        catch (SqlException ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION_DETALLE, (" '" + numeroCompletoOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            datosRetornados = string.Format("1|{0}", Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION, (" '" + numeroCompletoOperacion + "'"), Mensajes.ASSEMBLY));
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION_DETALLE, (" '" + numeroCompletoOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            datosRetornados = string.Format("1|{0}", Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION, (" '" + numeroCompletoOperacion + "'"), Mensajes.ASSEMBLY));
        }

        return datosRetornados;
    }
    
    /// <summary>
    /// Se encarga de realizar la obtención de las garantías reales asociadas a la operación, contrato o giro consultada.
    /// </summary>
    /// <param name="codigoContabilidad">Código de la contabilidad</param>
    /// <param name="codigoOficina">Código de la oficina</param>
    /// <param name="codigoMoneda">Código de la moneda</param>
    /// <param name="codigoProducto">Código del producto</param>
    /// <param name="numeroOperacion">Número de la operación, contrato o giro de contrato</param>
    /// <returns>La identificación y nombre del deudor</returns>
    [System.Web.Services.WebMethod]
    public static string ObtenerGarantias(string tipoOperacion, string consecutivoOperacion, string codigoContabilidad, string codigoOficina, string codigoMoneda, string codigoProducto, string numeroOperacion, string tipoGarantia)
    {
        HtmlGenericControl contendorTabla = new HtmlGenericControl("div"); 
        HtmlTable datosRetornados = new HtmlTable();
        
        string mensajeError = string.Empty;
        string datosDeudor = string.Empty;

        string numeroCompletoOperacion = string.Empty;

       
        numeroCompletoOperacion = ((codigoProducto.CompareTo("-1") != 0) ? (codigoContabilidad.ToString() + "-" + codigoOficina.ToString() + "-" + codigoMoneda.ToString() + "-" + codigoProducto.ToString() + "-" + numeroOperacion.ToString()) : (codigoContabilidad.ToString() + "-" + codigoOficina.ToString() + "-" + codigoMoneda.ToString() + "-" + numeroOperacion.ToString()));

        try
        {
            short codTipoOperacion = ((short.TryParse(tipoOperacion, out codTipoOperacion)) ? codTipoOperacion : ((short)-1));
            short codContabilidad = ((short.TryParse(codigoContabilidad, out codContabilidad)) ? codContabilidad : ((short)-1));
            short codOficina = ((short.TryParse(codigoOficina, out codOficina)) ? codOficina : ((short)-1));
            short codMoneda = ((short.TryParse(codigoMoneda, out codMoneda)) ? codMoneda : ((short)-1));
            short codProducto = ((short.TryParse(codigoProducto, out codProducto)) ? codProducto : ((short)-1));
            long numOperacion = ((long.TryParse(numeroOperacion, out numOperacion)) ? numOperacion : -1);
            long conOperacion = ((long.TryParse(consecutivoOperacion, out conOperacion)) ? conOperacion : -1);
            int codTipoGarantia = ((int.TryParse(tipoGarantia, out codTipoGarantia)) ? codTipoGarantia : -1);


            datosRetornados = Gestor.ObtenerListaGarantiasPorOperacion(codTipoOperacion, conOperacion, codContabilidad, codOficina, codMoneda, codProducto, numOperacion, Global.UsuarioSistema, codTipoGarantia);

            contendorTabla.Controls.Add(datosRetornados);
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION_DETALLE, (" '" + numeroCompletoOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        }

        StringBuilder sb = new StringBuilder();
        StringWriter tw = new StringWriter(sb);
        HtmlTextWriter hw = new HtmlTextWriter(tw);

        datosRetornados.RenderControl(hw);
        String HTMLContent = HttpUtility.HtmlEncode(sb.ToString().Trim());

        return (((HTMLContent != null) && (HTMLContent.Length > 0)) ? HTMLContent.Replace("\r", string.Empty).Replace("\n", string.Empty).Replace("\t", string.Empty) : string.Empty);
    }

    /// <summary>
    /// Se encarga de realizar la obtención de las operaciones respaldadas por la garantía fiduciaria suministrada.
    /// </summary>
    /// <param name="tipoPersona">Código del tipo de persona del fiador</param>
    /// <param name="identificacionFiador">Identificación del fiador</param>
    /// <returns>La lista con las operaciones que respalda la garantía</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] ObtenerOperacionesGarantiaFiduciaria(string tipoPersona, string identificacionFiador)
    {
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> datosRetornados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsGarantiaFiduciaria garantiaFiduciariaConsultada = new clsGarantiaFiduciaria();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();

        int tipoPerson;

        string mensajeError = string.Empty;
        string datosDeudor = string.Empty;

        string identificacionGarantia = string.Empty;
        decimal idFiador;


        try
        {
            garantiaFiduciariaConsultada.CedulaFiador = identificacionFiador;
            garantiaFiduciariaConsultada.IndentificacionSicc = ((decimal.TryParse(identificacionFiador, out idFiador)) ? idFiador : -1);
            garantiaFiduciariaConsultada.CodigoTipoPersonaFiador = ((int.TryParse(tipoPersona, out tipoPerson)) ? tipoPerson : -1);

            identificacionGarantia = string.Format("[F] {0}-{1}", tipoPersona, identificacionFiador).Replace("-1-", string.Empty).Replace("-", string.Empty);
            
            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ListaGarantia = Gestor.ObtenerOperacionesPorGarantiaFiduciaria(garantiaFiduciariaConsultada, Global.UsuarioSistema);

            if ((ListaGarantia != null) && (ListaGarantia.Count > 0))
            {
                foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in ListaGarantia)
                {
                    garantia.CodigoError = 0;
                    listaDatosRetornados.Add(garantia);
                }
            }
            else
            {
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 2;
                datosRetornado.DescripcionError = "La garantía consultada no existe en el sistema";
                listaDatosRetornados.Add(datosRetornado);
            }
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantiasDetalle, identificacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantia, Mensajes.ASSEMBLY);
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }
    
    /// <summary>
    /// Se encarga de realizar la obtención de las operaciones respaldadas por la garantía real suministrada.
    /// </summary>
    /// <param name="identificacionBien">Identificación del bien</param>
    /// <param name="claseGarantia">Código de la clase de garantía</param>
    /// <param name="codigoPartido">Código del partido</param>
    /// <param name="codigoGrado">Código del grado</param>
    /// <returns>La lista con las operaciones que respalda la garantía</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] ObtenerOperacionesGarantiaReal(string identificacionBien, string claseGarantia, string codigoPartido, string codigoGrado)
    {
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> datosRetornados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsGarantiaReal garantiaRealConsultada = new clsGarantiaReal();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();

        short codClaseGarantia;
        short codPartido;

        string mensajeError = string.Empty;
        string datosDeudor = string.Empty;

        string identificacionGarantiaReal = string.Empty;

        
        try
        {
            garantiaRealConsultada.IdentificacionAlfanumericaGarantia = identificacionBien;
            garantiaRealConsultada.CodClaseGarantia = ((short.TryParse(claseGarantia, out codClaseGarantia)) ? codClaseGarantia : ((short)-1));
            garantiaRealConsultada.CodPartido = (((codigoPartido.Length > 0) && (short.TryParse(codigoPartido, out codPartido))) ? codPartido : ((short)-1));
            garantiaRealConsultada.CodGrado = (((codigoGrado.Length > 0) && (codigoGrado.CompareTo("-1") != 0)) ? codigoGrado : string.Empty);


            if ((codClaseGarantia >= 10) && (codClaseGarantia <= 17))
            {
                identificacionGarantiaReal = string.Format("[HC] {0}-{1}", codigoPartido, identificacionBien);
                garantiaRealConsultada.CodTipoGarantiaReal = ((short)Enumeradores.Tipos_Garantia_Real.Hipoteca);
            }
            else if ((codClaseGarantia == 18) || ((codClaseGarantia >= 20) && (codClaseGarantia <= 29)))
            {
                identificacionGarantiaReal = string.Format("[CH] {0}-{1}", codigoPartido, identificacionBien);
                garantiaRealConsultada.CodTipoGarantiaReal = ((short)Enumeradores.Tipos_Garantia_Real.Cedula_Hipotecaria);
            }
            else if ((codClaseGarantia >= 30) && (codClaseGarantia <= 39))
            {
                identificacionGarantiaReal = string.Format("[P] {0}", identificacionBien);
                garantiaRealConsultada.CodTipoGarantiaReal = ((short)Enumeradores.Tipos_Garantia_Real.Prenda);
            }


            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ListaGarantia = Gestor.ObtenerOperacionesPorGarantiaReal(garantiaRealConsultada, Global.UsuarioSistema);

            if ((ListaGarantia != null) && (ListaGarantia.Count > 0))
            {                
                foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in ListaGarantia)
                {
                    garantia.CodigoError = 0;
                    listaDatosRetornados.Add(garantia);
                }
            }
            else
            {
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 2;
                datosRetornado.DescripcionError = "La garantía consultada no existe en el sistema";
                listaDatosRetornados.Add(datosRetornado);
            }
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantiasDetalle, identificacionGarantiaReal, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantiaReal, Mensajes.ASSEMBLY);
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }

    /// <summary>
    /// Se encarga de realizar la obtención de las operaciones respaldadas por la garantía valor suministrada.
    /// </summary>
    /// <param name="numeroSeguridad">Identificación de la seguridad</param>
    /// <param name="claseGarantia">Código de la clase de garantía</param>
    /// <returns>La lista con las operaciones que respalda la garantía</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] ObtenerOperacionesGarantiaValor(string numeroSeguridad, string claseGarantia)
    {
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> datosRetornados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsGarantiaValor garantiaValorConsultada = new clsGarantiaValor();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();

        short codClaseGarantia;
 
        string mensajeError = string.Empty;
        string datosDeudor = string.Empty;

        string identificacionGarantia = string.Empty;


        try
        {
            garantiaValorConsultada.NumeroSeguridad = numeroSeguridad;
            garantiaValorConsultada.CodigoClaseGarantia = ((short.TryParse(claseGarantia, out codClaseGarantia)) ? codClaseGarantia : ((short)-1));

            identificacionGarantia = string.Format("[V] {0}-{1}", claseGarantia, numeroSeguridad);           

            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> ListaGarantia = Gestor.ObtenerOperacionesPorGarantiaValor(garantiaValorConsultada, Global.UsuarioSistema);

            if ((ListaGarantia != null) && (ListaGarantia.Count > 0))
            {
               foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in ListaGarantia)
                {
                    garantia.CodigoError = 0;
                    listaDatosRetornados.Add(garantia);
                }
            }
            else
            {
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 2;
                datosRetornado.DescripcionError = "La garantía consultada no existe en el sistema";
                listaDatosRetornados.Add(datosRetornado);
            }
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantiasDetalle, identificacionGarantia, ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantia, Mensajes.ASSEMBLY);
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }

    /// <summary>
    /// Se encarga de realizar la inserción de un registro que haya sido excluido previamente.
    /// </summary>
    /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
    /// <param name="consecutivoGarantia">Consecutivo de la garantía</param>
    /// <param name="tipoGarantia">Código del tip ode garantía</param>
    /// <param name="saldoActualAjustado">Saldo actual ajustado</param>
    /// <param name="porcentajeRespAjustado">Porcentaje de responsabilidad ajustado</param>
    /// <param name="arregloElementos">Arreglo de elementos manipulados desde el cliente</param>
    /// <returns>La lista con las operaciones que respalda la garantía con el porcentaje de responsabilidad calculado</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] InsertarRegistro(string consecutivoOperacion, string consecutivoGarantia, string tipoGarantia, string saldoActualAjustado,
                                            string porcentajeRespAjustado, string arregloElementos, string cambioManual)
    {
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosInsertar = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosInsertarAnterior = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosBusqueda = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatosActualizados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

        bool resultadoCalculo = false;
        bool ajusteManual = (((cambioManual.Length > 0) && (cambioManual.CompareTo("1") == 0)) ? true : false);

        string identificacionGarantia = string.Empty;
        decimal saldoIngresado;
        decimal porcentajeIngresado;
        decimal porcentajePorDistribuir = 0;
        decimal limiteInferior;
        decimal limiteSuperior;
        long consecutivoOper;
        long consecutivoGar;
        short tipoGar;

        try
        {

            saldoIngresado = ((decimal.TryParse(saldoActualAjustado, out saldoIngresado)) ? saldoIngresado : -1);
            porcentajeIngresado = ((decimal.TryParse(porcentajeRespAjustado, out porcentajeIngresado)) ? porcentajeIngresado : -1);
            limiteInferior = ((decimal)(((decimal.TryParse("0.00010", out limiteInferior)) ? limiteInferior : 0) * 100));
            limiteSuperior = ((decimal)(((decimal.TryParse("0.01000", out limiteSuperior)) ? limiteSuperior : 0) * 100));

            consecutivoOper = ((long.TryParse(consecutivoOperacion, out consecutivoOper)) ? consecutivoOper : -1);
            consecutivoGar = ((long.TryParse(consecutivoGarantia, out consecutivoGar)) ? consecutivoGar : -1);
            tipoGar = ((short.TryParse(tipoGarantia, out tipoGar)) ? tipoGar : ((short)-1));

            porcentajePorDistribuir = ((100 - porcentajeIngresado) / 100);
                        
            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatos = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(arregloElementos);
            
            if ((listaDatos != null) && (listaDatos.Count > 0))
            {
                datosRetornado.CodigoError = 0;

                foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                {
                    if ((consecutivoOper == garantia.ConsecutivoOperacion) && (consecutivoGar == garantia.ConsecutivoGarantia) && (tipoGar == garantia.CodigoTipoGarantia))
                    {
                        datosInsertarAnterior = garantia;

                        garantia.IndicadorAjusteCampoSaldo = (((saldoIngresado >= 0) && (saldoIngresado != garantia.SaldoActual)) ? true : false);
                        garantia.IndicadorAjusteCampoPorcentaje = (((porcentajeIngresado >= 0) && (porcentajeIngresado != garantia.PorcentajeResponsabilidadAjustado)) ? true : false);
                        garantia.SaldoActualAjustado = ((saldoIngresado >= 0) ? saldoIngresado : garantia.SaldoActual);
                        garantia.PorcentajeResponsabilidadAjustado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadAjustado);
                        garantia.PorcentajeResponsabilidadCalculado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadCalculado);
                        garantia.IndicadorExcluido = false;

                        datosInsertar = garantia;
                        datosBusqueda = garantia;
                    }
                }

                if (((porcentajePorDistribuir > limiteInferior) && (porcentajePorDistribuir < limiteSuperior)) || (datosInsertar.IndicadorAjusteCampoSaldo))
                {
                    if (!ajusteManual)
                    {
                        resultadoCalculo = listaDatos.AplicarCalculoDistribucion();
                    }
                    else
                    {
                        resultadoCalculo = true;
                    }

                    foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                    {
                        datosInsertarAnterior = garantia;
                        datosInsertar = garantia;

                        if ((garantia.ConsecutivoOperacion > 0) && (garantia.ConsecutivoGarantia > 0) && (garantia.CodigoTipoGarantia > 0) && (!garantia.IndicadorExcluido))
                        {
                            Gestor.InsertarSaldoTotalPr(datosInsertar, datosInsertarAnterior, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                        }
                    }
                }
                else
                {
                    resultadoCalculo = true;

                    if ((consecutivoOper > 0) && (consecutivoGar > 0) && (tipoGar > 0))
                    {
                        Gestor.InsertarSaldoTotalPr(datosInsertar, datosInsertarAnterior, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                    }
                }
            }
            else
            {
                datosRetornado.CodigoError = 0;
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }

            if (resultadoCalculo)
            {
                if ((datosBusqueda.ConsecutivoOperacion > 0) && (datosBusqueda.ConsecutivoGarantia > 0) && (datosBusqueda.CodigoTipoGarantia > 0))
                {
                    switch (datosBusqueda.CodigoTipoGarantia)
                    {
                        case 1:
                            clsGarantiaFiduciaria datoBusquedaGF = new clsGarantiaFiduciaria();
                            datoBusquedaGF.ConsecutivoGarantiaFiduciaria = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaFiduciaria(datoBusquedaGF, Global.UsuarioSistema);
                            break;
                        case 2:
                            clsGarantiaReal datoBusquedaGR = new clsGarantiaReal();
                            datoBusquedaGR.CodGarantiaReal = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaReal(datoBusquedaGR, Global.UsuarioSistema);
                            break;
                        case 3:
                            clsGarantiaValor datoBusquedaGV = new clsGarantiaValor();
                            datoBusquedaGV.ConsecutivoGarantia = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaValor(datoBusquedaGV, Global.UsuarioSistema);
                            break;
                        default:
                            datosRetornado.CodigoError = 0;
                            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                            listaDatosRetornados.Clear();
                            listaDatosRetornados.Add(datosRetornado);
                            break;
                    }

                    if ((listaDatosActualizados != null) && (listaDatosActualizados.Count > 0))
                    {
                        listaDatosRetornados.Clear();

                        foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatosActualizados)
                        {
                            garantia.CodigoError = 0;
                            listaDatosRetornados.Add(garantia);
                        }
                    }
                }
            }
            else
            {
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 1;
                datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantia, Mensajes.ASSEMBLY);
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }            
        }
        catch (ExcepcionBase ex)
        {
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = ex.Message;
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }
        catch (Exception ex)
        {            
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPr, Mensajes.ASSEMBLY);
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }
    
    /// <summary>
    /// Se encarga de realizar la modificación del registro consultado.
    /// </summary>
    /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
    /// <param name="consecutivoGarantia">Consecutivo de la garantía</param>
    /// <param name="tipoGarantia">Código del tip ode garantía</param>
    /// <param name="saldoActualAjustado">Saldo actual ajustado</param>
    /// <param name="porcentajeRespAjustado">Porcentaje de responsabilidad ajustado</param>
    /// <param name="arregloElementos">Arreglo de elementos manipulados desde el cliente</param>
    /// <returns>La lista con las operaciones que respalda la garantía con el porcentaje de responsabilidad calculado</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] ModificarRegistro(string consecutivoOperacion, string consecutivoGarantia, string tipoGarantia, string saldoActualAjustado,
                                            string porcentajeRespAjustado, string arregloElementos, string cambioManual)
    {
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosModificar = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosModificarAnterior = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosBusqueda = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatosActualizados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

        bool resultadoCalculo = false;
        bool ajusteManual = (((cambioManual.Length > 0) && (cambioManual.CompareTo("1") == 0)) ? true : false);


        string identificacionGarantia = string.Empty;
        decimal saldoIngresado;
        decimal porcentajeIngresado;
        decimal porcentajePorDistribuir = 0;
        decimal limiteInferior;
        decimal limiteSuperior;
        long consecutivoOper;
        long consecutivoGar;
        short tipoGar;

        try
        {

            saldoIngresado = ((decimal.TryParse(saldoActualAjustado, out saldoIngresado)) ? saldoIngresado : -1);
            porcentajeIngresado = ((decimal.TryParse(porcentajeRespAjustado, out porcentajeIngresado)) ? porcentajeIngresado : -1);
            limiteInferior = ((decimal)(((decimal.TryParse("0.00010", out limiteInferior)) ? limiteInferior : 0) * 100));
            limiteSuperior = ((decimal)(((decimal.TryParse("0.01000", out limiteSuperior)) ? limiteSuperior : 0) * 100));

            consecutivoOper = ((long.TryParse(consecutivoOperacion, out consecutivoOper)) ? consecutivoOper : -1);
            consecutivoGar = ((long.TryParse(consecutivoGarantia, out consecutivoGar)) ? consecutivoGar : -1);
            tipoGar = ((short.TryParse(tipoGarantia, out tipoGar)) ? tipoGar : ((short)-1));

            porcentajePorDistribuir = ((100 - porcentajeIngresado) / 100);

            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatos = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(arregloElementos);
           
            if ((listaDatos != null) && (listaDatos.Count > 0))
            {
                foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                {
                    garantia.CodigoError = 0;
                    listaDatosRetornados.Add(garantia);

                    if ((consecutivoOper == garantia.ConsecutivoOperacion) && (consecutivoGar == garantia.ConsecutivoGarantia) && (tipoGar == garantia.CodigoTipoGarantia))
                    {
                        datosModificarAnterior = garantia;

                        garantia.IndicadorAjusteCampoSaldo = (((saldoIngresado >= 0) && (saldoIngresado != garantia.SaldoActual)) ? true : false);
                        garantia.IndicadorAjusteCampoPorcentaje = (((porcentajeIngresado >= 0) && (porcentajeIngresado != garantia.PorcentajeResponsabilidadAjustado)) ? true : false);
                        garantia.SaldoActualAjustado = ((saldoIngresado >= 0) ? saldoIngresado : garantia.SaldoActual);
                        garantia.PorcentajeResponsabilidadAjustado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadAjustado);
                        garantia.PorcentajeResponsabilidadCalculado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadCalculado);
                        
                        datosModificar = garantia;
                        datosBusqueda = garantia;
                    }
                }

                if (((porcentajePorDistribuir > limiteInferior) && (porcentajePorDistribuir < limiteSuperior)) || (datosModificar.IndicadorAjusteCampoSaldo))
                {
                    if (!ajusteManual)
                    {
                        resultadoCalculo = listaDatos.AplicarCalculoDistribucion();                       
                    }
                    else
                    {
                        resultadoCalculo = true;
                    }

                    listaDatosRetornados.Clear();

                    foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                    {
                        listaDatosRetornados.Add(garantia);

                        datosModificarAnterior = garantia;
                        datosModificar = garantia;

                        if ((garantia.ConsecutivoOperacion > 0) && (garantia.ConsecutivoGarantia > 0) && (garantia.CodigoTipoGarantia > 0) && (!garantia.IndicadorExcluido))
                        {
                            Gestor.ModificarSaldoTotalPr(datosModificar, datosModificarAnterior, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                        }
                    }
                }
                else
                {
                    resultadoCalculo = true;

                    if ((consecutivoOper > 0) && (consecutivoGar > 0) && (tipoGar > 0))
                    {
                        Gestor.ModificarSaldoTotalPr(datosModificar, datosModificarAnterior, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                    }
                }
            }
            else
            {
                datosRetornado.CodigoError = 0;
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }

            if (resultadoCalculo)
            {
                if ((datosBusqueda.ConsecutivoOperacion > 0) && (datosBusqueda.ConsecutivoGarantia > 0) && (datosBusqueda.CodigoTipoGarantia > 0))
                {
                    switch (datosBusqueda.CodigoTipoGarantia)
                    {
                        case 1:
                            clsGarantiaFiduciaria datoBusquedaGF = new clsGarantiaFiduciaria();
                            datoBusquedaGF.ConsecutivoGarantiaFiduciaria = datosBusqueda.ConsecutivoGarantia;
                            datoBusquedaGF.IndentificacionSicc = -1;
                            datoBusquedaGF.CodigoTipoPersonaFiador = -1;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaFiduciaria(datoBusquedaGF, Global.UsuarioSistema);
                            break;
                        case 2:
                            clsGarantiaReal datoBusquedaGR = new clsGarantiaReal();
                            datoBusquedaGR.CodGarantiaReal = datosBusqueda.ConsecutivoGarantia;
                           listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaReal(datoBusquedaGR, Global.UsuarioSistema);
                            break;
                        case 3:
                            clsGarantiaValor datoBusquedaGV = new clsGarantiaValor();
                            datoBusquedaGV.ConsecutivoGarantia = datosBusqueda.ConsecutivoGarantia;
                            datoBusquedaGV.NumeroSeguridad = string.Empty;
                            datoBusquedaGV.CodigoClaseGarantia = -1;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaValor(datoBusquedaGV, Global.UsuarioSistema);
                            break;
                        default:
                            datosRetornado.CodigoError = 0;
                            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                            listaDatosRetornados.Clear();
                            listaDatosRetornados.Add(datosRetornado);
                            break;
                    }

                    if ((listaDatosActualizados != null) && (listaDatosActualizados.Count > 0))
                    {
                        listaDatosRetornados.Clear();

                        foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatosActualizados)
                        {
                            garantia.CodigoError = 0;
                            listaDatosRetornados.Add(garantia);
                        }
                    }
                }
            }
            else
            {                
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 1;
                datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantia, Mensajes.ASSEMBLY);
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }            
        }
        catch (ExcepcionBase ex)
        {
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = ex.Message;
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }
        catch (Exception ex)
        {
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPr, Mensajes.ASSEMBLY);
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }
    
    /// <summary>
    /// Se encarga de realizar la modificación del registro consultado.
    /// </summary>
    /// <param name="consecutivoOperacion">Consecutivo de la operación</param>
    /// <param name="consecutivoGarantia">Consecutivo de la garantía</param>
    /// <param name="tipoGarantia">Código del tip ode garantía</param>
    /// <param name="saldoActualAjustado">Saldo actual ajustado</param>
    /// <param name="porcentajeRespAjustado">Porcentaje de responsabilidad ajustado</param>
    /// <param name="arregloElementos">Arreglo de elementos manipulados desde el cliente</param>
    /// <returns>La lista con las operaciones que respalda la garantía con el porcentaje de responsabilidad calculado</returns>
    [System.Web.Services.WebMethod]
    public static clsSaldoTotalPorcentajeResponsabilidad[] EliminarRegistro(string consecutivoOperacion, string consecutivoGarantia, string tipoGarantia, string saldoActualAjustado,
                                            string porcentajeRespAjustado, string arregloElementos, string cambioManual)
    {
        List<clsSaldoTotalPorcentajeResponsabilidad> listaDatosRetornados = new List<clsSaldoTotalPorcentajeResponsabilidad>();
        clsSaldoTotalPorcentajeResponsabilidad datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosEliminar = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosEliminarAnterior = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldoTotalPorcentajeResponsabilidad datosBusqueda = new clsSaldoTotalPorcentajeResponsabilidad();
        clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatosActualizados = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>();

        bool resultadoCalculo = false;
        bool ajusteManual = (((cambioManual.Length > 0) && (cambioManual.CompareTo("1") == 0)) ? true : false);


        string identificacionGarantia = string.Empty;
        decimal saldoIngresado;
        decimal porcentajeIngresado;
        decimal porcentajePorDistribuir = 0;
        decimal limiteInferior;
        decimal limiteSuperior;
        long consecutivoOper;
        long consecutivoGar;
        short tipoGar;

        try
        {

            saldoIngresado = ((decimal.TryParse(saldoActualAjustado, out saldoIngresado)) ? saldoIngresado : -1);
            porcentajeIngresado = ((decimal.TryParse(porcentajeRespAjustado, out porcentajeIngresado)) ? porcentajeIngresado : -1);
            limiteInferior = ((decimal)(((decimal.TryParse("0.00010", out limiteInferior)) ? limiteInferior : 0) * 100));
            limiteSuperior = ((decimal)(((decimal.TryParse("0.01000", out limiteSuperior)) ? limiteSuperior : 0) * 100));

            consecutivoOper = ((long.TryParse(consecutivoOperacion, out consecutivoOper)) ? consecutivoOper : -1);
            consecutivoGar = ((long.TryParse(consecutivoGarantia, out consecutivoGar)) ? consecutivoGar : -1);
            tipoGar = ((short.TryParse(tipoGarantia, out tipoGar)) ? tipoGar : ((short)-1));

            porcentajePorDistribuir = ((100 - porcentajeIngresado) / 100);

            clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad> listaDatos = new clsSaldosTotalesPorcentajeResponsabilidad<clsSaldoTotalPorcentajeResponsabilidad>(arregloElementos);

            if ((listaDatos != null) && (listaDatos.Count > 0))
            {
                datosRetornado.CodigoError = 0;

                foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                {
                    listaDatosRetornados.Add(garantia);

                    if ((consecutivoOper == garantia.ConsecutivoOperacion) && (consecutivoGar == garantia.ConsecutivoGarantia) && (tipoGar == garantia.CodigoTipoGarantia))
                    {
                        datosEliminarAnterior = garantia;

                        garantia.IndicadorAjusteCampoSaldo = (((saldoIngresado >= 0) && (saldoIngresado != garantia.SaldoActual)) ? true : false);
                        garantia.IndicadorAjusteCampoPorcentaje = (((porcentajeIngresado >= 0) && (porcentajeIngresado != garantia.PorcentajeResponsabilidadAjustado)) ? true : false);
                        garantia.SaldoActualAjustado = ((saldoIngresado >= 0) ? saldoIngresado : garantia.SaldoActual);
                        garantia.PorcentajeResponsabilidadAjustado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadAjustado);
                        garantia.PorcentajeResponsabilidadCalculado = ((porcentajeIngresado >= 0) ? porcentajeIngresado : garantia.PorcentajeResponsabilidadCalculado);
                        garantia.IndicadorExcluido = true;

                        datosEliminar = garantia;
                        datosBusqueda = garantia;
                    }
                }

                if ((consecutivoOper > 0) && (consecutivoGar > 0) && (tipoGar > 0))
                {
                    resultadoCalculo = true;

                    Gestor.EliminarSaldoTotalPr(datosEliminar, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                }

                if (((porcentajePorDistribuir > limiteInferior) && (porcentajePorDistribuir < limiteSuperior)) || (datosEliminar.IndicadorAjusteCampoSaldo))
                {
                    if (!ajusteManual)
                    {
                        resultadoCalculo = listaDatos.AplicarCalculoDistribucion();
                    }
                    else
                    {
                        resultadoCalculo = true;
                    }


                    foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatos)
                    {
                        listaDatosRetornados.Add(garantia);

                        datosEliminarAnterior = garantia;
                        datosEliminar = garantia;

                        if ((garantia.ConsecutivoOperacion > 0) && (garantia.ConsecutivoGarantia > 0) && (garantia.CodigoTipoGarantia > 0) && (!garantia.IndicadorExcluido))
                        {
                            Gestor.ModificarSaldoTotalPr(datosEliminar, datosEliminarAnterior, Global.UsuarioSistema, HttpContext.Current.Request.UserHostAddress);
                        }
                    }
                }
            }
            else
            {
                datosRetornado.CodigoError = 0;
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }

            if (resultadoCalculo)
            {
                if ((datosBusqueda.ConsecutivoOperacion > 0) && (datosBusqueda.ConsecutivoGarantia > 0) && (datosBusqueda.CodigoTipoGarantia > 0))
                {
                    switch (datosBusqueda.CodigoTipoGarantia)
                    {
                        case 1:
                            clsGarantiaFiduciaria datoBusquedaGF = new clsGarantiaFiduciaria();
                            datoBusquedaGF.ConsecutivoGarantiaFiduciaria = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaFiduciaria(datoBusquedaGF, Global.UsuarioSistema);
                            break;
                        case 2:
                            clsGarantiaReal datoBusquedaGR = new clsGarantiaReal();
                            datoBusquedaGR.CodGarantiaReal = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaReal(datoBusquedaGR, Global.UsuarioSistema);
                            break;
                        case 3:
                            clsGarantiaValor datoBusquedaGV = new clsGarantiaValor();
                            datoBusquedaGV.ConsecutivoGarantia = datosBusqueda.ConsecutivoGarantia;
                            listaDatosActualizados = Gestor.ObtenerOperacionesPorGarantiaValor(datoBusquedaGV, Global.UsuarioSistema);
                            break;
                        default:
                            datosRetornado.CodigoError = 0;
                            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                            listaDatosRetornados.Clear();
                            listaDatosRetornados.Add(datosRetornado);
                            break;
                    }

                    if ((listaDatosActualizados != null) && (listaDatosActualizados.Count > 0))
                    {
                        listaDatosRetornados.Clear();

                        foreach (clsSaldoTotalPorcentajeResponsabilidad garantia in listaDatosActualizados)
                        {
                            garantia.CodigoError = 0;
                            listaDatosRetornados.Add(garantia);
                        }
                    }
                }
            }
            else
            {
                datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
                datosRetornado.CodigoError = 1;
                datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorObteniendoOperacionesGarantias, identificacionGarantia, Mensajes.ASSEMBLY);
                listaDatosRetornados.Clear();
                listaDatosRetornados.Add(datosRetornado);
            }            
        }
        catch (ExcepcionBase ex)
        {
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = ex.Message;
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }
        catch (Exception ex)
        {
            datosRetornado = new clsSaldoTotalPorcentajeResponsabilidad();
            datosRetornado.CodigoError = 1;
            datosRetornado.DescripcionError = Mensajes.Obtener(Mensajes._errorAplicandoCalculoDistribucionPr, Mensajes.ASSEMBLY);
            listaDatosRetornados.Clear();
            listaDatosRetornados.Add(datosRetornado);
        }

        return listaDatosRetornados.ToArray();
    }

    #endregion

}