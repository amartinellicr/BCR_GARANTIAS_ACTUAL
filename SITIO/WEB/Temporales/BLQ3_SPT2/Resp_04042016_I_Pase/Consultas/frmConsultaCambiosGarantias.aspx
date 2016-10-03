<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmConsultaCambiosGarantias.aspx.cs" Inherits="Consultas_frmConsultaCambiosGarantias" Title="Untitled Page"  %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit"   %> 

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
						            <asp:label id="lblTitulo" runat="server" CssClass="TextoTitulo">Cambios en Garantias</asp:label>
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
									        </table>    
									        
						            </td>
						        </tr>
						        						       						        
						              <tr>
							               <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" >Consulta Masiva
							               </td>          						              							               
						      		 </tr>						      		 
						      		 <tr>
						      		     <td>
						      		         <table width="100%">                          
						                                    <tr>
						                                        <td  width="50%" align="center" colSpan="3" >						                                    						                            
						                                            <asp:checkbox class="td_Texto" id="chkTodasOperaciones" runat="server" Text="Todas Operaciones" Autopostback= "true" ></asp:checkbox>

						                                        </td>   						                                    
						                                        <td width="50%" align="center" colSpan="2">
						                                    	    <asp:checkbox  class="td_Texto" id="chkTodosContratos" runat="server" Text="Todos Contratos" Autopostback= "true"></asp:checkbox>

						                                        </td>
						                                    </tr>
    						                                 <div id="contenedorDatosConsultaMasiva" runat="server" enableviewstate="true" style="width:100%">
                                           
    						                                
						                                     <tr>
                                                                <td class="td_Texto" valign="middle" >
                                                                    <asp:Label ID="lblDatoSolicitadoFecha" runat="server" Text="Fecha Desde:"></asp:Label>
									                            </td>
                                                                <td  >                                                             
                                                                            <%-- Filtro por rango de fechas --%>
                                                                            <asp:TextBox ID="txtFechaInicial" BackColor="White"  runat="server" Width="70px" 
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
                                                                        <td class="td_Texto" align="center">
                                                                           <asp:Label ID="lblEntreFechas" runat="server" Text="    Fecha Hasta: " Visible="true" Width="100px"></asp:Label> 
                                                                        </td>
                                                                        <td >
                                                                            <asp:TextBox ID="txtFechaFinal" BackColor="White" runat="server" Width="70px" 
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
                                                                        <td>
                                                                        <asp:button id="btnGenerarConsultaMasiva" runat="server" Text="Generar Consulta"></asp:button>
                                                                        </td>
                                                                        
                                                                 </div>  
                                                      
	                                                    </tr>
						                             </table>
						      		     </td>
						      		 </tr>
						              						        
						           <tr>
							               <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Consulta Individual
							               </td>          						              							               
						      		 </tr>	
						       
						        <tr>
							        <td>
							        
							         <div id="contenedorConsultaIndividual" runat="server" enableviewstate="true" style="width:100%">
								        <table width="100%" align="center" border="0">
									      								      
							           							    									        
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
								        
								            </div>  
							        </td>
						        </tr>
						        <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Garantías Reales Relacionadas
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
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Garantias de Valor Relacionadas
							        </td>
						        <tr>
						            <td>   						              
                                            
                                           <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorGarantiaValor" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>
                                     
						            </td>
						        </tr>
						              <tr>
							        <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">Garantias Fiduciarias Relacionadas
							        </td>
						        </tr>
						        <tr>
						            <td>						                      
                                           <div style="overflow:auto; width: 100%; height: 100%">
                                            
                                             <div id="contenedorGarantiaFiduciaria" runat="server" enableviewstate="true" style="width:100%">
                                             </div>
                                             
                                           </div>
						            </td>
						        </tr>
						        
						        
						        <tr>
							        <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								        rowSpan="1"><asp:label id="lblListadoHistorico" runat="server">Detalle de los Cambios Respectivos</asp:label></td>
						        </tr>
						       
						        <tr>
							        <td align="center">
							        
							         <table  id="Table1" width="100%" align="center" border="0" runat="server">
                                                <tr>
                                                <td align="center" colSpan="4" style="height: 12px">
                                                <asp:label id="lblMensaje3" runat="server" CssClass="TextoError"></asp:label>
                                                </td>
                                                </tr>
                                                <tr>                                                                                                                                       
                                                 <td align="right">
                                                <asp:button id="btnLimpiar" runat="server" Text="Limpiar" tabIndex="8" Enable ="false"></asp:button>
                                                <asp:button id="btnGenerarConsulta" runat="server" Text="Generar Consulta" tabIndex="9" Enable ="false"></asp:button>
                                                </td>
                                                                        
                                                </tr>
                                      </table>
                                      
							            <asp:GridView ID="gdvCambioGarantia" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="USUARIO" PageSize="10" 
                                             OnPageIndexChanging="gdvCambioGarantia_PageIndexChanging" 
                                          
                                             CssClass="gridview" BorderColor="black" >
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                 <asp:ButtonField DataTextField="TIPO_GARANTIA" CommandName="SelectedValuacionesHistoricas" HeaderText="Tipo" > 
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                                        <HeaderStyle BorderColor="Black"/>
                                                    </asp:ButtonField>
                                                     <asp:ButtonField DataTextField="ACCION_REALIZADA" CommandName="SelectedValuacionesHistoricas" HeaderText="Accion Realizada" > 
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                                        <HeaderStyle BorderColor="Black"/>
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="CAMPO" CommandName="SelectedValuacionesHistoricas" HeaderText="Campo" > 
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                                        <HeaderStyle BorderColor="Black"/>
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="VALOR_PASADO" CommandName="SelectedValuacionesHistoricas" HeaderText="Valor Pasado" >
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="VALOR_ACTUAL" CommandName="SelectedValuacionesHistoricas" HeaderText="Valor Actual" >
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                    <asp:ButtonField DataTextField="FECHA_MODIFICACION" CommandName="SelectedValuacionesHistoricas" HeaderText="Fecha Modificación" DataTextFormatString="{0:d}">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:ButtonField>
                                                     <asp:BoundField  DataField="USUARIO" HeaderText="Usuario">
                                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                                        <HeaderStyle BorderColor="Black" />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="NOMBRE" HeaderText="Nombre" >
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
     <Triggers>
    <asp:PostBackTrigger ControlID="btnGenerarConsultaMasiva" />
    </Triggers>
          <Triggers>
    <asp:PostBackTrigger ControlID="btnGenerarConsulta" />
    </Triggers>
     
    </asp:UpdatePanel>
    <asp:HiddenField id="hdnBtnPostback" runat="server"></asp:HiddenField>
    <asp:HiddenField id="hdnFechaActual" runat="server"></asp:HiddenField>
</asp:Content>
