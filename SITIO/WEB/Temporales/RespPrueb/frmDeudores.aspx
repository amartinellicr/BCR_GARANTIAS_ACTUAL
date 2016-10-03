<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmDeudores.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmDeudores" Title="BCR GARANTIAS - Deudores" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Deudores</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Información 
								del Deudor
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" width="40%" colSpan="2">
										    <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_Texto">Tipo de Persona:</td>
										<td>
											<asp:DropDownList id="cbTipo" runat="server" Width="276px" BackColor="AliceBlue" tabIndex="1"></asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="td_Texto">Cédula del Deudor:</td>
										<td>
										    <asp:textbox id="txtCedula" tabIndex="2" runat="server" CssClass="Txt_Style_Default" Width="128px"
												BackColor="AliceBlue" MaxLength="80" ToolTip="Tipo de Persona del Deudor"></asp:textbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto">Nombre&nbsp;del Deudor:</td>
										<td>
										    <asp:textbox id="txtNombre" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="343px"
												BackColor="AliceBlue" MaxLength="50" ToolTip="Tipo de Persona del Deudor" Enabled="False"></asp:textbox>
									    </td>
									</tr>
									<tr>
										<td class="td_Texto">Condiciones Especiales:</td>
										<td>
											<asp:DropDownList id="cbCondicion" runat="server" Width="276px" BackColor="White" tabIndex="4"></asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="td_Texto">Tipo de Asignación:</td>
										<td>
											<asp:dropdownlist id="cbTipoAsignacion" tabIndex="5" runat="server" BackColor="White" Width="476px"></asp:dropdownlist>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" style="HEIGHT: 19px">Indicador de Generador de Divisas:</td>
										<td style="HEIGHT: 19px">
											<asp:dropdownlist id="cbGenerador" tabIndex="6" runat="server" BackColor="AliceBlue" Width="344px"></asp:dropdownlist>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" style="HEIGHT: 20px">Indicador de Vinculado a Entidad:</td>
										<td style="HEIGHT: 20px">
											<asp:dropdownlist id="cbVinculadoEntidad" tabIndex="7" runat="server" BackColor="AliceBlue" Width="136px"></asp:dropdownlist>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">&nbsp;</td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">
											<asp:Button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:Button>
											<asp:Button id="btnRegresar" runat="server" Text="Regresar" tabIndex="8"></asp:Button><asp:button id="btnCapacidadPago" tabIndex="9" runat="server" Text="Capacidad de Pago" Visible="False"></asp:button><asp:button id="btnModificar" runat="server" Text="Modificar" tabIndex="10"></asp:button>
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

