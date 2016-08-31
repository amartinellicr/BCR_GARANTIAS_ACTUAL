using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Globalization;
using System.Collections.Generic;

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
        private const string LLAVE_ENTIDAD_CATALOGOS            = "LLAVE_ENTIDAD_CATALOGOS";

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

        /// <summary>
        /// Permite obetener la lista de los códigos de los catálogos usados en este mantenimiento
        /// </summary>
        public string ListaCodigosCatalogos
        {
            get
            {
                return "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_CLASE_GARANTIA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_GRADO_GRAVAMEN).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_INSCRIPCION).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_MONEDA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_OPERACION_ESPECIAL).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TENENCIA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_CLASIFICACION_INSTRUMENTO).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPO_MITIGADOR).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPO_PERSONA).ToString() +
                        "|" + ((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPOS_DOCUMENTOS).ToString() + "|";
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del tipo Catálogos
        /// </summary>
        public clsCatalogos<clsCatalogo> ListaCatalogosGV
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
                int nProducto = -1;
                int nContabilidad;
                int nOficina;
                int nMoneda;
                long nOperacion;
                FilaSeleccionada = -1;

                FormatearCamposNumericos();

                if (ValidarDatosOperacion())
                {
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
                                                        
                            CargarGrid( int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
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
            clsGarantiaValor dsDatos = new clsGarantiaValor();
            DateTime fechaBase = new DateTime(1900,01,01);
           
            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedGarantiaValor"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvGarantiasValor.SelectedIndex = rowIndex;

                        FilaSeleccionada = rowIndex;

                        ConsecutivoOperacion = long.Parse(gdvGarantiasValor.SelectedDataKey[0].ToString());
                        ConsecutivoGarantia = long.Parse(gdvGarantiasValor.SelectedDataKey[1].ToString());

                        dsDatos = Gestor.ObtenerDatosGarantiaValor(ConsecutivoOperacion, ConsecutivoGarantia, Session["strUSER"].ToString());

                        #region Cargar Datos                    

                        if (dsDatos != null)
                        {
                            FormatearCamposNumericos();

                            CargarClasesGarantia();
                            cbClaseGarantia.SelectedIndex = -1;
                            cbClaseGarantia.Items.FindByValue(dsDatos.CodigoClaseGarantia.ToString()).Selected = true;

                            txtSeguridad.Text = dsDatos.NumeroSeguridad;

                            txtFechaConstitucion.Text = ((dsDatos.FechaConstitucion != fechaBase) ? dsDatos.FechaConstitucion.ToString("dd/MM/yyyy") : string.Empty);
                            txtFechaVencimiento.Text = ((dsDatos.FechaVencimientoInstrumento != fechaBase) ? dsDatos.FechaVencimientoInstrumento.ToString("dd/MM/yyyy") : string.Empty);
                            txtFechaPrescripcion.Text = ((dsDatos.FechaPrescripcion != fechaBase) ? dsDatos.FechaPrescripcion.ToString("dd/MM/yyyy") : string.Empty);

                            CargarClasificacionInstrumento();
                            cbClasificacion.SelectedIndex = -1;
                            cbClasificacion.Items.FindByValue(dsDatos.CodigoClasificacionInstrumento.ToString()).Selected = true;
                            
                            cbInstrumento.SelectedIndex = -1;
                            cbInstrumento.Items.FindByValue((((dsDatos.CodigoClasificacionInstrumento != -1) && (dsDatos.CodigoClasificacionInstrumento != 5) && (dsDatos.DescripcionInstrumento.Length > 0)) ? dsDatos.DescripcionInstrumento : string.Empty)).Selected = true;

                            txtInstrumento.Text = ((dsDatos.CodigoClasificacionInstrumento == 5) ? dsDatos.DescripcionInstrumento : string.Empty);

                            cbInstrumento.Visible = (((dsDatos.CodigoClasificacionInstrumento != -1) && (dsDatos.CodigoClasificacionInstrumento != 5)) ? true : false);
                            txtInstrumento.Visible = (((dsDatos.CodigoClasificacionInstrumento != -1) && (dsDatos.CodigoClasificacionInstrumento != 5)) ? false : true);
                            Session["DecripcionInstrumento"] = (((dsDatos.CodigoClasificacionInstrumento != -1) && (dsDatos.CodigoClasificacionInstrumento != 5)) ? cbInstrumento.SelectedItem.Text : txtInstrumento.Text);

                            txtSerie.Text = dsDatos.SerieInstrumento;

                            CargarTiposPersona();
                            cbTipoEmisor.SelectedIndex = -1;
                            cbTipoEmisor.Items.FindByValue(dsDatos.CodigoTipoPersonaEmisor.ToString()).Selected = true;

                            txtEmisor.Text = dsDatos.CedulaEmisor;

                            txtPorcentajePremio.Text = dsDatos.PorcentajePremio.ToString("N2");

                            cbISIN.SelectedIndex = -1;
                            cbISIN.Items.FindByValue((dsDatos.CodigoIsin.Length > 0) ? dsDatos.CodigoIsin : string.Empty).Selected = true;

                            txtValorFacial.Text = dsDatos.MontoValorFacial.ToString("N2");

                            CargarMonedas();
                            cbMonedaValorFacial.SelectedIndex = -1;
                            cbMonedaValorFacial.Items.FindByValue(dsDatos.CodigoMonedaValorFacial.ToString()).Selected = true;

                            txtValorMercado.Text = dsDatos.MontoValorMercado.ToString("N2");

                            cbMonedaValorMercado.SelectedIndex = -1;
                            cbMonedaValorMercado.Items.FindByValue(dsDatos.CodigoMonedaValorMercado.ToString()).Selected = true;

                            CargarTenencias();
                            cbTenencia.SelectedIndex = -1;
                            cbTenencia.Items.FindByValue(dsDatos.CodigoTipoTenencia.ToString()).Selected = true;

                            CargarTipoMitigador();
                            cbMitigador.SelectedIndex = -1;
                            cbMitigador.Items.FindByValue(dsDatos.CodigoTipoMitigador.ToString()).Selected = true;

                            CargarTiposDocumentos();
                            cbTipoDocumento.SelectedIndex = -1;
                            cbTipoDocumento.Items.FindByValue(dsDatos.CodigoTipoDocumentoLegal.ToString()).Selected = true;

                            txtMontoMitigador.Text = dsDatos.MontoMitigiador.ToString("N2");

                            CargarInscripciones();
                            cbInscripcion.SelectedIndex = -1;
                            cbInscripcion.Items.FindByValue(dsDatos.CodigoIndicadorInscripcion.ToString()).Selected = true;

                            txtPorcentajeResponsabilidad.Text = ((dsDatos.PorcentajeResponsabilidad > -1) ? dsDatos.PorcentajeResponsabilidad.ToString("N2") : "0.00");

                            txtPorcentajeAceptacion.Text = dsDatos.PorcentajeAceptacion.ToString("N2");

                            CargarGrados();
                            cbGravamen.SelectedIndex = -1;
                            cbGravamen.Items.FindByValue(dsDatos.CodigoGradoGravamen.ToString()).Selected = true;

                            cbGradoPrioridad.SelectedIndex = -1;
                            cbGradoPrioridad.Items.FindByValue(dsDatos.CodigoGradoPrioridad.ToString()).Selected = true;

                            txtMontoPrioridades.Text = dsDatos.MontoPrioridad.ToString("N2");

                            CargarOperacionEspecial();
                            cbOperacionEspecial.SelectedIndex = -1;
                            cbOperacionEspecial.Items.FindByValue(dsDatos.CodigoOperacionEspecial.ToString()).Selected = true;

                            cbTipoAcreedor.SelectedIndex = -1;
                            cbTipoAcreedor.Items.FindByValue(dsDatos.CodigoTipoPersonaAcreedor.ToString()).Selected = true;

                            txtAcreedor.Text = dsDatos.CedulaAcreedor;

                            Session["GarantiaValor"] = ConsecutivoGarantia.ToString();
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
                                                
                        string usuarioModifico = (((dsDatos.UsuarioModifico.Length > 0) && (dsDatos.NombreUsuarioModifico.Length > 0)) ? (string.Format("{0} - {1}", dsDatos.UsuarioModifico, dsDatos.NombreUsuarioModifico)) : string.Empty);
                        string fechaModifico = ((dsDatos.FechaModifico != fechaBase) ? dsDatos.FechaModifico.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);
                        string fechaReplica = ((dsDatos.FechaReplica != fechaBase) ? dsDatos.FechaReplica.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty);

                        ViewState.Add(LLAVE_FECHA_MODIFICACION, fechaModifico);
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
            NumberFormatInfo a = new NumberFormatInfo();
            a.NumberDecimalSeparator = ".";
        }

        private void CargarGrid(int nTipoOperacion, long nCodOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
            try
            {
                DataSet dsDatos = Gestor.ObtenerListaGarantiasValor(nTipoOperacion, nCodOperacion, nContabilidad, nOficina, nMoneda, nProducto, nOperacion, Session["strUSER"].ToString());

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
            DateTime fechaBase = new DateTime(1900, 01, 01);

            try
            {
                clsGarantiaValor oGarantia = clsGarantiaValor.Current;

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
                
                cbClaseGarantia.ClearSelection();
                cbClaseGarantia.Items.FindByValue(oGarantia.CodigoClaseGarantia.ToString()).Selected = true;
                
                txtSeguridad.Text = oGarantia.NumeroSeguridad.ToString();

                //Informacion general de la garantia

                cbMitigador.ClearSelection();
                cbMitigador.Items.FindByValue(oGarantia.CodigoTipoMitigador.ToString()).Selected = true;
                
                cbTipoDocumento.ClearSelection();
                cbTipoDocumento.Items.FindByValue(oGarantia.CodigoTipoDocumentoLegal.ToString()).Selected = true;
                
                txtMontoMitigador.Text = oGarantia.MontoMitigiador.ToString("N2");
                
                cbInscripcion.ClearSelection();
                cbInscripcion.Items.FindByValue(oGarantia.CodigoIndicadorInscripcion.ToString()).Selected = true;
                
                txtPorcentajeResponsabilidad.Text = ((oGarantia.PorcentajeResponsabilidad > -1) ? oGarantia.PorcentajeResponsabilidad.ToString("N2") : "0.00");

                txtPorcentajeAceptacion.Text = oGarantia.PorcentajeAceptacion.ToString("N2");

                txtFechaConstitucion.Text = ((oGarantia.FechaConstitucion != fechaBase) ? oGarantia.FechaConstitucion.ToShortDateString() : string.Empty);
                
                cbGravamen.ClearSelection();
                cbGravamen.Items.FindByValue(oGarantia.CodigoGradoGravamen.ToString()).Selected = true;

                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.FindByValue(oGarantia.CodigoTipoPersonaAcreedor.ToString()).Selected = true;
                txtAcreedor.Text = oGarantia.CedulaAcreedor;
                
                cbGradoPrioridad.ClearSelection();
                cbGradoPrioridad.Items.FindByValue(oGarantia.CodigoGradoPrioridad.ToString()).Selected = true;

                txtMontoPrioridades.Text = oGarantia.MontoPrioridad.ToString("N2");

                txtFechaVencimiento.Text = ((oGarantia.FechaVencimientoInstrumento != fechaBase) ? oGarantia.FechaVencimientoInstrumento.ToShortDateString() : string.Empty);

                cbOperacionEspecial.ClearSelection();
                cbOperacionEspecial.Items.FindByValue(oGarantia.CodigoOperacionEspecial.ToString()).Selected = true;

                cbClasificacion.ClearSelection();
                cbClasificacion.Items.FindByValue(oGarantia.CodigoClasificacionInstrumento.ToString()).Selected = true;

                if (oGarantia.CodigoClasificacionInstrumento != 5)
                    cbInstrumento.Items.FindByValue(oGarantia.DescripcionInstrumento).Selected = true;
                else
                    txtInstrumento.Text = oGarantia.DescripcionInstrumento;

                txtSerie.Text = oGarantia.SerieInstrumento;

                cbTipoEmisor.ClearSelection();
                cbTipoEmisor.Items.FindByValue(oGarantia.CodigoTipoPersonaEmisor.ToString()).Selected = true;

                txtEmisor.Text = oGarantia.CedulaEmisor;
                
                cbTenencia.ClearSelection();
                cbTenencia.Items.FindByValue(oGarantia.CodigoTipoTenencia.ToString()).Selected = true;

                txtFechaPrescripcion.Text = ((oGarantia.FechaPrescripcion != fechaBase) ? oGarantia.FechaPrescripcion.ToShortDateString() : string.Empty);

                txtPorcentajePremio.Text = oGarantia.PorcentajePremio.ToString("N2");
                
                cbISIN.ClearSelection();
                cbISIN.Items.FindByValue(oGarantia.CodigoIsin).Selected = true;

                txtValorFacial.Text = oGarantia.MontoValorFacial.ToString("N2");

                cbMonedaValorFacial.ClearSelection();
                cbMonedaValorFacial.Items.FindByValue(oGarantia.CodigoMonedaValorFacial.ToString()).Selected = true;

                txtValorMercado.Text = oGarantia.MontoValorMercado.ToString("N2");

                cbMonedaValorMercado.ClearSelection();
                cbMonedaValorMercado.Items.FindByValue(oGarantia.CodigoMonedaValorMercado.ToString()).Selected = true;

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
            DateTime fechaBase = new DateTime(1900, 01, 01);

            try
            {
                clsGarantiaValor oGarantia = clsGarantiaValor.Current;

                //Campos llave
                oGarantia.TipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                oGarantia.Contabilidad = int.Parse(txtContabilidad.Text);
                oGarantia.Oficina = int.Parse(txtOficina.Text);
                oGarantia.Moneda = int.Parse(txtMoneda.Text);

                if (txtProducto.Text.Trim().Length > 0)
                    oGarantia.Producto = int.Parse(txtProducto.Text);

                oGarantia.Numero = long.Parse(txtOperacion.Text);
                oGarantia.CodigoClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());
                oGarantia.NumeroSeguridad = ((txtSeguridad.Text.Trim().Length > 0) ? txtSeguridad.Text : string.Empty);

                //Informacion general de la garantia
                oGarantia.CodigoTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.CodigoTipoDocumentoLegal = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                oGarantia.MontoMitigiador = Convert.ToDecimal(((txtMontoMitigador.Text.Trim().Length > 0) ? txtMontoMitigador.Text : "0"));

                oGarantia.CodigoIndicadorInscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                oGarantia.PorcentajeResponsabilidad = -1; // Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text : "-1"));

                oGarantia.PorcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                oGarantia.FechaConstitucion = ((txtFechaConstitucion.Text.Trim().Length > 0) ? DateTime.Parse(txtFechaConstitucion.Text.ToString()) : fechaBase);

                oGarantia.CodigoGradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());

                oGarantia.CodigoTipoPersonaAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());

                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();

                oGarantia.CodigoGradoPrioridad = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                oGarantia.MontoPrioridad = Convert.ToDecimal(((txtMontoPrioridades.Text.Trim().Length > 0) ? txtMontoPrioridades.Text : "0"));
                
                oGarantia.FechaVencimientoInstrumento = ((txtFechaVencimiento.Text.Trim().Length > 0) ? DateTime.Parse(txtFechaVencimiento.Text.ToString()) : fechaBase);

                oGarantia.CodigoOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                oGarantia.CodigoClasificacionInstrumento = int.Parse(cbClasificacion.SelectedValue.ToString());

                oGarantia.DescripcionInstrumento = ((oGarantia.CodigoClasificacionInstrumento != 5) ? cbInstrumento.SelectedValue.ToString() : txtInstrumento.Text.Trim());

                oGarantia.SerieInstrumento = txtSerie.Text;
                oGarantia.CodigoTipoPersonaEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                oGarantia.CedulaEmisor = txtEmisor.Text.Trim();

                oGarantia.PorcentajePremio = Convert.ToDecimal(((txtPorcentajePremio.Text.Trim().Length > 0) ? txtPorcentajePremio.Text : "0"));

                oGarantia.CodigoIsin = cbISIN.SelectedValue.ToString();

                oGarantia.MontoValorFacial = Convert.ToDecimal(((txtValorFacial.Text.Trim().Length > 0) ? txtValorFacial.Text : "0"));

                oGarantia.CodigoMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                oGarantia.MontoValorMercado = Convert.ToDecimal(((txtValorMercado.Text.Trim().Length > 0) ? txtValorMercado.Text : "0"));

                oGarantia.CodigoMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());

                oGarantia.CodigoTipoTenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                oGarantia.FechaPrescripcion = ((txtFechaPrescripcion.Text.Trim().Length > 0) ? DateTime.Parse(txtFechaPrescripcion.Text.ToString()) : fechaBase);

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
                clsGarantiaValor oGarantia = clsGarantiaValor.Current;

                //Campos llave
                oGarantia.TipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                oGarantia.Contabilidad = int.Parse(txtContabilidad.Text);
                oGarantia.Oficina = int.Parse(txtOficina.Text);
                oGarantia.Moneda = int.Parse(txtMoneda.Text);

                oGarantia.Producto = int.Parse(((txtProducto.Text.Trim().Length > 0) ? txtProducto.Text : "0"));

                oGarantia.Numero = long.Parse(txtOperacion.Text);
                oGarantia.CodigoClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());

                oGarantia.NumeroSeguridad = ((!bLimpiar) && ((txtSeguridad.Text.Trim().Length > 0)) ? txtSeguridad.Text : null);

                //Informacion general de la garantia
                oGarantia.CodigoTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.CodigoTipoDocumentoLegal = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                oGarantia.MontoMitigiador = Convert.ToDecimal((((!bLimpiar) && (txtMontoMitigador.Text.Trim().Length > 0)) ? txtMontoMitigador.Text : "0"));

                oGarantia.CodigoIndicadorInscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                oGarantia.PorcentajeAceptacion = Convert.ToDecimal(((txtPorcentajeAceptacion.Text.Trim().Length > 0) ? txtPorcentajeAceptacion.Text : "0"));

                oGarantia.PorcentajeResponsabilidad = Convert.ToDecimal(((txtPorcentajeResponsabilidad.Text.Trim().Length > 0) ? txtPorcentajeResponsabilidad.Text : "-1"));

                oGarantia.FechaConstitucion = (((!bLimpiar) && (txtFechaConstitucion.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaConstitucion.Text.ToString()) : DateTime.Today);

                oGarantia.CodigoGradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                oGarantia.CodigoTipoPersonaAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.CodigoGradoPrioridad = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                oGarantia.MontoPrioridad = Convert.ToDecimal((((!bLimpiar) && (txtMontoPrioridades.Text.Trim().Length > 0)) ? txtMontoPrioridades.Text : "0"));

                oGarantia.FechaVencimientoInstrumento = (((!bLimpiar) && (txtFechaVencimiento.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaVencimiento.Text.ToString()) : DateTime.Today);
                 
                oGarantia.CodigoOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());

                oGarantia.CodigoClasificacionInstrumento = int.Parse(cbClasificacion.SelectedValue.ToString());

                oGarantia.DescripcionInstrumento = ((oGarantia.CodigoClasificacionInstrumento != 5) ? cbInstrumento.SelectedValue.ToString() : txtInstrumento.Text.Trim());
                  
                oGarantia.SerieInstrumento = txtSerie.Text;
                oGarantia.CodigoTipoPersonaEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                oGarantia.CedulaEmisor = txtEmisor.Text.Trim();

                oGarantia.PorcentajePremio = Convert.ToDecimal(((txtPorcentajePremio.Text.Trim().Length > 0) ? txtPorcentajePremio.Text : "0"));

                oGarantia.CodigoIsin = cbISIN.SelectedValue.ToString();

                oGarantia.MontoValorFacial = Convert.ToDecimal((((!bLimpiar) && (txtValorFacial.Text.Trim().Length > 0)) ? txtValorFacial.Text : "0"));

                oGarantia.CodigoMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                oGarantia.MontoValorMercado = Convert.ToDecimal((((!bLimpiar) && (txtValorMercado.Text.Trim().Length > 0)) ? txtValorMercado.Text : "0"));

                oGarantia.CodigoMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());

                oGarantia.CodigoTipoTenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                oGarantia.FechaPrescripcion = (((!bLimpiar) && (txtFechaPrescripcion.Text.Trim().Length > 0)) ? DateTime.Parse(txtFechaPrescripcion.Text) : DateTime.Today);

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
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaClasesGarantia = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_CLASE_GARANTIA)).FindAll((delegate (clsCatalogo catalogo) { return (catalogo.IDElemento >= 20 && catalogo.IDElemento <= 29) || catalogo.IDElemento == -1; }));
                 
                cbClaseGarantia.DataSource = null;
                cbClaseGarantia.DataSource = listaClasesGarantia;
                cbClaseGarantia.DataValueField = "CodigoElemento";
                cbClaseGarantia.DataTextField = "DescripcionCodigoElemento";
                cbClaseGarantia.DataBind();
                cbClaseGarantia.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
         }

        private void CargarInstrumentos()
        {
            try
            {
                DataSet dsDatos = Gestor.ObtenerCatalogoInstrumentos();

                cbInstrumento.DataSource = null;
                cbInstrumento.DataSource = dsDatos.Tables[0].DefaultView;
                cbInstrumento.DataValueField = "COD_INSTRUMENTO";
                cbInstrumento.DataTextField = "DES_INSTRUMENTO";
                cbInstrumento.ClearSelection();
                cbInstrumento.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[Instrumento] Error: " + ex.Message;
            }
        }

        private void CargarISIN()
        {
            try
            {
                DataSet dsDatos = Gestor.ObtenerCatalogoIsin();

                cbISIN.DataSource = null;
                cbISIN.DataSource = dsDatos.Tables[0].DefaultView;
                cbISIN.DataValueField = "COD_ISIN";
                cbISIN.DataTextField = "COD_ISIN";
                cbISIN.ClearSelection();
                cbISIN.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "[ISIN] Error: " + ex.Message;
            }
        }

        private void CargarTipoMitigador()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposMitigadoress = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPO_MITIGADOR));

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
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
         }

        private void CargarTiposDocumentos()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposDocumentosLegales = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPOS_DOCUMENTOS));

                cbTipoDocumento.DataSource = null;
                cbTipoDocumento.DataSource = listaTiposDocumentosLegales;
                cbTipoDocumento.DataValueField = "CodigoElemento";
                cbTipoDocumento.DataTextField = "DescripcionCodigoElemento";
                cbTipoDocumento.DataBind();
                cbTipoDocumento.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarClasificacionInstrumento()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposClasificacionInstrumentos = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_CLASIFICACION_INSTRUMENTO));

                cbClasificacion.DataSource = null;
                cbClasificacion.DataSource = listaTiposClasificacionInstrumentos;
                cbClasificacion.DataValueField = "CodigoElemento";
                cbClasificacion.DataTextField = "DescripcionCodigoElemento";
                cbClasificacion.DataBind();
                cbClasificacion.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarMonedas()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposMoneda = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_MONEDA));

                cbMonedaValorFacial.DataSource = null;
                cbMonedaValorFacial.DataSource = listaTiposMoneda;
                cbMonedaValorFacial.DataValueField = "CodigoElemento";
                cbMonedaValorFacial.DataTextField = "DescripcionCodigoElemento";
                cbMonedaValorFacial.DataBind();
                cbMonedaValorFacial.ClearSelection();

                cbMonedaValorMercado.DataSource = null;
                cbMonedaValorMercado.DataSource = listaTiposMoneda;
                cbMonedaValorMercado.DataValueField = "CodigoElemento";
                cbMonedaValorMercado.DataTextField = "DescripcionCodigoElemento";
                cbMonedaValorMercado.DataBind();
                cbMonedaValorMercado.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarTenencias()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposTenencia = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TENENCIA));

                cbTenencia.DataSource = null;
                cbTenencia.DataSource = listaTiposTenencia;
                cbTenencia.DataValueField = "CodigoElemento";
                cbTenencia.DataTextField = "DescripcionCodigoElemento";
                cbTenencia.DataBind();
                cbTenencia.ClearSelection();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarGrados()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposGrados = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_GRADO_GRAVAMEN));

                cbGravamen.DataSource = null;
                cbGravamen.DataSource = listaTiposGrados;
                cbGravamen.DataValueField = "CodigoElemento";
                cbGravamen.DataTextField = "DescripcionCodigoElemento";
                cbGravamen.DataBind();
                cbGravamen.ClearSelection();

                cbGradoPrioridad.DataSource = null;
                cbGradoPrioridad.DataSource = listaTiposGrados;
                cbGradoPrioridad.DataValueField = "CodigoElemento";
                cbGradoPrioridad.DataTextField = "DescripcionCodigoElemento";
                cbGradoPrioridad.DataBind();
                cbGradoPrioridad.ClearSelection();
                cbGradoPrioridad.Items.FindByValue(Application["DEFAULT_GRADO_PRIORIDAD"].ToString()).Selected = true;
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarOperacionEspecial()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposOperacionesEspeciales = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_OPERACION_ESPECIAL));

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
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarInscripciones()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                /*Se filtran los datos según requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripción, por AMM-Lidersoft Internacional S.A., el 11/07/2012*/
                List<clsCatalogo> listaIndicadoresInscripcion = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_INSCRIPCION)).FindAll((delegate (clsCatalogo catalogo) { return catalogo.IDElemento == 0 || catalogo.IDElemento == -1; }));

                cbInscripcion.DataSource = null;
                cbInscripcion.DataSource = listaIndicadoresInscripcion;
                cbInscripcion.DataValueField = "CodigoElemento";
                cbInscripcion.DataTextField = "DescripcionCodigoElemento";
                cbInscripcion.DataBind();
                cbInscripcion.ClearSelection();
                cbInscripcion.Items.FindByValue(Application["DEFAULT_INSCRIPCION"].ToString()).Selected = true;
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
            }
        }

        private void CargarTiposPersona()
        {
            if (!ListaCatalogosGV.ErrorDatos)
            {
                List<clsCatalogo> listaTiposPersonas = ListaCatalogosGV.Items(((int)Enumeradores.Catalogos_Garantias_Valor.CAT_TIPO_PERSONA));

                cbTipoAcreedor.DataSource = null;
                cbTipoAcreedor.DataSource = listaTiposPersonas;
                cbTipoAcreedor.DataValueField = "CodigoElemento";
                cbTipoAcreedor.DataTextField = "DescripcionCodigoElemento";
                cbTipoAcreedor.DataBind();
                cbTipoAcreedor.ClearSelection();
                cbTipoAcreedor.Items.FindByValue(Application["DEFAULT_TIPO_ACREEDOR"].ToString()).Selected = true;

                cbTipoEmisor.DataSource = null;
                cbTipoEmisor.DataSource = listaTiposPersonas;
                cbTipoEmisor.DataValueField = "CodigoElemento";
                cbTipoEmisor.DataTextField = "DescripcionCodigoElemento";
                cbTipoEmisor.ClearSelection();
                cbTipoEmisor.DataBind();
            }
            else
            {
                lblMensaje.Text = ListaCatalogosGV.DescripcionError;
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
                bRespuesta = Gestor.ExisteGarantiaValor(txtContabilidad.Text, txtOficina.Text, txtMoneda.Text, txtProducto.Text, txtOperacion.Text, (int.Parse(cbTipoCaptacion.SelectedValue.ToString())), txtSeguridad.Text);               
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
