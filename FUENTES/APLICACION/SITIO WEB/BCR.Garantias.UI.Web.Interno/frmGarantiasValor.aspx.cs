using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Globalization;

using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Comun;
using BCR.GARANTIAS.Entidades;


namespace BCRGARANTIAS.Forms
{
    public partial class frmGarantiasValor : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string LLAVE_CONSECUTIVO_OPERACION        = "LLAVE_CONSECUTIVO_OPERACION";
        private const string LLAVE_CONSECUTIVO_GARANTIA         = "LLAVE_CONSECUTIVO_GARANTIA";
        private const string LLAVE_ES_GIRO                      = "LLAVE_ES_GIRO";
        private const string LLAVE_CONSECUTIVO_CONTRATO         = "LLAVE_CONSECUTIVO_CONTRATO";
        private const string _llaveContratoGiro                 = "_llaveContratoGiro";
        private const string LLAVE_FECHA_REPLICA                = "LLAVE_FECHA_REPLICA";
        private const string LLAVE_FECHA_MODIFICACION           = "LLAVE_FECHA_MODIFICACION";
        private const string LLAVE_FILA_SELECCIONADA            = "LLAVE_FILA_SELECCIONADA";
        #endregion Constantes

        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        protected string strDescInstObt;
        protected string strDescInstNuevo;
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

        #endregion Propiedades

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            Button2.Click += new EventHandler(Button2_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnValidarOperacion.Click += new EventHandler(btnValidarOperacion_Click);
            cbClasificacion.SelectedIndexChanged += new EventHandler(cbClasificacion_SelectedIndexChanged);
            cbTipoCaptacion.SelectedIndexChanged += new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            contenedorDatosModificacion.Visible = false;
            
            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtProducto.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtSeguridad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtAcreedor.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtEmisor.Attributes["onblur"] = "javascript:EsNumerico(this);";

            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la garantía seleccionada?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la garantía seleccionada?')";


            txtMontoMitigador.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoMitigador.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtPorcentajeAceptacion.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeAceptacion.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

            txtPorcentajeResponsabilidad.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeResponsabilidad.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

            txtMontoPrioridades.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoPrioridades.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtPorcentajePremio.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajePremio.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

            txtValorFacial.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtValorFacial.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtValorMercado.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtValorMercado.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");


            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIA_VALOR"].ToString())))
                    {
                        FormatearCamposNumericos();
                        BloquearCampos(((Session["EsOperacionValidaValor"] != null) && bool.Parse(((Session["EsOperacionValidaValor"] != null) ? Session["EsOperacionValidaValor"].ToString() : "false"))));
                        Session["Tipo_Operacion"] = int.Parse(Application["OPERACION_CREDITICIA"].ToString());
                        Session["EsOperacionValida"] = false;
                        Session["EsOperacionValidaReal"] = false;

                        CargarCombos();

                        if ((Session["EsOperacionValidaValor"] != null) && (bool.Parse(Session["EsOperacionValidaValor"].ToString())))
                        {
                            if ((Session["Accion"] == null) || ((Session["Accion"] != null) && (Session["Accion"].ToString().Length == 0)))
                            {
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                            }
                            else if ((Session["Accion"] != null) &&
                                     (Session["Accion"].ToString() == "INSERTAR") ||
                                     (Session["Accion"].ToString() == "MODIFICAR") ||
                                     (Session["Accion"].ToString() == "ELIMINAR"))
                            {
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                //								CargarCombos();
                                LimpiarCampos();
                                contenedorDatosModificacion.Visible = false;

                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();

                                CargarDatosSession();

                            }
                            else if ((Session["Accion"] != null) &&
                               (Session["Accion"].ToString() == "DEUDOR_MOD") ||
                               (Session["Accion"].ToString() == "GARANTIA_MOD"))
                            {
                                btnInsertar.Enabled = false;
                                btnModificar.Enabled = true;
                                btnEliminar.Enabled = true;

                                lblDeudor.Visible = true;
                                lblNombreDeudor.Visible = true;
                                lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();

                                CargarDatosSession();
                            }
                            else
                            {
                                LimpiarCampos();
                                contenedorDatosModificacion.Visible = false;
                            }

                            int nProducto = -1;

                            if (txtProducto.Text.Length > 0)
                                nProducto = int.Parse(txtProducto.Text);

                            if ((cbTipoCaptacion.SelectedItem.Selected) && (cbTipoCaptacion.SelectedValue.Length > 0)
                                && (txtContabilidad.Text.Length > 0) && (txtOficina.Text.Length > 0)
                                && (txtOperacion.Text.Length > 0))
                            {
                                CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
                                            ((EsGiro) ? ConsecutivoContrato : ConsecutivoOperacion),
                                            int.Parse(txtContabilidad.Text),
                                            int.Parse(txtOficina.Text),
                                            int.Parse(txtMoneda.Text),
                                            nProducto,
                                            long.Parse(txtOperacion.Text));
                            }
                        }

                        #region Bloquear campos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012

                        cbInscripcion.Enabled = false;

                        #endregion Bloquear campos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012

                        if (FilaSeleccionada != -1)
                        {
                            CommandEventArgs comando = new CommandEventArgs("SelectedGarantiaValor", FilaSeleccionada.ToString());
                            GridViewCommandEventArgs evento = new GridViewCommandEventArgs(gdvGarantiasValor, comando);
                            gdvGarantiasValor_RowCommand(gdvGarantiasValor, evento);
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
                    Utilitarios.RegistraEventLog("Problemas Cargando Página. Detalle Técnico: " + ex.Message + " Trace: " + ex.StackTrace, EventLogEntryType.Error);

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
        }

        private void cbClasificacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            //Número de cuenta de deposito
            if (int.Parse(cbClasificacion.SelectedValue.ToString()) == 5)
            {
                cbInstrumento.SelectedIndex = -1;
                cbInstrumento.Visible = false;
                txtInstrumento.Visible = true;
            }
            else
            {
                cbInstrumento.Visible = true;
                txtInstrumento.Visible = false;
            }

            if (FilaSeleccionada != -1)
            {
                contenedorDatosModificacion.Visible = true;
            }
        }

        private void Button2_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
        }

        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                decimal nPorcentaje = -1;
                
                Session["Accion"] = "INSERTAR";
                
                if (ValidarDatos())
                {
                    if (ValidarGarantiaValor())
                    {
                        int tipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue);
                        long nOperacion = ConsecutivoOperacion;
                        int nTipoGarantia = int.Parse(Application["GARANTIA_VALOR"].ToString());
                        int nClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue);
                        string strSeguridad = txtSeguridad.Text.Trim();

                        DateTime dFechaConstitucion = DateTime.Parse(((txtFechaConstitucion.Text.Trim().Length > 0) ? txtFechaConstitucion.Text : "1900-01-01"));

                        DateTime dFechaVencimiento = DateTime.Parse(((txtFechaVencimiento.Text.Trim().Length > 0) ? txtFechaVencimiento.Text : "1900-01-01"));

                        DateTime dFechaPrescripcion = DateTime.Parse(((txtFechaPrescripcion.Text.Trim().Length > 0) ? txtFechaPrescripcion.Text : "1900-01-01"));

                        int nClasificacion = int.Parse(cbClasificacion.SelectedValue);
                        string  strInstrumento = cbInstrumento.SelectedValue;
                        string strSerie = txtSerie.Text.Trim();
                        int nTipoEmisor = int.Parse(cbTipoEmisor.SelectedValue);
                        string strEmisor = txtEmisor.Text.Trim();

                        decimal nPremio = ((decimal.TryParse(((txtPorcentajePremio.Text.Length > 0) ? txtPorcentajePremio.Text : "0"), out nPremio)) ? nPremio : 0);

                        string strISIN = cbISIN.SelectedValue;

                        decimal nValorFacial = ((decimal.TryParse(((txtValorFacial.Text.Length > 0) ? txtValorFacial.Text : "0"), out nValorFacial)) ? nValorFacial : 0);

                        int nMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue);

                        decimal nValorMercado = ((decimal.TryParse(((txtValorMercado.Text.Length > 0) ? txtValorMercado.Text : "0"), out nValorMercado)) ? nValorMercado : 0);
 
                        int nMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue);
                        int nTenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                        
                        int nTipoMitigador = int.Parse(cbMitigador.SelectedValue);
                        int nTipoDocumento = int.Parse(cbTipoDocumento.SelectedValue);
                        decimal nMontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text);
                        int nInscripcion = int.Parse(cbInscripcion.SelectedValue);

                        int nGradoGravamen = int.Parse(cbGravamen.SelectedValue);
                        int nGradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue);

                        decimal nMontoPrioridades = ((decimal.TryParse(((txtMontoPrioridades.Text.Length > 0) ? txtMontoPrioridades.Text : "0"), out nMontoPrioridades)) ? nMontoPrioridades : 0);

                        int nOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue);
                        int nTipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue);
                        string strAcreedor = txtAcreedor.Text.Trim();

                        decimal porcentajeAceptacion = ((decimal.TryParse(((txtPorcentajeAceptacion.Text.Length > 0) ? txtPorcentajeAceptacion.Text : "0"), out porcentajeAceptacion)) ? porcentajeAceptacion : 0);

                        string strOperacionCrediticia = string.Empty;

                        if(tipoOperacion == ((int) Enumeradores.Tipos_Operaciones.Directa))
                        {
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtProducto.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                        }
                        else
                        {
                            strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                        }

                        Gestor.CrearGarantiaValor(nOperacion, nTipoGarantia, nClaseGarantia, strSeguridad,
                                                dFechaConstitucion, dFechaVencimiento, nClasificacion, strInstrumento,
                                                strSerie, nTipoEmisor, strEmisor, nPremio, strISIN, nValorFacial,
                                                nMonedaValorFacial, nValorMercado, nMonedaValorMercado, nTenencia,
                                                dFechaPrescripcion, nTipoMitigador, nTipoDocumento, nMontoMitigador,
                                                nInscripcion, nPorcentaje, nGradoGravamen,
                                                nGradoPrioridades, nMontoPrioridades, nOperacionEspecial,
                                                nTipoAcreedor, strAcreedor,
                                                Session["strUSER"].ToString(),
                                                Request.UserHostAddress.ToString(), strOperacionCrediticia,
                                                cbInstrumento.SelectedItem.Text, porcentajeAceptacion);

                        CargarCombos();
                        LimpiarCampos();
                        GuardarDatosSession(true);

                        contenedorDatosModificacion.Visible = false;
 
                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=0" +
                                            "&strTitulo=" + "Inserción Exitosa" +
                                            "&strMensaje=" + "La garantía de valor se insertó satisfactoriamente." +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=frmGarantiasValor.aspx");
                    }
                    else
                        lblMensaje2.Text = "Ya existe esta garantía de valor. Por favor verifique...";
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
                                        "&strMensaje=" + "No se pudo insertar la garantía de valor. Error: " + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasValor.aspx");
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                LimpiarCampos();
                CargarCombos();
                BloquearCampos(true);
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;

                contenedorDatosModificacion.Visible = false;

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
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            decimal nPorcentaje = -1;
            Session["Accion"] = "MODIFICAR";
 
            try
            {
                if (ValidarDatos())
                {

                    int tipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue);
                    long nOperacion = ConsecutivoOperacion;
                    int nTipoGarantia = int.Parse(Application["GARANTIA_VALOR"].ToString());
                    int nClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue);
                    string strSeguridad = txtSeguridad.Text.Trim();

                    DateTime dFechaConstitucion = DateTime.Parse(((txtFechaConstitucion.Text.Trim().Length > 0) ? txtFechaConstitucion.Text : "1900-01-01"));

                    DateTime dFechaVencimiento = DateTime.Parse(((txtFechaVencimiento.Text.Trim().Length > 0) ? txtFechaVencimiento.Text : "1900-01-01"));

                    DateTime dFechaPrescripcion = DateTime.Parse(((txtFechaPrescripcion.Text.Trim().Length > 0) ? txtFechaPrescripcion.Text : "1900-01-01"));

                    int nClasificacion = int.Parse(cbClasificacion.SelectedValue);
                    string strInstrumento = (((int.Parse(cbClasificacion.SelectedValue) != -1) && (int.Parse(cbClasificacion.SelectedValue) != 5)) ? cbInstrumento.SelectedValue : txtInstrumento.Text.Trim());
                    strDescInstNuevo = (((int.Parse(cbClasificacion.SelectedValue) != -1) && (int.Parse(cbClasificacion.SelectedValue) != 5)) ? cbInstrumento.SelectedItem.Text : txtInstrumento.Text.Trim());

                    string strSerie = txtSerie.Text.Trim();
                    int nTipoEmisor = int.Parse(cbTipoEmisor.SelectedValue);
                    string strEmisor = txtEmisor.Text.Trim();

                    decimal nPremio = ((decimal.TryParse(((txtPorcentajePremio.Text.Length > 0) ? txtPorcentajePremio.Text : "0"), out nPremio)) ? nPremio : 0);

                    string strISIN = cbISIN.SelectedValue;

                    decimal nValorFacial = ((decimal.TryParse(((txtValorFacial.Text.Length > 0) ? txtValorFacial.Text : "0"), out nValorFacial)) ? nValorFacial : 0);

                    int nMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue);

                    decimal nValorMercado = ((decimal.TryParse(((txtValorMercado.Text.Length > 0) ? txtValorMercado.Text : "0"), out nValorMercado)) ? nValorMercado : 0);

                    int nMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue);
                    int nTenencia = int.Parse(cbTenencia.SelectedValue);

                    if (txtPorcentajePremio.Text.Trim().Length > 0)
                        nPremio = Convert.ToDecimal(txtPorcentajePremio.Text);
                    
                    int nTipoMitigador = int.Parse(cbMitigador.SelectedValue);
                    int nTipoDocumento = int.Parse(cbTipoDocumento.SelectedValue);
                    decimal nMontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text);
                    int nInscripcion = int.Parse(cbInscripcion.SelectedValue);

                    int nGradoGravamen = int.Parse(cbGravamen.SelectedValue);
                    int nGradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue);

                    decimal nMontoPrioridades = ((decimal.TryParse(((txtMontoPrioridades.Text.Length > 0) ? txtMontoPrioridades.Text : "0"), out nMontoPrioridades)) ? nMontoPrioridades : 0);

                    int nOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue);
                    int nTipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue);
                    string strAcreedor = txtAcreedor.Text.Trim();

                    decimal porcentajeAceptacion = ((decimal.TryParse(((txtPorcentajeAceptacion.Text.Length > 0) ? txtPorcentajeAceptacion.Text : "0"), out porcentajeAceptacion)) ? porcentajeAceptacion : 0);

                    string strOperacionCrediticia = string.Empty;

                    if (tipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Directa))
                    {
                        strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtProducto.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                    }
                    else
                    {
                        strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                    }
                    
                    if (Session["DecripcionInstrumento"] != null)
                    {
                        strDescInstObt = Session["DecripcionInstrumento"].ToString();
                    }
                    else
                    {
                        strDescInstObt = strDescInstNuevo;
                    }

                    Gestor.ModificarGarantiaValor(ConsecutivoOperacion,
                                                    long.Parse(Session["GarantiaValor"].ToString()),
                                                    nTipoGarantia, nClaseGarantia, strSeguridad,
                                                    dFechaConstitucion, dFechaVencimiento, nClasificacion, strInstrumento,
                                                    strSerie, nTipoEmisor, strEmisor, nPremio, strISIN, nValorFacial,
                                                    nMonedaValorFacial, nValorMercado, nMonedaValorMercado, nTenencia,
                                                    dFechaPrescripcion, nTipoMitigador, nTipoDocumento, nMontoMitigador,
                                                    nInscripcion, nPorcentaje, nGradoGravamen,
                                                    nGradoPrioridades, nMontoPrioridades, nOperacionEspecial,
                                                    nTipoAcreedor, strAcreedor,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString(), strOperacionCrediticia,
                                                    strDescInstObt, strDescInstNuevo, porcentajeAceptacion);

                    Session.Remove("DecripcionInstrumento");
                    CargarCombos();
                    LimpiarCampos();
                    GuardarDatosSession(true);

                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Modificación Exitosa" +
                                        "&strMensaje=" + "La información de la garantía de valor se modificó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasValor.aspx");
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
                                        "&strMensaje=" + "No se pudo modificar la información de la garantía de valor. " + "\r" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasValor.aspx");
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {

                int tipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue);

                string strOperacionCrediticia = string.Empty;

                if (tipoOperacion == ((int)Enumeradores.Tipos_Operaciones.Directa))
                {
                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}-{4}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtProducto.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                }
                else
                {
                    strOperacionCrediticia = string.Format("{0}-{1}-{2}-{3}", txtContabilidad.Text.TrimStart("0".ToCharArray()), txtOficina.Text.TrimStart("0".ToCharArray()), txtMoneda.Text.TrimStart("0".ToCharArray()), txtOperacion.Text);
                }

                Session["Accion"] = "ELIMINAR";

                Gestor.EliminarGarantiaValor(ConsecutivoOperacion,
                                            long.Parse(Session["GarantiaValor"].ToString()),
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString(), strOperacionCrediticia);

                CargarCombos();
                LimpiarCampos();
                GuardarDatosSession(true);

                contenedorDatosModificacion.Visible = false;
 
                seRedirecciona = true;
                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La garantía de valor se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasValor.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Eliminando Registro" +
                                        "&strMensaje=" + "No se pudo eliminar la garantía de valor." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasValor.aspx");
                }
            }

            if (seRedirecciona)
            {
                contenedorDatosModificacion.Visible = false;
                FilaSeleccionada = -1;

                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                //Campos llave
                FormatearCamposNumericos();
                txtOficina.Text = string.Empty;
                txtMoneda.Text = string.Empty;
                txtProducto.Text = string.Empty;
                txtOperacion.Text = string.Empty;
                CargarCombos();
                BloquearCampos(false);
                gdvGarantiasValor.DataSource = null;
                gdvGarantiasValor.DataBind();

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
                lblMensaje.Text = ex.Message;
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
                FilaSeleccionada = -1;

                FormatearCamposNumericos();
                if (ValidarDatosOperacion())
                {
                    string strProducto = ((int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString())) ? txtProducto.Text : string.Empty);
                    DataSet dsDatos = new DataSet();

                    oleDbConnection1 = AccesoBD.ObtenerStringConexion();
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

                            lblDeudor.Visible = true;
                            lblNombreDeudor.Visible = true;
                            Session["Nombre_Deudor"] = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString() + " - " +
                                                       dsDatos.Tables["Operacion"].Rows[0]["nombre_deudor"].ToString();
                            lblNombreDeudor.Text = Session["Nombre_Deudor"].ToString();
                            btnModificar.Enabled = false;
                            btnEliminar.Enabled = false;
                            Session["EsOperacionValidaValor"] = true;
                            GuardarDatosSession();
                        }
                        else
                        {
                            BloquearCampos(false);

                            lblDeudor.Text = string.Empty;
                            lblNombreDeudor.Text = string.Empty;

                            cbGravamen.Enabled = false;
                            txtMontoPrioridades.Enabled = false;
                            cbTenencia.Enabled = false;
                            txtFechaPrescripcion.Enabled = false;

                            igbCalendarioConstitucion.Enabled = false;
                            igbCalendarioPrescripcion.Enabled = false;
                            igbCalendarioVencimiento.Enabled = false;

                            btnLimpiar.Enabled = false;

                            gdvGarantiasValor.DataSource = null;
                            gdvGarantiasValor.DataBind();

                            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorConsultaGiro, _contratoDelGiro, Mensajes.ASSEMBLY);
                        }
                    }
                    else
                    {
                        BloquearCampos(false);
                        Session["EsOperacionValidaValor"] = false;
                        lblDeudor.Visible = false;
                        lblNombreDeudor.Visible = false;
                        Session["Nombre_Deudor"] = string.Empty;
                        if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                            lblMensaje.Text = "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
                        else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                            lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";

                        gdvGarantiasValor.DataSource = null;
                        gdvGarantiasValor.DataBind();
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
            finally
            {
                if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Open))
                {
                    oleDbConnection1.Close();
                    
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvGarantiasValor_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvGarantiasValor = (GridView)sender;
            int rowIndex = 0;
            DateTime dFecha;
            DataSet dsDatos = new DataSet();
            DateTime fechaBase = new DateTime(1900,01,01);
            string[] formatosFecha = { "yyyyMMdd", "dd/MM/yyyy" };

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedGarantiaValor"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvGarantiasValor.SelectedIndex = rowIndex;

                        FilaSeleccionada = rowIndex;

                        long vvv = ConsecutivoOperacion;

                        ConsecutivoOperacion = long.Parse(gdvGarantiasValor.SelectedDataKey[0].ToString());
                        ConsecutivoGarantia = long.Parse(gdvGarantiasValor.SelectedDataKey[1].ToString());

                        dsDatos = Gestor.ObtenerDatosGarantiaValor(ConsecutivoOperacion, ConsecutivoGarantia, Session["strUSER"].ToString());


                        #region Cargar Datos                    

                       

                        if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables[0].Rows.Count > 0))
                        {
                            FormatearCamposNumericos();

                            CargarClasesGarantia();
                            cbClaseGarantia.SelectedIndex = -1;
                            cbClaseGarantia.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoClaseGarantia) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoClaseGarantia].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoClaseGarantia].ToString() : "-1")).Selected = true;

                            txtSeguridad.Text = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._numeroSeguridad) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._numeroSeguridad].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._numeroSeguridad].ToString() :string.Empty);

                            string fechaConstitucion = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaConstitucion) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaConstitucion].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaConstitucion].ToString() : "19000101");
                            string fechaVencimiento = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaVencimientoInstrumento) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaVencimientoInstrumento].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaVencimientoInstrumento].ToString() : "19000101");
                            string fechaPrescripcion = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._fechaPrescripcion) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaPrescripcion].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaPrescripcion].ToString() : "19000101");
                            
                            txtFechaConstitucion.Text = ((DateTime.TryParseExact(fechaConstitucion, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out dFecha)) ? ((dFecha != fechaBase) ? dFecha.ToString("dd/MM/yyyy") : string.Empty) : string.Empty);
                            txtFechaVencimiento.Text = ((DateTime.TryParseExact(fechaVencimiento, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out dFecha)) ? ((dFecha != fechaBase) ? dFecha.ToString("dd/MM/yyyy") : string.Empty) : string.Empty); 
                            txtFechaPrescripcion.Text = ((DateTime.TryParseExact(fechaPrescripcion, formatosFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out dFecha)) ? ((dFecha != fechaBase) ? dFecha.ToString("dd/MM/yyyy") : string.Empty) : string.Empty); 

                            CargarClasificacionInstrumento();
                            cbClasificacion.SelectedIndex = -1;
                            cbClasificacion.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoClasificacionInstrumento) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoClasificacionInstrumento].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoClasificacionInstrumento].ToString() : "-1")).Selected = true;

                            cbInstrumento.SelectedIndex = -1;
                            cbInstrumento.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._descripcionInstrumento) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._descripcionInstrumento].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._descripcionInstrumento].ToString() : "-1")).Selected = true;

                            int codigoClasificacionInstrumento = (int.Parse(cbClasificacion.SelectedValue.ToString()));
                            cbInstrumento.Visible = (((codigoClasificacionInstrumento != -1) && (codigoClasificacionInstrumento != 5)) ? true : false);
                            txtInstrumento.Visible = (((codigoClasificacionInstrumento != -1) && (codigoClasificacionInstrumento != 5)) ? false : true);
                            Session["DecripcionInstrumento"] = (((codigoClasificacionInstrumento != -1) && (codigoClasificacionInstrumento != 5)) ? cbInstrumento.SelectedItem.Text : txtInstrumento.Text);

                            txtSerie.Text = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._serieInstrumento) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._serieInstrumento].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._serieInstrumento].ToString() : string.Empty);

                            CargarTiposPersona();
                            cbTipoEmisor.SelectedIndex = -1;
                            cbTipoEmisor.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoPersonaEmisor) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaEmisor].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaEmisor].ToString() : "-1")).Selected = true;

                            txtEmisor.Text = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._cedulaEmisor) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._cedulaEmisor].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._cedulaEmisor].ToString() : string.Empty);

                            decimal porcentajePremio = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajePremio) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajePremio].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajePremio].ToString() : "0"));
                            txtPorcentajePremio.Text = porcentajePremio.ToString("N2");

                            cbISIN.SelectedIndex = -1;
                            cbISIN.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoIsin) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoIsin].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoIsin].ToString() : "-1")).Selected = true;

                            decimal montoValorFacial = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoValorFacial) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoValorFacial].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoValorFacial].ToString() : "0"));
                            txtValorFacial.Text = montoValorFacial.ToString("N2");

                            CargarMonedas();
                            cbMonedaValorFacial.SelectedIndex = -1;
                            cbMonedaValorFacial.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoMonedaValorFacial) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorFacial].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorFacial].ToString() : "-1")).Selected = true;

                            decimal montoValorMercado = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoValorMercado) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoValorMercado].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoValorMercado].ToString() : "0"));
                            txtValorMercado.Text = montoValorMercado.ToString("N2");
                            
                            cbMonedaValorMercado.SelectedIndex = -1;
                            cbMonedaValorMercado.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoMonedaValorMercado) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorMercado].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoMonedaValorMercado].ToString() : "-1")).Selected = true;
                             
                            CargarTenencias();
                            cbTenencia.SelectedIndex = -1;
                            cbTenencia.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTenencia) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTenencia].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTenencia].ToString() : "-1")).Selected = true;

                            CargarTipoMitigador();
                            cbMitigador.SelectedIndex = -1;
                            cbMitigador.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoMitigador) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoMitigador].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoMitigador].ToString() : "-1")).Selected = true;

                            CargarTiposDocumentos();
                            cbTipoDocumento.SelectedIndex = -1;
                            cbTipoDocumento.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoDocumentoLegal) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoDocumentoLegal].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoDocumentoLegal].ToString() : "-1")).Selected = true;

                            decimal montoMitigador = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoMitigador) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoMitigador].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoMitigador].ToString() : "0"));
                            txtMontoMitigador.Text = montoMitigador.ToString("N2");
                            
                            CargarInscripciones();
                            cbInscripcion.SelectedIndex = -1;
                            cbInscripcion.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoIndicadorInscripcion) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoIndicadorInscripcion].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoIndicadorInscripcion].ToString() : "-1")).Selected = true;

                            decimal porcentajeResponsabilidad = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajeResponsabilidad) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajeResponsabilidad].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajeResponsabilidad].ToString() : "-1"));
                            txtPorcentajeResponsabilidad.Text = ((porcentajeResponsabilidad > -1) ? porcentajeResponsabilidad.ToString("N2") : "0.00");

                            decimal porcentajeAceptacion = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._porcentajeAceptacion) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajeAceptacion].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._porcentajeAceptacion].ToString() : "0"));
                            txtPorcentajeAceptacion.Text = porcentajeAceptacion.ToString("N2");

                            CargarGrados();
                            cbGravamen.SelectedIndex = -1;
                            cbGravamen.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoGradoGravamen) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoGradoGravamen].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoGradoGravamen].ToString() : "-1")).Selected = true;

                            cbGradoPrioridad.SelectedIndex = -1;
                            cbGradoPrioridad.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoGradoPrioridades) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoGradoPrioridades].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoGradoPrioridades].ToString() : "-1")).Selected = true;

                            decimal montoPrioridades = Convert.ToDecimal(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._montoPrioridades) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoPrioridades].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._montoPrioridades].ToString() : "0"));
                            txtMontoPrioridades.Text = montoPrioridades.ToString("N2");

                            CargarOperacionEspecial();
                            cbOperacionEspecial.SelectedIndex = -1;
                            cbOperacionEspecial.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoOperacionEspecial) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoOperacionEspecial].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoOperacionEspecial].ToString() : "-1")).Selected = true;

                            cbTipoAcreedor.SelectedIndex = -1;
                            cbTipoAcreedor.Items.FindByValue(((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._codigoTipoPersonaAcreedor) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaAcreedor].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._codigoTipoPersonaAcreedor].ToString() : "-1")).Selected = true;

                            txtAcreedor.Text = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._cedulaAcreedor) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._cedulaAcreedor].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._cedulaAcreedor].ToString() : string.Empty);

                            Session["GarantiaValor"] = ((!dsDatos.Tables[0].Rows[0].IsNull(clsGarantiaValor._consecutivoGarantiaValor) && (dsDatos.Tables[0].Rows[0][clsGarantiaValor._consecutivoGarantiaValor].ToString() != null)) ? dsDatos.Tables[0].Rows[0][clsGarantiaValor._consecutivoGarantiaValor].ToString() : null);
                        }

                        #endregion


                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;
                        btnLimpiar.Enabled = true;
                        lblMensaje.Text = string.Empty;
                        lblMensaje2.Text = string.Empty;

                        cbGravamen.Enabled = true;
                        txtMontoPrioridades.Enabled = true;
                        cbTenencia.Enabled = true;
                        txtFechaPrescripcion.Enabled = true;

                        igbCalendarioConstitucion.Enabled = true;
                        igbCalendarioPrescripcion.Enabled = true;
                        igbCalendarioVencimiento.Enabled = true;

                        contenedorDatosModificacion.Visible = true;

                        DateTime fechaReplicag = DateTime.Parse(dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaReplica].ToString());
                        DateTime fechaModificacion = DateTime.Parse(dsDatos.Tables[0].Rows[0][clsGarantiaValor._fechaModifico].ToString());

                        string usrModifico = dsDatos.Tables[0].Rows[0][clsGarantiaValor._cedulaUsuarioModifico].ToString();
                        string nombreUsrModifico = dsDatos.Tables[0].Rows[0][clsGarantiaValor._nombreUsuarioModifico].ToString();

                        string usuarioModifico = (((usrModifico.Length > 0) && (nombreUsrModifico.Length > 0)) ? (string.Format("{0} - {1}", usrModifico, nombreUsrModifico)) : string.Empty);
                        string fechaModifico = ((fechaModificacion != fechaBase) ? fechaModificacion.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);
                        string fechaReplica = ((fechaReplicag != fechaBase) ? (fechaReplicag.ToString("dd/MM/yyyy hh:mm:ss tt")) : string.Empty);

                        ViewState.Add(LLAVE_FECHA_MODIFICACION, fechaModificacion);
                        ViewState.Add(LLAVE_FECHA_REPLICA, fechaReplica);

                        lblUsrModifico.Text = string.Format("Usuario Modificó: {0}", usuarioModifico);
                        lblFechaModificacion.Text = string.Format("Fecha Modificación: {0}", fechaModifico);
                        lblFechaReplica.Text = string.Format("Fecha Replica: {0}", fechaReplica);

                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        protected void gdvGarantiasValor_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvGarantiasValor.SelectedIndex = -1;
            this.gdvGarantiasValor.PageIndex = e.NewPageIndex;

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

        #endregion

        #region Métodos Privados
        private void FormatearCamposNumericos()
        {
            System.Globalization.NumberFormatInfo a = new System.Globalization.NumberFormatInfo();
            a.NumberDecimalSeparator = ".";
        }

        private void CargarGrid(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            try
            {
                DataSet dsDatos = new DataSet();
                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    SqlCommand oComando = null;

                    if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        oComando = new SqlCommand("pa_ObtenerGarantiasValorOperaciones", oConexion);
                    else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
                        oComando = new SqlCommand("pa_ObtenerGarantiasValorContratos", oConexion);

                    SqlDataAdapter oDataAdapter = new SqlDataAdapter();
                    //declara las propiedades del comando
                    oComando.CommandType = CommandType.StoredProcedure;
                    oComando.CommandTimeout = 120;
                    oComando.Parameters.AddWithValue("@piConsecutivo_Operacion", nCodOperacion);
                    oComando.Parameters.AddWithValue("@piCodigo_Contabilidad", nContabilidad);
                    oComando.Parameters.AddWithValue("@piCodigo_Oficina", nOficina);
                    oComando.Parameters.AddWithValue("@piCodigo_Moneda", nMoneda);

                    //AGREGAR PARÁMETRO @nObtenerSoloCodigo = 1

                    if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                    {
                        oComando.Parameters.AddWithValue("@piCodigo_Producto", nProducto);
                        oComando.Parameters.AddWithValue("@pdNumero_Operacion", nOperacion);
                    }
                    else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
                    {
                        oComando.Parameters.AddWithValue("@pdNumero_Contrato", nOperacion);
                    }

                    oComando.Parameters.AddWithValue("@psCedula_Usuario", Global.UsuarioSistema);

                    //Abre la conexion
                    oConexion.Open();
                    oDataAdapter.SelectCommand = oComando;
                    oDataAdapter.SelectCommand.Connection = oConexion;
                    oDataAdapter.Fill(dsDatos, "Datos");

                    if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                    {

                        if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("des_clase_garantia")) &&
                            (!dsDatos.Tables["Datos"].Rows[0].IsNull(clsGarantiaValor._numeroSeguridad)))
                        {
                            this.gdvGarantiasValor.DataSource = dsDatos.Tables["Datos"].DefaultView;
                            this.gdvGarantiasValor.DataBind();
                        }
                        else
                        {
                            dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                            this.gdvGarantiasValor.DataSource = dsDatos;
                            this.gdvGarantiasValor.DataBind();

                            int TotalColumns = this.gdvGarantiasValor.Rows[0].Cells.Count;
                            this.gdvGarantiasValor.Rows[0].Cells.Clear();
                            this.gdvGarantiasValor.Rows[0].Cells.Add(new TableCell());
                            this.gdvGarantiasValor.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                            this.gdvGarantiasValor.Rows[0].Cells[0].Text = "No existen registros";
                        }
                    }
                    else
                    {
                        dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                        this.gdvGarantiasValor.DataSource = dsDatos;
                        this.gdvGarantiasValor.DataBind();

                        int TotalColumns = this.gdvGarantiasValor.Rows[0].Cells.Count;
                        this.gdvGarantiasValor.Rows[0].Cells.Clear();
                        this.gdvGarantiasValor.Rows[0].Cells.Add(new TableCell());
                        this.gdvGarantiasValor.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvGarantiasValor.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Metodo que carga la información de la garantia que se encuentra almacenada en el objeto Session.
        /// </summary>
        private void CargarDatosSession()
        {
            try
            {
                CGarantiaValor oGarantia = CGarantiaValor.Current;

                //Campos llave
                if (oGarantia.TipoOperacion != 0)
                {
                    cbTipoCaptacion.ClearSelection();
                    cbTipoCaptacion.Items.FindByValue(oGarantia.TipoOperacion.ToString()).Selected = true;
                }

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

                if (oGarantia.ClaseGarantia != -1)
                {
                    cbClaseGarantia.ClearSelection();
                    cbClaseGarantia.Items.FindByValue(oGarantia.ClaseGarantia.ToString()).Selected = true;
                }

                if (oGarantia.Seguridad != null)
                    txtSeguridad.Text = oGarantia.Seguridad.ToString();

                //Informacion general de la garantia
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

                txtMontoMitigador.Text = oGarantia.MontoMitigador.ToString("N2");

                if (oGarantia.Inscripcion != 0)
                {
                    cbInscripcion.ClearSelection();
                    cbInscripcion.Items.FindByValue(oGarantia.Inscripcion.ToString()).Selected = true;
                }

                txtPorcentajeResponsabilidad.Text = ((oGarantia.PorcentajeResposabilidad > -1) ? oGarantia.PorcentajeResposabilidad.ToString("N2") : "0.00");

                txtPorcentajeAceptacion.Text = oGarantia.PorcentajeAceptacion.ToString("N2");

                txtFechaConstitucion.Text = oGarantia.FechaConstitucion.ToShortDateString();

                if (oGarantia.GradoGravamen != 0)
                {
                    cbGravamen.ClearSelection();
                    cbGravamen.Items.FindByValue(oGarantia.GradoGravamen.ToString()).Selected = true;
                }

                if (oGarantia.TipoAcreedor != 0)
                {
                    cbTipoAcreedor.ClearSelection();
                    cbTipoAcreedor.Items.FindByValue(oGarantia.TipoAcreedor.ToString()).Selected = true;
                }

                if (oGarantia.CedulaAcreedor != null)
                    txtAcreedor.Text = oGarantia.CedulaAcreedor;

                if (oGarantia.GradoPrioridades != 0)
                {
                    cbGradoPrioridad.ClearSelection();
                    cbGradoPrioridad.Items.FindByValue(oGarantia.GradoPrioridades.ToString()).Selected = true;
                }

                txtMontoPrioridades.Text = oGarantia.MontoPrioridades.ToString("N2");

                txtFechaVencimiento.Text = oGarantia.FechaVencimiento.ToShortDateString();

                if (oGarantia.OperacionEspecial != 0)
                {
                    cbOperacionEspecial.ClearSelection();
                    cbOperacionEspecial.Items.FindByValue(oGarantia.OperacionEspecial.ToString()).Selected = true;
                }

                if (oGarantia.Clasificacion != 0)
                {
                    cbClasificacion.ClearSelection();
                    cbClasificacion.Items.FindByValue(oGarantia.Clasificacion.ToString()).Selected = true;
                }

                if (oGarantia.Instrumento != null)
                    if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                        cbInstrumento.Items.FindByValue(oGarantia.Instrumento).Selected = true;
                    else
                        txtInstrumento.Text = oGarantia.Instrumento;

                if (oGarantia.Serie != null)
                    txtSerie.Text = oGarantia.Serie;

                if (oGarantia.TipoEmisor != 0)
                {
                    cbTipoEmisor.ClearSelection();
                    cbTipoEmisor.Items.FindByValue(oGarantia.TipoEmisor.ToString()).Selected = true;
                }

                if (oGarantia.CedulaEmisor != null)
                    txtEmisor.Text = oGarantia.CedulaEmisor;

                if (oGarantia.Tenencia != 0)
                {
                    cbTenencia.ClearSelection();
                    cbTenencia.Items.FindByValue(oGarantia.Tenencia.ToString()).Selected = true;
                }

                txtFechaPrescripcion.Text = oGarantia.FechaPrescripcion.ToShortDateString();

                txtPorcentajePremio.Text = oGarantia.Premio.ToString("N2");

                if (oGarantia.ISIN != null)
                {
                    cbISIN.ClearSelection();
                    cbISIN.Items.FindByValue(oGarantia.ISIN).Selected = true;
                }

                txtValorFacial.Text = oGarantia.ValorFacial.ToString("N2");

                if (oGarantia.MonedaValorFacial != 0)
                {
                    cbMonedaValorFacial.ClearSelection();
                    cbMonedaValorFacial.Items.FindByValue(oGarantia.MonedaValorFacial.ToString()).Selected = true;
                }

                txtValorMercado.Text = oGarantia.ValorMercado.ToString("N2");

                if (oGarantia.MonedaValorMercado != 0)
                {
                    cbMonedaValorMercado.ClearSelection();
                    cbMonedaValorMercado.Items.FindByValue(oGarantia.MonedaValorMercado.ToString()).Selected = true;
                }

                if (FilaSeleccionada != -1)
                {
                    contenedorDatosModificacion.Visible = true;
                    lblUsrModifico.Text = oGarantia.UsuarioModifico;
                    lblFechaModificacion.Text = string.Format("Fecha Modificacion: {0}", oGarantia.FechaModifico.ToShortDateString());
                    lblFechaReplica.Text = string.Format("Fecha Replica: {0}-{1}", oGarantia.FechaReplica.ToShortDateString(), oGarantia.FechaReplica.ToShortTimeString());
                }
                else
                {
                    contenedorDatosModificacion.Visible = false;
                }

                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este método guarda los datos de la pantalla en el objeto Session
        /// </summary>
        private void GuardarDatosSession()
        {
            try
            {
                CGarantiaValor oGarantia = CGarantiaValor.Current;

                //Campos llave
                oGarantia.TipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                oGarantia.Contabilidad = int.Parse(txtContabilidad.Text);
                oGarantia.Oficina = int.Parse(txtOficina.Text);
                oGarantia.Moneda = int.Parse(txtMoneda.Text);

                if (txtProducto.Text.Trim().Length > 0)
                    oGarantia.Producto = int.Parse(txtProducto.Text);

                oGarantia.Numero = long.Parse(txtOperacion.Text);
                oGarantia.ClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());
                if (txtSeguridad.Text.Trim().Length > 0)
                    oGarantia.Seguridad = txtSeguridad.Text;

                //Informacion general de la garantia
                oGarantia.TipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.TipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                if (txtMontoMitigador.Text.Trim().Length > 0)
                    oGarantia.MontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text); 
                else
                    oGarantia.MontoMitigador = 0;

                oGarantia.Inscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                if (txtPorcentajeResponsabilidad.Text.Trim().Length > 0)
                    oGarantia.PorcentajeResposabilidad = Convert.ToDecimal(txtPorcentajeResponsabilidad.Text); 
                else
                    oGarantia.PorcentajeResposabilidad = -1;

                if (txtPorcentajeAceptacion.Text.Trim().Length > 0)
                    oGarantia.PorcentajeAceptacion = Convert.ToDecimal(txtPorcentajeAceptacion.Text);
                else
                    oGarantia.PorcentajeAceptacion = 0;

                if (txtFechaConstitucion.Text.Trim().Length > 0)
                    oGarantia.FechaConstitucion = DateTime.Parse(txtFechaConstitucion.Text.ToString());

                oGarantia.GradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                oGarantia.TipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.GradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                if (txtMontoPrioridades.Text.Trim().Length > 0)
                    oGarantia.MontoPrioridades = Convert.ToDecimal(txtMontoPrioridades.Text); 
                else
                    oGarantia.MontoPrioridades = 0;

                if (txtFechaVencimiento.Text.Trim().Length > 0)
                    oGarantia.FechaVencimiento = DateTime.Parse(txtFechaVencimiento.Text.ToString());

                oGarantia.OperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                oGarantia.Clasificacion = int.Parse(cbClasificacion.SelectedValue.ToString());

                if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                    oGarantia.Instrumento = cbInstrumento.SelectedValue.ToString();
                else
                    oGarantia.Instrumento = txtInstrumento.Text.Trim();

                oGarantia.Serie = txtSerie.Text;
                oGarantia.TipoEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                oGarantia.CedulaEmisor = txtEmisor.Text.Trim();

                if (txtPorcentajePremio.Text.Trim().Length > 0)
                    oGarantia.Premio = Convert.ToDecimal(txtPorcentajePremio.Text); 
                else
                    oGarantia.Premio = 0;

                oGarantia.ISIN = cbISIN.SelectedValue.ToString();

                if (txtValorFacial.Text.Trim().Length > 0)
                    oGarantia.ValorFacial = Convert.ToDecimal(txtValorFacial.Text);
                else
                    oGarantia.ValorFacial = 0;

                oGarantia.MonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                if (txtValorMercado.Text.Trim().Length > 0)
                    oGarantia.ValorMercado = Convert.ToDecimal(txtValorMercado.Text); 
                else
                    oGarantia.ValorMercado = 0;

                oGarantia.MonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());

                oGarantia.Tenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                if (txtFechaPrescripcion.Text.Trim().Length > 0)
                    oGarantia.FechaPrescripcion = DateTime.Parse(txtFechaPrescripcion.Text.ToString());

                oGarantia.UsuarioModifico = lblUsrModifico.Text.Trim();

                if (ViewState[LLAVE_FECHA_MODIFICACION] != null)
                {
                    if (!ViewState[LLAVE_FECHA_MODIFICACION].ToString().Equals(string.Empty))
                    {
                        oGarantia.FechaModifico = DateTime.Parse(ViewState[LLAVE_FECHA_MODIFICACION].ToString());
                    }                             
                }

                if (ViewState[LLAVE_FECHA_REPLICA] != null)
                {
                    if (!ViewState[LLAVE_FECHA_REPLICA].ToString().Equals(string.Empty))
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
        /// Este método guarda los datos de la pantalla en el objeto Session
        /// </summary>
        private void GuardarDatosSession(bool bLimpiar)
        {
            try
            {
                CGarantiaValor oGarantia = CGarantiaValor.Current;

                //Campos llave
                oGarantia.TipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                oGarantia.Contabilidad = int.Parse(txtContabilidad.Text);
                oGarantia.Oficina = int.Parse(txtOficina.Text);
                oGarantia.Moneda = int.Parse(txtMoneda.Text);

                oGarantia.Producto = int.Parse(((txtProducto.Text.Trim().Length > 0) ? txtProducto.Text : "0"));

                oGarantia.Numero = long.Parse(txtOperacion.Text);
                oGarantia.ClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());

                oGarantia.Seguridad = ((!bLimpiar) && ((txtSeguridad.Text.Trim().Length > 0)) ? txtSeguridad.Text : null);

                //Informacion general de la garantia
                oGarantia.TipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.TipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                oGarantia.MontoMitigador = Convert.ToDecimal((((!bLimpiar) && (txtMontoMitigador.Text.Trim().Length > 0)) ? txtMontoMitigador.Text : "0"));

                oGarantia.Inscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                oGarantia.PorcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                oGarantia.PorcentajeResposabilidad = Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text : "-1"));

                oGarantia.FechaConstitucion = (((!bLimpiar) && (txtFechaConstitucion.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaConstitucion.Text.ToString()) : DateTime.Today);

                oGarantia.GradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                oGarantia.TipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.GradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                oGarantia.MontoPrioridades = Convert.ToDecimal((((!bLimpiar) && (txtMontoPrioridades.Text.Trim().Length > 0)) ? txtMontoPrioridades.Text : "0"));

                oGarantia.FechaVencimiento = (((!bLimpiar) && (txtFechaVencimiento.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaVencimiento.Text.ToString()) : DateTime.Today);
                 
                oGarantia.OperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                oGarantia.Clasificacion = int.Parse(cbClasificacion.SelectedValue.ToString());

                oGarantia.Instrumento = ((int.Parse(cbClasificacion.SelectedValue.ToString()) != 5) ? cbInstrumento.SelectedValue.ToString() : txtInstrumento.Text.Trim());
                  
                oGarantia.Serie = txtSerie.Text;
                oGarantia.TipoEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                oGarantia.CedulaEmisor = txtEmisor.Text.Trim();

                oGarantia.Premio = Convert.ToDecimal(((txtPorcentajePremio.Text.Trim().Length > 0) ? txtPorcentajePremio.Text : "0"));

                oGarantia.ISIN = cbISIN.SelectedValue.ToString();

                oGarantia.ValorFacial = Convert.ToDecimal((((!bLimpiar) && (txtValorFacial.Text.Trim().Length > 0)) ? txtValorFacial.Text : "0"));

                oGarantia.MonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                oGarantia.ValorMercado = Convert.ToDecimal((((!bLimpiar) && (txtValorMercado.Text.Trim().Length > 0)) ? txtValorMercado.Text : "0"));

                oGarantia.MonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());

                oGarantia.Tenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                oGarantia.FechaPrescripcion = (((!bLimpiar) && (txtFechaPrescripcion.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaPrescripcion.Text) : DateTime.Today);

                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void LimpiarDatosSession()
        {
            try
            {
                CGarantiaValor oGarantia = CGarantiaValor.Current;
                oGarantia.ClaseGarantia = -1;
                oGarantia.Seguridad = null;
                oGarantia.TipoMitigador = -1;
                oGarantia.TipoDocumento = 0;
                oGarantia.MontoMitigador = 0;
                oGarantia.Inscripcion = 0;
                oGarantia.FechaRegistro = DateTime.Today;
                oGarantia.PorcentajeResposabilidad = -1;
                oGarantia.FechaConstitucion = DateTime.Today;
                oGarantia.GradoGravamen = 0;
                oGarantia.TipoAcreedor = 0;
                oGarantia.CedulaAcreedor = null;
                oGarantia.GradoPrioridades = 0;
                oGarantia.MontoPrioridades = 0;
                oGarantia.FechaVencimiento = DateTime.Today;
                oGarantia.OperacionEspecial = -1;
                oGarantia.Clasificacion = 0;
                oGarantia.Instrumento = null;
                oGarantia.Serie = null;
                oGarantia.TipoEmisor = 0;
                oGarantia.CedulaEmisor = null;
                oGarantia.Premio = 0;
                oGarantia.ISIN = null;
                oGarantia.ValorFacial = 0;
                oGarantia.MonedaValorFacial = 0;
                oGarantia.ValorMercado = 0;
                oGarantia.MonedaValorMercado = 0;
                oGarantia.Tenencia = 0;
                oGarantia.FechaPrescripcion = DateTime.Today;
                oGarantia.PorcentajeAceptacion = 0;
                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este método permite bloquear o desbloquear los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles están bloqueados o no</param>
        private void BloquearCampos(bool bBloqueado)
        {
            try
            {
                LimpiarCampos();
                CargarCombos();
                txtSeguridad.Enabled = bBloqueado;
                cbClaseGarantia.Enabled = bBloqueado;
                cbMitigador.Enabled = bBloqueado;
                cbTipoDocumento.Enabled = bBloqueado;
                txtMontoMitigador.Enabled = bBloqueado;
                txtPorcentajeAceptacion.Enabled = bBloqueado;
                txtFechaConstitucion.Enabled = bBloqueado;
                txtAcreedor.Enabled = bBloqueado;
                cbOperacionEspecial.Enabled = bBloqueado;
                cbClasificacion.Enabled = bBloqueado;
                cbInstrumento.Enabled = bBloqueado;
                txtSerie.Enabled = bBloqueado;
                txtFechaVencimiento.Enabled = bBloqueado;
                cbTipoEmisor.Enabled = bBloqueado;
                txtEmisor.Enabled = bBloqueado;
                txtPorcentajePremio.Enabled = bBloqueado;
                cbISIN.Enabled = bBloqueado;
                txtValorFacial.Enabled = bBloqueado;
                cbMonedaValorFacial.Enabled = bBloqueado;
                txtValorMercado.Enabled = bBloqueado;
                cbMonedaValorMercado.Enabled = bBloqueado;
                cbGravamen.Enabled = bBloqueado;
                cbTenencia.Enabled = bBloqueado;
                txtMontoPrioridades.Enabled = bBloqueado;
                txtFechaPrescripcion.Enabled = bBloqueado;
                igbCalendarioConstitucion.Enabled = bBloqueado;
                igbCalendarioPrescripcion.Enabled = bBloqueado;
                igbCalendarioVencimiento.Enabled = bBloqueado;
                txtPorcentajeResponsabilidad.Enabled = false;

                //Botones
                btnInsertar.Enabled = bBloqueado;
                btnModificar.Enabled = bBloqueado;
                btnEliminar.Enabled = bBloqueado;
                btnLimpiar.Enabled = bBloqueado;
                //Mensajes
                lblMensaje.Text = string.Empty;
                lblMensaje2.Text = string.Empty;
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
                txtSeguridad.Text = string.Empty;
                txtMontoMitigador.Text = string.Empty;
                txtPorcentajeAceptacion.Text = string.Empty;
                txtAcreedor.Text = string.Empty;
                txtFechaConstitucion.Text = string.Empty;
                txtFechaVencimiento.Text = string.Empty;
                txtFechaPrescripcion.Text = string.Empty;
                txtSerie.Text = string.Empty;
                txtEmisor.Text = string.Empty;
                txtPorcentajePremio.Text = string.Empty;
                txtValorFacial.Text = string.Empty;
                txtValorMercado.Text = string.Empty;
                lblMensaje.Text = string.Empty;
                lblMensaje2.Text = string.Empty;
                txtPorcentajeResponsabilidad.Text = string.Empty;

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
                CargarClasesGarantia();
                CargarTiposPersona();
                CargarTipoMitigador();
                CargarTiposDocumentos();
                CargarInscripciones();
                CargarGrados();
                CargarOperacionEspecial();
                CargarTenencias();
                CargarMonedas();
                CargarClasificacionInstrumento();
                CargarInstrumentos();
                CargarISIN();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void CargarClasesGarantia()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_CLASE_GARANTIA"].ToString()) + " AND CAT_CAMPO BETWEEN 20 AND 29 UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbClaseGarantia.DataSource = null;
                cbClaseGarantia.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbClaseGarantia.DataValueField = "CAT_CAMPO";
                cbClaseGarantia.DataTextField = "CAT_DESCRIPCION";
                cbClaseGarantia.ClearSelection();
                cbClaseGarantia.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Clases de Garantía] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarInstrumentos()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "cod_instrumento, " +
                                    "des_instrumento " +
                                "FROM " +
                                    "cat_instrumentos " +
                                "UNION ALL " +
                                "SELECT '', '' " +
                                "ORDER BY " +
                                    "des_instrumento";

                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbInstrumento.DataSource = null;
                cbInstrumento.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbInstrumento.DataValueField = "COD_INSTRUMENTO";
                cbInstrumento.DataTextField = "DES_INSTRUMENTO";
                cbInstrumento.ClearSelection();
                cbInstrumento.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Instrumento] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarISIN()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "cod_isin " +
                                "FROM " +
                                    "cat_isin " +
                                "UNION ALL " +
                                "SELECT '' " +
                                "ORDER BY " +
                                "cod_isin";

                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbISIN.DataSource = null;
                cbISIN.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbISIN.DataValueField = "COD_ISIN";
                cbISIN.DataTextField = "COD_ISIN";
                cbISIN.ClearSelection();
                cbISIN.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Instrumento] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarTipoMitigador()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_MITIGADOR"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbMitigador.DataSource = null;
                cbMitigador.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbMitigador.DataValueField = "CAT_CAMPO";
                cbMitigador.DataTextField = "CAT_DESCRIPCION";
                cbMitigador.ClearSelection();
                cbMitigador.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Tipo Mitigador] Error: " + ex.Message;
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
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPOS_DOCUMENTOS"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbTipoDocumento.DataSource = null;
                cbTipoDocumento.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbTipoDocumento.DataValueField = "CAT_CAMPO";
                cbTipoDocumento.DataTextField = "CAT_DESCRIPCION";
                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Tipos de Documentos Legales] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarClasificacionInstrumento()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_CLASIFICACION_INSTRUMENTO"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbClasificacion.DataSource = null;
                cbClasificacion.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbClasificacion.DataValueField = "CAT_CAMPO";
                cbClasificacion.DataTextField = "CAT_DESCRIPCION";
                cbClasificacion.ClearSelection();
                cbClasificacion.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Clasificación Instrumento] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarMonedas()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_MONEDA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbMonedaValorFacial.DataSource = null;
                cbMonedaValorFacial.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbMonedaValorFacial.DataValueField = "CAT_CAMPO";
                cbMonedaValorFacial.DataTextField = "CAT_DESCRIPCION";
                cbMonedaValorFacial.ClearSelection();
                cbMonedaValorFacial.DataBind();

                cbMonedaValorMercado.DataSource = null;
                cbMonedaValorMercado.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbMonedaValorMercado.DataValueField = "CAT_CAMPO";
                cbMonedaValorMercado.DataTextField = "CAT_DESCRIPCION";
                cbMonedaValorMercado.ClearSelection();
                cbMonedaValorMercado.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Monedas] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarTenencias()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TENENCIA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbTenencia.DataSource = null;
                cbTenencia.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbTenencia.DataValueField = "CAT_CAMPO";
                cbTenencia.DataTextField = "CAT_DESCRIPCION";
                cbTenencia.ClearSelection();
                cbTenencia.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Tenencias] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarGrados()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_GRADO_GRAVAMEN"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbGravamen.DataSource = null;
                cbGravamen.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbGravamen.DataValueField = "CAT_CAMPO";
                cbGravamen.DataTextField = "CAT_DESCRIPCION";
                cbGravamen.ClearSelection();
                cbGravamen.DataBind();

                cbGradoPrioridad.DataSource = null;
                cbGradoPrioridad.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbGradoPrioridad.DataValueField = "CAT_CAMPO";
                cbGradoPrioridad.DataTextField = "CAT_DESCRIPCION";
                cbGradoPrioridad.ClearSelection();
                cbGradoPrioridad.DataBind();
                cbGradoPrioridad.Items.FindByValue(Application["DEFAULT_GRADO_PRIORIDAD"].ToString()).Selected = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Grados] Error: " + ex.Message;
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
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_OPERACION_ESPECIAL"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbOperacionEspecial.DataSource = null;
                cbOperacionEspecial.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbOperacionEspecial.DataValueField = "CAT_CAMPO";
                cbOperacionEspecial.DataTextField = "CAT_DESCRIPCION";
                cbOperacionEspecial.ClearSelection();
                cbOperacionEspecial.DataBind();
                cbOperacionEspecial.Items.FindByValue(Application["DEFAULT_OPERACION_ESPECIAL"].ToString()).Selected = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Operación Especial] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
        }

        private void CargarInscripciones()
        {
            try
            {
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                /*Se filtran los datos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012*/
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_INSCRIPCION"].ToString()) + " AND cat_campo = 0 UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Codigos");
                cbInscripcion.DataSource = null;
                cbInscripcion.DataSource = dsDatos.Tables["Codigos"].DefaultView;
                cbInscripcion.DataValueField = "CAT_CAMPO";
                cbInscripcion.DataTextField = "CAT_DESCRIPCION";
                cbInscripcion.ClearSelection();
                cbInscripcion.DataBind();
                cbInscripcion.Items.FindByValue(Application["DEFAULT_INSCRIPCION"].ToString()).Selected = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Inscripciones] Error: " + ex.Message;
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
                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_PERSONA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Tipos");

                cbTipoAcreedor.DataSource = null;
                cbTipoAcreedor.DataSource = dsDatos.Tables["Tipos"].DefaultView;
                cbTipoAcreedor.DataValueField = "CAT_CAMPO";
                cbTipoAcreedor.DataTextField = "CAT_DESCRIPCION";
                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.DataBind();
                cbTipoAcreedor.Items.FindByValue(Application["DEFAULT_TIPO_ACREEDOR"].ToString()).Selected = true;

                cbTipoEmisor.DataSource = null;
                cbTipoEmisor.DataSource = dsDatos.Tables["Tipos"].DefaultView;
                cbTipoEmisor.DataValueField = "CAT_CAMPO";
                cbTipoEmisor.DataTextField = "CAT_DESCRIPCION";
                cbTipoEmisor.ClearSelection();
                cbTipoEmisor.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Tipos de Persona] Error: " + ex.Message;
            }
            finally
            {
                oleDbConnection1.Close();
            }
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

                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
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
        /// Metodo de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = string.Empty;
                lblMensaje2.Text = string.Empty;

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
                if (bRespuesta && txtSeguridad.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el número de seguridad";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClaseGarantia.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la clase de garantía";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMitigador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar el tipo mitigador de riesgo.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoDocumento.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar el tipo de documento legal.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoMitigador.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el monto mitigador";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClasificacion.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la clasificación del instrumento.";
                    bRespuesta = false;
                }
                if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                {
                    if (bRespuesta && cbInstrumento.SelectedValue.ToString() == string.Empty)
                    {
                        lblMensaje2.Text = "Debe seleccionar la identificación del instrumento.";
                        bRespuesta = false;
                    }
                }
                else
                {
                    if (bRespuesta && txtInstrumento.Text == string.Empty)
                    {
                        lblMensaje2.Text = "Debe ingresar el número de cuenta de depósito como identificación del instrumento.";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtFechaConstitucion.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar la fecha de emisión del instrumento.";
                    bRespuesta = false;
                }
                if (bRespuesta && cbISIN.SelectedValue.ToString() == string.Empty)
                {
                    lblMensaje2.Text = "Debe seleccionar el código ISIN.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbGravamen.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar el grado de gravamen.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMontoPrioridades.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el monto de prioridades";
                    bRespuesta = false;
                }
                if (bRespuesta && txtValorFacial.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el valor facial";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMonedaValorFacial.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la moneda del valor facial";
                    bRespuesta = false;
                }
                if (bRespuesta && txtValorMercado.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el valor de mercado";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbMonedaValorMercado.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la moneda del valor mercado";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTenencia.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la tenencia";
                    bRespuesta = false;
                }
                if (bRespuesta && txtFechaPrescripcion.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar la fecha de prescripción de la garantía.";
                    bRespuesta = false;
                }

                if (!bRespuesta)
                    FormatearCamposNumericos();

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
            lblMensaje.Text = string.Empty;
            try
            {
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

        private bool ValidarDatosLlave()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = string.Empty;

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
                if (bRespuesta && int.Parse(cbClaseGarantia.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar la clase de garantía";
                    bRespuesta = false;
                }
                if (bRespuesta && txtSeguridad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el número de seguridad";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        private bool ValidarGarantiaValor()
        {
            bool bRespuesta = true;
            try
            {
                string strSQL = "SELECT " +
                                    "b.cod_operacion, " +
                                    "b.cod_garantia_valor " +
                                "FROM " +
                                    "dbo.GAR_OPERACION a, " +
                                    "dbo.GAR_GARANTIAS_VALOR_X_OPERACION b, " +
                                    "dbo.GAR_GARANTIA_VALOR c " +
                                "WHERE " +
                                    "a.cod_contabilidad = " + txtContabilidad.Text +
                                    " and a.cod_oficina = " + txtOficina.Text +
                                    " and a.cod_moneda = " + txtMoneda.Text;

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
                                " and b.cod_garantia_valor = c.cod_garantia_valor " +
                                " and c.numero_seguridad = '" + txtSeguridad.Text + "'";

                DataSet dsDatos = new DataSet();
                oleDbConnection1 = AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if (dsDatos.Tables["Datos"].Rows.Count > 0)
                    bRespuesta = false;
                else
                    bRespuesta = true;
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
        #endregion
    }
}
