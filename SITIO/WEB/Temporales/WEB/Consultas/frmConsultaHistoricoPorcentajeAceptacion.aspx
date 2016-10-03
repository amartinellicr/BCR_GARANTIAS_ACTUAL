<%@ Page Title="" Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmConsultaHistoricoPorcentajeAceptacion.aspx.cs" Inherits="Consultas_frmConsultaHistoricoPorcentajeAceptacion" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
  <asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto"></asp:ScriptManager>
    <asp:UpdatePanel id="UpdatePanel1" runat="server">

         <contenttemplate>

                <div>
		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo">Histórico de Porcentajes de Aceptación</asp:label></td>
			</tr>
			<tr>
				<td valign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Histórico de Porcentajes de Aceptación</td>
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
                                                            <asp:Label ID="lblCodigoUsuario" runat="server" Text="Código del Usuario:"></asp:Label>
									                    </td>
                                                        <td class="td_TextoIzq">
                                                            <%-- Filtro por código de usuario --%>
                                                           <asp:TextBox ID="txtCodigoUsuario" runat="server" Visible="true" TabIndex="1"></asp:TextBox>                                                        
                                                        </td>
                                                                                                           
                                                    </tr>
 									                <tr>
                                                        <td style="width: 177px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblTipoGarantia" runat="server" Text="Tipo de Garantía:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq">                                                           											
										                 <asp:DropDownList id="cboTipoGarantia" tabIndex="1" runat="server" Width="225px" BackColor="AliceBlue"></asp:DropDownList>
	                                                    </td>	                                                  
                                                    </tr>
                                                     <tr>
                                                        <td style="width: 177px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="Label1" runat="server" Text="Tipo de Mitigador:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq">                                                           											
										              <asp:DropDownList id="cboTipoMitigador" tabIndex="2" runat="server" Width="493px" BackColor="AliceBlue"></asp:DropDownList>
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
                                                                        <ajaxtoolkit:maskededitextender ID="meeFechaInicial" runat="server"
                                                                            TargetControlID="txtFechaInicial"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />

                                                                            <%-- <ajaxToolkit:MaskedEditValidator ID="mevFechaInicial" runat="server"
                                                                            ControlExtender="meeFechaInicial"
                                                                            ControlToValidate="txtFechaInicial"
                                                                            EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                            InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                            Display="Dynamic"
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />
--%>

                                                                        <ajaxtoolkit:calendarextender ID="cleFechaInicial" Format="dd/MM/yyyy" 
                                                                            CssClass="calendario" runat="server" TargetControlID="txtFechaInicial" 
                                                                            PopupButtonID="igbCalendarioInicial" />
                                                                    </td>
                                                                    <td align="center">
                                                                       <asp:Label ID="lblEntreFechas" runat="server" Text="     Hasta: " Visible="true" Width="70px"></asp:Label> 
                                                                    </td>
                                                                    <td class="td_TextoIzq">
                                                                        <asp:TextBox ID="txtFechaFinal" BackColor="White" tabIndex="5" runat="server" Width="70px" 
							                                                     MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de inicial del reporte" Visible="true" />
                                                                        <asp:ImageButton ID="igbCalendarioFinal" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" Visible="true" />
                                                                        <ajaxtoolkit:maskededitextender ID="meeFechaFinal" runat="server"
                                                                            TargetControlID="txtFechaFinal"
                                                                            Mask="99/99/9999"
                                                                            MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus"
                                                                            OnInvalidCssClass="MaskedEditError"
                                                                            MaskType="Date"
                                                                            DisplayMoney="Left"
                                                                            AcceptNegative="Left"
                                                                            ErrorTooltipEnabled="True" />

                                                                          <%--   <ajaxToolkit:MaskedEditValidator ID="mevFechaFinal" runat="server"
                                                                            ControlExtender="meeFechaFinal"
                                                                            ControlToValidate="txtFechaFinal"
                                                                            EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                            InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                            Display="Dynamic"
                                                                            EmptyValueBlurredText="*"
                                                                            InvalidValueBlurredMessage="*"
                                                                            ValidationGroup="MKE" />--%>

                                                                        <ajaxtoolkit:calendarextender ID="cleFechaFinal" Format="dd/MM/yyyy" 
                                                                            CssClass="calendario" runat="server" TargetControlID="txtFechaFinal" 
                                                                            PopupButtonID="igbCalendarioFinal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
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
                                                  <asp:button id="btnLimpiar" runat="server" Text="Limpiar" ToolTip="Limpiar" ></asp:button>
										        <asp:button id="btnConsultar" tabIndex="6" runat="server" ToolTip="Consultar" Text="Consultar"></asp:button>										       
											</td>
									    </tr>  
								    </table>
							</td>
						</tr>
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
								<asp:Label id="lblIAA" runat="server">Histórico de Porcentajes</asp:Label></td>
						</tr>
						<tr>

                   
							<td align="center">
							    <br/>
							       <asp:GridView ID="gdvPorcentajeAceptacion" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                     AutoGenerateColumns="False"  PageSize="10"  DataKeyNames="TIPO_GARANTIA,TIPO_MITIGADOR"                                     
                                     CssClass="gridview" BorderColor="black"   OnPageIndexChanging="gdvPorcentajeAceptacion_PageIndexChanging" >                                                                     
                                                                                           
                                        <Columns>
                                            <asp:BoundField DataField="ACCION_REALIZADA" HeaderText="Acción Realizada" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="TIPO_GARANTIA" HeaderText="Tipo Garantia" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="TIPO_MITIGADOR" HeaderText="Tipo Mitigador" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="CAMPO" HeaderText="Campo" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="VALOR_PASADO" HeaderText="Valor Pasado" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="VALOR_ACTUAL" HeaderText="Valor Actual" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="FECHA_HORA" HeaderText="Fecha Modificó" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black" DataFormatString="{0:d}"/>
                                            <asp:BoundField DataField="USUARIO" HeaderText="Usuario" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                            <asp:BoundField DataField="NOMBRE_USUARIO" HeaderText="Nombre" Visible="True" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                                                 
                                       </Columns>
                                        <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%"/>
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

