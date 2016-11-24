<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGarantiasReales.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmGarantiasReales" Title="BCR GARANTIAS - Garantas Reales" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto" AsyncPostBackTimeout="210"  EnableScriptGlobalization="True" EnableScriptLocalization="True" LoadScriptsBeforeUI="True"></asp:ScriptManager>
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
                                <div style="text-align:right; float:right; display:inline-block; width:320px; padding-left:250px; background-color:transparent; border-color:transparent;">
                                    <asp:Label ID="lblFechaReplica" runat="server" CssClass="Txt_Fecha" Width="320px"></asp:Label>
                                </div>
			                </div> 
                        </td> 
                    </tr>
			        <tr>
				        <td style="height: 43px" align="center" colspan="3">
					        <!--TITULO PRINCIPAL-->
						        <center>
						        <b>
						            <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Mantenimiento de Garantías Reales</asp:label>
					            </b>
					            <b></b> 
					            </center>
			        </tr>
			        <tr>
				        <td valign="top" colspan="3">
					        <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1">Información 
								        de la Operación</td>
						        </tr>
						        <tr>
							        <td>
								        <table width="100%" align="center" border="0">
									        <tr>
										        <td align="center" colspan="11"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label> </td>
									        </tr>
									        <tr>
										        <td class="td_Texto">Tipo de Operación:</td>
										        <td colspan="10"><asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												        Width="194px">
												        <asp:ListItem Value="1">Operación Crediticia</asp:ListItem>
												        <asp:ListItem Value="2">Contrato</asp:ListItem>
											        </asp:dropdownlist>
										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" width="24%">Contabilidad:</td>
										        <td width="4%"><asp:textbox id="txtContabilidad" tabIndex="2" runat="server" BackColor="AntiqueWhite" Width="23px"
												        MaxLength="2">1</asp:textbox></td>
										        <td class="td_Texto" width="9%">Oficina:</td>
										        <td width="4%"><asp:textbox id="txtOficina" tabIndex="3" runat="server" BackColor="AntiqueWhite" Width="32px"
												        MaxLength="3"></asp:textbox></td>
										        <td class="td_Texto" width="9%">Moneda:</td>
										        <td width="4%"><asp:textbox id="txtMoneda" tabIndex="4" runat="server" BackColor="AntiqueWhite" Width="21px"
												        MaxLength="2"></asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:label id="lblProducto" runat="server">Producto:</asp:label></td>
										        <td width="9%"><asp:textbox id="txtProducto" tabIndex="5" runat="server" BackColor="AntiqueWhite" Width="21px"
												        MaxLength="2"></asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:label id="lblTipoOperacion" runat="server">Operación:</asp:label></td>
										        <td width="9%"><asp:textbox id="txtOperacion" tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="64px"
												        MaxLength="7"></asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:button id="btnValidarOperacion" tabIndex="7" runat="server" ToolTip="Verifica que la operación sea valida"
												        Text="Validar Operación"></asp:button></td>
									        </tr>
									        <tr>
										        <td class="td_Texto"><asp:label id="lblDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												        Font-Italic="true">Deudor:</asp:label></td>
										        <td class="td_TextoIzq" colspan="10"><asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												        Font-Italic="true"></asp:label></td>
									        </tr>
								        </table>
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1">Información de 
								        la Garantía
							        </td>
						        </tr>
						        <tr>
							        <td>
								        <table width="100%" align="center" border="0">
									        <tr>
										        <td align="center" colspan="4"><asp:label id="lblMensaje3" runat="server" CssClass="TextoError"></asp:label> </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="height: 16px" width="25%">Tipo de Garantía Real:</td>
										        <td style="height: 16px" width="25%"><asp:dropdownlist id="cbTipoGarantiaReal" tabIndex="8" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												        Width="174px"></asp:dropdownlist></td>
										        <td class="td_Texto" style="height: 16px" width="18%">Clase de Garantía:</td>
										        <td style="height: 16px" width="25%"><asp:dropdownlist id="cbClase" tabIndex="9" runat="server" Enabled="False" BackColor="AntiqueWhite" Width="215px"></asp:dropdownlist></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" colspan="4">
											        <table width="100%" align="center" border="0">
												        <tr>
													        <td class="td_Texto" width="24.5%"><asp:label id="lblPartido" Font-Size="11px" runat="server" Font-Italic="true">Partido:</asp:label></td>
													        <td width="9%"><asp:textbox id="txtPartido" Enabled="False" tabIndex="10" runat="server" BackColor="AntiqueWhite" Width="42px"
															        MaxLength="3"></asp:textbox></td>
													        <td class="td_Texto" width="16%"><asp:label id="lblFinca" Font-Size="11px" runat="server" Font-Italic="true">Número Finca:</asp:label></td>
													        <td width="12%"><asp:textbox id="txtNumFinca" Enabled="False" tabIndex="11" runat="server" BackColor="AntiqueWhite" Width="100px"
															        MaxLength="25"></asp:textbox></td>
													        <td class="td_Texto" width="11%"><asp:label id="lblGrado" Font-Size="11px" runat="server" Font-Italic="true">Grado:</asp:label></td>
													        <td width="5%"><asp:textbox id="txtGrado" tabIndex="12" runat="server" BackColor="AntiqueWhite" Width="42px"
															        MaxLength="2"></asp:textbox></td>
													        <td class="td_Texto" width="18%"><asp:label id="lblCedula" Font-Size="11px" runat="server" Font-Italic="true">Cédula Hipotecaria:</asp:label></td>
													        <td width="5%"><asp:textbox id="txtCedulaHipotecaria" tabIndex="13" runat="server" BackColor="AntiqueWhite"
															        Width="42px" MaxLength="2"></asp:textbox></td>
												        </tr>
											        </table>
										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="WIDTH: 178px; height: 22px;" width="178">Tipo de Bien:</td>
										        <td><asp:dropdownlist id="cbTipoBien" tabIndex="14" runat="server" BackColor="AliceBlue" Width="152px" AutoPostBack="True" OnSelectedIndexChanged="cbTipoBien_SelectedIndexChanged"></asp:dropdownlist></td>
                                                <td colspan="2" class="td_Texto" style="text-align:left; "><asp:CheckBox ID="chkDeudorHabitaVivienda" runat="server" />Vivienda habitada deudor</td>
                                                
									        </tr>
									        <tr>
										        <td class="td_Texto" style="height: 21px">Tipo Mitigador Riesgo:</td>
										        <td style="height: 21px" colspan="3"><asp:dropdownlist id="cbMitigador" tabIndex="15" runat="server" BackColor="AliceBlue" Width="493px" AutoPostBack="True" OnSelectedIndexChanged="cbMitigador_SelectedIndexChanged" ></asp:dropdownlist></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="height: 17px">Tipo Documento Legal:</td>
										        <td style="height: 17px" colspan="3"><asp:dropdownlist id="cbTipoDocumento" tabIndex="16" runat="server" Enabled="False" BackColor="AliceBlue" Width="493px"></asp:dropdownlist></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" width="25%">Monto Mitigador:</td>
										        <td width="25%">
										            <asp:TextBox ID="txtMontoMitigador" tabIndex="17" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
										                         ToolTip="Monto Mitigador. Utilice el punto como separador de decimales." BackColor="AliceBlue" Width="176px" />
										        </td>
										        <td class="td_Texto" width="18%">Indicador Inscripción:</td>
										        <td width="25%"><asp:dropdownlist id="cbInscripcion" tabIndex="18" runat="server" BackColor="White"
												        Width="162px" Enabled="false"></asp:dropdownlist></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" width="25%">Monto Mitigador Calculado:</td>
										        <td width="25%">
										            <asp:TextBox ID="txtMontoMitigadorCalculado" runat="server" CssClass="id-tabla-texto" Enabled="false" ReadOnly="true" tabIndex="19"
										                         ToolTip="Monto mitigador calculado, según el porcentaje de aceptación y el monto total del avalúo." BackColor="White" Width="176px" />
										        </td>
                                                <td class="td_Texto">% Aceptación Calculado:</td>
                                                 <td>
										            <asp:TextBox ID="txtPorcentajeAceptacionCalculado"  runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                         ToolTip="Porcentaje de Aceptación Calculado" Enabled= "False" tabIndex="20"/>
										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto">Fecha Presentación:</td>
										        <td>
										            <asp:TextBox ID="txtFechaRegistro" BackColor="AliceBlue" tabIndex="21" runat="server" Width="136px" 
										                         MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Presentación" />
                                                    <asp:ImageButton ID="igbCalendario" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
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
                                                    <ajaxToolkit:MaskedEditValidator ID="mevFechaRegistro" runat="server"
                                                        ControlExtender="meeFechaRegistro"
                                                        ControlToValidate="txtFechaRegistro"
                                                        EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                        InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                        Display="Dynamic"
                                                        TooltipMessage="Ingrese una fecha: día/mes/año"
                                                        EmptyValueBlurredText="*"
                                                        InvalidValueBlurredMessage="*"
                                                        ValidationGroup="MKE" />
                                                         
                                                    <ajaxToolkit:CalendarExtender ID="cleFechaRegistro" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaRegistro" PopupButtonID="igbCalendario" />
                                                    
    										    </td>
										        <td class="td_Texto">% Aceptación:</td>
										        <td>
										            <asp:TextBox ID="txtPorcentajeAceptacion" tabIndex="22" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                         ToolTip="Porcentaje de Aceptación" />
										        </td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="height: 20px">Fecha de Constitución:</td>
										        <td style="height: 20px">
										            <asp:TextBox ID="txtFechaConstitucion" BackColor="AliceBlue" tabIndex="23" runat="server" Width="136px" 
										                         MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Constitución" Enabled="False" />
											    </td>
										        <td class="td_Texto">Grado Gravamen:</td>
										        <td><asp:dropdownlist id="cbGravamen" tabIndex="22" runat="server" BackColor="AliceBlue" Width="162px" Enabled="False"></asp:dropdownlist></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" style="height: 24px">Tipo Persona Acreedor:</td>
										        <td style="height: 24px"><asp:dropdownlist id="cbTipoAcreedor" tabIndex="24" runat="server" BackColor="White" Width="177px"
												        Enabled="False"></asp:dropdownlist></td>
										        <td class="td_Texto" style="height: 24px">Cédula del Acreedor:</td>
										        <td style="height: 24px;"><asp:textbox id="txtAcreedor" tabIndex="25" runat="server" BackColor="White"
												        Width="113px" MaxLength="30" ToolTip="Cédula del Acreedor"></asp:textbox></td>
									        </tr>
									        <tr>
										        <td class="td_Texto">Fecha de Vencimiento:</td>
										        <td style="height: 15px">
										            <asp:TextBox ID="txtFechaVencimiento" BackColor="White" tabIndex="26" runat="server" Width="136px" Enabled="false"
										                         MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de vencimiento de la garantía" />
											    </td>
											    <td class="td_Texto" style="height: 24px; width:25%">Fecha de Prescripción:</td>
										        <td style="height: 15px">
										             <asp:TextBox ID="txtFechaPrescripcion" BackColor="White" tabIndex="27" runat="server" Width="136px" 
										                         MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Prescripción" Enabled="false" />
											    </td>
									        </tr>
									        <tr>
                                                <td class="td_Texto">% Responsabilidad:</td>
                                                <td>
										            <asp:TextBox ID="txtPorcentajeResponsabilidad"  runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
										                         ToolTip="Porcentaje de Responsabilidad" Enabled="False" tabIndex="20"/>
                                                    <div style="cursor:pointer; display:inline;">
                                                        <asp:ImageButton ID="imgCalculadoraGR" runat="server" ImageUrl="~/Images/Calculadora.png" />
                                                    </div>
										        </td>
                                                <td></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" colspan="4"><br>
										        </td>
									        </tr>
									        <tr>
										        <td colspan="4" style="clear:both;" valign="top" >
										            <div id="accordion" style="width:100%;">
                                                        <h3 style="margin-bottom:0px;">Detalle del Avalúo</h3>
                                                        <div style="text-align:left;">
                                                            <table width="95%" style="text-align:left; height:300px;">
													            <tr>
													                <td style="width:450px; min-width:450px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Fecha Última Tasación Garantía:</td>
														            <td style="width:2px;"></td>
														            <td style="height:15px; font-size:15px;">
														                <asp:TextBox ID="txtFechaValuacion" BackColor="AliceBlue" Enabled="False" tabIndex="28" runat="server" Width="136px" 
								                                                     style="text-align:left; font-size:11px; font-style:normal; font-family:Verdana, Tahoma, Arial;" ValidationGroup="MKE" ToolTip="Fecha de Valuación del Bien" />
                                                                    </td>
                                                                    <td style="width:450px; min-width:450px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Fecha de Valuación SICC:</td>
                                                                    <td style="width:2px;"></td>
                                                                    <td style="width:140px; height:15px; font-size:15px;">
                                                                        <asp:TextBox ID="txtFechaValuacionSICC" BackColor="AliceBlue" Enabled="False" tabIndex="29" runat="server" Width="136px" 
								                                                     style="text-align:left; font-size:11px; font-style:normal; font-family:Verdana, Tahoma, Arial;" ValidationGroup="MKE" ToolTip="Fecha de Valuación del Bien Registrada en el SICC" />
                                                                    </td>
													            </tr>
													           <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Cédula de Empresa:</td>
														            <td style="width:2px;"></td>
														            <td style="width:572px; height:20px; font-size:15px;" colspan="5"><asp:dropdownlist id="cbEmpresa" tabIndex="30" runat="server" Width="100%" Height="100%"></asp:dropdownlist></td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Cédula del Perito:</td>
														            <td style="width:2px;"></td>
														            <td style="width:572px; height:20px; font-size:15px;" colspan="5"><asp:dropdownlist id="cbPerito" tabIndex="31" runat="server" Width="100%" Height="100%"></asp:dropdownlist></td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Mto Última Tasación Terreno:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
																        
														                <asp:TextBox ID="txtMontoUltTasacionTerreno" tabIndex="32" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto de Última Tasación Terreno (Utilice el punto como separador de decimales)" BackColor="AliceBlue" Width="136px"/>
															        </td>
														            <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Mto Última Tasación no Terreno:</td>
														            <td style="width:2px;"></td>
														            <td style="width:140px; height:15px; font-size:14px;" valign="middle">
																        
														                <asp:TextBox ID="txtMontoUltTasacionNoTerreno" tabIndex="33" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto de Última Tasación No Terreno (Utilice el punto como separador de decimales)" BackColor="AliceBlue" Width="136px"/>
															        </td>
													            </tr>
													            <tr id="filaPorAcep" runat="server">
														           <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">% Aceptación Terreno:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
																        
														                <asp:TextBox ID="txtPorcentajeAceptacionTerreno" tabIndex="34" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
								                                                     ToolTip="% Aceptación Terreno (Utilice el punto como separador de decimales)" BackColor="AliceBlue" />
															        </td>
														            <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">% Aceptación No Terreno:</td>
														            <td style="width:2px;"></td>
														            <td style="width:140px; height:15px; font-size:14px;" valign="middle">
																        
														                <asp:TextBox ID="txtPorcentajeAceptacionNoTerreno" tabIndex="35" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
								                                                     ToolTip="% Aceptación No Terreno (Utilice el punto como separador de decimales)" BackColor="AliceBlue" />
															        </td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Mto Tasación Actualizada Terreno Calculado:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														            
														                <asp:TextBox ID="txtMontoTasActTerreno" tabIndex="36" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto Tasación Actualizada Terreno Calculado" BackColor="AliceBlue"  Width="136px" />
															        </td>
														            <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Mto Tasación Actualizada No Terreno Calculado:</td>
														            <td style="width:2px;"></td>
														            <td style="width:140px; height:15px; font-size:14px;" valign="middle">
														            
														                <asp:TextBox ID="txtMontoTasActNoTerreno" tabIndex="37" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto Tasación Actualizada No Terreno Calculado" BackColor="AliceBlue"  Width="136px" />
															        </td>
													            </tr>
													            <tr id="filaPorAcepCalc" runat="server">
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">% Aceptación Terreno Calculado:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														            
														                <asp:TextBox ID="txtPorcentajeAceptacionTerrenoCalculado" tabIndex="38" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
								                                                     ToolTip="% Aceptación Terreno Calculado" Enabled="false" BackColor="AliceBlue" />
															        </td>
														            <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">% Aceptación No Terreno Calculado:</td>
														            <td style="width:2px;"></td>
														            <td style="width:140px; height:15px; font-size:14px;" valign="middle">
														            
														                <asp:TextBox ID="txtPorcentajeAceptacionNoTerrenoCalculado" tabIndex="39" runat="server" CssClass="id-tabla-texto" MaxLength="6" ValidationGroup="MKE" 
								                                                     ToolTip="% Aceptación No Terreno Calculado" Enabled="false" BackColor="AliceBlue" />
															        </td>
													            </tr>
													           <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Fecha Último Seguimiento Garantía:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:15px;">
														                <asp:TextBox ID="txtFechaSeguimiento" BackColor="AliceBlue" tabIndex="40" runat="server" Width="115px" 
								                                                     MaxLength="1" style="text-align:justify" ToolTip="Ingrese una fecha: día/mes/año" ValidationGroup="MKE" />
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
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
                                                                             
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaSeguimiento" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaSeguimiento" PopupButtonID="igbCalendarioSeguimiento" />
															        </td>
														            <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Fecha de Construcción:</td>
														            <td style="width:2px;"></td>
														            <td style="width:140px; height:15px; font-size:15px;">
														                <asp:TextBox ID="txtFechaConstruccion" BackColor="White" tabIndex="41" runat="server" Width="112px" 
								                                                     MaxLength="1" style="text-align:justify" ToolTip="Ingrese una fecha: día/mes/año" ValidationGroup="MKE" />
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
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
                                                                             
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaConstruccion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaConstruccion" PopupButtonID="igbCalendarioConstruccion" />
															        </td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Monto Total Avalúo:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														                <asp:TextBox ID="txtMontoAvaluo" tabIndex="42" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto Total Avalúo" BackColor="AliceBlue" Width="136px" Enabled="False" />
															        </td>
															        <td style="width:280px; min-height:280px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Tipo Moneda Tasación:</td>
														            <td style="width:2px;"></td>
															        <td style="width:140px; height:15px; font-size:15px;">
                                                                        <asp:dropdownlist id="cbTipoMonedaAvaluo" tabIndex="43" runat="server" BackColor="White" Width="162px" Enabled="false"></asp:dropdownlist>
															        </td>
													            </tr>
                                                                <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;"></td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														                <asp:Label ID="lblMontoTotalAvaluoColonizado" runat="server" CssClass="id-tabla-texto" BackColor="AliceBlue" Width="136px" Enabled="False"></asp:Label>
                                                          	        </td>
															        <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>
													            </tr>
												            </table>
                                                        </div>
                                                    </div>
										        </td>
									        </tr>
									        <tr>
										        <td colspan="4" style="clear:both; width:100%; height:100%;" valign="top" >
										            <div id="accPoliza" style="width:100%; height:100%;">
                                                        <h3 style="margin-bottom:0px;">Póliza de la Garantía</h3>
                                                        <div style="text-align:left;">
                                                            <table width="95%" style="text-align:left; height:500px;">
													            <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Código SAP:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:20px; font-size:15px;" colspan="5"><asp:dropdownlist id="cbCodigoSap" tabIndex="44" runat="server" Width="450px" Height="100%"></asp:dropdownlist></td>
															        <%--<td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>--%>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Monto Póliza:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														                <asp:TextBox ID="txtMontoPoliza" tabIndex="45" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto de la póliza" BackColor="AliceBlue" Width="140px" Enabled="false"/>
															        </td>
															       <%-- <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>--%>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Moneda Póliza:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:20px; font-size:15px;" colspan="5"><asp:dropdownlist id="cbMonedaPoliza" tabIndex="46" runat="server" Width="100%" Height="100%" Enabled="false"></asp:dropdownlist></td>
															       <%-- <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>--%>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Identificación del Acreedor:</td>
														            <td style="width:2px;"></td>
										                            <td style="width:150px; height:24px; font-size:15px;"><asp:textbox id="txtCedulaAcreedorPoliza" tabIndex="47" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												                            Width="140px" MaxLength="30" style="text-align:left; font-size:11px; font-style:normal; font-family:Verdana, Tahoma, Arial;" ToolTip="Cédula del acreedor de la póliza" Enabled="false"></asp:textbox></td>
															        <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">
                                                                        <input type="checkbox" id="ckbPolizaExterna" runat="server" tabindex="48" disabled="disabled" /><span>Póliza Externa</span>
                                                                    </td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height:25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Nombre del Acreedor:</td>
														            <td style="width:2px;"></td>
										                            <td style="width:150px; height:24px; font-size:15px;"><asp:textbox id="txtNombreAcreedorPoliza" tabIndex="49" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												                            Width="140px" MaxLength="30" style="text-align:left; font-size:11px; font-style:normal; font-family:Verdana, Tahoma, Arial;" ToolTip="Nombre del acreedor de la póliza" Enabled="false"></asp:textbox></td>
															        <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>
													            </tr>
												                <tr>
													                <td style="width:650px; min-width:550px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Fecha de Vencimiento Póliza:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:15px;">
														                <asp:TextBox ID="txtFechaVencimientoPoliza" BackColor="AliceBlue" Enabled="false" tabIndex="50" runat="server" Width="140px" 
								                                                      style="text-align:left; font-size:11px; font-style:normal; font-family:Verdana, Tahoma, Arial;" ValidationGroup="MKE" ToolTip="Fecha de vencimiento de la póliza" />
                                                                    </td>
															        <td style="width:200px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:160px; text-align:center; vertical-align:middle; font-size:15px;">
                                                                        <asp:RadioButtonList ID="rdlEstadoPoliza" Enabled="false" runat="server" CssClass="id-tabla-texto" tabIndex="51" RepeatDirection="Horizontal" TextAlign="Right" ForeColor="black">
                                                                            <asp:ListItem Enabled="true" Text="Vencida" Value="0"></asp:ListItem>
                                                                            <asp:ListItem Enabled="true" Text="Vigente" Value="1"></asp:ListItem>
                                                                        </asp:RadioButtonList>
															        </td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Acreencia del Bien:</td>
														            <td style="width:2px;"></td>
														            <td style="width:150px; height:15px; font-size:14px;" valign="middle">
														                <asp:TextBox ID="txtMontoAcreenciaPoliza" tabIndex="52" runat="server" CssClass="id-tabla-texto" MaxLength="17" ValidationGroup="MKE" 
								                                                     ToolTip="Monto de la acreencia de la póliza" BackColor="AliceBlue" Width="140px"/>
															        </td>
															        <td style="width:280px;"></td>
															        <td style="width:2px;"></td>
															        <td style="width:140px;"></td>
													            </tr>
													            <tr>
														            <td style="width:250px; min-width:250px; height: 25px; text-align:right; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Detalle Póliza:</td>
														            <td style="width:2px;"></td>
														            <td style="width:450px; height:15px; font-size:15px"; colspan="4">
														                <asp:TextBox ID="txtDetallePoliza" tabIndex="53" runat="server" CssClass="id-tabla-texto-multilinea" ValidationGroup="MKE"
								                                                     ToolTip="Detalle de la póliza" BackColor="AliceBlue" Width="450px" Height="50px" TextMode="MultiLine" ReadOnly="true"/>
															        </td>
													            </tr>
                                                                <tr>
														            <td colspan="6" style="clear:both; height:25px;" valign="top">
                                                                        <div style="display:inline; float:left; width:345px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">
                                                                            <span style="width:300px; min-width:200px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Coberturas Indicadas por el Asegurador:</span>
                                                                            <br />
                                                                            <span style="width:300px; min-width:200px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">(* = Cobertura Obligatoria)</span>
                                                                        </div>
                                                                        <div style="display:inline; float:left; width:345px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">
                                                                            <span style="width:300px; min-width:200px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">Cobertura Respaldada por el Bien:</span>
                                                                            <br />
                                                                            <span style="width:300px; min-width:200px; height: 25px; text-align:center; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px;">(* = Cobertura Obligatoria)</span>
                                                                        </div>
															        </td>
													            </tr>
                                                                <tr>
														            <td colspan="6" style="clear:both;" valign="top">
                                                                        <div id="divCoberturasPorAsignar" style="display:inline; float:left; width:340px; height:150px; text-align:left; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:12px; border-left-width:thin; border-right-width:thin; border-top:thin; border-bottom:thin; border-color:#79B7E7; border-style:solid; margin-right:0.5px; overflow:auto;">
                                                                            <div id="lbCoberturasPorAsignar" tabindex="51" runat="server" style="text-align:left; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px; border:0px; overflow:visible; display:block; padding:5px 0px 5px 5px; float:left; margin:5px; max-width:0px;"></div>
                                                                        </div>
                                                                        <div id="divCoberturasAsignadas" style="display:inline; float:left; width:340px; height:150px; text-align:left; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:12px; border-left-width:thin; border-right-width:thin; border-top:thin; border-bottom:thin; border-color:#79B7E7; border-style:solid; margin-left:0.5px; overflow:auto;">
                                                                            <div id="lbCoberturasAsignadas" tabindex="52" runat="server" style="text-align:left; font-style:normal; font-family:Verdana, Tahoma, Arial; font-size:11px; border:0px; overflow:visible; display:block; padding:5px 0px 5px 5px; float:left; margin:5px; max-width:0px;"></div>
                                                                         </div>
															        </td>
													            </tr>
												            </table>
                                                        </div>
                                                    </div>
										        </td>
									        </tr>

									        <tr>
										        <td class="td_Texto" colspan="4"><br>
										        </td>
									        </tr>
									        <tr>
										        <td colspan="2">
										        </td>
										        <td class="td_Texto" colspan="2">
										            <asp:button id="btnLimpiar" tabIndex="54" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button>
												    <asp:button id="btnModificar" tabIndex="55" runat="server" ToolTip="Modificar Garantía" Text="Modificar"></asp:button>
												    <asp:button id="btnEliminar" tabIndex="56" runat="server" ToolTip="Eliminar Garantía" Text="Eliminar"></asp:button>
											    </td>
									        </tr>
								        </table>
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" style="height: 20px" width="100%" bgColor="#dcdcdc" colspan="4"
								        rowSpan="1"><asp:label id="lblCatalogo" runat="server">Garantías Reales de la Operación</asp:label></td>
						        </tr>
						        <tr>
							        <td align="center">
							            <br>
							                <asp:GridView ID="gdvGarantiasReales" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="cod_operacion, cod_garantia_real, cod_tipo_garantia_real, Garantia_Real" 
                                             OnRowCommand="gdvGarantiasReales_RowCommand" 
                                             OnRowDataBound="gdvGarantiasReales_RowDataBound"
                                             OnPageIndexChanging="gdvGarantiasReales_PageIndexChanging" 
                                             CssClass="gridview" BorderColor="black" >
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:ButtonField DataTextField="tipo_garantia_real" CommandName="SelectedGarantiaReal" HeaderText="Tipo de Garantía Real">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="200px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="Garantia_Real" CommandName="SelectedGarantiaReal" HeaderText="Garantía Real">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:BoundField DataField="cod_operacion" Visible="False"/>
                                                    <asp:BoundField DataField="cod_garantia_real" Visible="False"/>
                                                    <asp:BoundField DataField="cod_tipo_garantia_real" Visible="False"/>
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
    <asp:HiddenField ID="hdnBtnPostback" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="hdnFechaActual" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="hdnIndiceAccordionActivo" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnHabilitarValuacion" runat="server" Value="0"></asp:HiddenField>
    <asp:HiddenField ID="hdnListaSemestresCalculados" runat="server"></asp:HiddenField>
    <asp:HiddenField ID="hdnIndiceAccordionPolizaActivo" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnHabilitarPoliza" runat="server" Value="0"></asp:HiddenField>
    <asp:HiddenField ID="hdnAplicaCalculoPA" runat="server" Value="1"></asp:HiddenField>
   
</asp:Content>

