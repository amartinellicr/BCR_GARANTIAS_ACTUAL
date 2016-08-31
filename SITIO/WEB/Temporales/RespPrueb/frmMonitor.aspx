<%@ Page Language="C#" AutoEventWireup="true" CodeFile="frmMonitor.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmMonitor" %>

<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>frmMonitor</title>
    <LINK href="Estilos/WebStyles.css" type="text/css" rel="stylesheet">
</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div>
            <table id="table1" style="Z-INDEX: 101; LEFT: 8px; WIDTH: 864px; POSITION: absolute; TOP: 8px; HEIGHT: 49px"
				cellSpacing="1" cellPadding="1" width="864" border="0">
				<tr>
					<td class="TextoTitulo_2" colSpan="2">BCR-GARANTIAS</td>
				</tr>
				<tr>
					<td class="td_TextoIzq" colSpan="2">
						<P>La aplicación se inició a las
							<asp:label id="lblFechaHora" runat="server" Font-Bold="true"></asp:label>, hay
							<asp:Label id="lblSesiones" runat="server" Font-Bold="true"></asp:Label>&nbsp;usuarios 
							activos.</P>
					</td>
				</tr>
			</table>
        </div>
    </form>
</body>
</html>
