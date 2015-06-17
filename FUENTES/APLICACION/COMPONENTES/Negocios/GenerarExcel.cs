using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.IO;

namespace BCRGARANTIAS.Negocios
{
    class GenerarExcel
    {
        StreamWriter w;    
        
        public int DoExcel(string ruta, DataTable dtEntrada, string strEncabezados)   
        {
            try
            {
                FileStream fs = new FileStream(ruta, FileMode.Create, FileAccess.ReadWrite);
                w = new StreamWriter(fs);
                EscribeCabecera(strEncabezados);
                for (int nIndice = 0; nIndice < dtEntrada.Rows.Count; nIndice++)
                {
                    EscribeLinea(nIndice, dtEntrada.Rows[nIndice]);
                }

                EscribePiePagina();
            }
            catch
            {
                throw;
            }
            finally
            {
                w.Flush();
                w.Close();
                w.Dispose();
            }
            
            return 0;  
        }      
        
        public void EscribeCabecera(string strEncabezados)  
        {   
            StringBuilder html = new StringBuilder();

            string[] strLista;

            if (strEncabezados != string.Empty)
            {

                strLista = strEncabezados.Split(",".ToCharArray());

                if (strLista.Length > 0)
                {
                    html.Append("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">");
                    html.Append("<html>");
                    html.Append("  <head>");
                    html.Append("<title>www.somosbancobcr.com</title>");
                    html.Append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />");
                    html.Append("  </head>");
                    html.Append("<body>");
                    html.Append("<p>");
                    html.Append("<table>");
                    html.Append("<tr style=\"font-weight: bold;font-size: 12px;color: white;\">");

                    for (int nIndice = 0; nIndice < strLista.Length; nIndice++)
                    {
                        html.Append("<td bgcolor=\"Blue\">" + strLista[nIndice].ToString()+ "</td>");
                    }

                    html.Append("</tr>");


                    w.Write(html.ToString());
                }
            }
        }    
        
        public void EscribeLinea(int i, DataRow drDatoEntrada)  
        {      
            string bgColor = "", fontColor = "";

            if (i % 2 == 0)
            {
                bgColor = " bgcolor=\"LightBlue\" ";
                fontColor = " style=\"font-size: 12px;color: white;\" ";
            }
            if ((drDatoEntrada != null) && (drDatoEntrada.ItemArray.Length > 0))
            {
                w.Write("<tr>");

                for (int nIndice = 0; nIndice < drDatoEntrada.ItemArray.Length; nIndice++)
                {
                    w.Write(@"<td align=\""center\"" {1} {2}>{0}</td>",
                        drDatoEntrada.ItemArray[nIndice].ToString(), bgColor, fontColor);
                }

                w.Write("</tr>");
            }
        }
        
        public void EscribePiePagina()  
        {   
            StringBuilder html = new StringBuilder();          
            html.Append("  </table>");   
            html.Append("</p>");   
            html.Append(" </body>");   
            html.Append("</html>");   
            w.Write(html.ToString());  
        }   
    }
}
