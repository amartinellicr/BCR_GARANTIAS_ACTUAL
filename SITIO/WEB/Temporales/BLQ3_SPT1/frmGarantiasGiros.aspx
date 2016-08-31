<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGarantiasGiros.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmGarantiasGiros" Title="BCR GARANTIAS - Garantías de Giros" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellSpacing="1" cellPadding="1" width="775" align="center"
			bgColor="window" border="0">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3">
					<!--TITULO PRINCIPAL-->
						<center>
						    <b>
						        <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Relación de Giros a Contratos</asp:label>
					        </b>
					        <b></b>
					    </center> 
					<!--<asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Garantías Fiduciarias</asp:label>--></td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								<P>Información del Contrato</P>
							</td>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" colSpan="11">
										    <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_Texto" width="15%">Contabilidad:</td>
										<td width="4%">
										    <asp:textbox id="txtContabilidad" tabIndex="1" runat="server" MaxLength="2" BackColor="AntiqueWhite"
												Width="23px">1</asp:textbox>
										</td>
										<td class="td_Texto" width="9%">Oficina:</td>
										<td width="4%">
										    <asp:textbox id="txtOficina" tabIndex="2" runat="server" MaxLength="3" BackColor="AntiqueWhite"
												Width="32px"></asp:textbox>
										</td>
										<td class="td_Texto" width="9%">Moneda:</td>
										<td width="4%">
										    <asp:textbox id="txtMoneda" tabIndex="3" runat="server" MaxLength="2" BackColor="AntiqueWhite"
												Width="21px"></asp:textbox>
										</td>
										<td class="td_Texto" width="9%">
										    <asp:label id="lblTipoCaptacion" runat="server">Contrato:</asp:label>
										</td>
										<td width="9%">
										    <asp:textbox id="txtOperacion" tabIndex="5" runat="server" MaxLength="7" BackColor="AntiqueWhite"
												Width="64px"></asp:textbox>
										</td>
										<td class="td_Texto" width="36%">
											<asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button><asp:button id="btnVerGarantias" tabIndex="6" runat="server" Text="Consultar Garantías"></asp:button>
										</td>
									</tr>
									<tr>
										<td class="td_Texto">
										    <asp:label id="lblDeudor" runat="server" Visible="False" Font-Italic="true">Deudor:</asp:label>
										</td>
										<td class="td_TextoIzq" colSpan="10">
										    <asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Italic="true"></asp:label>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								rowSpan="1">
								<asp:label id="lblCatalogo" runat="server"> Garantías del Contrato</asp:label>
							</td>
						</tr>
						<tr>
							<td align="center">
							    <br/>
								     <asp:GridView ID="gdvGarantiasGiros" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="cod_garantia, cod_tipo_garantia, cat_descripcion, Garantia" 
                                         OnPageIndexChanging="gdvGarantiasGiros_PageIndexChanging" CssClass="gridview">
                                         <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                         
                                        <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                        <Columns>
                                            <asp:BoundField DataField="cat_descripcion" HeaderText="Tipo de Garantía" Visible="True" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="Garantia" HeaderText="Garantía" Visible="True" ItemStyle-Width="510px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="cod_garantia" Visible="false"/>
                                            <asp:BoundField DataField="cod_tipo_garantia" Visible="false"/>
                                       </Columns>
                                        <RowStyle BackColor="#EFF3FB" />
                                        <EditRowStyle BackColor="#2461BF" />
                                        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                        <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                        <AlternatingRowStyle BackColor="White" />
    							    </asp:GridView>
								<br/>
							</td>
						</tr>
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								<P>Información del Giro</P>
							</td>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" colSpan="11">
										    <asp:label id="lblMensaje2" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_Texto">Contabilidad:</td>
										<td>
										    <asp:textbox id="txtConta" tabIndex="7" runat="server" MaxLength="2" BackColor="AntiqueWhite"
												Width="23px">1</asp:textbox>
										</td>
										<td class="td_Texto">Oficina:</td>
										<td><asp:textbox id="txtOfici" tabIndex="8" runat="server" MaxLength="3" BackColor="AntiqueWhite"
												Width="32px"></asp:textbox></td>
										<td class="td_Texto">Moneda:</td>
										<td>
										    <asp:textbox id="txtMon" tabIndex="9" runat="server" MaxLength="2" BackColor="AntiqueWhite" Width="21px"></asp:textbox>
										</td>
										<td class="td_Texto">Producto:</td>
										<td style="WIDTH: 31px">
										    <asp:textbox id="txtProd" tabIndex="10" runat="server" MaxLength="2" BackColor="AntiqueWhite"
												Width="28px"></asp:textbox>
										</td>
										<td class="td_Texto">
										    <asp:label id="Label2" runat="server">Operación:</asp:label>
										</td>
										<td>
										    <asp:textbox id="txtOper" tabIndex="11" runat="server" MaxLength="7" BackColor="AntiqueWhite"
												Width="64px"></asp:textbox>
										</td>
										<td class="td_Texto">
										    <asp:button id="btnAsignar" tabIndex="12" runat="server" Text="Asignar Garantías"></asp:button>
										</td>
									</tr>
									<tr>
										<td colSpan="11"><br/>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table> <!--DEFINE BOTONERA-->
					<table class="table_Default" style="WIDTH: 775px; HEIGHT: 19px" width="775" align="center"
						bgColor="window" border="0">
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

