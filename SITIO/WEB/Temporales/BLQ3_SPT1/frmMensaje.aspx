<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmMensaje.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmMensaje" Title="BCR GARANTIAS - Mensaje" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="WIDTH: 869px">
					<table id="table3" cellSpacing="1" cellPadding="1" width="775" border="0">
						<tr>
							<td align="center">
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
														<img src="<%=ObtenerImagen()%>">
														<asp:Label CssClass="TextoMensaje" id="lblMensaje" runat="server"></asp:Label>
													</td>
												</tr>
												<tr>
													<td width="100%" align="center">
														<br>
														<asp:Button id="cmdAccion" runat="server"></asp:Button>
														<br>
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center"
								valign="top">
								Banco de Costa Rica © Derechos reservados 2006.</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
    </div>
</asp:Content>

