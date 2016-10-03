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
    public partial class frmCalificaciones : System.Web.UI.Page
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;

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
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.AppendHeader("Cache-Control", "no-cache, must-revalidate");
            Response.AppendHeader("Pragma", "no-cache");
            Response.Expires = -1;

            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar la calificación del deudor seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar la calificación del deudor seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Session["strUSER"].ToString(), int.Parse(Application["MNU_CALIFICACIONES"].ToString())))
                    {
                        lblCatalogo.Text = "Histórico de Calificaciones";

                        txtCedula.Text = "401640970";//Request.QueryString["strCedula"].ToString();
                        txtNombre.Text = "Tato"; // Request.QueryString["strNombre"].ToString();
                        txtFechaCalificacion.Text = DateTime.Today.ToString();

                        //CargarComboTipos();
                        //CargarGrid();
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
                            "&bBotonVisible=0", true);
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando Página" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=0", true);
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
                        Gestor.CrearCalificacion(txtCedula.Text, DateTime.Parse(txtFechaCalificacion.Text.ToString()),
                                                int.Parse(cbTipoAsignacion.SelectedValue.ToString()),
                                                txtCategoria.Text, txtCalificacion.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                        Response.Redirect("frmMensaje.aspx?" +
                            "bError=0" +
                            "&strTitulo=" + "Inserción Exitosa" +
                            "&strMensaje=" + "La calificación del deudor se insertó satisfactoriamente." +
                            "&bBotonVisible=1" +
                            "&strTextoBoton=Regresar" +
                            "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
                    }
                    else
                    {
                        lblMensaje.Text = "Ya existe una calificación para esta fecha. Por favor verifique.";
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
                                    "&strMensaje=" + "No se pudo insertar la calificación del deudor. Error:" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
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
            CargarComboTipos();
            txtFechaCalificacion.Text = "";
            txtCategoria.Text = "";
            txtCalificacion.Text = "";
            btnInsertar.Enabled = true;
            btnModificar.Enabled = false;
            btnEliminar.Enabled = false;
            txtFechaCalificacion.Enabled = true;
        }

        /// <summary>
        /// Este evento permite regresar al formulario anterior
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            if (int.Parse(Request.QueryString["nTipoGarantia"].ToString()) == int.Parse(Application["GARANTIA_FIDUCIARIA"].ToString()))
                Response.Redirect("frmGarantiasFiduciaria.aspx", true);
            else if (int.Parse(Request.QueryString["nTipoGarantia"].ToString()) == int.Parse(Application["GARANTIA_REAL"].ToString()))
                Response.Redirect("frmGarantiasReales.aspx", true);
            else if (int.Parse(Request.QueryString["nTipoGarantia"].ToString()) == int.Parse(Application["GARANTIA_VALOR"].ToString()))
                Response.Redirect("frmGarantiasValor.aspx", true);
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
                    Gestor.ModificarCalificacion(txtCedula.Text, DateTime.Parse(txtFechaCalificacion.Text.ToString()),
                                                int.Parse(cbTipoAsignacion.SelectedValue.ToString()),
                                                txtCategoria.Text, txtCalificacion.Text, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=0" +
                        "&strTitulo=" + "Modificación Exitosa" +
                        "&strMensaje=" + "La calificación del deudor se modificó satisfactoriamente." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Modificando Registro" +
                        "&strMensaje=" + "No se pudo modificar la información de la calificación del deudor." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
                }
            }
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                Gestor.EliminarCalificacion(txtCedula.Text, DateTime.Parse(txtFechaCalificacion.Text.ToString()), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Eliminación Exitosa" +
                    "&strMensaje=" + "La calificación del deudor se eliminó satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Eliminando Registro" +
                        "&strMensaje=" + "No se pudo eliminar la calificación el deudor." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmCalificaciones.aspx?strCedula=" + Request.QueryString["strCedula"].ToString() + "|strNombre=" + Request.QueryString["strNombre"].ToString(), true);
                }
            }
        }
        
        #endregion

        #region Métodos GridView

        protected void gdvCalificaciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvCalificaciones = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedCalificacion"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvCalificaciones.SelectedIndex = rowIndex;

                        try
                        {

                            
                            if (gdvCalificaciones.SelectedDataKey[3].ToString() != null)
                                txtFechaCalificacion.Text = gdvCalificaciones.SelectedDataKey[3].ToString();

                            CargarComboTipos();

                            if (gdvCalificaciones.SelectedDataKey[4].ToString() != null)
                            {
                                cbTipoAsignacion.Items.FindByValue(gdvCalificaciones.SelectedDataKey[4].ToString()).Selected = true;
                            }

                            if (gdvCalificaciones.SelectedDataKey[5].ToString() != null)
                                txtCategoria.Text = gdvCalificaciones.SelectedDataKey[5].ToString();

                            if (gdvCalificaciones.SelectedDataKey[6].ToString() != null)
                                txtCalificacion.Text = gdvCalificaciones.SelectedDataKey[6].ToString();

                            txtFechaCalificacion.Enabled = false;
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

        protected void gdvCalificaciones_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvCalificaciones.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        #endregion

        #region Métodos Privados

        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            string strSQL = "SELECT " +
                                "a.cedula_deudor, " +
                                "b.nombre_deudor, " +
                                "convert(varchar(10),a.fecha_calificacion,111) as fecha_calificacion, " +
                                "isnull(a.cod_tipo_asignacion,0) as cod_tipo_asignacion, " +
                                "c.cat_descripcion as des_tipo_asignacion, " +
                                "a.cod_categoria_calificacion, " +
                                "isnull(a.cod_calificacion_riesgo,'') as cod_calificacion_riesgo " +
                            "FROM " +
                                "GAR_CALIFICACIONES a, " +
                                "GAR_DEUDOR b, " +
                                "CAT_ELEMENTO c " +
                            "WHERE " +
                                "a.cedula_deudor = b.cedula_deudor " +
                                "and a.cedula_deudor = '" + txtCedula.Text.Trim() + "'" +
                                "and isnull(a.cod_tipo_asignacion,0) = c.cat_campo " +
                                "and c.cat_catalogo = 19 " +
                            "ORDER BY " +
                                "fecha_calificacion DESC";

            DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Deudor");

            if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Deudor"].Rows.Count > 0))
            {

                if ((!dsDatos.Tables["Deudor"].Rows[0].IsNull("fecha_calificacion")) &&
                    (!dsDatos.Tables["Deudor"].Rows[0].IsNull("des_tipo_asignacion")) &&
                    (!dsDatos.Tables["Deudor"].Rows[0].IsNull("cod_categoria_calificacion")) &&
                    (!dsDatos.Tables["Deudor"].Rows[0].IsNull("cod_calificacion_riesgo")))
                {
                    this.gdvCalificaciones.DataSource = dsDatos.Tables["Deudor"].DefaultView;
                    this.gdvCalificaciones.DataBind();
                }
                else
                {
                    dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                    this.gdvCalificaciones.DataSource = dsDatos;
                    this.gdvCalificaciones.DataBind();

                    int TotalColumns = this.gdvCalificaciones.Rows[0].Cells.Count;
                    this.gdvCalificaciones.Rows[0].Cells.Clear();
                    this.gdvCalificaciones.Rows[0].Cells.Add(new TableCell());
                    this.gdvCalificaciones.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvCalificaciones.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            else
            {
                dsDatos.Tables["Deudor"].Rows.Add(dsDatos.Tables["Deudor"].NewRow());
                this.gdvCalificaciones.DataSource = dsDatos;
                this.gdvCalificaciones.DataBind();

                int TotalColumns = this.gdvCalificaciones.Rows[0].Cells.Count;
                this.gdvCalificaciones.Rows[0].Cells.Clear();
                this.gdvCalificaciones.Rows[0].Cells.Add(new TableCell());
                this.gdvCalificaciones.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                this.gdvCalificaciones.Rows[0].Cells[0].Text = "No existen registros";
            }
        }

        private void CargarComboTipos()
        {
            DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT cat_campo, convert(varchar(10),cat_campo) + ' - ' + cat_descripcion as cat_descripcion FROM cat_elemento WHERE cat_catalogo = " + int.Parse(Application["CAT_TIPO_ASIGNACION"].ToString()) + " UNION ALL SELECT -1, '' ORDER BY cat_campo", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Tipos");
            cbTipoAsignacion.DataSource = null;
            cbTipoAsignacion.DataSource = dsDatos.Tables["Tipos"].DefaultView;
            cbTipoAsignacion.DataValueField = "CAT_CAMPO";
            cbTipoAsignacion.DataTextField = "CAT_DESCRIPCION";
            cbTipoAsignacion.DataBind();
        }

        /// <summary>
        /// Metodo de validación de datos
        /// </summary>
        /// <returns></returns>
        private bool ValidarDatos()
        {
            lblMensaje.Text = "";
            if (txtFechaCalificacion.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe seleccionar la fecha de calificación.";
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
            DateTime dFecha = DateTime.Parse(txtFechaCalificacion.Text.ToString());
            string strSQL = "SELECT " +
                                "fecha_calificacion " +
                            "FROM " +
                                "GAR_CALIFICACIONES " +
                            "WHERE " +
                                "cedula_deudor = '" + txtCedula.Text.Trim() + "' " +
                                "and fecha_calificacion = convert(varchar(10),'" + dFecha.Year.ToString() + "-" +
                                                                                   dFecha.Month.ToString() + "-" +
                                                                                   dFecha.Day.ToString() + "',111)";

            DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Datos");
            if (dsDatos.Tables["Datos"].Rows.Count > 0)
                return false;
            else
                return true;
        }
        #endregion

    }
}
