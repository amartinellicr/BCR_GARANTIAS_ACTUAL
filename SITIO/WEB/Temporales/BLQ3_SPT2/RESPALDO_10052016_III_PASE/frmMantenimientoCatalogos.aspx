<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmMantenimientoCatalogos.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmMantenimientoCatalogos" Title="BCR GARANTIAS - Catálogos" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
			<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
				border="0" cellSpacing="1">
				<tr>
					<td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Catálogos</asp:label></td>
				</tr>
				<tr>
					<td vAlign="top" colSpan="3">
						<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
							<tr>
								<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
									GARANTIAS&nbsp;- Catálogos</td>
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
											<td class="td_Texto" style="WIDTH: 286px">Código:</td>
											<td><asp:textbox id="txtCodigo" tabIndex="1" runat="server" CssClass="Txt_Style_Default" Width="63px"
													BackColor="AliceBlue" MaxLength="5"></asp:textbox></td>
										</tr>
										<tr>
											<td class="td_Texto" style="WIDTH: 286px">Descripción:</td>
											<td><asp:textbox id="txtDescripcion" tabIndex="1" runat="server" CssClass="Txt_Style_Default" Width="299px"
													BackColor="AliceBlue" MaxLength="150"></asp:textbox></td>
										</tr>
										<tr>
											<td class="td_Texto" style="WIDTH: 286px"></td>
											<td>
												<asp:Label id="lblElemento" runat="server" Visible="False"></asp:Label></td>
										</tr>
										<tr>
											<td class="td_Texto" colSpan="2">&nbsp;</td>
										</tr>
										<tr>
											<td class="td_Texto" colSpan="2">
												<asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button>
												<asp:Button id="btnRegresar" tabIndex="2" runat="server" Text="Regresar"></asp:Button><asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar" tabIndex="3"></asp:button><asp:button id="btnInsertar" runat="server" ToolTip="Insertar Campo" Text="Insertar" tabIndex="4"></asp:button><asp:button id="btnModificar" runat="server" ToolTip="Modificar Campo" Text="Modificar" tabIndex="5"></asp:button><asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Campo" Text="Eliminar" tabIndex="6"></asp:button></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
									<asp:Label id="lblCatalogo" runat="server"></asp:Label></td>
							</tr>
							<tr>
								<td align="center">
								    <br/>
								        <asp:GridView ID="gdvCatalogos" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="cat_elemento,cat_catalogo,cat_campo,cat_descripcion" 
                                         OnRowCommand="gdvCatalogos_RowCommand" 
                                         OnPageIndexChanging="gdvCatalogos_PageIndexChanging" CssClass="gridview" BorderColor="black">
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                             
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="cat_campo" CommandName="SelectedCatalogo" HeaderText="Código" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="cat_descripcion" CommandName="SelectedCatalogo" HeaderText="Descripción" Visible="True" ItemStyle-Width="630px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:BoundField DataField="cat_elemento" Visible="false"/>
                                                <asp:BoundField DataField="cat_catalogo" Visible="false"/>
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
     </contenttemplate>
</asp:UpdatePanel>
</asp:Content>

