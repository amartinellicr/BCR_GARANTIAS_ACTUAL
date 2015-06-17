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
using System.Globalization;
using System.Collections.Generic;
using System.Collections.Specialized;

using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Forms
{
    public partial class frmValuacionesReales : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string INDICADOR_MOSTRO_MENSAJE = "IMM";
        private const string FECHA_AVALUO_MAS_RECIENTE = "FAMR";
        private const string FECHA_PRESENTACION = "FP";
        private const string FECHA_CONSTITUCION = "FC";

        #endregion Constantes

        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;
        protected System.Web.UI.WebControls.TextBox txtMontoTasacionActTerreno;

        private int tipoInconsistencia = 0;
        private int tipoBien;

        private Dictionary<string, string> listaDatosGenerales;

        #endregion

        #region Propiedades

        /// <summary>
        /// Obtiene o establece el indicador que determina si se muestra el mensaje de error de las validaciones, donde 1 = Mostralo y 0 = No mostrarlo
        /// </summary>
        public bool MostrarMensaje
        {
            get
            {
                if ((btnRegresar.Attributes[INDICADOR_MOSTRO_MENSAJE] != null) && (btnRegresar.Attributes[INDICADOR_MOSTRO_MENSAJE].Length > 0))
                {
                    return ((btnRegresar.Attributes[INDICADOR_MOSTRO_MENSAJE].CompareTo("1") == 0) ? true : false);
                }
                else
                {
                    btnRegresar.Attributes.Add(INDICADOR_MOSTRO_MENSAJE, "0");
                    return false;
                }
            }

            set
            {
                if (value)
                {
                    btnRegresar.Attributes.Add(INDICADOR_MOSTRO_MENSAJE, "1");
                }
                else
                {
                    btnRegresar.Attributes.Add(INDICADOR_MOSTRO_MENSAJE, "0");
                }
            }
        }

        /// <summary>
        /// Obtiene o establece la fecha del avalúo más reciente
        /// </summary>
        //public DateTime AvaluoMasReciente
        //{
        //    get
        //    {
        //        if ((btnRegresar.Attributes[FECHA_AVALUO_MAS_RECIENTE] != null) && (btnRegresar.Attributes[FECHA_AVALUO_MAS_RECIENTE].Length > 0))
        //        {
        //            DateTime fechaRetornada;
        //            return ((DateTime.TryParse(btnRegresar.Attributes[FECHA_AVALUO_MAS_RECIENTE], out fechaRetornada)) ? fechaRetornada : DateTime.MinValue);
        //        }
        //        else
        //        {
        //            return DateTime.MinValue;
        //        }
        //    }

        //    set
        //    {
        //        btnRegresar.Attributes.Add(FECHA_AVALUO_MAS_RECIENTE, value.ToShortDateString());
        //    }
        //}

        /// <summary>
        /// Obtiene o establece la fecha de presnetación del a garantía
        /// </summary>
        public DateTime FechaPresentacion
        {
            get
            {
                if ((btnRegresar.Attributes[FECHA_PRESENTACION] != null) && (btnRegresar.Attributes[FECHA_PRESENTACION].Length > 0))
                {
                    DateTime fechaPresentacionRetornada;
                    return ((DateTime.TryParse(btnRegresar.Attributes[FECHA_PRESENTACION], out fechaPresentacionRetornada)) ? fechaPresentacionRetornada : DateTime.MinValue);
                }
                else
                {
                    return DateTime.MinValue;
                }
            }

            set
            {
                if (value != DateTime.MinValue)
                {
                    btnRegresar.Attributes.Add(FECHA_PRESENTACION, value.ToShortDateString());
                }
                else
                {
                    btnRegresar.Attributes.Remove(FECHA_PRESENTACION);
                }
            }
        }

        /// <summary>
        /// Obtiene o establece la fecha de constitución de la garantía
        /// </summary>
        public DateTime FechaConstitucion
        {
            get
            {
                if ((btnRegresar.Attributes[FECHA_CONSTITUCION] != null) && (btnRegresar.Attributes[FECHA_CONSTITUCION].Length > 0))
                {
                    DateTime fechaConstitucionRetornada;
                    return ((DateTime.TryParse(btnRegresar.Attributes[FECHA_CONSTITUCION], out fechaConstitucionRetornada)) ? fechaConstitucionRetornada : DateTime.MinValue);
                }
                else
                {
                    return DateTime.MinValue;
                }
            }

            set
            {
                if (value != DateTime.MinValue)
                {
                    btnRegresar.Attributes.Add(FECHA_CONSTITUCION, value.ToShortDateString());
                }
                else
                {
                    btnRegresar.Attributes.Remove(FECHA_CONSTITUCION);
                }
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
            btnRegresar.Click += new EventHandler(btnRegresar_Click);
            Button2.Click += new EventHandler(Button2_Click);
            //tipoInconsistencia = int.Parse((Request.QueryString["TipoInconsistencia"] != null) ? Request.QueryString["TipoInconsistencia"].ToString() : "0");
            //ValidarTipoInconsistencia(tipoInconsistencia);
        }

        protected override void OnLoadComplete(EventArgs e)
        {
            base.OnLoadComplete(e);

            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

            tipoInconsistencia = int.Parse((Request.QueryString["TipoInconsistencia"] != null) ? Request.QueryString["TipoInconsistencia"].ToString() : "0");
            ValidarTipoInconsistencia(tipoInconsistencia);

            //Se obtiene el error de la lista de errores
            if (requestSM != null && requestSM.IsInAsyncPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this,
                                                        typeof(Page),
                                                        Guid.NewGuid().ToString(),
                                                        "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; document.documentElement.style.cursor = 'default'; </script>",
                                                        false);
            }
            else
            {
                this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                       Guid.NewGuid().ToString(),
                                                       "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; document.documentElement.style.cursor = 'default'; </script>",
                                                       false);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtMontoUltTasacionTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoUltTasacionTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtMontoUltTasacionNoTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoUltTasacionNoTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtMontoTasActTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoTasActTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtMontoTasActNoTerreno.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoTasActNoTerreno.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            txtMontoAvaluo.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtMontoAvaluo.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

            btnEliminar.Attributes["onclick"] = "javascript:var acepta = confirm('¿Está seguro que desea eliminar la valuación seleccionada?'); if(acepta == true) { document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait'; return true;} else { document.body.style.cursor = 'default'; document.documentElement.style.cursor = 'default'; return false;}";
            btnModificar.Attributes["onclick"] = "javascript:var acepta = confirm('¿Está seguro que desea modificar la valuación seleccionada?'); if(acepta == true) { document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait'; return true;} else { document.body.style.cursor = 'default'; document.documentElement.style.cursor = 'default'; return false;}";

            btnInsertar.Attributes["onclick"] = "javascript:document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait'; return true;";
            btnLimpiar.Attributes["onclick"] = "javascript:document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait'; return true;";
            btnRegresar.Attributes["onclick"] = "javascript:document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait'; return true;";

            gdvValuacionesReales.Attributes.Add("OnDataBinding", "document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait';");

            listaDatosGenerales = new Dictionary<string, string>();

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_VALUACION_REAL"].ToString())))
                    {
                        string datosGenerales = ((Request.QueryString["DatosGenerales"] != null) ? Request.QueryString["DatosGenerales"].ToString() : string.Empty);

                        if (datosGenerales.Length > 0)
                        {
                            string[] datosGen = datosGenerales.Split("|".ToCharArray(), StringSplitOptions.None);

                            if (datosGen.Length == 9)
                            {
                                //Se obtienen los datos generales que son mostrados en la pantalla de los avalúos, esto para que haya consistencia entre la información de la pantalla principal y la de los avalúos. 
                                //El orden es: Tipo de Garantia Real, Clase de la garantía, Partido, Finca, Grado de cédula hipotecaria, Cédula hipotecaria,
                                //             Clase de bien, Placa del bien y Tipo de bien.
                                listaDatosGenerales.Add(clsGarantiaReal._codTipoGarantiaReal, datosGen[0]);
                                listaDatosGenerales.Add(clsGarantiaReal._codClaseGarantia, datosGen[1]);
                                listaDatosGenerales.Add(clsGarantiaReal._codPartido, datosGen[2]);
                                listaDatosGenerales.Add(clsGarantiaReal._numeroFinca, datosGen[3]);
                                listaDatosGenerales.Add(clsGarantiaReal._codGrado, datosGen[4]);
                                listaDatosGenerales.Add(clsGarantiaReal._cedulaHipotecaria, datosGen[5]);
                                listaDatosGenerales.Add(clsGarantiaReal._codClaseBien, datosGen[6]);
                                listaDatosGenerales.Add(clsGarantiaReal._numPlacaBien, datosGen[7]);
                                listaDatosGenerales.Add(clsGarantiaReal._codTipoBien, datosGen[8]);
                            }
                        }

                        //FormatearCamposNumericos();
                        Session["AccionVal"] = "";
                        lblCatalogo.Text = "Histórico de Valuaciones";
                        CargarCombos();
                        CargarDatos();
                        txtFechaValuacion.Text = DateTime.Today.ToString();
                        CargarGrid();
                        btnModificar.Enabled = false;
                        btnEliminar.Enabled = false;
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
        }

        private void Button2_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
        }

        /// <summary>
        /// Este evento permite insertar valuaciones de garantias reales
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    if (ValidarFecha())
                    {
                        decimal nMontoUltTasacionTerreno = 0;
                        decimal nMontoUltTasacionNoTerreno = 0;
                        string dFechaConstruccion = "";
                        decimal nMontoTasacionActTerreno = 0;
                        decimal nMontoTasacionActNoTerreno = 0;
                        string dFechaUltSeguimiento = "";
                        decimal nMontoAvaluo = 0;
                        int nRecomendacion;
                        int nInspeccion;
                        string strEmpresa = "";
                        string strPerito = "";

                        if (cbEmpresa.SelectedValue.ToString().Length > 0)
                            strEmpresa = cbEmpresa.SelectedValue.ToString();

                        if (cbPerito.SelectedValue.ToString().Length > 0)
                            strPerito = cbPerito.SelectedValue.ToString();


                        #region Modificado por AMM - Lidersoft

                        if (txtMontoUltTasacionTerreno.Text.Trim().Length > 0)
                            nMontoUltTasacionTerreno = Convert.ToDecimal(txtMontoUltTasacionTerreno.Text);

                        if (txtMontoUltTasacionNoTerreno.Text.Trim().Length > 0)
                            nMontoUltTasacionNoTerreno = Convert.ToDecimal(txtMontoUltTasacionNoTerreno.Text);

                        if (txtMontoTasActTerreno.Text.Trim().Length > 0)
                            nMontoTasacionActTerreno = Convert.ToDecimal(txtMontoTasActTerreno.Text);

                        if (txtMontoTasActNoTerreno.Text.Trim().Length > 0)
                            nMontoTasacionActNoTerreno = Convert.ToDecimal(txtMontoTasActNoTerreno.Text);

                        if (txtMontoAvaluo.Text.Trim().Length > 0)
                            nMontoAvaluo = Convert.ToDecimal(txtMontoAvaluo.Text);
                        //if (txtMontoUltTasacionTerreno.Text.Trim().Length > 0)

                        //   //nMontoUltTasacionTerreno = double.Parse(strMontoUltTasacionTerreno);

                        //if (txtMontoUltTasacionNoTerreno.Text.Trim().Length > 0)
                        //    nMontoUltTasacionNoTerreno = double.Parse(txtMontoUltTasacionNoTerreno.Text);

                        //if (txtMontoTasActTerreno.Text.Trim().Length > 0)
                        //    nMontoTasacionActTerreno = double.Parse(txtMontoTasActTerreno.Text);

                        //if (txtMontoTasActNoTerreno.Text.Trim().Length > 0)
                        //    nMontoTasacionActNoTerreno = double.Parse(txtMontoTasActNoTerreno.Text);

                        //if (txtMontoAvaluo.Text.Trim().Length > 0)
                        //    nMontoAvaluo = double.Parse(txtMontoAvaluo.Text);
                        #endregion

                        if (txtFechaSeguimiento.Text.Trim().Length > 0)
                            dFechaUltSeguimiento = txtFechaSeguimiento.Text.ToString();

                        if (txtFechaConstruccion.Text.Trim().Length > 0)
                            dFechaConstruccion = txtFechaConstruccion.Text.ToString();

                        nRecomendacion = int.Parse(cbRecomendacion.SelectedValue.ToString());
                        nInspeccion = int.Parse(cbInspeccion.SelectedValue.ToString());

                        Gestor.CrearValuacionReal(long.Parse(Request.QueryString["nGarantiaReal"].ToString()),
                                                    txtFechaValuacion.Text.ToString(),
                                                    strEmpresa, strPerito,
                                                    nMontoUltTasacionTerreno,
                                                    nMontoUltTasacionNoTerreno,
                                                    nMontoTasacionActTerreno,
                                                    nMontoTasacionActNoTerreno,
                                                    txtFechaSeguimiento.Text.ToString(),
                                                    nMontoAvaluo, nRecomendacion, nInspeccion, dFechaConstruccion,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString());

                        //						Gestor.CrearValuacionReal(long.Parse(Request.QueryString["nGarantiaReal"].ToString()),
                        //												DateTime.Parse(txtFechaValuacion.Text.ToString()),
                        //												strEmpresa, strPerito,
                        //												nMontoUltTasacionTerreno,
                        //												nMontoUltTasacionNoTerreno,
                        //												nMontoTasacionActTerreno,
                        //												nMontoTasacionActNoTerreno,
                        //												dFechaUltSeguimiento,
                        //												nMontoAvaluo, nRecomendacion, nInspeccion, dFechaConstruccion,
                        //												Session["strUSER"].ToString(),
                        //												Request.UserHostAddress.ToString());

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserción Exitosa" +
                                        "&strMensaje=" + "La valuación de la garantía real se insertó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString() + "&nOperacion=" + Request.QueryString["nOperacion"].ToString() + ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty));
                    }
                    else
                    {
                        lblMensaje.Text = "Ya existe una valuación para esta fecha. Por favor verifique.";
                    }
                }
            }
            catch (Exception ex)
            {
                //				lblMensaje.Text = ex.Message;
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + "No se pudo insertar la valuación de la garantía real. Error:" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString() + "&nOperacion=" + Request.QueryString["nOperacion"].ToString() + ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty));
                }
            }
        }

        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmGarantiasReales.aspx", true);
        }

        /// <summary>
        /// Este evento permite limpiar los campos del formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                txtFechaValuacion.Text = "";
                txtMontoUltTasacionTerreno.Text = "";
                txtMontoUltTasacionNoTerreno.Text = "";
                txtMontoTasActTerreno.Text = "";
                txtMontoTasActNoTerreno.Text = "";
                txtFechaSeguimiento.Text = "";
                txtFechaConstruccion.Text = "";
                CargarRecomendacion();
                CargarInspeccion();
                CargarEmpresas();
                CargarPeritos();
                txtMontoAvaluo.Text = "";
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                txtFechaValuacion.Enabled = true;
                igbCalendarioValuacion.Visible = true;
                lblMensaje.Text = "";
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este evento permite modificar la información de valuaciones de garantias reales
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    Session["AccionVal"] = "MODIFICAR";

                    decimal nMontoUltTasacionTerreno = 0;
                    decimal nMontoUltTasacionNoTerreno = 0;
                    string dFechaConstruccion = "";
                    decimal nMontoTasacionActTerreno = 0;
                    decimal nMontoTasacionActNoTerreno = 0;
                    string dFechaUltSeguimiento = "";
                    decimal nMontoAvaluo = 0;
                    int nRecomendacion;
                    int nInspeccion;
                    string strEmpresa = "";
                    string strPerito = "";

                    if (cbEmpresa.SelectedValue.ToString().Length > 0)
                        strEmpresa = cbEmpresa.SelectedValue.ToString();

                    if (cbPerito.SelectedValue.ToString().Length > 0)
                        strPerito = cbPerito.SelectedValue.ToString();

                    if (txtMontoUltTasacionTerreno.Text.Trim().Length > 0)
                        nMontoUltTasacionTerreno = Convert.ToDecimal(txtMontoUltTasacionTerreno.Text);

                    //nMontoUltTasacionTerreno = double.Parse(txtMontoUltTasacionTerreno.Text.Replace(".",""));

                    if (txtMontoUltTasacionNoTerreno.Text.Trim().Length > 0)
                        nMontoUltTasacionNoTerreno = Convert.ToDecimal(txtMontoUltTasacionNoTerreno.Text);

                    //nMontoUltTasacionNoTerreno = double.Parse(txtMontoUltTasacionNoTerreno.Text.Replace(".",""));

                    if (txtMontoTasActTerreno.Text.Trim().Length > 0)
                        nMontoTasacionActTerreno = Convert.ToDecimal(txtMontoTasActTerreno.Text);

                    //nMontoTasacionActTerreno = double.Parse(txtMontoTasActTerreno.Text.Replace(".",""));

                    if (txtMontoTasActNoTerreno.Text.Trim().Length > 0)
                        nMontoTasacionActNoTerreno = Convert.ToDecimal(txtMontoTasActNoTerreno.Text);

                    //nMontoTasacionActNoTerreno = double.Parse(txtMontoTasActNoTerreno.Text.Replace(".",""));

                    if (txtFechaSeguimiento.Text.Trim().Length > 0)
                        dFechaUltSeguimiento = txtFechaSeguimiento.Text.ToString();

                    if (txtFechaConstruccion.Text != null)
                        dFechaConstruccion = txtFechaConstruccion.Text.ToString();

                    if (txtMontoAvaluo.Text.Trim().Length > 0)
                        nMontoAvaluo = Convert.ToDecimal(txtMontoAvaluo.Text);

                    //nMontoAvaluo = double.Parse(txtMontoAvaluo.Text.Replace(".",""));

                    nRecomendacion = int.Parse(cbRecomendacion.SelectedValue.ToString());
                    nInspeccion = int.Parse(cbInspeccion.SelectedValue.ToString());

                    Gestor.ModificarValuacionReal(long.Parse(Request.QueryString["nGarantiaReal"].ToString()),
                                                    txtFechaValuacion.Text.ToString(),
                                                    strEmpresa, strPerito,
                                                    nMontoUltTasacionTerreno,
                                                    nMontoUltTasacionNoTerreno,
                                                    nMontoTasacionActTerreno,
                                                    nMontoTasacionActNoTerreno,
                                                    txtFechaSeguimiento.Text.ToString(),
                                                    nMontoAvaluo, nRecomendacion, nInspeccion, dFechaConstruccion,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString());

                    //					Gestor.ModificarValuacionReal(long.Parse(Request.QueryString["nGarantiaReal"].ToString()), 
                    //												dFechaValuacionTMP, strEmpresaTMP, strPeritoTMP, 
                    //												nMtoUltTasacionTerrenoTMP, nMtoUltTasacionNoTerrenoTMP,
                    //												nMtoTasacionActTerrenoTMP, nMtoTasacionActNoTerrenoTMP,
                    //												dFechaUltSegTMP, nMtoAvaluoTMP, nRecomensacionTMP, nInspeccionTMP,
                    //												dFechaConstruccionTMP, Session["strUSER"].ToString(),
                    //												Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "La valuación de la garantía se modificó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString() + "&nOperacion=" + Request.QueryString["nOperacion"].ToString() + ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty));
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;

                //				if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                //				{
                //					Response.Redirect("frmMensaje.aspx?" + 
                //						"bError=1" + 
                //						"&strTitulo=" + "Problemas Modificando Registro" + 
                //						"&strMensaje=" + "No se pudo modificar la información de la valuación de la garantía." + "\r" + 
                //						"&bBotonVisible=1" +
                //						"&strTextoBoton=Regresar" + 
                //						"&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString());
                //				}
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarValuacionReal(long.Parse(Request.QueryString["nGarantiaReal"].ToString()),
                                            txtFechaValuacion.Text.ToString(),
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString());

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + "La valuación de la garantía se eliminó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString() + "&nOperacion=" + Request.QueryString["nOperacion"].ToString() + ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty));
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar la valuación de la garantía." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuacionesReales.aspx?nGarantiaReal=" + Request.QueryString["nGarantiaReal"].ToString() + "&nOperacion=" + Request.QueryString["nOperacion"].ToString() + ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty));

                }
            }
        }

        protected void txtMontoTasActTerreno_TextChanged(object sender, EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                decimal nMontoTotal;
                string strMonto1, strMonto2;

                if (txtMontoTasActTerreno.Text != string.Empty)
                {
                    strMonto1 = txtMontoTasActTerreno.Text;
                }
                else
                {
                    strMonto1 = "0";
                }
                //txtMontoTasActTerreno.Text = String.Format("{0:D}", strMonto1);

                //				strMonto1 = strMonto1.Replace(",","");

                if (txtMontoTasActNoTerreno.Text != string.Empty)
                {
                    strMonto2 = txtMontoTasActNoTerreno.Text;
                }
                else
                {
                    strMonto2 = "0";
                }

                //txtMontoTasActNoTerreno.Text = String.Format("{0:D}", strMonto2);
                //				strMonto2 = strMonto2.Replace(",","");

                Session["AccionVal"] = "MODIFICAR";
                nMontoTotal = Convert.ToDecimal(strMonto1) + Convert.ToDecimal(strMonto2);
                //nMontoTotal = double.Parse(strMonto1.Replace(".",",")) + double.Parse(strMonto2.Replace(".",","));
                txtMontoAvaluo.Text = nMontoTotal.ToString("N");
            }
            catch
            {
                FormatearCamposNumericos();
                txtMontoAvaluo.Text = "0.00";
            }
        }

        protected void txtMontoTasActNoTerreno_TextChanged(object sender, EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                decimal nMontoTotal;
                string strMonto1, strMonto2;

                if (txtMontoTasActTerreno.Text != string.Empty)
                {
                    strMonto1 = txtMontoTasActTerreno.Text;
                }
                else
                {
                    strMonto1 = "0";
                }
                //txtMontoTasActTerreno.Text = String.Format("{0:D}", strMonto1);
                //				strMonto1 = strMonto1.Replace(",","");

                if (txtMontoTasActNoTerreno.Text != string.Empty)
                {
                    strMonto2 = txtMontoTasActNoTerreno.Text;
                }
                else
                {
                    strMonto2 = "0";
                }
                //txtMontoTasActNoTerreno.Text = String.Format("{0:D}", strMonto2);
                //				strMonto2 = strMonto2.Replace(",","");

                Session["AccionVal"] = "MODIFICAR";
                nMontoTotal = Convert.ToDecimal(strMonto1) + Convert.ToDecimal(strMonto2);
                //nMontoTotal = double.Parse(strMonto1.Replace(".",",")) + double.Parse(strMonto2.Replace(".",","));
                txtMontoAvaluo.Text = nMontoTotal.ToString("N");
            }
            catch
            {
                FormatearCamposNumericos();
                txtMontoAvaluo.Text = "0.00";
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvValuacionesReales_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvValuacionesReales = (GridView)sender;
            int rowIndex = 0;
            ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);
            //DateTime avaluoMasReciente;
            DateTime fechaPresentacion;
            DateTime fechaConstitucion;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedValuacionReal"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvValuacionesReales.SelectedIndex = rowIndex;

                        try
                        {
                            lblMensaje.Text = string.Empty;

                            FormatearCamposNumericos();

                            MostrarMensaje = ((rowIndex == 0) ? true : false);

                            //AvaluoMasReciente = ((gdvValuacionesReales.SelectedDataKey[14].ToString() != null) && (DateTime.TryParse(gdvValuacionesReales.SelectedDataKey[14].ToString(), out avaluoMasReciente)) ? avaluoMasReciente : DateTime.MinValue);
                            FechaPresentacion = ((gdvValuacionesReales.SelectedDataKey[14].ToString() != null) && (DateTime.TryParse(gdvValuacionesReales.SelectedDataKey[14].ToString(), out fechaPresentacion)) ? fechaPresentacion : DateTime.MinValue);
                            FechaConstitucion = ((gdvValuacionesReales.SelectedDataKey[15].ToString() != null) && (DateTime.TryParse(gdvValuacionesReales.SelectedDataKey[15].ToString(), out fechaConstitucion)) ? fechaConstitucion : DateTime.MinValue);
                            
                            if (gdvValuacionesReales.SelectedDataKey[0].ToString() != null)
                                txtFechaValuacion.Text = gdvValuacionesReales.SelectedDataKey[0].ToString();

                            CargarEmpresas();
                            if (gdvValuacionesReales.SelectedDataKey[1].ToString() != null)
                            {
                                cbEmpresa.ClearSelection();
                                cbEmpresa.Items.FindByValue(gdvValuacionesReales.SelectedDataKey[1].ToString()).Selected = true;
                            }

                            CargarPeritos();
                            if (gdvValuacionesReales.SelectedDataKey[2].ToString() != null)
                            {
                                cbPerito.ClearSelection();
                                cbPerito.Items.FindByValue(gdvValuacionesReales.SelectedDataKey[2].ToString()).Selected = true;
                            }

                            if (gdvValuacionesReales.SelectedDataKey[3].ToString() != null)
                            {
                                decimal nMontoUltTasacionTerreno = Convert.ToDecimal(gdvValuacionesReales.SelectedDataKey[3].ToString());
                                txtMontoUltTasacionTerreno.Text = nMontoUltTasacionTerreno.ToString("N");
                            }
                            else
                            {
                                txtMontoUltTasacionTerreno.Text = "0.00";
                            }

                            if (gdvValuacionesReales.SelectedDataKey[4].ToString() != null)
                            {
                                decimal nMontoUltTasacionNoTerreno = Convert.ToDecimal(gdvValuacionesReales.SelectedDataKey[4].ToString());
                                txtMontoUltTasacionNoTerreno.Text = nMontoUltTasacionNoTerreno.ToString("N");
                                txtMontoUltTasacionNoTerreno.Enabled = true;
                            }
                            else
                            {
                                txtMontoUltTasacionNoTerreno.Text = "0.00";
                            }

                            if (Session["AccionVal"].ToString() != "MODIFICAR")
                            {
                                if (gdvValuacionesReales.SelectedDataKey[11].ToString() != null)
                                {
                                    decimal nMontoTasActTerreno = Convert.ToDecimal(gdvValuacionesReales.SelectedDataKey[11].ToString());
                                    txtMontoTasActTerreno.Text = nMontoTasActTerreno.ToString("N");
                                }
                                else
                                {
                                    txtMontoTasActTerreno.Text = "0.00";
                                }

                                if (gdvValuacionesReales.SelectedDataKey[12].ToString() != null)
                                {
                                    decimal nMontoTasActNoTerreno = Convert.ToDecimal(gdvValuacionesReales.SelectedDataKey[12].ToString());
                                    txtMontoTasActNoTerreno.Text = nMontoTasActNoTerreno.ToString("N");
                                    txtMontoTasActNoTerreno.Enabled = true;
                                }
                                else
                                {
                                    txtMontoTasActNoTerreno.Text = "0.00";
                                }

                                //					if (e.SelectedCells[0].Row.Cells[10].Value != null)
                                //						txtMontoAvaluo.Text = e.SelectedCells[0].Row.Cells[10].Value;
                                //					else
                                //						txtMontoAvaluo.Text = 0;

                                decimal nMontoAvaluo = Convert.ToDecimal(txtMontoTasActTerreno.Text.ToString()) + Convert.ToDecimal(txtMontoTasActNoTerreno.Text.ToString());
                                txtMontoAvaluo.Text = nMontoAvaluo.ToString("N");
                            }
                            if ((gdvValuacionesReales.SelectedDataKey[6].ToString() != null) && (gdvValuacionesReales.SelectedDataKey[6].ToString() != string.Empty))
                            {
                                DateTime dFechaConstruccion = Convert.ToDateTime(gdvValuacionesReales.SelectedDataKey[6].ToString());
                                if (dFechaConstruccion.ToShortDateString().CompareTo("01/01/1900/") != 0)
                                {
                                    txtFechaConstruccion.Text = dFechaConstruccion.ToShortDateString();
                                    txtFechaConstruccion.Enabled = true;
                                }
                            }

                            if ((gdvValuacionesReales.SelectedDataKey[5].ToString() != null) && (gdvValuacionesReales.SelectedDataKey[5].ToString() != string.Empty))
                            {
                                DateTime dFechaUltimoSeguimiento = Convert.ToDateTime(gdvValuacionesReales.SelectedDataKey[5].ToString());
                                if (dFechaUltimoSeguimiento.ToShortDateString().CompareTo("01/01/1900") != 0)
                                    txtFechaSeguimiento.Text = dFechaUltimoSeguimiento.ToShortDateString();
                            }

                            CargarRecomendacion();
                            if (gdvValuacionesReales.SelectedDataKey[7].ToString() != null)
                                if (int.Parse(gdvValuacionesReales.SelectedDataKey[7].ToString()) != -1)
                                {
                                    cbRecomendacion.ClearSelection();
                                    cbRecomendacion.Items.FindByValue(gdvValuacionesReales.SelectedDataKey[7].ToString()).Selected = true;
                                }

                            CargarInspeccion();
                            if (gdvValuacionesReales.SelectedDataKey[8].ToString() != null)
                                if (int.Parse(gdvValuacionesReales.SelectedDataKey[8].ToString()) != -1)
                                {
                                    cbInspeccion.ClearSelection();
                                    cbInspeccion.Items.FindByValue(gdvValuacionesReales.SelectedDataKey[8].ToString()).Selected = true;
                                }

                            CargarDatos();
                            txtFechaValuacion.Enabled = false;
                            igbCalendarioValuacion.Visible = false;
                            btnInsertar.Enabled = false;
                            btnModificar.Enabled = true;
                            btnEliminar.Enabled = true;

                            tipoInconsistencia = int.Parse((Request.QueryString["TipoInconsistencia"] != null) ? Request.QueryString["TipoInconsistencia"].ToString() : "0");
                            ValidarTipoInconsistencia(tipoInconsistencia);
                        }
                        catch (Exception ex)
                        {
                            lblMensaje.Text = ex.Message;
                        }


                        //Se cambia el puntero del cursor
                        if (requestSM != null && requestSM.IsInAsyncPostBack)
                        {
                            ScriptManager.RegisterClientScriptBlock(this,
                                                                    typeof(Page),
                                                                    Guid.NewGuid().ToString(),
                                                                    "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; </script>",
                                                                    false);
                        }
                        else
                        {
                            this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                                   Guid.NewGuid().ToString(),
                                                                   "<script type=\"text/javascript\" language=\"javascript\">document.body.style.cursor = 'default'; </script>",
                                                                   false);
                        }

                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        protected void gdvValuacionesReales_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvValuacionesReales.SelectedIndex = -1;
            this.gdvValuacionesReales.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        protected void gdvValuacionesReales_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            gdvValuacionesReales.Attributes.Add("onClick", "document.body.style.cursor = 'wait'; document.documentElement.style.cursor = 'wait';");
        }

        #endregion

        #region Métodos Privados
        private void FormatearCamposNumericos()
        {
            System.Globalization.NumberFormatInfo a = new System.Globalization.NumberFormatInfo();
            a.NumberDecimalSeparator = ".";
            //txtMontoUltTasacionTerreno.NumberFormat = a;
            //txtMontoUltTasacionNoTerreno.NumberFormat = a;
            //txtMontoTasActTerreno.NumberFormat = a;
            //txtMontoTasActNoTerreno.NumberFormat = a;
            //txtMontoAvaluo.NumberFormat = a;
        }

        public static NumberFormatInfo ConfigurarFormatoNumeros()
        {

            NumberFormatInfo tipo_formato = new NumberFormatInfo();

            tipo_formato.NumberGroupSeparator = ",";

            tipo_formato.NumberDecimalSeparator = ".";

            tipo_formato.NumberDecimalDigits = 2;

            return tipo_formato;

        }

        private void CargarDatos()
        {
            try
            {
                if (listaDatosGenerales.Count == 0)
                {
                    string strQry = "SELECT " +
                                        "cod_tipo_garantia, " +
                                        "cod_clase_garantia, " +
                                        "cod_tipo_garantia_real, " +
                                        "cod_partido, " +
                                        "numero_finca, " +
                                        "cod_grado, " +
                                        "cedula_hipotecaria, " +
                                        "cod_clase_bien, " +
                                        "num_placa_bien, " +
                                        "cod_tipo_bien " +
                                    "FROM " +
                                        "GAR_GARANTIA_REAL " +
                                    "WHERE " +
                                        "cod_garantia_real = " + Request.QueryString["nGarantiaReal"].ToString();

                    System.Data.DataSet dsDatos = new System.Data.DataSet();
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strQry, oleDbConnection1);
                    cmdConsulta.Fill(dsDatos, "Garantia");

                    if (dsDatos.Tables["Garantia"].Rows.Count > 0)
                    {
                        FormatearCamposNumericos();
                        CargarTiposGarantiaReal();
                        cbTipoGarantiaReal.Items.FindByValue(dsDatos.Tables["Garantia"].Rows[0][2].ToString()).Selected = true;
                        CargarClasesGarantia();
                        cbClase.Items.FindByValue(dsDatos.Tables["Garantia"].Rows[0][1].ToString()).Selected = true;

                        if (int.Parse(dsDatos.Tables["Garantia"].Rows[0][2].ToString()) == int.Parse(Application["HIPOTECAS"].ToString()))
                        {
                            txtPartido.Text = dsDatos.Tables["Garantia"].Rows[0][3].ToString();
                            txtNumFinca.Text = dsDatos.Tables["Garantia"].Rows[0][4].ToString();
                            lblPartido.Text = "Partido:";
                            lblFinca.Text = "Número Finca:";
                            lblGrado.Visible = false;
                            lblCedula.Visible = false;
                            txtGrado.Visible = false;
                            txtCedulaHipotecaria.Visible = false;
                            //txtMontoTasActNoTerreno.Enabled = true;
                            txtMontoUltTasacionTerreno.Enabled = true;
                            txtMontoTasActTerreno.Enabled = true;

                            tipoBien = int.Parse((dsDatos.Tables["Garantia"].Rows[0].IsNull(9)) ? "-1" : dsDatos.Tables["Garantia"].Rows[0][9].ToString());

                            hdfTipoBien.Value = tipoBien.ToString();

                            if (tipoBien == 1)
                            {
                                if (txtMontoUltTasacionNoTerreno.Text.Length > 0)
                                {
                                    if (txtMontoUltTasacionNoTerreno.Text.CompareTo("0.00") == 0)
                                    {
                                        txtMontoUltTasacionNoTerreno.Enabled = false;
                                    }
                                    else
                                    {
                                        txtMontoUltTasacionNoTerreno.Enabled = true;
                                    }
                                }
                                else
                                {
                                    txtMontoUltTasacionNoTerreno.Enabled = false;
                                }

                                if (txtMontoTasActNoTerreno.Text.Length > 0)
                                {
                                    if (txtMontoTasActNoTerreno.Text.CompareTo("0.00") == 0)
                                    {
                                        txtMontoTasActNoTerreno.Enabled = false;
                                    }
                                    else
                                    {
                                        txtMontoTasActNoTerreno.Enabled = true;
                                    }
                                }
                                else
                                {
                                    txtMontoTasActNoTerreno.Enabled = false;
                                }

                                if (txtFechaConstruccion.Text.Length == 0)
                                {
                                    txtFechaConstruccion.Enabled = false;
                                    igbCalendarioConstruccion.Visible = false;
                                }
                            }
                        }
                        else if (int.Parse(dsDatos.Tables["Garantia"].Rows[0][2].ToString()) == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                        {
                            txtPartido.Text = dsDatos.Tables["Garantia"].Rows[0][3].ToString();
                            txtNumFinca.Text = dsDatos.Tables["Garantia"].Rows[0][4].ToString();
                            txtGrado.Text = dsDatos.Tables["Garantia"].Rows[0][5].ToString();
                            txtCedulaHipotecaria.Text = dsDatos.Tables["Garantia"].Rows[0][6].ToString();
                            lblPartido.Text = "Partido:";
                            lblFinca.Text = "Número Finca:";
                            lblGrado.Visible = true;
                            lblCedula.Visible = true;
                            txtGrado.Visible = true;
                            txtCedulaHipotecaria.Visible = true;
                            txtMontoTasActNoTerreno.Enabled = true;
                            txtMontoUltTasacionNoTerreno.Enabled = true;
                            txtMontoUltTasacionTerreno.Enabled = true;
                            txtMontoTasActTerreno.Enabled = true;
                        }
                        else if (int.Parse(dsDatos.Tables["Garantia"].Rows[0][2].ToString()) == int.Parse(Application["PRENDAS"].ToString()))
                        {
                            txtPartido.Text = dsDatos.Tables["Garantia"].Rows[0][7].ToString();
                            txtNumFinca.Text = dsDatos.Tables["Garantia"].Rows[0][8].ToString();
                            lblPartido.Text = "Clase Bien:";
                            lblFinca.Text = "# Placa Bien:";
                            lblGrado.Visible = false;
                            lblCedula.Visible = false;
                            txtGrado.Visible = false;
                            txtCedulaHipotecaria.Visible = false;

                            txtMontoTasActNoTerreno.Enabled = true;
                            txtMontoUltTasacionNoTerreno.Enabled = true;

                            txtMontoUltTasacionTerreno.Enabled = false;
                            txtMontoTasActTerreno.Enabled = false;
                        }
                    }
                }
                else
                {
                    FormatearCamposNumericos();
                    CargarTiposGarantiaReal();
                    cbTipoGarantiaReal.Items.FindByValue(listaDatosGenerales[clsGarantiaReal._codTipoGarantiaReal]).Selected = true;
                    CargarClasesGarantia();
                    cbClase.Items.FindByValue(listaDatosGenerales[clsGarantiaReal._codClaseGarantia]).Selected = true;

                    if (int.Parse(listaDatosGenerales[clsGarantiaReal._codTipoGarantiaReal]) == int.Parse(Application["HIPOTECAS"].ToString()))
                    {
                        txtPartido.Text = listaDatosGenerales[clsGarantiaReal._codPartido];
                        txtNumFinca.Text = listaDatosGenerales[clsGarantiaReal._numeroFinca];
                        lblPartido.Text = "Partido:";
                        lblFinca.Text = "Número Finca:";
                        lblGrado.Visible = false;
                        lblCedula.Visible = false;
                        txtGrado.Visible = false;
                        txtCedulaHipotecaria.Visible = false;
                        //txtMontoTasActNoTerreno.Enabled = true;
                        txtMontoUltTasacionTerreno.Enabled = true;
                        txtMontoTasActTerreno.Enabled = true;

                        //tipoBien = int.Parse((dsDatos.Tables["Garantia"].Rows[0].IsNull(9)) ? "-1" : dsDatos.Tables["Garantia"].Rows[0][9].ToString());

                        hdfTipoBien.Value = listaDatosGenerales[clsGarantiaReal._codTipoBien];

                        if (listaDatosGenerales[clsGarantiaReal._codTipoBien].CompareTo("1") == 0)
                        {
                            if (txtMontoUltTasacionNoTerreno.Text.Length > 0)
                            {
                                if (txtMontoUltTasacionNoTerreno.Text.CompareTo("0.00") == 0)
                                {
                                    txtMontoUltTasacionNoTerreno.Enabled = false;
                                }
                                else
                                {
                                    txtMontoUltTasacionNoTerreno.Enabled = true;
                                }
                            }
                            else
                            {
                                txtMontoUltTasacionNoTerreno.Enabled = false;
                            }

                            if (txtMontoTasActNoTerreno.Text.Length > 0)
                            {
                                if (txtMontoTasActNoTerreno.Text.CompareTo("0.00") == 0)
                                {
                                    txtMontoTasActNoTerreno.Enabled = false;
                                }
                                else
                                {
                                    txtMontoTasActNoTerreno.Enabled = true;
                                }
                            }
                            else
                            {
                                txtMontoTasActNoTerreno.Enabled = false;
                            }

                            if (txtFechaConstruccion.Text.Length == 0)
                            {
                                txtFechaConstruccion.Enabled = false;
                                igbCalendarioConstruccion.Visible = false;
                            }
                        }
                    }
                    else if (int.Parse(listaDatosGenerales[clsGarantiaReal._codTipoGarantiaReal]) == int.Parse(Application["CEDULAS_HIPOTECARIAS"].ToString()))
                    {
                        txtPartido.Text = listaDatosGenerales[clsGarantiaReal._codPartido];
                        txtNumFinca.Text = listaDatosGenerales[clsGarantiaReal._numeroFinca];
                        txtGrado.Text = listaDatosGenerales[clsGarantiaReal._codGrado];
                        txtCedulaHipotecaria.Text = listaDatosGenerales[clsGarantiaReal._cedulaHipotecaria];
                        lblPartido.Text = "Partido:";
                        lblFinca.Text = "Número Finca:";
                        lblGrado.Visible = true;
                        lblCedula.Visible = true;
                        txtGrado.Visible = true;
                        txtCedulaHipotecaria.Visible = true;
                        txtMontoTasActNoTerreno.Enabled = true;
                        txtMontoUltTasacionNoTerreno.Enabled = true;
                        txtMontoUltTasacionTerreno.Enabled = true;
                        txtMontoTasActTerreno.Enabled = true;
                    }
                    else if (int.Parse(listaDatosGenerales[clsGarantiaReal._codTipoGarantiaReal]) == int.Parse(Application["PRENDAS"].ToString()))
                    {
                        txtPartido.Text = listaDatosGenerales[clsGarantiaReal._codClaseBien];
                        txtNumFinca.Text = listaDatosGenerales[clsGarantiaReal._numPlacaBien];
                        lblPartido.Text = "Clase Bien:";
                        lblFinca.Text = "# Placa Bien:";
                        lblGrado.Visible = false;
                        lblCedula.Visible = false;
                        txtGrado.Visible = false;
                        txtCedulaHipotecaria.Visible = false;

                        txtMontoTasActNoTerreno.Enabled = true;
                        txtMontoUltTasacionNoTerreno.Enabled = true;

                        txtMontoUltTasacionTerreno.Enabled = false;
                        txtMontoTasActTerreno.Enabled = false;
                    }
                }
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
                CargarTiposGarantiaReal();
                CargarClasesGarantia();
                CargarEmpresas();
                CargarPeritos();
                CargarRecomendacion();
                CargarInspeccion();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void CargarEmpresas()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cedula_empresa, cedula_empresa + ' - ' + des_empresa as des_empresa FROM gar_empresa UNION ALL SELECT '', '' ORDER BY des_empresa", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Empresas");
            cbEmpresa.DataSource = null;
            cbEmpresa.DataSource = dsDatos.Tables["Empresas"].DefaultView;
            cbEmpresa.DataValueField = "cedula_empresa";
            cbEmpresa.DataTextField = "des_empresa";
            cbEmpresa.ClearSelection();
            cbEmpresa.DataBind();
        }

        private void CargarPeritos()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cedula_perito, cedula_perito + ' - ' + des_perito as des_perito FROM gar_perito UNION ALL SELECT '', '' ORDER BY des_perito", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Peritos");
            cbPerito.DataSource = null;
            cbPerito.DataSource = dsDatos.Tables["Peritos"].DefaultView;
            cbPerito.DataValueField = "cedula_perito";
            cbPerito.DataTextField = "des_perito";
            cbPerito.ClearSelection();
            cbPerito.DataBind();
        }

        private void CargarTiposGarantiaReal()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_GARANTIA_REAL"].ToString()) + " ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbTipoGarantiaReal.DataSource = null;
            cbTipoGarantiaReal.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbTipoGarantiaReal.DataValueField = "CAT_CAMPO";
            cbTipoGarantiaReal.DataTextField = "CAT_DESCRIPCION";
            cbTipoGarantiaReal.ClearSelection();
            cbTipoGarantiaReal.DataBind();
        }

        private void CargarClasesGarantia()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + '-' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_CLASE_GARANTIA"].ToString()) + " AND CAT_CAMPO BETWEEN 10 AND 69 UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Codigos");
            cbClase.DataSource = null;
            cbClase.DataSource = dsDatos.Tables["Codigos"].DefaultView;
            cbClase.DataValueField = "CAT_CAMPO";
            cbClase.DataTextField = "CAT_DESCRIPCION";
            cbClase.ClearSelection();
            cbClase.DataBind();
        }

        private void CargarRecomendacion()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_RECOMENDACION_PERITO"].ToString()) + " ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbRecomendacion.DataSource = null;
            cbRecomendacion.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbRecomendacion.DataValueField = "CAT_CAMPO";
            cbRecomendacion.DataTextField = "CAT_DESCRIPCION";
            cbRecomendacion.ClearSelection();
            cbRecomendacion.DataBind();
        }

        private void CargarInspeccion()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_INSPECCION_3_MESES"].ToString()) + " ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbInspeccion.DataSource = null;
            cbInspeccion.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbInspeccion.DataValueField = "CAT_CAMPO";
            cbInspeccion.DataTextField = "CAT_DESCRIPCION";
            cbInspeccion.ClearSelection();
            cbInspeccion.DataBind();
        }

        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "convert(varchar(10),a.fecha_valuacion,103) as fecha_valuacion, " +
                                    "isnull(a.cedula_empresa,'') as cedula_empresa, " +
                                    "isnull(a.cedula_perito,'') as cedula_perito, " +
                                    "isnull(a.monto_ultima_tasacion_terreno,0) as monto_ultima_tasacion_terreno, " +
                                    "isnull(a.monto_ultima_tasacion_no_terreno,0) as monto_ultima_tasacion_no_terreno, " +
                                    "isnull(a.monto_tasacion_actualizada_terreno,0) as monto_tasacion_actualizada_terreno, " +
                                    "isnull(a.monto_tasacion_actualizada_no_terreno,0) as monto_tasacion_actualizada_no_terreno, " +
                                    "isnull(convert(varchar(10),a.fecha_ultimo_seguimiento,111),'') as fecha_ultimo_seguimiento, " +
                                    "b.cat_descripcion as des_recomendacion_perito, " +
                                    "c.cat_descripcion as des_inspeccion_menor_tres_meses, " +
                                    "isnull(a.monto_tasacion_actualizada_terreno,0) + isnull(a.monto_tasacion_actualizada_no_terreno,0) as monto_total_avaluo, " +
                                    //"isnull(a.monto_total_avaluo,0) as monto_total_avaluo, " +  
                                    "isnull(a.cod_recomendacion_perito,-1) as cod_recomendacion_perito, " +
                                    "isnull(a.cod_inspeccion_menor_tres_meses,-1) as cod_inspeccion_menor_tres_meses, " +
                                    "isnull(convert(varchar(10),a.fecha_construccion,111),'') as fecha_construccion, " +
                                    "d.fecha_valuacion_mas_reciente, " +
                                    "e.fecha_presentacion, " +
                                    "e.fecha_constitucion " +
                                "FROM " +
                                    "GAR_VALUACIONES_REALES a, " +
                                    "CAT_ELEMENTO b, " +
                                    "CAT_ELEMENTO c, " +
                                    "(SELECT convert(varchar(10),MAX(f.fecha_valuacion),103) as fecha_valuacion_mas_reciente" +
                                     " FROM GAR_VALUACIONES_REALES f" +
                                     " WHERE f.cod_garantia_real = " + Request.QueryString["nGarantiaReal"].ToString() +
                                     ") d, " +
                                    "(SELECT isnull(convert(varchar(10),g.fecha_presentacion,111),'') as fecha_presentacion," +
                                    "        isnull(convert(varchar(10),g.fecha_constitucion,111),'') as fecha_constitucion" +
                                     " FROM GAR_GARANTIAS_REALES_X_OPERACION g" +
                                     " WHERE g.cod_garantia_real = " + Request.QueryString["nGarantiaReal"].ToString() +
                                     " AND g.cod_operacion = " + Request.QueryString["nOperacion"].ToString() +
                                     ") e " +
                                "WHERE " +
                                    "a.cod_garantia_real = " + Request.QueryString["nGarantiaReal"].ToString() +
                                    " and a.cod_recomendacion_perito *= b.cat_campo " +
                                    " and b.cat_catalogo = " + Application["CAT_RECOMENDACION_PERITO"].ToString() +
                                    " and a.cod_inspeccion_menor_tres_meses *= c.cat_campo " +
                                    " and c.cat_catalogo = " + Application["CAT_INSPECCION_3_MESES"].ToString() +
                                " ORDER BY " +
                                    " convert(varchar(10),a.fecha_valuacion,111) DESC";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                this.gdvValuacionesReales.DataSource = dsDatos.Tables["Datos"].DefaultView;
                this.gdvValuacionesReales.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
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
                lblMensaje.Text = "";

                if (bRespuesta && txtFechaValuacion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe seleccionar la fecha de Valuación.";
                    bRespuesta = false;
                }
                if (bRespuesta && cbPerito.SelectedValue.ToString() == "" && cbEmpresa.SelectedValue.ToString() == "")
                {
                    lblMensaje.Text = "Debe seleccionar el perito o la empresa.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) != int.Parse(Application["PRENDAS"].ToString()))
                {
                    if (txtMontoUltTasacionTerreno.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el monto de última tasación terreno.";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) != int.Parse(Application["PRENDAS"].ToString()))
                {
                    if (txtMontoTasActTerreno.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el monto tasación actualizada terreno.";
                        bRespuesta = false;
                    }
                }
                if (bRespuesta && txtFechaSeguimiento.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe seleccionar la fecha de último seguimiento.";
                    bRespuesta = false;
                }

                if (bRespuesta && int.Parse(cbTipoGarantiaReal.SelectedValue.ToString()) == int.Parse(Application["HIPOTECAS"].ToString()))
                {
                    ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

                    tipoBien = int.Parse(hdfTipoBien.Value);


                    if (tipoBien == 1)
                    {
                        if (bRespuesta && txtMontoUltTasacionNoTerreno.Text.Trim().Length > 0 && txtMontoUltTasacionNoTerreno.Text.Trim().CompareTo("0.00") != 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(1);
                        }
                        if (bRespuesta && txtMontoTasActNoTerreno.Text.Trim().Length > 0 && txtMontoTasActNoTerreno.Text.Trim().CompareTo("0.00") != 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(1);
                        }
                    }
                    else if ((tipoBien == 2) || (tipoBien == 3))
                    {
                        if (bRespuesta && txtMontoUltTasacionNoTerreno.Text.Trim().Length == 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(2);
                        }
                        if (bRespuesta && txtMontoTasActNoTerreno.Text.Trim().Length == 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(2);
                        }
                        if (bRespuesta && txtMontoUltTasacionNoTerreno.Text.Trim().Length > 0 && txtMontoUltTasacionNoTerreno.Text.Trim().CompareTo("0.00") == 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(2);
                        }
                        if (bRespuesta && txtMontoTasActNoTerreno.Text.Trim().Length > 0 && txtMontoTasActNoTerreno.Text.Trim().CompareTo("0.00") == 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(2);
                        }
                        if (bRespuesta && txtFechaConstruccion.Text.Trim().Length == 0)
                        {
                            bRespuesta = false;
                            MostrarMensaje = true;
                            ValidarTipoInconsistencia(2);
                        }
                        if ((bRespuesta && txtFechaConstruccion.Text.Trim().Length >= 0) && (tipoBien == 2))
                        {
                            DateTime fechaConstruccion = ((DateTime.TryParse(txtFechaConstruccion.Text.Trim(), out fechaConstruccion)) ? fechaConstruccion : DateTime.MinValue);

                            if (fechaConstruccion != DateTime.MinValue)
                            {
                                if (fechaConstruccion > FechaConstitucion)
                                {
                                    bRespuesta = false;
                                    MostrarMensaje = true;
                                    ValidarTipoInconsistencia(3);
                                }
                                else if (fechaConstruccion > FechaPresentacion)
                                {
                                    bRespuesta = false;
                                    MostrarMensaje = true;
                                    ValidarTipoInconsistencia(3);
                                }
                            }
                        }
                    }
                    else
                    {
                        if (bRespuesta && txtMontoUltTasacionNoTerreno.Text.Trim().Length == 0)
                        {
                            lblMensaje.Text = "Debe ingresar el monto de última tasación no terreno.";
                            bRespuesta = false;
                        }
                        if (bRespuesta && txtMontoTasActNoTerreno.Text.Trim().Length == 0)
                        {
                            lblMensaje.Text = "Debe ingresar el monto tasación actualizada no terreno.";
                            bRespuesta = false;
                        }
                    }
                }
                else
                {
                    if (bRespuesta && txtMontoUltTasacionNoTerreno.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el monto de última tasación no terreno.";
                        bRespuesta = false;
                    }
                    if (bRespuesta && txtMontoTasActNoTerreno.Text.Trim().Length == 0)
                    {
                        lblMensaje.Text = "Debe ingresar el monto tasación actualizada no terreno.";
                        bRespuesta = false;
                    }
                }

                if (!bRespuesta)
                    FormatearCamposNumericos();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return bRespuesta;
        }

        /// <summary>
        /// Valida que no existe una valuación para una fecha especifica
        /// </summary>
        /// <returns></returns>
        private bool ValidarFecha()
        {
            bool bRespuesta = true;

            try
            {

                DateTime dFecha = DateTime.Parse(txtFechaValuacion.Text.ToString());

                string strFecha = dFecha.ToString("yyyyMMdd");

                string strSQL = "SELECT " +
                                    "fecha_valuacion " +
                                "FROM " +
                                    "GAR_VALUACIONES_REALES " +
                                "WHERE " +
                                    "cod_garantia_real = " + Request.QueryString["nGarantiaReal"].ToString() +
                                    " AND fecha_valuacion = '" + strFecha + "'";


                //txtFechaValuacion.Text.ToString().Substring(6, 4).ToString() + "/" +
                //                            txtFechaValuacion.Text.ToString().Substring(0, 2).ToString() + "/" +
                //                            txtFechaValuacion.Text.ToString().Substring(3, 2).ToString() + "'";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if (dsDatos.Tables["Datos"] != null)
                    if (dsDatos.Tables["Datos"].Rows.Count > 0)
                        bRespuesta = false;

                if (!bRespuesta)
                    FormatearCamposNumericos();

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return bRespuesta;
        }

        private void ValidarTipoInconsistencia(int codigoInconsistencia)
        {
            if (MostrarMensaje)
            {
                ScriptManager requestSM = ScriptManager.GetCurrent(this.Page);

                MostrarMensaje = false;

                //DateTime avaluoSeleccionado;

                //avaluoSeleccionado = (((txtFechaValuacion.Text.Length > 0) && (DateTime.TryParse(txtFechaValuacion.Text, out avaluoSeleccionado))) ? avaluoSeleccionado : DateTime.MinValue);

                //if ((avaluoSeleccionado != DateTime.MinValue) && (avaluoSeleccionado == AvaluoMasReciente))
                //{

                if (codigoInconsistencia == 1)
                {
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesTerreno) !== 'undefined'){$MensajeValuacionesTerreno.dialog('open');} </script>",
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesTerreno) !== 'undefined'){$MensajeValuacionesTerreno.dialog('open');} </script>",
                                                               false);
                    }
                }

                if (codigoInconsistencia == 2)
                {
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerreno) !== 'undefined'){$MensajeValuacionesNoTerreno.dialog('open');} </script>",
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerreno) !== 'undefined'){$MensajeValuacionesNoTerreno.dialog('open');} </script>",
                                                               false);
                    }
                }

                if (codigoInconsistencia == 3)
                {
                    //Se obtiene el error de la lista de errores
                    if (requestSM != null && requestSM.IsInAsyncPostBack)
                    {
                        ScriptManager.RegisterClientScriptBlock(this,
                                                                typeof(Page),
                                                                Guid.NewGuid().ToString(),
                                                                "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerrenoFecha) !== 'undefined'){$MensajeValuacionesNoTerrenoFecha.dialog('open');} </script>",
                                                                false);
                    }
                    else
                    {
                        this.Page.ClientScript.RegisterClientScriptBlock(typeof(Page),
                                                               Guid.NewGuid().ToString(),
                                                               "<script type=\"text/javascript\" language=\"javascript\">if(typeof($MensajeValuacionesNoTerrenoFecha) !== 'undefined'){$MensajeValuacionesNoTerrenoFecha.dialog('open');} </script>",
                                                               false);
                    }
                }

                //}
            }
        }
        #endregion
    }
}
