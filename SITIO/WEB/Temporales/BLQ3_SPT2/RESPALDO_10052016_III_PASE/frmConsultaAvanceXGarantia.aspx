<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" EnableEventValidation="false" AutoEventWireup="true" CodeFile="frmConsultaAvanceXGarantia.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmConsultaAvanceXGarantia" Title="BCR GARANTIAS - Consulta" %>

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
				        <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Avance por Oficina Cliente</asp:label>
				    </td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 18px" width="100%" bgColor="#dcdcdc" colSpan="4"
								    rowSpan="1">BCR GARANTIAS&nbsp;- Filtros de Consulta
							    </td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="2">
										        <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="30%">Fecha de Actualización:</td>
										    <td>
										        <asp:TextBox ID="txtFechaCorte" tabIndex="1" runat="server" BackColor="AliceBlue"  Width="130px" MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Valuación" />
                                                <asp:ImageButton ID="igbCalendario" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="False" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaCorte" runat="server"
                                                    TargetControlID="txtFechaCorte"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mkvFechaCorte" runat="server"
                                                    ControlExtender="meeFechaCorte"
                                                    ControlToValidate="txtFechaCorte"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaCorte" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaCorte" PopupButtonID="igbCalendario" />
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Oficina Cliente:</td>
										    <td>
										        <asp:dropdownlist id="cbOficina" tabIndex="2" runat="server" BackColor="AliceBlue" Width="362px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 21px">Tipo de Operación:</td>
										    <td style="HEIGHT: 21px">
										        <asp:dropdownlist id="cbTipoCaptacion" tabIndex="3" runat="server" BackColor="AliceBlue" Width="194px">
												    <asp:ListItem Value="1">Operaciones Crediticias</asp:ListItem>
												    <asp:ListItem Value="2">Contratos</asp:ListItem>
											    </asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 22px">Tipo de Reporte:</td>
										    <td style="HEIGHT: 22px">
										        <asp:dropdownlist id="cbTipoReporte" tabIndex="4" runat="server" BackColor="AliceBlue" Width="362px">
												    <asp:ListItem Value="1" Selected="true">Resumen consolidado de garant&#237;as por oficina cliente</asp:ListItem>
												    <asp:ListItem Value="3">Detalle de garant&#237;as por oficina cliente</asp:ListItem>
												    <asp:ListItem Value="2">Resumen consolidado de operaciones por oficina cliente</asp:ListItem>
												    <asp:ListItem Value="4">Detalle de operaciones por oficina cliente</asp:ListItem>
											    </asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 22px">Estado&nbsp;del Registro:</td>
										    <td style="HEIGHT: 22px">
										        <asp:dropdownlist id="cbTipo" tabIndex="5" runat="server" BackColor="AliceBlue" Width="153px">
												    <asp:ListItem Value="-1">[TODOS]</asp:ListItem>
												    <asp:ListItem Value="1">Completo</asp:ListItem>
												    <asp:ListItem Value="2">Pendiente</asp:ListItem>
											    </asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">
										        <br>
											    <asp:button id="btnConsultar" tabIndex="7" runat="server" Text="Consultar"></asp:button>
											    <asp:button id="btnExportar" tabIndex="8" runat="server" Text="Exportar a Excel" Enabled="False"></asp:button>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
							        <asp:label id="lblCatalogo" runat="server"></asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
								    <table class="table_Default" width="100%" border="0">
									    <tr>
										    <td class="TextoConsulta" align="right" width="30%">
										        <asp:label id="Label1" runat="server">% Avance: </asp:label>
										    </td>
										    <td class="TextoAvance" width="20%">
										        <asp:label id="lblAvance" runat="server"></asp:label>
										    </td>
										    <td class="TextoConsulta" align="right" width="20%">
										        <asp:label id="Label2" runat="server">% Pendiente:</asp:label>
										    </td>
										    <td class="TextoPendiente" width="30%">
										        <asp:label id="lblPendiente" runat="server"></asp:label>
										    </td>
									    </tr>
								    </table>
								    <br/>
                                        <asp:Panel ID="Panel1" runat="server" Height="100%" Width="100%" ScrollBars="Auto">
								            <asp:GridView ID="gdvReporte" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" 
                                             OnRowCommand="gdvReporte_RowCommand" 
                                             OnPageIndexChanging="gdvReporte_PageIndexChanging" 
                                             OnDataBinding="gdvReporte_DataBinding" 
                                             CssClass="gridview" > 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <RowStyle BackColor="#EFF3FB" BorderColor="Black" />
                                                <EditRowStyle BackColor="#2461BF" BorderColor="Black" />
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" BorderColor="Black" />
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center"/>
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" BorderColor="Black" />
                                                <AlternatingRowStyle BackColor="White" />
                                                
    							            </asp:GridView>
   							            </asp:Panel>
								    <br/>
								    <P></P>
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
    <Triggers>
    <asp:PostBackTrigger ControlID="btnExportar" />
    <asp:PostBackTrigger ControlID="btnConsultar" />
    </Triggers>
</asp:UpdatePanel>
</asp:Content>

