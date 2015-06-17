<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGarantiasValor.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmGarantiasValor" Title="BCR GARANTIAS - Garantías Valor" %>

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
				    <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Garantías de Valor</asp:label></td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Información 
								    de la Operación</td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="11"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo de Operación:</td>
										    <td colSpan="10"><asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" Width="194px" BackColor="AntiqueWhite"
												    AutoPostBack="true">
												    <asp:ListItem Value="1">Operaci&#243;n Crediticia</asp:ListItem>
												    <asp:ListItem Value="2">Contrato</asp:ListItem>
											    </asp:dropdownlist>
											    <asp:button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:button></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="24%">Contabilidad:</td>
										    <td width="4%"><asp:textbox id="txtContabilidad" tabIndex="2" runat="server" Width="23px" BackColor="AntiqueWhite"
												    MaxLength="2">1</asp:textbox></td>
										    <td class="td_Texto" width="9%">Oficina:</td>
										    <td width="4%"><asp:textbox id="txtOficina" tabIndex="3" runat="server" Width="32px" BackColor="AntiqueWhite"
												    MaxLength="3"></asp:textbox></td>
										    <td class="td_Texto" width="9%">Moneda:</td>
										    <td width="4%"><asp:textbox id="txtMoneda" tabIndex="4" runat="server" Width="21px" BackColor="AntiqueWhite"
												    MaxLength="2"></asp:textbox></td>
										    <td class="td_Texto" width="9%"><asp:label id="lblProducto" runat="server">Producto:</asp:label></td>
										    <td width="9%"><asp:textbox id="txtProducto" tabIndex="5" runat="server" Width="21px" BackColor="AntiqueWhite"
												    MaxLength="2"></asp:textbox></td>
										    <td class="td_Texto" width="9%"><asp:label id="lblTipoOperacion" runat="server">Operación:</asp:label></td>
										    <td width="9%"><asp:textbox id="txtOperacion" tabIndex="6" runat="server" Width="64px" BackColor="AntiqueWhite"
												    MaxLength="7"></asp:textbox></td>
										    <td class="td_Texto" width="9%"><asp:button id="btnValidarOperacion" tabIndex="7" runat="server" Text="Validar Operación" ToolTip="Verifica que la operación sea valida"></asp:button></td>
									    </tr>
									    <tr>
										    <td class="td_Texto"><asp:label id="lblDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												    Font-Italic="true">Deudor:</asp:label></td>
										    <td class="td_TextoIzq" colSpan="10"><asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												    Font-Italic="true"></asp:label></td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Información 
								    de la Garantía
							    </td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="4"><asp:label id="lblMensaje2" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Número de Seguridad:</td>
										    <td style="WIDTH: 217px"><asp:textbox id="txtSeguridad" tabIndex="8" runat="server" CssClass="Txt_Style_Default" Width="191px"
												    BackColor="AntiqueWhite" MaxLength="25"></asp:textbox></td>
										    <td class="td_Texto">Clase de Garantía:</td>
										    <td><asp:dropdownlist id="cbClaseGarantia" tabIndex="9" runat="server" Width="166px" BackColor="AntiqueWhite"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 16px">Tipo Mitigador Riesgo:</td>
										    <td style="HEIGHT: 16px" colSpan="3"><asp:dropdownlist id="cbMitigador" tabIndex="10" runat="server" Width="535px" BackColor="AliceBlue"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo&nbsp;Documento Legal:</td>
										    <td colSpan="3"><asp:dropdownlist id="cbTipoDocumento" tabIndex="11" runat="server" Width="534px" BackColor="AliceBlue"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Monto Mitigador:</td>
										    <td style="WIDTH: 217px">
										        <asp:TextBox ID="txtMontoMitigador" tabIndex="12" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Monto Mitigador" BackColor="AliceBlue" Width="176px" />
										    </td>
										    <td class="td_Texto">Ind. Inscripción:</td>
										    <td><asp:dropdownlist id="cbInscripcion" tabIndex="13" runat="server" Width="170px" BackColor="White"
												    Enabled="False"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td></td>
										    <td class="td_TextoLeyenda" colSpan="3"><asp:label id="lblLeyenda" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Grado&nbsp;Gravamen:</td>
										    <td style="WIDTH: 217px">
											    <asp:dropdownlist id="cbGravamen" tabIndex="14" runat="server" BackColor="AliceBlue" Width="180px"></asp:dropdownlist></td>
										    <td class="td_Texto">% Aceptación:</td>
										    <td>
										         <asp:TextBox ID="txtPorcentajeAceptacion" tabIndex="15" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                     ToolTip="Procentaje de Aceptación" />
											</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo&nbsp;Persona&nbsp;Acreedor:</td>
										    <td style="WIDTH: 217px"><asp:dropdownlist id="cbTipoAcreedor" tabIndex="17" runat="server" Width="177px" BackColor="White"
												    Enabled="False"></asp:dropdownlist></td>
										    <td class="td_Texto">Cédula&nbsp;Acreedor:</td>
										    <td><asp:textbox id="txtAcreedor" tabIndex="18" runat="server" CssClass="Txt_Style_Default" Width="113px"
												    BackColor="White" MaxLength="30" ToolTip="Cédula del Acreedor"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 19px">Grado Prioridad:</td>
										    <td style="WIDTH: 217px; HEIGHT: 19px"><asp:dropdownlist id="cbGradoPrioridad" tabIndex="19" runat="server" Width="177px" BackColor="White"
												    Enabled="False"></asp:dropdownlist></td>
										    <td class="td_Texto" style="HEIGHT: 19px">Monto&nbsp;Prioridades:</td>
										    <td style="HEIGHT: 19px">
										         <asp:TextBox ID="txtMontoPrioridades" tabIndex="20" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Monto Prioridades" BackColor="AliceBlue" Width="176px" />
											</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Operación Especial:</td>
										    <td colSpan="3"><asp:dropdownlist id="cbOperacionEspecial" tabIndex="21" runat="server" Width="497px" BackColor="White"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 19px">Clasificación&nbsp;Instrumento:</td>
										    <td colSpan="3" style="HEIGHT: 21px"><asp:dropdownlist id="cbClasificacion" tabIndex="22" runat="server" Width="498px" BackColor="AliceBlue"
												    AutoPostBack="true"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 19px">Identificación&nbsp;Instrumento:</td>
										    <td colSpan="3" style="HEIGHT: 21px"><asp:dropdownlist id="cbInstrumento" tabIndex="23" runat="server" Width="546px" BackColor="AliceBlue"></asp:dropdownlist>
											    <asp:TextBox id="txtInstrumento" tabIndex="23" runat="server" BackColor="AliceBlue" Width="135px"
												    ToolTip="Ingrese el número de cuenta de depósito" Visible="False"></asp:TextBox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto"></td>
										    <td style="WIDTH: 217px"></td>
										    <td class="td_Texto">Serie del Instrumento:</td>
										    <td><asp:textbox id="txtSerie" tabIndex="24" runat="server" CssClass="Txt_Style_Default" Width="152px"
												    BackColor="White" MaxLength="20" ToolTip="Serie del Instrumento"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 24px">Vencimiento&nbsp;Instrumento:</td>
										    <td style="WIDTH: 217px; HEIGHT: 24px">
										        <asp:TextBox ID="txtFechaVencimiento" BackColor="White" tabIndex="25" runat="server" Width="136px" 
										                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Vencimiento del Instrumento" />
                                                <asp:ImageButton ID="igbCalendarioVencimiento" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="True" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaVencimiento" runat="server"
                                                    TargetControlID="txtFechaVencimiento"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevFechaVencimiento" runat="server"
                                                    ControlExtender="meeFechaVencimiento"
                                                    ControlToValidate="txtFechaVencimiento"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaVencimiento" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaVencimiento" PopupButtonID="igbCalendarioVencimiento" />
											</td>
										    <td class="td_Texto" style="HEIGHT: 3px">Fecha Emisión&nbsp;Instrum.:</td>
										    <td style="HEIGHT: 3px">
										        <asp:TextBox ID="txtFechaConstitucion" BackColor="AliceBlue" tabIndex="26" runat="server" Width="136px" 
										                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Emisión del Instrumento" />
                                                <asp:ImageButton ID="igbCalendarioConstitucion" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="True" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaConstitucion" runat="server"
                                                    TargetControlID="txtFechaConstitucion"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevFechaConstitucion" runat="server"
                                                    ControlExtender="meeFechaConstitucion"
                                                    ControlToValidate="txtFechaConstitucion"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaConstitucion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaConstitucion" PopupButtonID="igbCalendarioConstitucion" />
											</td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo&nbsp;Persona del Emisor:</td>
										    <td style="WIDTH: 217px"><asp:dropdownlist id="cbTipoEmisor" tabIndex="27" runat="server" Width="177px" BackColor="White"></asp:dropdownlist></td>
										    <td class="td_Texto">Cédula del Emisor:</td>
										    <td><asp:textbox id="txtEmisor" tabIndex="28" runat="server" CssClass="Txt_Style_Default" Width="113px"
												    BackColor="White" MaxLength="30" ToolTip="Cédula del Tasador"></asp:textbox></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Premio:</td>
										    <td style="WIDTH: 217px">
										         <asp:TextBox ID="txtPorcentajePremio" tabIndex="29" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                     ToolTip="Procentaje del Premio" />
											</td>
										    <td class="td_Texto">ISIN:</td>
										    <td>
											    <asp:dropdownlist id="cbISIN" tabIndex="30" runat="server" BackColor="AliceBlue" Width="140px"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 24px">Valor Facial:</td>
										    <td style="WIDTH: 217px; HEIGHT: 24px">
										        <asp:TextBox ID="txtValorFacial" tabIndex="31" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Valor Facial" BackColor="AliceBlue" Width="176px" />
											</td>
										    <td class="td_Texto" style="HEIGHT: 24px">Moneda Valor Facial:</td>
										    <td style="HEIGHT: 24px"><asp:dropdownlist id="cbMonedaValorFacial" tabIndex="32" runat="server" Width="140px" BackColor="AliceBlue"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td></td>
										    <td class="td_TextoLeyenda" colSpan="3"><asp:label id="Label2" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Valor Mercado:</td>
										    <td style="WIDTH: 217px">
										        <asp:TextBox ID="txtValorMercado" tabIndex="33" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Valor Facial" BackColor="AliceBlue" Width="176px" />
											</td>
										    <td class="td_Texto">Moneda Valor Mercado:</td>
										    <td><asp:dropdownlist id="cbMonedaValorMercado" tabIndex="34" runat="server" Width="140px" BackColor="AliceBlue"></asp:dropdownlist></td>
									    </tr>
									    <tr>
										    <td></td>
										    <td class="td_TextoLeyenda" colSpan="3"><asp:label id="Label3" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Código de Tenencia:</td>
										    <td style="WIDTH: 217px"><asp:dropdownlist id="cbTenencia" tabIndex="35" runat="server" Width="152px" BackColor="AliceBlue"></asp:dropdownlist></td>
										    <td class="td_Texto">Fecha de Prescripción:</td>
										    <td>
										      <asp:TextBox ID="txtFechaPrescripcion" BackColor="AliceBlue" tabIndex="36" runat="server" Width="136px" 
										                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Prescripción" />
                                                <asp:ImageButton ID="igbCalendarioPrescripcion" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaPrescripcion" runat="server"
                                                    TargetControlID="txtFechaPrescripcion"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevFechaPrescripcion" runat="server"
                                                    ControlExtender="meeFechaPrescripcion"
                                                    ControlToValidate="txtFechaPrescripcion"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaPrescripcion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaPrescripcion" PopupButtonID="igbCalendarioPrescripcion" />
											</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="4"><br>
										    </td>
									    </tr>
									    <tr>
										    <td colSpan="2" style="WIDTH: 377px">
										    </td>
										    <td class="td_Texto" colSpan="2">
										        <asp:button id="btnLimpiar" tabIndex="38" runat="server" Text="Limpiar" ToolTip="Limpiar"></asp:button>
										        <asp:button id="btnInsertar" tabIndex="39" runat="server" Text="Insertar" ToolTip="Insertar Garantía" Visible="False"></asp:button>
												<asp:button id="btnModificar" tabIndex="40" runat="server" Text="Modificar" ToolTip="Modificar Garantía"></asp:button>
												<asp:button id="btnEliminar" tabIndex="41" runat="server" Text="Eliminar" ToolTip="Eliminar Garantía"></asp:button></td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								    rowSpan="1"><asp:label id="lblCatalogo" runat="server">Garantías de Valor de la Operación</asp:label></td>
						    </tr>
						    <tr>
							    <td align="center">
							    <br>
							        <asp:GridView ID="gdvGarantiasValor" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="cod_operacion, cod_garantia_valor, cod_tipo_garantia, cod_clase_garantia, fecha_constitucion, 
	                                        fecha_vencimiento, cod_clasificacion_instrumento, des_instrumento, des_serie_instrumento, cod_tipo_emisor, cedula_emisor, 
	                                        premio, cod_isin, valor_facial, cod_moneda_valor_facial, valor_mercado, cod_moneda_valor_mercado, cod_tenencia,
	                                        fecha_prescripcion, cod_tipo_mitigador, cod_tipo_documento_legal, cod_inscripcion, monto_mitigador, 
	                                        fecha_presentacion, porcentaje_responsabilidad, cod_grado_gravamen, cod_grado_prioridades, monto_prioridades, cod_operacion_especial,
	                                        cod_tipo_acreedor, cedula_acreedor, des_clase_garantia, numero_seguridad, cod_estado" 
                                         OnRowCommand="gdvGarantiasValor_RowCommand" 
                                         OnPageIndexChanging="gdvGarantiasValor_PageIndexChanging" CssClass="gridview" BorderColor="black" >
                                             <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                             
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="des_clase_garantia" CommandName="SelectedGarantiaValor" HeaderText="Clase de Garantía" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="numero_seguridad" CommandName="SelectedGarantiaValor" HeaderText="Número de Seguridad" Visible="True" ItemStyle-Width="350px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:BoundField DataField="cod_operacion" Visible="false"/>
                                                <asp:BoundField DataField="cod_garantia_valor" Visible="false"/>
                                                <asp:BoundField DataField="cod_tipo_garantia" Visible="false"/>
                                                <asp:BoundField DataField="cod_clase_garantia" Visible="false"/>
                                                <asp:BoundField DataField="fecha_constitucion" Visible="false" HtmlEncode="false" DataFormatString="{0:dd-MM-yyyy}"/>
                                                <asp:BoundField DataField="fecha_vencimiento" Visible="false"/>
                                                <asp:BoundField DataField="cod_clasificacion_instrumento" Visible="false"/>
                                                <asp:BoundField DataField="des_instrumento" Visible="false"/>
                                                <asp:BoundField DataField="des_serie_instrumento" Visible="false"/>
                                                <asp:BoundField DataField="cod_tipo_emisor" Visible="false"/>
                                                <asp:BoundField DataField="cedula_emisor" Visible="false"/>
                                                <asp:BoundField DataField="premio" Visible="false"/>
                                                <asp:BoundField DataField="cod_isin" Visible="false"/>
                                                <asp:BoundField DataField="valor_facial" Visible="false"/>
                                                <asp:BoundField DataField="cod_moneda_valor_facial" Visible="false"/>
                                                <asp:BoundField DataField="valor_mercado" Visible="false"/>
                                                <asp:BoundField DataField="cod_moneda_valor_mercado" Visible="false"/>
                                                <asp:BoundField DataField="cod_tenencia" Visible="false"/>
                                                <asp:BoundField DataField="fecha_prescripcion" Visible="false"/>
                                                <asp:BoundField DataField="cod_tipo_mitigador" Visible="false"/>
                                                <asp:BoundField DataField="cod_tipo_documento_legal" Visible="false"/>
                                                <asp:BoundField DataField="cod_inscripcion" Visible="false"/>
                                                <asp:BoundField DataField="monto_mitigador" Visible="false"/>
                                                <asp:BoundField DataField="fecha_presentacion" Visible="false"/>
                                                <asp:BoundField DataField="porcentaje_responsabilidad" Visible="false"/>
                                                <asp:BoundField DataField="cod_grado_gravamen" Visible="false"/>
                                                <asp:BoundField DataField="cod_grado_prioridades" Visible="false"/>
                                                <asp:BoundField DataField="monto_prioridades" Visible="false"/>
                                                <asp:BoundField DataField="cod_operacion_especial" Visible="false"/>
                                                <asp:BoundField DataField="cod_tipo_acreedor" Visible="false"/>
                                                <asp:BoundField DataField="cedula_acreedor" Visible="false"/>
                                                <asp:BoundField DataField="cod_estado" Visible="false"/>
                                            </Columns>
                                            <RowStyle BackColor="#EFF3FB" />
                                            <EditRowStyle BackColor="#2461BF" />
                                            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                            <AlternatingRowStyle BackColor="White" />
    							        </asp:GridView>
								    <br>
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
