using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using BCRGARANTIAS.Negocios;
using BCRGarantias.Contenedores;
using System.Drawing;
using System.IO;
using System.Security.Permissions;

public partial class Reportes_frmRptFiltroBitacora : BCR.Web.SystemFramework.PaginaPersistente
{
    #region Variables Globales
        protected DataSet dsBitacora = new DataSet();
        private string strNombreReporte = "Informacion de la Bitacora";
    #endregion

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        cbCodigoOperacion.AutoPostBack = true;
        txtCodigoUsuario.AutoPostBack = true;
        txtIP.AutoPostBack = true;
        txtFechaInicial.AutoPostBack = true;
        cbMantenimientos.AutoPostBack = true;

        btnConsultar.Click += new EventHandler(btnConsultar_Click);
        btnGenerarReporte.Click += new EventHandler(btnGenerarReporte_Click);
        cbCodigoOperacion.SelectedIndexChanged += new EventHandler(cbCodigoOperacion_SelectedIndexChanged);
        txtCodigoUsuario.TextChanged += new EventHandler(txtCodigoUsuario_TextChanged);
        txtIP.TextChanged += new EventHandler(txtIP_TextChanged);
        txtFechaInicial.TextChanged += new EventHandler(txtFechaInicial_TextChanged);
        cbMantenimientos.SelectedIndexChanged += new EventHandler(cbMantenimientos_SelectedIndexChanged);
        
    }

    //void btnExportar_Click(object sender, EventArgs e)
    //{
    //    String sFilename = "ConsultaBitacoraBCRGarantias.xls";

    //    StreamWriter sw = null;
    //    String s = "";

    //    DataTable dtDatos = new DataTable();

    //    string strRuta = ConfigurationManager.AppSettings["DOWNLOAD"].ToString();

    //    string[] straEncabezados = new string[9];

    //    for (int nIndice = 0; nIndice < straEncabezados.Length; nIndice++)
    //    {
    //        straEncabezados[nIndice] = string.Empty;
    //    }

    //    try
    //    {
    //        RealizarConsulta();

    //        if ((dsBitacora.Tables.Count > 0) && (dsBitacora.Tables[0].Rows.Count > 0))
    //        {
    //            if (Directory.Exists(strRuta))
    //            {
    //                FileIOPermission Directorio = new FileIOPermission(FileIOPermissionAccess.AllAccess, strRuta);
    //                Directorio.AddPathList(FileIOPermissionAccess.AllAccess | FileIOPermissionAccess.Write, strRuta + sFilename);
    //            }

    //            if (strRuta.Contains("\\"))
    //            {
    //                if (strRuta.EndsWith("\\"))
    //                {
    //                    strRuta += sFilename;
    //                }
    //                else
    //                {
    //                    strRuta += "\\" + sFilename;
    //                }
    //            }
    //            else if (strRuta.Contains("/"))
    //            {
    //                if (strRuta.EndsWith("/"))
    //                {
    //                    strRuta += sFilename;
    //                }
    //                else
    //                {
    //                    strRuta += "/" + sFilename;
    //                }
    //            }

    //            File.Delete(strRuta);
    //            sw = File.CreateText(strRuta);


    //            int nIndiceEncabezados = 0;
    //            for (int i = 0; i < gdvReporte.Columns.Count; i++)
    //                if (gdvReporte.Columns[i].Visible) 
    //                {
    //                    s += gdvReporte.Columns[i].HeaderText + "\t";

    //                    if (gdvReporte.Columns[i].GetType() == typeof(ButtonField))
    //                    {
    //                        ButtonField btnField = ((ButtonField)gdvReporte.Columns[i]);

    //                        straEncabezados[nIndiceEncabezados] = btnField.DataTextField;
    //                    }
    //                    else if (gdvReporte.Columns[i].GetType() == typeof(BoundField))
    //                    {
    //                        BoundField bndField = ((BoundField)gdvReporte.Columns[i]);

    //                        straEncabezados[nIndiceEncabezados] = bndField.DataField;
    //                    }

    //                    nIndiceEncabezados++;

    //                    dtDatos.Columns.Add(new DataColumn(gdvReporte.Columns[i].HeaderText, Type.GetType("System.String")));
    //                }

    //            sw.WriteLine(s.TrimEnd('\t'));
    //            s = "";

    //            DataRow dr = dtDatos.NewRow();

    //            for (int nIndiceFilas = 0; nIndiceFilas < dsBitacora.Tables[0].Rows.Count; nIndiceFilas++)
    //            {

    //                for (int nIndiceEncab = 0; nIndiceEncab < straEncabezados.Length; nIndiceEncab++)
    //                {
    //                    for (int nIndiceCol = 0; nIndiceCol < dsBitacora.Tables[0].Columns.Count; nIndiceCol++)
    //                    {
    //                        if (dsBitacora.Tables[0].Columns[nIndiceCol].ColumnName.CompareTo(straEncabezados[nIndiceEncab].ToString()) == 0)
    //                        {
    //                            s += dsBitacora.Tables[0].Rows[nIndiceFilas][nIndiceCol].ToString() + "\t";

    //                            dr[nIndiceEncab] = dsBitacora.Tables[0].Rows[nIndiceFilas][nIndiceCol].ToString();

    //                        }
    //                    }

    //                }
    //                dtDatos.Rows.Add(dr);
    //                dr.AcceptChanges();
    //                dtDatos.AcceptChanges();
    //                sw.WriteLine(s.TrimEnd('\t'));
    //                s = string.Empty;
    //                dr = dtDatos.NewRow();
    //            }

    //            sw.Close();

    //            HttpResponse response = HttpContext.Current.Response;

    //            response.Clear();
    //            response.Charset = "";

    //            response.ContentType = "application/vnd.ms-excel";
    //            response.AddHeader("Content-Disposition", "attachment;filename=\"" + sFilename + "\"");

    //            using (StringWriter sw1 = new StringWriter())
    //            {
    //                using (HtmlTextWriter htw = new HtmlTextWriter(sw1))
    //                {
    //                    GridView dg = new GridView();
    //                    dg.DataSource = dtDatos;//ds.Tables[0];
    //                    dg.DataBind();
    //                    dg.RenderControl(htw);
    //                    response.Write(sw1.ToString());
    //                    response.End();
    //                }
    //            }
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        throw new Exception(ex.Message);
    //    }
    //    finally
    //    {
    //        sw.Close();
    //    }
    //}

    //void btnExportar_Click(object sender, EventArgs e)
    //{

    //    rptBitacora = new ReportDocument();
    //    string reportPath = Server.MapPath("rptBitacora.rpt");

    //    string strRutaEsquema = Server.MapPath("DataSetBitacora.xsd");

    //    try
    //    {

    //        dsBitacora.ReadXmlSchema(strRutaEsquema);

    //        RealizarConsulta();

    //        if ((dsBitacora != null) && (dsBitacora.Tables.Count > 0) && (dsBitacora.Tables[0].Rows.Count > 0))
    //        {

    //            dsBitacora.Tables[0].TableName = "Datos";

    //            if ((!dsBitacora.Tables["Datos"].Columns.Contains("fecha_corte"))
    //                && (!dsBitacora.Tables["Datos"].Columns.Contains("num_registro")))
    //            {
    //                DataTable dtBitacora = new DataTable();
    //                dtBitacora = dsBitacora.Tables["Datos"];

    //                DataColumn dcFechaCorte = new DataColumn("fecha_corte");
    //                dcFechaCorte.DataType = System.Type.GetType("System.String");
    //                dcFechaCorte.AllowDBNull = false;

    //                dtBitacora.Columns.Add(dcFechaCorte);
    //                dtBitacora.AcceptChanges();
    //                dsBitacora.AcceptChanges();

    //                DataColumn dcNumRegistro = new DataColumn("num_registro");
    //                dcNumRegistro.DataType = System.Type.GetType("System.String");
    //                dcNumRegistro.AllowDBNull = true;

    //                dtBitacora.Columns.Add(dcNumRegistro);
    //                dtBitacora.AcceptChanges();
    //                dsBitacora.AcceptChanges();

    //                DataRow[] adrBitacora = dsBitacora.Tables["Datos"].Select(ContenedorBitacora.FECHA_HORA + " = " + ContenedorBitacora.FECHA_HORA, ContenedorBitacora.FECHA_HORA + " DESC");

    //                if (adrBitacora.Length > 0)
    //                {
    //                    int nRegistro = 1;
    //                    foreach (DataRow drBitacora in adrBitacora)
    //                    {
    //                        drBitacora["fecha_corte"] = (Convert.ToDateTime(adrBitacora[0]["fecha_hora"].ToString())).ToShortDateString();
    //                    }

    //                    foreach (DataRow drBitacora in adrBitacora)
    //                    {
    //                        drBitacora["num_registro"] = nRegistro.ToString();
    //                        nRegistro += 1;
    //                    }

    //                    dsBitacora.AcceptChanges();
    //                }
    //            }

    //            lblMensaje.Text = dsBitacora.Tables["Datos"].Rows[dsBitacora.Tables["Datos"].Rows.Count - 1]["num_registro"].ToString();
    //            rptBitacora.Load(reportPath);

    //            rptBitacora.SetDataSource(dsBitacora);
    //            rptBitacora.SetDataSource(dsBitacora);


    //            //Se crea el documento de lectura y escritura
    //            System.IO.MemoryStream rptStream = new System.IO.MemoryStream();
    //            //Se envia el reporte al stream y le indicamos el metodo de escritura o tipo de documento
    //            rptStream = (System.IO.MemoryStream)rptBitacora.ExportToStream((CrystalDecisions.Shared.ExportFormatType)int.Parse(cbFormato.SelectedValue));
    //            //Rel.ExportToStream((CrystalDecisions.Shared.ExportFormatType)int.Parse(cbFormato.SelectedValue));

    //            //Limpiamos la memoria
    //            Response.Clear();
    //            Response.Buffer = true;

    //            //Le indicamos el tipo de documento que vamos a exportar
    //            Response.ContentType = FormatoDocumento();

    //            //Automaticamente se descarga el archivo
    //            Response.AddHeader("Content-Disposition", "attachment;filename=" + this.strNombreReporte);

    //            //Se escribe el archivo
    //            Response.BinaryWrite(rptStream.ToArray());
    //            Response.End();
    //        }
    //    }
    //    catch (Exception exError)
    //    {
    //        Response.Redirect("~/frmMensaje.aspx?" +
    //                   "bError=1" +
    //                   "&strTitulo=" + "Problemas Cargando Página" +
    //                   "&strMensaje=" + exError.Message +
    //                   "&bBotonVisible=0");
    //    }
    //}

    void txtFechaInicial_TextChanged(object sender, EventArgs e)
    {
        if ((cbCodigoOperacion.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }

        if ((cbMantenimientos.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }
    }

    void txtIP_TextChanged(object sender, EventArgs e)
    {
        if ((cbCodigoOperacion.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }
        if ((cbMantenimientos.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }
    }

    void txtCodigoUsuario_TextChanged(object sender, EventArgs e)
    {
        if ((cbCodigoOperacion.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }

        if ((cbMantenimientos.SelectedValue.CompareTo("-1") != 0) && (!btnGenerarReporte.Enabled))
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }
    }

    protected void cbCodigoOperacion_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList cbOperacion = ((DropDownList) sender);

        if (cbOperacion.SelectedValue.CompareTo("-1") != 0)
        {
            if ((txtCodigoUsuario.Text != string.Empty) || (txtIP.Text != string.Empty)
            || (txtFechaInicial.Text != string.Empty))
            {
                btnGenerarReporte.Enabled = true;
                lblMensaje.Text = string.Empty;
            }
            else
            {
                lblMensaje.Text = "Este filtro debería ser acompañado de algún otro para generar el reporte";
                btnGenerarReporte.Enabled = false;
            }
        }
        else
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }
    }

    protected void cbMantenimientos_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList cbMantenimiento = ((DropDownList)sender);

        if (cbMantenimiento.SelectedValue.CompareTo("-1") != 0)
        {
            if ((txtCodigoUsuario.Text != string.Empty) || (txtIP.Text != string.Empty)
            || (txtFechaInicial.Text != string.Empty))
            {
                btnGenerarReporte.Enabled = true;
                lblMensaje.Text = string.Empty;
            }
            else
            {
                lblMensaje.Text = "Este filtro debería ser acompañado de algún otro para generar el reporte";
                btnGenerarReporte.Enabled = false;
            }
        }
        else
        {
            btnGenerarReporte.Enabled = true;
            lblMensaje.Text = string.Empty;
        }

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_REPORTE_TRANSACCIONES_BITACORA"].ToString())))
                {
                    //rblTiposFiltro.SelectedIndex = 0;
                    txtCodigoUsuario.Visible = true;
                    txtCodigoUsuario.Focus();
                    ScriptManager1.SetFocus(txtCodigoUsuario);
                    Session.Remove("bGridCargado");
                    Session.Remove("OrdenarPor");

                }
                else
                {
                    //El usuario no tiene acceso a esta página
                    throw new Exception("ACCESO DENEGADO");
                }
            }
            catch (Exception ex)
            {
                string strRutaActual = HttpContext.Current.Request.Path.Substring(0,HttpContext.Current.Request.Path.LastIndexOf("/"));

                strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Reportes"));

                if (ex.Message.StartsWith("ACCESO DENEGADO"))
                {
                    Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Acceso Denegado" +
                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                        "&bBotonVisible=0");
                }
                else
                {
                    Response.Redirect(strRutaActual + "/frmMensaje.aspx?" + 
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Página" +
                        "&strMensaje=" + ex.Message +
                        "&bBotonVisible=0");
                }
            }
        }
    }
          
    //protected void rblTiposFiltro_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    //RadioButtonList rblTiposFiltro = ((RadioButtonList)sender);

    //    //if (rblTiposFiltro.SelectedValue.CompareTo("0") == 0)
    //    //{
    //    //    txtCodigoUsuario.Text = string.Empty;
    //    //    txtCodigoUsuario.Visible = true;
    //    //    ScriptManager1.SetFocus(txtCodigoUsuario);
    //    //    txtIP.Visible = false;
    //    //    txtFechaInicialF.Visible = false;
    //    //    txtFechaFinalF.Visible = false;
    //    //    igbFIF.Visible = false;
    //    //    igbFFF.Visible = false;
    //    //    cbCodigoOperacion.Visible = false;
    //    //    lblDatoSolicitado.Text = "Código de Usuario:";
    //    //    lblEntreFechasF.Visible = false;
    //    //    lblDatoSolicitado.Visible = true;
    //    //    igbCalendarioInicial.Visible = true;
    //    //    igbCalendarioFinal.Visible = true;
    //    //    lblDatoSolicitadoFecha.Visible = true;
    //    //}
    //    //else if (rblTiposFiltro.SelectedValue.CompareTo("1") == 0)
    //    //{
    //    //    txtCodigoUsuario.Text = string.Empty;
    //    //    txtCodigoUsuario.Visible = false;
    //    //    txtIP.Visible = true;
    //    //    ScriptManager1.SetFocus(txtIP);
    //    //    txtIP.Text = string.Empty;
    //    //    txtFechaInicialF.Visible = false;
    //    //    txtFechaFinalF.Visible = false;
    //    //    igbFIF.Visible = false;
    //    //    igbFFF.Visible = false;
    //    //    cbCodigoOperacion.Visible = false;
    //    //    lblDatoSolicitado.Text = "Número de IP:";
    //    //    lblEntreFechasF.Visible = false;
    //    //    lblDatoSolicitado.Visible = true;
    //    //    igbCalendarioInicial.Visible = true;
    //    //    igbCalendarioFinal.Visible = true;
    //    //    lblDatoSolicitadoFecha.Visible = true;
    //    //}
    //    //else if (rblTiposFiltro.SelectedValue.CompareTo("2") == 0)
    //    //{
    //    //    txtCodigoUsuario.Text = string.Empty;
    //    //    txtCodigoUsuario.Visible = false;
    //    //    txtIP.Visible = false;
    //    //    txtIP.Text = string.Empty;
    //    //    txtFechaInicial.Text = string.Empty;
    //    //    txtFechaFinal.Text = string.Empty;
    //    //    //txtFechaInicialF.Visible = false;
    //    //    //txtFechaFinalF.Visible = false;
    //    //    //igbFIF.Visible = false;
    //    //    //igbFFF.Visible = false;
    //    //    cbCodigoOperacion.Visible = true;
    //    //    ScriptManager1.SetFocus(cbCodigoOperacion);
    //    //    cbCodigoOperacion.SelectedIndex = 0;
    //    //    lblDatoSolicitado.Text = "Código de Operación:";
    //    //    //lblEntreFechasF.Visible = false;
    //    //    lblDatoSolicitado.Visible = true;
    //    //    igbCalendarioInicial.Visible = true;
    //    //    igbCalendarioFinal.Visible = true;
    //    //    lblDatoSolicitadoFecha.Visible = true;
    //    //}
    //    //else if (rblTiposFiltro.SelectedValue.CompareTo("3") == 0)
    //    //{
    //    //    txtCodigoUsuario.Text = string.Empty;
    //    //    txtCodigoUsuario.Visible = false;
    //    //    txtIP.Visible = false;
    //    //    txtIP.Text = string.Empty;
    //    //    txtFechaInicialF.Text = string.Empty; //DateTime.Now.ToShortDateString();
    //    //    txtFechaFinalF.Text = string.Empty; //DateTime.Now.ToShortDateString();
    //    //    txtFechaInicialF.Visible = true;
    //    //    ScriptManager1.SetFocus(txtFechaInicial);
    //    //    txtFechaFinalF.Visible = true;
    //    //    igbCalendarioInicial.Visible = false;
    //    //    igbCalendarioFinal.Visible = false;
    //    //    cbCodigoOperacion.Visible = false;
    //    //    lblDatoSolicitado.Text = "Fecha Desde:";
    //    //    lblEntreFechasF.Visible = true;
    //    //    lblDatoSolicitado.Visible = true;
    //    //    txtFechaInicial.Visible = false;
    //    //    txtFechaFinal.Visible = false;
    //    //    igbFIF.Visible = true;
    //    //    igbFFF.Visible = true;
    //    //    lblDatoSolicitadoFecha.Visible = false;
    //    //}

    //}

    void btnConsultar_Click(object sender, EventArgs e)
    {
        this.gdvReporte.Visible = true;
        CargarGrid();
    }

    void btnGenerarReporte_Click(object sender, EventArgs e)
    {
        //CrearNuevoDataSet();

        //Session["dsDatos"] = dsBitacora;
        //Session["OrdenarPor"] = cbCriterioOrden.SelectedValue;

        //Response.Redirect("frmReporteBitacora.aspx", false);
        this.gdvReporte.Visible = true;
        cargaConsulta();
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
                case ("SelectedPistaAuditoria"):
                    rowIndex = (int.Parse(e.CommandArgument.ToString()));

                    gdvReporte.SelectedIndex = rowIndex;

                    if ((gdvReporte.SelectedDataKey[0].ToString() != null) && (gdvReporte.SelectedDataKey[0].ToString() != string.Empty))
                    {
                        lblTablaObt.Text = gdvReporte.SelectedDataKey[0].ToString();
                        lblTablaObt.Visible = true;
                        lblTabla.Visible = true;
                    }
                    else
                    {
                        lblTablaObt.Text = "El registro no posee este dato";
                        lblTablaObt.Visible = false;
                        lblTabla.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[1].ToString() != null) && (gdvReporte.SelectedDataKey[1].ToString() != string.Empty))
                    {
                        lblUsuarioObt.Text = gdvReporte.SelectedDataKey[1].ToString();
                        lblUsuarioObt.Visible = true;
                        lblUsuario.Visible = true;
                    }
                    else
                    {
                        lblUsuarioObt.Text = "El registro no posee este dato";
                        lblUsuarioObt.Visible = false;
                        lblUsuario.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[2].ToString() != null) && (gdvReporte.SelectedDataKey[2].ToString() != string.Empty))
                    {
                        lblIPObt.Text = gdvReporte.SelectedDataKey[2].ToString();
                        lblIPObt.Visible = true;
                        lblIP.Visible = true;
                    }
                    else
                    {
                        lblIPObt.Text = "El registro no posee este dato";
                        lblIPObt.Visible = false;
                        lblIP.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[4].ToString() != null)  && (gdvReporte.SelectedDataKey[4].ToString() != string.Empty)) 
                    {
                        lblOperacionObt.Text = gdvReporte.SelectedDataKey[4].ToString();
                        lblOperacionObt.Visible = true;
                        lblOperacion.Visible = true;
                    }
                    else
                    {
                        lblOperacionObt.Text = "El registro no posee este dato";
                        lblOperacionObt.Visible = false;
                        lblOperacion.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[5].ToString() != null)  && (gdvReporte.SelectedDataKey[5].ToString() != string.Empty))
                    {
                        lblFechaObt.Text = gdvReporte.SelectedDataKey[5].ToString();
                        lblFechaObt.Visible = true;
                        lblFecha.Visible = true;
                    }
                    else
                    {
                        lblFechaObt.Text = "El registro no posee este dato";
                        lblFechaObt.Visible = false;
                        lblFecha.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[7].ToString() != null)  && (gdvReporte.SelectedDataKey[7].ToString() != string.Empty))
                    {
                        lblTipoGarantiaObt.Text = gdvReporte.SelectedDataKey[7].ToString();
                        lblTipoGarantiaObt.Visible = true;
                        lblTipoGarantia.Visible = true;
                    }
                    else
                    {
                        lblTipoGarantiaObt.Text = "El registro no posee este dato";
                        lblTipoGarantiaObt.Visible = false;
                        lblTipoGarantia.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[8].ToString() != null)  && (gdvReporte.SelectedDataKey[8].ToString() != string.Empty))
                    {
                        lblGarantiaObt.Text = gdvReporte.SelectedDataKey[8].ToString();
                        lblGarantiaObt.Visible = true;
                        lblGarantia.Visible = true;
                    }
                    else
                    {
                        lblGarantiaObt.Text = "El registro no posee este dato";
                        lblGarantiaObt.Visible = false;
                        lblGarantia.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[9].ToString() != null)  && (gdvReporte.SelectedDataKey[9].ToString() != string.Empty))
                    {
                        lblOperacionCrediticiaObt.Text = gdvReporte.SelectedDataKey[9].ToString();
                        lblOperacionCrediticiaObt.Visible = true;
                        lblOperacionCrediticia.Visible = true;
                    }
                    else
                    {
                        lblOperacionCrediticiaObt.Text = "El registro no posee este dato";
                        lblOperacionCrediticiaObt.Visible = false;
                        lblOperacionCrediticia.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[10].ToString() != null)  && (gdvReporte.SelectedDataKey[10].ToString() != string.Empty))
                    {
                        lblCampoAfectadoObt.Text = gdvReporte.SelectedDataKey[10].ToString();
                        lblCampoAfectadoObt.Visible = true;
                        lblCampoAfectado.Visible = true;
                    }
                    else
                    {
                        lblCampoAfectadoObt.Text = "El registro no posee este dato";
                        lblCampoAfectadoObt.Visible = false;
                        lblCampoAfectado.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[11].ToString() != null)  && (gdvReporte.SelectedDataKey[11].ToString() != string.Empty))
                    {
                        lblEstadoAnteriorObt.Text = gdvReporte.SelectedDataKey[11].ToString();
                        lblEstadoAnteriorObt.Visible = true;
                        lblEstadoAnterior.Visible = true;
                    }
                    else
                    {
                        lblEstadoAnteriorObt.Text = "El registro no posee este dato";
                        lblEstadoAnteriorObt.Visible = false;
                        lblEstadoAnterior.Visible = false;
                    }

                    if ((gdvReporte.SelectedDataKey[12].ToString() != null)  && (gdvReporte.SelectedDataKey[12].ToString() != string.Empty))
                    {
                        lblEstadoActualObt.Text = gdvReporte.SelectedDataKey[12].ToString();
                        lblEstadoActualObt.Visible = true;
                        lblEstadoActual.Visible = true;
                    }
                    else
                    {
                        lblEstadoActualObt.Text = "El registro no posee este dato";
                        lblEstadoActualObt.Visible = false;
                        lblEstadoActual.Visible = false;
                    }

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
        CargarGrid();
    }

    protected void gdvReporte_DataBinding(object sender, EventArgs e)
    {
        //GridView gdvReporte = ((GridView)sender);

        //BoundField bnfColumnaInvisible = new BoundField();
        //BoundField bnfColumnaVisible = new BoundField();
        //ButtonField btfColumnaVisible = new ButtonField();

        //gdvReporte.Columns.Clear();

        //btfColumnaVisible.DataTextField = "cod_usuario";
        //btfColumnaVisible.CommandName = "SelectedPistaAuditoria";
        //btfColumnaVisible.HeaderText = "Usuario";
        //btfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //btfColumnaVisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(btfColumnaVisible);

        //bnfColumnaInvisible = new BoundField();
        //bnfColumnaInvisible.DataField = "cod_ip";
        //bnfColumnaInvisible.Visible = false;
        ////bnfColumnaInvisible.HeaderText = "IP";
        ////bnfColumnaInvisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        ////bnfColumnaInvisible.ItemStyle.Width = new Unit(120, UnitType.Pixel);
        //gdvReporte.Columns.Add(bnfColumnaInvisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "fecha_hora";
        //bnfColumnaVisible.HeaderText = "Fecha";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(300, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaInvisible = new BoundField();
        //bnfColumnaInvisible.DataField = "cod_operacion";
        //bnfColumnaInvisible.Visible = false;
        ////bnfColumnaInvisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        ////bnfColumnaInvisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //gdvReporte.Columns.Add(bnfColumnaInvisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "des_operacion";
        //bnfColumnaVisible.HeaderText = "Operación Realizada";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(80, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "cod_operacion_crediticia";
        //bnfColumnaVisible.HeaderText = "Operación Crediticia";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaInvisible = new BoundField();
        //bnfColumnaInvisible.DataField = "cod_tipo_garantia";
        //bnfColumnaInvisible.Visible = false;
        //gdvReporte.Columns.Add(bnfColumnaInvisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "des_tipo_garantia";
        //bnfColumnaVisible.HeaderText = "Tipo Garantía";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(190, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "cod_garantia";
        //bnfColumnaVisible.HeaderText = "Garantía";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(50, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaInvisible = new BoundField();
        //bnfColumnaInvisible.DataField = "des_tabla";
        //bnfColumnaInvisible.Visible = false;
        ////bnfColumnaInvisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        ////bnfColumnaInvisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //gdvReporte.Columns.Add(bnfColumnaInvisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "des_campo_afectado";
        //bnfColumnaVisible.HeaderText = "Campo Afectado";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "est_anterior_campo_afectado";
        //bnfColumnaVisible.HeaderText = "Estado Anterior";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        //bnfColumnaVisible = new BoundField();
        //bnfColumnaVisible.DataField = "est_actual_campo_afectado";
        //bnfColumnaVisible.HeaderText = "Estado Actual";
        //bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        //bnfColumnaVisible.ItemStyle.Width = new Unit(150, UnitType.Pixel);
        //btfColumnaVisible.ItemStyle.BorderColor = Color.Black;
        //btfColumnaVisible.HeaderStyle.BorderColor = Color.Black;
        //gdvReporte.Columns.Add(bnfColumnaVisible);

        
        ////bnfColumnaVisible = new ButtonField();
        ////bnfColumnaVisible.DataField = "cod_consulta";
        ////bnfColumnaVisible.HeaderText = "I Consulta";
        ////bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        ////bnfColumnaVisible.ItemStyle.Width = new Unit(800, UnitType.Pixel);
        ////gdvReporte.Columns.Add(bnfColumnaVisible);

        ////bnfColumnaVisible = new ButtonField();
        ////bnfColumnaVisible.DataField = "cod_consulta2";
        ////bnfColumnaVisible.HeaderText = "II Consulta";
        ////bnfColumnaVisible.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
        ////bnfColumnaVisible.ItemStyle.Width = new Unit(800, UnitType.Pixel);
        ////gdvReporte.Columns.Add(bnfColumnaVisible);
        
    }

    #endregion

    #region Métodos Privados

    /// <summary>
    /// Método que se encarga de realizar la consulta solicitada
    /// </summary>
    private void RealizarConsulta()
    {
        Bitacora oBitacora = new Bitacora();

        lblMensaje.Text = string.Empty;

        bool bProseguir = true;

        if ((txtFechaInicial.Text != string.Empty) && (txtFechaFinal.Text != string.Empty))
        {
            DateTime dFI = new DateTime();
            DateTime dFF = new DateTime();

            if ((DateTime.TryParse(txtFechaInicial.Text, out dFI)) && (DateTime.TryParse(txtFechaFinal.Text, out dFF)))
            {
                if (!ValidarFechas(dFI, dFF))
                {
                    bProseguir = false;
                }
            }
            else
            {
                lblMensaje.Text = "Valor ingresado erroneo o formato de fecha incorrecto: dd/mm/aaaa";
                bProseguir = false;
            }
        }


        if (bProseguir)
        {
            if ((cbCodigoOperacion.SelectedValue.CompareTo("-1") != 0) || (cbMantenimientos.SelectedValue.CompareTo("-1") != 0))
            {
                if ((cbCodigoOperacion.SelectedValue.CompareTo("-1") != 0) && (cbMantenimientos.SelectedValue.CompareTo("-1") != 0))
                {
                    if ((txtCodigoUsuario.Text != string.Empty) || (txtIP.Text != string.Empty)
                      || ((txtFechaInicial.Text != string.Empty) && (txtFechaFinal.Text != string.Empty)))
                    {

                        dsBitacora = oBitacora.GenerarConsultaBD(txtCodigoUsuario.Text, txtIP.Text,
                            cbCodigoOperacion.SelectedValue, txtFechaInicial.Text, txtFechaFinal.Text,
                            Convert.ToInt32(cbMantenimientos.SelectedValue), cbCriterioOrden.SelectedValue);
                        lblMensaje.Text = string.Empty;
                        btnGenerarReporte.Enabled = true;

                    }
                    else
                    {

                        lblMensaje.Text = "Estos filtros deberían ser acompañados de algún otro para generar el reporte";
                        btnGenerarReporte.Enabled = false;
                        dsBitacora = oBitacora.GenerarConsultaBD(txtCodigoUsuario.Text, txtIP.Text,
                            cbCodigoOperacion.SelectedValue, txtFechaInicial.Text, txtFechaFinal.Text,
                            Convert.ToInt32(cbMantenimientos.SelectedValue), cbCriterioOrden.SelectedValue);
                    }
                }
                else
                {
                    if ((txtCodigoUsuario.Text != string.Empty) || (txtIP.Text != string.Empty)
                      || ((txtFechaInicial.Text != string.Empty) && (txtFechaFinal.Text != string.Empty)))
                    {
                        dsBitacora = oBitacora.GenerarConsultaBD(txtCodigoUsuario.Text, txtIP.Text,
                            cbCodigoOperacion.SelectedValue, txtFechaInicial.Text, txtFechaFinal.Text,
                            Convert.ToInt32(cbMantenimientos.SelectedValue), cbCriterioOrden.SelectedValue);
                        lblMensaje.Text = string.Empty;
                        btnGenerarReporte.Enabled = true;
                    }
                    else
                    {
                        lblMensaje.Text = "Este filtro debería ser acompañado de algún otro para generar el reporte";
                        btnGenerarReporte.Enabled = false;

                        dsBitacora = oBitacora.GenerarConsultaBD(txtCodigoUsuario.Text, txtIP.Text,
                            cbCodigoOperacion.SelectedValue, txtFechaInicial.Text, txtFechaFinal.Text,
                            Convert.ToInt32(cbMantenimientos.SelectedValue), cbCriterioOrden.SelectedValue);
                    }
                }
            }
            else
            {
                dsBitacora = oBitacora.GenerarConsultaBD(txtCodigoUsuario.Text, txtIP.Text,
                    cbCodigoOperacion.SelectedValue, txtFechaInicial.Text, txtFechaFinal.Text,
                    Convert.ToInt32(cbMantenimientos.SelectedValue), cbCriterioOrden.SelectedValue);
                lblMensaje.Text = string.Empty;
                btnGenerarReporte.Enabled = true;
            }
        }

        if (dsBitacora == null)
        {
            if ((txtCodigoUsuario.Text == string.Empty) && (txtIP.Text == string.Empty)
              && ((txtFechaInicial.Text == string.Empty) && (txtFechaFinal.Text == string.Empty))
              && (cbMantenimientos.SelectedValue.CompareTo("-1") == 0) && (cbCodigoOperacion.SelectedValue.CompareTo("-1") == 0))
            {
                lblMensaje.Text = "Debe proveer almenos un filtro";
            }

            dsBitacora = new DataSet();
            dsBitacora.Tables.Add(CrearEstructuraDataSet());
        }
       
    }

    /// <summary>
    /// Método que se encarga de cargar el GridView con la información recopilada
    /// </summary>
    private void CargarGrid()
    {

        this.gdvReporte.DataSource = null;
        this.gdvReporte.DataBind();

        RealizarConsulta();

        //AgregarNuevaColumnaDataSet();

        if ((dsBitacora != null) && (dsBitacora.Tables.Count > 0) && (dsBitacora.Tables[0].Rows.Count > 0))
        {
            if ((!dsBitacora.Tables[0].Rows[0].IsNull("cod_usuario")) &&
                (!dsBitacora.Tables[0].Rows[0].IsNull("cod_ip")) &&
                (!dsBitacora.Tables[0].Rows[0].IsNull("fecha_hora")) &&
                (!dsBitacora.Tables[0].Rows[0].IsNull("cod_operacion")))
            {
                this.gdvReporte.DataSource = dsBitacora.Tables[0].DefaultView;
                this.gdvReporte.DataBind();
                //Session["bGridCargado"] = true;
            }
            else
            {
                dsBitacora.Tables[0].Rows.Add(dsBitacora.Tables[0].NewRow());
                this.gdvReporte.DataSource = dsBitacora;
                this.gdvReporte.DataBind();

                int TotalColumns = this.gdvReporte.Rows[0].Cells.Count;
                this.gdvReporte.Rows[0].Cells.Clear();
                this.gdvReporte.Rows[0].Cells.Add(new TableCell());
                this.gdvReporte.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                this.gdvReporte.Rows[0].Cells[0].Text = "No existen registros";
            }
        }
        else
        {
            dsBitacora.Tables[0].Rows.Add(dsBitacora.Tables[0].NewRow());
            this.gdvReporte.DataSource = dsBitacora;
            this.gdvReporte.DataBind();

            int TotalColumns = this.gdvReporte.Rows[0].Cells.Count;
            this.gdvReporte.Rows[0].Cells.Clear();
            this.gdvReporte.Rows[0].Cells.Add(new TableCell());
            this.gdvReporte.Rows[0].Cells[0].ColumnSpan = TotalColumns;
            this.gdvReporte.Rows[0].Cells[0].Text = "No existen registros";
        }
    }

    /// <summary>
    /// Método que crea un nuevo dataset, esto para utilizarlo en el reporte
    /// </summary>
    private void CrearNuevoDataSet()
    {

        DataTable dtBitacoraNuevo = new DataTable("Datos");

        string[] arrDatos = { "cod_usuario", "cod_ip", "cod_operacion", "des_operacion",
            "des_tabla", "des_campo_afectado", "est_anterior_campo_afectado", 
            "est_actual_campo_afectado", "cod_tipo_garantia", "cod_garantia", "cod_operacion_crediticia"};


        foreach (string strDato in arrDatos)
        {

            DataColumn dcDato = new DataColumn(strDato);
            dcDato.DataType = System.Type.GetType("System.String");
            dcDato.AllowDBNull = true;

            dtBitacoraNuevo.Columns.Add(dcDato);
            dtBitacoraNuevo.AcceptChanges();
        }

        DataColumn dcDatos = new DataColumn("fecha_hora");
        dcDatos.DataType = System.Type.GetType("System.DateTime");
        dcDatos.AllowDBNull = true;

        dtBitacoraNuevo.Columns.Add(dcDatos);
        dtBitacoraNuevo.AcceptChanges();

        if ((dsBitacora == null) || (dsBitacora.Tables.Count == 0) || (dsBitacora.Tables[0].Rows.Count == 0))
        {
            RealizarConsulta();
        }

        dsBitacora.Tables[0].TableName = "Datos";

        foreach (DataRow drBitacora in dsBitacora.Tables["Datos"].Rows)
        {
            DataRow drDatoNuevo = dtBitacoraNuevo.NewRow();

            for (int nIndice = 0; nIndice < drBitacora.Table.Columns.Count; nIndice++)
            {
                if (drBitacora.Table.Columns[nIndice].ColumnName.CompareTo("cod_operacion") == 0)
                {
                    int nTipoOperacion = Convert.ToInt32(drBitacora["cod_operacion"].ToString());

                    switch (nTipoOperacion)
                    {
                        case 1: drDatoNuevo["des_operacion"] = "INS";
                            break;

                        case 2: drDatoNuevo["des_operacion"] = "MOD";
                            break;

                        case 3: drDatoNuevo["des_operacion"] = "BOR";
                            break;

                        default: drDatoNuevo["des_operacion"] = "-";
                            break;
                    }
                }
                else if (drBitacora.Table.Columns[nIndice].ColumnName.CompareTo("cod_tipo_garantia") == 0)
                {
                    if (drBitacora.Table.Columns[nIndice] != null)
                    {
                        int nTipoGarantia = -1;

                        if (drBitacora["cod_tipo_garantia"].ToString() != string.Empty)
                        {
                            nTipoGarantia = Convert.ToInt32(drBitacora["cod_tipo_garantia"].ToString());
                        }

                        switch (nTipoGarantia)
                        {
                            case 1: drDatoNuevo["cod_tipo_garantia"] = "Fiduciaria";
                                break;

                            case 2: drDatoNuevo["cod_tipo_garantia"] = "Real";
                                break;

                            case 3: drDatoNuevo["cod_tipo_garantia"] = "Valor";
                                break;

                            default: drDatoNuevo["cod_tipo_garantia"] = "-";
                                break;
                        }

                    }
                } 
                else if (drBitacora.Table.Columns[nIndice].ColumnName.CompareTo("fecha_hora") == 0)
                {
                    drDatoNuevo["fecha_hora"] = Convert.ToDateTime(drBitacora[nIndice, DataRowVersion.Current].ToString());
                }
                else
                {
                    if ((drBitacora[nIndice] == null) || (drBitacora[nIndice, DataRowVersion.Current].ToString().CompareTo("NULL") == 0)
                       || (drBitacora[nIndice, DataRowVersion.Current].ToString() == string.Empty))
                    {
                        if (drDatoNuevo.Table.Columns.Contains(drBitacora.Table.Columns[nIndice].ColumnName))
                        {
                            drDatoNuevo[drBitacora.Table.Columns[nIndice].ColumnName] = "-";
                        }
                    }
                    else
                    {
                        if (drDatoNuevo.Table.Columns.Contains(drBitacora.Table.Columns[nIndice].ColumnName))
                        {
                            drDatoNuevo[drBitacora.Table.Columns[nIndice].ColumnName] = drBitacora[nIndice, DataRowVersion.Current].ToString();
                        }
                    }
                }
               
            }


            //drDatoNuevo["cod_usuario"] = drBitacora["cod_usuario"].ToString();
            //drDatoNuevo["cod_ip"] = drBitacora["cod_ip"].ToString();
            //drDatoNuevo["fecha_hora"] = Convert.ToDateTime(drBitacora["fecha_hora"].ToString());
            //drDatoNuevo["cod_operacion"] = drBitacora["cod_operacion"].ToString();
            //drDatoNuevo["des_tabla"] = drBitacora["des_tabla"].ToString();
            //drDatoNuevo["des_campo_afectado"] = drBitacora["des_campo_afectado"].ToString();
            //drDatoNuevo["est_anterior_campo_afectado"] = drBitacora["est_anterior_campo_afectado"].ToString();
            //drDatoNuevo["est_actual_campo_afectado"] = drBitacora["est_actual_campo_afectado"].ToString();
            ////drDatoNuevo["cod_tipo_garantia"] = drBitacora["cod_tipo_garantia"].ToString();
            //drDatoNuevo["cod_garantia"] = drBitacora["cod_garantia"].ToString();
            //drDatoNuevo["cod_operacion_crediticia"] = drBitacora["cod_operacion_crediticia"].ToString();

            //switch (nTipoOperacion)
            //{
            //    case 1: drDatoNuevo["des_operacion"] = "INS";
            //        break;

            //    case 2: drDatoNuevo["des_operacion"] = "MOD";
            //        break;

            //    case 3: drDatoNuevo["des_operacion"] = "BOR";
            //        break;

            //    default: 
            //        break;
            //}

            //if (!drBitacora.IsNull("cod_tipo_garantia"))
            //{
            //    int nTipoGarantia = Convert.ToInt32(drBitacora["cod_tipo_garantia"].ToString());

            //    switch (nTipoGarantia)
            //    {
            //        case 1: drDatoNuevo["cod_tipo_garantia"] = "Fiduciaria";
            //            break;

            //        case 2: drDatoNuevo["cod_tipo_garantia"] = "Real";
            //            break;

            //        case 3: drDatoNuevo["cod_tipo_garantia"] = "Valor";
            //            break;

            //        default:
            //            break;
            //    }
            //}

            dtBitacoraNuevo.Rows.Add(drDatoNuevo);
            dtBitacoraNuevo.AcceptChanges();
        }

        dsBitacora.Tables.Clear();
        dsBitacora.Tables.Add(dtBitacoraNuevo);
        dsBitacora.AcceptChanges();
    }

    /// <summary>
    /// Método que se encarga de agregar la columna que describe el tipo de operación realizada, siendo 
    /// 1-INS, 2-MOD y 3-BOR
    /// </summary>
    private void AgregarNuevaColumnaDataSet()
    {

        if ((dsBitacora == null) || (dsBitacora.Tables.Count == 0) || (dsBitacora.Tables[0].Rows.Count == 0))
        {
            RealizarConsulta();
            dsBitacora.Tables[0].TableName = "Datos";
        }

        dsBitacora.Tables[0].TableName = "Datos";
        DataColumn dcDatos = new DataColumn();

        if (!dsBitacora.Tables[0].Columns.Contains("des_operacion"))
        {
            dcDatos = new DataColumn("des_operacion");
            dcDatos.DataType = System.Type.GetType("System.String");
            dcDatos.AllowDBNull = true;

            dsBitacora.Tables["Datos"].Columns.Add(dcDatos);
            dsBitacora.Tables["Datos"].AcceptChanges();
        }

        if (!dsBitacora.Tables[0].Columns.Contains("des_tipo_garantia"))
        {
            dcDatos = new DataColumn("des_tipo_garantia");
            dcDatos.DataType = System.Type.GetType("System.String");
            dcDatos.AllowDBNull = true;

            dsBitacora.Tables["Datos"].Columns.Add(dcDatos);
            dsBitacora.Tables["Datos"].AcceptChanges();
        }

        foreach (DataRow drBitacora in dsBitacora.Tables["Datos"].Rows)
        {
            int nTipoOperacion = Convert.ToInt32(drBitacora["cod_operacion"].ToString());

            for (int nIndice = 0; nIndice < drBitacora.Table.Columns.Count; nIndice++)
            {
                if (drBitacora.Table.Columns[nIndice].ColumnName.CompareTo("des_operacion") == 0)
                {
                    switch (nTipoOperacion)
                    {
                        case 1: drBitacora[nIndice] = "INS";
                            break;

                        case 2: drBitacora[nIndice] = "MOD";
                            break;

                        case 3: drBitacora[nIndice] = "BOR";
                            break;

                        default: drBitacora[nIndice] = "-";
                            break;
                    }
                }
                else if (drBitacora.Table.Columns[nIndice].ColumnName.CompareTo("cod_tipo_garantia") == 0)
                {
                    if (drBitacora.Table.Columns[nIndice] != null)
                    {
                        int nTipoGarantia = -1;

                        if (drBitacora["cod_tipo_garantia"].ToString() != string.Empty)
                        {
                            nTipoGarantia = Convert.ToInt32(drBitacora["cod_tipo_garantia"].ToString());
                        }
                        else
                        {
                            nTipoGarantia = -1;
                        }

                        switch (nTipoGarantia)
                        {
                            case 1: drBitacora["des_tipo_garantia"] = "Fiduciaria";
                                break;

                            case 2: drBitacora["des_tipo_garantia"] = "Real";
                                break;

                            case 3: drBitacora["des_tipo_garantia"] = "Valor";
                                break;

                            case 4: drBitacora["des_tipo_garantia"] = "Perfil";
                                break;

                            default: drBitacora["des_tipo_garantia"] = "-";
                                break;
                        }

                    }
                }
                else
                {
                    if ((drBitacora[nIndice, DataRowVersion.Current] == null) || (drBitacora[nIndice, DataRowVersion.Current].ToString().CompareTo("NULL") == 0)
                       || (drBitacora[nIndice, DataRowVersion.Current].ToString() == string.Empty))
                    {
                        drBitacora[nIndice] = "-";
                    }
                }

            }

            dsBitacora.Tables["Datos"].AcceptChanges();
        }

        dsBitacora.AcceptChanges();
    }

    /// <summary>
    /// Función que crea la estructura que debería poseer el dataset, esto en caso de que no hayan
    /// registros que presentar o algún error.
    /// </summary>
    /// <returns>Tabla con la estructura que debería poeer el dataset</returns>
    private DataTable CrearEstructuraDataSet()
    {
        DataTable dtBitacoraNuevo = new DataTable("Datos");

        string[] arrDatos = { "cod_usuario", "cod_ip", "fecha_hora", "cod_operacion", "des_operacion",
            "des_tabla", "des_campo_afectado", "est_anterior_campo_afectado", 
            "est_actual_campo_afectado", "cod_tipo_garantia", "cod_garantia", "cod_operacion_crediticia",
            "cod_consulta", "cod_consulta2"};


        foreach (string strDato in arrDatos)
        {

            DataColumn dcDato = new DataColumn(strDato);
            dcDato.DataType = System.Type.GetType("System.String");
            dcDato.AllowDBNull = true;

            dtBitacoraNuevo.Columns.Add(dcDato);
            dtBitacoraNuevo.AcceptChanges();
        }

        return dtBitacoraNuevo;

    }

    /// <summary>
    /// Metodo que carga la consulta
    /// </summary>
    /// <returns>Retorna un dataset con la consulta</returns>
    public void cargaConsulta()
    {
        //Creacion del comand text de la consulta

        Hashtable oParametros = new Hashtable();

        DateTime dFechaInicial = new DateTime();
        DateTime dFechaFinal = new DateTime();

        if ((txtFechaInicial.Text != string.Empty) && (txtFechaFinal.Text != string.Empty))
        {
            if (txtCodigoUsuario.Text != string.Empty)
            {
                oParametros.Add("strCodigoUsuario", txtCodigoUsuario.Text);
            }

            dFechaInicial = Convert.ToDateTime(txtFechaInicial.Text);
            dFechaFinal = Convert.ToDateTime(txtFechaFinal.Text);



            if (txtFechaInicial.Text.CompareTo(txtFechaFinal.Text) == 0)
            {
                dFechaFinal = dFechaFinal.AddDays(1);
            }

            if (ValidarFechas(dFechaInicial, dFechaFinal))
            {

                oParametros.Add("dFechaInicial", dFechaInicial.Year.ToString() + "-" + dFechaInicial.Month.ToString() + "-" + dFechaInicial.Day.ToString());
                oParametros.Add("dFechaFinal", dFechaFinal.Year.ToString() + "-" + dFechaFinal.Month.ToString() + "-" + dFechaFinal.Day.ToString());

                //oParametros.Add("dFechaInicial", txtFechaInicial.Text.Substring(6, 4) + "-" + txtFechaInicial.Text.Substring(3, 2) + "-" + txtFechaInicial.Text.Substring(0, 2));
                //oParametros.Add("dFechaFinal", txtFechaFinal.Text.Substring(6, 4) + "-" + txtFechaFinal.Text.Substring(3, 2) + "-" + txtFechaFinal.Text.Substring(0, 2));

                if (cbCodigoOperacion.SelectedItem.Value.CompareTo("-1") != 0)
                {
                    oParametros.Add("nCodigoOperacion", cbCodigoOperacion.SelectedItem.Value);
                }

                if (txtIP.Text != string.Empty)
                {
                    oParametros.Add("strNumeroIP", txtIP.Text);
                }

                oParametros.Add("strDescTabla", cbMantenimientos.SelectedItem.Value);
                oParametros.Add("strCriterioOrden", cbCriterioOrden.SelectedItem.Value);

                Session["NomReporte"] = "rptBitacora";
                Session.Add("ParametrosReporte", oParametros);

                Reporte.MostrarReporte("HTML3.2");
            }
            //else
            //{
            //    this.lblMensaje.Text = "La fecha final debe ser mayor o igual a la fecha inicial";
            //}

        }
        else
        {
            this.lblMensaje.Text = "Se debe proporcionar un rango de fechas";

            if ((this.gdvReporte.Rows.Count < 0) || (this.gdvReporte.Rows[0].Cells.Count < 0))
            {
                this.gdvReporte.Visible = false;
            }
        }
    }

    private bool ValidarFechas(DateTime dFechaI, DateTime dFechaF)
    {
        bool bFechasValidas = false;

        if (dFechaI <= dFechaF)
        {
            bFechasValidas = true;
        }
        else
        {
            lblMensaje.Text = "La fecha final debe ser mayor o igual a la fecha inicial";
        }

        return bFechasValidas;
    }

     #endregion

}
