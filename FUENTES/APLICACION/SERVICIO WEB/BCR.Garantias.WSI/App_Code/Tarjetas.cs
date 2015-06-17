using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;

using BCRGARANTIAS.Negocios;

[WebService(Namespace = "http://bancobcr.com/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class Tarjetas : System.Web.Services.WebService
{
    public Tarjetas()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public int ActualizarEstadoTarjeta(string strNumeroTarjeta, string strEstadoTarjeta) 
    {
        return Gestor.ActualizarEstadoTarjeta(strNumeroTarjeta, strEstadoTarjeta, -1);
    }
    
}
