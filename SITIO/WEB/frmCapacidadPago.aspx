<%@ Page Language="C#" ValidateRequest="false" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmCapacidadPago.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmCapacidadPago" Title="BCR GARANTIAS - Capacidades de Pago" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto" >
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="WIDTH: 775px" cellpadding="1" align="center" bgColor="window" border="0" cellspacing="1">
			    <tr>
				    <td style="HEIGHT: 43px" align="center" colspan="3">
				        <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Información Deudor / Codeudor</asp:label>
				    </td>
			    </tr>
			    <tr>
				    <td valign="top" colspan="2">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowspan="1">BCR 
								    GARANTIAS&nbsp;- Deudores/Codeudores - Capacidades de Pago</td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" width="40%" colspan="2">
										        <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto"></td>
										    <td width="60%">
											    <asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 28px">Cédula del Deudor/Codeudor:</td>
										    <td style="HEIGHT: 28px"><asp:textbox id="txtCedula" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												    Width="128px" ToolTip="Cédula del Deudor" MaxLength="80" Enabled="False" tabIndex="1"></asp:textbox>
											    <asp:Button id="btnValidarDeudor" runat="server" Text="Validar Deudor" Visible="False" tabIndex="2"></asp:Button>
											    <asp:TextBox id="txtTipoRegistroDeudor" runat="server" Visible="False"></asp:TextBox>
											    <asp:TextBox id="txtDescripcionTipoRegistroDeudor" runat="server" Visible="False"></asp:TextBox> 
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Nombre del Deudor/Codeudor:</td>
										    <td>
										        <asp:textbox id="txtNombre" tabIndex="3" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												    Width="343px" ToolTip="Nombre del Deudor" MaxLength="50" Enabled="False"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo de Persona:</td>
										    <td>
											    <asp:DropDownList id="cbTipo" runat="server" Width="276px" BackColor="AliceBlue" Enabled="False" tabIndex="1"></asp:DropDownList>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Condiciones Especiales:</td>
										    <td>
											    <asp:DropDownList id="cbCondicion" runat="server" Width="276px" BackColor="White" tabIndex="4"></asp:DropDownList>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo de Asignación:</td>
										    <td>
											    <asp:dropdownlist id="cbTipoAsignacion" tabIndex="5" runat="server" BackColor="White" Width="476px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 19px">Indicador de Generador de Divisas:</td>
										    <td style="HEIGHT: 19px">
											    <asp:dropdownlist id="cbGenerador" tabIndex="6" runat="server" BackColor="AliceBlue" Width="344px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 20px">Indicador de Vinculado a Entidad:</td>
										    <td style="HEIGHT: 20px">
											    <asp:dropdownlist id="cbVinculadoEntidad" tabIndex="7" runat="server" BackColor="AliceBlue" Width="136px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 20px">Tipo de Deudor:</td>
										    <td style="HEIGHT: 20px">
											    <asp:dropdownlist id="cbTipoRegistroDeudor" tabIndex="8" runat="server" BackColor="AliceBlue" Width="136px" Enabled="False">
											        <asp:ListItem Value="-1" Text=""></asp:ListItem>
											        <asp:ListItem Value="0">Deudor</asp:ListItem>
                                                    <asp:ListItem Value="1">Codeudor</asp:ListItem>
                                                    <asp:ListItem Value="2">Deudor/Codeudor</asp:ListItem>
											    </asp:dropdownlist>
										    </td>
									    </tr>
									    <tr style="height:20px;">
							                <td class="td_Texto"></td>
							                <td></td>
						                </tr>
									    <tr>
										    <td class="td_Texto" colspan="2">
											    <asp:Button id="btnModificarDeudor" runat="server" Text="Modificar"></asp:Button>
										    </td>
									    </tr>
								    </table>
								</td>
							</tr>
							<tr>
				                <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowspan="1">
				                    <asp:label id="lblTituloSeccionCapacidaPago" runat="server">Información sobre la Capacidad de Pago</asp:label>
				                </td>
			                </tr>
		                    <tr>
						        <td>
						            <table width="100%" style="text-align:left;" border="0">
						                <tr style="height:20px;">
			                                <td class="td_Texto"></td>
			                                <td></td>
		                                </tr>
									    <tr>
							                <td class="td_Texto" style="width:235px;">Fecha de Valuación:</td>
							                <td>
							                    <asp:TextBox ID="txtFechaValuacion" tabIndex="4" runat="server" Width="130px" BackColor="AliceBlue" MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Valuación" Enabled="False" />
                                                <asp:ImageButton ID="igbCalendario" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="False" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaValuacion" runat="server"
                                                    TargetControlID="txtFechaValuacion"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mkvFecha" runat="server"
                                                    ControlExtender="meeFechaValuacion"
                                                    ControlToValidate="txtFechaValuacion"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaValuacion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaValuacion" PopupButtonID="igbCalendario" />
                                            </td>
						                </tr>
						                <tr>
							                <td class="td_Texto" style="width:235px;">Nivel de Capacidad de Pago:</td>
							                <td>
							                    <asp:dropdownlist id="cbCapacidadPago" tabIndex="5" runat="server" Width="136px" BackColor="AliceBlue"></asp:dropdownlist>
							                </td>
						                </tr>
						                <tr>
							                <td class="td_Texto" style="height: 26px; width:235px;">% Sensibilidad Tipo de Cambio:</td>
							                <td class="td_TextoIzq" style="HEIGHT: 26px" valign="top">
							                    <asp:TextBox ID="txtSensibilidad" tabIndex="6" runat="server" CssClass="id-tabla-texto" MaxLength="6" ToolTip="% Sensibilidad al Tipo de Cambio" BackColor="AliceBlue" />
							                </td>
						                </tr>
						                <tr>
							                <td class="td_Texto"></td>
							                <td></td>
						                </tr>
						                <tr>
							                <td class="td_Texto" colspan="2">&nbsp;</td>
						                </tr>
						                <tr>
							                <td class="td_Texto" colspan="2">
								                <asp:Button id="btnRegresar" runat="server" ToolTip="Regresa al formulario anterior" Text="Regresar" tabIndex="7"></asp:Button>
									                <asp:button id="btnLimpiar" tabIndex="8" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button>
									                <asp:button id="btnInsertar" tabIndex="9" runat="server" ToolTip="Insertar Capacidad de Pago" Text="Insertar"></asp:button>
									                <asp:button id="btnModificar" tabIndex="10" runat="server" ToolTip="Modificar Capacidad de Pago" Text="Modificar" Visible="False"></asp:button>
									                <asp:button id="btnEliminar" tabIndex="11" runat="server" ToolTip="Eliminar Capacidad de Pago" Text="Eliminar"></asp:button>
							                </td>
						                </tr>
							        </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowspan="1">
							        <asp:label id="lblCatalogo" runat="server"></asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
							            <asp:GridView ID="gdvCapacidadPago" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="cod_capacidad_pago, fecha_capacidad_pago, des_capacidad_pago, sensibilidad_tipo_cambio" 
                                         OnRowCommand="gdvCapacidadPago_RowCommand" 
                                         OnPageIndexChanging="gdvCapacidadPago_PageIndexChanging" CssClass="gridview" BorderColor="black" >
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                             
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="fecha_capacidad_pago" CommandName="SelectedCapacidadPago" HeaderText="Fecha" Visible="True" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" DataTextFormatString="{0:dd/MM/yyyy}"/>
                                                <asp:ButtonField DataTextField="des_capacidad_pago" CommandName="SelectedCapacidadPago" HeaderText="Capacidad de Pago" Visible="True" ItemStyle-Width="250px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="sensibilidad_tipo_cambio" CommandName="SelectedCapacidadPago" HeaderText="Sensibilidad Tipo Cambio" Visible="True" ItemStyle-Width="300px" ItemStyle-HorizontalAlign="Center" DataTextFormatString="{0:N2}" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <%--<asp:BoundField DataField="cedula_deudor" Visible="false"/>
                                                <asp:BoundField DataField="nombre_deudor" Visible="false"/>--%>
                                                <asp:BoundField DataField="cod_capacidad_pago" Visible="false"/>
                                            </Columns>
                                            <RowStyle BackColor="#EFF3FB" BorderColor="black"/>
                                            <EditRowStyle BackColor="#2461BF" BorderColor="black"/>
                                            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" BorderColor="black"/>
                                            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" BorderColor="black"/>
                                            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" BorderColor="black"/>
                                            <AlternatingRowStyle BackColor="White" BorderColor="black"/>
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
