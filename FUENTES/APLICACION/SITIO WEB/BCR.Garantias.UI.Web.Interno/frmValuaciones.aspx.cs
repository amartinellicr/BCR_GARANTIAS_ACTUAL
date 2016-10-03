using System;
using System.Web.UI.WebControls;
using System.Data;

using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Forms
{
    public partial class frmValuaciones : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected Label lblUsrConectado;
        protected Label lblFecha;

        private bool seRedirecciona = false;

        private string urlPaginaMensaje = string.Empty;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnRegresar.Click +=new EventHandler(btnRegresar_Click);           
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea eliminar la valuaci�n del fiador seleccionado?')";
            
            txtSalario.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtSalario.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");


            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_VALUACION_FIADOR"].ToString())))
                    {
                        FormatearCamposNumericos();
                        lblCatalogo.Text = "Hist�rico de Ingresos";

                        txtCedula.Text = Request.QueryString["strCedula"].ToString();
                        txtNombre.Text = Request.QueryString["strNombre"].ToString();
 
                        if ((txtCedula.Text != string.Empty) && (txtNombre.Text != string.Empty))
                        {
                            CargarGrid();
                        }

                       btnEliminar.Enabled = false;
                    }
                    else
                    {
                        //El usuario no tiene acceso a esta p�gina
                        throw new Exception("ACCESO DENEGADO");
                    }
                }
                catch (Exception ex)
                {
                    seRedirecciona = true;

                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                    {
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=1" +
                                            "&strTitulo=" + "Acceso Denegado" +
                                            "&strMensaje=" + "El usuario no posee permisos de acceso a esta p�gina." +
                                            "&bBotonVisible=0");
                    }
                    else
                    {
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=1" +
                                            "&strTitulo=" + "Problemas Cargando P�gina" +
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

        /// <summary>
        /// Este evento permite insertar calificaciones a los deudores
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
                        Gestor.CrearValuacionFiador(int.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                    txtFechaActualizacion.Text.ToString(),
                                                     Convert.ToDecimal(txtSalario.Text),
                                                    -1,
                                                    Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                        seRedirecciona = true;
                        urlPaginaMensaje = ("frmMensaje.aspx?" +
                                            "bError=0" +
                                            "&strTitulo=" + "Inserci�n Exitosa" +
                                            "&strMensaje=" + "La valuaci�n del fiador se insert� satisfactoriamente." +
                                            "&bBotonVisible=1" +
                                            "&strTextoBoton=Regresar" +
                                            "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                        "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                        "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                    }
                    else
                    {
                        lblMensaje.Text = "Ya existe una valuaci�n para esta fecha. Por favor verifique.";
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
                                        "&strMensaje=" + "No se pudo insertar la valuaci�n del fiador. Error:" + ex.Message +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                        "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                        "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmGarantiasFiduciaria.aspx");
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
                txtFechaActualizacion.Text = "";
                txtSalario.Text = "";
                btnInsertar.Enabled = true;
                btnEliminar.Enabled = false;
                txtFechaActualizacion.Enabled = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
 
        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarValuacionFiador(int.Parse(Request.QueryString["nGarantiaFiduciaria"].ToString()),
                                                txtFechaActualizacion.Text.ToString(),
                                                Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                seRedirecciona = true;

                urlPaginaMensaje = ("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Eliminaci�n Exitosa" +
                                    "&strMensaje=" + "La valuaci�n del fiador se elimin� satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    seRedirecciona = true;
                    urlPaginaMensaje = ("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Eliminando Registro" +
                                        "&strMensaje=" + "No se pudo eliminar la valuaci�n del fiador." + "\r" +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }

            if (seRedirecciona)
            {
                Response.Redirect(urlPaginaMensaje, true);
            }
        }

        #endregion

        #region M�todos GridView

        protected void gdvValuacionesFiador_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvValuacionesFiador = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedValuacionFiador"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvValuacionesFiador.SelectedIndex = rowIndex;

                        try
                        {
                            
                            FormatearCamposNumericos();

                            if (gdvValuacionesFiador.SelectedDataKey[0].ToString() != null)
                                txtFechaActualizacion.Text = gdvValuacionesFiador.SelectedDataKey[0].ToString();

                            if (gdvValuacionesFiador.SelectedDataKey[1].ToString() != null)
                            {
                                decimal nSalario = Convert.ToDecimal(gdvValuacionesFiador.SelectedDataKey[1].ToString());

                                txtSalario.Text = nSalario.ToString("N");
                            }
                            else
                            {
                                txtSalario.Text = "0.00";
                            }

                            txtFechaActualizacion.Enabled = false;
                            btnInsertar.Enabled = false;
                            btnEliminar.Enabled = true;

                        }
                        catch (Exception ex)
                        {
                            lblMensaje.Text = ex.Message;
                        }


                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
        
        protected void gdvValuacionesFiador_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvValuacionesFiador.SelectedIndex = -1;
            this.gdvValuacionesFiador.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        #endregion

        #region M�todos Privados

        private void FormatearCamposNumericos()
        {
            System.Globalization.NumberFormatInfo a = new System.Globalization.NumberFormatInfo();
            a.NumberDecimalSeparator = ".";
            //txtSalario.Text = txtSalario.Text.ToString(a);
        }

        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            try
            {
                int consecutivoGarantia = ((int.TryParse(Request.QueryString["nGarantiaFiduciaria"].ToString(), out consecutivoGarantia)) ? consecutivoGarantia : -1);

                DataSet dsDatos = Gestor.ObtenerValuacionesFiador(consecutivoGarantia);

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables[0].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables[0].Rows[0].IsNull("fecha_valuacion")) &&
                        (!dsDatos.Tables[0].Rows[0].IsNull("ingreso_neto"))) 
                    {
                        this.gdvValuacionesFiador.DataSource = dsDatos.Tables[0].DefaultView;
                        this.gdvValuacionesFiador.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables[0].Rows.Add(dsDatos.Tables[0].NewRow());
                        this.gdvValuacionesFiador.DataSource = dsDatos;
                        this.gdvValuacionesFiador.DataBind();

                        int TotalColumns = this.gdvValuacionesFiador.Rows[0].Cells.Count;
                        this.gdvValuacionesFiador.Rows[0].Cells.Clear();
                        this.gdvValuacionesFiador.Rows[0].Cells.Add(new TableCell());
                        this.gdvValuacionesFiador.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvValuacionesFiador.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables[0].Rows.Add(dsDatos.Tables[0].NewRow());
                    this.gdvValuacionesFiador.DataSource = dsDatos;
                    this.gdvValuacionesFiador.DataBind();

                    int TotalColumns = this.gdvValuacionesFiador.Rows[0].Cells.Count;
                    this.gdvValuacionesFiador.Rows[0].Cells.Clear();
                    this.gdvValuacionesFiador.Rows[0].Cells.Add(new TableCell());
                    this.gdvValuacionesFiador.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvValuacionesFiador.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
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
                if (bRespuesta && txtFechaActualizacion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe seleccionar la fecha de Valuaci�n.";
                    bRespuesta = false;
                }
                if (bRespuesta && DateTime.Parse(txtFechaActualizacion.Text.ToString()) > DateTime.Today)
                {
                    lblMensaje.Text = "La fecha de valuaci�n no puede ser mayor a la fecha actual.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtSalario.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el salario neto del fiador.";
                    bRespuesta = false;
                }
                //if (bRespuesta && int.Parse(cbCapacidad.SelectedValue) == -1)
                //{
                //    lblMensaje.Text = "Debe indicar si tiene capacidad de pago.";
                //    bRespuesta = false;
                //}
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
        /// Valida que no existe una valuaci�n para una fecha especifica
        /// </summary>
        /// <returns></returns>
        private bool ValidarFecha()
        {
            bool bRespuesta = true;
            try
            {
                int consecutivoGarantia = ((int.TryParse(Request.QueryString["nGarantiaFiduciaria"].ToString(), out consecutivoGarantia)) ? consecutivoGarantia : -1);
                DateTime fechaValuacion = ((DateTime.TryParse(txtFechaActualizacion.Text, out fechaValuacion)) ? fechaValuacion : DateTime.MinValue);

                if((consecutivoGarantia != -1) && (fechaValuacion != DateTime.MinValue))
                {
                    bRespuesta = !Gestor.ExisteFecha(consecutivoGarantia, fechaValuacion.ToString("yyyyMMdd"));
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
        #endregion
    }
}
