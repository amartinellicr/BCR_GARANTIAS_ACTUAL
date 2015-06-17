<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmCatalogos.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmCatalogos" Title="BCR GARANTIAS - Catálogos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
	    <table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Catálogos</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								BCR GARANTIAS&nbsp;- Catálogos</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" colSpan="2">
										    <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td width="70%"></td>
									</tr>
									<tr>
										<td class="td_Texto">
											Catálogo:</td>
										<td>
											<asp:DropDownList id="cbCatalogo" runat="server" Width="341px" BackColor="AliceBlue"></asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td></td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">
										    <asp:button id="btnSiguiente" runat="server" ToolTip="Siguiente" Text="Siguiente"></asp:button>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table> <!--DEFINE BOTONERA-->
					<table class="table_Default" width="60%" align="center" border="0">
						<tr>
							<td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">Banco 
								de Costa Rica © Derechos reservados 2006.</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
    </div>
</asp:Content>

