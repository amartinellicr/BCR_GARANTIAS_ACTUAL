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
using Microsoft.Reporting.WebForms;
using BCRGARANTIAS.Negocios;
using BCRGarantias.Contenedores;

public partial class Reportes_frmReporteBitacora : System.Web.UI.Page
{
    #region Variables Globales

    private string strNombreReporte = "Informacion de la Bitacora";
    protected DataSet dsBitacora = new DataSet();
    private Bitacora moBitacora = new Bitacora();
    //protected BCRGARANTIAS.Presentacion.dsBitacora dsBitacora1;
    //private rptBitacora Rel = new rptBitacora();
    #endregion

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        //btnImprimir.Click += new EventHandler(btnImprimir_Click);
        //btnRegresar.Click += new EventHandler(btnRegresar_Click);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string reportPath = string.Empty;
        string strRutaEsquema = string.Empty;

        try
        {
            //rptBitacora = new ReportDocument();
            //reportPath = Server.MapPath("rptBitacora.rdlc");
            
            ReportViewer1.LocalReport.ReportPath = "Reportes\\rptBitacora.rdlc";
            ReportViewer1.LocalReport.EnableExternalImages = true;

            strRutaEsquema = Server.MapPath("dsBitacora.xsd");
            dsBitacora.ReadXmlSchema(strRutaEsquema);

            CargarDataSet();

            if ((dsBitacora != null) && (dsBitacora.Tables.Count > 0) && (dsBitacora.Tables[0].Rows.Count > 0))
            {

                dsBitacora.Tables[0].TableName = "Datos";

                if ((!dsBitacora.Tables["Datos"].Columns.Contains("fecha_corte"))
                    && (!dsBitacora.Tables["Datos"].Columns.Contains("num_registro")))
                {
                    DataTable dtBitacora = new DataTable();
                    dtBitacora = dsBitacora.Tables["Datos"];

                    DataColumn dcFechaCorte = new DataColumn("fecha_corte");
                    dcFechaCorte.DataType = System.Type.GetType("System.String");
                    dcFechaCorte.AllowDBNull = false;

                    dtBitacora.Columns.Add(dcFechaCorte);
                    dtBitacora.AcceptChanges();
                    dsBitacora.AcceptChanges();

                    DateTime dtFechaHora = Convert.ToDateTime(dsBitacora.Tables["Datos"].Rows[dsBitacora.Tables["Datos"].Rows.Count - 1][ContenedorBitacora.FECHA_HORA].ToString());

                    int nRegistro = 1;

                    foreach (DataRow drBitacora in dsBitacora.Tables["Datos"].Rows)
                    {
                        drBitacora["fecha_corte"] = dtFechaHora.ToShortDateString();
                    }

                    dsBitacora.AcceptChanges();
                }

                dsBitacora.DataSetName = "dsBitacora";
                ReportDataSource rdsReporte = new ReportDataSource("dsBitacora_Datos", ObtenerTabla());
                ReportViewer1.LocalReport.DataSources.Clear();
                ReportViewer1.LocalReport.DataSources.Add(rdsReporte);
                ReportViewer1.LocalReport.Refresh();
                
               

                //rptBitacora.Load(reportPath);

                //rptBitacora.SetDataSource(dsBitacora);

                ////Rel.SetDataSource(dsBitacora);

                //rptBitacora.SetDataSource(dsBitacora);

                //crvReporte.ReportSource = rptBitacora; //Rel;
                //crvReporte.SeparatePages = true;
                //crvReporte.DisplayGroupTree = false;
                //crvReporte.DisplayToolbar = true;
                //crvReporte.DisplayPage = true;
                //crvReporte.HasGotoPageButton = true;
                //crvReporte.HasPageNavigationButtons = true;
                //crvReporte.HasSearchButton = true;
                //crvReporte.HasZoomFactorList = true;
            }
        }
        catch (Exception ex)
        {
            string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf(" /"));

            strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Reportes/"));

            Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Cargando Reporte" +
                            "&strMensaje=" + ex.Message +
                            "&bBotonVisible=1" +
                            "&strTextoBoton=Regresar" +
                            "&strHref=Reportes/frmRptFiltroBitacora.aspx");
        }
    }

    private void btnRegresar_Click(object sender, System.EventArgs e)
    {
        string strRuta = "~/Reportes/frmRptFiltroBitacora.aspx";
        Response.Redirect(strRuta);
    }

    private void btnImprimir_Click(object sender, System.EventArgs e)
    {
        ////Se crea el documento de lectura y escritura
        //System.IO.MemoryStream rptStream = new System.IO.MemoryStream();
        ////Se envia el reporte al stream y le indicamos el metodo de escritura o tipo de documento
        //rptStream = (System.IO.MemoryStream)rptBitacora.ExportToStream((CrystalDecisions.Shared.ExportFormatType)int.Parse(cbFormato.SelectedValue));
        ////Rel.ExportToStream((CrystalDecisions.Shared.ExportFormatType)int.Parse(cbFormato.SelectedValue));

        ////Limpiamos la memoria
        //Response.Clear();
        //Response.Buffer = true;

        ////Le indicamos el tipo de documento que vamos a exportar
        //Response.ContentType = FormatoDocumento();

        ////Automaticamente se descarga el archivo
        //Response.AddHeader("Content-Disposition", "attachment;filename=" + this.strNombreReporte);

        ////Se escribe el archivo
        //Response.BinaryWrite(rptStream.ToArray());
        //Response.End();
    }

    #endregion

    #region Métodos Privados

    private DataTable ObtenerTabla()
    {
        return this.dsBitacora.Tables["Datos"];
    }

    private string FormatoDocumento()
    {
        string tipo = "";

        //if (int.Parse(cbFormato.SelectedValue) == 4)
        //{
        //    tipo = "application/vnd.ms-excel";
        //    strNombreReporte += ".xls";
        //}
        //else if (int.Parse(cbFormato.SelectedValue) == 3)
        //{
        //    tipo = "application/msword";
        //    strNombreReporte += ".doc";
        //}
        //else if (int.Parse(cbFormato.SelectedValue) == 5)
        //{
        //    tipo = "application/pdf";
        //    strNombreReporte += ".pdf";
        //}

        return tipo;
    }

    private void CargarDataSet()
    {
        if (Session["dsDatos"] != null)
        {
            dsBitacora = ((DataSet)Session["dsDatos"]);
        }
        else
        {
            dsBitacora = null;
        }
    }
    #endregion
}
