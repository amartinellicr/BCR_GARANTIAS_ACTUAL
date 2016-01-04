using System;
using System.Web.UI.WebControls;
using System.Data.OleDb;
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Forms
{
    public partial class frmValuaciones : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnRegresar.Click +=new EventHandler(btnRegresar_Click);
            Button2.Click +=new EventHandler(Button2_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la valuación del fiador seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la valuación del fiador seleccionado?')";

            txtSalario.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
            txtSalario.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");


            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_VALUACION_FIADOR"].ToString())))
                    {
                        FormatearCamposNumericos();
                        lblCatalogo.Text = "Histórico de Ingresos";

                        txtCedula.Text = Request.QueryString["strCedula"].ToString();
                        txtNombre.Text = Request.QueryString["strNombre"].ToString();
                        //CargarTieneCapacidad();
                        if ((txtCedula.Text != string.Empty) && (txtNombre.Text != string.Empty))
                        {
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
            try
            {
                if (ValidarDatos())
                {
                    if (ValidarFecha())
                    {
                        //DateTime dFecha = DateTime.Parse(txtFechaActualizacion.Text.ToString());
                        Gestor.CrearValuacionFiador(int.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                    txtFechaActualizacion.Text.ToString(),
                            //Convert.ToDecimal(txtSalario.Text.Replace(".","")),
                                                    Convert.ToDecimal(txtSalario.Text),
                                                    -1,
                                                    //int.Parse(cbCapacidad.SelectedValue.ToString()), 
                                                    Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserción Exitosa" +
                                        "&strMensaje=" + "La valuación del fiador se insertó satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
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
                                    "&strMensaje=" + "No se pudo insertar la valuación del fiador. Error:" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                    "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }
        }

        private void Button2_Click(object sender, System.EventArgs e)
        {
            FormatearCamposNumericos();
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
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                txtFechaActualizacion.Enabled = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Este evento permite modificar la información de la calificación
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    Gestor.ModificarValuacionFiador(int.Parse(Session["GarantiaFiduciaria"].ToString()),
                                                    DateTime.Parse(txtFechaActualizacion.Text.ToString()),
                                                    Convert.ToDecimal(txtSalario.Text),
                                                    int.Parse(cbCapacidad.SelectedValue.ToString()),
                                                    Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "La valuación del fiador se modificó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Modificando Registro" +
                        "&strMensaje=" + "No se pudo modificar la información de la valuación del fiador." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                    "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                    "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarValuacionFiador(int.Parse(Request.QueryString["nGarantiaFiduciaria"].ToString()),
                                                txtFechaActualizacion.Text.ToString(),
                                                Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                //				Gestor.EliminarValuacionFiador(int.Parse(Request.QueryString["nGarantiaFiduciaria"].ToString()),
                //												DateTime.Parse(txtFechaActualizacion.Text.ToString()));

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + "La valuación del fiador se eliminó satisfactoriamente." +
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
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar la valuación del fiador." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmValuaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() +
                                                                "|strNombre=" + Request.QueryString["strNombre"].ToString() +
                                                                "|nGarantiaFiduciaria=" + Request.QueryString["nGarantiaFiduciaria"].ToString());
                }
            }
        }

        #endregion

        #region Métodos GridView

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
                                //if (!gdvValuacionesFiador.SelectedDataKey[2].ToString().Contains("."))
                                //{
                                    decimal nSalario = Convert.ToDecimal(gdvValuacionesFiador.SelectedDataKey[1].ToString());

                                    txtSalario.Text = nSalario.ToString("N");
                                //}
                                //else
                                //{
                                //    txtSalario.Text = gdvValuacionesFiador.SelectedDataKey[2].ToString();
                                //}
                            }
                            else
                            {
                                txtSalario.Text = "0.00"; //gdvValuacionesFiador.SelectedDataKey[1].ToString();
                            }

                            //CargarTieneCapacidad();
                            //if (gdvValuacionesFiador.SelectedDataKey[0].ToString() != null)
                            //    cbCapacidad.Items.FindByValue(gdvValuacionesFiador.SelectedDataKey[0].ToString()).Selected = true;

                            txtFechaActualizacion.Enabled = false;
                            btnInsertar.Enabled = false;
                            btnModificar.Enabled = true;
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

        #region Métodos Privados

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
                string strSQL = "SELECT " +
                                    "convert(varchar(10),a.fecha_valuacion,103) as fecha_valuacion, " +
                                    "a.ingreso_neto " +
                                    //"isnull(a.cod_tiene_capacidad_pago,-1) as cod_tiene_capacidad_pago, " +
                                    //"b.cat_descripcion as tiene_capacidad_pago " +
                                "FROM " +
                                    "GAR_VALUACIONES_FIADOR a " +
                                    //, " +
                                    //"CAT_ELEMENTO b " +
                                "WHERE " +
                                    "a.cod_garantia_fiduciaria = " + Request.QueryString["nGarantiaFiduciaria"].ToString() +
                                    //" and a.cod_tiene_capacidad_pago = b.cat_campo " +
                                    //" and b.cat_catalogo = " + Application["CAT_TIENE_CAPACIDAD"].ToString() +
                                " ORDER BY " +
                                    "convert(datetime,a.fecha_valuacion) DESC";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("fecha_valuacion")) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull("ingreso_neto"))) //&&
                        //(!dsDatos.Tables["Datos"].Rows[0].IsNull("tiene_capacidad_pago")))
                    {
                        this.gdvValuacionesFiador.DataSource = dsDatos.Tables["Datos"].DefaultView;
                        this.gdvValuacionesFiador.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
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
                    dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
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

        private void CargarTieneCapacidad()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIENE_CAPACIDAD"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbCapacidad.DataSource = null;
            cbCapacidad.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbCapacidad.DataValueField = "CAT_CAMPO";
            cbCapacidad.DataTextField = "CAT_DESCRIPCION";
            cbCapacidad.DataBind();
            cbCapacidad.ClearSelection();

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
                if (bRespuesta && txtFechaActualizacion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe seleccionar la fecha de Valuación.";
                    bRespuesta = false;
                }
                if (bRespuesta && DateTime.Parse(txtFechaActualizacion.Text.ToString()) > DateTime.Today)
                {
                    lblMensaje.Text = "La fecha de valuación no puede ser mayor a la fecha actual.";
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
        /// Valida que no existe una valuación para una fecha especifica
        /// </summary>
        /// <returns></returns>
        private bool ValidarFecha()
        {
            bool bRespuesta = true;
            try
            {
                //DateTime dFecha = DateTime.Parse(txtFechaActualizacion.Text.ToString());
                string strSQL = "SELECT " +
                                    "fecha_valuacion " +
                                "FROM " +
                                    "GAR_VALUACIONES_FIADOR " +
                                "WHERE " +
                                    "cod_garantia_fiduciaria = " + Request.QueryString["nGarantiaFiduciaria"].ToString() +
                                    " AND fecha_valuacion = '" + txtFechaActualizacion.Text.ToString().Substring(6, 4).ToString() + "/" +
                                                                txtFechaActualizacion.Text.ToString().Substring(0, 2).ToString() + "/" +
                                                                txtFechaActualizacion.Text.ToString().Substring(3, 2).ToString() + "'";

                //			string strSQL = "SELECT " +
                //								"fecha_valuacion " +
                //							"FROM " +
                //								"GAR_VALUACIONES_FIADOR " +
                //							"WHERE " +
                //								"cod_garantia_fiduciaria = " + Request.QueryString["nGarantiaFiduciaria"].ToString() +
                //								" AND fecha_valuacion = convert(varchar(10),'" + dFecha.Year.ToString() + "-" 
                //													  						   + dFecha.Month.ToString() + "-"  
                //																			   + dFecha.Day.ToString() + "',111)";

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
        #endregion
    }
}
