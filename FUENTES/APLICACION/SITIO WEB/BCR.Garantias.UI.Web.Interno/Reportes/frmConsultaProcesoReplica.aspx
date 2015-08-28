<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmConsultaProcesoReplica.aspx.cs" Inherits="Reportes_frmConsultaProcesoReplica" Title="Ejecución de Procesos de Rélica" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
 <asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto" EnableScriptGlobalization="true" EnableScriptLocalization="true">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
		    <table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
			    border="0" cellSpacing="1">
			    <tr>
				    <td style="HEIGHT: 43px" align="center" colspan="3">
                        &nbsp;<asp:label id="lblTexto" runat="server" CssClass="TextoTitulo">Ejecución de Procesos de Réplica</asp:label>
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
									       <td style="height: 38px; width: 600px;" colspan="8" valign="middle" align="center">
                                                <table width="100%" align="center" border="0">
                                                     <tr>
                                                        <td style="width: 150px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoSolicitadoFecha" runat="server" Text="Fecha Desde:"></asp:Label>
									                    </td>
                                                        <td class="td_TextoIzq" style="position:relative; z-index:1;">
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
                                                        <td style="width: 150px; height: 38px;" class="td_Texto" valign="middle">
                                                           <asp:Label ID="lblEntreFechas" runat="server" Text="Hasta: " Visible="true" Width="70px"></asp:Label> 
                                                        </td>
                                                        <td class="td_TextoIzq" style="position:relative; z-index:1;">
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
                                                            <ajaxToolkit:CalendarExtender ID="cleFechaFinal" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaFinal" PopupButtonID="igbCalendarioFinal" />
                                                        </td>
	                                                </tr>
									                <tr>
                                                        <td style="width: 150px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblDatoProceso" runat="server" Text="Proceso Ejecutado:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq"valign="middle">
                                                            <%-- Filtro por cdigo de proceso --%>
                                                            <asp:DropDownList id="cbCodigoProceso"  style="z-index:1; position:relative; vertical-align:middle"
		                                                        runat="server" Width="180px" Visible="true" TabIndex="3">
		                                                        <asp:ListItem Value="-1" Text=""></asp:ListItem>
		                                                        <asp:ListItem Value="MIGRARGARANTIAS">Migrar Garantías</asp:ListItem>
		                                                        <asp:ListItem Value="ACTUALIZARGARANTIAS">Actualizar Garantías</asp:ListItem>
		                                                        <asp:ListItem Value="CARGARCONTRATVENCID">Cargar Contratos Vencidos</asp:ListItem>
		                                                        <asp:ListItem Value="GENERAARCHIVOSUGEF">Generar Archivos SUGEF</asp:ListItem>
		                                                        <asp:ListItem Value="CALCULAR_MTAT_MTANT">Cálculo Avalúos</asp:ListItem>
                                                                <asp:ListItem Value="MIGRARPOLIZAS">Migrar Pólizas</asp:ListItem>
	                                                        </asp:DropDownList>
	                                                    </td>
	                                                    <td style="width: 150px; height: 38px;" class="td_Texto" valign="middle">
                                                            <asp:Label ID="lblIndicadorResultado" runat="server" Text="Resultado:"></asp:Label>
									                    </td>
									                    <td class="td_TextoIzq" valign="middle">
                                                            <%-- Filtro por indicador del resultado --%>
                                                            <asp:DropDownList id="cbIndicadorResultado" style="z-index:1; position:relative; vertical-align:middle"
		                                                        runat="server" Width="120px" Visible="true" TabIndex="3">
		                                                        <asp:ListItem Value="-1" Text=""></asp:ListItem>
		                                                        <asp:ListItem Value="0">Exitoso</asp:ListItem>
		                                                        <asp:ListItem Value="1">Fallido</asp:ListItem>
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
										    <td class="td_Texto" colspan="8">
										        <asp:button id="btnConsultar" tabIndex="6" runat="server" ToolTip="Consultar" Text="Consultar"></asp:button>
											</td>
									    </tr>  
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1" style="height: 31px">
							        <asp:label id="lblCatalogo" runat="server">Resultado de la Consulta</asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
								            <asp:GridView ID="gdvReporte" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" PageSize="10" Font-Size="70%"  
                                             OnPageIndexChanging="gdvReporte_PageIndexChanging" CssClass="gridview" BorderColor="black"
                                             DataKeyNames="cocProceso, fecIngreso, Resultado, desObservacion" > 
                                                            
                                                <Columns>
                                                    <asp:ButtonField DataTextField="fecIngreso" HeaderText="Fecha-Hora Ejecucin" Visible="True" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="cocProceso" Visible="true" HeaderText="Paquetes Ejecutados" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="Resultado" Visible="true" HeaderText="Resultado" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:BoundField DataField="desObservacion" Visible="true" HeaderText="Detalle" ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                </Columns>
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%"/>
                                                <RowStyle BackColor="#EFF3FB" BorderColor="black"/>
                                                <EditRowStyle BackColor="#2461BF" BorderColor="black"/>
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" BorderColor="black"/>
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" BorderColor="black"/>
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" BorderColor="black"/>
                                                <AlternatingRowStyle BackColor="White" BorderColor="black"/>
    							            </asp:GridView>
							    </td>
						    </tr>
					    </table> <!--DEFINE BOTONERA-->
					    <table class="table_Default" width="60%" align="center" border="0">
						    <tr>
							    <td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">Banco 
								    de Costa Rica  Derechos reservados 2006.</td>
						    </tr>
					    </table>
				    </td>
			    </tr>
		    </table>
        </div>
    </contenttemplate>
</asp:UpdatePanel>
</asp:Content>

