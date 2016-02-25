<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx.cs" Inherits="frmMantenimientoSaldosTotalesPorcentajeResponsabilidad" Title="BCR GARANTIAS - Mantenimiento Saldos Totales y Porcentaje Responsabilidad" %>

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
						            <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Mantenimiento de Saldos Totales y % Responsabilidad</asp:label>
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
										        <td class="td_Texto">Tipo de Búesqueda:</td>
										        <td colSpan="10"><asp:dropdownlist id="cbTipoCaptacion" tabIndex="1" runat="server" AutoPostBack="true" BackColor="AntiqueWhite"
												        Width="194px">
												        <asp:ListItem Value="1">Operaci&#243;n Crediticia</asp:ListItem>
												        <asp:ListItem Value="2">Contrato</asp:ListItem>
                                                        <asp:ListItem Value="2">Garant&#237;a</asp:ListItem>
											        </asp:dropdownlist><asp:button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:button></td>
									        </tr>
									        <tr>
										        <td class="td_Texto" width="24%">Contabilidad:</td>
										        <td width="4%"><asp:textbox id="txtContabilidad" tabIndex="2" runat="server" BackColor="AntiqueWhite" Width="23px"
												        MaxLength="2">1</asp:textbox></td>
										        <td class="td_Texto" width="9%">Oficina:</td>
										        <td width="4%"><asp:textbox id="txtOficina" tabIndex="3" runat="server" BackColor="AntiqueWhite" Width="32px"
												        MaxLength="3">220</asp:textbox></td>
										        <td class="td_Texto" width="9%">Moneda:</td>
										        <td width="4%"><asp:textbox id="txtMoneda" tabIndex="4" runat="server" BackColor="AntiqueWhite" Width="21px"
												        MaxLength="2">1</asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:label id="lblProducto" runat="server">Producto:</asp:label></td>
										        <td width="9%"><asp:textbox id="txtProducto" tabIndex="5" runat="server" BackColor="AntiqueWhite" Width="21px"
												        MaxLength="2">2</asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:label id="lblTipoOperacion" runat="server">Operación:</asp:label></td>
										        <td width="9%"><asp:textbox id="txtOperacion" tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="64px"
												        MaxLength="7">5904248</asp:textbox></td>
										        <td class="td_Texto" width="9%"><asp:button id="btnValidarOperacion" tabIndex="7" runat="server" ToolTip="Verifica que la operación sea valida"
												        Text="Validar"></asp:button></td>
									        </tr>
									       <%-- <tr>
										        <td class="td_Texto"><asp:label id="lblDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												        Font-Italic="true">Deudor:</asp:label></td>
										        <td class="td_TextoIzq" colSpan="10"><asp:label id="lblNombreDeudor" runat="server" Visible="False" Font-Bold="true" ForeColor="SteelBlue"
												        Font-Italic="true"></asp:label></td>
									        </tr>--%>
								        </table>
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Relaciones
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#e8e8e8" colSpan="4" rowSpan="1">Garantias Fiduciarias Relacionadas
							        </td>
						        </tr>
						        <tr align="left">
						            <td>						                      
                                          <%-- <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorGarantiaFiduciaria" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>--%>
                                        <table>
                                            <tbody>
                                                <tr>
                                                    <td><a id=A1 title="Grado:  - Cédula Hipotecaria " style="COLOR: blue" href="javascript:__doPostBack('ctl00$cphPrincipal$261645','')" runat="Server">1-401640971 </a></td>
                                                    <td width=12>&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                    <td><a id=A2 title="Grado:  - Cédula Hipotecaria " style="COLOR: blue" href="javascript:__doPostBack('ctl00$cphPrincipal$261646','')" runat="Server">2-3994 </a></td>
                                                    <td width=12>&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>          
						            </td>
						        </tr>
                                <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#e8e8e8" colSpan="4" rowSpan="1">Garantías Reales Relacionadas
							        </td>
						        </tr>
						        <tr align="left">
						            <td>
                                            <%--<table  id="tblMensaje2" width="100%" align="center" border="0" runat="server">
                                                <tr>
										            <td align="center" colSpan="4"><asp:label id="lblMensaje2" runat="server" CssClass="TextoError"></asp:label></td>
									            </tr>									            
                                            </table>
                                            
                                           <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorTabla" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>   --%>    
                                        
                                        <table>
                                            <tbody>
                                                <tr>
                                                    <td><a id=ctl00_cphPrincipal_261645 title="Grado:  - Cédula Hipotecaria " style="COLOR: red" href="javascript:__doPostBack('ctl00$cphPrincipal$261645','')" runat="Server">1-109795 </a></td>
                                                    <td width=12>&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                    <td><a id=ctl00_cphPrincipal_261646 title="Grado:  - Cédula Hipotecaria " style="COLOR: blue" href="javascript:__doPostBack('ctl00$cphPrincipal$261646','')" runat="Server">4-100899 </a></td>
                                                    <td width=12>&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#e8e8e8" colSpan="4" rowSpan="1">Garantías Valor Relacionadas
							        </td>
						        <tr align="left">
						            <td>   						              
                                            
                                          <%-- <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorGarantiaValor" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>--%>
                                        <table>
                                            <tbody>
                                                <tr>
                                                    <td><a id=A3 title="Grado:  - Cédula Hipotecaria " style="COLOR: blue" href="javascript:__doPostBack('ctl00$cphPrincipal$261645','')" runat="Server">3101403350 </a></td>
                                                    <td width=12>&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                    <td><a id=A4 title="Grado:  - Cédula Hipotecaria " style="COLOR: blue" href="javascript:__doPostBack('ctl00$cphPrincipal$261646','')" runat="Server">61822100 </a></td>
                                                    <td width="12">&nbsp;&nbsp;/&nbsp;&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>                                              
						            </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								        rowSpan="1"><asp:label id="lblListadoHistorico" runat="server">Distribución</asp:label></td>
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
                                      
							            <%--<asp:GridView ID="gdvValuacionesHistoricas" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames=""
                                             OnRowCommand="gdvValuacionesHistoricas_RowCommand" 
                                             OnRowDataBound="gdvValuacionesHistoricas_RowDataBound"
                                             OnPageIndexChanging="gdvValuacionesHistoricas_PageIndexChanging" 
                                             CssClass="gridview" BorderColor="black" >
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:ButtonField DataTextField="fecha_valuacion" CommandName="SelectedValuacionesHistoricas" HeaderText="Operaciones o Contratos Relacionados"> 
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="200px" />
                                                        <HeaderStyle BorderColor="Black"/>
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_terreno" CommandName="SelectedValuacionesHistoricas" HeaderText="Saldo" DataTextFormatString = "{0:0,0.00}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_tasacion_actualizada_no_terreno" CommandName="SelectedValuacionesHistoricas" HeaderText="% Responsabilidad Calculado" DataTextFormatString = "{0:0,0.00}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_total_avaluo" CommandName="SelectedValuacionesHistoricas" HeaderText="Cta. Contable">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="monto_total_avaluo" CommandName="SelectedValuacionesHistoricas" HeaderText="Tipo Operación">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                </Columns>
                                                <RowStyle BackColor="#EFF3FB" />
                                                <EditRowStyle BackColor="#2461BF" />
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                                <AlternatingRowStyle BackColor="White" />
    							         </asp:GridView>--%>


                                        
                                        <TABLE id=ctl00_cphPrincipal_gdvValuacionesHistoricas class=gridview style="BORDER-TOP-COLOR: black; WIDTH: 730px; BORDER-COLLAPSE: collapse; BORDER-LEFT-COLOR: black; COLOR: #333333; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" cellSpacing=0 cellPadding=4 rules=all border=1><TBODY>
                                        <TR style="FONT-WEIGHT: bold; COLOR: white; BACKGROUND-COLOR: #507cd1">
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>Operaciones o Contratos Relacionados</TH>
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>Saldo</TH>
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>% Responsabilidad Calculado</TH>
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>Cta. Contable</TH>
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>Tipo Operación</TH>
                                        <TH style="BORDER-TOP-COLOR: black; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" scope=col>Excluida</TH></TR>
                                        <TR style="FONT-WEIGHT: bold; COLOR: #333333; BACKGROUND-COLOR: #d1ddf1">
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 200px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" href="javascript:__doPostBack('ctl00$cphPrincipal$gdvValuacionesHistoricas','SelectedValuacionesHistoricas$0')">1-220-1-2-5904248</A></TD>
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" >20,687,180.64</A></TD>
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" >80.00</A></TD>
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" >131</A></TD>
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" >Operaci&#243;n</A></TD>
                                        <TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" ><input type="checkbox"/></A></TD>
                                        <%--<TD style="BORDER-TOP-COLOR: black; WIDTH: 500px; BORDER-LEFT-COLOR: black; BORDER-BOTTOM-COLOR: black; BORDER-RIGHT-COLOR: black" align=center><A style="COLOR: #333333" ><input type="checkbox" checked="checked"/></A></TD>--%>

                                        </TR></TBODY></TABLE>
                                       
							        </td>
						        </tr>
						        
						        <tr>
							        <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								        rowSpan="1"><asp:label id="lblDetalle" runat="server">Ajustes</asp:label></td>
						        </tr>
						        <tr>
                                    <td valign="middle">
                                        <div style="width:100%;">
                                            <div style="float:left; height: 150px; vertical-align:middle;">
                                                <button id="Anterior" type="button" style="height:100%; text-decoration:solid; font-weight:bolder; width:20px;"><</button>
                                            </div>
                                            <div style="float:left; height:150px; width:690px;">
                                                <table id="tblDetalleInfo" align="center" border="1" runat="server" style="width:70%;">
 						                            <tr>
                                            
						                                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                                  Número Operación o Contrato:
						                                </th>
						                                <td style="width: 180px">
                                                            <asp:Label ID="lblFechaValuacion" runat="server">1-220-1-2-5904248</asp:Label>
						                                </td>
						                            </tr>
						                            <tr>
						                                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                                  Saldo Ajustado:
						                                </th>
						                                <td style="width: 260px">
                                                            <asp:Label ID="lblCedulaPeritoEmpresa" runat="server">18,687,181.64</asp:Label>
						                                </td>
						                            </tr>
						                            <tr>
						                                <th style="width: 215px" bgcolor= "#F5F5F5" align="left">
						                                  % Responsabilidad Ajustado:
						                                </th>
						                                <td style="width: 180px">
                                                            <asp:Label ID="lblUltimaTasacionTerreno" runat="server">75.65</asp:Label>
						                                </td>
						                            </tr>
						                            <tr>
										               <td  colspan="2" align="center">
										                    <asp:button id="btnLimpiar" tabIndex="24" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button>
										                   <%-- <asp:button id="btnInsertcar" tabIndex="25" runat="server" ToolTip="Incluir una operación excluída de la distribución" Text="Incluir"></asp:button>--%>
										                    <asp:button id="btnModificar" tabIndex="26" runat="server" ToolTip="Modificar Garantía" Text="Modificar"></asp:button>
										                    <asp:button id="btnEliminar" tabIndex="27" runat="server" ToolTip="Eliminar Garantía" Text="Eliminar"></asp:button>
										                </td>
									                </tr>				            
						                            
						                        </table>                                     
                                            </div>
                                            <div style="float:left; height:150px;">
                                                <button id="Siguiente" type="button" style="height:100%; text-decoration:solid; font-weight:bolder; width:20px;">></button>
                                            </div>
                                        </div>
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

