using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Configuration;
using System.Data.OleDb;

using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using ProcesamientoMQ2003;
using BCRGARANTIAS.Presentacion;
using BCR.GARANTIAS.Comun;


namespace BCRGARANTIAS.Forms
{
    public partial class frmGarantiasFiduciaria : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string LLAVE_CONSECUTIVO_OPERACION        = "LLAVE_CONSECUTIVO_OPERACION";
        private const string LLAVE_CONSECUTIVO_GARANTIA         = "LLAVE_CONSECUTIVO_GARANTIA";
        private const string LLAVE_ES_GIRO                      = "LLAVE_ES_GIRO";
        private const string LLAVE_CONSECUTIVO_CONTRATO         = "LLAVE_CONSECUTIVO_CONTRATO";
        private const string _llaveContratoGiro                 = "_llaveContratoGiro";
        private const string LLAVE_FECHA_REPLICA                = "LLAVE_FECHA_REPLICA";
        private const string LLAVE_FECHA_MODIFICACION           = "LLAVE_FECHA_MODIFICACION";

        #endregion Constantes

        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.DropDownList cbTipoEmpresa;
        protected System.Web.UI.WebControls.TextBox txtEmpresa;
        protected System.Web.UI.WebControls.DropDownList cbMoneda;
        protected System.Web.UI.WebControls.DropDownList cbLiquidez;
        protected System.Web.UI.WebControls.DropDownList cbRecomendacion;
        protected System.Web.UI.WebControls.DropDownList cbInspección;
        protected mtpMenuPrincipal oPagina = new mtpMenuPrincipal();

        private string _contratoDelGiro = string.Empty;

        #endregion

        #region Propiedades

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
        /// Se guarda en sesión el consecutivo de la garantía seleccionada
        /// </summary>
        public long ConsecutivoGarantia
        {
            get
            {
                return ((Session[LLAVE_CONSECUTIVO_GARANTIA] != null) ? long.Parse(Session[LLAVE_CONSECUTIVO_GARANTIA].ToString()) : -1);
            }

            set
            {
                Session[LLAVE_CONSECUTIVO_GARANTIA] = value.ToString();
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

        #endregion Propiedades

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnBuscarFiador.Click += new ImageClickEventHandler(btnBuscarFiador_Click);
            btnIngresos.Click += new EventHandler(btnIngresos_Click);
            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnValidarOperacion.Click += new EventHandler(btnValidarOperacion_Click);
            btnValidarTarjeta.Click += new EventHandler(btnValidarTarjeta_Click);
            cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtProducto.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtCedulaFiador.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtAcreedor.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtTarjeta.Attributes["onblur"] = "javascript:EsNumerico(this);";

            btnInsertar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea insertar esta garantía?')";
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la garantía seleccionada?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la garantía seleccionada?')";
            
            btnIngresos.Enabled = true;


            txtMontoMitigador.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoMitigador.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtPorcentajeResponsabilidad.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeResponsabilidad.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

            txtMontoCobertura.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoCobertura.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtObservacion.Visible = false;
            lblObservacion.Visible = false;

            contenedorDatosModificacion.Visible = false;
          

            if (!IsPostBack)
            {
                try
                {
                    int nProducto = -1;

                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIA_FIDUCIARIA"].ToString())))
                    {
                        CargarCombos();
                        Session["EsOperacionValidaReal"] = false;
                        Session["EsOperacionValidaValor"] = false;

                        if ((Session["EsOperacionValida"] != null) && (bool.Parse(Session["EsOperacionValida"].ToString())))
                        {
                            if ((Session["Accion"] != null) &&
                                ((Session["Accion"].ToString() == "INSERTAR") ||
                                (Session["Accion"].ToString() == "MODIFICAR") ||
                                (Session["Accion"].ToString() == "ELIMINAR")))
                            {
                                CargarCombos();
                                LimpiarCampos();
                                MostrarLlave();
                                BloquearCampos(true);
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                btnBuscarFiador.Visible = false;
                                txtFechaExpiracion.Enabled = true;
                                txtFechaExpiracion.ReadOnly = false;
                                btnIngresos.Enabled = true;

                                contenedorDatosModificacion.Visible = false;
                                contenedorDatosModificacion.Controls.Clear();

								if (Session["Accion"].ToString() == "INSERTAR")
								{
									btnBuscarFiador.Visible = true;
								}


                                if (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString())
                                {
                                    txtObservacion.Visible = true;
                                    lblObservacion.Visible = true;
                                }

                                this.btnLimpiar_Click(this.btnLimpiar, new EventArgs());

                            }
                            else if ((Session["Accion"] != null) &&
                                     ((Session["Accion"].ToString() == "DEUDOR_MOD") ||
                                     (Session["Accion"].ToString() == "FIADOR_MOD")))
                            {
                                BloquearCampos(true);
                                CargarDatosSession();
                                btnInsertar.Enabled = false;
                                btnModificar.Enabled = true;
                                btnEliminar.Enabled = true;
                                btnIngresos.Enabled = true;

                                if ((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString()))
                                {
                                    MostrarLlave();
                                    txtFechaExpiracion.Enabled = true;
                                    txtObservacion.Visible = true;
                                    lblObservacion.Visible = true;
                                }
                            }
                            else if ((Session["Accion"] == null) || (Session["Accion"].ToString().Length == 0))
                            {
                                btnIngresos.Enabled = false;
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                BloquearCampos(bool.Parse(Session["EsOperacionValida"].ToString()));

                                if ((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString()))
                                {
                                    MostrarLlave();
                                    btnIngresos.Enabled = true;
                                    btnInsertar.Enabled = true;
                                    btnModificar.Enabled = false;
                                    btnEliminar.Enabled = false;
                                    btnBuscarFiador.Visible = true;
                                    txtFechaExpiracion.Enabled = true;
                                    txtFechaExpiracion.ReadOnly = false;
                                    string strFechaExpiracion = (DateTime.Today.Year + 30).ToString() + "/" + DateTime.Today.Month.ToString() + "/" + DateTime.Today.Day.ToString();
                                    txtFechaExpiracion.Text = DateTime.Parse(strFechaExpiracion).ToShortDateString();
                                    txtObservacion.Visible = true;
                                    lblObservacion.Visible = true;
                                }
                            }

                            lblDeudor.Visible = true;
                            lblNombreDeudor.Visible = true;
                            lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();

                            if ((Session["Tipo_Operacion"] != null) && (int.Parse(Session["Tipo_Operacion"].ToString()) != int.Parse(Application["TARJETA"].ToString())))
                            {
                                if (txtProducto.Text.Length != 0)
                                    nProducto = int.Parse(txtProducto.Text);

                                CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                                    ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                                    int.Parse(txtContabilidad.Text),
                                                    int.Parse(txtOficina.Text),
                                                    int.Parse(txtMoneda.Text),
                                                    nProducto,
                                                    long.Parse(txtOperacion.Text));
                            }
                            else
                            {
                                if (Session["ValidarTarjeta"] != null)
                                {
                                    txtTarjeta.Text = Session["ValidarTarjeta"].ToString().Trim();
                                    this.btnValidarTarjeta_Click(this.btnValidarTarjeta, new EventArgs());
                                    Session.Remove("ValidarTarjeta");
                                }

                                CargarGridTarjetas();
                            }

                        }
                        else
                        {
                            cbTipoCaptacion.SelectedIndex = 0;
                            this.cbTipoCaptacion_SelectedIndexChanged(cbTipoCaptacion, new EventArgs());
                        }
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

            if ((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString()))
            {
                txtObservacion.Visible = true;
                lblObservacion.Visible = true;
            }
        }

        private void Button1_Click(object sender, System.EventArgs e)
        {
        }

        /// <summary>
        /// Este evento permite insertar una garantía fiduciaria a una operación crediticia
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            decimal nPorcentaje;
            string strTrama = string.Empty;
            string strTramaRespuesta;
            DataSet ds = new DataSet();
            string strArchivoXMLTemporal;

            string strCodigoEstadoTarjeta = string.Empty;

            #region Obtiene el nombre de los nodos del web.config

            string nodoSistar = ConfigurationManager.AppSettings["nodoSistar"].ToString();
            string nodoCabecera = ConfigurationManager.AppSettings["nodoCabecera"].ToString();
            string nodoRespuesta = ConfigurationManager.AppSettings["nodoRespuesta"].ToString();
            string nodoTrans = ConfigurationManager.AppSettings["nodoTransaccion"].ToString();
            string nodoTipoTarjeta = ConfigurationManager.AppSettings["nodoTipoTarjeta"].ToString();
            string nodoCedula = ConfigurationManager.AppSettings["nodoCedula"].ToString();
            string nodoCuentaAfectada = ConfigurationManager.AppSettings["nodoCuentaAfectada"].ToString();
            string nodoMoneda = ConfigurationManager.AppSettings["nodoMoneda"].ToString();
            string nodoOficinaOrigen = ConfigurationManager.AppSettings["nodoOficinaOrigen"].ToString();
            string nodoDescripcion = ConfigurationManager.AppSettings["nodoDescripcion"].ToString();
            string nodoTipoGarantia = ConfigurationManager.AppSettings["nodoTipoGarantia"].ToString();
            string nodoEstadoTarjeta = ConfigurationManager.AppSettings["nodoEstadoTarjeta"].ToString();

            #endregion
            try
            {
                if (ValidarGarantiaTarjeta())
                {
                    if (txtPorcentajeResponsabilidad.Text.Trim().Length == 0)
                        nPorcentaje = 0;
                    else
                        nPorcentaje = Convert.ToDecimal(txtPorcentajeResponsabilidad.Text.Trim());

                    Session["Accion"] = "INSERTAR";
                    GuardarDatosSession();

                    bool bActualizacionSistar = false;

                    if ((Session["Plazo"] == null) || ((Session["Plazo"] != null) && (Session["Plazo"].ToString().CompareTo("01") != 0)))
                    {
                        strTrama = new BCRGARANTIAS.Negocios.CreaXML().creaXMLConsultaTarjetaSISTAR(txtTarjeta.Text, "01");

                        ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
                                                                                                        Application["Cola_Entrada"].ToString(),
                                                                                                        Application["Cola_Salida"].ToString(),
                                                                                                        strTrama,
                                                                                                        Application["Cola_Respuesta"].ToString(),
                                                                                                        Application["IP"].ToString(),
                                                                                                        Application["Channel"].ToString(),
                                                                                                        Application["Port"].ToString());

                        strTramaRespuesta = oMQ.respuestaMQ();

                        strArchivoXMLTemporal = Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\" + txtTarjeta.Text.Trim() + ".xml";

                        if (!Directory.Exists(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\"))
                        {
                            Directory.CreateDirectory(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\");
                        }

                        CrearArchivoXMLTemporal(strArchivoXMLTemporal, strTramaRespuesta);
                        ds.ReadXml(strArchivoXMLTemporal);

                        //Valida que la respuesta de MQ fuera "TRANSACCION SATISFACTORIA"
                        if (ds.Tables[nodoCabecera].Rows[0][nodoRespuesta].ToString() == "000")
                        {
                            bActualizacionSistar = true;
                        }

                        EliminarArchivoXMLTemporal(strArchivoXMLTemporal);
                    }
                    else if ((Session["Plazo"] != null) && (Session["Plazo"].ToString().CompareTo("01") == 0))
                    {
                        bActualizacionSistar = true;
                    }

                    int nMensaje = 0;

                    if (bActualizacionSistar)
                    {
                       nMensaje = Gestor.CrearGarantiaFiduciariaTarjeta(txtTarjeta.Text.Trim(),
                                                            int.Parse(Application["GARANTIA_FIDUCIARIA"].ToString()),
                                                            int.Parse(Application["CLASE_GARANTIA_FIADOR"].ToString()),
                                                            txtCedulaFiador.Text.Trim(),
                                                            int.Parse(cbTipoFiador.SelectedValue.ToString()),
                                                            txtNombreFiador.Text.Trim(),
                                                            int.Parse(cbMitigador.SelectedValue.ToString()),
                                                            int.Parse(cbTipoDocumento.SelectedValue.ToString()),
                                                            Convert.ToDecimal(txtMontoMitigador.Text),
                                                            nPorcentaje,
                                                            int.Parse(cbOperacionEspecial.SelectedValue.ToString()),
                                                            int.Parse(cbTipoAcreedor.SelectedValue.ToString()),
                                                            txtAcreedor.Text.Trim(),
                                                            DateTime.Parse(txtFechaExpiracion.Text.ToString()),
                                                            Convert.ToDecimal(txtMontoCobertura.Text),
                                                            Session["Deudor"].ToString(),
                                                            long.Parse(Session["Bin"].ToString()),
                                                            long.Parse(Session["CodigoInternoSISTAR"].ToString()),
                                                            int.Parse(Session["Moneda"].ToString()),
                                                            int.Parse(Session["Oficina_Registra"].ToString()),
                                                            Session["strUSER"].ToString(),
                                                            Request.UserHostAddress.ToString(), txtTarjeta.Text.Trim(),
                                                            txtObservacion.Text,
                                                            Convert.ToInt32(ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"].ToString()));

                       string[] mensajes = MostrarMensaje(nMensaje, 1);

                       contenedorDatosModificacion.Visible = false;
                       contenedorDatosModificacion.Controls.Clear();

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=" + mensajes[0] +
                                        "&strTitulo=" + mensajes[1] +
                                        "&strMensaje=" + mensajes[2] +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");


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
                                    "&strMensaje=" + "No se pudo insertar la garantía fiduciaria. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasFiduciaria.aspx");
                }
            }
        }

        /// <summary>
        /// Este evento permite limpiar el formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                LimpiarCampos();
                CargarCombos();
                BloquearCampos(true);
                btnIngresos.Enabled = false;
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                lblMensaje.Text = string.Empty;
                lblMensaje3.Text = string.Empty;

                contenedorDatosModificacion.Visible = false;
                contenedorDatosModificacion.Controls.Clear();

                if (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString())
                {
                    txtObservacion.Visible = true;
                    lblObservacion.Visible = true;
                    txtCedulaFiador.Enabled = true;
                    btnBuscarFiador.Visible = true;
                    txtFechaExpiracion.Enabled = true;
                    txtFechaExpiracion.ReadOnly = false;
                    txtMontoCobertura.Enabled = true;

                    CargarValoresXDefecto();
                }
                else
                {
                    txtObservacion.Visible = false;
                    lblObservacion.Visible = false;
                }


            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este evento permite modificar la información de una garantía fiduciaria
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            decimal nPorcentaje;

            try
            {
                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) != int.Parse(Application["TARJETA"].ToString()))
                {
                    if (ValidarDatos())
                    {
                        Session["Accion"] = "MODIFICAR";

                        if (txtPorcentajeResponsabilidad.Text.Trim().Length == 0)
                            nPorcentaje = 0;
                        else
                            nPorcentaje = Convert.ToDecimal(txtPorcentajeResponsabilidad.Text);

                        //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                      //  string strOperacionCrediticia = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text;

                        string strOperacionCrediticia = (txtContabilidad.Text.StartsWith("0") ? txtContabilidad.Text.Remove(0, 1) : txtContabilidad.Text) + "-" + 
                                                         txtOficina.Text + "-" +
                                                        (txtMoneda.Text.StartsWith("0") ? txtMoneda.Text.Remove(0, 1) : txtMoneda.Text);

                        if (txtProducto.Visible)
                        {
                            //strOperacionCrediticia += "-" + txtProducto.Text;
                            strOperacionCrediticia += "-" + (txtProducto.Text.StartsWith("0") ? txtProducto.Text.Remove(0, 1) : txtProducto.Text);

                        }

                        strOperacionCrediticia += "-" + txtOperacion.Text;


                        GuardarDatosSession();
                        Gestor.ModificarGarantiaFiduciaria(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                            ConsecutivoOperacion,
                                                            txtCedulaFiador.Text.Trim(),
                                                            int.Parse(cbTipoFiador.SelectedValue.ToString()),
                                                            txtNombreFiador.Text.Trim(),
                                                            int.Parse(cbMitigador.SelectedValue.ToString()),
                                                            int.Parse(cbTipoDocumento.SelectedValue.ToString()),
                                                            Convert.ToDecimal(txtMontoMitigador.Text),
                                                            nPorcentaje,
                                                            int.Parse(cbOperacionEspecial.SelectedValue.ToString()),
                                                            int.Parse(cbTipoAcreedor.SelectedValue.ToString()),
                                                            txtAcreedor.Text.Trim(),
                                                            Session["strUSER"].ToString(),
                                                            Request.UserHostAddress.ToString(),
                                                            strOperacionCrediticia);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Modificación Exitosa" +
                                        "&strMensaje=" + "La información de la garantía fiduciaria se modificó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
                else
                {
                    if (ValidarGarantiaTarjeta())
                    {
                        Session["Accion"] = "MODIFICAR";

                        if (txtPorcentajeResponsabilidad.Text.Trim().Length == 0)
                            nPorcentaje = 0;
                        else
                            nPorcentaje = Convert.ToDecimal(txtPorcentajeResponsabilidad.Text);

                        GuardarDatosSession();
                        Gestor.ModificarGarantiaFiduciariaTarjeta(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                                long.Parse(Session["CodigoTarjeta"].ToString()),
                                                                txtCedulaFiador.Text.Trim(),
                                                                int.Parse(cbTipoFiador.SelectedValue.ToString()),
                                                                txtNombreFiador.Text.Trim(),
                                                                int.Parse(cbMitigador.SelectedValue.ToString()),
                                                                int.Parse(cbTipoDocumento.SelectedValue.ToString()),
                                                                Convert.ToDecimal(txtMontoMitigador.Text),
                                                                nPorcentaje,
                                                                int.Parse(cbOperacionEspecial.SelectedValue.ToString()),
                                                                int.Parse(cbTipoAcreedor.SelectedValue.ToString()),
                                                                txtAcreedor.Text.Trim(),
                                                                DateTime.Parse(txtFechaExpiracion.Text.ToString()),
                                                                Convert.ToDecimal(txtMontoCobertura.Text),
                                                                Session["strUSER"].ToString(),
                                                                Request.UserHostAddress.ToString(),
                                                                txtTarjeta.Text, txtObservacion.Text);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Modificación Exitosa" +
                                        "&strMensaje=" + "La información de la garantía fiduciaria se modificó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la información de la garantía fiduciaria. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasFiduciaria.aspx");
                }
            }
        }

        /// <summary>
        /// Este evento permite eliminar una garantía fiduciaria del sistema
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) != int.Parse(Application["TARJETA"].ToString()))
            {
                try
                {
                    //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                   // string strOperacionCrediticia = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text;

                    string strOperacionCrediticia = (txtContabilidad.Text.StartsWith("0") ? txtContabilidad.Text.Remove(0, 1) : txtContabilidad.Text) + "-" + 
                                                    txtOficina.Text + "-" +
                                                    (txtMoneda.Text.StartsWith("0") ? txtMoneda.Text.Remove(0, 1) : txtMoneda.Text);

                    if (txtProducto.Visible)
                    {
                       // strOperacionCrediticia += "-" + txtProducto.Text;
                        strOperacionCrediticia += "-" + (txtProducto.Text.StartsWith("0") ? txtProducto.Text.Remove(0, 1) : txtProducto.Text);

                    }

                    strOperacionCrediticia += "-" + txtOperacion.Text;

                    Session["Accion"] = "ELIMINAR";
                    GuardarDatosSession();
                    Gestor.EliminarGarantiaFiduciaria(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                    ConsecutivoOperacion,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString(), strOperacionCrediticia);

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La garantía fiduciaria se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasFiduciaria.aspx");
                }
                catch (Exception ex)
                {
                    if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                    {
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Eliminando Registro" +
                                        "&strMensaje=" + "No se pudo eliminar la garantía fiduciaria." + "\r" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }
            else
            {
                try
                {
                    Session["Accion"] = "ELIMINAR";
                    GuardarDatosSession();
                    Gestor.EliminarGarantiaFiduciariaTarjeta(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                            long.Parse(Session["CodigoTarjeta"].ToString()),
                                                            Session["strUSER"].ToString(),
                                                            Request.UserHostAddress.ToString(), txtTarjeta.Text);

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La garantía fiduciaria se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasFiduciaria.aspx");
                }
                catch (Exception ex)
                {
                    if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                    {
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Eliminando Registro" +
                                        "&strMensaje=" + "No se pudo eliminar la garantía fiduciaria." + "\r" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }
            contenedorDatosModificacion.Visible = false;
            contenedorDatosModificacion.Controls.Clear();

        }

        /// <summary>
        /// Este evento permite validar la cédula del fiador
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnBuscarFiador_Click(object sender, System.Web.UI.ImageClickEventArgs e)
        {
            try
            {
                if (txtCedulaFiador.Text.Trim().Length > 0)
                {
                    System.Data.DataSet dsDatos = new System.Data.DataSet();
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("select distinct bsmcl_sno_clien from gar_sicc_bsmcl where bsmcl_sco_ident = '" + txtCedulaFiador.Text.Trim() + "' and bsmcl_estado = 'A'", oleDbConnection1);
                    cmdConsulta.Fill(dsDatos, "Fiador");
                    if (dsDatos.Tables["Fiador"].Rows.Count > 0)
                    {
                        lblMensaje3.Text = "";
                        txtNombreFiador.Text = dsDatos.Tables["Fiador"].Rows[0][0].ToString();
                    }
                    else
                    {
                        lblMensaje3.Text = "Fiador no existe como cliente del Banco";
                        txtNombreFiador.Text = "";
                    }
                }
                else
                {
                    lblMensaje3.Text = "Debe ingresar el número de cédula del fiador";
                    txtNombreFiador.Text = "";
                }
            }
            catch (Exception ex)
            {
                lblMensaje3.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este evento permite verificar si la información de la operación es valida
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarOperacion_Click(object sender, System.EventArgs e)
        {
            try
            {
                int nProducto = -1;

                Session["Tipo_Operacion"] = cbTipoCaptacion.SelectedValue.ToString();

                if (ValidarDatosOperacion())
                {
					/*Se modifica la forma en como se validna las operaciones, esto para poder obtener la información de los contratos vencidos con giros activos*/
                                        string strProducto = (((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString().Length > 0) && (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))) ? txtProducto.Text : string.Empty);
                                        DataSet dsDatos = new DataSet();

					oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
					OleDbCommand oComando = new OleDbCommand("pa_ValidarOperaciones", oleDbConnection1);
					oComando.CommandTimeout = 120;
					oComando.CommandType = CommandType.StoredProcedure;
					oComando.Parameters.AddWithValue("@Contabilidad", txtContabilidad.Text);
					oComando.Parameters.AddWithValue("@Oficina", txtOficina.Text);
					oComando.Parameters.AddWithValue("@Moneda", txtMoneda.Text);

					if (!string.IsNullOrEmpty(strProducto))
					{
						oComando.Parameters.AddWithValue("@Producto", strProducto);
					}
					else
					{
						oComando.Parameters.AddWithValue("@Producto", DBNull.Value);
					}

					oComando.Parameters.AddWithValue("@Operacion", txtOperacion.Text);
					oComando.Parameters["@Producto"].IsNullable = true;

					OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(); 

					if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Closed))
					{
						oleDbConnection1.Open();
					}

					cmdConsulta.SelectCommand = oComando;
					cmdConsulta.SelectCommand.Connection = oleDbConnection1;
                    cmdConsulta.Fill(dsDatos, "Operacion");

                    if (dsDatos.Tables["Operacion"].Rows.Count > 0)
                    {
                        BloquearCampos(true);

                        EsGiro = (((dsDatos.Tables["Operacion"].Columns.Contains("esGiro")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("esGiro")) && (dsDatos.Tables["Operacion"].Rows[0]["esGiro"].ToString().CompareTo("1") == 0)) ? true : false);

                        ConsecutivoContrato = (((dsDatos.Tables["Operacion"].Columns.Contains("consecutivoContrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("consecutivoContrato"))) ? (long.Parse(dsDatos.Tables["Operacion"].Rows[0]["consecutivoContrato"].ToString())) : -1);

                        _contratoDelGiro = (((EsGiro) && (dsDatos.Tables["Operacion"].Columns.Contains("Contrato")) && (!dsDatos.Tables["Operacion"].Rows[0].IsNull("Contrato"))) ? (dsDatos.Tables["Operacion"].Rows[0]["Contrato"].ToString()) : string.Empty);

                        if (!EsGiro)
                        {
                            ConsecutivoOperacion = long.Parse(dsDatos.Tables["Operacion"].Rows[0]["cod_operacion"].ToString());

                        Session["Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString();

                        if (txtProducto.Text.Length != 0)
                            nProducto = int.Parse(txtProducto.Text);

                        CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
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
                        btnIngresos.Enabled = false;
                        btnModificar.Enabled = false;
                        btnEliminar.Enabled = false;
                        Session["EsOperacionValida"] = true;
                        GuardarDatosSession();
                    }
                    else
                    {
                        BloquearCampos(false);
                            btnModificar.Enabled = false;
                            btnLimpiar.Enabled = false;
                            lblDeudor.Text = string.Empty;
                            lblNombreDeudor.Text = string.Empty;
                            this.gdvGarantiasFiduciarias.DataSource = null;
                            this.gdvGarantiasFiduciarias.DataBind();

                            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorConsultaGiro, _contratoDelGiro, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        BloquearCampos(false);
                        Session["EsOperacionValida"] = false;
                        lblDeudor.Visible = false;
                        lblNombreDeudor.Visible = false;
                        Session["Nombre_Deudor"] = "";
                        if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                            lblMensaje.Text = "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
                        else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                            lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";

                        this.gdvGarantiasFiduciarias.DataSource = null;
                        this.gdvGarantiasFiduciarias.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas Cargando Página" +
                                "&strMensaje=" + ex.Message +
                                "&bBotonVisible=0");
            }
			finally
			{
				if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Open))
				{
					oleDbConnection1.Close();
				}
			}
        }

        /// <summary>
        /// Este evento permite validar el tipo de operación que se desea utilizar
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                //Campos llave
                txtOficina.Text = "";
                txtMoneda.Text = "";
                txtProducto.Text = "";
                txtOperacion.Text = "";
                txtTarjeta.Text = "";
                BloquearCampos(false);
                gdvGarantiasFiduciarias.DataSource = null;
                gdvGarantiasFiduciarias.DataBind();

                Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());

                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblTipoOperacion.Text = "Operación:";
                    btnValidarOperacion.Text = "Validar Operación";
                    btnValidarOperacion.ToolTip = "Verifica que la operación sea válida";
                    ConfigurarControles(true);
                    lblTarjeta.Visible = false;
                    txtTarjeta.Visible = false;
                    btnValidarTarjeta.Visible = false;
                    lblFechaExpiracion.Visible = false;
                    txtFechaExpiracion.Visible = false;
                    lblMontoCobertura.Visible = false;
                    txtMontoCobertura.Visible = false;
                    btnIngresos.Enabled = false;
                    btnInsertar.Visible = false;
                    btnEliminar.Visible = false;
                    lblObservacion.Visible = false;
                    txtObservacion.Text = string.Empty;
                    txtObservacion.Visible = false;
                }
                else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                {
                    lblTipoOperacion.Text = "Contrato:";
                    btnValidarOperacion.Text = "Validar Contrato";
                    btnValidarOperacion.ToolTip = "Verifica que el contrato sea válido";
                    ConfigurarControles(true);
                    lblProducto.Visible = false;
                    txtProducto.Visible = false;
                    lblTarjeta.Visible = false;
                    txtTarjeta.Visible = false;
                    btnValidarTarjeta.Visible = false;
                    lblFechaExpiracion.Visible = false;
                    txtFechaExpiracion.Visible = false;
                    lblMontoCobertura.Visible = false;
                    txtMontoCobertura.Visible = false;
                    btnIngresos.Enabled = false;
                    btnInsertar.Visible = false;
                    btnEliminar.Visible = false;
                    lblObservacion.Visible = false;
                    txtObservacion.Text = string.Empty;
                    txtObservacion.Visible = false;
                }
                else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["TARJETA"].ToString()))
                {
                    ConfigurarControles(false);
                    lblTarjeta.Visible = true;
                    txtTarjeta.Visible = true;
                    btnValidarTarjeta.Visible = true;
                    lblFechaExpiracion.Visible = true;
                    txtFechaExpiracion.Visible = true;
                    lblMontoCobertura.Visible = true;
                    txtMontoCobertura.Visible = true;
                    btnIngresos.Enabled = false;
                    btnInsertar.Visible = true;
                    btnEliminar.Visible = true;
                    btnModificar.Enabled = false;
                    btnEliminar.Enabled = false;
                    string strFechaExpiracion = (DateTime.Today.Year + 30).ToString() + "/" + DateTime.Today.Month.ToString() + "/" + DateTime.Today.Day.ToString();
                    txtFechaExpiracion.Text = DateTime.Parse(strFechaExpiracion).ToShortDateString();
                    lblObservacion.Visible = true;
                    txtObservacion.Text = string.Empty;
                    txtObservacion.Visible = true;
                }
                lblDeudor.Visible = false;
                lblNombreDeudor.Visible = false;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnIngresos_Click(object sender, System.EventArgs e)
        {
            if (btnModificar.Enabled)
                Session["Accion"] = "FIADOR_MOD";
            else
                Session["Accion"] = "";

            GuardarDatosSession();
            Response.Redirect("frmValuaciones.aspx?strCedula=" + txtCedulaFiador.Text.Trim() +
                                                "&strNombre=" + txtNombreFiador.Text.Trim() +
                                                "&nGarantiaFiduciaria=" + Session["GarantiaFiduciaria"].ToString());
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarTarjeta_Click(object sender, System.EventArgs e)
        {
            string strTrama = string.Empty;
            string cedula = string.Empty;
            string strTramaRespuesta;
            DataSet ds = new DataSet();
            string strArchivoXMLTemporal;

            string strCodigoEstadoTarjeta = string.Empty;

            #region Obtiene el nombre de los nodos del web.config

            string nodoSistar = ConfigurationManager.AppSettings["nodoSistar"].ToString();
            string nodoCabecera = ConfigurationManager.AppSettings["nodoCabecera"].ToString();
            string nodoRespuesta = ConfigurationManager.AppSettings["nodoRespuesta"].ToString();
            string nodoTrans = ConfigurationManager.AppSettings["nodoTransaccion"].ToString();
            string nodoTipoTarjeta = ConfigurationManager.AppSettings["nodoTipoTarjeta"].ToString();
            string nodoCedula = ConfigurationManager.AppSettings["nodoCedula"].ToString();
            string nodoCuentaAfectada = ConfigurationManager.AppSettings["nodoCuentaAfectada"].ToString();
            string nodoMoneda = ConfigurationManager.AppSettings["nodoMoneda"].ToString();
            string nodoOficinaOrigen = ConfigurationManager.AppSettings["nodoOficinaOrigen"].ToString();
            string nodoDescripcion = ConfigurationManager.AppSettings["nodoDescripcion"].ToString();
            string nodoTipoGarantia = ConfigurationManager.AppSettings["nodoTipoGarantia"].ToString();
            string nodoEstadoTarjeta = ConfigurationManager.AppSettings["nodoEstadoTarjeta"].ToString();

            #endregion

            try
            {
                txtObservacion.Visible = true;
                lblObservacion.Visible = true;

                Session["Tipo_Operacion"] = cbTipoCaptacion.SelectedValue.ToString();
                if (ValidarFormatoTarjeta())
                {
                    decimal nBin = Convert.ToDecimal(txtTarjeta.Text.Substring(0, 6));

                    if (Gestor.Verifica_Tarjeta_Sistar(nBin))
                    {
                        strTrama = new BCRGARANTIAS.Negocios.CreaXML().creaXMLConsultaTarjetaSISTAR(txtTarjeta.Text, "");

                        ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
                                                                                                        Application["Cola_Entrada"].ToString(),
                                                                                                        Application["Cola_Salida"].ToString(),
                                                                                                        strTrama,
                                                                                                        Application["Cola_Respuesta"].ToString(),
                                                                                                        Application["IP"].ToString(),
                                                                                                        Application["Channel"].ToString(),
                                                                                                        Application["Port"].ToString());

                        strTramaRespuesta = oMQ.respuestaMQ();

                        strArchivoXMLTemporal = Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\" + txtTarjeta.Text.Trim() + ".xml";

                        if (!Directory.Exists(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\"))
                        {
                            Directory.CreateDirectory(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\");
                        }

                        CrearArchivoXMLTemporal(strArchivoXMLTemporal, strTramaRespuesta);
                        ds.ReadXml(strArchivoXMLTemporal);

                        //Valida que la respuesta de MQ fuera "TRANSACCION SATISFACTORIA"
                        if (ds.Tables[nodoCabecera].Rows[0][nodoRespuesta].ToString() == "000")
                        {
                            //Tarjeta débito/crédito VISA
                            if ((ds.Tables[nodoSistar].Rows[0][nodoTrans].ToString() == "1") ||
                                    (ds.Tables[nodoSistar].Rows[0][nodoTipoTarjeta].ToString() == "D"))
                            {
                                BloquearCampos(false);
                                Session["EsOperacionValida"] = false;
                                Session["Nombre_Deudor"] = "";
                                lblMensaje.Text = "BCR-GARANTIAS solamente procesa tarjetas de crédito MASTERCARD";
                                lblDeudor.Text = "";
                                lblNombreDeudor.Text = "";

                                gdvGarantiasFiduciarias.DataSource = null;
                                gdvGarantiasFiduciarias.DataBind();
                            }
                            //Valida que la tarjeta fuera débito/crédito MARTERCARD
                            else if (ds.Tables[nodoSistar].Rows[0][nodoTrans].ToString() == "2")
                            {
                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString();
                                string strDeudor = Gestor.ObtenerNombreDeudor(ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString());
                                lblNombreDeudor.Text = lblNombreDeudor.Text + " - " + strDeudor.Trim();

                                BloquearCampos(true);
                                Session["Tarjeta"] = txtTarjeta.Text.Trim();
                                Session["Deudor"] = ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString();
                                Session["Bin"] = ds.Tables[nodoSistar].Rows[0][nodoCuentaAfectada].ToString().Substring(0, 6);
                                Session["CodigoInternoSISTAR"] = ds.Tables[nodoSistar].Rows[0][nodoCuentaAfectada].ToString().Substring(6);

                                if (ds.Tables[nodoSistar].Rows[0][nodoMoneda].ToString().Trim() == "188")
                                    Session["Moneda"] = "1";
                                else if (ds.Tables[nodoSistar].Rows[0][nodoMoneda].ToString().Trim() == "840")
                                    Session["Moneda"] = "2";

                                Session["Oficina_Registra"] = ds.Tables[nodoSistar].Rows[0][nodoOficinaOrigen].ToString().Trim();

                                if ((ds.Tables[nodoSistar].Columns.Contains(nodoTipoGarantia)) 
                                   && (!ds.Tables[nodoSistar].Rows[0].IsNull(nodoTipoGarantia)) 
                                   && (ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString() != string.Empty))
                                {
                                    Session["Plazo"] = ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString().Trim();

                                    int nCodigoTipoGarantiaObt = Convert.ToInt32(ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString());

                                    if (Gestor.CodigoTipoTarjetaEsPerfil(nCodigoTipoGarantiaObt))
                                    {
                                        Session["ValidarTarjeta"] = txtTarjeta.Text;
                                        lblMensaje.Text = "Esta tarjeta posee una <a href=frmGarantiasporPerfil.aspx>Garantía por Perfil<a>";
                                    }
                                }
                                

                                txtCedulaFiador.Enabled = true;
                                btnBuscarFiador.Visible = true;
                                txtFechaExpiracion.Enabled = true;
                                txtFechaExpiracion.ReadOnly = false;
                                txtMontoCobertura.Enabled = true;

                                CargarValoresXDefecto();

                                CargarGridTarjetas();
                                Session["Nombre_Deudor"] = lblNombreDeudor.Text;
                                Session["EsOperacionValida"] = true;
                                GuardarDatosSession();

                                strCodigoEstadoTarjeta = ds.Tables[nodoSistar].Rows[0][nodoEstadoTarjeta].ToString().Trim();

                                if (strCodigoEstadoTarjeta != string.Empty)
                                {
                                    ActualizarEstadoTarjeta(strCodigoEstadoTarjeta);
                                }
                            }

                            btnIngresos.Enabled = false;
                        }
                        //Transacción no satisfactoria
                        else
                        {
                            BloquearCampos(false);
                            Session["EsOperacionValida"] = false;
                            Session["Nombre_Deudor"] = "";
                            lblMensaje.Text = ds.Tables[nodoCabecera].Rows[0][nodoDescripcion].ToString();
                            lblDeudor.Text = "";
                            lblNombreDeudor.Text = "";

                            gdvGarantiasFiduciarias.DataSource = null;
                            gdvGarantiasFiduciarias.DataBind();
                        }

                        EliminarArchivoXMLTemporal(strArchivoXMLTemporal);

                        txtObservacion.Visible = true;
                        lblObservacion.Visible = true;
                    }
                    else
                    {
                        lblMensaje.Text = "La tarjeta que se requiere validar en SISTAR no es de crédito o no se encuentra en SISTAR";
                    }
                }
                
            }
            catch (Exception ex)
            {
                if ((ex.Message.StartsWith("Referencia a objeto no establecida"))
                   || (ex.Message.StartsWith("Object reference not set to an instance of an object.")))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + "No hay comunicación con el sistema SISTAR" +
                                    "&bBotonVisible=0");
                }
                else if (ex.Message.Contains("CODIGORESPUESTA")) 
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                   "bError=1" +
                                   "&strTitulo=" + "Problemas Cargando Página" +
                                   "&strMensaje=" + "No hay comunicación con el sistema  utilizado para obtener la información de la tarjeta (Sistema MQ)" +
                                   "&bBotonVisible=0");
                }
                else
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + ex.Message +
                                    "&bBotonVisible=0");
                }
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvGarantiasFiduciarias_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvGarantiasFiduciarias = (GridView)sender;
            int rowIndex = 0;
            DataSet dsDatos = new DataSet();

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedFiador"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvGarantiasFiduciarias.SelectedIndex = rowIndex;

                        #region DATOS


                        if (gdvGarantiasFiduciarias.SelectedDataKey[11].ToString() != null)
                            Session["CodigoTarjeta"] = gdvGarantiasFiduciarias.SelectedDataKey[11].ToString();

                        if (gdvGarantiasFiduciarias.SelectedDataKey[3].ToString() != null)
                        {
                            cbTipoFiador.ClearSelection();
                            cbTipoFiador.SelectedValue = gdvGarantiasFiduciarias.SelectedDataKey[3].ToString();
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[1].ToString() != null)
                            txtCedulaFiador.Text = gdvGarantiasFiduciarias.SelectedDataKey[1].ToString();
                        else
                            txtCedulaFiador.Text = "";

                        if (gdvGarantiasFiduciarias.SelectedDataKey[2].ToString() != null)
                            txtNombreFiador.Text = gdvGarantiasFiduciarias.SelectedDataKey[2].ToString();
                        else
                            txtNombreFiador.Text = "";

                        CargarTipoMitigador();
                        if (gdvGarantiasFiduciarias.SelectedDataKey[4].ToString() != null)
                            cbMitigador.SelectedValue = gdvGarantiasFiduciarias.SelectedDataKey[4].ToString();

                        CargarTiposDocumentos();
                        if (gdvGarantiasFiduciarias.SelectedDataKey[5].ToString() != null)
                        {
                            cbTipoDocumento.ClearSelection();
                            cbTipoDocumento.SelectedValue = gdvGarantiasFiduciarias.SelectedDataKey[5].ToString();
                        }

                        if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[6].ToString()))
                        {
                            decimal nMontoMitigador = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[6].ToString());
                            txtMontoMitigador.Text = nMontoMitigador.ToString("N");
                        }
                        else
                        {
                            txtMontoMitigador.Text = "0.00";
                        }

                        if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[7].ToString()))
                        {
                            decimal nPorcentaje = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[7].ToString());
                            txtPorcentajeResponsabilidad.Text = nPorcentaje.ToString("N");
                        }
                        else
                        {
                            txtPorcentajeResponsabilidad.Text = "0.00";
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[9].ToString() != null)
                        {
                            cbTipoAcreedor.ClearSelection();
                            cbTipoAcreedor.SelectedValue = gdvGarantiasFiduciarias.SelectedDataKey[9].ToString();
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[10].ToString() != null)
                            txtAcreedor.Text = gdvGarantiasFiduciarias.SelectedDataKey[10].ToString();
                        else
                            txtAcreedor.Text = "";

                        if (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString())
                        {
                            if (gdvGarantiasFiduciarias.SelectedDataKey[14].ToString() != "01/01/1900 12:00:00 AM")
                                txtFechaExpiracion.Text = gdvGarantiasFiduciarias.SelectedDataKey[14].ToString();

                            decimal nMontoCobertura = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[15].ToString());

                            txtMontoCobertura.Text = nMontoCobertura.ToString("N");

                            lblObservacion.Visible = true;
                            txtObservacion.Visible = true;

                            if (gdvGarantiasFiduciarias.SelectedDataKey[16].ToString() != null)
                            {
                                txtObservacion.Text = gdvGarantiasFiduciarias.SelectedDataKey[16].ToString();
                            }
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[8].ToString() != null)
                        {
                            cbOperacionEspecial.ClearSelection();
                            cbOperacionEspecial.SelectedValue = gdvGarantiasFiduciarias.SelectedDataKey[8].ToString();
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[12].ToString() != null)
                            Session["GarantiaFiduciaria"] = gdvGarantiasFiduciarias.SelectedDataKey[12].ToString();


                        #endregion

                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;
                        btnIngresos.Enabled = true;
                        btnLimpiar.Enabled = true;
                        lblMensaje.Text = "";
                        lblMensaje3.Text = "";

                        contenedorDatosModificacion.Visible = true;         

                        DateTime fechaReplicag = DateTime.Parse(gdvGarantiasFiduciarias.SelectedDataKey[18].ToString());
                        DateTime fechaModificacion = DateTime.Parse(gdvGarantiasFiduciarias.SelectedDataKey[16].ToString());                     
                        string usrModifico = gdvGarantiasFiduciarias.SelectedDataKey[14].ToString();
                        string nombreUsrModifico = gdvGarantiasFiduciarias.SelectedDataKey[15].ToString();

                        string usuarioModifico = (((usrModifico.Length > 0) && (nombreUsrModifico.Length > 0)) ? (usrModifico + " - " + nombreUsrModifico) : string.Empty);
                        string fechaModifico = ((fechaModificacion != DateTime.Parse("01/01/1900 12:00:00 AM")  ) ? fechaModificacion.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);
                        string fechaReplica = ((fechaReplicag != DateTime.Parse("01/01/1900 12:00:00 AM")) ? (fechaReplicag.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty);

                        ViewState.Add(LLAVE_FECHA_MODIFICACION, fechaModifico);
                        ViewState.Add(LLAVE_FECHA_REPLICA, fechaReplica);
                        
                        lblUsrModifico.Text = " Usuario Modificó: " + usuarioModifico;
                        lblFechaModificacion.Text = "Fecha Modificación: " + fechaModifico;
                        lblFechaReplica.Text = "Fecha Replica: " + fechaReplica;                        
                        
                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        protected void gdvGarantiasFiduciarias_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvGarantiasFiduciarias.SelectedIndex = -1;
            this.gdvGarantiasFiduciarias.PageIndex = e.NewPageIndex;

            int nProducto = -1;

            if (txtProducto.Text.Length != 0)
                nProducto = int.Parse(txtProducto.Text);

            CargarGrid( int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                        ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                        int.Parse(txtContabilidad.Text),
                        int.Parse(txtOficina.Text),
                        int.Parse(txtMoneda.Text),
                        nProducto,
                        long.Parse(txtOperacion.Text));
        }

        protected void gdvGarantiasFiduciarias_DataBinding(object sender, EventArgs e)
        {
            try
            {
                GridView gdvGF = ((GridView)sender);

                string[] strLlavesNoTarjeta = {"tipo_persona", "cedula_fiador", "nombre_fiador", "cod_tipo_fiador", "cod_tipo_mitigador", 
                                               "cod_tipo_documento_legal", "monto_mitigador", "porcentaje_responsabilidad", "cod_operacion_especial", 
                                               "cod_tipo_acreedor", "cedula_acreedor", "cod_operacion", "cod_garantia_fiduciaria", "cod_estado",
                                                "Usuario_Modifico","Nombre_Usuario_Modifico","Fecha_Modifico","Fecha_Inserto","Fecha_Replica"};

                string[] strLlavesTarjeta = {"tipo_persona", "cedula_fiador", "nombre_fiador", "cod_tipo_fiador", "cod_tipo_mitigador", 
                                             "cod_tipo_documento_legal", "monto_mitigador", "porcentaje_responsabilidad", "cod_operacion_especial", 
                                             "cod_tipo_acreedor", "cedula_acreedor", "cod_operacion", "cod_garantia_fiduciaria", "cod_estado",
                                             "fecha_expiracion", "monto_cobertura", "des_observacion"};

                if ((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString()))
                {
                    
                    BoundField bnfColumnaInvisible = new BoundField();

                    bnfColumnaInvisible.DataField = "fecha_expiracion";
                    bnfColumnaInvisible.Visible = false;

                    if (!gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Add(bnfColumnaInvisible);
                    }

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "monto_cobertura";
                    bnfColumnaInvisible.Visible = false;

                    if (!gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Add(bnfColumnaInvisible);
                    }

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_observacion";
                    bnfColumnaInvisible.Visible = false;

                    if (!gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Add(bnfColumnaInvisible);
                    }

                    gdvGF.DataKeyNames = strLlavesTarjeta;
                    
                }
                else
                {

                    
                    BoundField bnfColumnaInvisible = new BoundField();

                    bnfColumnaInvisible.DataField = "fecha_expiracion";
                    bnfColumnaInvisible.Visible = false;

                    if (gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Remove(bnfColumnaInvisible);
                    }

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "monto_cobertura";
                    bnfColumnaInvisible.Visible = false;
                    if (gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Remove(bnfColumnaInvisible);
                    }

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_observacion";
                    bnfColumnaInvisible.Visible = false;
                    if (gdvGF.Columns.Contains(bnfColumnaInvisible))
                    {
                        gdvGF.Columns.Remove(bnfColumnaInvisible);
                    }

                    gdvGF.DataKeyNames = strLlavesNoTarjeta;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #endregion

        #region Métodos Privados

        private void ConfigurarControles(bool bVisible)
        {
            lblContabilidad.Visible = bVisible;
            txtContabilidad.Visible = bVisible;
            lblOficina.Visible = bVisible;
            txtOficina.Visible = bVisible;
            lblMoneda.Visible = bVisible;
            txtMoneda.Visible = bVisible;
            lblProducto.Visible = bVisible;
            txtProducto.Visible = bVisible;
            lblTipoOperacion.Visible = bVisible;
            txtOperacion.Visible = bVisible;
            btnValidarOperacion.Visible = bVisible;
        }

        private bool ValidarGarantiaTarjeta()
        {
            bool bRespuesta = true;

            try
            {
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

                if (bRespuesta && txtTarjeta.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el número de tarjeta";
                    bRespuesta = false;
                }
                //Valida los datos del fiador
                if (bRespuesta && int.Parse(cbTipoFiador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de persona del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtCedulaFiador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar la cédula del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombreFiador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el nombre del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMitigador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo mitigador de riesgo.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoDocumento.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de documento legal.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoMitigador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el monto mitigador de la garantía.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtFechaExpiracion.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe seleccionar la fecha de expiración.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoCobertura.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el monto de cobertura.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }

            return bRespuesta;
        }

        private void CargarValoresXDefecto()
        {
            cbTipoDocumento.ClearSelection();
            cbOperacionEspecial.ClearSelection();
            cbTipoDocumento.Items.FindByValue(Application["DEFAULT_TIPO_DOCUMENTO_LEGAL_FIADORES"].ToString()).Selected = true;
            cbOperacionEspecial.Items.FindByValue(Application["DEFAULT_OPERACION_ESPECIAL"].ToString()).Selected = true;
            string strFechaExpiracion = (DateTime.Today.Year + 30).ToString() + "/" + DateTime.Today.Month.ToString() + "/" + DateTime.Today.Day.ToString();
            txtFechaExpiracion.Text = DateTime.Parse(strFechaExpiracion).ToShortDateString();
            txtObservacion.Visible = true;
            lblObservacion.Visible = true;
            txtObservacion.Text = string.Empty;
        }

        private void CargarGridTarjetas()
        {
            try
            {
                System.Data.DataSet dsDatos = new System.Data.DataSet();
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = null;

					oComando = new SqlCommand("pa_ObtenerGarantiasFiduciariasXTarjeta", oConexion);
					SqlDataAdapter oDataAdapter = new SqlDataAdapter();
					//declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;
					oComando.CommandTimeout = 120;
					oComando.Parameters.AddWithValue("@strTarjeta", txtTarjeta.Text.Trim());

					//Abre la conexion
					oConexion.Open();
					oDataAdapter.SelectCommand = oComando;
					oDataAdapter.SelectCommand.Connection = oConexion;
					oDataAdapter.Fill(dsDatos, "Datos");

					this.gdvGarantiasFiduciarias.DataSource = dsDatos.Tables["Datos"].DefaultView;
					this.gdvGarantiasFiduciarias.DataBind();

					txtObservacion.Visible = true;
					lblObservacion.Visible = true;
				}
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private bool ValidarFormatoTarjeta()
        {
            bool bRespuesta = true;

            lblMensaje.Text = "";

            if (bRespuesta && txtTarjeta.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el número de tarjeta que desea validar";
                bRespuesta = false;
            }

            if (bRespuesta && txtTarjeta.Text.Trim().Length != 16)
            {
                lblMensaje.Text = "Largo del número de tarjeta inválido";
                bRespuesta = false;
            }

            return bRespuesta;
        }

        private void CrearArchivoXMLTemporal(string strArchivo, string strXML)
        {
            try
            {
                StreamWriter writer = File.CreateText(strArchivo);
                writer.WriteLine(strXML);
                writer.Close();
            }
            catch (Exception ex)
            {

            }
        }

        private void EliminarArchivoXMLTemporal(string strArchivo)
        {
            File.Delete(strArchivo);
        }

        /// <summary>
        /// Este método devuelve un string con el Header para MQ
        /// </summary>
        /// <param name="strReferencia"></param>
        /// <param name="strCanal"></param>
        /// <param name="strTrans"></param>
        /// <param name="strAccion"></param>
        /// <param name="strUsuario"></param>
        /// <param name="strOficinaOrigen"></param>
        /// <param name="strEstacion"></param>
        /// <param name="strFechaHora"></param>
        /// <returns></returns>
        private string GenerarHeaderMQ(string strReferencia, string strCanal, string strTrans, string strAccion,
                                       string strUsuario, string strOficinaOrigen, string strEstacion, string strFechaHora)
        {
            string strHeader = "";
            try
            {
                strHeader = "<HEADER><REFERENCIA>";
                strHeader = strHeader + strReferencia;
                strHeader = strHeader + "</REFERENCIA><CANAL>";
                strHeader = strHeader + strCanal;
                strHeader = strHeader + "</CANAL><TRANS>";
                strHeader = strHeader + strTrans;
                strHeader = strHeader + "</TRANS><ACCION>";
                strHeader = strHeader + strAccion;
                strHeader = strHeader + "</ACCION><USUARIO>";
                strHeader = strHeader + strUsuario;
                strHeader = strHeader + "</USUARIO><OFICINAORIGEN>";
                strHeader = strHeader + strOficinaOrigen;
                strHeader = strHeader + "</OFICINAORIGEN><ESTACION>";
                strHeader = strHeader + strEstacion;
                strHeader = strHeader + "</ESTACION><FECHAHORA>";
                strHeader = strHeader + strFechaHora;
                strHeader = strHeader + "</FECHAHORA></HEADER>";
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return strHeader;
        }

        /// <summary>
        /// Este método genera la trama de consulta de tarjetas para MQ
        /// </summary>
        /// <param name="strCanal"></param>
        /// <param name="strTrans"></param>
        /// <param name="strAccion"></param>
        /// <param name="strTipoMovimiento"></param>
        /// <param name="strTarjeta"></param>
        /// <returns></returns>
        private string GenerarTramaMQ(string strCanal, string strTrans, string strAccion, string strTipoMovimiento, string strTarjeta)
        {
            string strTrama = "";
            try
            {
                strTrama = "<SISTAR><CANAL>";
                strTrama = strTrama + strCanal;
                strTrama = strTrama + "</CANAL><TRANS>";
                strTrama = strTrama + strTrans;
                strTrama = strTrama + "</TRANS><ACCION>";
                strTrama = strTrama + strAccion;
                strTrama = strTrama + "</ACCION><TIPOMOVIMIENTO>";
                strTrama = strTrama + strTipoMovimiento;
                strTrama = strTrama + "</TIPOMOVIMIENTO><NROTARJETA>";
                strTrama = strTrama + strTarjeta;
                strTrama = strTrama + "</NROTARJETA></SISTAR>";
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return strTrama;
        }

        /// <summary>
        /// Este método guarda los datos de la pantalla en el objeto Session
        /// </summary>
        private void GuardarDatosSession()
        {
            try
            {
                CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

                //Campos llave
                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) != int.Parse(Application["TARJETA"].ToString()))
                {
                    oGarantia.Contabilidad = int.Parse(txtContabilidad.Text);
                    oGarantia.Oficina = int.Parse(txtOficina.Text);
                    oGarantia.Moneda = int.Parse(txtMoneda.Text);

                    if (txtProducto.Text.Trim().Length > 0)
                        oGarantia.Producto = int.Parse(txtProducto.Text);

                    oGarantia.Numero = long.Parse(txtOperacion.Text);
                }
                else
                {
                    oGarantia.Tarjeta = txtTarjeta.Text.Trim();
                    oGarantia.Observacion = txtObservacion.Text;
                }

                oGarantia.TipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                oGarantia.ClaseGarantia = int.Parse(Application["CLASE_GARANTIA_FIADOR"].ToString());
                //Informacion del fiador
                oGarantia.TipoFiador = int.Parse(cbTipoFiador.SelectedValue.ToString());
                oGarantia.CedulaFiador = txtCedulaFiador.Text.Trim();
                oGarantia.NombreFiador = txtNombreFiador.Text.Trim();
                oGarantia.TipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.TipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                if (txtMontoMitigador.Text.Trim().Length > 0)
                    oGarantia.MontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text);
                else
                    oGarantia.MontoMitigador = 0;

                if (txtPorcentajeResponsabilidad.Text.Trim().Length > 0)
                    oGarantia.PorcentajeResposabilidad = Convert.ToDecimal(txtPorcentajeResponsabilidad.Text);
                else
                    oGarantia.PorcentajeResposabilidad = 0;

                oGarantia.TipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.OperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                if (txtFechaExpiracion.Text.Trim().Length > 0)
                    oGarantia.FechaExpiracion = DateTime.Parse(txtFechaExpiracion.Text.ToString());

                if (txtMontoCobertura.Text.Trim().Length > 0)
                    oGarantia.MontoCobertura = Convert.ToDecimal(txtMontoCobertura.Text);
                else
                    oGarantia.MontoCobertura = 0;

                oGarantia.UsuarioModifico = lblUsrModifico.Text.Trim();


                if ((ViewState[LLAVE_FECHA_MODIFICACION] != null))
                {
                    if (!ViewState[LLAVE_FECHA_MODIFICACION].ToString().Equals(""))
                    {
                        oGarantia.FechaModifico = DateTime.Parse(ViewState[LLAVE_FECHA_MODIFICACION].ToString());
                    }                  
              
                }

                if ((ViewState[LLAVE_FECHA_REPLICA] != null) )
                {
                  if (!ViewState[LLAVE_FECHA_REPLICA].ToString().Equals(""))
                  {
                      oGarantia.FechaReplica = DateTime.Parse(ViewState[LLAVE_FECHA_REPLICA].ToString());
                  }                  
                }

                oGarantia = null;           
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Método que carga la información de la garantía que se encuentra almacenada en el objeto Session.
        /// </summary>
        private void CargarDatosSession()
        {
            try
            {
                CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

                //Campos llave
                if (oGarantia.TipoOperacion != int.Parse(Application["TARJETA"].ToString()))
                {
                    if (oGarantia.TipoOperacion != 0)
                        cbTipoCaptacion.Items.FindByValue(oGarantia.TipoOperacion.ToString()).Selected = true;

                    if (oGarantia.Contabilidad != 0)
                        txtContabilidad.Text = oGarantia.Contabilidad.ToString();

                    if (oGarantia.Oficina != 0)
                        txtOficina.Text = oGarantia.Oficina.ToString();

                    if (oGarantia.Moneda != 0)
                        txtMoneda.Text = oGarantia.Moneda.ToString();

                    if (oGarantia.TipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                    {
                        lblProducto.Visible = true;
                        txtProducto.Visible = true;

                        if (oGarantia.Producto != 0)
                            txtProducto.Text = oGarantia.Producto.ToString();
                    }
                    else
                    {
                        lblProducto.Visible = false;
                        txtProducto.Visible = false;
                    }

                    if (oGarantia.Numero != 0)
                        txtOperacion.Text = oGarantia.Numero.ToString();
                }
                else
                {
                    if (oGarantia.TipoOperacion != 0)
                        cbTipoCaptacion.Items.FindByValue(oGarantia.TipoOperacion.ToString()).Selected = true;

                    txtTarjeta.Text = oGarantia.Tarjeta;

                    txtObservacion.Text = oGarantia.Observacion;
                }

                //Informacion del fiador
                if (oGarantia.TipoFiador != 0)
                {
                    cbTipoFiador.ClearSelection();
                    cbTipoFiador.Items.FindByValue(oGarantia.TipoFiador.ToString()).Selected = true;
                }

                if (oGarantia.CedulaFiador != null)
                    txtCedulaFiador.Text = oGarantia.CedulaFiador;

                if (oGarantia.NombreFiador != null)
                    txtNombreFiador.Text = oGarantia.NombreFiador;

                if (oGarantia.TipoMitigador != -1)
                {
                    cbMitigador.ClearSelection();
                    cbMitigador.Items.FindByValue(oGarantia.TipoMitigador.ToString()).Selected = true;
                }

                if (oGarantia.TipoDocumento != 0)
                {
                    cbTipoDocumento.ClearSelection();
                    cbTipoDocumento.Items.FindByValue(oGarantia.TipoDocumento.ToString()).Selected = true;
                }

                if (oGarantia.MontoMitigador != 0)
                    txtMontoMitigador.Text = oGarantia.MontoMitigador.ToString("N");

                if (oGarantia.PorcentajeResposabilidad != 0)
                    txtPorcentajeResponsabilidad.Text = oGarantia.PorcentajeResposabilidad.ToString("N");

                if (oGarantia.TipoAcreedor != 0)
                {
                    cbTipoAcreedor.ClearSelection();
                    cbTipoAcreedor.Items.FindByValue(oGarantia.TipoAcreedor.ToString()).Selected = true;
                }

                if (oGarantia.CedulaAcreedor != null)
                    txtAcreedor.Text = oGarantia.CedulaAcreedor;

                if (oGarantia.OperacionEspecial != -1)
                {
                    cbOperacionEspecial.ClearSelection();
                    cbOperacionEspecial.Items.FindByValue(oGarantia.OperacionEspecial.ToString()).Selected = true;
                }

                txtFechaExpiracion.Text = oGarantia.FechaExpiracion.ToShortDateString();

                if (oGarantia.MontoCobertura != 0)
                    txtMontoCobertura.Text = oGarantia.MontoCobertura.ToString("N");

                contenedorDatosModificacion.Visible = true;


                string usuarioModifico = ((oGarantia.UsuarioModifico.Length > 0) ? (oGarantia.UsuarioModifico) : string.Empty);
                string fechaModifico = ((oGarantia.FechaModifico != DateTime.MinValue) ? oGarantia.FechaModifico.ToString("dd/MM/yyyy") : string.Empty);
                string fechaReplica = ((oGarantia.FechaReplica != DateTime.MinValue) ? (oGarantia.FechaReplica.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty);

                lblUsrModifico.Text = " Usuario Modificó: " + usuarioModifico;
                lblFechaModificacion.Text = "Fecha Modificación: " + fechaModifico;
                lblFechaReplica.Text = "Fecha Replica: " + fechaReplica;


                //lblUsrModifico.Text = oGarantia.UsuarioModifico;          
                //lblFechaModificacion.Text = "Fecha Modificacion: "  + oGarantia.FechaModifico.ToShortDateString();
                //lblFechaReplica.Text = "Fecha Replica: " + oGarantia.FechaReplica.ToShortDateString() + "-" + oGarantia.FechaReplica.ToShortTimeString(); 


                oGarantia = null;

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void MostrarLlave()
        {
            CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

            if (oGarantia.TipoOperacion != int.Parse(Application["TARJETA"].ToString()))
            {
                if (oGarantia.TipoOperacion != 0)
                    cbTipoCaptacion.Items.FindByValue(oGarantia.TipoOperacion.ToString()).Selected = true;

                if (oGarantia.Contabilidad != 0)
                    txtContabilidad.Text = oGarantia.Contabilidad.ToString();

                if (oGarantia.Oficina != 0)
                    txtOficina.Text = oGarantia.Oficina.ToString();

                if (oGarantia.Moneda != 0)
                    txtMoneda.Text = oGarantia.Moneda.ToString();

                if (oGarantia.TipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblProducto.Visible = true;
                    txtProducto.Visible = true;

                    if (oGarantia.Producto != 0)
                        txtProducto.Text = oGarantia.Producto.ToString();
                }
                else
                {
                    lblProducto.Visible = false;
                    txtProducto.Visible = false;
                }

                if (oGarantia.Numero != 0)
                    txtOperacion.Text = oGarantia.Numero.ToString();
            }
            else
            {
                if (oGarantia.TipoOperacion != 0)
                    cbTipoCaptacion.Items.FindByValue(oGarantia.TipoOperacion.ToString()).Selected = true;

                txtTarjeta.Text = oGarantia.Tarjeta;
            }

            if (oGarantia.TipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                lblContabilidad.Visible = true;
                txtContabilidad.Visible = true;
                lblOficina.Visible = true;
                txtOficina.Visible = true;
                lblMoneda.Visible = true;
                txtMoneda.Visible = true;
                lblProducto.Visible = true;
                txtProducto.Visible = true;
                lblTipoOperacion.Visible = true;
                txtOperacion.Visible = true;
                btnValidarOperacion.Visible = true;
                lblTarjeta.Visible = false;
                txtTarjeta.Visible = false;
                btnValidarTarjeta.Visible = false;
                lblFechaExpiracion.Visible = false;
                txtFechaExpiracion.Visible = false;
                lblMontoCobertura.Visible = false;
                txtMontoCobertura.Visible = false;
                btnInsertar.Visible = false;
                btnEliminar.Visible = false;
            }
            else if (oGarantia.TipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
            {
                lblContabilidad.Visible = true;
                txtContabilidad.Visible = true;
                lblOficina.Visible = true;
                txtOficina.Visible = true;
                lblMoneda.Visible = true;
                txtMoneda.Visible = true;
                lblProducto.Visible = false;
                txtProducto.Visible = false;
                lblTipoOperacion.Visible = true;
                txtOperacion.Visible = true;
                btnValidarOperacion.Visible = true;
                lblTarjeta.Visible = false;
                txtTarjeta.Visible = false;
                btnValidarTarjeta.Visible = false;
                lblFechaExpiracion.Visible = false;
                txtFechaExpiracion.Visible = false;
                lblMontoCobertura.Visible = false;
                txtMontoCobertura.Visible = false;
                btnInsertar.Visible = false;
                btnEliminar.Visible = false;
            }
            else if (oGarantia.TipoOperacion == int.Parse(Application["TARJETA"].ToString()))
            {
                lblContabilidad.Visible = false;
                txtContabilidad.Visible = false;
                lblOficina.Visible = false;
                txtOficina.Visible = false;
                lblMoneda.Visible = false;
                txtMoneda.Visible = false;
                lblProducto.Visible = false;
                txtProducto.Visible = false;
                lblTipoOperacion.Visible = false;
                txtOperacion.Visible = false;
                btnValidarOperacion.Visible = false;
                lblTarjeta.Visible = true;
                txtTarjeta.Visible = true;
                btnValidarTarjeta.Visible = true;
                lblFechaExpiracion.Visible = true;
                txtFechaExpiracion.Visible = true;
                lblMontoCobertura.Visible = true;
                txtMontoCobertura.Visible = true;
                btnInsertar.Visible = true;
                btnEliminar.Visible = true;
            }

            oGarantia = null;
        }

        /// <summary>
        /// Este método permite bloquear o desbloquear los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles están bloqueados o no</param>
        private void BloquearCampos(bool bBloqueado)
        {
            try
            {
                //Información del Deudor
                LimpiarCampos();
                CargarCombos();
                //Información del Fiador
                cbTipoFiador.Enabled = bBloqueado;
                txtCedulaFiador.Enabled = bBloqueado;
                //Información de la Garantia
                cbMitigador.Enabled = bBloqueado;
                cbTipoDocumento.Enabled = bBloqueado;
                txtMontoMitigador.Enabled = bBloqueado;
                txtPorcentajeResponsabilidad.Enabled = bBloqueado;
                cbOperacionEspecial.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtMontoCobertura.Enabled = bBloqueado;
                //Botones
                btnIngresos.Enabled = bBloqueado;
                btnInsertar.Enabled = bBloqueado;
                btnModificar.Enabled = bBloqueado;
                btnLimpiar.Enabled = bBloqueado;
                //Mensajes
                lblMensaje.Text = "";
                lblMensaje3.Text = "";
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este método permite limpiar los campos del formulario
        /// </summary>
        private void LimpiarCampos()
        {
            try
            {
                txtCedulaFiador.Text = string.Empty;
                txtNombreFiador.Text = string.Empty;
                txtMontoMitigador.Text = string.Empty;
                txtFechaExpiracion.Text = string.Empty;
                txtMontoCobertura.Text = string.Empty;
                lblMensaje.Text = string.Empty;
                lblMensaje3.Text = string.Empty;
                txtObservacion.Text = string.Empty;           

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void CargarCombos()
        {
            try
            {
                CargarTipoMitigador();
                CargarTiposPersona();
                CargarTiposDocumentos();
                CargarOperacionEspecial();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void CargarTipoMitigador()
        {
			try
			{
				System.Data.DataSet dsDatos = new System.Data.DataSet();
				oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
				OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
				cmdConsulta.Fill(dsDatos, "Codigos");
				cbMitigador.DataSource = null;
				cbMitigador.DataSource = dsDatos.Tables["Codigos"].DefaultView;
				cbMitigador.DataValueField = "CAT_CAMPO";
				cbMitigador.DataTextField = "CAT_DESCRIPCION";
				cbMitigador.DataBind();
				cbMitigador.ClearSelection();
				cbMitigador.Items.FindByValue("0").Selected = true;
			}
			finally
			{
				oleDbConnection1.Close();
			}
        }

        private void CargarOperacionEspecial()
        {
			try
			{
				System.Data.DataSet dsDatos = new System.Data.DataSet();
				oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
				OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_OPERACION_ESPECIAL"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
				cmdConsulta.Fill(dsDatos, "Codigos");
				cbOperacionEspecial.DataSource = null;
				cbOperacionEspecial.DataSource = dsDatos.Tables["Codigos"].DefaultView;
				cbOperacionEspecial.DataValueField = "CAT_CAMPO";
				cbOperacionEspecial.DataTextField = "CAT_DESCRIPCION";
				cbOperacionEspecial.DataBind();
				cbOperacionEspecial.ClearSelection();
				cbOperacionEspecial.Items.FindByValue(Application["DEFAULT_OPERACION_ESPECIAL"].ToString()).Selected = true;
			}
			finally
			{
				oleDbConnection1.Close();
			}
		}

		private void CargarTiposDocumentos()
		{
			try
			{
				System.Data.DataSet dsDatos = new System.Data.DataSet();
				oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
				OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPOS_DOCUMENTOS"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
				cmdConsulta.Fill(dsDatos, "Codigos");
				cbTipoDocumento.DataSource = null;
				cbTipoDocumento.DataSource = dsDatos.Tables["Codigos"].DefaultView;
				cbTipoDocumento.DataValueField = "CAT_CAMPO";
				cbTipoDocumento.DataTextField = "CAT_DESCRIPCION";
				cbTipoDocumento.DataBind();
				cbTipoDocumento.ClearSelection();
				cbTipoDocumento.Items.FindByValue(Application["DEFAULT_TIPO_DOCUMENTO_LEGAL_FIADORES"].ToString()).Selected = true;
			}
			finally
			{
				oleDbConnection1.Close();
			}
		}

		private void CargarTiposPersona()
		{
			try
			{
				System.Data.DataSet dsDatos = new System.Data.DataSet();
				oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
				OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_PERSONA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
				cmdConsulta.Fill(dsDatos, "Tipos");

				cbTipoAcreedor.DataSource = null;
				cbTipoAcreedor.DataSource = dsDatos.Tables["Tipos"].DefaultView;
				cbTipoAcreedor.DataValueField = "CAT_CAMPO";
				cbTipoAcreedor.DataTextField = "CAT_DESCRIPCION";
				cbTipoAcreedor.DataBind();
				cbTipoAcreedor.ClearSelection();
				cbTipoAcreedor.Items.FindByValue(Application["DEFAULT_TIPO_ACREEDOR"].ToString()).Selected = true;

				cbTipoFiador.DataSource = null;
				cbTipoFiador.DataSource = dsDatos.Tables["Tipos"].DefaultView;
				cbTipoFiador.DataValueField = "CAT_CAMPO";
				cbTipoFiador.DataTextField = "CAT_DESCRIPCION";
				cbTipoFiador.DataBind();
				cbTipoFiador.ClearSelection();
			}
			finally
			{
				oleDbConnection1.Close();
			}
		}

        /// <summary>
        /// Método de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;

            try
            {
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

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
                        lblMensaje.Text = "Debe ingresar el número de operación";
                    else
                        lblMensaje.Text = "Debe ingresar el número de contrato";
                    bRespuesta = false;
                }
                //Valida los datos del fiador
                if (bRespuesta && int.Parse(cbTipoFiador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de persona del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtCedulaFiador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar la cédula del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombreFiador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el nombre del fiador.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMitigador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo mitigador de riesgo.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoDocumento.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de documento legal.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoMitigador.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el monto mitigador de la garantía.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtPorcentajeResponsabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje3.Text = "Debe ingresar el porcentaje de aceptación de la garantía.";
                    bRespuesta = false;
                }

                if (bRespuesta && int.Parse(cbOperacionEspecial.SelectedValue.ToString()) == -1)
                {
                    lblMensaje3.Text = "Debe seleccionar el tipo de operación especial.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }

            return bRespuesta;
        }

        private bool ValidarMontoMitigador(decimal nMontoMitigador)
        {
            bool bRespuesta = false;
            try
            {
                string strSQLQuery = "SELECT " +
                                        "isnull(a.saldo_actual,0) as saldo_actual " +
                                    "FROM " +
                                        "gar_operacion a " +
                                    "WHERE " +
                                        " a.cod_contabilidad = " + txtContabilidad.Text +
                                        " and a.cod_oficina = " + txtOficina.Text +
                                        " and a.cod_moneda = " + txtMoneda.Text;

                if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    strSQLQuery = strSQLQuery + " and a.cod_producto = " + txtProducto.Text +
                                                " and a.num_operacion = " + txtOperacion.Text;
                }
                else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                {
                    strSQLQuery = strSQLQuery + " and a.num_operacion is null " +
                                                " and a.num_contrato = " + txtOperacion.Text;
                }

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQLQuery, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Operacion");

                if (dsDatos.Tables["Operacion"].Rows.Count > 0)
                {
                    if (nMontoMitigador <= Convert.ToDecimal(dsDatos.Tables["Operacion"].Rows[0]["saldo_actual"].ToString()))
                        bRespuesta = true;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
			finally
			{
				oleDbConnection1.Close();
			}

            return bRespuesta;
        }

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
                        lblMensaje.Text = "Debe ingresar el número de operación";
                    else
                        lblMensaje.Text = "Debe ingresar el número de contrato";

                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        private void CargarGrid(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            try
			{
				System.Data.DataSet dsDatos = new System.Data.DataSet();
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = null;

					if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
						oComando = new SqlCommand("pa_ObtenerGarantiasFiduciariasOperaciones", oConexion);
					else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
						oComando = new SqlCommand("pa_ObtenerGarantiasFiduciariasContratos", oConexion);

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

						if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("tipo_persona")) &&
							(!dsDatos.Tables["Datos"].Rows[0].IsNull("cedula_fiador")) &&
							(!dsDatos.Tables["Datos"].Rows[0].IsNull("nombre_fiador")))
						{
							this.gdvGarantiasFiduciarias.DataSource = dsDatos.Tables["Datos"].DefaultView;
							this.gdvGarantiasFiduciarias.DataBind();
						}
						else
						{
							dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
							this.gdvGarantiasFiduciarias.DataSource = dsDatos;
							this.gdvGarantiasFiduciarias.DataBind();

							int TotalColumns = this.gdvGarantiasFiduciarias.Rows[0].Cells.Count;
							this.gdvGarantiasFiduciarias.Rows[0].Cells.Clear();
							this.gdvGarantiasFiduciarias.Rows[0].Cells.Add(new TableCell());
							this.gdvGarantiasFiduciarias.Rows[0].Cells[0].ColumnSpan = TotalColumns;
							this.gdvGarantiasFiduciarias.Rows[0].Cells[0].Text = "No existen registros";
						}
					}
					else
					{
						dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
						this.gdvGarantiasFiduciarias.DataSource = dsDatos;
						this.gdvGarantiasFiduciarias.DataBind();

						int TotalColumns = this.gdvGarantiasFiduciarias.Rows[0].Cells.Count;
						this.gdvGarantiasFiduciarias.Rows[0].Cells.Clear();
						this.gdvGarantiasFiduciarias.Rows[0].Cells.Add(new TableCell());
						this.gdvGarantiasFiduciarias.Rows[0].Cells[0].ColumnSpan = TotalColumns;
						this.gdvGarantiasFiduciarias.Rows[0].Cells[0].Text = "No existen registros";
					}
				}
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private bool ValidarGarantiaFiduciaria()
        {
            bool bRespuesta = true;
            try
            {
                string strSQL = "SELECT " +
                                    "b.cod_operacion, " +
                                    "b.cod_garantia_fiduciaria " +
                                "FROM " +
                                    "dbo.GAR_OPERACION a, " +
                                    "dbo.GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b, " +
                                    "dbo.GAR_GARANTIA_FIDUCIARIA c " +
                                "WHERE " +
                                    "a.cod_contabilidad= " + txtContabilidad.Text +
                                    " and a.cod_oficina= " + txtOficina.Text +
                                    " and a.cod_moneda= " + txtMoneda.Text;

                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    strSQL = strSQL + " and a.cod_producto= " + txtProducto.Text +
                                    " and a.num_operacion= " + txtOperacion.Text;
                }
                else
                {
                    strSQL = strSQL + " and a.num_operacion is null " +
                                    " and a.num_contrato = " + txtOperacion.Text;
                }
                strSQL = strSQL +
                                " and a.cod_operacion = b.cod_operacion " +
                                " and b.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria " +
                                " and c.cedula_fiador = '" + txtCedulaFiador.Text + "'";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if (dsDatos.Tables["Datos"].Rows.Count > 0)
                    bRespuesta = false;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
			}
			finally
			{
				oleDbConnection1.Close();
			}
			
			return bRespuesta;
        }

        /// <summary>
        /// Este método procesa la respuesta enviada por MQ
        /// </summary>
        /// <param name="strXML">XML de respuesta</param>
        private void ProcesarRespuestaMQ(string strXML)
        {
            try
            {
                //Carga el XML en un archivo 
                StreamWriter writer = File.CreateText(Application["ARCHIVOS"].ToString() + "TMPXML.xml");
                writer.WriteLine(strXML);
                writer.Close();

                XmlDocument xDoc = new XmlDocument();
                xDoc.Load(Application["ARCHIVOS"].ToString() + "TMPXML.xml");

                XmlNodeList oEvento = xDoc.GetElementsByTagName("TRAMAXML");

                //Valida que la transacción se haya procesado
                if (ValidarRespuestaMQ(oEvento))
                {
                    XmlNodeList oElementos = ((XmlElement)oEvento[0]).GetElementsByTagName(Application["PRC18"].ToString());

                    int i = 0;
                    XmlNodeList ndElemento;
                    if (oElementos.Count > 0)
                    {
                        foreach (XmlElement nodo in oElementos)
                        {
                            //Obtiene el número de cédula del deudor de la operación
                            XmlNodeList ndCliente = nodo.GetElementsByTagName("NUMERO");

                            if (ndCliente[i] != null)
                                Session["Deudor"] = long.Parse(ndCliente[i].InnerText).ToString();

                            //Obtiene el consecutivo de la operación en BCR_GARANTIAS
                            ConsecutivoOperacion = Gestor.ObtenerConsecutivoOperacion(int.Parse(txtContabilidad.Text),
                                                                                    int.Parse(txtOficina.Text),
                                                                                    int.Parse(txtMoneda.Text),
                                                                                    int.Parse(txtProducto.Text),
                                                                                    long.Parse(txtOperacion.Text),
                                                                                    long.Parse(ndCliente[i].InnerText).ToString());
                            BloquearCampos(true);
                            btnModificar.Enabled = false;
                            btnEliminar.Enabled = false;
                            Session["EsOperacionValida"] = true;
                            GuardarDatosSession();

                            //Carga las garantias fiduciarias en el Grid
                            ndElemento = nodo.GetElementsByTagName("CLAGAR");
                            if (ndElemento[i] != null)
                            {
                                if (ndElemento[i].InnerText == "00")
                                {
                                }
                            }
                        }
                    }
                    else
                    {
                        BloquearCampos(false);
                        Session["EsOperacionValida"] = false;
                        if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                            lblMensaje.Text = "La operación crediticia no existe en el sistema.";
                        else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                            lblMensaje.Text = "El contrato no existe en el sistema.";
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Este método permite validar el código de respuesta enviado por MQ
        /// </summary>
        /// <param name="oEvento"></param>
        /// <returns></returns>
        private bool ValidarRespuestaMQ(XmlNodeList oEvento)
        {
            bool bRespuesta = false;
            try
            {
                XmlNodeList oElementos = ((XmlElement)oEvento[0]).GetElementsByTagName("HEADER");
                if (oElementos.Count > 0)
                {
                    foreach (XmlElement nodo in oElementos)
                    {
                        //Obtiene el código de respuesta del MQ
                        XmlNodeList ndRespuesta = nodo.GetElementsByTagName("CODIGORESPUESTA");
                        XmlNodeList ndDescripcion = nodo.GetElementsByTagName("DESCRIPCION");

                        if (ndRespuesta[0] != null)
                            if (int.Parse(ndRespuesta[0].InnerText) == int.Parse(Application["TRANSACCION_PROCESADA"].ToString()))
                                bRespuesta = true;
                            else
                                lblMensaje.Text = "Error: " + ndDescripcion[0].InnerText;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return bRespuesta;
        }

        /// <summary>
        /// Método que permite actualizar el estado de la tarjeta
        /// </summary>
        /// <param name="strEstadoTarjeta"></param>
        private void ActualizarEstadoTarjeta(string strEstadoTarjeta)
        {
            string strEstadoActualTarjeta = Gestor.ObtenerEstadoTarjeta(txtTarjeta.Text.Trim());
            int nMensaje = 0;

            if (strEstadoActualTarjeta != string.Empty)
            {
                if (strEstadoActualTarjeta.CompareTo(strEstadoTarjeta) != 0)
                {
                    nMensaje = Gestor.ActualizarEstadoTarjeta(txtTarjeta.Text.Trim(), strEstadoTarjeta, 1);

                    if (nMensaje != 0)
                    {
                        string[] aMensajes = MostrarMensaje(nMensaje, 2);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=" + aMensajes[0] +
                                        "&strTitulo=" + aMensajes[1] +
                                        "&strMensaje=" + aMensajes[2] +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }
        }

        /// <summary>
        /// Maneja los mensajes que se deben mostrar de acuerdo al número retornado por la transacción
        /// </summary>
        /// <param name="numeroMensaje">
        /// Número de mensaje que se debe mostrar
        /// </param>
        /// <param name="nAccion">
        /// Número que indica el evento que lo ha llamado
        /// </param>
        /// <returns>
        /// Arreglo de strings con los mensajes a mostrar
        /// </returns>
        private string[] MostrarMensaje(int numeroMensaje, int nAccion)
        {
            string[] mensaje = { string.Empty, string.Empty, string.Empty };

            if (numeroMensaje.Equals(0))
            {
                mensaje[0] = "0";
                mensaje[1] = "Inserción Exitosa";
                mensaje[2] = "La garantía fiduciaria se insertó satisfactoriamente.";
            }
            else
                if (numeroMensaje.Equals(1))
                {
                    mensaje[0] = "1";

                    if (nAccion == 1)
                    {
                        mensaje[1] = "Problemas Insertando Registro";
                        mensaje[2] = "La información de la tarjeta no se ingresó correctamente.";
                    }
                    else if(nAccion == 2)
                    {
                        mensaje[1] = "Problemas Modificando Registro";
                        mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que la tarjeta no existe.";
                    }
                }
                else
                    if (numeroMensaje.Equals(2))
                    {
                        mensaje[0] = "1";

                        if (nAccion == 1)
                        {
                            mensaje[1] = "Problemas Insertando Registro";
                            mensaje[2] = "La información de la garantía fiduciaria no se ingresó correctamente.";
                        }
                        else if (nAccion == 2)
                        {
                            mensaje[1] = "Problemas Modificando Registro";
                            mensaje[2] = "El estado de la tarjeta no pudo ser modificado correctamente.";
                        }
                    }
                    else
                        if (numeroMensaje.Equals(3))
                        {
                            mensaje[0] = "1";

                            if (nAccion == 1)
                            {
                                mensaje[1] = "Problemas Eliminando Registro";
                                mensaje[2] = "La información de la garantía por perfil no se eliminó correctamente.";
                            }
                            else if (nAccion == 2)
                            {
                                mensaje[1] = "Problemas Modificando Registro";
                                mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se suministró el número de tarjeta.";
                            }
                        }
                        else
                            if (numeroMensaje.Equals(4))
                            {
                                mensaje[0] = "1";

                                if (nAccion == 1)
                                {
                                    mensaje[1] = "Problemas Modificando Registro";
                                    mensaje[2] = "La información del tipo de la garantía de la tarjeta no se modificó correctamente.";
                                }
                                else if (nAccion == 2)
                                {
                                    mensaje[1] = "Problemas Modificando Registro";
                                    mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se suministró el nuevo estado.";
                                }
                            }
                            else
                                if (numeroMensaje.Equals(5))
                                {
                                    mensaje[0] = "1";

                                    if (nAccion == 1)
                                    {
                                        mensaje[1] = "Problemas Insertando Registro";
                                        mensaje[2] = "El tipo de la garantía que posee la tarjeta no es válida.";
                                    }
                                    else if (nAccion == 2)
                                    {
                                        mensaje[1] = "Problemas Modificando Registro";
                                        mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se brindó dato alguno.";
                                    }
                                }
                                else
                                    if (numeroMensaje.Equals(6))
                                    {
                                        mensaje[0] = "1";
                                        mensaje[1] = "Problemas Insertando Registro";
                                        mensaje[2] = "La información de la garantía fiduciaria de la tarjeta no se insertó correctamente.";
                                    }

                            

            return mensaje;

        }/*fin del método MostrarMensaje*/

        /// <summary>
        /// Este método permite bloquear o desbloquear todos los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles están bloqueados o no</param>
        private void BloquearTodosCampos(bool bBloqueado)
        {
            try
            {
                //Información del Fiador
                cbTipoFiador.Enabled = bBloqueado;
                txtCedulaFiador.Enabled = bBloqueado;
                //Información de la Garantia
                cbMitigador.Enabled = bBloqueado;
                cbTipoDocumento.Enabled = bBloqueado;
                txtMontoMitigador.Enabled = bBloqueado;
                txtPorcentajeResponsabilidad.Enabled = bBloqueado;
                cbTipoAcreedor.Enabled = bBloqueado;
                txtAcreedor.Enabled = bBloqueado;
                cbOperacionEspecial.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtMontoCobertura.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtObservacion.Enabled = bBloqueado;
                //Botones
                btnIngresos.Enabled = bBloqueado;
                btnInsertar.Enabled = bBloqueado;
                btnModificar.Enabled = bBloqueado;
                btnEliminar.Enabled = bBloqueado;
                btnBuscarFiador.Enabled = bBloqueado;
                //Mensajes
                lblMensaje3.Text = "";
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
        #endregion

}
}
