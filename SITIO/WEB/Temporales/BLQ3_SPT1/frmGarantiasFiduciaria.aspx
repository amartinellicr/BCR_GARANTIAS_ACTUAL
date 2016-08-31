<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGarantiasFiduciaria.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmGarantiasFiduciaria" Title="BCR GARANTIAS - Garantías Fiduciarias" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1"  runat="server" ScriptMode="Auto" AsyncPostBackTimeout="210"  EnableScriptGlobalization="True" EnableScriptLocalization="True" LoadScriptsBeforeUI="True">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="width: 880px; background-color:Window;" cellspacing="1" cellpadding="1" width="875" align="center" border="0">
               <tr style="border-color:#E0E0DF; border-width:0px;">
                        <td>
			                <div id="contenedorDatosModificacion" runat="server" enableviewstate="true" style="clear:both; width:880px; border-color:#E0E0DF; background-color:#E0E0DF; padding-left:7px; padding-right:7px;">
                                <div style="text-align:left; width:540px; float:left; display:inline; background-color:transparent; border-color:transparent;">
                                    <asp:Label ID="lblUsrModifico" runat="server" CssClass="Txt_Fecha" Width="540px"></asp:Label>
                                </div>
                                <div style="text-align:right; width:320px; float:right; display:inline; background-color:transparent; border-color:transparent;">
                                    <asp:Label ID="lblFechaModificacion" runat="server" CssClass="Txt_Fecha" Width="320px"></asp:Label>
                                </div>
                                <div style="text-align:right; float:right; display:block; background-color:transparent; border-color:transparent;">
                                    <asp:Label ID="lblFechaReplica" runat="server" CssClass="Txt_Fecha"></asp:Label>
                                </div>
			                </div> 
                        </td> 
                </tr>
			    <tr>
				    <td style="HEIGHT: 43px" align="center">
					    <!--TITULO PRINCIPAL-->
					    <center>
					        <b>
					        <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Mantenimiento de Garantías Fiduciarias</asp:label>
					        </b>
					    </center>
					    <b></b> 
					    <!--<asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Garantías Fiduciarias</asp:label>--></td>
			    </tr>
			    <tr>
				    <td vAlign="top">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" rowSpan="1">Información de 
								    la Operación
							    </td>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="11">
										        <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="24%">
										        <asp:label id="lblTipoCaptacion" runat="server">Tipo de Operación:</asp:label>
										    </td>
										    <td width="76%" colSpan="10">
										        <asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												    Width="194px">
												    <asp:ListItem Value="1">Operaci&#243;n Crediticia</asp:ListItem>
												    <asp:ListItem Value="2">Contrato</asp:ListItem>
												    <asp:ListItem Value="3">Tarjeta</asp:ListItem>
											    </asp:dropdownlist>
											    <asp:button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:button>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="24%">
										        <asp:label id="lblContabilidad" runat="server">Contabilidad:</asp:label>
										    </td>
										    <td width="4%">
										        <asp:textbox id="txtContabilidad" tabIndex="2" runat="server" BackColor="AntiqueWhite" Width="23px"
												    MaxLength="2">1</asp:textbox>
										    </td>
										    <td class="td_Texto" width="9%">
										        <asp:label id="lblOficina" runat="server">Oficina:</asp:label>
										    </td>
										    <td width="4%">
										        <asp:textbox id="txtOficina" tabIndex="3" runat="server" BackColor="AntiqueWhite" Width="32px"
												    MaxLength="3"></asp:textbox>
										    </td>
										    <td class="td_Texto" width="9%">
										        <asp:label id="lblMoneda" runat="server">Moneda:</asp:label>
										    </td>
										    <td width="4%">
										        <asp:textbox id="txtMoneda" tabIndex="4" runat="server" BackColor="AntiqueWhite" Width="21px"
												    MaxLength="2"></asp:textbox>
										    </td>
										    <td class="td_Texto" width="9%">
										        <asp:label id="lblProducto" runat="server">Producto:</asp:label>
										    </td>
										    <td width="9%">
										        <asp:textbox id="txtProducto" tabIndex="5" runat="server" BackColor="AntiqueWhite" Width="21px"
												    MaxLength="2"></asp:textbox>
										    </td>
										    <td class="td_Texto" width="9%">
										        <asp:label id="lblTipoOperacion" runat="server">Operación:</asp:label>
										    </td>
										    <td width="9%">
										        <asp:textbox id="txtOperacion" tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="64px"
												    MaxLength="7"></asp:textbox>
										    </td>
										    <td class="td_Texto" width="10%">
										        <asp:button id="btnValidarOperacion" tabIndex="7" runat="server" ToolTip="Verifica que la operación sea valida"
												    Text="Validar Operación"></asp:button>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="24%">
										        <asp:label id="lblTarjeta" runat="server" Visible="False">Tarjeta:</asp:label>
										    </td>
										    <td class="td_TextoIzq" width="26%" colSpan="4">
										        <asp:textbox id="txtTarjeta" tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="143px"
												    MaxLength="16" Visible="False"></asp:textbox>
										    </td>
										    <td class="td_TextoIzq" width="50%" colSpan="6">
										        <asp:button id="btnValidarTarjeta" tabIndex="7" runat="server" ToolTip="Verifica que la tarjeta sea valida en SISTAR"
												    Text="Validar Tarjeta en SISTAR" Visible="False"></asp:button>
										    </td>
									    <tr>
										    <td class="td_Texto" width="24%">
										        <asp:label id="lblDeudor" runat="server" Visible="False" Font-Italic="true" ForeColor="SteelBlue"
												    Font-Bold="true">Deudor:</asp:label>
										    </td>
										    <td class="td_TextoIzq" width="76%" colSpan="10">
										        <asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Italic="true" ForeColor="SteelBlue"
												    Font-Bold="true"></asp:label>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" rowSpan="1">Información 
								    del Fiador
							    </td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colSpan="4">
										        <asp:label id="lblMensaje3" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 18px">Tipo de Persona:</td>
										    <td style="HEIGHT: 18px">
										        <asp:dropdownlist id="cbTipoFiador" tabIndex="8" runat="server" BackColor="AliceBlue" Width="198px"></asp:dropdownlist>
										    </td>
										    <td class="td_Texto" style="HEIGHT: 18px">Cédula del Fiador:</td>
										    <td style="HEIGHT: 18px">
										        <asp:textbox id="txtCedulaFiador" tabIndex="9" runat="server" CssClass="Txt_Style_Default" BackColor="AntiqueWhite"
												    Width="96px" MaxLength="80" ToolTip="Cédula del Fiador" Enabled="False"></asp:textbox>
											    <asp:imagebutton id="btnBuscarFiador" tabIndex="10" runat="server" ToolTip="Buscar Fiador" Visible="False"
												    ImageUrl="Images/search.gif"></asp:imagebutton>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Nombre del Fiador:</td>
										    <td colSpan="3">
										        <asp:textbox id="txtNombreFiador" tabIndex="11" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												    Width="356px" MaxLength="50" ToolTip="Nombre del Fiador" Enabled="False"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 17px">Tipo Mitigador Riesgo:</td>
										    <td style="HEIGHT: 17px" colSpan="3">
										        <asp:dropdownlist id="cbMitigador" tabIndex="12" runat="server" BackColor="AliceBlue" Width="486px"
												    Enabled="true"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 15px">Tipo Documento Legal:</td>
										    <td style="HEIGHT: 15px" colSpan="3">
										        <asp:dropdownlist id="cbTipoDocumento" tabIndex="13" runat="server" BackColor="AliceBlue" Width="487px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 24px" width="25%">Monto Mitigador:</td>
										    <td style="HEIGHT: 24px" width="25%">
										        <asp:TextBox ID="txtMontoMitigador" tabIndex="14" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Monto Mitigador" BackColor="AliceBlue" Enabled="true" Width="176px" text="0" />
										    </td>
										    <td class="td_Texto" style="HEIGHT: 24px" width="25%">%&nbsp;Aceptación:</td>
										    <td style="HEIGHT: 24px" width="25%">
										        <asp:TextBox ID="txtPorcentajeAceptacion" tabIndex="15" Enabled="True" Text="0.00" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                     ToolTip="Porcentaje de Aceptación" Width="64px" />
										    </td>
									    </tr>
									    <tr>
										    <td></td>
										    <td class="td_TextoLeyenda" colSpan="3">
										        <asp:label id="lblLeyenda" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="25%">Tipo Persona Acreedor:</td>
										    <td width="25%">
										        <asp:dropdownlist id="cbTipoAcreedor" tabIndex="16" runat="server" BackColor="White" Width="198px"
												    Enabled="False"></asp:dropdownlist>
										    </td>
										    <td class="td_Texto" width="25%">Cédula del Acreedor:</td>
										    <td width="25%">
										        <asp:textbox id="txtAcreedor" tabIndex="17" runat="server" Enabled="false" BackColor="White" Text="4000000019" Width="96px" MaxLength="80"
												    ToolTip="Cédula del Acreedor"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" width="25%">
										        <asp:label id="lblFechaExpiracion" runat="server" Visible="False">Fecha de Expiración:</asp:label>
										    </td>
										    <td width="25%">
										        <asp:TextBox ID="txtFechaExpiracion" BackColor="AliceBlue" tabIndex="4" runat="server" Width="136px" 
										                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Expiración" 
										                     Visible="False" ReadOnly="true" Editable="False"/>
                                                <asp:ImageButton ID="igbCalendario" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="False" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaExpiracion" runat="server"
                                                    TargetControlID="txtFechaExpiracion"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevFechaExpiracion" runat="server"
                                                    ControlExtender="meeFechaExpiracion"
                                                    ControlToValidate="txtFechaExpiracion"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                <ajaxToolkit:CalendarExtender ID="cleFechaExpiracion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaExpiracion" PopupButtonID="igbCalendario" />
											</td>
										    <td class="td_Texto" width="25%">
										        <asp:label id="lblMontoCobertura" runat="server" Visible="False">Monto de Cobertura:</asp:label>
										    </td>
										    <td width="25%">
										        <asp:TextBox ID="txtMontoCobertura" tabIndex="19" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                     ToolTip="Monto de Cobertura" BackColor="AliceBlue" Width="156px" Visible="False" Enabled="False" />
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 17px">Operación Especial:</td>
										    <td style="HEIGHT: 17px" colSpan="2">
										        <asp:dropdownlist id="cbOperacionEspecial" tabIndex="20" runat="server" BackColor="White" Width="365px"></asp:dropdownlist>
										    </td>
										    <td class="td_Texto" style="HEIGHT: 17px">
										        <asp:button id="btnIngresos" tabIndex="21" runat="server" ToolTip="Histórico de Ingresos" Text="Histórico Ingresos"
												    Enabled="true"></asp:button>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" style="HEIGHT: 17px">
                                                <asp:Label ID="lblObservacion" runat="server" Text="Observaciones:"></asp:Label></td>
										    <td style="HEIGHT: 17px" colSpan="2">
                                                <asp:TextBox ID="txtObservacion" runat="server" Visible="false" Width="410px" MaxLength="150" tabIndex="22" TextMode="MultiLine" onKeyUp="javascript:Count(this,150);" onKeyDown="javascript:Count(this,150);"></asp:TextBox>
										    </td>
									    </tr>
									    <tr>
										    <td></td>
										    <td colSpan="3"></td>
									    </tr>
                                        <tr>
                                           <td class="td_Texto" style="HEIGHT: 24px" width="25%">%&nbsp;Responsabilidad:</td>
										   <td>
										        <asp:TextBox ID="txtPorcentajeResponsabilidad"  runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                        ToolTip="Porcentaje de Responsabilidad" Enabled="False" tabIndex="20"/>
                                                <asp:ImageButton ID="imgCalculadora" runat="server" ImageUrl="~/Images/Calculadora.png" OnClientClick="javascript: return false;" />
										    </td>
                                            <td></td>
                                        </tr>
									    <tr>
										    <td colSpan="2">
										    </td>
										    <td class="td_Texto" colSpan="2">
										        <asp:button id="btnLimpiar" tabIndex="24" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button>
										        <asp:button id="btnInsertar" tabIndex="25" runat="server" ToolTip="Insertar Garantía" Text="Insertar" Visible="False"></asp:button>
										        <asp:button id="btnModificar" tabIndex="26" runat="server" ToolTip="Modificar Garantía" Text="Modificar"></asp:button>
										        <asp:button id="btnEliminar" tabIndex="27" runat="server" ToolTip="Eliminar Garantía" Text="Eliminar" Visible="False"></asp:button>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								    rowSpan="1">
								    <asp:label id="lblCatalogo" runat="server">Fiadores de la Operación</asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
							            <asp:GridView ID="gdvGarantiasFiduciarias" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="tipo_persona, cedula_fiador, nombre_fiador, cod_tipo_fiador, cod_tipo_mitigador, cod_tipo_documento_legal, 
                                         monto_mitigador, porcentaje_responsabilidad, cod_operacion_especial, cod_tipo_acreedor, cedula_acreedor, cod_operacion, cod_garantia_fiduciaria, cod_estado,
                                         Usuario_Modifico,Nombre_Usuario_Modifico,Fecha_Modifico,Fecha_Inserto,Fecha_Replica,Porcentaje_Aceptacion" 
                                         OnRowCommand="gdvGarantiasFiduciarias_RowCommand"     
                                         OnPageIndexChanging="gdvGarantiasFiduciarias_PageIndexChanging" OnDataBinding="gdvGarantiasFiduciarias_DataBinding" BorderColor="Black" CssClass="gridview">
                                         
                                        <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" BorderColor="Black" BorderStyle="Solid" />
                                        <Columns>
                                            <asp:ButtonField DataTextField="tipo_persona" CommandName="SelectedFiador" HeaderText="Tipo de Persona" ItemStyle-HorizontalAlign="center" ItemStyle-Width="170px" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" >
                                            </asp:ButtonField>
                                            <asp:ButtonField DataTextField="cedula_fiador" CommandName="SelectedFiador" HeaderText="C&#233;dula del Fiador" ItemStyle-HorizontalAlign="center" ItemStyle-Width="170px" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" >
                                            </asp:ButtonField>
                                            <asp:ButtonField DataTextField="nombre_fiador" CommandName="SelectedFiador" HeaderText="Nombre del Fiador" ItemStyle-HorizontalAlign="center" ItemStyle-Width="300px" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" >
                                            </asp:ButtonField>
                                            <asp:BoundField DataField="cod_tipo_fiador" Visible="False"/>
                                            <asp:BoundField DataField="cod_tipo_mitigador" Visible="False"/>
                                            <asp:BoundField DataField="cod_tipo_documento_legal" Visible="False"/>
                                            <asp:BoundField DataField="monto_mitigador" Visible="False"/>
                                            <asp:BoundField DataField="porcentaje_responsabilidad" Visible="False"/>
                                            <asp:BoundField DataField="cod_operacion_especial" Visible="False"/>
                                            <asp:BoundField DataField="cod_tipo_acreedor" Visible="False"/>
                                            <asp:BoundField DataField="cedula_acreedor" Visible="False"/>
                                            <asp:BoundField DataField="cod_operacion" Visible="False"/>
                                            <asp:BoundField DataField="cod_garantia_fiduciaria" Visible="False"/>
                                            <asp:BoundField DataField="cod_estado" Visible="False"/>
                                            <asp:BoundField DataField="Usuario_Modifico" Visible="False"/>
                                            <asp:BoundField DataField="Nombre_Usuario_Modifico" Visible="False"/>
                                            <asp:BoundField DataField="Fecha_Modifico" Visible="False"/>
                                            <asp:BoundField DataField="Fecha_Inserto" Visible="False"/>
                                            <asp:BoundField DataField="Fecha_Replica" Visible="False"/>
                                            <asp:BoundField DataField="Porcentaje_Aceptacion" Visible="False"/>
                                       </Columns>
                                        
                                        <RowStyle BackColor="#EFF3FB" BorderColor="Black" BorderStyle="Solid"/>
                                        <EditRowStyle BackColor="#2461BF" />
                                        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" BorderColor="Black" BorderStyle="Solid" />
                                        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" BorderColor="Black" BorderStyle="Solid" />
                                        <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" BorderColor="Black" BorderStyle="Solid" />
                                        <AlternatingRowStyle BackColor="White" BorderColor="Black" BorderStyle="Solid" />
    							    </asp:GridView>
								    <br/>
							    </td>
						    </tr>
					    </table>
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
        </div>
  </contenttemplate>
</asp:UpdatePanel>
<asp:HiddenField ID="hdnAplicaCalculoPA" runat="server" Value="0"></asp:HiddenField>
</asp:Content>

