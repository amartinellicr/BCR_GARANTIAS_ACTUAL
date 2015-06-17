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

namespace BCRGARANTIAS.Forms
{
    public partial class frmCapacidadPago : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;
        protected DropDownList cbGenerador;
        protected DropDownList cbVinculado;

        private string strDireccion = "DIRECTO";

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnRegresar.Click +=new EventHandler(btnRegresar_Click);
            btnValidarDeudor.Click +=new EventHandler(btnValidarDeudor_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la capacidad de pago del deudor seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la capacidad de pago del deudor seleccionado?')";

            txtSensibilidad.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtSensibilidad.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true, true)");

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CAPACIDAD_PAGO"].ToString())))
                    {
                        FormatearCamposNumericos();
                        lblCatalogo.Text = "Histórico de Capacidades de Pago";

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

                        CargarCombos();
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

        /// <summary>
        /// Este evento permite insertar calificaciones a los deudores
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            decimal nSensibilidad = 0;
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
                                                    Request.UserHostAddress.ToString());

                        if (strDireccion == "INDIRECTO")
                            Response.Redirect("frmMensaje.aspx?" +
                                            "bError=0" +
                                            "&strTitulo=" + "Inserción Exitosa" +
                                            "&strMensaje=" + "La capacidad de pago del deudor se insertó satisfactoriamente." +
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
                    else
                    {
                        lblMensaje.Text = "Ya existe una valuación para esta fecha. Por favor verifique.";
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
                                    "&strMensaje=" + "No se pudo insertar la capacidad de pago del deudor. Error:" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
                }
            }
        }

        /// <summary>
        /// Este evento permite limpiar los campos del formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
            CargarCombos();
            txtFechaValuacion.Text = "";
            txtSensibilidad.Text = "";
            btnInsertar.Enabled = true;
            btnModificar.Enabled = false;
            btnEliminar.Enabled = false;
            txtFechaValuacion.Enabled = true;
            lblMensaje.Text = "";
            txtFechaValuacion.Text = DateTime.Today.ToString();
            txtFechaValuacion.Enabled = false;
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
                                             Request.UserHostAddress.ToString());

                if (strDireccion == "INDIRECTO")
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La capacidad de pago del deudor se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
                else
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminación Exitosa" +
                                    "&strMensaje=" + "La capacidad de pago del deudor se eliminó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + txtCedula.Text +
                                                                    "|strNombre=" + txtNombre.Text);

            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar la capacidad de pago del deudor." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString());
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
                        "&strHref=frmCapacidadPago.aspx");
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

                            if (gdvCapacidadPago.SelectedDataKey[3].ToString() != null)
                                txtFechaValuacion.Text = gdvCapacidadPago.SelectedDataKey[3].ToString();

                            CargarCapacidades();
                            if (gdvCapacidadPago.SelectedDataKey[2].ToString() != null)
                                cbCapacidadPago.Items.FindByValue(gdvCapacidadPago.SelectedDataKey[2].ToString()).Selected = true;

                            if (gdvCapacidadPago.SelectedDataKey[5].ToString() != null)
                                txtSensibilidad.Text = gdvCapacidadPago.SelectedDataKey[5].ToString();

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
                                            "&strHref=frmCapacidadPago.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString());
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
            try
            {
                if (txtCedula.Text != string.Empty)
                {
                    string strSQL = "SELECT " +
                                        "b.cedula_deudor, " +
                                        "b.nombre_deudor, " +
                                        "convert(varchar(10),a.fecha_capacidad_pago,103) as fecha, " +
                                        "isnull(a.cod_capacidad_pago,-1) as cod_capacidad_pago, " +
                                        "isnull(c.cat_descripcion, '') as des_capacidad_pago, " +
                                        "a.sensibilidad_tipo_cambio " +
                                    "FROM " +
                                        "GAR_CAPACIDAD_PAGO a " +
                                        "RIGHT OUTER JOIN GAR_DEUDOR b " +
                                        "ON a.cedula_deudor = b.cedula_deudor " +
                                        "LEFT JOIN CAT_ELEMENTO c " +
                                        "ON isnull(a.cod_capacidad_pago,-1) = c.cat_campo " +
                                        "AND c.cat_catalogo = " + int.Parse(Application["CAT_TIPO_CAPACIDAD_PAGO"].ToString()) +
                                    " WHERE " +
                                        " b.cedula_deudor = '" + txtCedula.Text.Trim() + "'" +
                                    " ORDER BY " +
                                        "a.fecha_capacidad_pago DESC";

                    System.Data.DataSet dsDatos = new System.Data.DataSet();
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                    cmdConsulta.Fill(dsDatos, "Deudor");

                    if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Deudor"].Rows.Count > 0))
                    {
                        if (!dsDatos.Tables["Deudor"].Rows[0].IsNull("nombre_deudor"))
                        {
                            txtNombre.Text = dsDatos.Tables["Deudor"].Rows[0][1].ToString();
                        }

                        if ((!dsDatos.Tables["Deudor"].Rows[0].IsNull("fecha")) &&
                            (!dsDatos.Tables["Deudor"].Rows[0].IsNull("des_capacidad_pago")) &&
                            (!dsDatos.Tables["Deudor"].Rows[0].IsNull("sensibilidad_tipo_cambio")))
                        {
                            //this.gdvCapacidadPago.DataSource = null;
                            //this.gdvCapacidadPago.DataBind();
                            this.gdvCapacidadPago.DataSource = dsDatos.Tables["Deudor"].DefaultView;
                            this.gdvCapacidadPago.DataBind();
                        }
                        else
                        {
                            dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                            this.gdvCapacidadPago.DataSource = dsDatos;
                            this.gdvCapacidadPago.DataBind();

                            int TotalColumns = this.gdvCapacidadPago.Rows[0].Cells.Count;
                            this.gdvCapacidadPago.Rows[0].Cells.Clear();
                            this.gdvCapacidadPago.Rows[0].Cells.Add(new TableCell());
                            this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                            this.gdvCapacidadPago.Rows[0].Cells[0].Text = "No existen registros";
                        }
                    }
                    else
                    {
                        txtNombre.Text = string.Empty;
                        lblMensaje.Text = "El Deudor no existe";
                        dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                        this.gdvCapacidadPago.DataSource = dsDatos;
                        this.gdvCapacidadPago.DataBind();

                        int TotalColumns = this.gdvCapacidadPago.Rows[0].Cells.Count;
                        this.gdvCapacidadPago.Rows[0].Cells.Clear();
                        this.gdvCapacidadPago.Rows[0].Cells.Add(new TableCell());
                        this.gdvCapacidadPago.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvCapacidadPago.Rows[0].Cells[0].Text = "No existen registros";
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
            CargarCapacidades();
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
        #endregion

    }
}
