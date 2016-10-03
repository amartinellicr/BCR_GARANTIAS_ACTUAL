<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmConsultaHistoricoIndicesValuaciones.aspx.cs" Inherits="Consultas_frmConsultaHistoricoIndicesValuaciones" Title="Untitled Page" %>
<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo">Histórico de Indices de Valuaciones</asp:label></td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Histórico de Indices de Valuaciones</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									</tr>
									<tr>
										<td class="td_Texto" style="WIDTH: 286px" width="286"></td>
										<td width="60%"></td>
									</tr>
									<tr>
										<td class="td_Texto" style="WIDTH: 286px; height: 26px;">Año:</td>
										<td style="height: 26px">
										    <asp:DropDownList id="ddlAnno" style="POSITION:relative; vertical-align:middle"
                                                runat="server" Width="100px" Height="28px" Visible="true"  TabIndex="3">
                                            </asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" style="WIDTH: 286px">Mes:</td>
										<td>
										    <asp:DropDownList id="ddlMes" style="POSITION:relative; vertical-align:middle"
                                                runat="server" Width="100px" Height="28px" Visible="true"  TabIndex="3">
                                                <asp:ListItem Value="1">Enero</asp:ListItem>
                                                <asp:ListItem Value="2">Febrero</asp:ListItem>
                                                <asp:ListItem Value="3">Marzo</asp:ListItem>
                                                <asp:ListItem Value="4">Abril</asp:ListItem>
                                                <asp:ListItem Value="5">Mayo</asp:ListItem>
                                                <asp:ListItem Value="6">Junio</asp:ListItem>
                                                <asp:ListItem Value="7">Julio</asp:ListItem>
                                                <asp:ListItem Value="8">Agosto</asp:ListItem>
                                                <asp:ListItem Value="9">Septiembre</asp:ListItem>
                                                <asp:ListItem Value="10">Octubre</asp:ListItem>
                                                <asp:ListItem Value="11">Noviembre</asp:ListItem>
                                                <asp:ListItem Value="12">Diciembre</asp:ListItem>
                                           </asp:DropDownList>
										</td>
								    </tr>
									<tr>
										<td class="td_Texto" colSpan="2">&nbsp;</td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">
											<asp:button id="btnConsultar" runat="server" ToolTip="Consultar histórico" Text="Consultar" tabIndex="4"></asp:button>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								<asp:Label id="lblIAA" runat="server">Histórico de Indices</asp:Label></td>
						</tr>
						<tr>
							<td align="center">
							    <br/>
							        <asp:GridView ID="gdvIndicesAA" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="false" AllowSorting="false"
                                     AutoGenerateColumns="False" DataKeyNames="FechaHora,TipoCambio,IndicePreciosConsumidor" 
                                     CssClass="gridview" BorderColor="black">
                                        <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                        <Columns>
                                            <asp:BoundField DataField="FechaHora" HeaderText="Fecha" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" DataFormatString="{0:d}"/>
                                            <asp:BoundField DataField="TipoCambio" HeaderText="Tipo de Cambio" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="IndicePreciosConsumidor" HeaderText="Indice de Precios al Consumidor" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                       </Columns>
                                        <RowStyle BackColor="#EFF3FB" />
                                        <EditRowStyle BackColor="#2461BF" />
                                        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                        <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                        <AlternatingRowStyle BackColor="White" />
                                        <EmptyDataTemplate></EmptyDataTemplate>
						            </asp:GridView>  
								<br/>
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

