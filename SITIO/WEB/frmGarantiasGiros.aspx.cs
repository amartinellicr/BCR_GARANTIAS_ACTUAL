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
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Presentacion
{
    public partial class frmGarantiasGiros : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Label Label1;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnAsignar.Click +=new EventHandler(btnAsignar_Click);
            btnVerGarantias.Click +=new EventHandler(btnVerGarantias_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtConta.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOfici.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMon.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtProd.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOper.Attributes["onblur"] = "javascript:EsNumerico(this);";

            btnAsignar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea asignar estas garantías al giro?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIA_GIRO"].ToString())))
                    {
                        txtConta.Enabled = false;
                        txtOfici.Enabled = false;
                        txtMon.Enabled = false;
                        txtProd.Enabled = false;
                        txtOper.Enabled = false;
                        btnAsignar.Enabled = false;
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

        private void btnVerGarantias_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    string strSQLQuery = "SELECT " +
                                            "a.cod_operacion, " +
                                            "b.cedula_deudor, " +
                                            "b.nombre_deudor " +
                                        "FROM " +
                                            "gar_operacion a, " +
                                            "gar_deudor b " +
                                        "WHERE " +
                                            "a.cod_contabilidad = " + txtContabilidad.Text +
                                            " and a.cod_oficina = " + txtOficina.Text +
                                            " and a.cod_moneda = " + txtMoneda.Text +
                                            " and a.num_operacion is null " +
                                            " and a.num_contrato = " + txtOperacion.Text +
                                            " and a.cedula_deudor = b.cedula_deudor";

                    System.Data.DataSet dsDatos = new System.Data.DataSet();
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQLQuery, oleDbConnection1);
                    cmdConsulta.Fill(dsDatos, "Operacion");

                    if (dsDatos.Tables["Operacion"].Rows.Count > 0)
                    {
                        txtConta.Enabled = true;
                        txtOfici.Enabled = true;
                        txtMon.Enabled = true;
                        txtProd.Enabled = true;
                        txtOper.Enabled = true;
                        btnAsignar.Enabled = true;
                        Session["Contrato"] = int.Parse(dsDatos.Tables["Operacion"].Rows[0]["cod_operacion"].ToString());
                        lblDeudor.Visible = true;
                        lblNombreDeudor.Visible = true;
                        lblNombreDeudor.Text = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString() + " - " +
                                               dsDatos.Tables["Operacion"].Rows[0]["nombre_deudor"].ToString();
                        CargarGrid();
                    }
                    else
                    {
                        txtConta.Enabled = false;
                        txtOfici.Enabled = false;
                        txtMon.Enabled = false;
                        txtProd.Enabled = false;
                        txtOper.Enabled = false;
                        btnAsignar.Enabled = false;
                        Session["Contrato"] = "";
                        lblDeudor.Visible = false;
                        lblNombreDeudor.Visible = false;
                        lblMensaje.Text = "El contrato no existe en el sistema.";
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                    "bError=1" +
                    "&strTitulo=" + "Problemas Cargando Página" +
                    "&strMensaje=" + ex.Message +
                    "&bBotonVisible=0");
            }
        }

        private void btnAsignar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatosGiro())
                {

                    string strOperacionCrediticia = txtConta.Text + "-" + txtOfici.Text + "-" + txtMon.Text + "-" + txtProd.Text + "-" + txtOper.Text;



                    string strSQLQuery = "SELECT " +
                                            "cod_operacion " +
                                        "FROM " +
                                            "gar_operacion " +
                                        "WHERE " +
                                            "cod_contabilidad = " + txtConta.Text +
                                            " and cod_oficina = " + txtOfici.Text +
                                            " and cod_moneda = " + txtMon.Text +
                                            " and cod_producto = " + txtProd.Text +
                                            " and num_operacion = " + txtOper.Text;

                    System.Data.DataSet dsDatos = new System.Data.DataSet();
                    oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                    OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQLQuery, oleDbConnection1);
                    cmdConsulta.Fill(dsDatos, "Operacion");

                    if (dsDatos.Tables["Operacion"].Rows.Count > 0)
                    {
                        Gestor.AsignarGarantias(long.Parse(dsDatos.Tables["Operacion"].Rows[0]["cod_operacion"].ToString()),
                                                long.Parse(Session["Contrato"].ToString()),
                                                Session["strUSER"].ToString(),
                                                Request.UserHostAddress.ToString(), strOperacionCrediticia);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=0" +
                                        "&strTitulo=" + "Inserción Exitosa" +
                                        "&strMensaje=" + "Las garantías se asignaron satisfactoriamente." +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasGiros.aspx");
                    }
                    else
                        lblMensaje2.Text = "La operación crediticia no existe en el sistema.";
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("Violation of PRIMARY KEY constraint"))
                {
                    lblMensaje.Text = "Estas garantías ya han sido asociadas anteriormente a esta operación. Por favor verifique... ";
                }
                else if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando Página" +
                                    "&strMensaje=" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasGiros.aspx");
                }
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvGarantiasGiros_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            //GridView gdvGarantiasGiros = (GridView)sender;
            //int rowIndex = 0;

            //try
            //{
            //    switch (e.CommandName)
            //    {
            //        case ("SelectedGarantiaGiro"):
            //            rowIndex = (int.Parse(e.CommandArgument.ToString()));

            //            gdvGarantiasGiros.SelectedIndex = rowIndex;

            //            Session["CodigoTarjeta"] = gdvGarantiasGiros.SelectedDataKey[11].ToString();

            //            if (gdvGarantiasGiros.SelectedDataKey[3].ToString() != null)
            //                cbTipoFiador.SelectedValue = gdvGarantiasGiros.SelectedDataKey[3].ToString();

            //            if (gdvGarantiasGiros.SelectedDataKey[1].ToString() != null)
            //                txtCedulaFiador.Text = gdvGarantiasGiros.SelectedDataKey[1].ToString();
            //            else
            //                txtCedulaFiador.Text = "";

            //            if (gdvGarantiasGiros.SelectedDataKey[2].ToString() != null)
            //                txtNombreFiador.Text = gdvGarantiasGiros.SelectedDataKey[2].ToString();
            //            else
            //                txtNombreFiador.Text = "";

            //            //				CargarTipoMitigador();
            //            //				if (e.SelectedCells[0].Row.Cells[4].Value != null)
            //            //					cbMitigador.SelectedValue = e.SelectedCells[0].Row.Cells[4].Value.ToString();

            //            CargarTiposDocumentos();
            //            if (gdvGarantiasGiros.SelectedDataKey[5].ToString() != null)
            //                cbTipoDocumento.SelectedValue = gdvGarantiasGiros.SelectedDataKey[5].ToString();

            //            //				if (e.SelectedCells[0].Row.Cells[6].Value != null)
            //            //					txtMontoMitigador.Value = e.SelectedCells[0].Row.Cells[6].Value;
            //            //				else
            //            //					txtMontoMitigador.Value = 0;

            //            if (gdvGarantiasGiros.SelectedDataKey[6].ToString() != null)
            //                txtPorcentajeResponsabilidad.Text = gdvGarantiasGiros.SelectedDataKey[6].ToString();
            //            else
            //                txtPorcentajeResponsabilidad.Text = "0";

            //            if (gdvGarantiasGiros.SelectedDataKey[8].ToString() != null)
            //                cbTipoAcreedor.SelectedValue = gdvGarantiasGiros.SelectedDataKey[8].ToString();

            //            if (gdvGarantiasGiros.SelectedDataKey[9].ToString() != null)
            //                txtAcreedor.Text = gdvGarantiasGiros.SelectedDataKey[9].ToString();
            //            else
            //                txtAcreedor.Text = "";

            //            if (Session["Tipo_Operacion"].ToString() == Application["TARJETA"].ToString())
            //            {
            //                if (gdvGarantiasGiros.SelectedDataKey[13].ToString() != "01/01/1900 12:00:00 AM")
            //                    txtFechaExpiracion.Text = gdvGarantiasGiros.SelectedDataKey[13].ToString();

            //                txtMontoCobertura.Text = gdvGarantiasGiros.SelectedDataKey[14].ToString();
            //            }

            //            if (gdvGarantiasGiros.SelectedDataKey[7].ToString() != null)
            //                cbOperacionEspecial.SelectedValue = gdvGarantiasGiros.SelectedDataKey[7].ToString();

            //            if (gdvGarantiasGiros.SelectedDataKey[11].ToString() != null)
            //                Session["GarantiaFiduciaria"] = gdvGarantiasGiros.SelectedDataKey[11].ToString();

            //            //				btnIngresos.Enabled = true;
            //            btnInsertar.Enabled = false;
            //            btnModificar.Enabled = true;
            //            btnEliminar.Enabled = true;
            //            lblMensaje.Text = "";
            //            lblMensaje3.Text = "";


            //            break;

            //    }
            //}
            //catch (Exception ex)
            //{
            //    lblMensaje.Text = ex.Message;
            //}
        }

        protected void gdvGarantiasGiros_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvGarantiasGiros.SelectedIndex = -1;
            this.gdvGarantiasGiros.PageIndex = e.NewPageIndex;

            CargarGrid();
        }

        #endregion
        
        #region Métodos Privados

        /// <summary>
        /// Este método permite validar los campos llave del contrato
        /// </summary>
        /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";

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
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
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

        /// <summary>
        /// Este método permite validar los campos llave del contrato
        /// </summary>
        /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
        private bool ValidarDatosGiro()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje2.Text = "";

                if (bRespuesta && txtConta.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el código de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOfici.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el código de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMon.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el código de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && txtProd.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el código del producto";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOper.Text.Trim().Length == 0)
                {
                    lblMensaje2.Text = "Debe ingresar el número de contrato";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        private void CargarGrid()
        {
            try
            {
                string strSQL = "SELECT " +
                                    "b.cod_garantia_fiduciaria as cod_garantia, " +
                                    "b.cod_tipo_garantia, " +
                                    "c.cat_descripcion, " +
                                    "'[Fiador] ' + ISNULL(b.cedula_fiador,'') + ' - ' + ISNULL(b.nombre_fiador,'') as Garantia " +
                                "FROM " +
                                    "GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION a, " +
                                    "GAR_GARANTIA_FIDUCIARIA b, " +
                                    "CAT_ELEMENTO c " +
                                "WHERE " +
                                    "a.cod_operacion = " + Session["Contrato"].ToString() +
                                    "AND a.cod_garantia_fiduciaria = b.cod_garantia_fiduciaria " +
                                    "AND b.cod_tipo_garantia = c.cat_campo " +
                                    "AND c.cat_catalogo = " + Application["CAT_TIPO_GARANTIA"].ToString() +

                                "UNION ALL " +

                                "SELECT " +
                                    "b.cod_garantia_real as cod_garantia, " +
                                    "b.cod_tipo_garantia, " +
                                    "c.cat_descripcion, " +
                                    "case b.cod_tipo_garantia_real " +
                                        "when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), b.cod_partido),'') + ' - Finca: ' + ISNULL(b.numero_finca,'') " +
                                        "when 2 then '[Cédula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), b.cod_partido),'') + ' - Finca: ' + ISNULL(b.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), b.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2), b.cedula_hipotecaria),'') " +
                                        "when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), b.cod_clase_bien),'') + ' - Placa: ' + ISNULL(b.num_placa_bien,'') " +
                                    "end as Garantia " +
                                "FROM " +
                                    "GAR_GARANTIAS_REALES_X_OPERACION a, " +
                                    "GAR_GARANTIA_REAL b, " +
                                    "CAT_ELEMENTO c " +
                                "WHERE " +
                                    "a.cod_operacion = " + Session["Contrato"].ToString() +
                                    "AND a.cod_garantia_real = b.cod_garantia_real " +
                                    "AND b.cod_tipo_garantia = c.cat_campo " +
                                    "AND c.cat_catalogo = " + Application["CAT_TIPO_GARANTIA"].ToString() +

                                "UNION ALL " +

                                "SELECT " +
                                    "b.cod_garantia_valor as cod_garantia, " +
                                    "b.cod_tipo_garantia, " +
                                    "c.cat_descripcion, " +
                                    "'[Número de Seguridad] ' + ISNULL(b.numero_seguridad,'') as Garantia " +
                                "FROM " +
                                    "GAR_GARANTIAS_VALOR_X_OPERACION a, " +
                                    "GAR_GARANTIA_VALOR b, " +
                                    "CAT_ELEMENTO c " +
                                "WHERE " +
                                    "a.cod_operacion = " + Session["Contrato"].ToString() +
                                    "AND a.cod_garantia_valor = b.cod_garantia_valor " +
                                    "AND b.cod_tipo_garantia = c.cat_campo " +
                                    "AND c.cat_catalogo = " + Application["CAT_TIPO_GARANTIA"].ToString();

                System.Data.DataSet dsDatos = new System.Data.DataSet();
                oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
                OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
                cmdConsulta.Fill(dsDatos, "Datos");

                if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
                {

                    if ((!dsDatos.Tables["Datos"].Rows[0].IsNull("cat_descripcion")) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull("Garantia")) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull("cod_garantia")) &&
                        (!dsDatos.Tables["Datos"].Rows[0].IsNull("cod_tipo_garantia")))
                    {
                        this.gdvGarantiasGiros.DataSource = dsDatos.Tables["Datos"].DefaultView;
                        this.gdvGarantiasGiros.DataBind();
                    }
                    else
                    {
                        dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                        this.gdvGarantiasGiros.DataSource = dsDatos;
                        this.gdvGarantiasGiros.DataBind();

                        int TotalColumns = this.gdvGarantiasGiros.Rows[0].Cells.Count;
                        this.gdvGarantiasGiros.Rows[0].Cells.Clear();
                        this.gdvGarantiasGiros.Rows[0].Cells.Add(new TableCell());
                        this.gdvGarantiasGiros.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                        this.gdvGarantiasGiros.Rows[0].Cells[0].Text = "No existen registros";
                    }
                }
                else
                {
                    dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
                    this.gdvGarantiasGiros.DataSource = dsDatos;
                    this.gdvGarantiasGiros.DataBind();

                    int TotalColumns = this.gdvGarantiasGiros.Rows[0].Cells.Count;
                    this.gdvGarantiasGiros.Rows[0].Cells.Clear();
                    this.gdvGarantiasGiros.Rows[0].Cells.Add(new TableCell());
                    this.gdvGarantiasGiros.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvGarantiasGiros.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #endregion
    }
}
