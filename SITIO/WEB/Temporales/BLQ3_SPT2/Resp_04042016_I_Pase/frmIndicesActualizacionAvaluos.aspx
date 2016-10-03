<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmIndicesActualizacionAvaluos.aspx.cs" Inherits="frmIndicesActualizacionAvaluos" Title="Indices de Actualización de Avalúos" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>

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
				        <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Indices de Actualización de Avalúos</asp:label></td>
			        </tr>
			        <tr>
				        <td vAlign="top" colSpan="3">
					        <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								        GARANTIAS&nbsp;- Indices de Actualización de Avalúos</td>
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
										        <td class="td_Texto" style="WIDTH: 286px; height: 26px;">Fecha:</td>
										        <td style="height: 26px">
										            <asp:textbox id="txtFechaRegistro" tabIndex="1" runat="server" Width="96px" BackColor="AliceBlue"  
										                MaxLength="1" style="text-align:justify">
										            </asp:textbox>
										            <asp:ImageButton ID="igbCalendarioRegistro" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="true" />
                                                    <ajaxToolkit:MaskedEditExtender ID="meeFechaRegistro" runat="server"
                                                        TargetControlID="txtFechaRegistro"
                                                        Mask="99/99/9999"
                                                        MessageValidatorTip="true"
                                                        OnFocusCssClass="MaskedEditFocus"
                                                        OnInvalidCssClass="MaskedEditError"
                                                        MaskType="Date"
                                                        DisplayMoney="Left"
                                                        AcceptNegative="Left"
                                                        ErrorTooltipEnabled="True" />
                                                    <ajaxToolkit:CalendarExtender ID="cleFechaRegistro" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaRegistro" PopupButtonID="igbCalendarioRegistro" />

										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="WIDTH: 286px">Tipo de Cambio:</td>
										        <td>
										            <asp:textbox id="txtTipoCambio" tabIndex="2" runat="server" CssClass="id-tabla-texto" Width="116px"
												        BackColor="AliceBlue" MaxLength="17" ToolTip="Monto de la compra del dólar, según el Banco Central de Costa Rica. Utilice el punto como separador de decimales.">
										            </asp:textbox>
										        </td>
								        </tr>
									        <tr>
										        <td class="td_Texto" style="WIDTH: 286px">Indice de Precios al Consumidor:</td>
										        <td>
										            <asp:textbox id="txtIndicePreciosConsumidor" tabIndex="3" runat="server" CssClass="id-tabla-texto" Width="116px"
												        BackColor="AliceBlue" MaxLength="17" ToolTip="Monto del índice de precios al consumidor, según el Banco Central de Costa Rica. Utilice el punto como separador de decimales.">
										            </asp:textbox>
										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" colSpan="2">&nbsp;</td>
									        </tr>
									        <tr>
										        <td class="td_Texto" colSpan="2">
											        <asp:button id="btnInsertar" runat="server" ToolTip="Insertar Registro" Text="Insertar" tabIndex="4"></asp:button>
										        </td>
									        </tr>
								        </table>
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								        <asp:Label id="lblIAA" runat="server">Ultimo Registro</asp:Label></td>
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

