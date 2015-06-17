using System.Web.UI;

namespace ControlesWebPersonalizados
{
	public class Navegador
	{

		Page Pag ;
		// Constructor
		public Navegador(Page Pagina)
		{
			Pag = Pagina;
		}


		// Este método se aplica a la ventana padre.
		// Este método se encarga de abrir una ventana hija
		// -->>  Como entrada recibe la url de la página a abrir, el ancho y alto de la ventana y determinar si 
		//      ha de estar centrada de forma opcional una serie de strings "yes"|"no"|"auto" 
		//      para determinar la forma de la ventana.
		//
		public void Abrir_Ventana_Hija( string Url , int width, int height, bool CentrarPopUp, object toolbar , object directories , 
			object titlebar , object status,
			object resizable, object menubar, 
			object scrollbars)
		{

			string strScript = "";
			string script = Abrir_PopUP();

			// Construcción de los atributos de la ventana
			strScript = strScript + "<script type='text/javascript'> " + "\n";
			strScript = strScript + "var atributos='width=" + width + ",height=" + height + ",titlebar=" + titlebar + ",";
			strScript = strScript + "toolbar=" + toolbar + ",directories=" + directories + ",status=" + status + ",";
			strScript = strScript + "resizable=" + resizable + ",menubar=" + menubar + ", scrollbars=" + scrollbars + "';" + "\n";

			// Centrar la ventana 
			if (CentrarPopUp == true )
			{
				strScript += "var H = (screen.height - " + height + ") / 2;" + "\n";
				strScript += "var L = (screen.width - " + width + ") / 2;" + "\n";
				strScript += "var fin = ',top='+ H +',left='+ L;" + "\n";
				strScript += "atributos=atributos + fin;" + "\n";
			}

			// Abrir la ventana
			strScript += "openChild('" + Url + "',atributos)" + "\n";
			strScript += "</script>" + "\n";

			Pag.ClientScript.RegisterStartupScript(Pag.GetType(), "AbrirPopUp", script);
			Pag.ClientScript.RegisterStartupScript(Pag.GetType(), "VentanaHija", strScript);

		}


		// Abrir una Ventana Hija
		//
		private string Abrir_PopUP()
		{
			string strScript = "";
			strScript += "<script language='jscript'>" + "\n";
			strScript += "function openChild(URL,winAtts)" + "\n";
			strScript += "{" + "\n";
			strScript += "var winName='child'" + "\n";
			strScript += "myChild= window.open(URL,winName,winAtts);" + "\n";
			strScript += "}" + "\n";
			strScript += "</script>" + "\n";

			return strScript;

		}


		// Este método se aplica a la ventana Hija
		// Este método se encarga de Redireccionar en la ventana Padre cuando se cierra la ventana Hija.
		// -->> Como entrada recibe la Url de la página padre y un string con las variables de url ** SIN: ? **

		public void EstablecerUrl_VentanaPadre(string url , string Variables)
		{
			string strScript = "";
			strScript += "<script language='jscript'>" + "\n";
			strScript += "var pWin" + "\n";
			strScript += "function setParent(){" + "\n";
			strScript += "pWin = top.window.opener" + "\n";
			strScript += "}" + "\n";

			strScript += "function reloadParent(){" + "\n";
			strScript += "pWin.location.href='" + url + "?" + Variables + "'" + "\n";
			strScript += "}" + "\n";
			strScript += "</script>" + "\n";

			Pag.ClientScript.RegisterStartupScript(Pag.GetType(), "VentanaHija", strScript);

		}


		// Este método se aplica a la ventana Hija
		// Este método inicializa el método de actualizar la ventana padre al cerrar la ventana hija.
		// -->>  De forma opcional recibe un Integer con el número de segundos que transcurriran 
		//      para cerrar la ventana hija.

		public void ActualizarVentanaPadre_CerrarVentanaHija()
		{
			string strScript = "";
			int Segundos = 10;
			strScript += "<script languaje='javascript'>" + "\n";
			strScript += "setParent();" + "\n";
			strScript += "reloadParent();" + "\n";
			strScript += "</script>" + "\n";
		
			Pag.ClientScript.RegisterStartupScript(Pag.GetType(), "Cargar", strScript);
			CerrarPantalla_TimeOut(Segundos);
		
		}
		//
		//
		//' Método para cerrar la ventana del navegador transcurrido un determinado tiempo.
		//' -->> Como entrada recibe el número de segundos tras los cuales se cerrará la ventana del navegador.
		//'
		public void CerrarPantalla_TimeOut(int Segundos)
		{
			string strScript = "";
			Segundos = Segundos * 1000;
		
			strScript = "<script type='text/javascript'>" + "\n";
			strScript += "function cerrar() " + "\n";
			strScript += "{" + "\n";
			strScript += "var ventana = window.self" + "\n";
			strScript += "ventana.opener = window.self" + "\n";
			strScript += "ventana.close()" + "\n";
			strScript += "}" + "\n";
			strScript += "setTimeout(cerrar(),"  + Segundos + ")" + "\n";
			strScript += "</script>" + "\n";
		
			Pag.ClientScript.RegisterStartupScript(Pag.GetType(), "CerrarVentanaTimeOut", strScript);
		
		}
		//
		//
		//' Método que Deshabilita el Click derecho del ratón en una página.
		//'
		public void Deshabilitar_ClickDerecho()
		{
			string strScript = "";
			strScript += "<script language='JavaScript'>" + "\n";
			strScript += "var message='';" + "\n";
			strScript += "function clickIE() {if (document.all) {(message);return false;}}" + "\n";
			strScript += "function clickNS(e) {if " + "\n";
			strScript += "(document.layers||(document.getElementById++!document.all)) {" + "\n";
			strScript += "if (e.which==2||e.which==3) {(message);return false;}}}" + "\n";
			strScript += "if (document.layers)" + "\n";
			strScript += "{document.captureEvents(Event.MOUSEDOWN);document.onmousedown=clickNS;}" + "\n";
			strScript += "else{document.onmouseup=clickNS;document.oncontextmenu=clickIE;}" + "\n";
			strScript += "document.oncontextmenu=new Function(return false)" + "\n";
			strScript += "</script>" + "\n";

			Pag.ClientScript.RegisterClientScriptBlock(Pag.GetType(), "noClickDerecho", strScript);

		}
		//
		//
		//' Método que maximiza el tamaño de la ventana del navegador hasta la resolución
		//' que tenga el cliente establecida.
		//'
		//Public Sub MaximizarVentana_ResolucionCliente()
		//
		//Dim strScript As String = String.Empty
		//strScript += "<script language='JavaScript1.2'>" + \n
		//strScript += "window.moveTo(0,0);" + \n
		//strScript += "if (document.all) {" + \n
		//strScript += "top.window.resizeTo(screen.availWidth,screen.availHeight);" + \n
		//strScript += "}" + \n
		//strScript += "else if (document.layers||document.getElementById) {" + \n
		//strScript += "if (top.window.outerHeight<screen.availHeight||top.window.outerWidth<screen.availWidth){" + \n
		//strScript += "top.window.outerHeight = screen.availHeight;" + \n
		//strScript += "top.window.outerWidth = screen.availWidth;" + \n
		//strScript += "}" + \n
		//strScript += "}" + \n
		//strScript += "</script>" + \n
		//
        //Pag.ClientScript.RegisterClientScriptBlock(Pag.GetType(), "MaximizarPantalla", strScript)
		//
		//End Sub
		//
		//
		//' Función que deshabilita la tecla intro en una página.
		//'
		//Public Sub Deshabilitar_Intro()
		//
		//Dim script As String = String.Empty
		//script = "<script language = 'javascript'>"
		//script += "function keydown(){"
		//script += "var keycode = event.keyCode;"
		//script += "if (keycode == 13){"
		//script += "return false;"
		//script += "}"
		//script += "}"
		//script += "document.onkeydown = keydown;"
		//script += "</script>"
		//
        //Pag.ClientScript.RegisterClientScriptBlock(Pag.GetType(), "noIntro", script)
		//
		//End Sub
		//
		//End Class
	}
}