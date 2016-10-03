<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmPerfiles.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmPerfiles" Title="BCR GARANTIAS - Perfiles de Seguridad" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Perfiles</asp:label></td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Seguridad -&nbsp;Perfiles</td>
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
										<td class="td_Texto" style="WIDTH: 286px">Descripción del Perfil:</td>
										<td><asp:textbox id="txtPerfil" tabIndex="1" runat="server" CssClass="Txt_Style_Default" Width="299px"
												BackColor="AliceBlue" MaxLength="30"></asp:textbox></td>
									</tr>
									<tr>
										<td class="td_Texto" style="WIDTH: 286px"></td>
										<td></td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">&nbsp;</td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">
											<asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button><asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button><asp:button id="btnInsertar" runat="server" ToolTip="Insertar Perfil" Text="Insertar"></asp:button><asp:button id="btnModificar" runat="server" ToolTip="Modificar Perfil" Text="Modificar"></asp:button><asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Perfil" Text="Eliminar"></asp:button></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Perfiles&nbsp;</td>
						</tr>
						<tr>
							<td align="center">
							    <br/>
							        <asp:GridView ID="gdvPerfiles" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="COD_PERFIL,DES_PERFIL" 
                                         OnRowCommand="gdvPerfiles_RowCommand" 
                                         OnPageIndexChanging="gdvPerfiles_PageIndexChanging" CssClass="gridview" BorderColor="black">
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                             
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="DES_PERFIL" CommandName="SelectedPerfil" HeaderText="Descripción del Perfil" Visible="True" ItemStyle-Width="800px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:BoundField DataField="COD_PERFIL" Visible="False"/>
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

