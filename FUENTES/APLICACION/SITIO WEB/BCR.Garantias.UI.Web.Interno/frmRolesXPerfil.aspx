<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmRolesXPerfil.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmRolesXPerfil" Title="BCR GARANTIAS - Mantenimiento de Roles por Perfil" %>

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
				    <td style="WIDTH: 869px">
					    <table id="table3" style="WIDTH: 775px" cellSpacing="1" cellPadding="1" width="775" border="0">
						    <tr>
							    <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Roles por Perfil</asp:label></td>
						    </tr>
						    <tr>
							    <td style="HEIGHT: 58px" colSpan="3">
								    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
									    <tr>
										    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
											    &nbsp;BCR GARANTIAS- Seguridad - Roles por Perfil</td>
									    </tr>
									    <tr>
										    <td>
											    <table width="100%" align="center" border="0">
												    <tr>
													    <td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 289px" width="289"></td>
													    <td width="60%"></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" width="35%" style="HEIGHT: 25px">Perfil:</td>
													    <td width="65%"><asp:dropdownlist id="cbPerfil" runat="server" Width="296px" BackColor="AliceBlue"></asp:dropdownlist></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" style="WIDTH: 289px">Rol:</td>
													    <td>
														    <asp:dropdownlist id="cbRol" runat="server" Width="296px" BackColor="AliceBlue"></asp:dropdownlist></td>
												    </tr>
												    <tr>
													    <td class="td_Texto" colSpan="2">&nbsp;</td>
												    </tr>
												    <tr>
													    <td class="td_Texto" colSpan="2">
														    <asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button>
														    <asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button><asp:button id="btnInsertar" runat="server" Text="Insertar" ToolTip="Insertar Rol por Perfil"></asp:button>
														    <asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Rol por Perfil" Text="Eliminar"></asp:button></td>
												    </tr>
											    </table>
										    </td>
									    </tr>
									    <tr>
										    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1" style="HEIGHT: 19px">Roles 
											    por Perfil&nbsp;</td>
									    </tr>
									    <tr>
										    <td align="center">
										        <br/>
                                                <asp:Panel ID="pnlRolesXPerfil" runat="server" Height="50px" Width="730px" ScrollBars="Auto" HorizontalAlign="Left" ForeColor="#333333" BackColor="AliceBlue">
                                                    <asp:TreeView ID="trvRolesXPerfil" runat="server" ShowExpandCollapse="true" ShowLines="true" ForeColor="Black" ExpandDepth="0"  
                                                     BackColor="AliceBlue" Height="98%" Width="98%" Font-Bold="false"  
                                                     HoverNodeStyle-BackColor="#A5C2EE" HoverNodeStyle-Font-Bold="true" HoverNodeStyle-ForeColor="white"
                                                     SelectedNodeStyle-BackColor="#2461BF" SelectedNodeStyle-Font-Bold="true" SelectedNodeStyle-ForeColor="White" OnSelectedNodeChanged="trvRolesXPerfil_SelectedNodeChanged"
                                                     LeafNodeStyle-Font-Bold="false"
                                                     RootNodeStyle-Font-Bold="true">
                                                    </asp:TreeView>
                                                </asp:Panel>
											    <br/>
										    </td>
									    </tr>
								    </table> <!--DEFINE BOTONERA-->
								    <table class="table_Default" width="60%" align="center" border="0">
									    <tr>
										    <td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">
											    Banco de Costa Rica © Derechos reservados 2006.</td>
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

