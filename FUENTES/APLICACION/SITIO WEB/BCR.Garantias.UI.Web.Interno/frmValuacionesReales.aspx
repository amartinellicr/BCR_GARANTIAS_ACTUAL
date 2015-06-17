<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmValuacionesReales.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmValuacionesReales" Title="BCR GARANTIAS - Valuaciones" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="WIDTH: 780px" cellpadding="1" width="780" align="center" bgColor="window"
			    border="0" cellspacing="1">
			    <tr>
				    <td style="HEIGHT: 43px" align="center" colspan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Valuaciones</asp:label></td>
			    </tr>
			    <tr>
				    <td valign="top" colspan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowspan="1">BCR 
								    GARANTIAS&nbsp;- Valuaciones de Garantías Reales</td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" style="table-layout:auto; text-align:center" border="0">
									    <tr>
										    <td align="center" style="width:40%" colspan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colspan="2">
											    <table id="table2" width="100%" style="table-layout:auto; text-align:center" border="0">
												    <tr>
													    <td>
														    <table width="100%" style="table-layout:auto; text-align:center" border="0">
															    <tr>
																    <td class="td_Texto">Tipo Garantía Real:</td>
																    <td class="td_TextoIzq" colspan="3"><asp:dropdownlist id="cbTipoGarantiaReal" tabIndex="1" runat="server" AutoPostBack="true" Enabled="False"
																		    BackColor="AntiqueWhite" Width="174px"></asp:dropdownlist></td>
																    <td class="td_Texto" colspan="3">Clase de Garantía:</td>
																    <td class="td_TextoIzq" colspan="3"><asp:dropdownlist id="cbClase" tabIndex="2" runat="server" Enabled="False" BackColor="AntiqueWhite"
																		    Width="215px"></asp:dropdownlist></td>
															    </tr>
															    <tr>
																    <td class="td_Texto"><asp:label id="lblPartido" runat="server" Font-Italic="true">Partido:</asp:label></td>
																    <td class="td_TextoIzq"><asp:textbox id="txtPartido" tabIndex="3" runat="server" Enabled="False" BackColor="AntiqueWhite"
																		    Width="42px" MaxLength="3"></asp:textbox></td>
																    <td class="td_Texto"><asp:label id="lblFinca" runat="server" Font-Italic="true">Número Finca:</asp:label></td>
																    <td class="td_TextoIzq"><asp:textbox id="txtNumFinca" tabIndex="4" runat="server" Enabled="False" BackColor="AntiqueWhite"
																		    Width="70px" MaxLength="6"></asp:textbox></td>
																    <td class="td_Texto"><asp:label id="lblGrado" runat="server" Font-Italic="true">Grado:</asp:label></td>
																    <td class="td_TextoIzq"><asp:textbox id="txtGrado" tabIndex="5" runat="server" Enabled="False" BackColor="AntiqueWhite"
																		    Width="42px" MaxLength="2"></asp:textbox></td>
																    <td class="td_Texto"><asp:label id="lblCedula" runat="server" Font-Italic="true">Cédula Hipotecaria:</asp:label></td>
																    <td class="td_TextoIzq"><asp:textbox id="txtCedulaHipotecaria" tabIndex="6" runat="server" Enabled="False" BackColor="AntiqueWhite"
																		    Width="42px" MaxLength="2"></asp:textbox></td>
															    </tr>
														    </table>
													    </td>
												    </tr>
												    <tr>
													    <td colspan="10">
														    <table width="100%" style="table-layout:fixed; text-align:left">
															    <tr>
															        <td class="td_Texto" style="width: 207px; height: 25px">Fecha de Valuación:</td>
																    <td class="td_TextoIzq" style="HEIGHT: 25px" colspan="9">
																        <asp:TextBox ID="txtFechaValuacion" BackColor="White" tabIndex="25" runat="server" Width="70px" 
										                                             MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Valuacion del Instrumento" />
                                                                        <asp:ImageButton ID="igbCalendarioValuacion" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                                        <ajaxToolkit:MaskedEditExtender ID="meeFechaValuacion" runat="server"
                                                                            TargetControlID="txtFechaValuacion"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="None"
                                                                            AcceptNegative="None"
                                                                            ErrorTooltipEnabled="True" />
                                                                        <ajaxToolkit:MaskedEditValidator ID="mevFechaValuacion" runat="server"
                                                                            ControlExtender="meeFechaValuacion"
                                                                            ControlToValidate="txtFechaValuacion"
                                                                            EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                            InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                            Display="Dynamic"
                                                                            TooltipMessage="Ingrese una fecha: día/mes/año"
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
                                                                             
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaValuacion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaValuacion" PopupButtonID="igbCalendarioValuacion" />
                                                                    </td>
															    </tr>
															   <tr>
																    <td class="td_Texto" style="WIDTH: 207px">Cédula de Empresa:</td>
																    <td class="td_TextoIzq" colspan="17"><asp:dropdownlist id="cbEmpresa" tabIndex="8" runat="server" Width="462px"></asp:dropdownlist></td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px">Cédula del Perito:</td>
																    <td class="td_TextoIzq" colspan="17"><asp:dropdownlist id="cbPerito" tabIndex="9" runat="server" Width="462px"></asp:dropdownlist></td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px" width="207">Mto Última Tasación Terreno:</td>
																    <td class="td_TextoIzq" style="width:140px" colspan="5">
																        
																        <asp:TextBox ID="txtMontoUltTasacionTerreno" tabIndex="10" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                                             ToolTip="Monto de Última Tasación Terreno" BackColor="AliceBlue" Width="136px" AutoPostBack="false"/>
																	</td>
																    <td class="td_Texto" style="width:30%" colspan="7">Mto Última Tasación no Terreno:</td>
																    <td class="td_TextoIzq" style="width:140px" colspan="5">
																        
																        <asp:TextBox ID="txtMontoUltTasacionNoTerreno" tabIndex="11" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                                             ToolTip="Monto de Última Tasación No Terreno" BackColor="AliceBlue" Width="136px" AutoPostBack="false"  />
																	</td>
															    </tr>
															    <tr>
																    <td></td>
																    <td class="td_TextoLeyenda" colspan="8"><asp:label id="lblLeyenda" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px">Mto Tasación Actualiz. Terreno:</td>
																    <td class="td_TextoIzq" style="HEIGHT: 23px" colspan="5">
																        <asp:TextBox ID="txtMontoTasActTerreno" tabIndex="12" runat="server" AutoPostBack="true" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                                             ToolTip="Monto Tasación Actualizada Terreno" BackColor="AliceBlue" Width="136px" OnTextChanged="txtMontoTasActTerreno_TextChanged" />
																	</td>
																    <td class="td_Texto" style="HEIGHT: 23px" colspan="7">Mto Tasación Actualiz. no Terreno:</td>
																    <td class="td_TextoIzq" style="HEIGHT: 23px"  colspan="5">
																        <asp:TextBox ID="txtMontoTasActNoTerreno" tabIndex="13" runat="server" AutoPostBack="true" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                                             ToolTip="Monto Tasación Actualizada No Terreno" BackColor="AliceBlue" Width="136px" OnTextChanged="txtMontoTasActNoTerreno_TextChanged" />
																	</td>
															    </tr>
															    <tr>
																    <td></td>
																    <td class="td_TextoLeyenda" colspan="8"><asp:label id="Label1" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px">Fecha Último Seguimiento:</td>
																    <td class="td_TextoIzq"  colspan="4">
																        <asp:TextBox ID="txtFechaSeguimiento" BackColor="AliceBlue" tabIndex="14" runat="server" Width="70px" 
										                                             MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha del Último Seguimiento" />
                                                                        <asp:ImageButton ID="igbCalendarioSeguimiento" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                                        <ajaxToolkit:MaskedEditExtender ID="meeFechaSeguimiento" runat="server"
                                                                            TargetControlID="txtFechaSeguimiento"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />
                                                                        <ajaxToolkit:MaskedEditValidator ID="mevFechaSeguimiento" runat="server"
                                                                            ControlExtender="meeFechaSeguimiento"
                                                                            ControlToValidate="txtFechaSeguimiento"
                                                                            EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                            InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                            Display="Dynamic"
                                                                            TooltipMessage="Ingrese una fecha: día/mes/año"
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
                                                                             
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaSeguimiento" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaSeguimiento" PopupButtonID="igbCalendarioSeguimiento" />
																	</td>
																    <td class="td_Texto" colspan="6">Fecha de Construcción:</td>
																    <td class="td_TextoIzq" colspan="4">
																        <asp:TextBox ID="txtFechaConstruccion" BackColor="White" tabIndex="15" runat="server" Width="70px" 
										                                             MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Registro" />
                                                                        <asp:ImageButton ID="igbCalendarioConstruccion" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                                        <ajaxToolkit:MaskedEditExtender ID="meeFechaConstruccion" runat="server"
                                                                            TargetControlID="txtFechaConstruccion"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />
                                                                        <ajaxToolkit:MaskedEditValidator ID="mevFechaConstruccion" runat="server"
                                                                            ControlExtender="meeFechaConstruccion"
                                                                            ControlToValidate="txtFechaConstruccion"
                                                                            EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                            InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                            Display="Dynamic"
                                                                            TooltipMessage="Ingrese una fecha: día/mes/año"
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
                                                                             
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaConstruccion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaConstruccion" PopupButtonID="igbCalendarioConstruccion" />
																	</td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px; HEIGHT: 19px">Recomendación del Perito:</td>
																    <td class="td_TextoIzq" style="HEIGHT: 19px" colspan="2"><asp:dropdownlist id="cbRecomendacion" tabIndex="16" runat="server" Enabled="False"></asp:dropdownlist></td>
																    <td class="td_Texto" style="HEIGHT: 19px" colspan="8">Inspección Menor&nbsp;tres Meses:</td>
																    <td class="td_TextoIzq" style="HEIGHT: 19px" colspan="2"><asp:dropdownlist id="cbInspeccion" tabIndex="17" runat="server" Enabled="False"></asp:dropdownlist></td>
															    </tr>
															    <tr>
																    <td class="td_Texto" style="WIDTH: 207px">Monto Total Avalúo:</td>
																    <td class="td_TextoIzq" colspan="5">
																        <asp:TextBox ID="txtMontoAvaluo" tabIndex="18" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                                             ToolTip="Monto Total Avalúo" BackColor="AliceBlue" Width="136px" Enabled="False" />
																	</td>
															    </tr>
														    </table>
													    </td>
												    </tr>
											    </table>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colspan="2">
										        <asp:button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:button>
										        <asp:button id="btnRegresar" tabIndex="19" runat="server" Text="Regresar" ToolTip="Regresa al formulario anterior"></asp:button>
										        <asp:button id="btnLimpiar" tabIndex="20" runat="server" Text="Limpiar" ToolTip="Limpiar"></asp:button>
										        <asp:button id="btnInsertar" tabIndex="21" runat="server" Text="Insertar" ToolTip="Insertar Valuación"></asp:button>
										        <asp:button id="btnModificar" tabIndex="22" runat="server" Text="Modificar" ToolTip="Modificar Valuación"></asp:button>
										        <asp:button id="btnEliminar" tabIndex="23" runat="server" Text="Eliminar" ToolTip="Eliminar Valuación"></asp:button>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" style="width:100%; background-color:#dcdcdc" colspan="4" rowspan="1"><asp:label id="lblCatalogo" runat="server"></asp:label></td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
								        <asp:GridView ID="gdvValuacionesReales" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="fecha_valuacion,cedula_empresa,cedula_perito,monto_ultima_tasacion_terreno,monto_ultima_tasacion_no_terreno,
                                               fecha_ultimo_seguimiento,fecha_construccion,cod_recomendacion_perito,cod_inspeccion_menor_tres_meses,des_recomendacion_perito,des_inspeccion_menor_tres_meses,
                                               monto_tasacion_actualizada_terreno,monto_tasacion_actualizada_no_terreno,monto_total_avaluo,fecha_presentacion,fecha_constitucion" 
                                             OnRowCommand="gdvValuacionesReales_RowCommand" 
                                             OnPageIndexChanging="gdvValuacionesReales_PageIndexChanging" 
                                             OnRowDataBound="gdvValuacionesReales_RowDataBound"
                                             CssClass="gridview" 
                                             BorderColor="black" >
                                                 <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:ButtonField DataTextField="fecha_valuacion" CommandName="SelectedValuacionReal" HeaderText="Fecha" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_terreno" CommandName="SelectedValuacionReal" HeaderText="Tasación Act. Terreno" Visible="True" ItemStyle-Width="190px" ItemStyle-HorizontalAlign="Center" DataTextFormatString="{0:N2}" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_no_terreno" CommandName="SelectedValuacionReal" HeaderText="Tasación Act. No Terreno" Visible="True" ItemStyle-Width="190px" ItemStyle-HorizontalAlign="Center" DataTextFormatString="{0:N2}" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="monto_total_avaluo" CommandName="SelectedValuacionReal" HeaderText="Monto Total Avalúo" Visible="True" ItemStyle-Width="160px" ItemStyle-HorizontalAlign="Center" DataTextFormatString="{0:N2}" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="cedula_empresa" Visible="False"/>
                                                    <asp:BoundField DataField="cedula_perito" Visible="False"/>
                                                    <asp:BoundField DataField="monto_ultima_tasacion_terreno" Visible="False"/>
                                                    <asp:BoundField DataField="monto_ultima_tasacion_no_terreno" Visible="False"/>
                                                    <asp:BoundField DataField="fecha_ultimo_seguimiento" Visible="False"/>
                                                    <asp:BoundField DataField="fecha_construccion" Visible="False"/>
                                                    <asp:BoundField DataField="cod_recomendacion_perito" Visible="False"/>
                                                    <asp:BoundField DataField="cod_inspeccion_menor_tres_meses" Visible="False"/>
                                                    <asp:BoundField DataField="des_recomendacion_perito" Visible="False"/>
                                                    <asp:BoundField DataField="des_inspeccion_menor_tres_meses" Visible="False"/>
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

<asp:HiddenField ID="hdfTipoBien" runat="server" />

</asp:Content>

