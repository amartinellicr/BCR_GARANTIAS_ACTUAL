using System;
using System.Web;
using System.Configuration;

/// <summary>
/// Summary description for Reporte
/// </summary>
public class Reporte
{
    /// <summary>
    /// Constructor default de la clase
    /// </summary>
    public Reporte()
    {        
    }

    /// <summary>
    /// Metodo que encamina la visualizaci�n de un reporte predeterminado
    /// </summary>
    /// <param name="nFormatoVisualizar">Formato de Visualizaci�n del Reporte</param>
    public static void MostrarReporte(string nFormatoVisualizar)
    {
        //Nombre de la soluci�n en donde residen los reportes
        string strNomAplicacion = ConfigurationManager.AppSettings["nombreAplicacionReportes"];
        
        //Nombre del Reporte
        string sNomReporte = HttpContext.Current.Session["NomReporte"].ToString();

        //Nombre del Url donde se muestra el reporte
        //string strUrl = "/Administrador/ModuloAdministrador/ReporteGeneralForm.aspx?Aplicacion=" + strNomAplicacion + "&Reporte=" + sNomReporte + "&Formato=" + nFormatoVisualizar;
        string strUrl = "../Reportes/frmReporteGeneralForm.aspx?Aplicacion=" + strNomAplicacion + "&Reporte=" + sNomReporte + "&Formato=" + nFormatoVisualizar;
        //Navegaci�n hacia la pagina que muestra los reportes de la soluci�n.
        HttpContext.Current.Response.Redirect(strUrl, true);
        
    }
}
