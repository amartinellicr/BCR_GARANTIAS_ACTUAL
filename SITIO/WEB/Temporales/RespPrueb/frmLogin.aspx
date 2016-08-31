<%@ Page Language="C#" AutoEventWireup="true" CodeFile="frmLogin.aspx.cs" Inherits="BCRGARANTIAS.frmLogin" %>

<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>BCR GARANTIAS - Pantalla de Login</title>
    <link href="Estilos/WebStyles.min.css" type="text/css" rel="stylesheet" />
    <script src="<%#ResolveUrl("~/JSLib/FuncionesGenericas.js")%>" type="text/javascript"></script>
	<script language="JavaScript" type="text/javascript">
		window.history.forward(1);
	</script>
</head>
<body>
    <form onkeypress="if(window.event.keyCode==13){document.frmLogin1.cmdIngresar.click();return false}" id="frmLogin1" method="post" runat="server">
        <div>
            <br>
			<br>
			<BR>
			<table style="WIDTH: 391px; HEIGHT: 68px" width="391" align="center" border="0">
				<tr>
					<td align="center" width="20%"><IMG src="Images/Banner_Inicio.jpg"></td>
				</tr>
			</table>
			<table style="WIDTH: 491px; HEIGHT: 197px" borderColor="#005a9c" width="491" align="center"
				border="2">
				<tr>
					<td align="center">
						<table width="100%" align="center" border="0">
							<tr>
								<td align="center" colSpan="2"></td>
							</tr>
							<tr>
								<td align="center" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label></td>
							</tr>
							<tr>
								<td align="center" colSpan="2"></td>
							</tr>
							<tr>
								<td class="td_Texto" style="HEIGHT: 12px" width="38%">Usuario:</td>
								<td style="HEIGHT: 12px" width="62%"><asp:textbox id="txtUsuario" tabIndex="1" runat="server" Width="160px" MaxLength="15" BackColor="AliceBlue"
										BorderStyle="Solid" BorderColor="#7F9DB9" ToolTip="Digite su usuario de dominio BCR" AutoCompleteType="Disabled"></asp:textbox></td>
							</tr>
							<tr>
								<td class="td_Texto" style="HEIGHT: 26px" width="38%">Contraseña:</td>
								<td style="HEIGHT: 26px" width="62%"><asp:textbox id="txtClave" tabIndex="2" runat="server" Width="160px" MaxLength="30" BackColor="AliceBlue"
										BorderStyle="Solid" BorderColor="#7F9DB9" ToolTip="Digite su contraseña de dominio BCR" TextMode="Password" AutoCompleteType="Disabled"></asp:textbox></td>
							</tr>
							<tr>
								<td class="td_Texto" style="HEIGHT: 12px" width="38%" colSpan="2"></td>
							</tr>
							<tr>
								<td style="HEIGHT: 12px" align="center" width="38%" colSpan="2"><asp:button id="cmdIngresar" tabIndex="3" runat="server" BackColor="#7F9DB9" BorderColor="#7F9DB9"
										ToolTip="Ingreso al Sistema BCR - Garantías" Text="Ingresar"></asp:button></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="491" align="center" border="0">
				<tr>
					<td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">
						Banco de Costa Rica © Derechos reservados&nbsp;2006.</td>
				</tr>
			</table>  
        </div>
    </form>
</body>
</html>
