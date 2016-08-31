<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmEmpresas.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmEmpresas" Title="BCR GARANTIAS - Empresas Consultoras" %>

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
				    <td style="HEIGHT: 43px" align="center" colSpan="3">
				        <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Empresas</asp:label>
				    </td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1" style="HEIGHT: 19px">
								    BCR GARANTIAS&nbsp;- Empresas
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
										    <td class="td_Texto" style="WIDTH: 250px"></td>
										    <td width="70%"></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">
											    Cédula Jurídica:
										    </td>
										    <td>
											    <asp:textbox id="txtCedula" runat="server" CssClass="Txt_Style_Default" Width="128px" BackColor="AliceBlue"
												    ToolTip="Cédula Jurídica de la Empresa" MaxLength="30" tabIndex="1"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Nombre de la Empresa:</td>
										    <td>
											    <asp:textbox id="txtNombre" tabIndex="2" runat="server" CssClass="Txt_Style_Default" Width="383px"
												    BackColor="AliceBlue" ToolTip="Nombre de la Empresa" MaxLength="100"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Teléfono:</td>
										    <td>
											    <asp:textbox id="txtTelefono" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="128px"
												    BackColor="White" ToolTip="Teléfono de la Empresa" MaxLength="10"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Correo Electrónico:</td>
										    <td>
											    <asp:textbox id="txtEmail" tabIndex="4" runat="server" CssClass="Txt_Style_Default" Width="383px"
												    BackColor="White" ToolTip="Correo Electrónico de la Empresa" MaxLength="50"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Dirección:</td>
										    <td>
											    <asp:textbox id="txtDireccion" tabIndex="5" runat="server" CssClass="Txt_Style_Default" Height="65px"
												    Width="383px" BackColor="AliceBlue" ToolTip="Dirección de la Empresa" MaxLength="250" TextMode="MultiLine"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px; HEIGHT: 21px"></td>
										    <td style="HEIGHT: 21px"></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">
											    <asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button><asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar" tabIndex="6"></asp:button><asp:button id="btnInsertar" runat="server" ToolTip="Insertar Empresa" Text="Insertar" tabIndex="7"></asp:button><asp:button id="btnModificar" runat="server" ToolTip="Modificar Empresa" Text="Modificar" tabIndex="8"></asp:button><asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Empresa" Text="Eliminar" tabIndex="9"></asp:button>
									        </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								    <asp:Label id="lblCatalogo" runat="server"></asp:Label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
						                <asp:GridView ID="gdvEmpresas" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="cedula_empresa,des_empresa,des_telefono,des_email,des_direccion" 
                                             OnRowCommand="gdvEmpresas_RowCommand" 
                                             OnPageIndexChanging="gdvEmpresas_PageIndexChanging" CssClass="gridview" BorderColor="black">
                                                 <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:ButtonField DataTextField="cedula_empresa" CommandName="SelectedEmpresa" HeaderText="Cédula" Visible="True" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_empresa" CommandName="SelectedEmpresa" HeaderText="Empresa" Visible="True" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_telefono" CommandName="SelectedEmpresa" HeaderText="Teléfono" Visible="True" ItemStyle-Width="100px" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_email" CommandName="SelectedEmpresa" HeaderText="Correo Electrónico" Visible="True" ItemStyle-Width="100px" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_direccion" CommandName="SelectedEmpresa" HeaderText="Dirección" Visible="True" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
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

