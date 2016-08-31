<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmRptFiltroBitacora.aspx.cs" Inherits="Reportes_frmRptFiltroBitacora" Title="BCR GARANTIAS - Reportes" %>

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
				    <td style="HEIGHT: 43px" align="center" colspan="3">
                        &nbsp;<asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Transacciones de la Bitácora</asp:label>
				    </td>
			    </tr>
			    <tr>
				    <td valign="top" colspan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 18px" width="100%" bgColor="#dcdcdc" colspan="4"
								    rowSpan="1">BCR GARANTIAS&nbsp;- Filtros de Consulta
							    </td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" colspan="6">
										        <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
									       <td style="height: 38px; width: 750px;" colspan="10" valign="middle">
                                                <table width="100%" align="center" border="0">
                                                    <tr>
                                                        <td style="width: 175px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoSolicitado" runat="server" Text="Código del Usuario:"></asp:Label>
									                    </td>
                                                        <td class="td_TextoIzq">
                                                            <%-- Filtro por código de usuario --%>
                                                           <asp:TextBox ID="txtCodigoUsuario" runat="server" Visible="true" TabIndex="1"></asp:TextBox>
                                                           <ajaxToolkit:FilteredTextBoxExtender ID="ftbeCodigoUsuario" runat="server" FilterType="Numbers" 
                                                            TargetControlID="txtCodigoUsuario">
                                                            </ajaxToolkit:FilteredTextBoxExtender>
                                                        </td>
                                                        <td style="width: 175px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoIP" runat="server" Text="Número de IP:"></asp:Label>
									                    </td>
                                                        <td class="td_TextoIzq">
                                                            <%-- Filtro por IP --%>  
                                                          <asp:TextBox ID="txtIP" runat="server" Visible="true" MaxLength="15" TabIndex="2"></asp:TextBox>
                                                            <ajaxToolkit:FilteredTextBoxExtender ID="ftbeIP" runat="server" FilterType="Custom, Numbers" 
                                                            ValidChars="." TargetControlID="txtIP">
                                                            </ajaxToolkit:FilteredTextBoxExtender>
                                                        </td>
                                                    </tr>
 									                <tr>
                                                        <td style="width: 177px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoOperacion" runat="server" Text="Operación Realizada:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq">
                                                            <%-- Filtro por código de operación --%>
                                                            <asp:DropDownList id="cbCodigoOperacion" style="POSITION:relative; vertical-align:middle"
		                                                        runat="server" Width="100px" Height="28px" Visible="true"  TabIndex="3">
		                                                        <asp:ListItem Value="-1" Text=""></asp:ListItem>
		                                                        <asp:ListItem Value="1">Insertar</asp:ListItem>
		                                                        <asp:ListItem Value="2">Modificar</asp:ListItem>
		                                                        <asp:ListItem Value="3">Borrar</asp:ListItem>
	                                                        </asp:DropDownList>
	                                                    </td>
	                                                    <td style="width: 177px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblCriterioOrdenacion" runat="server" Text="Criterio de Orden:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq">
                                                            <%-- Filtro por código de operación --%>
                                                            <asp:DropDownList id="cbCriterioOrden" style="Z-INDEX: 50; POSITION: relative; vertical-align:middle"
		                                                        runat="server" Width="140px" Height="28px" Visible="true"  TabIndex="3">
		                                                        <asp:ListItem Value="cod_usuario" Text="C&#243;digo Usuario"></asp:ListItem>
		                                                        <asp:ListItem Value="cod_ip">C&#243;digo IP</asp:ListItem>
		                                                        <asp:ListItem Value="cod_operacion">C&#243;digo de Operaci&#243;n</asp:ListItem>
		                                                        <asp:ListItem Value="fecha_hora">Fecha</asp:ListItem>
	                                                        </asp:DropDownList>
	                                                    </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoSolicitadoFecha" runat="server" Text="Fecha Desde:"></asp:Label>
									                    </td>
                                                        <td class="td_TextoIzq" colspan="10">
                                                            <table>
                                                                <tr>
                                                                    <td class="td_TextoIzq">
                                                                        <%-- Filtro por rango de fechas --%>
                                                                        <asp:TextBox ID="txtFechaInicial" BackColor="White" tabIndex="4" runat="server" Width="70px" 
								                                                 MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de inicial del reporte" Visible="true" />
                                                                        <asp:ImageButton ID="igbCalendarioInicial" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="true" />
                                                                        <ajaxToolkit:MaskedEditExtender ID="meeFechaInicial" runat="server"
                                                                            TargetControlID="txtFechaInicial"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />
                                                                        <ajaxToolkit:CalendarExtender ID="cleFechaInicial" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaInicial" PopupButtonID="igbCalendarioInicial" />
                                                                    </td>
                                                                    <td align="center">
                                                                       <asp:Label ID="lblEntreFechas" runat="server" Text="     Hasta: " Visible="true" Width="70px"></asp:Label> 
                                                                    </td>
                                                                    <td class="td_TextoIzq">
                                                                        <asp:TextBox ID="txtFechaFinal" BackColor="White" tabIndex="5" runat="server" Width="70px" 
							                                                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de inicial del reporte" Visible="true" />
                                                                        <asp:ImageButton ID="igbCalendarioFinal" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="true" />
                                                                        <ajaxToolkit:MaskedEditExtender ID="meeFechaFinal" runat="server"
                                                                            TargetControlID="txtFechaFinal"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />
                                                                        <ajaxToolkit:CalendarExtender ID="CalendarExtender1" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaFinal" PopupButtonID="igbCalendarioFinal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
	                                                </tr>
	                                                <tr>
	                                                    <td style="width: 177px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblNombreMantenimiento" runat="server" Text="Mantenimiento:"></asp:Label>
									                    </td>
	                                                    <td class="td_TextoIzq">
                                                            <%-- Filtro por nombre de mantenimiento --%>
                                                            <asp:DropDownList ID="cbMantenimientos" runat="server">
                                                                <asp:ListItem Value="-1" Text=""></asp:ListItem>
		                                                        <asp:ListItem Value="1">Garantías Fiduciarias</asp:ListItem>
		                                                        <asp:ListItem Value="2">Garantías para Tarjetas</asp:ListItem>
		                                                        <asp:ListItem Value="3">Garantías Reales</asp:ListItem>
		                                                        <asp:ListItem Value="4">Garantías de Valor</asp:ListItem>
		                                                        <asp:ListItem Value="5">Relacionar Giro</asp:ListItem>
		                                                        <asp:ListItem Value="6">Capacidad de Pago</asp:ListItem>
		                                                        <asp:ListItem Value="7">Deudores de Garantías Fiduciarias</asp:ListItem>
		                                                        <asp:ListItem Value="8">Deudores de Garantías Reales</asp:ListItem>
		                                                        <asp:ListItem Value="9">Deudores de Garantías de Valor</asp:ListItem>
		                                                        <asp:ListItem Value="10">Histórico de Ingresos</asp:ListItem>
		                                                        <asp:ListItem Value="11">Mantenimiento de Valuaciones Reales</asp:ListItem>
		                                                        <asp:ListItem Value="12">Peritos</asp:ListItem>
		                                                        <asp:ListItem Value="13">Empresas</asp:ListItem>
		                                                        <asp:ListItem Value="14">Catálogos</asp:ListItem>
		                                                        <asp:ListItem Value="15">Perfiles</asp:ListItem>
		                                                        <asp:ListItem Value="16">Roles por Perfil</asp:ListItem>
		                                                        <asp:ListItem Value="17">Usuarios</asp:ListItem>
                                                            </asp:DropDownList> 
	                                                    </td>
	                                                </tr>
		                                        </table>
									       </td>
										</tr> 
										<tr>
										    <td class="td_Texto" colspan="10"><br/>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colspan="10">
										        <asp:button id="btnConsultar" tabIndex="6" runat="server" ToolTip="Consultar" Text="Consultar"></asp:button>
										        <asp:button id="btnGenerarReporte" tabIndex="7" runat="server" ToolTip="Generar Reporte" Text="Generar Reporte"></asp:button>
										        <asp:button id="btnExportar" tabIndex="7" runat="server" ToolTip="Exportar Excel" Text="Exportar Excel"></asp:button>
											</td>
									    </tr>  
								    </table>
							    </td>
						    </tr>
						     <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1" style="font-size:medium">
							        <asp:Panel ID="pnlEncabezadoReporte" runat="server" CssClass="collapsePanelHeaderRpt"> 
							            <div style="padding:5px; cursor: pointer; vertical-align: middle;">
                                            <div style="float: left;">Detalle de la Bitácora</div>
                                            <div style="float: left; margin-left: 20px;">
                                                <asp:Label ID="lblLeyendaPanel" runat="server">(Mostrar Detalles...)</asp:Label>
                                            </div>
                                            <div style="float: right; vertical-align: middle;">
                                                <asp:ImageButton ID="imgExpande" runat="server" ImageUrl="~/Images/downarrows_white.gif" AlternateText="(Show Details...)"/>
                                            </div>
                                        </div>
							        </asp:Panel>
							        <asp:Panel ID="pnlDetalleReporte" runat="server" Width="775px" CssClass="collapsePanelRpt"> 
							            <table>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblUsuario" runat="server">Código de Usuario:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblUsuarioObt" runat="server" ></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblIP" runat="server">IP:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblIPObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblFecha" runat="server">Fecha:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblFechaObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblOperacion" runat="server">Operación Realizada:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblOperacionObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblTabla" runat="server">Nombre de la tabla afectada:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblTablaObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblCampoAfectado" runat="server">Campo Afectado:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblCampoAfectadoObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblEstadoAnterior" runat="server">Estado Anterior del Campo:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblEstadoAnteriorObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblEstadoActual" runat="server">Estado Actual del Campo:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblEstadoActualObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblTipoGarantia" runat="server">Tipo de la Garantia:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblTipoGarantiaObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblGarantia" runat="server">Garantía:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblGarantiaObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							                <tr>
							                    <td class="td_Texto">
							                       <asp:Label ID="lblOperacionCrediticia" runat="server">Operación Crediticia:</asp:Label> 
							                    </td>
							                    <td class="td_TextoIzq">
							                        <asp:Label ID="lblOperacionCrediticiaObt" runat="server"></asp:Label> 
							                    </td>
							                </tr>
							            </table>
							        </asp:Panel>
							        
							        <ajaxToolkit:CollapsiblePanelExtender ID="cpeDetalleRegistro" runat="Server"
                                        TargetControlID="pnlDetalleReporte"
                                        ExpandControlID="pnlEncabezadoReporte"
                                        CollapseControlID="pnlEncabezadoReporte" 
                                        CollapsedSize="0"
                                        ExpandedSize="200"
                                        Collapsed="True"
                                        ImageControlID="imgExpande"
                                        AutoCollapse="False"
                                        AutoExpand="False"
                                        ScrollContents="True"
                                        TextLabelID="lblLeyendaPanel"
                                        CollapsedText="Mostrar Detalles..."
                                        ExpandedText="Ocultar Detalles" 
                                        ExpandedImage="~/Images/uparrows_white.gif"
                                        CollapsedImage="~/Images/downarrows_white.gif"
                                        ExpandDirection="Vertical" />
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1" style="height: 31px">
							        <asp:label id="lblCatalogo" runat="server">Resultado de la Consulta</asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
<%--							        <asp:Panel ID="Panel1" runat="server" Width="775px">
--%>								            <asp:GridView ID="gdvReporte" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" PageSize="10" Font-Size="70%"  
                                             OnRowCommand="gdvReporte_RowCommand" 
                                             OnPageIndexChanging="gdvReporte_PageIndexChanging" 
                                             OnDataBinding="gdvReporte_DataBinding"  CssClass="gridview" BorderColor="black"
                                             DataKeyNames="des_tabla, cod_usuario, cod_ip, cod_operacion, des_operacion, fecha_hora,  
                                                            cod_tipo_garantia, des_tipo_garantia, cod_garantia, cod_operacion_crediticia,  
                                                            des_campo_afectado, est_anterior_campo_afectado, est_actual_campo_afectado" > 
                                                            
                                                <Columns>
                                                    <asp:ButtonField DataTextField="cod_usuario" CommandName="SelectedPistaAuditoria" HeaderText="Usuario" Visible="True" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="fecha_hora" Visible="true" HeaderText="Fecha" ItemStyle-Width="300px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="des_operacion" Visible="true" HeaderText="Operación Realizada" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="cod_operacion_crediticia" Visible="true" HeaderText="Operación Crediticia" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="cod_garantia" Visible="true" HeaderText="Garantía" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="des_tipo_garantia" Visible="true" HeaderText="Tipo Garantía" ItemStyle-Width="190px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="des_campo_afectado" Visible="true" HeaderText="Campo Afectado" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="est_anterior_campo_afectado" Visible="true" HeaderText="Estado Anterior" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="est_actual_campo_afectado" Visible="true" HeaderText="Estado Actual" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="des_tabla" Visible="false"/>
                                                    <asp:BoundField DataField="cod_ip" Visible="false"/>
                                                    <asp:BoundField DataField="cod_operacion" Visible="false"/>
                                                    <%--<asp:BoundField DataField="cod_consulta" Visible="false"/>--%>
                                                    <asp:BoundField DataField="cod_tipo_garantia" Visible="false"/>
                                                    <%--<asp:BoundField DataField="cod_consulta2" Visible="false"/>--%>
                                                </Columns>
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%"/>
                                                <RowStyle BackColor="#EFF3FB" BorderColor="black"/>
                                                <EditRowStyle BackColor="#2461BF" BorderColor="black"/>
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" BorderColor="black"/>
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" BorderColor="black"/>
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" BorderColor="black"/>
                                                <AlternatingRowStyle BackColor="White" BorderColor="black"/>
    							            </asp:GridView>
<%--								    </asp:Panel>
--%>							    </td>
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

