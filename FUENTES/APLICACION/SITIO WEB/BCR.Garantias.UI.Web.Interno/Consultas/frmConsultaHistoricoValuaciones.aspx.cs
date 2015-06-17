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
using System.Data.OleDb;
using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;
using System.Diagnostics;
using System.Data.SqlClient;
using System.Web.UI.MobileControls;
using System.Collections.Generic;

[Serializable]
public partial class Consultas_frmConsultaHistoricoValuaciones : BCR.Web.SystemFramework.PaginaPersistente
{
    #region constantes

    private const string LLAVE_CONSECUTIVO_OPERACION = "LLAVE_CONSECUTIVO_OPERACION";
    private const string LLAVE_DATOS_OPERACION = "LLAVE_DATOS_OPERACION";
    private const string LLAVE_ES_GIRO = "LLAVE_ES_GIRO";
    private const string LLAVE_CONSECUTIVO_CONTRATO = "LLAVE_CONSECUTIVO_CONTRATO";


    #endregion

    #region Variables Globales

    protected System.Data.OleDb.OleDbConnection oleDbConnection1;
    private string _contratoDelGiro = string.Empty;

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

         if (!IsPostBack)
         {
             Session["Tipo_Operacion"] = int.Parse(Application["OPERACION_CREDITICIA"].ToString());
             this.Session.Add("listaEnlaces", null);

             try
             {
                 if (!Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CONSULTA_HST_AVALUOS"].ToString())))
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

        //if (Session["listaValuacionesReales"] != null)
        //{
        //     GenerarTablaDetalleHistorico(()Session["listaValuacionesReales"]);
        //}
    }

   #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
    }

    protected void btnValidarOperacion_Click(object sender, EventArgs e)
    {
        int nProducto = -1;
        string numeroOperacion = string.Empty;

        EliminarDatosGlobales();
        Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
        this.ViewState["enlaceSeleccionado"] = null;

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
                        gdvValuacionesHistoricas.DataSource = null;
                        gdvValuacionesHistoricas.DataBind();

                        lblMensaje.Text = "";
                        lblMensaje3.Text = "";
                        lblMensaje2.Text = "";

                        tblDetalleInfo.Visible = false;

                        contenedorTabla.Controls.Clear();

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

                    gdvValuacionesHistoricas.DataSource = null;
                    gdvValuacionesHistoricas.DataBind();

                    lblMensaje3.Text = "";
                    lblMensaje2.Text = "";

                    tblDetalleInfo.Visible = false;

                    contenedorTabla.Controls.Clear();
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
        System.Data.DataSet dsDatos = new System.Data.DataSet();
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
        lblMensaje.Text = "";
        lblMensaje3.Text = "";
        lblMensaje2.Text = "";
        gdvValuacionesHistoricas.DataSource = null;
        gdvValuacionesHistoricas.DataBind();
        tblDetalleInfo.Visible = false;

        try
        {
            int nCodOperacion = Int32.Parse(e.CommandArgument.ToString());
            int catalogoRP = Int16.Parse(Application["CAT_RECOMENDACION_PERITO"].ToString());
            int catalogoIMT  = Int16.Parse(Application["CAT_INSPECCION_3_MESES"].ToString());
            string codigoBien = ((LinkButton)sender).Text;

            //((LinkButton)sender).ForeColor = System.Drawing.Color.Red;
            idEnlaceSeleccionado = ((LinkButton)sender).ID;
            ViewState.Add("enlaceSeleccionado", idEnlaceSeleccionado);

            GenerarTablaEnlaces((List<LinkButton>)Session["listaEnlaces"]);

       
            clsValuacionesReales<clsValuacionReal> listaValuacionesReales =
                            Gestor.Obtener_Avaluos(nCodOperacion, codigoBien, false, catalogoRP, catalogoIMT);

            if (listaValuacionesReales != null)
            {
                dsDatos = listaValuacionesReales.toDataSet();

                #region Ordena el grid de valuaciones historicas por una columna especifica

                    DataView dtvValuacionesHistoricasOrdenado = new DataView();
                    dtvValuacionesHistoricasOrdenado.Table = dsDatos.Tables[0];
                    dtvValuacionesHistoricasOrdenado.Sort = "fecha_valuacion Desc";
                    DataTable dtOrdenado = dtvValuacionesHistoricasOrdenado.ToTable();

                    dsDatos = new DataSet();
                    dsDatos.Tables.Add(dtOrdenado);

                #endregion
            }
            else
            {
                lblMensaje3.Text = "No existen valuaciones históricas de la garantía seleccionada.";
            }

            if ((dsDatos != null) && (dsDatos.Tables.Count > 0))
            {
                gdvValuacionesHistoricas.DataSource = dsDatos;
                gdvValuacionesHistoricas.DataBind();
            }
            else
            {
                lblMensaje3.Text = "No existen valuaciones históricas de la garantía seleccionada.";
            }

        }//fin del try
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(ex.Message, EventLogEntryType.Error);
            lblMensaje3.Text = "Ha ocurrido un error en la consulta de valuaciones históricas o No existen valuaciones históricas de la garantía seleccionada.";
        }//fin del cath
    }//fin del metodo enlaceNuevo_Click

    protected void gdvValuacionesHistoricas_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {

    }//fin del metodo gdvValuacionesHistoricas_PageIndexChanging

    protected void gdvValuacionesHistoricas_RowCommand(object sender, GridViewCommandEventArgs e)
    {
            GridView gdvValuacionesHistorica = (GridView)sender;
            int rowIndex = 0;
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedValuacionesHistoricas"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvValuacionesHistorica.SelectedIndex = rowIndex;

                        try
                        {
                            if (gdvValuacionesHistorica.SelectedDataKey[0].ToString() != null)
                            {
                                DateTime dFechaValuacion = Convert.ToDateTime(gdvValuacionesHistorica.SelectedDataKey[0].ToString());
                                if (dFechaValuacion.ToShortDateString().CompareTo("01/01/1900") != 0)
                                {
                                    lblFechaValuacion.Text = dFechaValuacion.ToShortDateString();
                                }
                                else 
                                {
                                    lblFechaValuacion.Text = "-";
                                }
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[1].ToString() != null && Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[1].ToString()) != 0)
                            {
                                decimal nMontoUltTasacionActualizadaTerreno = Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[1].ToString());
                                lblTasacionActualizadaTerreno.Text = nMontoUltTasacionActualizadaTerreno.ToString("N");
                            }
                            else 
                            {
                                lblTasacionActualizadaTerreno.Text = "00.00";
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[2].ToString() != null && Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[2].ToString()) != 0)
                            {
                                decimal nMontoUltTasacionActualizadaNoTerreno = Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[2].ToString());
                                lblTasacionActualizadaNoTerreno.Text = nMontoUltTasacionActualizadaNoTerreno.ToString("N");
                            }
                            else
                            {
                                lblTasacionActualizadaNoTerreno.Text = "00.00";
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[4].ToString() != null)
                            {
                                lblCedulaPeritoEmpresa.Text = gdvValuacionesHistorica.SelectedDataKey[4].ToString() + " - " + gdvValuacionesHistorica.SelectedDataKey[10].ToString();
                            }
                            else 
                            {
                                lblCedulaPeritoEmpresa.Text = gdvValuacionesHistorica.SelectedDataKey[5].ToString() + " - " + gdvValuacionesHistorica.SelectedDataKey[11].ToString();
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[6].ToString() != null && Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[6].ToString()) != 0)
                            {
                                decimal nMontoUltTasacionTerreno = Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[6].ToString());
                                lblUltimaTasacionTerreno.Text = nMontoUltTasacionTerreno.ToString("N");
                            }
                            else
                            {
                                lblUltimaTasacionTerreno.Text = "00.00";
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[7].ToString() != null && Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[7].ToString()) != 0)
                            {
                                decimal nMontoUltTasacionNoTerreno = Convert.ToDecimal(gdvValuacionesHistorica.SelectedDataKey[7].ToString());
                                lblUltimaTasacionNoTerreno.Text = nMontoUltTasacionNoTerreno.ToString("N");
                            }
                            else
                            {
                                lblUltimaTasacionNoTerreno.Text = "00.00";
                            }

                            if (gdvValuacionesHistorica.SelectedDataKey[8].ToString() != null)
                            {
                                DateTime dFechaUltimoSeguimient = Convert.ToDateTime(gdvValuacionesHistorica.SelectedDataKey[8].ToString());
                                if (dFechaUltimoSeguimient.ToShortDateString().CompareTo("01/01/1900") != 0)
                                {
                                    lblFechaUltimoSeguimiento.Text = dFechaUltimoSeguimient.ToShortDateString();   
                                    
                                }
                                else
                                {
                                    lblFechaUltimoSeguimiento.Text = "-";                            
                                }
                            }
                            if (gdvValuacionesHistorica.SelectedDataKey[9].ToString() != null)
                            {
                                DateTime dFechaConstruccion = Convert.ToDateTime(gdvValuacionesHistorica.SelectedDataKey[9].ToString());
                                if (dFechaConstruccion.ToShortDateString().CompareTo("01/01/1900") != 0)
                                {
                                    lblFechaConstruccion.Text = dFechaConstruccion.ToShortDateString();
                                }
                                else
                                {
                                    lblFechaConstruccion.Text = "-";
                                    
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, "", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                            throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, "", Mensajes.ASSEMBLY)));
                        }

                        break;
                }

                tblDetalleInfo.Visible = true;
            }
            catch (Exception ex)
            {
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, "", ex.Message, Mensajes.ASSEMBLY), System.Diagnostics.EventLogEntryType.Error);
                throw new ExcepcionBase((Mensajes.Obtener(Mensajes.ERROR_OBTENIENDO_DATOS_AVALUO, "", Mensajes.ASSEMBLY)));
            }
    }//fin del metodo gdvValuacionesHistoricas_RowCommand

    protected void gdvValuacionesHistoricas_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        /*double monto_tasacion_actualizada_terreno = 00.00;
        double monto_tasacion_actualizada_no_terreno = 00.00;

        double sumaTotal;

        if(e.Row.RowIndex >= 0 )
        {
            monto_tasacion_actualizada_terreno = Double.Parse(e.Row.Cells[1].Text);

            monto_tasacion_actualizada_no_terreno = Double.Parse(e.Row.Cells[2].Text);
        }

        sumaTotal = monto_tasacion_actualizada_terreno + monto_tasacion_actualizada_no_terreno;

        e.Row.Cells[3].Text = sumaTotal.ToString();*/

    }//fin del metodo gdvValuacionesHistoricas_RowDataBound
    
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
            tblDetalleInfo.Visible = false;
            contenedorTabla.Controls.Clear();
            gdvValuacionesHistoricas.DataSource = null;
            gdvValuacionesHistoricas.DataBind();

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

    private void GenerarListadoGarantias(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
    {
        List<LinkButton> listadoEnlaces = new List<LinkButton>();

        System.Data.DataSet dsDatos = new System.Data.DataSet();
        ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

        using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
        {
            SqlCommand oComando = null;

            if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                oComando = new SqlCommand("pa_ObtenerGarantiasRealesOperaciones", oConexion);
            else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
                oComando = new SqlCommand("pa_ObtenerGarantiasRealesContratos", oConexion);

            SqlDataAdapter oDataAdapter = new SqlDataAdapter();

            //declara las propiedades del comando
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.CommandTimeout = 120;
            oComando.Parameters.AddWithValue("@nCodOperacion", nCodOperacion);
            oComando.Parameters.AddWithValue("@nContabilidad", nContabilidad);
            oComando.Parameters.AddWithValue("@nOficina", nOficina);
            oComando.Parameters.AddWithValue("@nMoneda", nMoneda);

            if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                oComando.Parameters.AddWithValue("@nProducto", nProducto);
                oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
            }
            else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
            {
                oComando.Parameters.AddWithValue("@nContrato", nOperacion);
            }

            oComando.Parameters.AddWithValue("@IDUsuario", Global.UsuarioSistema);


            //Abre la conexion
            oConexion.Open();
            oDataAdapter.SelectCommand = oComando;
            oDataAdapter.SelectCommand.Connection = oConexion;
            oDataAdapter.Fill(dsDatos, "Datos");

            if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
            {
                foreach(DataRow fila in dsDatos.Tables[0].Rows)
                {
                    LinkButton enlaceNuevo = new LinkButton();
                    enlaceNuevo.ID = fila["cod_garantia_real"].ToString();
                    enlaceNuevo.Text = fila["cod_garantias_listado"].ToString();
                    enlaceNuevo.Attributes.Add("runat", "Server");
                    enlaceNuevo.CommandName = fila["cod_garantia_real"].ToString();
                    enlaceNuevo.CommandArgument = fila["cod_garantia_real"].ToString();
                    enlaceNuevo.ToolTip = "Grado: " + fila["cod_grado"].ToString() + " - Cédula Hipotecaria " + fila["cedula_hipotecaria"].ToString();

                    listadoEnlaces.Add(enlaceNuevo);
                  }

                GenerarTablaEnlaces(listadoEnlaces);
            }
            else
            {
                lblMensaje2.Text = "No existen garantías relacionadas a los datos suministrados.";
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
    /// Este método permite generar una tabla con los enlaces generados de acuerdo a los datos de consulta emitidos por el
    /// usuario.
    /// </summary>
    private void GenerarTablaEnlaces(List<LinkButton> listadoEnlacesGarantias) 
    {
        string enlaceSeleccionado = "";
        int contadorColumnas = 0;

        HtmlTable tablaEnlaces = new HtmlTable();
        HtmlTableRow nuevaFila = new HtmlTableRow();

        contenedorTabla.Controls.Clear();
        contenedorTabla.Controls.Add(tablaEnlaces);

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

            HtmlTableCell nuevaCelda = new HtmlTableCell();
            HtmlTableCell celdaEspacio = new HtmlTableCell();
            celdaEspacio.Width = "12x";
            celdaEspacio.InnerHtml = "&nbsp;&nbsp;/&nbsp;&nbsp;";

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
            nuevaCelda.Controls.Add(button);
            nuevaFila.Cells.Add(nuevaCelda);
            nuevaFila.Cells.Add(celdaEspacio);
            nuevaFila.Cells.Add(celdaEspacio);
            tablaEnlaces.Rows.Add(nuevaFila);

            contadorColumnas++;
        }

        contenedorTabla.Controls.Add(tablaEnlaces);
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

            gdvValuacionesHistoricas.DataSource = null;
            gdvValuacionesHistoricas.DataBind();

            tblDetalleInfo.Visible = false;

            contenedorTabla.Controls.Clear();
        }
        catch (Exception ex)
        {
            Utilitarios.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS_DETALLE, "LimpiarCampos", ex.Message, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_SETEANDO_CAMPOS, Mensajes.ASSEMBLY);
        }
    }

    /// <summary>
    /// Se encarga de eliminar las variables de sesión propias de la validación de cada operación y garantía,
    /// así mismo de los atributos agregados a controles o al ViewState de la página,
    /// </summary>
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

        gdvValuacionesHistoricas.DataSource = null;
        gdvValuacionesHistoricas.DataBind();

        lblMensaje.Text = "";
        lblMensaje3.Text = "";
        lblMensaje2.Text = "";

        tblDetalleInfo.Visible = false;

        contenedorTabla.Controls.Clear();
    }


  #endregion
}
  