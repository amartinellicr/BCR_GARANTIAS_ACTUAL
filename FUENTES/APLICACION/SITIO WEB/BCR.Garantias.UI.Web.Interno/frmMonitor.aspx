<%@ Page Language="C#" AutoEventWireup="true" CodeFile="frmMonitor.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmMonitor" %>

<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>frmMonitor</title>
    <LINK href="Estilos/WebStyles.css" type="text/css" rel="stylesheet">
</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div style="display:block;">
            <table id="table1" style="Z-INDEX: 101; LEFT: 8px; WIDTH: 864px; TOP: 8px; HEIGHT: 49px"
				cellSpacing="1" cellPadding="1" width="864" border="0">
				<tr>
					<td class="TextoTitulo_2" colSpan="2">BCR-GARANTIAS</td>
				</tr>
				<tr>
					<td class="td_TextoIzq" colSpan="2">
						<p>La aplicación se inició a las
							<asp:label id="lblFechaHora" runat="server" Font-Bold="true"></asp:label>, hay
							<asp:Label id="lblSesiones" runat="server" Font-Bold="true"></asp:Label>&nbsp;usuarios 
							activos.</p>
					</td>
                    <td class="td_TextoIzq" runat="server">
                        <asp:TextBox ID="txtSentencia" runat="server" Visible="false" Width="200px" Height="20px"></asp:TextBox>
                        <asp:Button ID="btnConsultar" runat="server" Visible="false"  />
                       
                    </td>
				</tr>
			</table>

            <asp:Label ID="Error" runat="server"></asp:Label>

        </div>
        <div id="ResultadoObtenido" runat="server" style="display:block;"></div>
    </form>
</body>
</html>
