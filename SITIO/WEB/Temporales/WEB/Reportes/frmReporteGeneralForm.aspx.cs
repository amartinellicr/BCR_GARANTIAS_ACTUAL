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
using System.Net;
using System.IO;

using System.Web.Services.Protocols;
using System.Text;

public partial class Reportes_frmReporteGeneralForm : System.Web.UI.Page
{
    /// <summary>
    /// Evento que se dispara cada vez que se accesa a la página
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        //lblModulo.Text = ConfigurationManager.AppSettings["moduloAdministrador"];

        #region Con CrystalReports
        ////Declaración del Documento de Reporte
        //ReportDocument RpDoc = new ReportDocument();

        ////Asignación de la variable de Session que trae el report document
        //RpDoc = (ReportDocument)Session["goReporte"];

        ////Seteo de los parametros del reporte
        //RpDoc.SetParameterValue("tcUsuario", Session["cocUsuario"]);
        //RpDoc.SetParameterValue("pfTitulo", Session["Titulo"]);

        ////Si la variable no es nula
        //if (Session["goReporte"] != null)
        //{
        //    //Asigna al reporviwer el report dicument como Recurso de Datos
        //    VisorReportes.ReportSource = RpDoc;
        //    //Carga el reporte
        //    VisorReportes.DataBind();
        //}
        #endregion

        
        string strMensaje = "No se puede mostrar el reporte solicitado";

        string strNomAplicacion = Request.QueryString.Get("Aplicacion");
        string strNomReporte = Request.QueryString.Get("Reporte");
        string strFormato = Request.QueryString.Get("Formato");
                       
        #region Con Literal y Render
        try
        { 
            //Encoding ascii = Encoding.ASCII;
          //ReportingService rs = new ReportingService();

          //rs.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;

          ////rs.Credentials = new System.Net.NetworkCredential("303800983", "lA123456");

          //rs.Url = ConfigurationManager.AppSettings["UrlWSReportServices"].ToString();

            //*****************************************************************
            //Declaro las variables requeridas para implementar el reporte.
            //byte[] reportDefinition = null;
            ////byte[] image;
            //ParameterValue[] parameters = null;
            //Warning[] alertas = null;
            //string[] colas = null;
            //string devInfo = @"<DeviceInfo><HTMLFragment>true</HTMLFragment><Toolbar>True</Toolbar></DeviceInfo>";
          //  //string devInfo = "<DeviceInfo>";
          //  //devInfo += "<StreamRoot>streamRoot</StreamRoot>";
          //  //devInfo += "<Toolbar>False</Toolbar>";
          //  //devInfo += "<Parameters>False</Parameters>";
          //  //devInfo += "<HTMLFragment>True</HTMLFragment>";
          //  //devInfo += "<StyleStream>False</StyleStream>";
          //  //devInfo += "<Section>0</Section>";
          //  //devInfo += "<Zoom>zoom</Zoom>";
          //  //devInfo += "</DeviceInfo>";

            //string mimeType = string.Empty;
            //string strNombreArchivo = string.Empty;

          //  //****************************************************************

          //  //Obtenemos de la session la clase de parametros del reporte.
          //  Hashtable oParametros = (Hashtable)Session["ParametrosReporte"];

          //////  //Definicion de Parametros
          //  ParameterValue[] parametros = new ParameterValue[oParametros.Count];

          //  int i = 0;

          //  IDictionaryEnumerator oEnumerator = oParametros.GetEnumerator();
          //  while (oEnumerator.MoveNext())
          //  {
          //      parametros[i] = new ParameterValue();
          //      parametros[i].Name = oEnumerator.Key.ToString();
          //      parametros[i].Value = oEnumerator.Value.ToString();

          //      i++;
          //  }
        
          //string strPath = "/Kioscos/" + strNomAplicacion + "/" + strNomReporte;            

          //reportDefinition = rs.Render(strPath, strFormato, null,
          //            devInfo, parametros, null, null, out strNombreArchivo, out mimeType, out parameters,
          //            out alertas, out colas);


          //if (mimeType.Equals("text/html"))
          //{
          //    mimeType = "text/xml";
          //}

          //Response.ContentType = mimeType;

          //char[] asciiChars = new char[ascii.GetCharCount(reportDefinition, 0, reportDefinition.Length)];
          //ascii.GetChars(reportDefinition, 0, reportDefinition.Length, asciiChars, 0);
          //string asciiString = new string(asciiChars);


          //ltlVisorReporte.Text = asciiString;
          //ltlVisorReporte.Text = reportDefinition.ToString();

          #endregion

        #region Con IFRAME 
          
          //Tabla Hash a la cual se le asignan los parametros
          Hashtable oParametros = (Hashtable)Session["ParametrosReporte"];

          //Definicion de Parametros
          ParameterValue[] parametros = new ParameterValue[oParametros.Count];

          //Variable para recorrer los parametros
          int i = 0;

          //Crea el enumerador con los valores de la tabla hash.
          IDictionaryEnumerator oEnumerator = oParametros.GetEnumerator();
              
              //Carga los valores de la tabla a la variable de los parámetros         
              while (oEnumerator.MoveNext())
              {
                  parametros[i] = new ParameterValue();
                  parametros[i].Name = oEnumerator.Key.ToString();
                  parametros[i].Value = oEnumerator.Value.ToString();

                  i++;
              }    

          

          //Crea el path del reporte dinámicamente
          string strPath = "/BCR Garantias/" + strNomAplicacion + "/" + strNomReporte;   

          //Crea el path del servicio web
          string v_ServerPath = ConfigurationManager.AppSettings["UrlWSReportServices"].ToString();

          //Variavble para la secuencia de parámetros a pasar al recurso del IFRAME
          string secuenciaParametros = string.Empty;

          //Crea la secuencia de parámetros a pasar al recurso del IFRAME de una forma dinámica         
          for (int j = 0; j < oParametros.Count; j++)
          {              
            secuenciaParametros += "&" + parametros[j].Name.ToString() + "=";
            secuenciaParametros += parametros[j].Value.ToString();                  
          }

          //Setea el atributo del IFrame con la construccion dada con las variables necesarias para cargar el reporte en el objeto
          IFrameReporte.Attributes["src"] = v_ServerPath.Substring(0, v_ServerPath.LastIndexOf("/")) + "?" + strPath + secuenciaParametros + "&rs:Command=Render&rc:LinkTarget=IFrameReporte&rc:Zoom=75&rc:Toolbar=true&rc:Parameters=false";
          


          #endregion

        #region Logica con Report Viewer
          //string v_ServerPath = ConfigurationManager.AppSettings["UrlWSReportServices"].ToString();
            
          //ReportViewer1.ServerReport.ReportServerUrl = new System.Uri(v_ServerPath);
          //Microsoft.Reporting.WebForms.Warning[] alertas;
          //string[] luis;
          //ReportViewer1.ServerReport.ReportPath = strPath;

          //Microsoft.Reporting.WebForms.ReportParameter[] RptParameters = new Microsoft.Reporting.WebForms.ReportParameter[oParametros.Count];

          //while (oEnumerator.MoveNext())
          //{
          //    RptParameters[i] = new Microsoft.Reporting.WebForms.ReportParameter(oEnumerator.Key.ToString(), oEnumerator.Value.ToString());
          //    i++;
          //}

          //MyReportServerCredentials credenciales = new MyReportServerCredentials();
          //ReportViewer1.ServerReport.ReportServerCredentials = credenciales;

          //this.ReportViewer1.ServerReport.SetParameters(RptParameters);
          //ReportViewer1.ServerReport.Render(strFormato, devInfo, out strNombreArchivo, out strNombreArchivo, out strNombreArchivo, out luis, out alertas);

          //System.IO.Stream s = new MemoryStream(reportDefinition);
          //ReportViewer1.ServerReport.LoadReportDefinition(s);

          //this.ReportViewer1.ServerReport.Refresh();

          #endregion

        }
        catch (SoapException ex)
        {
            throw new Exception(strMensaje, ex);
        }
        catch (WebException ex)
        {           
            throw new Exception(strMensaje, ex);
        }
    }
    
}