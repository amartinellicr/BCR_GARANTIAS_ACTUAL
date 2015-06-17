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
    public partial class frmDeudores : BCR.Web.SystemFramework.PaginaPersistente
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

            btnCapacidadPago.Click +=new EventHandler(btnCapacidadPago_Click);
            btnModificar.Click +=new EventHandler(btnModificar_Click);
            btnRegresar.Click +=new EventHandler(btnRegresar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el deudor seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_DEUDORES"].ToString())))
                    {
                        if (Request.QueryString["nTipoGarantia"] != null)
                        {
                            Session["nTipoGarantia"] = Request.QueryString["nTipoGarantia"].ToString(); 
                        }

                        txtCedula.Text = Session["Deudor"].ToString();
                        CargarComboCondiciones();
                        CargarComboTipos();
                        CargarTiposAsignacion();
                        CargarGenerador();
                        CargarVinculado();
                        CargarDatos();
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

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                CargarComboTipos();
                txtCedula.Text = "";
                txtNombre.Text = "";
                CargarComboCondiciones();
                btnModificar.Enabled = false;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            int nTipoGarantia = 0;

            try
            {
                if (ValidarDatos())
                {

                    if (Request.QueryString["nTipoGarantia"] != null)
                    {
                        nTipoGarantia = Convert.ToInt32(Request.QueryString["nTipoGarantia"].ToString());
                    }

                    Gestor.ModificarDeudor(int.Parse(cbTipo.SelectedValue.ToString()),
                                            txtCedula.Text.Trim(),
                                            txtNombre.Text.Trim(),
                                            int.Parse(cbCondicion.SelectedValue.ToString()),
                                            int.Parse(cbTipoAsignacion.SelectedValue.ToString()),
                                            int.Parse(cbGenerador.SelectedValue.ToString()),
                                            int.Parse(cbVinculadoEntidad.SelectedValue.ToString()),
                                            Session["strUSER"].ToString(),
                                            Request.UserHostAddress.ToString(), nTipoGarantia);

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Modificación Exitosa" +
                                    "&strMensaje=" + "La información del deudor se modificó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmDeudores.aspx?strDeudor=" + Session["Deudor"].ToString() +
                                                              "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString(), true);
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la información del deudor. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmDeudores.aspx?strDeudor=" + Session["Deudor"].ToString() +
                                                              "|nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString(), true);
                }
            }
        }

        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            if (Request.QueryString["nTipoGarantia"].ToString() == Application["GARANTIA_REAL"].ToString())
                Response.Redirect("frmGarantiasReales.aspx", true);
            else if (Request.QueryString["nTipoGarantia"].ToString() == Application["GARANTIA_FIDUCIARIA"].ToString())
                Response.Redirect("frmGarantiasFiduciaria.aspx", true);
            else if (Request.QueryString["nTipoGarantia"].ToString() == Application["GARANTIA_VALOR"].ToString())
                Response.Redirect("frmGarantiasValor.aspx", true);
        }

        private void btnCapacidadPago_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmCapacidadPago.aspx?strCedula=" + txtCedula.Text.Trim() +
                                                  "&strNombre=" + txtNombre.Text.Trim() +
                                                  "&nTipoGarantia=" + Request.QueryString["nTipoGarantia"].ToString() +
                                                  "&strDireccion=INDIRECTO", true);
        }

        #endregion

        #region Métodos Privados

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
            try
            {
                string strSQL;

                strSQL = "SELECT " +
                            "cedula_deudor, " +
                            "nombre_deudor, " +
                            "isnull(cod_tipo_deudor,-1) as cod_tipo_deudor, " +
                            "isnull(cod_condicion_especial,-1) as cod_condicion_especial, " +
                            "isnull(cod_tipo_asignacion,2) as cod_tipo_asignacion, " +
                            "isnull(cod_generador_divisas,-1) as cod_generador_divisas, " +
                            "isnull(cod_vinculado_entidad,2) as cod_vinculado_entidad " +
                        "FROM " +
                            "gar_deudor " +
                        "WHERE " +
                            "cedula_deudor = '" + Session["Deudor"].ToString() + "'";

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Deudor");
                CargarComboTipos();
                cbTipo.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][2].ToString()).Selected = true;
                txtNombre.Text = dsDatos.Tables["Deudor"].Rows[0][1].ToString();
                CargarComboCondiciones();
                cbCondicion.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][3].ToString()).Selected = true;
                CargarTiposAsignacion();
                cbTipoAsignacion.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][4].ToString()).Selected = true;
                CargarGenerador();
                cbGenerador.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][5].ToString()).Selected = true;
                CargarVinculado();
                cbVinculadoEntidad.Items.FindByValue(dsDatos.Tables["Deudor"].Rows[0][6].ToString()).Selected = true;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
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
        private bool ValidarDatos()
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

        #endregion
    }
}
