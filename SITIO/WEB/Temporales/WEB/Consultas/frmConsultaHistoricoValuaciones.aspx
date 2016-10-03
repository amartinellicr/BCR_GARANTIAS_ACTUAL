<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmConsultaHistoricoValuaciones.aspx.cs" Inherits="Consultas_frmConsultaHistoricoValuaciones" Title="BCR GARANTIAS - Consulta histórico valuaciones" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
   <asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto"></asp:ScriptManager>
    <asp:UpdatePanel id="UpdatePanel1" runat="server">
        <contenttemplate>
            <div>
		        <table id="tblTablaPrincipal" style="WIDTH: 775px" cellSpacing="1" cellPadding="1" width="775" align="center"
			        bgColor="window" border="0">
			        <tr>
				        <td style="HEIGHT: 43px" align="center" colSpan="3">
					        <!--TITULO PRINCIPAL-->
						        <center>
						        <b>
						            <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Consulta Histórico de Valuaciones</asp:label>
					            </b>
					            <b></b> 
					            </center>
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
										        <td colSpan="10"><asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												        Width="194px">
												        <asp:ListItem Value="1">Operaci&#243;n Crediticia</asp:ListItem>
												        <asp:ListItem Value="2">Contrato</asp:ListItem>
											        </asp:dropdownlist><asp:button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:button></td>
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
												        Text="Validar Operación" OnClick="btnValidarOperacion_Click"></asp:button></td>
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
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Listado de garantías
							        </td>
						        </tr>
						        <tr>
							        <td>
                                            <table  id="tblMensaje2" width="100%" align="center" border="0" runat="server">
                                                <tr>
										            <td align="center" colSpan="4"><asp:label id="lblMensaje2" runat="server" CssClass="TextoError"></asp:label></td>
									            </tr>
                                            </table>
                                            
                                           <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorTabla" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>
                                            
                                    </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								        rowSpan="1"><asp:label id="lblListadoHistorico" runat="server">Listado de valuaciones históricas de la garantía</asp:label></td>
						        </tr>
						       
						        <tr>
							        <td align="center">
							        
							         <table  id="Table1" width="100%" align="center" border="0" runat="server">
                                                <tr>
                                                <td align="center" colSpan="4" style="height: 12px">
                                                <asp:label id="lblMensaje3" runat="server" CssClass="TextoError"></asp:label>
                                                </td>
                                                </tr>
                                      </table>
                                      
							            <asp:GridView ID="gdvValuacionesHistoricas" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="fecha_valuacion,monto_tasacion_actualizada_terreno,
                                             monto_tasacion_actualizada_no_terreno, monto_total_avaluo, cedula_perito, cedula_empresa, monto_ultima_tasacion_terreno,
                                             monto_ultima_tasacion_no_terreno, fecha_ultimo_seguimiento, fecha_construccion, nombre_cliente_perito, nombre_cliente_empresa"
                                             OnRowCommand="gdvValuacionesHistoricas_RowCommand" 
                                             OnRowDataBound="gdvValuacionesHistoricas_RowDataBound"
                                             OnPageIndexChanging="gdvValuacionesHistoricas_PageIndexChanging" 
                                             CssClass="gridview" BorderColor="black" >
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:ButtonField DataTextField="fecha_valuacion" CommandName="SelectedValuacionesHistoricas" HeaderText="Fecha" DataTextFormatString="{0:d}"> 
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="200px" />
                                                        <HeaderStyle BorderColor="Black"/>
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_terreno" CommandName="SelectedValuacionesHistoricas" HeaderText="Tasación Act. Terreno Calc." DataTextFormatString ="{0:0,0.00}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_no_terreno" CommandName="SelectedValuacionesHistoricas" HeaderText="Tasación Act. No Terreno Calc." DataTextFormatString ="{0:0,0.00}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_total_avaluo" CommandName="SelectedValuacionesHistoricas" HeaderText="Monto Total Avaluo" DataTextFormatString ="{0:0,0.00}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                     <asp:BoundField  DataField="cedula_perito" HeaderText="Cedula perito" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="cedula_empresa" HeaderText="Cedula empresa" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="monto_ultima_tasacion_terreno" HeaderText="Mto. ultima tasacion" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                     <asp:BoundField DataField="monto_ultima_tasacion_no_terreno" HeaderText="Mto. ultima tasacion no terreno" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="fecha_ultimo_seguimiento" HeaderText="Fecha ultimo seguimiento" DataFormatString="{0:d}" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="fecha_construccion" HeaderText="Fecha construcción" DataFormatString="{0:d}" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="nombre_cliente_perito" HeaderText="Cliente perito" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="nombre_cliente_empresa" HeaderText="Cliente empresa" Visible = "false">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                </Columns>
                                                <RowStyle BackColor="#EFF3FB" />
                                                <EditRowStyle BackColor="#2461BF" />
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                                <AlternatingRowStyle BackColor="White" />
    							         </asp:GridView>
							        </td>
						        </tr>
						        
						        <tr>
							        <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								        rowSpan="1"><asp:label id="lblDetalle" runat="server">Detalle del histórico de valuación de la garantía</asp:label></td>
						        </tr>
						        <tr>
                                    <td>
                                    <table id="tblDetalleInfo" visible ="false" width="70%" align="center" border="1" runat="server">
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Fecha de Valuación:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblFechaValuacion" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Cédula del perito(empresa):
						                </th>
						                <td style="width: 260px">
                                            <asp:Label ID="lblCedulaPeritoEmpresa" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Mto última tasación terreno:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblUltimaTasacionTerreno" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Mto última tasación No terreno:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblUltimaTasacionNoTerreno" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Mto Tasación Actualizada Terreno Calculado:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblTasacionActualizadaTerreno" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Mto Tasación Actualizada No Terreno Calculado:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblTasacionActualizadaNoTerreno" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                  Fecha ultimo seguimiento:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblFechaUltimoSeguimiento" runat="server"></asp:Label>
						                </td>
						            </tr>
						            <tr>
						                <th style="width: 215px" bgcolor= "#F5F5F5" align="left"> 
						                  Fecha construccion:
						                </th>
						                <td style="width: 180px">
                                            <asp:Label ID="lblFechaConstruccion" runat="server"></asp:Label>
						                </td>
						            </tr>
						              
						            </table>   
                                    </td>						        
                                </tr>
					        </table> <!--DEFINE BOTONERA-->
					        <table class="table_Default" width="60%" align="center" border="0">
						        <tr>
							        <td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma; height: 15px;" align="center">Banco 
								        de Costa Rica © Derechos reservados 2006.</td>
						        </tr>
					        </table>
				        </td>
			        </tr>
		        </table>
            </div>
     </contenttemplate>
    </asp:UpdatePanel>
    <asp:HiddenField id="hdnBtnPostback" runat="server"></asp:HiddenField>
    <asp:HiddenField id="hdnFechaActual" runat="server"></asp:HiddenField>
</asp:Content>

