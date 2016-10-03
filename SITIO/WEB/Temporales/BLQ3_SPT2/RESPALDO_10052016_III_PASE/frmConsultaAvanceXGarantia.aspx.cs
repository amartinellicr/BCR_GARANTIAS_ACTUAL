using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.IO;
using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using System.Configuration;
using System.Security.Permissions;
using System.Xml;

namespace BCRGARANTIAS.Forms
{
    public partial class frmConsultaAvanceXGarantia : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected Image Image2;
        protected OleDbConnection oleDbConnection1;
        protected Label lblUsrConectado;
        protected Label lblFecha;
        protected DropDownList cbFechaCorte2;

        protected DataSet dsDatos = new DataSet();

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnConsultar.Click += new EventHandler(btnConsultar_Click);
            btnExportar.Click += new EventHandler(btnExportar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_REPORTE_AVANCE_OFICINA"].ToString())))
                    {
                        lblCatalogo.Text = "Resultado de la Consulta";
                        CargarDatos();
                        Label1.Visible = false;
                        Label2.Visible = false;
                        lblAvance.Visible = false;
                        lblPendiente.Visible = false;
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

        private void btnConsultar_Click(object sender, System.EventArgs e)
        {
            lblMensaje.Text = "";
            gdvReporte.DataSource = null;
            gdvReporte.DataBind();

            if ((int.Parse(cbTipoReporte.SelectedValue.ToString()) == 1) ||
                (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 2))
            {
                Label1.Visible = true;
                Label2.Visible = true;
                lblAvance.Visible = true;
                lblPendiente.Visible = true;
            }
            else
            {
                Label1.Visible = false;
                Label2.Visible = false;
                lblAvance.Visible = false;
                lblPendiente.Visible = false;
            }

            if ((int.Parse(cbTipoReporte.SelectedValue.ToString()) == 1) ||
                (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 2) ||
                ((int.Parse(cbTipoReporte.SelectedValue.ToString()) == 3) && (int.Parse(cbOficina.SelectedValue.ToString()) != -1)) ||
                ((int.Parse(cbTipoReporte.SelectedValue.ToString()) == 4) && (int.Parse(cbOficina.SelectedValue.ToString()) != -1)))
            {
                btnExportar.Enabled = true;
                btnConsultar.Enabled = true;
                CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()), int.Parse(cbTipoReporte.SelectedValue.ToString()));
                btnConsultar.Enabled = true;
            }
            else
                GenerarExcel(int.Parse(cbTipoCaptacion.SelectedValue.ToString()), int.Parse(cbTipoReporte.SelectedValue.ToString()));
        }

        private void btnExportar_Click(object sender, System.EventArgs e)
        {
            try
            {
                String sFilename = "";
                DataTable dtDatos = new DataTable();

                string strRuta = ConfigurationManager.AppSettings["DOWNLOAD"].ToString();

                string[] straEncabezados = new string[6];

                for (int nIndice = 0; nIndice < straEncabezados.Length; nIndice++)
                {
                    straEncabezados[nIndice] = string.Empty;
                }

                //sFilename = strRuta;

                if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 1)
                    sFilename = "AvanceXGarantia.xls";
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 2)
                    sFilename = "AvanceXOperacion.xls";
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 3)
                    sFilename = "DetalleXGarantia.xls";
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 4)
                    sFilename = "DetalleXOperacion.xls";

                //File.Delete(Page.MapPath(sFilename));
                //StreamWriter sw = File.CreateText(Page.MapPath(sFilename));

                if (Directory.Exists(strRuta))
                {
                    FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRuta);
                    Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, strRuta + sFilename);
                }

                if (strRuta.Contains("\\"))
                {
                    if (strRuta.EndsWith("\\"))
                    {
                        strRuta += sFilename;
                    }
                    else
                    {
                        strRuta += "\\" + sFilename;
                    }
                }
                else if (strRuta.Contains("/"))
                {
                    if (strRuta.EndsWith("/"))
                    {
                        strRuta += sFilename;
                    }
                    else
                    {
                        strRuta += "/" + sFilename;
                    }
                }


                File.Delete(strRuta);
                StreamWriter sw = File.CreateText(strRuta);

                String s = "";

                if ((dsDatos == null) || (dsDatos.Tables.Count == 0) || (dsDatos.Tables[0].Rows.Count == 0))
                {
                    ObtenerDatos();
                }

                int nIndiceEncabezados = 0;
                for (int i = 0; i < gdvReporte.Columns.Count; i++)
                    if (gdvReporte.Columns[i].Visible)
                    {
                        s += gdvReporte.Columns[i].HeaderText + "\t";

                        straEncabezados[nIndiceEncabezados] = gdvReporte.DataKeyNames[i].ToString();

                        nIndiceEncabezados++;

                        dtDatos.Columns.Add(new DataColumn(gdvReporte.Columns[i].HeaderText, Type.GetType("System.String")));
                    }

                sw.WriteLine(s.TrimEnd('\t'));
                s = "";

                DataRow dr = dtDatos.NewRow();

                for (int nIndiceFilas = 0; nIndiceFilas < dsDatos.Tables["Datos"].Rows.Count; nIndiceFilas++)
                {
                    
                    for (int nIndiceEncab = 0; nIndiceEncab < straEncabezados.Length; nIndiceEncab++)
                    {
                        for (int nIndiceCol = 0; nIndiceCol < dsDatos.Tables["Datos"].Columns.Count; nIndiceCol++)
                        {
                            if (dsDatos.Tables["Datos"].Columns[nIndiceCol].ColumnName.CompareTo(straEncabezados[nIndiceEncab].ToString()) == 0)
                            {
                                s += dsDatos.Tables["Datos"].Rows[nIndiceFilas][nIndiceCol].ToString() + "\t";

                                dr[nIndiceEncab] = dsDatos.Tables["Datos"].Rows[nIndiceFilas][nIndiceCol].ToString();
                             
                            }
                        }

                    }
                    dtDatos.Rows.Add(dr);
                    dr.AcceptChanges();
                    dtDatos.AcceptChanges();
                    sw.WriteLine(s.TrimEnd('\t'));
                    s = string.Empty;
                    dr = dtDatos.NewRow();
                }

                sw.Close();
                
                HttpResponse response = HttpContext.Current.Response;

                response.Clear();
                response.Charset = "";

                response.ContentType = "application/vnd.ms-excel";
                response.AddHeader("Content-Disposition", "attachment;filename=\"" + sFilename + "\"");

                using (StringWriter sw1 = new StringWriter())
                {
                    using (HtmlTextWriter htw = new HtmlTextWriter(sw1))
                    {
                        GridView dg = new GridView();
                        dg.DataSource = dtDatos;//ds.Tables[0];
                        dg.DataBind();
                        dg.RenderControl(htw);
                        response.Write(sw1.ToString());
                        response.End();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
            //base.VerifyRenderingInServerForm(control);
        }
        #endregion

        #region Métodos GridView

        protected void gdvReporte_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvReporte = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedGarantiaReal"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvReporte.SelectedIndex = rowIndex;



                        break;

                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        protected void gdvReporte_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gdvReporte.PageIndex = e.NewPageIndex;

            CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()), int.Parse(cbTipoReporte.SelectedValue.ToString()));
        }

        protected void gdvReporte_DataBinding(object sender, EventArgs e)
        {
            GridView gdvReporte = ((GridView)sender);

            BoundField bnfColumnaInvisible = new BoundField();
            ButtonField btfColumnaVisible = new ButtonField();

            if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
            {
                //Resumen consolidado de garantias por oficina cliente
                if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 1)
                {

                    gdvReporte.Columns.Clear();

                    bnfColumnaInvisible.DataField = "fecha_corte";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "cod_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "avance";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "pendiente";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_garantias_completas";
                    btfColumnaVisible.HeaderText = "% AVANCE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(90, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_garantias_pendientes";
                    btfColumnaVisible.HeaderText = "% PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias";
                    btfColumnaVisible.HeaderText = "TOTAL GARANTIAS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias_completas";
                    btfColumnaVisible.HeaderText = "GARANTIAS COMPLETAS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(190, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias_pendientes";
                    btfColumnaVisible.HeaderText = "GARANTIAS PENDIENTES";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(190, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    string[] strLlaves = {"fecha_corte", "cod_oficina", "des_oficina", "avance",
                    "pendiente", "oficina", "porcentaje_total_garantias_completas", "porcentaje_total_garantias_pendientes", 
                    "total_garantias", "total_garantias_completas", "total_garantias_pendientes"};

                    gdvReporte.DataKeyNames = strLlaves;
                }
                //Resumen consolidado de operaciones por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 2)
                {
                    gdvReporte.Columns.Clear();

                    bnfColumnaInvisible.DataField = "fecha_corte";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "cod_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "avance";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "pendiente";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_operaciones_completas";
                    btfColumnaVisible.HeaderText = "% AVANCE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(90, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_operaciones_pendientes";
                    btfColumnaVisible.HeaderText = "% PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_operaciones";
                    btfColumnaVisible.HeaderText = "TOTAL OPERACIONES";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(170, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_operaciones_completas";
                    btfColumnaVisible.HeaderText = "OPERACIONES COMPLETAS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(210, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_operaciones_pendientes";
                    btfColumnaVisible.HeaderText = "OPERACIONES PENDIENTES";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(210, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    string[] strLlaves = {"fecha_corte", "cod_oficina", "des_oficina", "avance",
                    "pendiente", "oficina", "porcentaje_total_operaciones_completas", "porcentaje_total_operaciones_pendientes", 
                    "total_operaciones", "total_operaciones_completas", "total_operaciones_pendientes"};

                    gdvReporte.DataKeyNames = strLlaves;

                }
                //Detalle de garantías por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 3)
                {
                    gdvReporte.Columns.Clear();

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "operacion";
                    btfColumnaVisible.HeaderText = "OPERACION";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(160, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "tipo_garantia";
                    btfColumnaVisible.HeaderText = "TIPO GARANTIA";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(180, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "garantia";
                    btfColumnaVisible.HeaderText = "GARANTIA";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(550, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "pendiente";
                    btfColumnaVisible.HeaderText = "PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    string[] strLlaves = { "oficina", "operacion", "tipo_garantia", "garantia", "pendiente" };

                    gdvReporte.DataKeyNames = strLlaves;
                }
                //Detalle de operaciones por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 4)
                {
                    gdvReporte.Columns.Clear();

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "operacion";
                    btfColumnaVisible.HeaderText = "OPERACION";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(160, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "saldo_actual";
                    btfColumnaVisible.HeaderText = "SALDO ACTUAL";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(180, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "fecha_constitucion";
                    btfColumnaVisible.HeaderText = "FECHA CONSTITUCION";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(200, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "fecha_contabilizacion";
                    btfColumnaVisible.HeaderText = "FECHA CONTABILIZACION";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(200, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "pendiente";
                    btfColumnaVisible.HeaderText = "PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);


                    string[] strLlaves = { "oficina", "operacion", "saldo_actual", "fecha_constitucion", 
                        "fecha_contabilizacion", "pendiente" };

                    gdvReporte.DataKeyNames = strLlaves;

                }
            }
            //Contratos
            else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
            {
                //Resumen consolidado de garantias por oficina cliente
                if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 1)
                {
                    gdvReporte.Columns.Clear();

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "fecha_corte";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "cod_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "avance";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "pendiente";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_garantias_completas";
                    btfColumnaVisible.HeaderText = "% AVANCE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(90, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_garantias_pendientes";
                    btfColumnaVisible.HeaderText = "% PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias";
                    btfColumnaVisible.HeaderText = "TOTAL GARANTIAS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias_completas";
                    btfColumnaVisible.HeaderText = "GARANTIAS COMPLETAS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(190, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_garantias_pendientes";
                    btfColumnaVisible.HeaderText = "GARANTIAS PENDIENTES";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(190, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    string[] strLlaves = {"fecha_corte", "cod_oficina", "des_oficina", "avance",
                    "pendiente", "oficina", "porcentaje_total_garantias_completas", "porcentaje_total_garantias_pendientes", 
                    "total_garantias", "total_garantias_completas", "total_garantias_pendientes"};

                    gdvReporte.DataKeyNames = strLlaves;

                }
                //Resumen consolidado de operaciones por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 2)
                {
                    gdvReporte.Columns.Clear();

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "fecha_corte";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "cod_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "des_oficina";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "avance";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    bnfColumnaInvisible = new BoundField();
                    bnfColumnaInvisible.DataField = "pendiente";
                    bnfColumnaInvisible.Visible = false;
                    gdvReporte.Columns.Add(bnfColumnaInvisible);

                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_contratos_completos";
                    btfColumnaVisible.HeaderText = "% AVANCE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(90, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "porcentaje_total_contratos_pendientes";
                    btfColumnaVisible.HeaderText = "% PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_contratos";
                    btfColumnaVisible.HeaderText = "TOTAL CONTRATOS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(170, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_contratos_completos";
                    btfColumnaVisible.HeaderText = "CONTRATOS COMPLETOS";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(210, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "total_contratos_pendientes";
                    btfColumnaVisible.HeaderText = "CONTRATOS PENDIENTES";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(210, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    string[] strLlaves = {"fecha_corte", "cod_oficina", "des_oficina", "avance",
                    "pendiente", "oficina", "porcentaje_total_contratos_completos", "porcentaje_total_contratos_pendientes", 
                    "total_contratos", "total_contratos_completos", "total_contratos_pendientes"};

                    gdvReporte.DataKeyNames = strLlaves;

                }
                //Detalle de garantías por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 3)
                {
                    gdvReporte.Columns.Clear();

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "contrato";
                    btfColumnaVisible.HeaderText = "CONTRATO";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(160, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "tipo_garantia";
                    btfColumnaVisible.HeaderText = "TIPO GARANTIA";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(180, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "garantia";
                    btfColumnaVisible.HeaderText = "GARANTIA";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(550, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "pendiente";
                    btfColumnaVisible.HeaderText = "PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);


                    string[] strLlaves = { "oficina", "contrato", "tipo_garantia", "garantia", "pendiente" };

                    gdvReporte.DataKeyNames = strLlaves;

                }
                //Detalle de operaciones por oficina cliente
                else if (int.Parse(cbTipoReporte.SelectedValue.ToString()) == 4)
                {
                    gdvReporte.Columns.Clear();

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "oficina";
                    btfColumnaVisible.HeaderText = "OFICINA CLIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(600, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "contrato";
                    btfColumnaVisible.HeaderText = "CONTRATO";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(160, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "fecha_constitucion";
                    btfColumnaVisible.HeaderText = "FECHA CONSTITUCION";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(200, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);

                    btfColumnaVisible = new ButtonField();
                    btfColumnaVisible.DataTextField = "pendiente";
                    btfColumnaVisible.HeaderText = "PENDIENTE";
                    btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                    btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
                    btfColumnaVisible.Visible = true;
                    gdvReporte.Columns.Add(btfColumnaVisible);


                    string[] strLlaves = { "oficina", "contrato", "fecha_constitucion", "pendiente" };

                    gdvReporte.DataKeyNames = strLlaves;
                }
            }
        }

        protected void gdvReporte_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //if (e.Row.RowType == DataControlRowType.DataRow)
            //{
            //    e.Row.Cells[1].Attributes.Add("class", "text");
            //}

        }

        #endregion

        #region Métodos Privados
        private void CargarDatos()
        {
            //			CargarFechas();
            CargarOficinas();
            txtFechaCorte.Text = DateTime.Now.ToShortDateString();
            txtFechaCorte.Enabled = false;
        }

        private void CargarFechas()
        {
            //			System.Data.DataSet dsDatos = new System.Data.DataSet();
            //			oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();			
            //			//OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("select distinct convert(varchar(10),fecha_corte,103) as fecha_corte from RPT_AVANCE_X_OFICINA_CLIENTE order by fecha_corte desc", oleDbConnection1);
            //			OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("select top 1 fecha_corte, convert(datetime,fecha_corte) as fecha from RPT_AVANCE_X_OFICINA_CLIENTE order by convert(datetime,fecha_corte) desc", oleDbConnection1);
            //			cmdConsulta.Fill(dsDatos, "Fechas");
            //			txtFechaCorte.DataSource = null;
            //			txtFechaCorte.DataSource = dsDatos.Tables["Fechas"].DefaultView;
            //			txtFechaCorte.DataValueField = "fecha_corte";
            //			txtFechaCorte.DataTextField = "fecha_corte";
            //			txtFechaCorte.DataBind();

        }

        private void CargarOficinas()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("select distinct cod_oficina, convert(varchar(3),cod_oficina) + ' - ' + des_oficina as des_oficina from dbo.RPT_AVANCE_X_OFICINA_CLIENTE UNION ALL select -1, '[TODAS LAS OFICINAS]' order by cod_oficina", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Oficinas");
            cbOficina.DataSource = null;
            cbOficina.DataSource = dsDatos.Tables["Oficinas"].DefaultView;
            cbOficina.DataValueField = "cod_oficina";
            cbOficina.DataTextField = "des_oficina";
            cbOficina.DataBind();

        }

        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid(int nTipoOperacion, int nTipoReporte)
        {
            try
            {
                SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString());
                SqlCommand oComando = null;

                if (nTipoReporte == 1)
                    oComando = new SqlCommand("pa_ConsultarAvanceXOficina", oConexion);
                else if (nTipoReporte == 2)
                    oComando = new SqlCommand("pa_ConsultarAvanceOperacionXOficina", oConexion);
                else if (nTipoReporte == 3)
                    oComando = new SqlCommand("pa_ConsultarDetalleAvanceXGarantia", oConexion);
                else if (nTipoReporte == 4)
                    oComando = new SqlCommand("pa_ConsultarDetalleAvanceXOperacion", oConexion);

                SqlDataAdapter oDataAdapter = new SqlDataAdapter();
                

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;

                //				if ((nTipoReporte == 1) || (nTipoReporte == 2))
                //					oComando.Parameters.AddWithValue("@dFechaCorte", txtFechaCorte.SelectedValue.ToString());
                if ((nTipoReporte == 1) || (nTipoReporte == 2))
                    oComando.Parameters.AddWithValue("@dFechaCorte", txtFechaCorte.Text.ToString());

                oComando.Parameters.AddWithValue("@nOficina", int.Parse(cbOficina.SelectedValue.ToString()));
                oComando.Parameters.AddWithValue("@nTipoRegistro", int.Parse(cbTipo.SelectedValue.ToString()));
                oComando.Parameters.AddWithValue("@nTipoOperacion", nTipoOperacion);

                //Abre la conexion
                oConexion.Open();
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(dsDatos, "Datos");

                gdvReporte.DataSource = dsDatos.Tables["Datos"].DefaultView;
                gdvReporte.DataBind();

                if ((nTipoReporte == 1) || (nTipoReporte == 2))
                {
                    if (dsDatos.Tables["Datos"].Rows.Count > 0)
                    {
                        lblAvance.Text = dsDatos.Tables["Datos"].Rows[0][9].ToString();
                        lblPendiente.Text = dsDatos.Tables["Datos"].Rows[0][10].ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void GenerarExcel(int nTipoOperacion, int nTipoReporte)
        {
            String sFilename = "";
            String sFilenameXML = "";
            SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString());
            SqlCommand oComando = null;
            SqlDataAdapter oDataAdapter = new SqlDataAdapter();

            string strRuta = ConfigurationManager.AppSettings["DOWNLOAD"].ToString();

            //sFilename = strRuta;

            if (nTipoReporte == 3)
            {
                sFilename = "DetalleXGarantia.xls";
                sFilenameXML = "DetalleXGarantia.xml";
            }
            else if (nTipoReporte == 4)
            {
                sFilename = "DetalleXOperacion.xls";
                sFilenameXML = "DetalleXOperacion.xls";
            }

            //			File.Delete(Page.MapPath(sFilename));
            //			StreamWriter sw = File.CreateText(Page.MapPath(sFilename));             
            //			String s = "";

            StreamWriter sw = null;
            String s = "";


            try
            {
                //File.Delete(Page.MapPath(sFilename));
                //sw = File.CreateText(Page.MapPath(sFilename));

                if (Directory.Exists(strRuta))
                {
                    FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRuta);
                    Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, strRuta + sFilename);
                }

                if (strRuta.Contains("\\"))
                {
                    if (strRuta.EndsWith("\\"))
                    {
                        strRuta += sFilename;
                    }
                    else
                    {
                        strRuta += "\\" + sFilename;
                    }
                }
                else if (strRuta.Contains("/"))
                {
                    if (strRuta.EndsWith("/"))
                    {
                        strRuta += sFilename;
                    }
                    else
                    {
                        strRuta += "/" + sFilename;
                    }
                }

                File.Delete(strRuta);
                sw = File.CreateText(strRuta);

                if (nTipoReporte == 3)
                    oComando = new SqlCommand("pa_ConsultarDetalleAvanceXGarantia", oConexion);
                else if (nTipoReporte == 4)
                    oComando = new SqlCommand("pa_ConsultarDetalleAvanceXOperacion", oConexion);

                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;

                oComando.Parameters.AddWithValue("@nOficina", int.Parse(cbOficina.SelectedValue.ToString()));
                oComando.Parameters.AddWithValue("@nTipoRegistro", int.Parse(cbTipo.SelectedValue.ToString()));
                oComando.Parameters.AddWithValue("@nTipoOperacion", nTipoOperacion);

                //Abre la conexion
                oConexion.Open();
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(dsDatos, "Datos");

                for (int i = 0; i < dsDatos.Tables["Datos"].Columns.Count; i++)
                    s = s + dsDatos.Tables["Datos"].Columns[i].ColumnName + "\t";

                sw.WriteLine(s.TrimEnd('\t'));
                s = "";

                for (int i = 0; i < dsDatos.Tables["Datos"].Rows.Count; i++)
                {
                    for (int j = 0; j < dsDatos.Tables["Datos"].Columns.Count; j++)
                        s = s + dsDatos.Tables["Datos"].Rows[i][j].ToString() + "\t";

                    sw.WriteLine(s.TrimEnd('\t'));
                    s = "";
                }

                sw.Close();

                this.EnableViewState = false;

                string TempPath = ConfigurationManager.AppSettings["DOWNLOAD"].ToString();
                string XMLPath = TempPath + "\\" + sFilenameXML; //temp path to store the XML file
                string XLSPath = TempPath + "\\" + sFilename;//temp path to store the XLS file


                
                byte[] Buffer = null;
                using (FileStream MyFileStream = new FileStream(XLSPath, FileMode.Open))
                {
                    long size;
                    size = MyFileStream.Length;
                    Buffer = new byte[size];
                    MyFileStream.Read(Buffer, 0, int.Parse(MyFileStream.Length.ToString()));
                    MyFileStream.Close();
                }
                
                Response.ContentType = "application/xls";
                string header = "attachment; filename=" + sFilename; ;
                Response.AddHeader("content-disposition", header);
                Response.BinaryWrite(Buffer);
                Response.Flush();
                Response.End();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                sw.Close();
                oConexion.Close();
            }
        }

        /// <summary>
        /// Método que se encarga de obtener los datos de la consulta que se quiere realizar
        /// </summary>
        private void ObtenerDatos()
        {
            int nTipoOperacion = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
            int nTipoReporte = int.Parse(cbTipoReporte.SelectedValue.ToString());

            SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString());
            SqlCommand oComando = null;

            if (nTipoReporte == 1)
                oComando = new SqlCommand("pa_ConsultarAvanceXOficina", oConexion);
            else if (nTipoReporte == 2)
                oComando = new SqlCommand("pa_ConsultarAvanceOperacionXOficina", oConexion);
            else if (nTipoReporte == 3)
                oComando = new SqlCommand("pa_ConsultarDetalleAvanceXGarantia", oConexion);
            else if (nTipoReporte == 4)
                oComando = new SqlCommand("pa_ConsultarDetalleAvanceXOperacion", oConexion);

            SqlDataAdapter oDataAdapter = new SqlDataAdapter();

            //declara las propiedades del comando
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.CommandTimeout = 120;

            if ((nTipoReporte == 1) || (nTipoReporte == 2))
                oComando.Parameters.AddWithValue("@dFechaCorte", txtFechaCorte.Text.ToString());

            oComando.Parameters.AddWithValue("@nOficina", int.Parse(cbOficina.SelectedValue.ToString()));
            oComando.Parameters.AddWithValue("@nTipoRegistro", int.Parse(cbTipo.SelectedValue.ToString()));
            oComando.Parameters.AddWithValue("@nTipoOperacion", nTipoOperacion);

            //Abre la conexion
            oConexion.Open();
            oDataAdapter.SelectCommand = oComando;
            oDataAdapter.SelectCommand.Connection = oConexion;
            oDataAdapter.Fill(dsDatos, "Datos");

        }
        #endregion

        
}
}
