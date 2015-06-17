using System;
using System.Collections;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Data.OleDb;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Comun;

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

        #endregion Constantes

        #region Variables Globales

        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        protected string strDescInstObt;
        protected string strDescInstNuevo;
        private string _contratoDelGiro = string.Empty;

        #endregion

        #region Propiedades

        /// <summary>
        /// Se guarda en sesi�n el consecutivo de la operaci�n
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
        /// Se guarda en sesi�n el consecutivo de la garant�a seleccionada
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
        /// Se establece si la operaci�n consultada corresponde a un giro de contrato
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
        /// Se establece si la operaci�n consultada corresponde a un giro de contrato, de serlo, 
        /// esta propiedad contendr� el consecutivo de dicho contrato
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

            Button2.Click +=new EventHandler(Button2_Click);
            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnValidarOperacion.Click +=new EventHandler(btnValidarOperacion_Click);
            cbClasificacion.SelectedIndexChanged +=new EventHandler(cbClasificacion_SelectedIndexChanged);
            cbTipoCaptacion.SelectedIndexChanged +=new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtProducto.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtSeguridad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtAcreedor.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtEmisor.Attributes["onblur"] = "javascript:EsNumerico(this);";

            btnEliminar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea eliminar la garant�a seleccionada?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea modificar la garant�a seleccionada?')";


            txtMontoMitigador.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoMitigador.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtPorcentajeAceptacion.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtPorcentajeAceptacion.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,true)");

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
                                     (Session["Accion"].ToString() == "INSERTAR")  ||
                                     (Session["Accion"].ToString() == "MODIFICAR") ||
                                     (Session["Accion"].ToString() == "ELIMINAR"))
                            {
                                btnInsertar.Enabled = true;
                                btnModificar.Enabled = false;
                                btnEliminar.Enabled = false;
                                LimpiarCampos();

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

                        #region Bloquear campos seg�n requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripci�n, por AMM-Lidersoft Internacional S.A., el 11/07/2012

                            cbInscripcion.Enabled = false;

                        #endregion Bloquear campos seg�n requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripci�n, por AMM-Lidersoft Internacional S.A., el 11/07/2012
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta p�gina
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    Utilitarios.RegistraEventLog("Problemas Cargando P�gina. Detalle T�cnico: " + ex.Message + " Trace: " + ex.StackTrace, EventLogEntryType.Error);

                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Acceso Denegado" +
                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta p�gina." +
                            "&bBotonVisible=0");
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando P�gina" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=0");
                }
            }
        }

        private void cbClasificacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            //N�mero de cuenta de deposito
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
        }

        private void Button2_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
        }

        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                decimal nPorcentaje = 0;
                DateTime dFechaConstitucion;
                DateTime dFechaVencimiento;
                DateTime dFechaPrescripcion;
                Session["Accion"] = "INSERTAR";
                decimal nPremio = 0;
                decimal nValorFacial = 0;
                decimal nValorMercado = 0;
                decimal nMontoPrioridades = 0;

                if (ValidarDatos())
                {
                    if (ValidarGarantiaValor())
                    {
                        long nOperacion = ConsecutivoOperacion;
                        int nTipoGarantia = int.Parse(Application["GARANTIA_VALOR"].ToString());
                        int nClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());
                        string strSeguridad = txtSeguridad.Text.Trim();

                        if (txtFechaConstitucion.Text.Trim().Length > 0)
                            dFechaConstitucion = DateTime.Parse(txtFechaConstitucion.Text.ToString());
                        else
                            dFechaConstitucion = DateTime.Parse("1900-01-01");

                        if (txtFechaVencimiento.Text.Trim().Length > 0)
                            dFechaVencimiento = DateTime.Parse(txtFechaVencimiento.Text.ToString());
                        else
                            dFechaVencimiento = DateTime.Parse("1900-01-01");

                        int nClasificacion = int.Parse(cbClasificacion.SelectedValue.ToString());
                        string strInstrumento = "";

                        strInstrumento = cbInstrumento.SelectedValue.ToString();
                        string strSerie = txtSerie.Text.Trim();
                        int nTipoEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                        string strEmisor = txtEmisor.Text.Trim();

                        if (txtPorcentajePremio.Text.Trim().Length > 0)
                            nPremio = Convert.ToDecimal(txtPorcentajePremio.Text);

                        string strISIN = "";

                        strISIN = cbISIN.SelectedValue.ToString();

                        if (txtValorFacial.Text.Trim().Length > 0)
                            nValorFacial = Convert.ToDecimal(txtValorFacial.Text);

                        int nMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                        if (txtValorMercado.Text.Trim().Length > 0)
                            nValorMercado = Convert.ToDecimal(txtValorMercado.Text);

                        int nMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());
                        int nTenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                        if (txtFechaPrescripcion.Text.Trim().Length > 0)
                            dFechaPrescripcion = DateTime.Parse(txtFechaPrescripcion.Text.ToString());
                        else
                            dFechaPrescripcion = DateTime.Parse("1900-01-01");

                        int nTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                        int nTipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());
                        decimal nMontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text);
                        int nInscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                        if (txtPorcentajeAceptacion.Text.Trim().Length > 0)
                            nPorcentaje = Convert.ToDecimal(txtPorcentajeAceptacion.Text);

                        int nGradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                        int nGradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                        if (txtMontoPrioridades.Text.Trim().Length > 0)
                            nMontoPrioridades = Convert.ToDecimal(txtMontoPrioridades.Text);

                        int nOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());
                        int nTipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                        string strAcreedor = txtAcreedor.Text.Trim();

                        string strOperacionCrediticia = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text
                        + "-";
                        if (txtProducto.Visible)
                        {
                            strOperacionCrediticia += txtProducto.Text + "-";
                        }

                        strOperacionCrediticia += txtOperacion.Text;

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
                                                cbInstrumento.SelectedItem.Text);

                        CargarCombos();
                        LimpiarCampos();
                        GuardarDatosSession(true);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserci�n Exitosa" +
                                        "&strMensaje=" + "La garant�a de valor se insert� satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasValor.aspx");
                    }
                    else
                        lblMensaje2.Text = "Ya existe esta garant�a de valor. Por favor verifique...";
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Insertando Registro" +
                        "&strMensaje=" + "No se pudo insertar la garant�a de valor. Error: " + ex.Message +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmGarantiasValor.aspx");
                }
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
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            decimal nPorcentaje = 0;
            DateTime dFechaConstitucion;
            DateTime dFechaVencimiento;
            DateTime dFechaPrescripcion;
            Session["Accion"] = "INSERTAR";
            decimal nPremio = 0;
            decimal nValorFacial = 0;
            decimal nValorMercado = 0;
            decimal nMontoPrioridades = 0;

            try
            {
                Session["Accion"] = "MODIFICAR";
                if (ValidarDatos())
                {
                    long nOperacion = ConsecutivoOperacion;
                    int nTipoGarantia = int.Parse(Application["GARANTIA_VALOR"].ToString());
                    int nClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());
                    string strSeguridad = txtSeguridad.Text.Trim();

                    if (txtFechaConstitucion.Text.Trim().Length > 0)
                        dFechaConstitucion = DateTime.Parse(txtFechaConstitucion.Text.ToString());
                    else
                        dFechaConstitucion = DateTime.Parse("1900-01-01");

                    if (txtFechaVencimiento.Text.Trim().Length > 0)
                        dFechaVencimiento = DateTime.Parse(txtFechaVencimiento.Text.ToString());
                    else
                        dFechaVencimiento = DateTime.Parse("1900-01-01");

                    int nClasificacion = int.Parse(cbClasificacion.SelectedValue.ToString());
                    string strInstrumento = "";
                   
                    if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                    {
                        strInstrumento = cbInstrumento.SelectedValue.ToString();
                        strDescInstNuevo = cbInstrumento.SelectedItem.Text;
                    }
                    else
                    {
                        strInstrumento = txtInstrumento.Text.Trim();
                        strDescInstNuevo = txtInstrumento.Text.Trim();
                    }

                    string strSerie = txtSerie.Text.Trim();
                    int nTipoEmisor = int.Parse(cbTipoEmisor.SelectedValue.ToString());
                    string strEmisor = txtEmisor.Text.Trim();

                    if (txtPorcentajePremio.Text.Trim().Length > 0)
                        nPremio = Convert.ToDecimal(txtPorcentajePremio.Text);

                    string strISIN = "";

                    strISIN = cbISIN.SelectedValue.ToString();

                    if (txtValorFacial.Text.Trim().Length > 0)
                        nValorFacial = Convert.ToDecimal(txtValorFacial.Text);

                    int nMonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                    if (txtValorMercado.Text.Trim().Length > 0)
                        nValorMercado = Convert.ToDecimal(txtValorMercado.Text);

                    int nMonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());
                    int nTenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                    if (txtFechaPrescripcion.Text.Trim().Length > 0)
                        dFechaPrescripcion = DateTime.Parse(txtFechaPrescripcion.Text.ToString());
                    else
                        dFechaPrescripcion = DateTime.Parse("1900-01-01");

                    int nTipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                    int nTipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());
                    decimal nMontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text);
                    int nInscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                    if (txtPorcentajeAceptacion.Text.Trim().Length > 0)
                        nPorcentaje = Convert.ToDecimal(txtPorcentajeAceptacion.Text);

                    int nGradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                    int nGradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                    if (txtMontoPrioridades.Text.Trim().Length > 0)
                        nMontoPrioridades = Convert.ToDecimal(txtMontoPrioridades.Text);

                    int nOperacionEspecial = int.Parse(cbOperacionEspecial.SelectedValue.ToString());
                    int nTipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                    string strAcreedor = txtAcreedor.Text.Trim();

                    string strOperacionCrediticia = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text
                        + "-";
                    if (txtProducto.Visible)
                    {
                        strOperacionCrediticia += txtProducto.Text + "-";
                    }

                    strOperacionCrediticia += txtOperacion.Text;

                    if (Session["DecripcionInstrumento"] != null)
                    {
                        strDescInstObt = Session["DecripcionInstrumento"].ToString();
                    }
                    else
                    {
                        strDescInstObt = strDescInstNuevo;
                    }
                    
                    Gestor.ModificarGarantiaValor(  ConsecutivoOperacion,
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
                                                    strDescInstObt, strDescInstNuevo);

                    Session.Remove("DecripcionInstrumento");
                    CargarCombos();
                    LimpiarCampos();
                    GuardarDatosSession(true);

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificaci�n Exitosa" +
                                    "&strMensaje=" + "La informaci�n de la garant�a de valor se modific� satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasValor.aspx");
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la informaci�n de la garant�a de valor. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasValor.aspx");
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                string strOperacionCrediticia = txtContabilidad.Text + "-" + txtOficina.Text + "-" + txtMoneda.Text
                        + "-";
                if (txtProducto.Visible)
                {
                    strOperacionCrediticia += txtProducto.Text + "-";
                }

                strOperacionCrediticia += txtOperacion.Text;

                Session["Accion"] = "ELIMINAR";

                Gestor.EliminarGarantiaValor(ConsecutivoOperacion,
                                            long.Parse(Session["GarantiaValor"].ToString()),
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString(), strOperacionCrediticia);

                CargarCombos();
                LimpiarCampos();
                GuardarDatosSession(true);

                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Eliminaci�n Exitosa" +
                    "&strMensaje=" + "La garant�a de valor se elimin� satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmGarantiasValor.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar la garant�a de valor." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasValor.aspx");
                }
            }
        }

        private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                //Campos llave
                FormatearCamposNumericos();
                txtOficina.Text = "";
                txtMoneda.Text = "";
                txtProducto.Text = "";
                txtOperacion.Text = "";
                CargarCombos();
                BloquearCampos(false);
                gdvGarantiasValor.DataSource = null;
                gdvGarantiasValor.DataBind();

                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblTipoOperacion.Text = "Operaci�n:";
                    btnValidarOperacion.Text = "Validar Operaci�n";
                    btnValidarOperacion.ToolTip = "Verifica que la operaci�n sea v�lida";
                    Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                    lblProducto.Visible = true;
                    txtProducto.Visible = true;
                }
                else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                {
                    lblTipoOperacion.Text = "Contrato:";
                    btnValidarOperacion.Text = "Validar Contrato";
                    btnValidarOperacion.ToolTip = "Verifica que el contrato sea v�lido";
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
        /// Este evento permite verificar si la informaci�n de la operaci�n es valida
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarOperacion_Click(object sender, System.EventArgs e)
        {
			try
			{
				FormatearCamposNumericos();
				if (ValidarDatosOperacion())
				{
					string strProducto = ((int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString())) ? txtProducto.Text : string.Empty);
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
						Session["Nombre_Deudor"] = "";
						if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
							lblMensaje.Text = "La operaci�n crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
						else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
							lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";

						gdvGarantiasValor.DataSource = null;
						gdvGarantiasValor.DataBind();
					}
				}
			}
			catch (Exception ex)
			{
				Response.Redirect("frmMensaje.aspx?" +
					"bError=1" +
					"&strTitulo=" + "Problemas Cargando P�gina" +
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

        #endregion

        #region M�todos GridView

        protected void gdvGarantiasValor_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvGarantiasValor = (GridView)sender;
            int rowIndex = 0;
			DateTime dFecha;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedGarantiaValor"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvGarantiasValor.SelectedIndex = rowIndex;

						string strObtenerDatos = "select fecha_constitucion, fecha_vencimiento_instrumento, fecha_prescripcion from dbo.GAR_GARANTIA_VALOR where cod_garantia_valor = " + gdvGarantiasValor.SelectedDataKey[1].ToString();

						DataSet dsDatos = AccesoBD.ExecuteDataSet(CommandType.Text, strObtenerDatos, null);

						string strFechaConstiucion = string.Empty;
						string strFechaVencimiento = string.Empty;
						string strFechaPrescripcion = string.Empty;

						if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables[0].Rows.Count > 0))
						{
							if (DateTime.TryParse(dsDatos.Tables[0].Rows[0]["fecha_constitucion"].ToString(), out dFecha))
							{
								strFechaConstiucion = (dFecha.CompareTo(new DateTime(1900, 01, 01)) != 0) ? dFecha.ToString("dd/MM/yyyy") : string.Empty;
							}

							if (DateTime.TryParse(dsDatos.Tables[0].Rows[0]["fecha_vencimiento_instrumento"].ToString(), out dFecha))
							{
								strFechaVencimiento = (dFecha.CompareTo(new DateTime(1900, 01, 01)) != 0) ? dFecha.ToString("dd/MM/yyyy") : string.Empty;
							}

							if (DateTime.TryParse(dsDatos.Tables[0].Rows[0]["fecha_prescripcion"].ToString(), out dFecha))
							{
								strFechaPrescripcion = (dFecha.CompareTo(new DateTime(1900, 01, 01)) != 0) ? dFecha.ToString("dd/MM/yyyy") : string.Empty;
							}
						}

                        FormatearCamposNumericos();

                        try
                        {
                            CargarClasesGarantia();
                            cbClaseGarantia.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[3].ToString() != null)
                                cbClaseGarantia.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[3].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[32].ToString() != null)
                            txtSeguridad.Text = gdvGarantiasValor.SelectedDataKey[32].ToString();
                        else
                            txtSeguridad.Text = "";


						txtFechaConstitucion.Text = strFechaConstiucion;
						txtFechaVencimiento.Text = strFechaVencimiento;
						txtFechaPrescripcion.Text = strFechaPrescripcion;

                        try
                        {
                            CargarClasificacionInstrumento();
                            cbClasificacion.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[6].ToString() != null)
                                cbClasificacion.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[6].ToString()).Selected = true;
                        }
                        catch { }

                        cbInstrumento.SelectedIndex = -1;
                        if (gdvGarantiasValor.SelectedDataKey[7].ToString() != null)
                        {
                            if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                            {
                                cbInstrumento.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[7].ToString()).Selected = true;
                                cbInstrumento.Visible = true;
                                txtInstrumento.Visible = false;
                                strDescInstObt = cbInstrumento.SelectedItem.Text;
                            }
                            else
                            {
                                txtInstrumento.Text = gdvGarantiasValor.SelectedDataKey[7].ToString();
                                cbInstrumento.Visible = false;
                                txtInstrumento.Visible = true;
                                strDescInstObt = txtInstrumento.Text;
                            }

                            Session["DecripcionInstrumento"] = strDescInstObt;
                        }

                        if (gdvGarantiasValor.SelectedDataKey[8].ToString() != null)
                            txtSerie.Text = gdvGarantiasValor.SelectedDataKey[8].ToString();
                        else
                            txtSerie.Text = "";

                        try
                        {
                            CargarTiposPersona();
                            cbTipoEmisor.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[9].ToString() != null)
                                cbTipoEmisor.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[9].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[10].ToString() != null)
                            txtEmisor.Text = gdvGarantiasValor.SelectedDataKey[10].ToString();
                        else
                            txtEmisor.Text = "";

                        if (gdvGarantiasValor.SelectedDataKey[11].ToString() != null)
                        {
                            decimal nPorcentaje = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[11].ToString());
                            txtPorcentajePremio.Text = nPorcentaje.ToString("N");
                        }
                        else
                            txtPorcentajePremio.Text = "0.00";

                        cbISIN.SelectedIndex = -1;
                        if (gdvGarantiasValor.SelectedDataKey[12].ToString() != null)
                            cbISIN.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[12].ToString()).Selected = true;

                        if (gdvGarantiasValor.SelectedDataKey[13].ToString() != null)
                        {
                            decimal nValorFacial = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[13].ToString());
                            txtValorFacial.Text = nValorFacial.ToString("N");
                        }
                        else
                            txtValorFacial.Text = "0.00";

                        try
                        {
                            CargarMonedas();
                            cbMonedaValorFacial.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[14].ToString() != null)
                                cbMonedaValorFacial.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[14].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[15].ToString() != null)
                        {
                            decimal nValorMercado = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[15].ToString());
                            txtValorMercado.Text = nValorMercado.ToString("N");
                        }
                        else
                            txtValorMercado.Text = "0.00";

                        try
                        {
                            cbMonedaValorMercado.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[16].ToString() != null)
                                cbMonedaValorMercado.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[16].ToString()).Selected = true;
                        }
                        catch { }

                        try
                        {
                            CargarTenencias();
                            cbTenencia.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[17].ToString() != null)
                                cbTenencia.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[17].ToString()).Selected = true;
                        }
                        catch { }

                        try
                        {
                            CargarTipoMitigador();
                            cbMitigador.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[19].ToString() != null)
                                cbMitigador.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[19].ToString()).Selected = true;
                        }
                        catch { }

                        try
                        {
                            CargarTiposDocumentos();
                            cbTipoDocumento.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[20].ToString() != null)
                                cbTipoDocumento.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[20].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[22].ToString() != null)
                        {
                            decimal nMontoMitigador = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[22].ToString());
                            txtMontoMitigador.Text = nMontoMitigador.ToString("N");
                        }
                        else
                            txtMontoMitigador.Text = "0.00";

                        try
                        {
                            CargarInscripciones();
                            cbInscripcion.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[21].ToString() != null)
                                cbInscripcion.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[21].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[24].ToString() != null)
                        {
                            decimal nPorcentajeAceptacion = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[24].ToString());
                            txtPorcentajeAceptacion.Text = nPorcentajeAceptacion.ToString("N");
                        }
                        else
                            txtPorcentajeAceptacion.Text = "0.00";

                        try
                        {
                            CargarGrados();
                            cbGravamen.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[25].ToString() != null)
                                cbGravamen.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[25].ToString()).Selected = true;
                        }
                        catch { }

                        try
                        {
                            cbGradoPrioridad.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[26].ToString() != null)
                                cbGradoPrioridad.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[26].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[27].ToString() != null)
                        {
                            decimal nMontoPrioridades = Convert.ToDecimal(gdvGarantiasValor.SelectedDataKey[27].ToString());
                            txtMontoPrioridades.Text = nMontoPrioridades.ToString("N");
                        }
                        else
                            txtMontoPrioridades.Text = "0.00";

                        try
                        {
                            CargarOperacionEspecial();
                            cbOperacionEspecial.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[28].ToString() != null)
                                cbOperacionEspecial.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[28].ToString()).Selected = true;
                        }
                        catch { }

                        try
                        {
                            cbTipoAcreedor.SelectedIndex = -1;
                            if (gdvGarantiasValor.SelectedDataKey[29].ToString() != null)
                                cbTipoAcreedor.Items.FindByValue(gdvGarantiasValor.SelectedDataKey[29].ToString()).Selected = true;
                        }
                        catch { }

                        if (gdvGarantiasValor.SelectedDataKey[30].ToString() != null)
                            txtAcreedor.Text = gdvGarantiasValor.SelectedDataKey[30].ToString();
                        else
                            txtAcreedor.Text = "";

                        if (gdvGarantiasValor.SelectedDataKey[1].ToString() != null)
                            Session["GarantiaValor"] = gdvGarantiasValor.SelectedDataKey[1].ToString();

                        btnInsertar.Enabled = false;
                        btnModificar.Enabled = true;
                        btnEliminar.Enabled = true;
                        btnLimpiar.Enabled = true;
                        lblMensaje.Text = "";
                        lblMensaje2.Text = "";

                        cbGravamen.Enabled = true;
                        txtMontoPrioridades.Enabled = true;
                        cbTenencia.Enabled = true;
                        txtFechaPrescripcion.Enabled = true;

                        igbCalendarioConstitucion.Enabled = true;
                        igbCalendarioPrescripcion.Enabled = true;
                        igbCalendarioVencimiento.Enabled = true;
                      
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

        #region M�todos Privados
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
				System.Data.DataSet dsDatos = new System.Data.DataSet();
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

						if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("des_clase_garantia")) &&
							(!dsDatos.Tables["Datos"].Rows[0].IsNull("numero_seguridad")))
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
        /// Metodo que carga la informaci�n de la garantia que se encuentra almacenada en el objeto Session.
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

                if (oGarantia.MontoMitigador != null)
                    txtMontoMitigador.Text = oGarantia.MontoMitigador.ToString("N");

                if (oGarantia.Inscripcion != 0)
                {
                    cbInscripcion.ClearSelection();
                    cbInscripcion.Items.FindByValue(oGarantia.Inscripcion.ToString()).Selected = true;
                }

                if (oGarantia.PorcentajeResposabilidad != null)
                    txtPorcentajeAceptacion.Text = oGarantia.PorcentajeResposabilidad.ToString("N");

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

                if (oGarantia.MontoPrioridades != null)
                    txtMontoPrioridades.Text = oGarantia.MontoPrioridades.ToString("N");

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

                if (oGarantia.Premio != null)
                    txtPorcentajePremio.Text = oGarantia.Premio.ToString("N");

                if (oGarantia.ISIN != null)
                {
                    cbISIN.ClearSelection();
                    cbISIN.Items.FindByValue(oGarantia.ISIN).Selected = true;
                }

                if (oGarantia.ValorFacial != null)
                    txtValorFacial.Text = oGarantia.ValorFacial.ToString("N");

                if (oGarantia.MonedaValorFacial != 0)
                {
                    cbMonedaValorFacial.ClearSelection();
                    cbMonedaValorFacial.Items.FindByValue(oGarantia.MonedaValorFacial.ToString()).Selected = true;
                }

                if (oGarantia.ValorMercado != null)
                    txtValorMercado.Text = oGarantia.ValorMercado.ToString("N");

                if (oGarantia.MonedaValorMercado != 0)
                {
                    cbMonedaValorMercado.ClearSelection();
                    cbMonedaValorMercado.Items.FindByValue(oGarantia.MonedaValorMercado.ToString()).Selected = true;
                }

                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este m�todo guarda los datos de la pantalla en el objeto Session
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

                if (txtPorcentajeAceptacion.Text.Trim().Length > 0)
                    oGarantia.PorcentajeResposabilidad = Convert.ToDecimal(txtPorcentajeAceptacion.Text); 
                else
                    oGarantia.PorcentajeResposabilidad = 0;

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

                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este m�todo guarda los datos de la pantalla en el objeto Session
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

                if (txtProducto.Text.Trim().Length > 0)
                    oGarantia.Producto = int.Parse(txtProducto.Text);

                oGarantia.Numero = long.Parse(txtOperacion.Text);
                oGarantia.ClaseGarantia = int.Parse(cbClaseGarantia.SelectedValue.ToString());

                if (!bLimpiar)
                {
                    if (txtSeguridad.Text.Trim().Length > 0)
                        oGarantia.Seguridad = txtSeguridad.Text;
                }
                else
                    oGarantia.Seguridad = null;

                //Informacion general de la garantia
                oGarantia.TipoMitigador = int.Parse(cbMitigador.SelectedValue.ToString());
                oGarantia.TipoDocumento = int.Parse(cbTipoDocumento.SelectedValue.ToString());

                if (!bLimpiar)
                {
                    if (txtMontoMitigador.Text.Trim().Length > 0)
                        oGarantia.MontoMitigador = Convert.ToDecimal(txtMontoMitigador.Text); 
                }
                else
                    oGarantia.MontoMitigador = 0;

                oGarantia.Inscripcion = int.Parse(cbInscripcion.SelectedValue.ToString());

                if (txtPorcentajeAceptacion.Text.Trim().Length > 0)
                    oGarantia.PorcentajeResposabilidad = Convert.ToDecimal(txtPorcentajeAceptacion.Text); 
                else
                    oGarantia.PorcentajeResposabilidad = 0;

                if (!bLimpiar)
                {
                    if (txtFechaConstitucion.Text.Trim().Length > 0)
                        oGarantia.FechaConstitucion = DateTime.Parse(txtFechaConstitucion.Text.ToString());
                }
                else
                    oGarantia.FechaConstitucion = DateTime.Today;

                oGarantia.GradoGravamen = int.Parse(cbGravamen.SelectedValue.ToString());
                oGarantia.TipoAcreedor = int.Parse(cbTipoAcreedor.SelectedValue.ToString());
                oGarantia.CedulaAcreedor = txtAcreedor.Text.Trim();
                oGarantia.GradoPrioridades = int.Parse(cbGradoPrioridad.SelectedValue.ToString());

                if (!bLimpiar)
                {
                    if (txtMontoPrioridades.Text.Trim().Length > 0)
                        oGarantia.MontoPrioridades = Convert.ToDecimal(txtMontoPrioridades.Text); 
                }
                else
                    oGarantia.MontoPrioridades = 0;

                if (!bLimpiar)
                {
                    if (txtFechaVencimiento.Text.Trim().Length > 0)
                        oGarantia.FechaVencimiento = DateTime.Parse(txtFechaVencimiento.Text.ToString());
                }
                else
                    oGarantia.FechaVencimiento = DateTime.Today;

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


                if (!bLimpiar)
                {
                    if (txtValorFacial.Text.Trim().Length > 0)
                        oGarantia.ValorFacial = Convert.ToDecimal(txtValorFacial.Text); 
                }
                else
                    oGarantia.ValorFacial = 0;

                oGarantia.MonedaValorFacial = int.Parse(cbMonedaValorFacial.SelectedValue.ToString());

                if (!bLimpiar)
                {
                    if (txtValorMercado.Text.Trim().Length > 0)
                        oGarantia.ValorMercado = Convert.ToDecimal(txtValorMercado.Text); 
                }
                else
                    oGarantia.ValorMercado = 0;

                oGarantia.MonedaValorMercado = int.Parse(cbMonedaValorMercado.SelectedValue.ToString());

                oGarantia.Tenencia = int.Parse(cbTenencia.SelectedValue.ToString());

                if (!bLimpiar)
                {
                    if (txtFechaPrescripcion.Text.Trim().Length > 0)
                        oGarantia.FechaPrescripcion = DateTime.Parse(txtFechaPrescripcion.Text.ToString());
                }
                else
                    oGarantia.FechaPrescripcion = DateTime.Today;

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
                oGarantia.PorcentajeResposabilidad = 0;
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
                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este m�todo permite bloquear o desbloquear los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles est�n bloqueados o no</param>
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

                //Botones
                btnInsertar.Enabled = bBloqueado;
                btnModificar.Enabled = bBloqueado;
                btnEliminar.Enabled = bBloqueado;
                btnLimpiar.Enabled = bBloqueado;
                //Mensajes
                lblMensaje.Text = "";
                lblMensaje2.Text = "";
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este m�todo permite limpiar los campos del formulario
        /// </summary>
        private void LimpiarCampos()
        {
            try
            {
                txtSeguridad.Text = "";
                txtMontoMitigador.Text = "";
                txtPorcentajeAceptacion.Text = "";
                txtAcreedor.Text = "";
                txtFechaConstitucion.Text = "";
                txtFechaVencimiento.Text = "";
                txtFechaPrescripcion.Text = "";
                txtSerie.Text = "";
                txtEmisor.Text = "";
                txtPorcentajePremio.Text = "";
                txtValorFacial.Text = "";
                txtValorMercado.Text = "";
                lblMensaje.Text = "";
                lblMensaje2.Text = "";

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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                lblMensaje.Text = "[Clases de Garant�a] Error: " + ex.Message;
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

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                lblMensaje.Text = "[Clasificaci�n Instrumento] Error: " + ex.Message;
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
                lblMensaje.Text = "[Operaci�n Especial] Error: " + ex.Message;
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                /*Se filtran los datos seg�n requerimiento Siebel No. 1-21317176  ---> 009 Req_Validaciones Indicador Inscripci�n, por AMM-Lidersoft Internacional S.A., el 11/07/2012*/
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_INSCRIPCION"].ToString()) + " AND cat_campo = 0 ", oleDbConnection1);
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
                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
        /// Metodo de validaci�n de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                lblMensaje2.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el c�digo del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el n�mero de operaci�n";
                    else
                        lblMensaje.Text = "Debe ingresar el n�mero de contrato";
                    bRespuesta = false;
                }
                if (bRespuesta && txtSeguridad.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el n�mero de seguridad";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClaseGarantia.SelectedValue.ToString()) == -1)
                {
                    lblMensaje2.Text = "Debe seleccionar la clase de garant�a";
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
                    lblMensaje2.Text = "Debe seleccionar la clasificaci�n del instrumento.";
                    bRespuesta = false;
                }
                if (int.Parse(cbClasificacion.SelectedValue.ToString()) != 5)
                {
                    if (bRespuesta && cbInstrumento.SelectedValue.ToString() == "")
                    {
                        lblMensaje2.Text = "Debe seleccionar la identificaci�n del instrumento.";
                        bRespuesta = false;
                    }
                }
                else
                {
                    if (bRespuesta && txtInstrumento.Text == "")
                    {
                        lblMensaje2.Text = "Debe ingresar el n�mero de cuenta de dep�sito como identificaci�n del instrumento.";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtFechaConstitucion.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar la fecha de emisi�n del instrumento.";
                    bRespuesta = false;
                }
                if (bRespuesta && cbISIN.SelectedValue.ToString() == "")
                {
                    lblMensaje2.Text = "Debe seleccionar el c�digo ISIN.";
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
                    lblMensaje2.Text = "Debe ingresar la fecha de prescripci�n de la garant�a.";
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
        /// Este m�todo permite validar los campos llave de la operaci�n
        /// </summary>
        /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
        private bool ValidarDatosOperacion()
        {
            bool bRespuesta = true;
            lblMensaje.Text = "";
            try
            {
                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el c�digo del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el n�mero de operaci�n";
                    else
                        lblMensaje.Text = "Debe ingresar el n�mero de contrato";

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
                lblMensaje.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el c�digo de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    if (txtProducto.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el c�digo del producto";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                        lblMensaje.Text = "Debe ingresar el n�mero de operaci�n";
                    else
                        lblMensaje.Text = "Debe ingresar el n�mero de contrato";

                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbClaseGarantia.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar la clase de garant�a";
                    bRespuesta = false;
                }
                if (bRespuesta && txtSeguridad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el n�mero de seguridad";
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

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
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
