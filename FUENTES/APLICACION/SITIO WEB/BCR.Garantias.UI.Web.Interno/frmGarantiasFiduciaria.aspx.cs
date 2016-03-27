using System;
using System.Xml;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.UI;
using System.Collections.Generic;
using System.Web;

using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using BCRGARANTIAS.Presentacion;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Forms
{
    public partial class frmGarantiasFiduciaria : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string LLAVE_CONSECUTIVO_OPERACION = "LLAVE_CONSECUTIVO_OPERACION";
        private const string LLAVE_CONSECUTIVO_GARANTIA = "LLAVE_CONSECUTIVO_GARANTIA";
        private const string LLAVE_ES_GIRO = "LLAVE_ES_GIRO";
        private const string LLAVE_CONSECUTIVO_CONTRATO = "LLAVE_CONSECUTIVO_CONTRATO";
        private const string _llaveContratoGiro = "_llaveContratoGiro";
        private const string LLAVE_FECHA_REPLICA = "LLAVE_FECHA_REPLICA";
        private const string LLAVE_FECHA_MODIFICACION = "LLAVE_FECHA_MODIFICACION";
        private const string LLAVE_FILA_SELECCIONADA = "LLAVE_FILA_SELECCIONADA";
        private const string LLAVE_ENTIDAD_CATALOGOS = "LLAVE_ENTIDAD_CATALOGOS";

        #endregion Constantes

        #region Variables Globales

        protected DropDownList cbTipoEmpresa;
        protected TextBox txtEmpresa;
        protected DropDownList cbMoneda;
        protected DropDownList cbLiquidez;
        protected DropDownList cbRecomendacion;
        protected DropDownList cbInspección;
        protected mtpMenuPrincipal oPagina = new mtpMenuPrincipal();

        private string _contratoDelGiro = string.Empty;

        private bool seRedirecciona = false;

        private string urlPaginaMensaje = string.Empty;

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

        /// <summary>
        /// Se guarda en sesión el índice de la fila seleccionada del grid
        /// </summary>
        public int FilaSeleccionada
        {
            get
            {
                return ((Session[LLAVE_FILA_SELECCIONADA] != null) ? int.Parse(Session[LLAVE_FILA_SELECCIONADA].ToString()) : -1);
            }

            set
            {
                Session[LLAVE_FILA_SELECCIONADA] = value.ToString();
            }
        }

        /// <summary>
        /// Permite obetener la lista de los códigos de los catálogos usados en este mantenimiento
        /// </summary>
        public string ListaCodigosCatalogos
        {
            get
            {
                return "|" + ((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_OPERACION_ESPECIAL).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPO_MITIGADOR).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPO_PERSONA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPOS_DOCUMENTOS).ToString() + "|";
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo Catálogos
        /// </summary>
        public clsCatalogos<clsCatalogo> ListaCatalogosGF
        {
            get
            {
                if (ViewState[LLAVE_ENTIDAD_CATALOGOS] != null)
                {
                    return new clsCatalogos<clsCatalogo>(((string)ViewState[LLAVE_ENTIDAD_CATALOGOS]));
                }
                else
                {
                    return Gestor.ObtenerCatalogos(ListaCodigosCatalogos);
                }
            }

            set
            {
                ViewState.Add(LLAVE_ENTIDAD_CATALOGOS, value.TramaCatalogo);
            }
        }

        #endregion Propiedades

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnIngresos.Click += new EventHandler(btnIngresos_Click);
            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnValidarOperacion.Click += new EventHandler(btnValidarOperacion_Click);
            btnValidarTarjeta.Click += new EventHandler(btnValidarTarjeta_Click);
            cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
            imgCalculadoraGF.Click += new ImageClickEventHandler(ImageButton_Click); 
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

            txtPorcentajeAceptacion.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeAceptacion.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

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
                    seRedirecciona = false;
                    urlPaginaMensaje = string.Empty;

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
                                CargarDatosSession();
                                BloquearCampos(true);
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                btnBuscarFiador.Visible = false;
                                txtFechaExpiracion.Enabled = true;
                                txtFechaExpiracion.ReadOnly = false;
                                btnIngresos.Enabled = true;

                                contenedorDatosModificacion.Visible = false;

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
                                     (Session["Accion"].ToString() == "FIADOR_MOD") ||
                                     (Session["Accion"].ToString() == "PR_MOD")))
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

                            if (FilaSeleccionada != -1)
                            {
                                CommandEventArgs comando = new CommandEventArgs("SelectedFiador", FilaSeleccionada.ToString());
                                GridViewCommandEventArgs evento = new GridViewCommandEventArgs(gdvGarantiasFiduciarias, comando);
                                this.gdvGarantiasFiduciarias_RowCommand(gdvGarantiasFiduciarias, evento);
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
                    {
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=1" +
                                            "&strTitulo=" + "Acceso Denegado" +
                                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                                            "&bBotonVisible=0");
                    }
                    else
                    {
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando Página" +
                                        "&strMensaje=" + ex.Message +
                                        "&bBotonVisible=0");
                    }
                }

                if (seRedirecciona)
                {
                    Response.Redirect(urlPaginaMensaje, true);
                }
            }

            if ((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString()))
            {
                txtObservacion.Visible = true;
                lblObservacion.Visible = true;
            }
        }

        /// <summary>
        /// Este evento permite insertar una garantía fiduciaria a una operación crediticia
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, EventArgs e)
        {
            decimal porcentajeResponsabilidad;
            decimal porcentajeAceptacion;
            string strTrama = string.Empty;
            string strCodigoEstadoTarjeta = string.Empty;

            try
            {
                if (ValidarGarantiaTarjeta())
                {
                    porcentajeResponsabilidad = Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text : "0"));
                    porcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                    Session["Accion"] = "INSERTAR";
                    GuardarDatosSession();

                    bool bActualizacionSistar = false;

                    if ((Session["Plazo"] == null) || ((Session["Plazo"] != null) && (Session["Plazo"].ToString().CompareTo("01") != 0)))
                    {
                        bActualizacionSistar = Gestor.ModificarGarantiaSISTAR(txtTarjeta.Text.Trim(), "01");
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
                                                             porcentajeResponsabilidad,
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
                                                             Convert.ToInt32(ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"].ToString()),
                                                             porcentajeAceptacion);

                        string[] mensajes = MostrarMensaje(nMensaje, 1);

                        contenedorDatosModificacion.Visible = false;

                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
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
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Insertando Registro" +
                                        "&strMensaje=" + "No se pudo insertar la garantía fiduciaria. " + "\r" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        /// <summary>
        /// Este evento permite limpiar el formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, EventArgs e)
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

                lblFechaReplica.Text = string.Empty;
                lblFechaModificacion.Text = string.Empty;
                lblUsrModifico.Text = string.Empty;

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
        private void btnModificar_Click(object sender, EventArgs e)
        {
            string strOperacionCrediticia = string.Empty;

            try
            {
                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) != int.Parse(Application["TARJETA"].ToString()))
                {
                    if (ValidarDatos())
                    {
                        Session["Accion"] = "MODIFICAR";

                        GuardarDatosSession();

                        clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

                        //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                        switch (oGarantia.TipoOperacion)
                        {
                            case ((int)Enumeradores.Tipos_Operaciones.Directa):
                                strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Producto.ToString(), oGarantia.Numero.ToString());
                                break;
                            case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                                strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Numero.ToString());
                                break;
                            default:
                                break;
                        }

                        Gestor.ModificarGarantiaFiduciaria(oGarantia, strOperacionCrediticia, Request.UserHostAddress.ToString());

                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=0" +
                                            "&strTitulo=" + "Modificación Exitosa" +
                                            "&strMensaje=" + "La información de la garantía fiduciaria se modificó satisfactoriamente." +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                    else
                    {
                        contenedorDatosModificacion.Visible = true;
                    }
                }
                else
                {
                    if (ValidarGarantiaTarjeta())
                    {
                        Session["Accion"] = "MODIFICAR";

                        decimal porcentajeResponsabilidad = -1;  //ELIMINAR ESTE COMENTARIO HASTA QUE ESTE VALOR SEA CALCULADO// Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text: "0"));
                        decimal porcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                        GuardarDatosSession();
                        Gestor.ModificarGarantiaFiduciariaTarjeta(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                                long.Parse(Session["CodigoTarjeta"].ToString()),
                                                                txtCedulaFiador.Text.Trim(),
                                                                int.Parse(cbTipoFiador.SelectedValue.ToString()),
                                                                txtNombreFiador.Text.Trim(),
                                                                int.Parse(cbMitigador.SelectedValue.ToString()),
                                                                int.Parse(cbTipoDocumento.SelectedValue.ToString()),
                                                                Convert.ToDecimal(txtMontoMitigador.Text),
                                                                porcentajeResponsabilidad,
                                                                int.Parse(cbOperacionEspecial.SelectedValue.ToString()),
                                                                int.Parse(cbTipoAcreedor.SelectedValue.ToString()),
                                                                txtAcreedor.Text.Trim(),
                                                                DateTime.Parse(txtFechaExpiracion.Text.ToString()),
                                                                Convert.ToDecimal(txtMontoCobertura.Text),
                                                                Session["strUSER"].ToString(),
                                                                Request.UserHostAddress.ToString(),
                                                                txtTarjeta.Text, txtObservacion.Text,
                                                                porcentajeAceptacion);

                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
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
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Modificando Registro" +
                                        "&strMensaje=" + "No se pudo modificar la información de la garantía fiduciaria. " + "\r" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        /// <summary>
        /// Este evento permite eliminar una garantía fiduciaria del sistema
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEliminar_Click(object sender, EventArgs e)
        {
            string strOperacionCrediticia = string.Empty;

            if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) != int.Parse(Application["TARJETA"].ToString()))
            {
                try
                {
                    GuardarDatosSession();

                    //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                    clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

                    //Se crea el dato correspondiente a operación crediticia que se almacenará en la bitácora
                    switch (oGarantia.TipoOperacion)
                    {
                        case ((int)Enumeradores.Tipos_Operaciones.Directa):
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Producto.ToString(), oGarantia.Numero.ToString());
                            break;
                        case ((int)Enumeradores.Tipos_Operaciones.Contrato):
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", oGarantia.Contabilidad.ToString(), oGarantia.Oficina.ToString(), oGarantia.Moneda.ToString(), oGarantia.Numero.ToString());
                            break;
                        default:
                            break;
                    }

                    Session["Accion"] = "ELIMINAR";

                    Gestor.EliminarGarantiaFiduciaria(long.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                    ConsecutivoOperacion,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString(), strOperacionCrediticia);
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
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
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
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

                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
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
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=1" +
                                            "&strTitulo=" + "Problemas Eliminando Registro" +
                                            "&strMensaje=" + "No se pudo eliminar la garantía fiduciaria." + "\r" + ex.Message +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }

            if (seRedirecciona)
            {
                contenedorDatosModificacion.Visible = false;
                FilaSeleccionada = -1;

                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        /// <summary>
        /// Este evento permite verificar si la información de la operación es valida
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarOperacion_Click(object sender, EventArgs e)
        {
            DataSet dsDatos = new DataSet();

            try
            {
                int nProducto = -1;
                int nContabilidad;
                int nOficina;
                int nMoneda;
                long nOperacion;

                Session["Tipo_Operacion"] = cbTipoCaptacion.SelectedValue.ToString();
                FilaSeleccionada = -1;

                if (ValidarDatosOperacion())
                {
                    /*Se modifica la forma en como se validna las operaciones, esto para poder obtener la información de los contratos vencidos con giros activos*/
                    string strProducto = (((Session["Tipo_Operacion"] != null) && (Session["Tipo_Operacion"].ToString().Length > 0) && (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))) ? txtProducto.Text : string.Empty);

                    nContabilidad = ((int.TryParse(txtContabilidad.Text, out nContabilidad)) ? nContabilidad : -1);
                    nOficina = ((int.TryParse(txtOficina.Text, out nOficina)) ? nOficina : -1);
                    nMoneda = ((int.TryParse(txtMoneda.Text, out nMoneda)) ? nMoneda : -1);
                    nProducto = ((int.TryParse(((strProducto.Length > 0) ? strProducto : "-1"), out nProducto)) ? nProducto : -1);
                    nOperacion = ((long.TryParse(txtOperacion.Text, out nOperacion)) ? nOperacion : -1);

                    clsOperacionCrediticia oOperacion = Gestor.ValidarOperacion(nContabilidad, nOficina, nMoneda, nProducto, nOperacion);

                    if (oOperacion.EsValida)
                    {
                        BloquearCampos(true);

                        EsGiro = oOperacion.EsGiro;

                        ConsecutivoContrato = oOperacion.ConsecutivoContrato;

                        _contratoDelGiro = oOperacion.FormatoLargoContrato;

                        if (!EsGiro)
                        {
                            ConsecutivoOperacion = oOperacion.ConsecutivoOperacion;

                            Session["Deudor"] = oOperacion.CedulaDeudor;

                            CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                        ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                        nContabilidad,
                                        nOficina,
                                        nMoneda,
                                        nProducto,
                                        nOperacion);

                            lblDeudor.Visible = true;
                            lblNombreDeudor.Visible = true;
                            string nombreDeudor = string.Format("{0} - {1}", oOperacion.CedulaDeudor, oOperacion.NombreDeudor);
                            Session["Nombre_Deudor"] = nombreDeudor;
                            lblNombreDeudor.Text = nombreDeudor;
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
                        Session["Nombre_Deudor"] = string.Empty;

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
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + ex.Message +
                                    "&bBotonVisible=0");
            }            

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        /// <summary>
        /// Este evento permite validar el tipo de operación que se desea utilizar
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cbTipoCaptacion_SelectedIndexChanged(object sender, EventArgs e)
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarTarjeta_Click(object sender, EventArgs e)
        {
            string strTrama = string.Empty;
            string cedula = string.Empty;
            string numeroTarjeta = string.Empty;
            string descripcionError = string.Empty;
            clsTarjeta informacionTarjeta = new clsTarjeta();

            XmlDocument xmlTrama = new XmlDocument();
            XmlDocument xmlTarjeta = new XmlDocument();

            string strCodigoEstadoTarjeta = string.Empty;

            try
            {
                txtObservacion.Visible = true;
                lblObservacion.Visible = true;

                Session["Tipo_Operacion"] = cbTipoCaptacion.SelectedValue.ToString();
                FilaSeleccionada = -1;

                if (ValidarFormatoTarjeta())
                {
                    numeroTarjeta = txtTarjeta.Text;
                    decimal nBin = Convert.ToDecimal(txtTarjeta.Text.Substring(0, 6));

                    if (Gestor.Verifica_Tarjeta_Sistar(nBin))
                    {
                        #region Método de Validación Anterior
                        //strTrama = new CreaXML().creaXMLConsultaTarjetaSISTAR(txtTarjeta.Text, "");

                        //ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
                        //                                                                                Application["Cola_Entrada"].ToString(),
                        //                                                                                Application["Cola_Salida"].ToString(),
                        //                                                                                strTrama,
                        //                                                                                Application["Cola_Respuesta"].ToString(),
                        //                                                                                Application["IP"].ToString(),
                        //                                                                                Application["Channel"].ToString(),
                        //                                                                                Application["Port"].ToString());

                        //string strTramaRespuesta = oMQ.respuestaMQ();

                        #endregion Método de Validación Anterior

                        informacionTarjeta = Gestor.ValidarTarjetaSISTAR(numeroTarjeta);

                        if ((informacionTarjeta != null) && (informacionTarjeta.TarjetaValida))
                        {
                            if (!informacionTarjeta.EsMasterCard)
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
                            else if (informacionTarjeta.EsMasterCard)
                            {
                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = string.Format("{0} - {1}", informacionTarjeta.CedulaDeudor, informacionTarjeta.NombreDeudor.Trim());

                                BloquearCampos(true);
                                Session["Tarjeta"] = txtTarjeta.Text.Trim();
                                Session["Deudor"] = informacionTarjeta.CedulaDeudor;
                                Session["Bin"] = informacionTarjeta.NumeroBin.ToString();
                                Session["CodigoInternoSISTAR"] = informacionTarjeta.CodigoInternoSistar.ToString();
                                Session["Moneda"] = informacionTarjeta.CodigoMoneda.ToString();
                                Session["Oficina_Registra"] = informacionTarjeta.CodigoOficinaRegistra.ToString();

                                if (informacionTarjeta.CodigoTipoGarantia != -1)
                                {
                                    Session["Plazo"] = informacionTarjeta.CodigoTipoGarantia.ToString();

                                    if (Gestor.CodigoTipoTarjetaEsPerfil(informacionTarjeta.CodigoTipoGarantia))
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

                                strCodigoEstadoTarjeta = informacionTarjeta.EstadoTarjeta.Trim();

                                if (strCodigoEstadoTarjeta.Length > 0)
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
                            lblMensaje.Text = informacionTarjeta.DescripcionError;
                            lblDeudor.Text = "";
                            lblNombreDeudor.Text = "";

                            gdvGarantiasFiduciarias.DataSource = null;
                            gdvGarantiasFiduciarias.DataBind();
                        }

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
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando Página" +
                                        "&strMensaje=" + "No hay comunicación con el sistema SISTAR" +
                                        "&bBotonVisible=0");
                }
                else if (ex.Message.Contains("CODIGORESPUESTA"))
                {
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                       "bError=1" +
                                       "&strTitulo=" + "Problemas Cargando Página" +
                                       "&strMensaje=" + "No hay comunicación con el sistema  utilizado para obtener la información de la tarjeta (Sistema MQ)" +
                                       "&bBotonVisible=0");
                }
                else
                {
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando Página" +
                                        "&strMensaje=" + ex.Message +
                                        "&bBotonVisible=0");
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
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

        private void ImageButton_Click(object sender, ImageClickEventArgs e)
        {
            string tipoPersona = cbTipoFiador.SelectedItem.Value;
            string cedulaFiador = txtCedulaFiador.Text;

            lblMensaje3.Text = string.Empty;
            lblMensaje.Text = string.Empty;

            if (btnModificar.Enabled)
                Session["Accion"] = "PR_MOD";
            else
                Session["Accion"] = "";

            GuardarDatosSession();

            if ((tipoPersona.Length > 0) && (tipoPersona.CompareTo("-1") != 0) && (cedulaFiador.Length > 0))
            {
                string url = "frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx?tipogarantia=1&tipofiador=" + Server.HtmlEncode(tipoPersona) + "&idfiador=" + Server.HtmlEncode(cedulaFiador);
                Response.Redirect(url);
            }
            else {
                if ((tipoPersona.Length > 0) && (tipoPersona.CompareTo("-1") != 0))
                {
                    lblMensaje.Text = "El tipo de persona es requerido";
                }
                else if (cedulaFiador.Length > 0)
                {
                    lblMensaje.Text = "La cédula del fiador es requerido";
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
                        FilaSeleccionada = rowIndex;

                        #region DATOS

                        //CargarDatos();
                        if (gdvGarantiasFiduciarias.SelectedDataKey[11].ToString() != null)
                            Session["CodigoTarjeta"] = gdvGarantiasFiduciarias.SelectedDataKey[11].ToString();

                        if (gdvGarantiasFiduciarias.SelectedDataKey[3].ToString() != null)
                        {
                            cbTipoFiador.ClearSelection();
                            cbTipoFiador.Items.FindByValue(((cbTipoFiador.Items.FindByValue(gdvGarantiasFiduciarias.SelectedDataKey[3].ToString()) != null) ? gdvGarantiasFiduciarias.SelectedDataKey[3].ToString() : "-1")).Selected = true;
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
                        {
                            cbMitigador.ClearSelection();
                            cbMitigador.Items.FindByValue(((cbMitigador.Items.FindByValue(gdvGarantiasFiduciarias.SelectedDataKey[4].ToString()) != null) ? gdvGarantiasFiduciarias.SelectedDataKey[4].ToString() : "-1")).Selected = true;
                        }

                        CargarTiposDocumentos();
                        if (gdvGarantiasFiduciarias.SelectedDataKey[5].ToString() != null)
                        {
                            cbTipoDocumento.ClearSelection();
                            cbTipoDocumento.Items.FindByValue(((cbTipoDocumento.Items.FindByValue(gdvGarantiasFiduciarias.SelectedDataKey[5].ToString()) != null) ? gdvGarantiasFiduciarias.SelectedDataKey[5].ToString() : "-1")).Selected = true;
                        }

                        if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[6].ToString()))
                        {
                            decimal nMontoMitigador = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[6].ToString());
                            txtMontoMitigador.Text = nMontoMitigador.ToString("N2");
                        }
                        else
                        {
                            txtMontoMitigador.Text = "0.00";
                        }

                        if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[7].ToString()))
                        {
                            decimal porcentajeResponsabilidad = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[7].ToString());
                            txtPorcentajeResponsabilidad.Text = ((porcentajeResponsabilidad > -1) ? porcentajeResponsabilidad.ToString("N2") : "0.00");
                        }
                        else
                        {
                            txtPorcentajeResponsabilidad.Text = "0.00";
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[9].ToString() != null)
                        {
                            cbTipoAcreedor.ClearSelection();
                            cbTipoAcreedor.Items.FindByValue(((cbTipoAcreedor.Items.FindByValue(gdvGarantiasFiduciarias.SelectedDataKey[9].ToString()) != null) ? gdvGarantiasFiduciarias.SelectedDataKey[9].ToString() : "-1")).Selected = true;
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[10].ToString() != null)
                            txtAcreedor.Text = gdvGarantiasFiduciarias.SelectedDataKey[10].ToString();
                        else
                            txtAcreedor.Text = "";

                        if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[19].ToString()))
                        {
                            decimal porcentajeAceptacion = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[19].ToString());
                            txtPorcentajeAceptacion.Text = ((porcentajeAceptacion > -1) ? porcentajeAceptacion.ToString("N2") : "0.00");
                        }
                        else
                        {
                            txtPorcentajeAceptacion.Text = "0.00";
                        }


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

                            if (!string.IsNullOrEmpty(gdvGarantiasFiduciarias.SelectedDataKey[17].ToString()))
                            {
                                decimal porcentajeAceptacion = Convert.ToDecimal(gdvGarantiasFiduciarias.SelectedDataKey[17].ToString());
                                txtPorcentajeAceptacion.Text = ((porcentajeAceptacion > -1) ? porcentajeAceptacion.ToString("N2") : "0.00");
                            }
                            else
                            {
                                txtPorcentajeAceptacion.Text = "0.00";
                            }
                        }

                        if (gdvGarantiasFiduciarias.SelectedDataKey[8].ToString() != null)
                        {
                            cbOperacionEspecial.ClearSelection();
                            cbOperacionEspecial.Items.FindByValue(((cbOperacionEspecial.Items.FindByValue(gdvGarantiasFiduciarias.SelectedDataKey[8].ToString()) != null) ? gdvGarantiasFiduciarias.SelectedDataKey[8].ToString() : "-1")).Selected = true;
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
                        string fechaModifico = ((fechaModificacion != DateTime.Parse("01/01/1900 12:00:00 AM")) ? fechaModificacion.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);
                        string fechaReplica = ((fechaReplicag != DateTime.Parse("01/01/1900 12:00:00 AM")) ? (fechaReplicag.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty);

                        ViewState.Add(LLAVE_FECHA_MODIFICACION, fechaModifico);
                        ViewState.Add(LLAVE_FECHA_REPLICA, fechaReplica);

                        lblUsrModifico.Text = "Usuario Modificó: " + usuarioModifico;
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

            CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
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
                                                "Usuario_Modifico","Nombre_Usuario_Modifico","Fecha_Modifico","Fecha_Inserto","Fecha_Replica", "Porcentaje_Aceptacion"};

                string[] strLlavesTarjeta = {"tipo_persona", "cedula_fiador", "nombre_fiador", "cod_tipo_fiador", "cod_tipo_mitigador",
                                             "cod_tipo_documento_legal", "monto_mitigador", "porcentaje_responsabilidad", "cod_operacion_especial",
                                             "cod_tipo_acreedor", "cedula_acreedor", "cod_operacion", "cod_garantia_fiduciaria", "cod_estado",
                                             "fecha_expiracion", "monto_cobertura", "des_observacion", "Porcentaje_Aceptacion"};

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
                    oComando.Parameters.AddWithValue("@psNumero_Tarjeta", txtTarjeta.Text.Trim());

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

        /// <summary>
        /// Este método guarda los datos de la pantalla en el objeto Session
        /// </summary>
        private void GuardarDatosSession()
        {
            DateTime fechaBase = new DateTime(1900, 01, 01);

            try
            {
                clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

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
                oGarantia.CodigoClaseGarantia = int.Parse(Application["CLASE_GARANTIA_FIADOR"].ToString());
                //Informacion del fiador
                oGarantia.CodigoTipoPersonaFiador = int.Parse(cbTipoFiador.SelectedValue.ToString());
                oGarantia.CedulaFiador = txtCedulaFiador.Text.Trim();
                oGarantia.NombreFiador = txtNombreFiador.Text.Trim();
                oGarantia.CodigoTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.CodigoTipoDocumentoLegal = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                oGarantia.MontoMitigador = Convert.ToDecimal(((txtMontoMitigador.Text.Trim().Length > 0) ? txtMontoMitigador.Text : "0"));

                oGarantia.PorcentajeResponsabilidad = Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text : "-1"));

                oGarantia.PorcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                oGarantia.CodigoTipoPersonaAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.CodigoOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                oGarantia.FechaExpiracion = ((txtFechaExpiracion.Text.Trim().Length > 0) ? DateTime.Parse(txtFechaExpiracion.Text.ToString()) : fechaBase);

                oGarantia.MontoCobertura = Convert.ToDecimal(((txtMontoCobertura.Text.Trim().Length > 0) ? txtMontoCobertura.Text : "0"));

                oGarantia.UsuarioModifico = lblUsrModifico.Text.Trim();

                if ((ViewState[LLAVE_FECHA_MODIFICACION] != null))
                {
                    if (ViewState[LLAVE_FECHA_MODIFICACION].ToString().Length > 0)
                    {
                        oGarantia.FechaModifico = DateTime.Parse(ViewState[LLAVE_FECHA_MODIFICACION].ToString());
                    }
                }

                if ((ViewState[LLAVE_FECHA_REPLICA] != null))
                {
                    if (ViewState[LLAVE_FECHA_REPLICA].ToString().Length > 0)
                    {
                        oGarantia.FechaReplica = DateTime.Parse(ViewState[LLAVE_FECHA_REPLICA].ToString());
                    }
                }

                oGarantia.ConsecutivoGarantiaFiduciaria = long.Parse((((Session["GarantiaFiduciaria"] != null) && (Session["GarantiaFiduciaria"].ToString().Length > 0)) ? Session["GarantiaFiduciaria"].ToString() : "-1"));
                oGarantia.ConsecutivoOperacion = ConsecutivoOperacion;
                oGarantia.UsuarioModifico = Session["strUSER"].ToString();

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
                clsGarantiaFiduciaria oGarantia = clsGarantiaFiduciaria.Current;

                //Campos llave
                cbTipoCaptacion.Items.FindByValue(((oGarantia.TipoOperacion != 0) ? oGarantia.TipoOperacion.ToString() : "1")).Selected = true;

                if (oGarantia.TipoOperacion != int.Parse(Application["TARJETA"].ToString()))
                {
                    txtContabilidad.Text = ((oGarantia.Contabilidad != 0) ? oGarantia.Contabilidad.ToString() : string.Empty);

                    txtOficina.Text = ((oGarantia.Oficina != 0) ? oGarantia.Oficina.ToString() : string.Empty);

                    txtMoneda.Text = ((oGarantia.Moneda != 0) ? oGarantia.Moneda.ToString() : string.Empty);

                    if (oGarantia.TipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                    {
                        lblProducto.Visible = true;
                        txtProducto.Visible = true;

                        txtProducto.Text = ((oGarantia.Producto != 0) ? oGarantia.Producto.ToString() : string.Empty);
                    }
                    else
                    {
                        lblProducto.Visible = false;
                        txtProducto.Visible = false;
                    }

                    txtOperacion.Text = ((oGarantia.Numero != 0) ? oGarantia.Numero.ToString() : string.Empty);
                }
                else
                {
                    txtTarjeta.Text = oGarantia.Tarjeta;

                    txtObservacion.Text = oGarantia.Observacion;
                }

                //Informacion del fiador
                cbTipoFiador.ClearSelection();
                cbTipoFiador.Items.FindByValue(((oGarantia.CodigoTipoPersonaFiador != 0) ? oGarantia.CodigoTipoPersonaFiador.ToString() : "-1")).Selected = true;

                txtCedulaFiador.Text = ((oGarantia.CedulaFiador != null) ? oGarantia.CedulaFiador : string.Empty);

                txtNombreFiador.Text = ((oGarantia.NombreFiador != null) ? oGarantia.NombreFiador : string.Empty);

                cbMitigador.ClearSelection();
                cbMitigador.Items.FindByValue(((oGarantia.CodigoTipoMitigador != -1) ? oGarantia.CodigoTipoMitigador.ToString() : "-1")).Selected = true;

                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.Items.FindByValue(((oGarantia.CodigoTipoDocumentoLegal != 0) ? oGarantia.CodigoTipoDocumentoLegal.ToString() : "-1")).Selected = true;

                txtMontoMitigador.Text = ((oGarantia.MontoMitigador != 0) ? oGarantia.MontoMitigador.ToString("N2") : "0.00");

                txtPorcentajeResponsabilidad.Text = ((oGarantia.PorcentajeResponsabilidad != -1) ? oGarantia.PorcentajeResponsabilidad.ToString("N2") : "0.00");

                txtPorcentajeAceptacion.Text = ((oGarantia.PorcentajeAceptacion != 0) ? oGarantia.PorcentajeAceptacion.ToString("N2") : "0.00");

                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.FindByValue(((oGarantia.CodigoTipoPersonaAcreedor != 0) ? oGarantia.CodigoTipoPersonaAcreedor.ToString() : "-1")).Selected = true;

                txtAcreedor.Text = ((oGarantia.CedulaAcreedor != null) ? oGarantia.CedulaAcreedor : string.Empty);

                cbOperacionEspecial.ClearSelection();
                cbOperacionEspecial.Items.FindByValue(((oGarantia.CodigoOperacionEspecial != 0) ? oGarantia.CodigoOperacionEspecial.ToString() : "-1")).Selected = true;

                txtFechaExpiracion.Text = oGarantia.FechaExpiracion.ToShortDateString();

                txtMontoCobertura.Text = ((oGarantia.MontoCobertura != 0) ? oGarantia.MontoCobertura.ToString("N2") : "0.00");

                contenedorDatosModificacion.Visible = true;

                lblUsrModifico.Text = string.Format("Usuario Modificó: {0}", ((oGarantia.UsuarioModifico.Length > 0) ? (oGarantia.UsuarioModifico) : string.Empty));
                lblFechaModificacion.Text = string.Format("Fecha Modificación: {0}", ((oGarantia.FechaModifico != DateTime.MinValue) ? oGarantia.FechaModifico.ToString("dd/MM/yyyy") : string.Empty));
                lblFechaReplica.Text = string.Format("Fecha Replica: {0}", ((oGarantia.FechaReplica != DateTime.MinValue) ? (oGarantia.FechaReplica.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty));

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
                //txtPorcentajeResponsabilidad.Enabled = bBloqueado;
                cbOperacionEspecial.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtMontoCobertura.Enabled = bBloqueado;
                txtPorcentajeAceptacion.Enabled = bBloqueado;
                //Botones
                btnIngresos.Enabled = bBloqueado;
                btnInsertar.Enabled = bBloqueado;
                btnModificar.Enabled = bBloqueado;
                btnLimpiar.Enabled = bBloqueado;
                //Mensajes
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

                imgCalculadoraGF.Enabled = bBloqueado;
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
            if (!ListaCatalogosGF.ErrorDatos)
            {
                List<clsCatalogo> listaTiposMitigadoress = ListaCatalogosGF.Items(((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPO_MITIGADOR));

                cbMitigador.DataSource = null;
                cbMitigador.DataSource = listaTiposMitigadoress;
                cbMitigador.DataValueField = "CodigoElemento";
                cbMitigador.DataTextField = "DescripcionCodigoElemento";
                cbMitigador.DataBind();
                cbMitigador.ClearSelection();
                cbMitigador.Items.FindByValue("0").Selected = true;
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGF.DescripcionError;
            }          
        }

        private void CargarOperacionEspecial()
        {
            if (!ListaCatalogosGF.ErrorDatos)
            {
                List<clsCatalogo> listaTiposOperacionesEspeciales = ListaCatalogosGF.Items(((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_OPERACION_ESPECIAL));

                cbOperacionEspecial.DataSource = null;
                cbOperacionEspecial.DataSource = listaTiposOperacionesEspeciales;
                cbOperacionEspecial.DataValueField = "CodigoElemento";
                cbOperacionEspecial.DataTextField = "DescripcionCodigoElemento";
                cbOperacionEspecial.DataBind();
                cbOperacionEspecial.ClearSelection();
                cbOperacionEspecial.Items.FindByValue(Application["DEFAULT_OPERACION_ESPECIAL"].ToString()).Selected = true;
           }
            else
            {
                lblMensaje.Text = ListaCatalogosGF.DescripcionError;
            }
         }

        private void CargarTiposDocumentos()
        {
            if (!ListaCatalogosGF.ErrorDatos)
            {
                List<clsCatalogo> listaTiposDocumentosLegales = ListaCatalogosGF.Items(((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPOS_DOCUMENTOS));

                cbTipoDocumento.DataSource = null;
                cbTipoDocumento.DataSource = listaTiposDocumentosLegales;
                cbTipoDocumento.DataValueField = "CodigoElemento";
                cbTipoDocumento.DataTextField = "DescripcionCodigoElemento";
                cbTipoDocumento.DataBind();
                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.Items.FindByValue(Application["DEFAULT_TIPO_DOCUMENTO_LEGAL_FIADORES"].ToString()).Selected = true;
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGF.DescripcionError;
            }
        }

		private void CargarTiposPersona()
		{
            if (!ListaCatalogosGF.ErrorDatos)
            {
                List<clsCatalogo> listaTiposPersona = ListaCatalogosGF.Items(((int)Enumeradores.Catalogos_Garantias_Fiduciarias.CAT_TIPO_PERSONA));

                cbTipoAcreedor.DataSource = null;
                cbTipoAcreedor.DataSource = listaTiposPersona;
                cbTipoAcreedor.DataValueField = "CodigoElemento";
                cbTipoAcreedor.DataTextField = "DescripcionCodigoElemento";
                cbTipoAcreedor.DataBind();
                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.FindByValue(Application["DEFAULT_TIPO_ACREEDOR"].ToString()).Selected = true;

                cbTipoFiador.DataSource = null;
                cbTipoFiador.DataSource = listaTiposPersona;
                cbTipoFiador.DataValueField = "CodigoElemento";
                cbTipoFiador.DataTextField = "DescripcionCodigoElemento";
                cbTipoFiador.DataBind();
                cbTipoFiador.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGF.DescripcionError;
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
                if (bRespuesta && txtPorcentajeAceptacion.Text.Trim().Length == 0)
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
                DataSet dsDatos = Gestor.ObtenerListaGarantiasFiduciarias(nTipoOperacion, nCodOperacion, nContabilidad, nOficina, nMoneda, nProducto, nOperacion, Session["strUSER"].ToString());
                
                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Datos"].Rows[0].IsNull(clsGarantiaFiduciaria._codigoTipoPersonaFiador)) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull(clsGarantiaFiduciaria._cedulaFiador)) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull(clsGarantiaFiduciaria._nombreFiador)))
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
                bRespuesta = Gestor.ExisteGarantiaFiduciaria(txtContabilidad.Text, txtOficina.Text, txtMoneda.Text, txtProducto.Text, txtOperacion.Text, (int.Parse(cbTipoCaptacion.SelectedValue.ToString())), txtCedulaFiador.Text, cbTipoFiador.SelectedValue);
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
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
                //txtPorcentajeResponsabilidad.Enabled = bBloqueado;
                cbTipoAcreedor.Enabled = bBloqueado;
                txtAcreedor.Enabled = bBloqueado;
                cbOperacionEspecial.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtMontoCobertura.Enabled = bBloqueado;
                txtFechaExpiracion.Enabled = bBloqueado;
                txtObservacion.Enabled = bBloqueado;
                txtPorcentajeAceptacion.Enabled = bBloqueado;
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
