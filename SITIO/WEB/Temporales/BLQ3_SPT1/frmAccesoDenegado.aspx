<%@ Page Language="C#" AutoEventWireup="true" CodeFile="frmAccesoDenegado.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmAccesoDenegado" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>BCR GARANTIAS - Acceso Denegado</title>
    <link href="Estilos/WebStyles.css" type="text/css" rel="stylesheet">
		<script language="JavaScript">
			window.history.forward(1);
		</script>
</head>
<body topmargin="0" bgcolor="#e5e9ef">
    <form id="frmActividades" method="post" runat="server">
    <div>
        <TABLE style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window" border="0" cellSpacing="1">
		    <TR>
			    <TD style="WIDTH: 869px">
				    <TABLE id="Table3" cellSpacing="1" cellPadding="1" width="775" border="0">
					    <TR>
						    <TD align="center">
							    <br>
							    <table width="70%" align="center" border="2" bordercolor="#005a9c">
								    <tr>
									    <td>
										    <br>
										    <table width="100%" align="center" border="0">
											    <tr>
												    <td align="center" class="TextoTitulo" colspan="2" width="100%">
													    <asp:Label id="lblTitulo" runat="server"></asp:Label>
												    </td>
											    </tr>
											    <tr>
												    <td width="100%" align="center">
													    <img src="Images/Error.ICO">
													    <asp:Label CssClass="TextoMensaje" id="lblMensaje" runat="server"></asp:Label>
												    </td>
											    </tr>
											    <tr>
												    <td align="center"><br>
													    <asp:Button id="cmdAccion" runat="server" Text="Ingreso al Sistema"></asp:Button><br>
													    <br>
												    </td>
											    </tr>
										    </table>
									    </td>
								    </tr>
							    </table>
						    </TD>
					    </TR>
					    <TR>
						    <TD style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center"
							    valign="top">
							    Banco de Costa Rica © Derechos reservados 2006.</TD>
					    </TR>
				    </TABLE>
			    </TD>
		    </TR>
		</TABLE>
    </div>
    </form>
</body>
</html>
