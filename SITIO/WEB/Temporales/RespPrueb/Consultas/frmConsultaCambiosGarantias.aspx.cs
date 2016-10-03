using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;
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


public partial class Consultas_frmConsultaCambiosGarantias : BCR.Web.SystemFramework.PaginaPersistente //BCR.Web.SystemFramework.PaginaPersistente
{

    #region constantes

    private const string LLAVE_CONSECUTIVO_OPERACION = "LLAVE_CONSECUTIVO_OPERACION";
    private const string LLAVE_DATOS_OPERACION = "LLAVE_DATOS_OPERACION";
    private const string LLAVE_ES_GIRO = "LLAVE_ES_GIRO";
    private const string LLAVE_CONSECUTIVO_CONTRATO = "LLAVE_CONSECUTIVO_CONTRATO";
    private const string LLAVE_ENTIDAD_CATALOGOS = "LLAVE_ENTIDAD_CATALOGOS";
    #endregion

    #region Variables Globales

    protected System.Data.OleDb.OleDbConnection oleDbConnection1;
    private string _contratoDelGiro = string.Empty;
    private DataSet oDatosBitacora;
    private BCR.Seguridad.Cryptography.TripleDES oSeguridad = new BCR.Seguridad.Cryptography.TripleDES();

    private List<string> ListaArchivos;

    #endregion

    #region propiedades

    /// <summary>
    /// Se guarda en sesión el consecutivo de la operación
    /// </summary>
    public long ConsecutivoOperacion
    {
        get
        {
            return ((Session[LLAVE_CONSECUTIVO_OPERACION] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_OPERACION].ToString()) : -1);
        }

        set
        {
            Session[LLAVE_CONSECUTIVO_OPERACION] = value.ToString();
        }
    }

    /// <summary>
    /// Se guarda en sesión los datos de la operación, en el formato tipoOperacion_oficina_moneda_producto_operacion
    /// </summary>
    public string DatosOperacion
    {
        get
        {
            return ((Session[LLAVE_DATOS_OPERACION] != null) ? Session[LLAVE_DATOS_OPERACION].ToString() : string.Empty);
        }

        set
        {
            Session[LLAVE_DATOS_OPERACION] = value;
        }
    }

    /// <summary>
    /// Se establece si la operación consultada corresponde a un giro de contrato
    /// </summary>
    public bool EsGiro
    {
        get
        {
            if (Session[LLAVE_ES_GIRO] != null)
            {
                return ((Session[LLAVE_ES_GIRO].ToString().CompareTo("1") == 0) ? true : false);
            }
            else
            {
                return false;
            }
        }

        set
        {
            if (value)
            {
                Session[LLAVE_ES_GIRO] = "1";
            }
            else
            {
                Session[LLAVE_ES_GIRO] = "0";
            }
        }
    }

    /// <summary>
    /// Se establece si la operación consultada corresponde a un giro de contrato, de serlo, 
    /// esta propiedad contendrá el consecutivo de dicho contrato
    /// </summary>
    public long ConsecutivoContrato
    {
        get
        {
            return ((Session[LLAVE_CONSECUTIVO_CONTRATO] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_CONTRATO].ToString()) : -1);
        }

        set
        {
            Session[LLAVE_CONSECUTIVO_CONTRATO] = value.ToString();
        }
    }

    #endregion 
    
    protected void Page_Load(object sender, EventArgs e)
    {
        txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
        txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
        txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
        txtProducto.Attributes["onblur"] = "javascript:EsNumerico(this);";
        txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";

        btnGenerarConsultaMasiva.Attributes["onclick"] = "javascript:return confirm('Este proceso puede tardar algunos minutos... ¿Está seguro que desea generar los archivos?')";
        btnGenerarConsulta.Attributes["onclick"] = "javascript:return confirm('Este proceso puede tardar algunos minutos... ¿Está seguro que desea generar los archivos?')";
        
        ListaArchivos = new List<string>();

        if (!IsPostBack)
        {        
           
            Session["Tipo_Operacion"] = int.Parse(Application["OPERACION_CREDITICIA"].ToString());
            this.Session.Add("listaEnlaces", null);

            contenedorDatosConsultaMasiva.Visible = false;
            btnGenerarConsulta.Enabled = false;
            btnLimpiar.Enabled = false;
            DeshabilitarCamposConsultaMasiva();


            try
            {             
               if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CONSULTA_CAMBIOS_GARANTIAS"].ToString())))
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

        List<LinkButton> listaVacia = new List<LinkButton>();
        /*pregunta si la lista de enlaces es diferente a null, si es diferente a null vuelve a generar 
         * la tabla de enlaces y esto se debe de hacer por que los enlaces son creados de forma dinámica 
         * y para no perder estos controles y los respectivos eventos de cada control creado dinamicamente 
         * se deben de volver a crear en el page_load de la pagina de lo contrario los enlaces se van a ver 
         * en pantalla pero no va a hacer nada por que pierden el evento.*/
        if (Session["listaEnlaces"] != null)
        {
            GenerarTablaEnlaces((List<LinkButton>)Session["listaEnlaces"]);
        }
    }



    #region Eventos
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
        btnGenerarConsultaMasiva.Click += new EventHandler(btnGenerarConsultaMasiva_Click);
        btnGenerarConsulta.Click += new EventHandler(btnGenerarConsulta_Click);
        btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
        chkTodasOperaciones.CheckedChanged += new EventHandler(chkTodasOperaciones_CheckedChanged);
        chkTodosContratos.CheckedChanged += new EventHandler(chkTodosContratos_CheckedChanged); 
    }


    protected void btnValidarOperacion_Click(object sender, EventArgs e)
    {
        int nProducto = -1;
         string numeroOperacion = string.Empty;

        EliminarDatosGlobales();
        Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
        this.ViewState["enlaceSeleccionado"] = null;

        btnGenerarConsulta.Enabled = false;
        btnLimpiar.Enabled = false;

        if (ValidarDatosOperacion())
        {
            string strProducto = ((int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString())) ? txtProducto.Text : string.Empty);
            DataSet dsDatos = new DataSet();

            try
            {
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbCommand oComando = new OleDbCommand("pa_ValidarOperaciones", oleDbConnection1);
                oComando.CommandTimeout = 120;
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.Parameters.AddWithValue("@Contabilidad", txtContabilidad.Text);
                oComando.Parameters.AddWithValue("@Oficina", txtOficina.Text);
                oComando.Parameters.AddWithValue("@Moneda", txtMoneda.Text);

                if (strProducto.Length > 0)
                {
                    oComando.Parameters.AddWithValue("@Producto", strProducto);
                }
                else
                {
                    oComando.Parameters.AddWithValue("@Producto", DBNull.Value);
                }

                oComando.Parameters.AddWithValue("@Operacion", txtOperacion.Text);
                oComando.Parameters["@Producto"].IsNullable = true;

                numeroOperacion = ((strProducto.Length > 0) ? (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + strProducto + "-" + txtOperacion.Text) : (txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text + "-" + txtOperacion.Text));

                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter();

                if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Closed))
                {
                    oleDbConnection1.Open();
                }

                cmdConsulta.SelectCommand = oComando;
                cmdConsulta.SelectCommand.Connection = oleDbConnection1;
                cmdConsulta.Fill(dsDatos, "Operacion");

            }
            catch (Exception ex)
            {
                string rutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                rutaActual = rutaActual.Remove(rutaActual.IndexOf("/Consultas"));

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION_DETALLE, (" '" + numeroOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                    "bError=1" +
                    "&strTitulo=" + "Problemas Validando Operación" +
                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_VALIDANDO_OPERACION, (" '" + numeroOperacion + "'"), Mensajes.ASSEMBLY) +
                    "&bBotonVisible=0");
            }
            finally
            {
                if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Open))
                {
                    oleDbConnection1.Close();
                }
            }

            try
            {
                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Operacion"].Rows.Count > 0))
                {

                    EsGiro = (((dsDatos.Tables["Operacion"].Columns.Contains("esGiro")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("esGiro")) && (dsDatos.Tables["Operacion"].Rows[0]["esGiro"].ToString().CompareTo("1") == 0)) ? true : false);

                    ConsecutivoContrato = (((dsDatos.Tables["Operacion"].Columns.Contains("consecutivoContrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("consecutivoContrato"))) ? (long.Parse(dsDatos.Tables["Operacion"].Rows[0]["consecutivoContrato"].ToString())) : -1);

                    _contratoDelGiro = (((EsGiro) && (dsDatos.Tables["Operacion"].Columns.Contains("Contrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("Contrato"))) ? (dsDatos.Tables["Operacion"].Rows[0]["Contrato"].ToString()) : string.Empty);

                    if (!EsGiro)
                    {
                        ConsecutivoOperacion = long.Parse(dsDatos.Tables["Operacion"].Rows[0]["cod_operacion"].ToString());

                        DatosOperacion = cbTipoCaptacion.SelectedItem.Value + "_" + txtOficina.Text + "_" + txtMoneda.Text + "_" + txtProducto.Text + "_" + txtOperacion.Text;

                        Session["Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString();

                        if (txtProducto.Text.Length != 0)
                            nProducto = int.Parse(txtProducto.Text);

                        GenerarListadoGarantias(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                            ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                            int.Parse(txtContabilidad.Text),
                                            int.Parse(txtOficina.Text),
                                            int.Parse(txtMoneda.Text),
                                            nProducto,
                                            long.Parse(txtOperacion.Text));

                        lblDeudor.Visible = true;
                        lblNombreDeudor.Visible = true;

                        Session["Nombre_Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString() + " - " +
                                                    dsDatos.Tables["Operacion"].Rows[0]["nombre_deudor"].ToString();

                        lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();
                        Session["EsOperacionValidaReal"] = true;
                        //GuardarDatosSession();
                    }
                    else
                    {
                        gdvCambioGarantia.DataSource = null;
                        gdvCambioGarantia.DataBind();

                        lblMensaje.Text = "";
                        lblMensaje3.Text = "";
                        lblMensaje2.Text = "";                    

                        contenedorTabla.Controls.Clear();
                        contenedorGarantiaValor.Controls.Clear();
                        contenedorGarantiaFiduciaria.Controls.Clear();

                        lblMensaje.Text = Mensajes.Obtener(Mensajes._errorConsultaGiro, _contratoDelGiro, Mensajes.ASSEMBLY);
                    }
                }
                else
                {
                    //BloquearCampos(false, true);
                    Session["EsOperacionValida"] = false;
                    lblDeudor.Visible = false;
                    lblNombreDeudor.Visible = false;
                    Session["Nombre_Deudor"] = "";

                    if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
                    else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                        lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";

                    gdvCambioGarantia.DataSource = null;
                    gdvCambioGarantia.DataBind();

                    lblMensaje3.Text = "";
                    lblMensaje2.Text = "";                  

                    contenedorTabla.Controls.Clear();
                    contenedorGarantiaFiduciaria.Controls.Clear();
                    contenedorGarantiaValor.Controls.Clear();
                }
            }
            catch (Exception ex)
            {
                string rutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                rutaActual = rutaActual.Remove(rutaActual.IndexOf("/Consultas"));

                Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS_DETALLE, (" '" + numeroOperacion + "'"), ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
                Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                    "bError=1" +
                    "&strTitulo=" + "Problemas Cargando Garantías" +
                    "&strMensaje=" + Mensajes.Obtener(Mensajes.ERROR_CARGANDO_DATOS, (" '" + numeroOperacion + "'"), Mensajes.ASSEMBLY) +
                    "&bBotonVisible=0");
            }
        }
        else
        {
            Session["listaEnlaces"] = null;
        }
    }

    protected void enlaceNuevo_Click(object sender, CommandEventArgs e)
    {
        string idEnlaceSeleccionado;
        oDatosBitacora = new DataSet();
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
        lblMensaje.Text = "";
        lblMensaje3.Text = "";
        lblMensaje2.Text = "";
        gdvCambioGarantia.DataSource = null;
        gdvCambioGarantia.DataBind();

        try
        {          
            string codGarantia = ((LinkButton)sender).Text;
            idEnlaceSeleccionado = ((LinkButton)sender).ID;

            ViewState.Add("codGarantia", codGarantia);
            ViewState.Add("enlaceSeleccionado", idEnlaceSeleccionado);

            GenerarTablaEnlaces((List<LinkButton>)Session["listaEnlaces"]);

            oDatosBitacora = Gestor.ObtenerDatosCambioGarantia("", codGarantia);
                       
            if (oDatosBitacora != null)           
            {               
                if (oDatosBitacora.Tables[0].Rows.Count > 0)
                {
                    btnGenerarConsulta.Enabled = true;
                    btnLimpiar.Enabled = true;                

                    ViewState.Add("DatosBitacora", oDatosBitacora);
                    CargarGrid(oDatosBitacora);
                }
                else
                {
                    btnGenerarConsulta.Enabled = false;
                    btnLimpiar.Enabled = false;
                    lblMensaje3.Text = "No existen cambios  de la garantía seleccionada.";
                }               
            }
            else
            {
                lblMensaje3.Text = "No existen cambios  de la garantía seleccionada.";
            }        

        }//fin del try
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(ex.Message, EventLogEntryType.Error);
            lblMensaje3.Text = "Ha ocurrido un error en la consulta de cambios en la garantía o No existen cambios de la garantía seleccionada.";
        }//fin del cath

    

    }//fin del metodo enlaceNuevo_Click

    private void CargarGrid(DataSet oDatosBitacorap) 
    {
        try
        { 
            if ((oDatosBitacorap != null) && (oDatosBitacorap.Tables.Count > 0))
            {
                gdvCambioGarantia.DataSource = oDatosBitacorap;
                gdvCambioGarantia.DataBind();
            }
            else
            {
                lblMensaje3.Text = "No existen cambios de la garantía seleccionada.";
            }

        }//fin del try
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(ex.Message, EventLogEntryType.Error);
            lblMensaje3.Text = "Ha ocurrido un error en la consulta de cambios en la garantía o No existen cambios de la garantía seleccionada.";
        }//fin del cath   
       
    }

    protected void gdvCambioGarantia_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        try
        {
            this.gdvCambioGarantia.SelectedIndex = -1;
            this.gdvCambioGarantia.PageIndex = e.NewPageIndex;

            oDatosBitacora =   (DataSet)this.ViewState["DatosBitacora"]; 
            CargarGrid(oDatosBitacora);
        }
        catch (Exception ex)
        {
            string v = ex.Message;
                lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }    

    }//fin del metodo gdvCambioGarantia_PageIndexChanging

    /// <summary>
    /// Este método permite generar una tabla con los enlaces generados de acuerdo a los datos de consulta emitidos por el
    /// usuario.
    /// </summary>
    private void GenerarTablaEnlaces(List<LinkButton> listadoEnlacesGarantias)
    {

        try {                   
    
        string enlaceSeleccionado = "";
        int contadorColumnas = 0;

        HtmlTable tablaEnlaces = new HtmlTable();
        HtmlTable tablaGarantiaValor = new HtmlTable();
        HtmlTable tablaGarantiaFiduciaria = new HtmlTable();

        HtmlTableRow nuevaFila = new HtmlTableRow();
        HtmlTableRow nuevaFilaFiduciaria = new HtmlTableRow();
        HtmlTableRow nuevaFilaValor = new HtmlTableRow();

        //contenedor de las garantias reales
        contenedorTabla.Controls.Clear();  
        contenedorTabla.Controls.Add(tablaEnlaces);

        contenedorGarantiaValor.Controls.Clear();
        contenedorGarantiaValor.Controls.Add(tablaGarantiaValor);

        contenedorGarantiaFiduciaria.Controls.Clear();
        contenedorGarantiaFiduciaria.Controls.Add(tablaGarantiaFiduciaria);

        if (this.ViewState["enlaceSeleccionado"] != null)
        {
            enlaceSeleccionado = this.ViewState["enlaceSeleccionado"].ToString();
        }  

        foreach (LinkButton button in listadoEnlacesGarantias)
        {
            if (contadorColumnas == 7)
            {
                nuevaFila = new HtmlTableRow();
                contadorColumnas = 0;
            }

            if (button.ID == enlaceSeleccionado)
            {
                button.ForeColor = System.Drawing.Color.Red;
            }
            else
            {
                button.ForeColor = System.Drawing.Color.Blue;
            }

            button.Command += new CommandEventHandler(this.enlaceNuevo_Click);
            this.Page.Controls.Add(button);         

            switch (button.CommandName)
            {
                //Fiduciaria
                case "1":

                    HtmlTableCell nuevaCelda = new HtmlTableCell();
                    HtmlTableCell celdaEspacio = new HtmlTableCell();
                    celdaEspacio.Width = "12x";
                    celdaEspacio.InnerHtml = "&nbsp;&nbsp;/&nbsp;&nbsp;";

                    nuevaCelda.Controls.Add(button);
                    nuevaFilaFiduciaria.Cells.Add(nuevaCelda);
                    nuevaFilaFiduciaria.Cells.Add(celdaEspacio);
                    nuevaFilaFiduciaria.Cells.Add(celdaEspacio);                

                    tablaGarantiaFiduciaria.Rows.Add(nuevaFilaFiduciaria);
                    break;

                //Real
                case "2":

                    nuevaCelda = new HtmlTableCell();
                    celdaEspacio = new HtmlTableCell();
                    celdaEspacio.Width = "12x";
                    celdaEspacio.InnerHtml = "&nbsp;&nbsp;/&nbsp;&nbsp;";          
                 
                    nuevaCelda.Controls.Add(button);
                    nuevaFila.Cells.Add(nuevaCelda);
                    nuevaFila.Cells.Add(celdaEspacio);
                    nuevaFila.Cells.Add(celdaEspacio);                    

                    tablaEnlaces.Rows.Add(nuevaFila);
                    break;


                //Valor
                case "3":
                     nuevaCelda = new HtmlTableCell();
                     celdaEspacio = new HtmlTableCell();
                    celdaEspacio.Width = "12x";
                    celdaEspacio.InnerHtml = "&nbsp;&nbsp;/&nbsp;&nbsp;";

                    nuevaCelda.Controls.Add(button);
                    nuevaFilaValor.Cells.Add(nuevaCelda);
                    nuevaFilaValor.Cells.Add(celdaEspacio);
                    nuevaFilaValor.Cells.Add(celdaEspacio);             

                    tablaGarantiaValor.Rows.Add(nuevaFilaValor);
                    break;
            }        

            contadorColumnas++;
        }     

        contenedorTabla.Controls.Add(tablaEnlaces);     
        contenedorGarantiaFiduciaria.Controls.Add(tablaGarantiaFiduciaria);
        contenedorGarantiaValor.Controls.Add(tablaGarantiaValor);

        }catch(Exception e)
        {
            string s = e.Message;
         }

    }

    private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        try
        {
            //Campos llave
            txtOficina.Text = "";
            txtMoneda.Text = "";
            txtProducto.Text = "";
            txtOperacion.Text = "";
            lblMensaje.Text = "";
            lblMensaje3.Text = "";
            lblMensaje2.Text = "";
           
            contenedorTabla.Controls.Clear();
            contenedorGarantiaValor.Controls.Clear();
            contenedorGarantiaFiduciaria.Controls.Clear();

            gdvCambioGarantia.DataSource = null;
            gdvCambioGarantia.DataBind();

            if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                lblTipoOperacion.Text = "Operación:";
                btnValidarOperacion.Text = "Validar Operación";
                btnValidarOperacion.ToolTip = "Verifica que la operación sea válida";
                Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                lblProducto.Visible = true;
                txtProducto.Visible = true;
            }
            else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
            {
                lblTipoOperacion.Text = "Contrato:";
                btnValidarOperacion.Text = "Validar Contrato";
                btnValidarOperacion.ToolTip = "Verifica que el contrato sea válido";
                Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                lblProducto.Visible = false;
                txtProducto.Visible = false;
            }
            lblDeudor.Visible = false;
            lblNombreDeudor.Visible = false;
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "cbTipoCaptacion_SelectedIndexChanged", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }
        
    }

    private void btnGenerarConsultaMasiva_Click(object sender, System.EventArgs e)
    {
        WindowsImpersonationContext _objContext = null;
        string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
        string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
        string dominio = Application["DOMINIO_DEFAULT"].ToString();
        string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();
        int codCataloIndIns = Convert.ToInt32(Application["CAT_INSCRIPCION"].ToString());
        int accion = 0;
        string strArchivoOrigen = string.Empty;
        string nombreArchivo = string.Empty;

        contenedorTabla.Controls.Clear();
        contenedorGarantiaFiduciaria.Controls.Clear();
        contenedorGarantiaValor.Controls.Clear();  

        _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio);

        lblMensaje.Text = string.Empty; 
        
        if (_objContext != null)
        {
                try
                {
                    if (ValidarDatosConsultaMasiva())
                    {
                        btnGenerarConsultaMasiva.Enabled = false;

                        if (chkTodasOperaciones.Checked)
                        {
                            accion = 1;

                        }
                        if (chkTodosContratos.Checked)
                        {
                            accion = 2;
                        }

                        if ((chkTodasOperaciones.Checked) && (chkTodosContratos.Checked))
                        {
                            accion = 3;
                        }                 
                       
                        strArchivoOrigen = Gestor.GenerarInformacionCambiosGarantiasTXT(strRuta, accion, DateTime.Parse(txtFechaInicial.Text), DateTime.Parse(txtFechaFinal.Text));
                        ComprimirArchivo(strRuta, strArchivoOrigen, strRuta + "Archivo de Cambios en Garantías.zip");
                        ListaArchivos.Add("Archivo de Cambios en Garantías.zip");
                        DescargarArchivos(strRuta);

                        string[] words = strArchivoOrigen.Split('\\');
                        nombreArchivo = words[5];                   

                        EliminarArchivos(nombreArchivo);                   

                    }

                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos. Por favor reintente. Detalle:" + ex.Message), EventLogEntryType.Error);

                    lblMensaje.Text = "Se presentaron problemas generando los archivos. Por favor reintente.";
                }
                finally
                {
                    txtFechaFinal.Text = string.Empty;
                    txtFechaInicial.Text = string.Empty;
                    btnGenerarConsultaMasiva.Enabled = true;
                    _objContext.Undo();
                }
                
        }
        else
        {
            lblMensaje.Text = "La impersonalización es nula";
            lblMensaje.Visible = true;
        }
     }

    private void btnGenerarConsulta_Click(object sender, System.EventArgs e)
    {
        WindowsImpersonationContext _objContext = null;
        string usuario = Application["BCRGARANTIAS.USUARIODFS"].ToString();
        string password = oSeguridad.Decrypt(Application["BCRGARANTIAS.CLAVEUSUARIODFS"].ToString());
        string dominio = Application["DOMINIO_DEFAULT"].ToString();
        string strRuta = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();
        int codCataloIndIns = Convert.ToInt32(Application["CAT_INSCRIPCION"].ToString());    
        string strArchivoOrigen = string.Empty;
        string nombreArchivo = string.Empty;
        lblMensaje3.Text = string.Empty;

        _objContext = Impersonalizacion.WinLogOn(usuario, password, dominio);
        string codGarantia = this.ViewState["codGarantia"].ToString();

        if (_objContext != null)
        {
            try
            {
                if (ValidarDatosConsulta())
                {               
                    strArchivoOrigen = Gestor.GenerarInformacionCambiosGarantiasTXT(strRuta, codGarantia);
                    ComprimirArchivo(strRuta, strArchivoOrigen, strRuta + "Archivo de Cambios en Garantías.zip");
                    ListaArchivos.Add("Archivo de Cambios en Garantías.zip");
                    DescargarArchivos(strRuta);

                    string[] words = strArchivoOrigen.Split('\\');
                    nombreArchivo = words[5];

                    EliminarArchivos(nombreArchivo);                 
                }
                LimpiarCamposConsultaIndividual();
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos. Por favor reintente. Detalle:" + ex.Message), EventLogEntryType.Error);

                lblMensaje3.Text = "Se presentaron problemas generando los archivos. Por favor reintente.";
            }
            finally
            {
                
                _objContext.Undo();
            }

        }
        else
        {
            lblMensaje.Text = "La impersonalización es nula";
            lblMensaje.Visible = true;
        }
    }

    private void btnLimpiar_Click(object sender, System.EventArgs e) 
    {

        //txtContabilidad.Text = "";
        //txtMoneda.Text = "";
        //txtOficina.Text = "";
        //txtOperacion.Text = "";
        //txtProducto.Text = "";
        lblMensaje.Text = "";
        lblMensaje3.Text = "";
        lblMensaje2.Text = "";
        lblDeudor.Text = string.Empty;
        lblNombreDeudor.Text = string.Empty;

        cbTipoCaptacion.SelectedIndex = 0;
        txtProducto.Visible = true;
        lblProducto.Visible = true;

        gdvCambioGarantia.DataSource = null;
        gdvCambioGarantia.DataBind();
        btnGenerarConsulta.Enabled = false;
        btnLimpiar.Enabled = false;

        contenedorTabla.Controls.Clear();
        contenedorGarantiaFiduciaria.Controls.Clear();
        contenedorGarantiaValor.Controls.Clear();    
    }

    protected void chkTodasOperaciones_CheckedChanged(object sender, EventArgs e) 
    {
        if (chkTodasOperaciones.Checked)
        {
            contenedorDatosConsultaMasiva.Visible = true;
            HabilitarCamposConsultaMasiva();
            contenedorConsultaIndividual.Visible = false;
        }
        else 
        {
            if (chkTodosContratos.Checked)
            {
                contenedorDatosConsultaMasiva.Visible = true;
                HabilitarCamposConsultaMasiva();
                contenedorConsultaIndividual.Visible = false;
            }
            else 
            {
                contenedorDatosConsultaMasiva.Visible = false;
                DeshabilitarCamposConsultaMasiva();
                LimpiarCamposConsultaMasiva();
                contenedorConsultaIndividual.Visible = true;
            }            
        }

        LimpiarCamposConsultaIndividual();        
    }

    protected void chkTodosContratos_CheckedChanged(object sender, EventArgs e)
    {
        if (chkTodosContratos.Checked)
        {
            contenedorDatosConsultaMasiva.Visible = true;
            HabilitarCamposConsultaMasiva();
            contenedorConsultaIndividual.Visible = false;           
        }
        else 
        {
            if (chkTodasOperaciones.Checked)
            {
                contenedorDatosConsultaMasiva.Visible = true;
                HabilitarCamposConsultaMasiva();
                contenedorConsultaIndividual.Visible = false;
            }
            else
            {
                contenedorDatosConsultaMasiva.Visible = false;
                DeshabilitarCamposConsultaMasiva();
                LimpiarCamposConsultaMasiva();
                contenedorConsultaIndividual.Visible = true;
            }
        
        }
        LimpiarCamposConsultaIndividual();
        
    }

    #endregion


    #region Métodos Privados

    /// <summary>
    /// Este método permite validar los campos llave de la operación
    /// </summary>
    /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
    private bool ValidarDatosOperacion()
    {
        bool bRespuesta = true;
        try
        {
            lblMensaje.Text = "";

            if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el código de contabilidad";
                bRespuesta = false;
            }
            if (bRespuesta && txtOficina.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el código de oficina";
                bRespuesta = false;
            }
            if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el código de moneda";
                bRespuesta = false;
            }
            if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                if (txtProducto.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código del producto";
                    bRespuesta = false;
                }
            }
            if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
            {
                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblMensaje.Text = "Debe ingresar el número de operación";
                }
                else
                {
                    lblMensaje.Text = "Debe ingresar el número de contrato";
                }

                bRespuesta = false;
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
        return bRespuesta;
    }

    private bool ValidarDatosConsultaMasiva()
    {
        lblMensaje.Text = "";

        if (string.IsNullOrEmpty(txtFechaInicial.Text) && string.IsNullOrEmpty(txtFechaFinal.Text))
        {
            lblMensaje.Text = "Debe seleccionar un Rando de Fechas";
            return false;
        }
        else 
        {
            DateTime dFI = new DateTime();
            DateTime dFF = new DateTime();

            //if ( (!DateTime.TryParse(txtFechaInicial.Text, out dFI)) && (!DateTime.TryParse(txtFechaFinal.Text, out dFF)))
            //{           
            //    lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
            //    return false;
            //}

            if (!DateTime.TryParse(txtFechaInicial.Text, out dFI))
            {
                lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
                return false;
            }

            if (!DateTime.TryParse(txtFechaFinal.Text, out dFF))
            {
                lblMensaje.Text = "Valor Ingresado Erroneo o Formato de Fecha Incorrecto: dd/mm/aaaa";
                return false;
            }
        
        }
        
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

        if(DateTime.Parse(txtFechaInicial.Text) > DateTime.Parse(txtFechaFinal.Text))        
        {
            lblMensaje.Text = "La Fecha Desde debe ser menor a la Fecha Hasta";
            return false;
        }     

        return true;
    }

    private bool ValidarDatosConsulta()
    {
        lblMensaje3.Text = "";

        if (gdvCambioGarantia.Rows.Count < 0)
        {
            lblMensaje3.Text = "Debe seleccionar una garantia asociada";
            return false;
        }    

        return true;
    }

    private void ComprimirArchivo(string strRutaOrigen, string strArchivoOrigen, string strArchivoDestino)
    {
        try 
        {        
            ZipOutputStream zipOut = new ZipOutputStream(File.Create(strArchivoDestino));       
            FileInfo fi = new FileInfo(strArchivoOrigen); 
            ZipEntry entry = new ZipEntry(fi.Name);       
            FileStream sReader = File.OpenRead(strArchivoOrigen);
            byte[] buff = new byte[Convert.ToInt32(sReader.Length)];
            sReader.Read(buff, 0, (int)sReader.Length);
            entry.DateTime = fi.LastWriteTime;
            entry.Size = sReader.Length;
            sReader.Close();
            zipOut.PutNextEntry(entry);
            zipOut.Write(buff, 0, buff.Length);
            zipOut.Finish();
            zipOut.Close();
        
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
            Utilitarios.RegistraEventLog(("Se presentaron problemas al comprimir los archivos solicitados. Detalle:" + ex.Message), EventLogEntryType.Error);
        }   
    }    

    private void EliminarArchivos(string strNombreArchivo)
    {
        try
        {
            string strRutaArchivos = Application["BCRGARANTIAS.RUTA.ARCHIVOS.INCONSISTENCIAS.Y.ALERTAS"].ToString();

            DirectoryInfo di = new DirectoryInfo(strRutaArchivos);

            FileInfo[] rgFiles = di.GetFiles(strNombreArchivo + ".*");
            foreach (FileInfo fi in rgFiles)
            {
                fi.Delete();
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
            Utilitarios.RegistraEventLog(("Se presentaron problemas generando los archivos solicitados. Detalle:" + ex.Message), EventLogEntryType.Error);
        }
    }

    /// <summary>
    /// Permite descargar los archivos una vez que han sido generados
    /// </summary>
    /// <param name="strRuta">Ruta del archivo a descargar</param>
    private void DescargarArchivos(string strRuta)
    {
        string strNombreArchivo = string.Empty;

        try
        {
            if (ListaArchivos.Count > 0)
            {
                DirectoryInfo di = new DirectoryInfo(strRuta);

                foreach (string archivo in ListaArchivos)
                {
                    FileInfo[] rgFiles = di.GetFiles((archivo + "*"));

                    foreach (FileInfo fi in rgFiles)
                    {
                        strNombreArchivo = fi.Name.ToString();

                        if (File.Exists(fi.FullName.ToString()))
                        {
                            //Crea una instancia del objeto Response
                            Response.Clear();
                            Response.HeaderEncoding = System.Text.Encoding.Default;
                            Response.AddHeader("Content-Disposition", "attachment; filename=" + fi.Name.ToString());
                            Response.AddHeader("Content-Length", fi.Length.ToString());
                            Response.ContentType = "application/octet-stream";
                            Response.WriteFile(fi.FullName.ToString());
                            Response.Flush();
                            Response.Close();
                        }
                        else
                        {
                            //lblMensaje.Text = Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertas, strNombreArchivo, Mensajes.ASSEMBLY);
                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertasDetalle, strNombreArchivo, "El archivo no existe.", Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                        }
                    }
                }
            }
            else
            {
                lblMensaje.Text = "No existen archivos que descargar";
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertas, strNombreArchivo, Mensajes.ASSEMBLY);
            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorDescargandoArchivosAlertasDetalle, strNombreArchivo, ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
        }
    }

    /// <summary>
    /// Retorna el tip ode contenido, de acuerdo a la extensión del archivo
    /// </summary>
    /// <param name="strExtensionArchivo">Estensión del archivo del cual se requiere el tipo de contenido</param>
    /// <returns>Cadena con el tipo de contenido</returns>
    private string RetornaTipoContenido(string strExtensionArchivo)
    {
        switch (strExtensionArchivo)
        {
            case ".htm":
            case ".html":
            case ".log":
                return "text/HTML";
            case ".txt":
                return "text/plain";
            case ".doc":
                return "application/ms-word";
            case ".tiff":
            case ".tif":
                return "image/tiff";
            case ".asf":
                return "video/x-ms-asf";
            case ".avi":
                return "video/avi";
            case ".zip":
                return "application/zip";
            case ".xls":
            case ".csv":
                return "application/vnd.ms-excel";
            case ".gif":
                return "image/gif";
            case ".jpg":
            case "jpeg":
                return "image/jpeg";
            case ".bmp":
                return "image/bmp";
            case ".wav":
                return "audio/wav";
            case ".mp3":
                return "audio/mpeg3";
            case ".mpg":
            case "mpeg":
                return "video/mpeg";
            case ".rtf":
                return "application/rtf";
            case ".asp":
                return "text/asp";
            case ".pdf":
                return "application/pdf";
            case ".fdf":
                return "application/vnd.fdf";
            case ".ppt":
                return "application/mspowerpoint";
            case ".dwg":
                return "image/vnd.dwg";
            case ".msg":
                return "application/msoutlook";
            case ".xml":
            case ".sdxl":
                return "application/xml";
            case ".xdp":
                return "application/vnd.adobe.xdp+xml";
            default:
                return "application/octet-stream";
        }
    }

    private void GenerarListadoGarantias(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                          int nOficina, int nMoneda, int nProducto, long nOperacion)
    {
        List<LinkButton> listadoEnlaces = new List<LinkButton>();

        System.Data.DataSet dsDatos = new System.Data.DataSet();
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

        using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
        {
            SqlCommand oComando = null;

            oComando = new SqlCommand("Obtener_Garantias_Bitacora", oConexion);
            SqlDataAdapter oDataAdapter = new SqlDataAdapter();

            //declara las propiedades del comando
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.CommandTimeout = 120;
            oComando.Parameters.AddWithValue("@piCodOperacion", nCodOperacion);
            oComando.Parameters.AddWithValue("@piContabilidad", nContabilidad);
            oComando.Parameters.AddWithValue("@piOficina", nOficina);
            oComando.Parameters.AddWithValue("@piMoneda", nMoneda);          
            oComando.Parameters.AddWithValue("@piOperacion", nOperacion);
            oComando.Parameters.AddWithValue("@piContrato", nOperacion);
            oComando.Parameters.AddWithValue("@psRespuesta", "");

            if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                oComando.Parameters.AddWithValue("@piProducto", nProducto);                
                oComando.Parameters.AddWithValue("@pbEsOperacion", 1);
           
            }
            else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
            {              
                oComando.Parameters.AddWithValue("@piProducto", DBNull.Value);
                oComando.Parameters.AddWithValue("@pbEsOperacion", 0);
          
            }         

            //Abre la conexion
            oConexion.Open();
            oDataAdapter.SelectCommand = oComando;
            oDataAdapter.SelectCommand.Connection = oConexion;
            oDataAdapter.Fill(dsDatos, "Datos");

            if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
            {
                foreach (DataRow fila in dsDatos.Tables[0].Rows)
                {
                    LinkButton enlaceNuevo = new LinkButton();
                    enlaceNuevo.ID = fila["cod_garantia"].ToString();              
                    enlaceNuevo.Text = fila["cod_garantia"].ToString();
                    enlaceNuevo.Attributes.Add("runat", "Server");
                    enlaceNuevo.CommandName = fila["cod_tipo_garantia"].ToString();
                    enlaceNuevo.CommandArgument = fila["cod_garantia"].ToString();

                    listadoEnlaces.Add(enlaceNuevo);
                }

                GenerarTablaEnlaces(listadoEnlaces);
            }
            else
            {
                lblMensaje2.Text = "No existen garantías relacionadas a los datos suministrados.";
                btnGenerarConsulta.Enabled = false;
                btnLimpiar.Enabled = false;
            }
        }

        if (listadoEnlaces.Count > 0)
        {
            Session["listaEnlaces"] = listadoEnlaces;
        }
        else
        {
            Session["listaEnlaces"] = null;
        }

    }


    /// <summary>
    /// Este método permite limpiar los campos del formulario
    /// </summary>
    private void LimpiarCampos()
    {
        try
        {
            txtContabilidad.Text = "";
            txtMoneda.Text = "";
            txtOficina.Text = "";
            txtOperacion.Text = "";
            txtProducto.Text = "";
            lblMensaje.Text = "";
            lblMensaje3.Text = "";
            lblMensaje2.Text = "";

            chkTodasOperaciones.Checked = false;
            chkTodosContratos.Checked = false;
            txtFechaFinal.Text = string.Empty;
            txtFechaInicial.Text = string.Empty;

            gdvCambioGarantia.DataSource = null;
            gdvCambioGarantia.DataBind();            

            contenedorTabla.Controls.Clear();
            contenedorGarantiaFiduciaria.Controls.Clear();
            contenedorGarantiaValor.Controls.Clear();
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }
    }

    private void LimpiarCamposConsultaIndividual()
    {
        try
        {
            txtContabilidad.Text = "";
            txtMoneda.Text = "";
            txtOficina.Text = "";
            txtOperacion.Text = "";
            txtProducto.Text = "";
            lblMensaje.Text = "";
            lblMensaje3.Text = "";
            lblMensaje2.Text = "";
            lblDeudor.Text = string.Empty;
            lblNombreDeudor.Text = string.Empty;

            cbTipoCaptacion.SelectedIndex = 0;
            txtProducto.Visible = true;
            lblProducto.Visible = true;

            gdvCambioGarantia.DataSource = null;
            gdvCambioGarantia.DataBind();
            btnGenerarConsulta.Enabled = false;
            btnLimpiar.Enabled = false;

            contenedorTabla.Controls.Clear();
            contenedorGarantiaFiduciaria.Controls.Clear();
            contenedorGarantiaValor.Controls.Clear();
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }
    }

    private void LimpiarCamposConsultaMasiva()
    {
        try
        {
            txtFechaFinal.Text = string.Empty;
            txtFechaInicial.Text = string.Empty;

        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }
    }

    private void EliminarDatosGlobales()
    {

        if (Session[LLAVE_CONSECUTIVO_OPERACION] != null)
        {
            Session.Remove(LLAVE_CONSECUTIVO_OPERACION);
        }

        if (Session[LLAVE_DATOS_OPERACION] != null)
        {
            Session.Remove(LLAVE_DATOS_OPERACION);
        }

        if (Session[LLAVE_ES_GIRO] != null)
        {
            Session.Remove(LLAVE_ES_GIRO);
        }

        if (Session[LLAVE_CONSECUTIVO_CONTRATO] != null)
        {
            Session.Remove(LLAVE_CONSECUTIVO_CONTRATO);
        }

        if (Session["Accion"] != null)
        {
            Session.Remove("Accion");
        }

        if (Session["EsOperacionValidaReal"] != null)
        {
            Session.Remove("EsOperacionValidaReal");
        }

        if (Session["EsOperacionValida"] != null)
        {
            Session.Remove("EsOperacionValida");
        }

        if (Session["Nombre_Deudor"] != null)
        {
            Session.Remove("Nombre_Deudor");
        }

        if (Session["Tipo_Operacion"] != null)
        {
            Session.Remove("Tipo_Operacion");
        }

        if (Session["Operacion"] != null)
        {
            Session.Remove("Operacion");
        }

        if (Session["Deudor"] != null)
        {
            Session.Remove("Deudor");
        }

        if (Session["GarantiaReal"] != null)
        {
            Session.Remove("GarantiaReal");
        }

        if (Session["EsCambioTipoGarantia"] != null)
        {
            Session.Remove("EsCambioTipoGarantia");
        }

        gdvCambioGarantia.DataSource = null;
        gdvCambioGarantia.DataBind();

        lblMensaje.Text = "";
        lblMensaje3.Text = "";
        lblMensaje2.Text = "";

       

        contenedorTabla.Controls.Clear();
        contenedorGarantiaFiduciaria.Controls.Clear();
        contenedorGarantiaValor.Controls.Clear();
    }

    private void DeshabilitarCamposConsultaMasiva() 
    {
        btnGenerarConsultaMasiva.Enabled = false;
        txtFechaInicial.Enabled = false;
        txtFechaFinal.Enabled = false;
        igbCalendarioInicial.Enabled = false;
        igbCalendarioFinal.Enabled = false;
    }

    private void HabilitarCamposConsultaMasiva()
    {
        btnGenerarConsultaMasiva.Enabled = true;
        txtFechaInicial.Enabled = true;
        txtFechaFinal.Enabled = true;
        igbCalendarioInicial.Enabled = true;
        igbCalendarioFinal.Enabled = true;
    }

 
    #endregion








}//fin
