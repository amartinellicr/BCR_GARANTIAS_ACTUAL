<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmUsuarios.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmUsuarios" Title="BCR GARANTIAS - Usuarios" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			    border="0" cellSpacing="1">
			    <tr>
				    <td style="WIDTH: 869px">
					    <table id="table3" style="WIDTH: 775px" cellSpacing="1" cellPadding="1" width="775" border="0">
						    <tr>
							    <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Usuarios</asp:label></td>
						    </tr>
						    <tr>
							    <td style="HEIGHT: 58px" colSpan="3">
								    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
									    <tr>
										    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
											    GARANTIAS&nbsp;-&nbsp;Seguridad - Usuarios</td>
									    </tr>
									    <tr>
										    <td>
											    <table width="100%" align="center" border="0">
												    <tr>
													    <td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 286px" width="286"></td>
													    <td width="60%"><asp:button id="Button2" runat="server" BorderColor="White" BorderStyle="None" BackColor="White"></asp:button></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 286px" width="286">Número de Identificación:</td>
													    <td width="60%"><asp:textbox id="txtID" tabIndex="1" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
															    MaxLength="30"></asp:textbox><asp:button id="btnValidar" runat="server" ToolTip="Valida el usuario contra el Active Directory"
															    Text="Validar Usuario" Width="146px"></asp:button></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 286px">Nombre del Usuario:</td>
													    <td><asp:textbox id="txtNombre" tabIndex="1" runat="server" CssClass="Txt_Style_Default" BackColor="White"
															    MaxLength="30" Width="299px" Enabled="False"></asp:textbox></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 286px">Perfil Asociado:</td>
													    <td><asp:dropdownlist id="cbPerfil" runat="server" BackColor="AliceBlue" Width="296px"></asp:dropdownlist></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" colSpan="2">&nbsp;</td>
												    </tr>
												    <tr>
													    <td class="td_Texto" colSpan="2"><asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button><asp:button id="btnInsertar" runat="server" ToolTip="Insertar Usuario" Text="Insertar"></asp:button><asp:button id="btnModificar" runat="server" ToolTip="Modificar Usuario" Text="Modificar"></asp:button><asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Usuario" Text="Eliminar"></asp:button></td>
												    </tr>
											    </table>
										    </td>
									    </tr>
									    <tr>
										    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Usuarios&nbsp;</td>
									    </tr>
									    <tr>
										    <td align="center">
										        <br/>
											        <asp:GridView ID="gdvUsuarios" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                                         AutoGenerateColumns="False" DataKeyNames="COD_USUARIO,DES_USUARIO,DES_PERFIL" 
                                                         OnRowCommand="gdvUsuarios_RowCommand" 
                                                         OnPageIndexChanging="gdvUsuarios_PageIndexChanging" CssClass="gridview" BorderColor="black" >
                                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                             
                                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                            <Columns>
                                                                <asp:ButtonField DataTextField="COD_USUARIO" CommandName="SelectedUsuario" HeaderText="Identificación" Visible="True" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                                <asp:ButtonField DataTextField="DES_USUARIO" CommandName="SelectedUsuario" HeaderText="Nombre del Usuario" Visible="True" ItemStyle-Width="450px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                                <asp:ButtonField DataTextField="DES_PERFIL" CommandName="SelectedUsuario" HeaderText="Perfil" Visible="True" ItemStyle-Width="250px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
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
				    </td>
			    </tr>
		    </table>
        </div>
    </contenttemplate>
</asp:UpdatePanel>
</asp:Content>

