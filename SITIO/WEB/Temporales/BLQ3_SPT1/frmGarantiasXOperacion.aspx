<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGarantiasXOperacion.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmGarantiasXOperacion" Title="BCR GARANTIAS - Garantías por Operación" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="WIDTH: 775px" cellSpacing="1" cellPadding="1" width="775" align="center"
			    bgColor="window" border="0">
			    <tr>
				    <td style="HEIGHT: 43px" align="center" colSpan="3">
					    <!--TITULO PRINCIPAL-->
					    <center>
					    <b>
						    <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo"> Garantías por Operación</asp:label>
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
								    <P>Información de la Operación</P>
							    </td>
						    <tr>
							    <td style="width: 728px">
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="11"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo de Operación:</td>
										    <td colSpan="10"><asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												    Width="194px">
												    <asp:ListItem Value="1">Operaci&#243;n Crediticia</asp:ListItem>
												    <asp:ListItem Value="2">Contrato</asp:ListItem>
											    </asp:dropdownlist>
											    <asp:Button id="Button1" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:Button></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="25%">Contabilidad:</td>
										    <td width="4%"><asp:textbox id="txtContabilidad" tabIndex="2" runat="server" BackColor="AntiqueWhite" Width="23px"
												    MaxLength="2">1</asp:textbox></td>
										    <td class="td_Texto" width="9%">Oficina:</td>
										    <td width="4%"><asp:textbox id="txtOficina" tabIndex="3" runat="server" BackColor="AntiqueWhite" Width="32px"
												    MaxLength="3"></asp:textbox></td>
										    <td class="td_Texto" width="9%">Moneda:</td>
										    <td width="4%"><asp:textbox id="txtMoneda" tabIndex="4" runat="server" BackColor="AntiqueWhite" Width="21px"
												    MaxLength="2"></asp:textbox></td>
										    <td class="td_Texto" width="9%"><asp:label id="lblProducto" runat="server">Producto:</asp:label></td>
										    <td width="9%"><asp:textbox id="txtProducto" tabIndex="5" runat="server" BackColor="AntiqueWhite" Width="28px"
												    MaxLength="2"></asp:textbox></td>
										    <td class="td_Texto" width="9%"><asp:label id="lblTipoCaptacion" runat="server">Operación:</asp:label></td>
										    <td width="9%"><asp:textbox id="txtOperacion" tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="64px"
												    MaxLength="7"></asp:textbox></td>
										    <td width="14%"><asp:button id="btnValidarOperacion" tabIndex="7" runat="server" ToolTip="Verifica que la operación sea valida"
												    Text="Consultar Garantías" Width="160px"></asp:button></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="WIDTH: 127px"><asp:label id="lblDeudor" runat="server" Visible="False" Font-Italic="true" ForeColor="steelblue">Deudor:</asp:label></td>
										    <td class="td_TextoIzq" colSpan="10"><asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Italic="true" ForeColor="steelblue"></asp:label></td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								    rowSpan="1"><asp:label id="lblCatalogo" runat="server"> Garantías</asp:label></td>
						    </tr>
						    <tr>
							    <td style="width:728px">
							        <br/>
    							        <asp:GridView ID="gdvGarantiasOperacion" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="garantia" CssClass="gridview" BorderColor="black" OnPageIndexChanging="gdvGarantiasOperacion_PageIndexChanging" >
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10"/>
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:BoundField HeaderText="Garantías" DataField="garantia" ItemStyle-Width="800" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
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
    </contenttemplate>
</asp:UpdatePanel>
</asp:Content>

