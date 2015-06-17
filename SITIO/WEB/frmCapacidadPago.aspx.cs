using System;
using System.Collections;
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
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Forms
{
    public partial class frmCapacidadPago : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;
        //protected DropDownList cbGenerador;
        protected DropDownList cbVinculado;

        private string strDireccion = "DIRECTO";

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnRegresar.Click += new EventHandler(btnRegresar_Click);
            btnValidarDeudor.Click += new EventHandler(btnValidarDeudor_Click);
            btnModificarDeudor.Click += new EventHandler(btnModificarDeudor_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la capacidad de pago del deudor seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la capacidad de pago del deudor seleccionado?')";

            txtSensibilidad.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtSensibilidad.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true, true)");

            btnModificarDeudor.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el deudor seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CAPACIDAD_PAGO"].ToString())))
                    {
                        FormatearCamposNumericos();
                        lblCatalogo.Text = "Histórico de Capacidades de Pago";

                        btnInsertar.Enabled = false;
                        btnLimpiar.Enabled = false;
                        btnModificarDeudor.Enabled = false;

                        if (Request.QueryString["strDireccion"] != null)
                        {
                            strDireccion = Request.QueryString["strDireccion"].ToString();
                            if (Request.QueryString["strCedula"] != null)
                                txtCedula.Text = Request.QueryString["strCedula"].ToString();
                        }
                        else
                        {
                            txtCedula.Enabled = true;

                            if (Request.QueryString["strCedula"] != null)
                                txtCedula.Text = Request.QueryString["strCedula"].ToString();

                            btnValidarDeudor.Visible = true;
                            btnRegresar.Visible = false;
                            strDireccion = "DIRECTO";
                        }

                        if (Request.QueryString["strNombre"] != null)
                            txtNombre.Text = Request.QueryString["strNombre"].ToString();

                        txtFechaValuacion.Text = DateTime.Today.ToString();

                        if (Request.QueryString["indSoloDeudor"] != null)
                        {
                            CargarCombos();
                            if (ValidarDatosLlave())
                            {
                                CargarGrid();
                            }

                            btnInsertar.Enabled = true;
                            btnLimpiar.Enabled = true;
                            btnModificarDeudor.Enabled = true;
                        }
                        else
                        {
                            CargarCombos();
                            CargarGrid();
                        }

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

        /// <summary>
        /// Este evento permite insertar calificaciones a los deudores
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            decimal nSensibilidad = 0;
            StringBuilder strUrlAccion = new StringBuilder();

            try
            {
                if (ValidarDatos())
                {
                    if (ValidarFecha())
                    {
                        if (txtSensibilidad.Text.Trim().Length > 0)
                            nSensibilidad = Convert.ToDecimal(txtSensibilidad.Text);

                        Gestor.CrearCapacidadPago(txtCedula.Text, txtFechaValuacion.Text.ToString(),
                                                    int.Parse(cbCapacidadPago.SelectedValue.ToString()),
                                                    nSensibilidad,
                                                    Session["strUSER"].ToString(),
                                                    Request.UserHostAddress.ToString(),
                                                    int.Parse(txtTipoRegistroDeudor.Text));

                        if (strDireccion == "INDIRECTO")
                        {
                            strUrlAccion.Append("frmMensaje.aspx?");
                            strUrlAccion.Append("bError=0");
                            strUrlAccion.Append("&strTitulo=Inserción Exitosa");
                            strUrlAccion.Append("&strMensaje=La inserción de los datos de la capacidad de pago fue realizada con éxito.");
                            strUrlAccion.Append("&bBotonVisible=1");
                            strUrlAccion.Append("&strTextoBoton=Regresar");
                            strUrlAccion.Append("&strHref=frmCapacidadPago.aspx?strCedula=");
                            strUrlAccion.Append(txtCedula.Text.Trim());
                            strUrlAccion.Append("|strNombre=");
                            strUrlAccion.Append(txtNombre.Text);
                            strUrlAccion.Append(((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty));
                            strUrlAccion.Append("|indSoloDeudor=1");

                            //Response.Redirect("frmMensaje.aspx?" +
                            //                "bError=0" +
                            //                "&strTitulo=" + "Inserción Exitosa" +
                            //                "&strMensaje=" + "La inserción de los datos de la capacidad de pago fue realizada con éxito." +
                            //                "&bBotonVisible=1" +
                            //                "&strTextoBoton=Regresar" +
                            //                "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                            //                                              "|strNombre=" + txtNombre.Text +
                            //                                              ((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty) +
                            //                                              "|indSoloDeudor=1");
                        }
                        else
                        {
                            strUrlAccion.Append("frmMensaje.aspx?");
                            strUrlAccion.Append("bError=0");
                            strUrlAccion.Append("&strTitulo=Inserción Exitosa");
                            strUrlAccion.Append("&strMensaje=La inserción de los datos de la capacidad de pago fue realizada con éxito.");
                            strUrlAccion.Append("&bBotonVisible=1");
                            strUrlAccion.Append("&strTextoBoton=Regresar");
                            strUrlAccion.Append("&strHref=frmCapacidadPago.aspx?strCedula=");
                            strUrlAccion.Append(txtCedula.Text.Trim());
                            strUrlAccion.Append("|strNombre=");
                            strUrlAccion.Append(txtNombre.Text);
                            strUrlAccion.Append("|indSoloDeudor=1");

                            //Response.Redirect(("frmMensaje.aspx?" +
                            //                "bError=0" +
                            //                "&strTitulo=" + "Inserción Exitosa" +
                            //                "&strMensaje=" + "La inserción de los datos de la capacidad de pago fue realizada con éxito." +
                            //                "&bBotonVisible=1" +
                            //                "&strTextoBoton=Regresar" +
                            //                "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                            //                                              "|strNombre=" + txtNombre.Text +
                            //                                              "|indSoloDeudor=1"));
                        }
                    }
                    else
                    {
                        lblMensaje.Text = "Ya existe una valuación para esta fecha. Por favor verifique.";
                    }
                }
                else
                {
                    CargarGrid();
                }
            }
            catch (Exception ex)
            {
                Utilitarios.RegistraEventLog(("Se presentó un error al insertar los datos de la capacidad de pago. Detalle:" + ex.Message), EventLogEntryType.Error);

                strUrlAccion.Append("frmMensaje.aspx?");
                strUrlAccion.Append("bError=1");
                strUrlAccion.Append("&strTitulo=Problemas Insertando Registro");
                strUrlAccion.Append("&strMensaje=Se presentó un error al insertar los datos de la capacidad de pago.");
                strUrlAccion.Append("&bBotonVisible=1");
                strUrlAccion.Append("&strTextoBoton=Regresar");
                strUrlAccion.Append("&strHref=frmCapacidadPago.aspx?strCedula=");
                strUrlAccion.Append(txtCedula.Text.Trim());
                strUrlAccion.Append("|strNombre=");
                strUrlAccion.Append(txtNombre.Text);
                strUrlAccion.Append(((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty));
                strUrlAccion.Append("|indSoloDeudor=1");

                //Response.Redirect("frmMensaje.aspx?" +
                //                "bError=1" +
                //                "&strTitulo=" + "Problemas Insertando Registro" +
                //                "&strMensaje=" + "Se presentó un error al insertar los datos de la capacidad de pago." +
                //                "&bBotonVisible=1" +
                //                "&strTextoBoton=Regresar" +
                //                "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                //                                              "|strNombre=" + txtNombre.Text +
                //                                              ((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty) +
                //                                              "|indSoloDeudor=1");
            }

            if (strUrlAccion.Length > 0)
            {
                Response.Redirect(strUrlAccion.ToString());
            }
        }

        /// <summary>
        /// Este evento permite limpiar los campos del formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            Limpiar_Campos(true);
        }

        /// <summary>
        /// Este evento permite regresar al formulario anterior
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmDeudores.aspx?strDeudor=" + txtCedula.Text.Trim() +
                                             "&nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
        }

        /// <summary>
        /// Este evento permite modificar la información de la calificación
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            decimal nSensibilidad = 0;
            try
            {
                if (ValidarDatos())
                {
                    if (txtSensibilidad.Text.Trim().Length > 0)
                        nSensibilidad = Convert.ToDecimal(txtSensibilidad.Text); //txtSensibilidad.Text.Replace(".", ""));

                    Gestor.ModificarCapacidadPago(txtCedula.Text, DateTime.Parse(txtFechaValuacion.Text.ToString()),
                                                int.Parse(cbCapacidadPago.SelectedValue.ToString()),
                                                nSensibilidad,
                                                Session["strUSER"].ToString(),
                                                Request.UserHostAddress.ToString());

                    if (strDireccion == "INDIRECTO")
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Modificación Exitosa" +
                                        "&strMensaje=" + "La capacidad de pago del deudor se modificó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                        "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                        "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserción Exitosa" +
                                        "&strMensaje=" + "La capacidad de pago del deudor se insertó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text +
                                        "|strNombre=" + txtNombre.Text);
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la información de la capacidad de pago del deudor." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarCapacidadPago(txtCedula.Text, txtFechaValuacion.Text.ToString(),
                                             Session["strUSER"].ToString(),
                                             Request.UserHostAddress.ToString(),
                                             int.Parse(txtTipoRegistroDeudor.Text));

                if (strDireccion == "INDIRECTO")
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La capacidad de pago del deudor se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                                                                    "|strNombre=" + txtNombre.Text +
                                                                    ((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty) +
                                                                    "|indSoloDeudor=1");
                else
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La capacidad de pago del deudor se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                                                                    "|strNombre=" + txtNombre.Text +
                                                                    "|indSoloDeudor=1");

            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "Se presentó un error al eliminar los datos de la capacidad de pago." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                                                                    "|strNombre=" + txtNombre.Text +
                                                                    ((Request.QueryString["nTipoGarantia"] != null) ? ("|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString()) : string.Empty) +
                                                                    "|indSoloDeudor=1");
                }
            }
        }

        private void btnValidarDeudor_Click(object sender, System.EventArgs e)
        {
            try
            {
                FormatearCamposNumericos();
                if (ValidarDatosLlave())
                {
                    CargarGrid();

                    if (lblMensaje.Text.Length == 0)
                    {
                        btnInsertar.Enabled = true;
                        btnLimpiar.Enabled = true;
                        btnModificarDeudor.Enabled = true;
                    }
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Validando Deudor" +
                        "&strMensaje=" + "No se pudo validar el deudor." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text);
                }
            }
        }

        private void btnModificarDeudor_Click(object sender, System.EventArgs e)
        {
            int nTipoGarantia = 0;

            try
            {
                if (ValidarDatosDeudor())
                {
                    Gestor.ModificarDeudor(int.Parse(cbTipo.SelectedValue.ToString()),
                                            txtCedula.Text.Trim(),
                                            txtNombre.Text.Trim(),
                                            int.Parse(cbCondicion.SelectedValue.ToString()),
                                            int.Parse(cbTipoAsignacion.SelectedValue.ToString()),
                                            int.Parse(cbGenerador.SelectedValue.ToString()),
                                            int.Parse(cbVinculadoEntidad.SelectedValue.ToString()),
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString(),
                                            int.Parse(txtTipoRegistroDeudor.Text));

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "La actualización de los datos del deudor/codeudor fue realizada con éxito." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text +
                                    "|indSoloDeudor=1");
                }
                else
                {
                    CargarGrid();
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Utilitarios.RegistraEventLog(("Se presentó un error al actualizar los datos del deudor/codeudor. Detalle:" + ex.Message), EventLogEntryType.Error);
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "Se presentó un error al actualizar los datos del deudor/codeudor." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text +
                                    "|indSoloDeudor=1");
                }
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvCapacidadPago_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvCapacidadPago = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedCapacidadPago"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvCapacidadPago.SelectedIndex = rowIndex;

                        FormatearCamposNumericos();

                        try
                        {

                            FormatearCamposNumericos();

                            if (gdvCapacidadPago.SelectedDataKey[1].ToString() != null)
                                txtFechaValuacion.Text = gdvCapacidadPago.SelectedDataKey[1].ToString();

                            CargarCapacidades();
                            if (gdvCapacidadPago.SelectedDataKey[0].ToString() != null)
                                cbCapacidadPago.Items.FindByValue(gdvCapacidadPago.SelectedDataKey[0].ToString()).Selected = true;

                            if (gdvCapacidadPago.SelectedDataKey[3].ToString() != null)
                                txtSensibilidad.Text = gdvCapacidadPago.SelectedDataKey[3].ToString();

                            txtFechaValuacion.Enabled = false;
                            btnInsertar.Enabled = false;
                            btnModificar.Enabled = true;
                            btnEliminar.Enabled = true;
                            lblMensaje.Text = "";

                        }
                        catch (Exception ex)
                        {
                            Response.Redirect("frmMensaje.aspx?" +
                                            "bError=1" +
                                            "&strTitulo=" + "Problemas Cargando Página" +
                                            "&strMensaje=" + "Se presentaron problemas al cargar la página. Error:" + ex.Message +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                            "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                            "|indSoloDeudor=1");
                        }


                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        protected void gdvCapacidadPago_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvCapacidadPago.SelectedIndex = -1;
            this.gdvCapacidadPago.PageIndex = e.NewPageIndex;

            CargarGrid();
        }

        #endregion

        #region Métodos Privados

        private void FormatearCamposNumericos()
        {
            System.Globalization.NumberFormatInfo a = new System.Globalization.NumberFormatInfo();
            a.NumberDecimalSeparator = ".";

            //txtSensibilidad.Text = Decimal.Parse(txtSensibilidad.Text, a).ToString();
        }

        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            DataSet dsDatos = new DataSet();

            try
            {
                if (txtCedula.Text.Trim().Length > 0)
                {
                    clsDeudor entidadDeudor = Gestor.ObtenerDatosDeudor(txtCedula.Text.Trim(), int.Parse(Application["CAT_TIPO_CAPACIDAD_PAGO"].ToString()));

                    if (entidadDeudor.ConsultaExitosa)
                    {
                        CargarComboTipos();
                        cbTipo.Items.FindByValue(entidadDeudor.TipoDeudor.ToString()).Selected = true;
                        txtNombre.Text = entidadDeudor.NombreDeudor;
                        CargarComboCondiciones();

                        cbCondicion.Items.FindByValue(((cbCondicion.Items.FindByValue(entidadDeudor.CondicionEspecial.ToString()) != null) ? entidadDeudor.CondicionEspecial.ToString() : "-1")).Selected = true;
                        CargarTiposAsignacion();
                        cbTipoAsignacion.Items.FindByValue(((cbTipoAsignacion.Items.FindByValue(entidadDeudor.TipoAsignacion.ToString()) != null) ? entidadDeudor.TipoAsignacion.ToString() : "-1")).Selected = true;
                        CargarGenerador();
                        cbGenerador.Items.FindByValue(((cbGenerador.Items.FindByValue(entidadDeudor.GeneradorDivisas.ToString()) != null) ? entidadDeudor.GeneradorDivisas.ToString() : "-1")).Selected = true;
                        CargarVinculado();
                        cbVinculadoEntidad.Items.FindByValue(((cbVinculadoEntidad.Items.FindByValue(entidadDeudor.VinculadoEntidad.ToString()) != null) ? entidadDeudor.VinculadoEntidad.ToString() : "-1")).Selected = true;

                        txtTipoRegistroDeudor.Text = entidadDeudor.TipoRegistro.ToString();
                        txtDescripcionTipoRegistroDeudor.Text = entidadDeudor.DescripcionTipoRegistro;

                        cbTipoRegistroDeudor.ClearSelection();

                        cbTipoRegistroDeudor.Items.FindByValue(((cbTipoRegistroDeudor.Items.FindByValue(entidadDeudor.TipoRegistro.ToString()) != null) ? entidadDeudor.TipoRegistro.ToString() : "-1")).Selected = true;

                        dsDatos = entidadDeudor.ListaCapacidadesPago.toDataSet();

                        if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Deudor"].Rows.Count > 0))
                        {
                            if ((!dsDatos.Tables["Deudor"].Rows[0].IsNull("fecha_capacidad_pago")) &&
                                (!dsDatos.Tables["Deudor"].Rows[0].IsNull("des_capacidad_pago")) &&
                                (!dsDatos.Tables["Deudor"].Rows[0].IsNull("sensibilidad_tipo_cambio")))
                            {
                                this.gdvCapacidadPago.DataSource = dsDatos.Tables["Deudor"].DefaultView;
                                this.gdvCapacidadPago.DataBind();
                            }
                            else
                            {
                                SetearGrid();
                            }
                        }
                        else
                        {
                            //txtNombre.Text = string.Empty;
                            //lblMensaje.Text = "El Deudor no existe";
                            SetearGrid();
                        }

                        #region Obsoleto

                        //string strSQL = "SELECT " +
                        //                    "b.cedula_deudor, " +
                        //                    "b.nombre_deudor, " +
                        //                    "convert(varchar(10),a.fecha_capacidad_pago,103) as fecha, " +
                        //                    "isnull(a.cod_capacidad_pago,-1) as cod_capacidad_pago, " +
                        //                    "isnull(c.cat_descripcion, '') as des_capacidad_pago, " +
                        //                    "a.sensibilidad_tipo_cambio " +
                        //                "FROM " +
                        //                    "GAR_CAPACIDAD_PAGO a " +
                        //                    "RIGHT OUTER JOIN GAR_DEUDOR b " +
                        //                    "ON a.cedula_deudor = b.cedula_deudor " +
                        //                    "LEFT JOIN CAT_ELEMENTO c " +
                        //                    "ON isnull(a.cod_capacidad_pago,-1) = c.cat_campo " +
                        //                    "AND c.cat_catalogo = " + int.Parse(Application["CAT_TIPO_CAPACIDAD_PAGO"].ToString()) +
                        //                " WHERE " +
                        //                    " b.cedula_deudor = '" + txtCedula.Text.Trim() + "'" +
                        //                " ORDER BY " +
                        //                    "a.fecha_capacidad_pago DESC";

                        //System.Data.DataSet dsDatos = new System.Data.DataSet();
                        //oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                        //OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                        //cmdConsulta.Fill(dsDatos, "Deudor");


                        //if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Deudor"].Rows.Count > 0))
                        //{
                        //    if (!dsDatos.Tables["Deudor"].Rows[0].IsNull("nombre_deudor"))
                        //    {
                        //        txtNombre.Text = dsDatos.Tables["Deudor"].Rows[0][1].ToString();
                        //    }

                        //    if ((!dsDatos.Tables["Deudor"].Rows[0].IsNull("fecha")) &&
                        //        (!dsDatos.Tables["Deudor"].Rows[0].IsNull("des_capacidad_pago")) &&
                        //        (!dsDatos.Tables["Deudor"].Rows[0].IsNull("sensibilidad_tipo_cambio")))
                        //    {
                        //        //this.gdvCapacidadPago.DataSource = null;
                        //        //this.gdvCapacidadPago.DataBind();
                        //        this.gdvCapacidadPago.DataSource = dsDatos.Tables["Deudor"].DefaultView;
                        //        this.gdvCapacidadPago.DataBind();
                        //    }
                        //    else
                        //    {
                        //        dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                        //        this.gdvCapacidadPago.DataSource = dsDatos;
                        //        this.gdvCapacidadPago.DataBind();

                        //        int TotalColumns = this.gdvCapacidadPago.Rows[0].Cells.Count;
                        //        this.gdvCapacidadPago.Rows[0].Cells.Clear();
                        //        this.gdvCapacidadPago.Rows[0].Cells.Add(new TableCell());
                        //        this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        //        this.gdvCapacidadPago.Rows[0].Cells[0].Text = "No existen registros";
                        //    }
                        //}
                        //else
                        //{
                        //    txtNombre.Text = string.Empty;
                        //    lblMensaje.Text = "El Deudor no existe";
                        //    dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                        //    this.gdvCapacidadPago.DataSource = dsDatos;
                        //    this.gdvCapacidadPago.DataBind();

                        //    int TotalColumns = this.gdvCapacidadPago.Rows[0].Cells.Count;
                        //    this.gdvCapacidadPago.Rows[0].Cells.Clear();
                        //    this.gdvCapacidadPago.Rows[0].Cells.Add(new TableCell());
                        //    this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        //    this.gdvCapacidadPago.Rows[0].Cells[0].Text = "No existen registros";
                        //}
                        #endregion Obsoleto
                    }
                    else
                    {
                        lblMensaje.Text = entidadDeudor.descErrorObtenido;
                        btnInsertar.Enabled = false;
                        btnLimpiar.Enabled = false;
                        btnModificarDeudor.Enabled = false;

                        return;
                    }

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
                Limpiar_Campos(false);

                btnInsertar.Enabled = false;
                btnLimpiar.Enabled = false;
                btnModificarDeudor.Enabled = false;
            }
        }

        private void CargarCombos()
        {
            CargarCapacidades();
            CargarComboCondiciones();
            CargarComboTipos();
            CargarTiposAsignacion();
            CargarGenerador();
            CargarVinculado();
        }

        private void CargarCapacidades()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_CAPACIDAD_PAGO"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbCapacidadPago.DataSource = null;
            cbCapacidadPago.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbCapacidadPago.DataValueField = "CAT_CAMPO";
            cbCapacidadPago.DataTextField = "CAT_DESCRIPCION";
            cbCapacidadPago.DataBind();
        }

        private void CargarTiposAsignacion()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_ASIGNACION"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbTipoAsignacion.DataSource = null;
            cbTipoAsignacion.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbTipoAsignacion.DataValueField = "CAT_CAMPO";
            cbTipoAsignacion.DataTextField = "CAT_DESCRIPCION";
            cbTipoAsignacion.DataBind();
            //cbTipoAsignacion.Items.FindByValue("2").Selected = true;
        }

        private void CargarComboCondiciones()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_CONDICION_ESPECIAL"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Condiciones");
            cbCondicion.DataSource = null;
            cbCondicion.DataSource = dsDatos.Tables["Condiciones"].DefaultView;
            cbCondicion.DataValueField = "CAT_CAMPO";
            cbCondicion.DataTextField = "CAT_DESCRIPCION";
            cbCondicion.DataBind();
        }

        private void CargarComboTipos()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_PERSONA"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbTipo.DataSource = null;
            cbTipo.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbTipo.DataValueField = "CAT_CAMPO";
            cbTipo.DataTextField = "CAT_DESCRIPCION";
            cbTipo.DataBind();
        }

        private void CargarDatos()
        {
            //try
            //{
            //    string strSQL;

            //    strSQL = "SELECT " +
            //                "cedula_deudor, " +
            //                "nombre_deudor, " +
            //                "isnull(cod_tipo_deudor,-1) as cod_tipo_deudor, " +
            //                "isnull(cod_condicion_especial,-1) as cod_condicion_especial, " +
            //                "isnull(cod_tipo_asignacion,2) as cod_tipo_asignacion, " +
            //                "isnull(cod_generador_divisas,-1) as cod_generador_divisas, " +
            //                "isnull(cod_vinculado_entidad,2) as cod_vinculado_entidad " +
            //            "FROM " +
            //                "gar_deudor " +
            //            "WHERE " +
            //                "cedula_deudor = '" + Session["Deudor"].ToString() + "'";

            //    System.Data.DataSet dsDatos = new System.Data.DataSet();
            //    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            //    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
            //    cmdConsulta.Fill(dsDatos, "Deudor");
            //    CargarComboTipos();
            //    cbTipo.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][2].ToString()).Selected = true;
            //    txtNombre.Text = dsDatos.Tables["Deudor"].Rows[0][1].ToString();
            //    CargarComboCondiciones();
            //    cbCondicion.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][3].ToString()).Selected = true;
            //    CargarTiposAsignacion();
            //    cbTipoAsignacion.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][4].ToString()).Selected = true;
            //    CargarGenerador();
            //    cbGenerador.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][5].ToString()).Selected = true;
            //    CargarVinculado();
            //    cbVinculadoEntidad.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][6].ToString()).Selected = true;
            //}
            //catch (Exception ex)
            //{
            //    lblMensaje.Text = ex.Message;
            //}
        }

        private void CargarVinculado()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_VINCULADO_ENTIDAD"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbVinculadoEntidad.DataSource = null;
            cbVinculadoEntidad.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbVinculadoEntidad.DataValueField = "CAT_CAMPO";
            cbVinculadoEntidad.DataTextField = "CAT_DESCRIPCION";
            cbVinculadoEntidad.DataBind();
        }

        private void CargarGenerador()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_GENERADOR"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbGenerador.DataSource = null;
            cbGenerador.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbGenerador.DataValueField = "CAT_CAMPO";
            cbGenerador.DataTextField = "CAT_DESCRIPCION";
            cbGenerador.DataBind();
        }

        /// <summary>
        /// Metodo de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatosDeudor()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";
                if (bRespuesta && int.Parse(cbTipo.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el tipo de persona del deudor.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtCedula.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la cédula del deudor.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtNombre.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el nombre del deudor.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbGenerador.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el indicador de generador de divisas.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbVinculadoEntidad.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el indicador de vinculado a entidad.";
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
        /// Metodo de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            lblMensaje.Text = "";
            if (txtFechaValuacion.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar la fecha de valuación.";
                return false;
            }

            if (cbCapacidadPago.SelectedItem.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar el nivel de la capacidad de pago.";
                return false;
            }

            if (txtSensibilidad.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe brindar el porcentaje de sensibilidad al tipo de cambio.";
                return false;
            }
            return true;
        }

        private bool ValidarDatosLlave()
        {
            lblMensaje.Text = "";
            if (txtCedula.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar la cédula del deudor.";
                return false;
            }
            return true;
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
                                    "fecha_capacidad_pago " +
                                "FROM " +
                                    "GAR_CAPACIDAD_PAGO " +
                                "WHERE " +
                                    "cedula_deudor = '" + txtCedula.Text.Trim() + "' " +
                                     "and fecha_capacidad_pago = '" + strFecha + "'";

                //"and fecha_capacidad_pago = '" + txtFechaValuacion.Text.ToString().Substring(6, 4).ToString() + "/" +
                //                                txtFechaValuacion.Text.ToString().Substring(0, 2).ToString() + "/" +
                //                                txtFechaValuacion.Text.ToString().Substring(3, 2).ToString() + "'";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if (dsDatos.Tables["Datos"] != null)
                    if (dsDatos.Tables["Datos"].Rows.Count > 0)
                        bRespuesta = false;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return bRespuesta;
        }

        /// <summary>
        /// Se encarga de limpiar todos los campos del a página
        /// </summary>
        private void Limpiar_Campos(bool boton)
        {
            FormatearCamposNumericos();
            txtFechaValuacion.Text = "";
            txtSensibilidad.Text = "";
            btnInsertar.Enabled = true;
            btnModificar.Enabled = false;
            btnEliminar.Enabled = false;
            txtFechaValuacion.Enabled = true;
            txtFechaValuacion.Text = DateTime.Today.ToString();
            txtFechaValuacion.Enabled = false;

            if (boton)
            {
                lblMensaje.Text = string.Empty;
                cbTipoRegistroDeudor.ClearSelection();

                if (this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan == this.gdvCapacidadPago.Rows[0].Cells.Count)
                {
                    SetearGrid();
                }
            }
            else
            {
                CargarCombos();
                cbTipoRegistroDeudor.ClearSelection();
                txtNombre.Text = string.Empty;

                SetearGrid();
            }
        }

        /// <summary>
        /// Setea el grid en el que se presnetan las capacidades de pago
        /// </summary>
        private void SetearGrid()
        {
            DataSet dsDatos = new clsCapacidadesPago<clsCapacidadPago>().toDataSet();

            dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
            this.gdvCapacidadPago.DataSource = dsDatos;
            this.gdvCapacidadPago.DataBind();

            int TotalColumns = this.gdvCapacidadPago.Rows[0].Cells.Count;
            this.gdvCapacidadPago.Rows[0].Cells.Clear();
            this.gdvCapacidadPago.Rows[0].Cells.Add(new TableCell());
            this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan = TotalColumns;
            this.gdvCapacidadPago.Rows[0].Cells[0].Text = "No existen registros";
        }
        #endregion

    }
}
