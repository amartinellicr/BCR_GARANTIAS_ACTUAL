<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmDownload.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmDownload" Title="BCR GARANTIAS - Archivos SEGUI" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Descarga de Archivos de Garantías</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1" style="HEIGHT: 19px">BCR 
								GARANTIAS&nbsp;- Archivos de Garantías
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center">
										    <asp:label id="lblMensaje" runat="server" CssClass="TextoError" ForeColor="Red"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_TextoCenter">
										    <asp:GridView ID="gdvArchivos" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="651px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="nombre,url,size,date,type" 
                                         OnRowCommand="gdvArchivos_RowCommand" 
                                         OnPageIndexChanging="gdvArchivos_PageIndexChanging" CssClass="gridview" BorderColor="black" Font-Size="12px">
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10"/>
                                             
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" Font-Size="12px" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="nombre" CommandName="SelectedFile" HeaderText="Nombre" Visible="True" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" ItemStyle-Font-Size="12px"/>
                                                <asp:ButtonField DataTextField="url" CommandName="" HeaderText="" Visible="false" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" ItemStyle-Font-Size="12px"/>
                                                <asp:ButtonField DataTextField="size" CommandName="SelectedFile" HeaderText="Tama&#241;o (Bytes)" Visible="True" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" ItemStyle-Font-Size="12px"/>
                                                <asp:ButtonField DataTextField="date" CommandName="SelectedFile" HeaderText="Fecha de Modificaci&#243;n" Visible="True" ItemStyle-Width="180px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" ItemStyle-Font-Size="12px"/>
                                                <asp:ButtonField DataTextField="type" CommandName="SelectedFile" HeaderText="Tipo" Visible="True" ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" ItemStyle-Font-Size="12px"/>
                                            </Columns>
                                            <RowStyle BackColor="#EFF3FB" />
                                            <EditRowStyle BackColor="#2461BF" />
                                            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Font-Size="12px" />
                                            <AlternatingRowStyle BackColor="White" />
							            </asp:GridView>  
										</td>
									</tr>
									<tr>
										<td><br>
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

