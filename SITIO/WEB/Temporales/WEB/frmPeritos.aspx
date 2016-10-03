<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmPeritos.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmPeritos" Title="BCR GARANTIAS - Peritos" %>

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
				    <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Peritos</asp:label></td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								    GARANTIAS&nbsp;- Peritos</td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px"></td>
										    <td width="70%"></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Cédula del Perito:</td>
										    <td><asp:textbox id="txtCedula" runat="server" CssClass="Txt_Style_Default" MaxLength="30" ToolTip="Cédula del Perito"
												    BackColor="AliceBlue" Width="128px"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Nombre del&nbsp;Perito:</td>
										    <td><asp:textbox id="txtNombre" tabIndex="1" runat="server" CssClass="Txt_Style_Default" MaxLength="100"
												    ToolTip="Nombre del Perito" BackColor="AliceBlue" Width="383px"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px; HEIGHT: 18px">Tipo de Persona:</td>
										    <td style="HEIGHT: 18px"><asp:dropdownlist id="cbTipo" tabIndex="2" runat="server" BackColor="AliceBlue" Width="274px"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Teléfono:</td>
										    <td><asp:textbox id="txtTelefono" tabIndex="3" runat="server" CssClass="Txt_Style_Default" MaxLength="10"
												    ToolTip="Teléfono del Perito" BackColor="White" Width="128px"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Correo Electrónico:</td>
										    <td><asp:textbox id="txtEmail" tabIndex="4" runat="server" CssClass="Txt_Style_Default" MaxLength="50"
												    ToolTip="Correo Electrónico del Perito" BackColor="White" Width="383px"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 250px">Dirección:</td>
										    <td><asp:textbox id="txtDireccion" tabIndex="5" runat="server" CssClass="Txt_Style_Default" MaxLength="250"
												    ToolTip="Dirección del Perito" BackColor="AliceBlue" Width="383px" TextMode="MultiLine" Height="65px"></asp:textbox></td>
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
											    <asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button><asp:button id="btnLimpiar" tabIndex="6" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button><asp:button id="btnInsertar" tabIndex="7" runat="server" ToolTip="Insertar Perito" Text="Insertar"></asp:button><asp:button id="btnModificar" tabIndex="8" runat="server" ToolTip="Modificar Perito" Text="Modificar"></asp:button><asp:button id="btnEliminar" tabIndex="9" runat="server" ToolTip="Eliminar Perito" Text="Eliminar"></asp:button></td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1"><asp:label id="lblCatalogo" runat="server"></asp:label></td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
								        <asp:GridView ID="gdvPeritos" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="cod_tipo_persona,des_tipo_persona,cedula_perito,des_perito,des_telefono,des_email,des_direccion" 
                                             OnRowCommand="gdvPeritos_RowCommand" 
                                             OnPageIndexChanging="gdvPeritos_PageIndexChanging" CssClass="gridview" BorderColor="black" >
                                                 <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:BoundField DataField="cod_tipo_persona" Visible="False"/>
                                                    <asp:ButtonField DataTextField="des_tipo_persona" CommandName="SelectedPerito" HeaderText="Tipo de Persona" Visible="True" ItemStyle-Width="230px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="cedula_perito" CommandName="SelectedPerito" HeaderText="Cédula" Visible="True" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_perito" CommandName="SelectedPerito" HeaderText="Nombre del Perito" Visible="True" ItemStyle-Width="250px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_telefono" CommandName="SelectedPerito" HeaderText="Teléfono" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_email" CommandName="SelectedPerito" HeaderText="Correo Electrónico" Visible="True" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="des_direccion" CommandName="SelectedPerito" HeaderText="Dirección" Visible="True" ItemStyle-Width="250px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
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

