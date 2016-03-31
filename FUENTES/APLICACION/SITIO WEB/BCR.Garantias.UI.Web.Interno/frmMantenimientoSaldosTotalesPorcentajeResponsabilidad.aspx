<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master"  EnableEventValidation="false" AutoEventWireup="true" CodeFile="frmMantenimientoSaldosTotalesPorcentajeResponsabilidad.aspx.cs" Inherits="frmMantenimientoSaldosTotalesPorcentajeResponsabilidad" Title="BCR GARANTIAS - Mantenimiento Saldos Totales y Porcentaje Responsabilidad" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
        <div id="Contenedor_Principal" class="Contenedor">
            <div class="Contenedor_Separador"></div>
            <div class="Contenedor_Inicializar"></div>
            <div id="Contenedor_Titulo" class="Contenedor_Titulo">
                <center>
                    <span class="Titulo_Nivel_1">Mantenimiento de Saldos Totales y Porcentaje de Responsabilidad</span> 
				</center>
            </div>
            <div class="Contenedor_Inicializar"></div>
            <div id="Tabla_Principal" class="Contenedor_Tabla">
                <div class="Contenedor_Fila">
                    <div class="Contenedor_Columna_Titulo">
                            <span class="Titulo_Nivel_2">Información de la Búsqueda</span> 
                    </div>
                </div>
                <div class="Contenedor_Fila">
                     <div class="Contenedor_Columna">
                        <div class="Contenedor_Distribuido" style="text-align:center;"> 
                            <asp:label id="lblMensaje" runat="server" CssClass="Texto_Error"></asp:label> 
                        </div>
                        <div class="Contenedor_Separador"></div>
                        <div class="Contenedor_Distribuido">
                             <div class="Contenedor_Agrupado">
                                <span class="Etiqueta">Tipo de Búsqueda:</span>
                                <asp:dropdownlist id="cbTipoBusqueda" CssClass="Campo_Normal" tabIndex="1" runat="server" onchange="javascript:HabilitarCamposBusqueda();" BackColor="AntiqueWhite" Width="194px">
							        <asp:ListItem Value="1">Operaci&#243;n</asp:ListItem>
									<asp:ListItem Value="2">Contrato</asp:ListItem>
                                    <asp:ListItem Value="3">Garant&#237;a</asp:ListItem>
						        </asp:dropdownlist>
                            </div>
                            <div id="filaRetorno" class="Contenedor_Agrupado" style="display:none;">
                                <a id="lknRetornar" class="enlaceRetorno" runat="server" href="#">Retornar al Mantenimiento de Garantías</a>
                            </div>
                        </div>
                        <div class="Contenedor_Separador"></div>
                        <div id="filaBusquedaOperacion" class="Contenedor_Distribuido" style="padding-left:33px; margin-bottom:5px;" runat="server">
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Contabilidad:</span>
                                <asp:textbox id="txtContabilidad" CssClass="Campo_Agrupado_Llave " tabIndex="2" runat="server" Width="23px" MaxLength="2">1</asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Oficina:</span>
                                <asp:textbox id="txtOficina" CssClass="Campo_Agrupado_Llave " tabIndex="3" runat="server" Width="32px" MaxLength="3"></asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Moneda:</span>
                                <asp:textbox id="txtMoneda" CssClass="Campo_Agrupado_Llave " tabIndex="4" runat="server" Width="21px" MaxLength="2"></asp:textbox>
                            </div>
                            <div id="columnaProducto" runat="server" class="Contenedor_Agrupado">
                                <asp:label id="lblProducto" CssClass="Etiqueta_Agrupada" runat="server">Producto:</asp:label>
                                <asp:textbox id="txtProducto" CssClass="Campo_Agrupado_Llave " tabIndex="5" runat="server" Width="21px" MaxLength="2"></asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado">
                                <asp:label id="lblTipoOperacion" CssClass="Etiqueta_Agrupada" runat="server">Operación:</asp:label>
                                <asp:textbox id="txtOperacion" CssClass="Campo_Agrupado_Llave " tabIndex="6" runat="server" BackColor="AntiqueWhite" Width="64px" MaxLength="7"></asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado" >
                                <asp:button id="btnValidarOperacion" tabIndex="7" runat="server" ToolTip="Verifica que la operación sea valida" Text="Validar" UseSubmitBehavior="false" OnClientClick="return ValidarOperacion();"></asp:button>
                            </div>
                        </div>
                        <div id="filaBusquedaGarantia" class="Contenedor_Distribuido" style="display:none;  margin-bottom:5px;" runat="server">
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta">Tipo de Garantía:</span>
                                <asp:dropdownlist id="cbTipoGarantia" CssClass="Campo_Normal ComboTipoGarantiaLlave" onchange="javascript:HabilitarCamposBusquedaGarantia();" tabIndex="8" runat="server" BackColor="AntiqueWhite" Width="194px">							        
						        </asp:dropdownlist>
                                <div id="filaTipoGarantiaReal" style="margin-top:10px;">
                                    <span class="Etiqueta">Tipo de Garantía Real:</span>                                 
                                    <asp:dropdownlist id="cbTipoGarantiaReal" CssClass="Campo_Normal" onchange="javascript:HabilitarCamposBusquedaGarantiaReal();" tabIndex="9" runat="server" BackColor="AntiqueWhite" Width="194px">							        
						            </asp:dropdownlist>                                    
                                </div>
                                <div id="filaClaseGarantiaReal" style="margin-top:10px;">
                                    <span class="Etiqueta_Agrupada">Clase de Garantía:</span>
                                    <asp:dropdownlist id="cbClaseGarantiaReal" CssClass="Campo_Normal" tabIndex="13" runat="server" Width="215px"></asp:dropdownlist>                                
                                </div>
                            </div>                           
                        </div>
                         <div style="margin-top:10px;"></div>                                
                        <div id="filaBusquedaGarantiaFiduciaria" class="Contenedor_Distribuido" style="margin-bottom:5px; display:none;" runat="server">
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Tipo de Persona:</span>
                                <asp:dropdownlist id="cbTipoPersona" CssClass="Campo_Normal ComboTipoPersonaLlave" tabIndex="10" runat="server" BackColor="AntiqueWhite" Width="198px"></asp:dropdownlist>
                            </div>
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Cédula Fiador:</span>
                                <asp:textbox id="txtCedulaFiador" CssClass="Campo_Normal" tabIndex="11" runat="server" BackColor="AntiqueWhite" Width="96px" MaxLength="25"></asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado" >
                                <asp:button id="btnValidarGarantiaFiduciaria" tabIndex="12" runat="server" ToolTip="Verifica que la garantía fiduciaria sea valida" Text="Validar" UseSubmitBehavior="false" OnClientClick="return ValidarGarantia();"></asp:button>
                            </div>
                        </div>
                        <div id="filaBusquedaGarantiaReal" class="Contenedor_Distribuido" style="padding-left:33px; margin-bottom:5px; display:none;" runat="server">                                               
                            <div class="Contenedor_Distribuido" style="text-align:center;"> 
                                <div class="Contenedor_Agrupado">
                                    <asp:label id="lblPartido" CssClass="Etiqueta_ID_Garantia" runat="server">Partido:</asp:label>
                                    <asp:textbox id="txtPartido" CssClass="Campo_Normal" tabIndex="14" runat="server" Width="42px" MaxLength="3"></asp:textbox>
                                    <asp:label id="lblFinca" CssClass="Etiqueta_ID_Garantia" runat="server">Id Garantía:</asp:label>
                                    <asp:textbox id="txtNumFinca" CssClass="Campo_Normal" tabIndex="15" runat="server" Width="150px" MaxLength="25"></asp:textbox>
                                    <div id="filaGradoCedula" style="display:none;">
                                        <asp:label id="lblGrado" CssClass="Etiqueta_ID_Garantia" runat="server">Grado:</asp:label>
                                        <asp:textbox id="txtGrado" CssClass="Campo_Normal" tabIndex="16" runat="server" Width="42px" MaxLength="2"></asp:textbox>
                                        <%--<asp:label id="lblCedula"  CssClass="Etiqueta_ID_Garantia" runat="server">Cédula Hipotecaria:</asp:label>
                                        <asp:textbox id="txtCedulaHipotecaria" CssClass="Campo_Normal " tabIndex="17" runat="server" Width="42px" MaxLength="2"></asp:textbox>--%>
                                    </div>     
                                    <asp:button id="btnValidarGarantiaReal" tabIndex="18" runat="server" ToolTip="Verifica que la garantía real sea valida" Text="Validar" UseSubmitBehavior="false" OnClientClick="return ValidarGarantia();"></asp:button>
                                </div>
                            </div>
                        </div>
                        <div id="filaBusquedaGarantiaValor" class="Contenedor_Distribuido" style="margin-bottom:5px; display:none;" runat="server">
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Clase de Garantía:</span>
                                <asp:dropdownlist id="cbClaseGarantiaValor" CssClass="Campo_Normal" tabIndex="19" runat="server"  BackColor="AntiqueWhite" Width="215px"></asp:dropdownlist>
                            </div>
                            <div class="Contenedor_Agrupado">
                                <span class="Etiqueta_Agrupada">Número de Seguridad:</span>
                                <asp:textbox id="txtNumeroSeguridad" tabIndex="20" runat="server" BackColor="AntiqueWhite" Width="96px" MaxLength="25"></asp:textbox>
                            </div>
                            <div class="Contenedor_Agrupado" >
                                <asp:button id="btnValidarGarantiaValor" tabIndex="21" runat="server" ToolTip="Verifica que la garantía valor sea valida" Text="Validar" UseSubmitBehavior="false" OnClientClick="return ValidarGarantia();"></asp:button>
                            </div>
                        </div>
                    </div>       
                </div>      
                <div class="Contenedor_Fila">
                    <div class="Contenedor_Columna_Titulo">
                            <span class="Titulo_Nivel_2">Relaciones</span> 
                    </div>
                </div>
               <div id="filaRelaciones" runat="server">
                    <div class="Contenedor_Inicializar"></div>
                    <div class="Contenedor_Fila">
                        <div class="Contenedor_Columna" style="min-height:40px;">
                            <div id="accordionGF" style="width:815px; padding:.5em .3em 0em .3em; font-size:12px;">
                                <h3 style="margin-bottom:0px;">Garantías Fiduciarias Relacionadas</h3>
                                <div style="text-align:left; padding-left:0em; height:300px; width:787px;">  
                                    <br />
                                    <div id="tablaGarantiasFiduciarias">

                                    </div>
                                    <br />
                                 </div>
                            </div>
                             <div id="accordionGR" style="width:815px; padding:.5em .3em 0em .3em; font-size:12px;">
                                <h3 style="margin-bottom:0px;">Garantías Reales Relacionadas</h3>
                                <div style="text-align:left; padding-left:0em; height:300px; width:787px;">                            
                                    <br />
                                    <div id="tablaGarantiasReales"></div>
                                    <br />
                                </div>
                            </div>
                            <div id="accordionGV" style="width:815px; padding:.5em .3em 1em .3em; font-size:12px;">
                                <h3 style="margin-bottom:0px;">Garantías Valor Relacionadas</h3>
                                <div style="text-align:left; padding-left:0em; height:300px; width:787px;">                            
                                    <br />
                                    <div id="tablaGarantiasValor">

                                    </div>
                                    <br />
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="Contenedor_Inicializar"></div>
                <div class="Contenedor_Fila">
                    <div class="Contenedor_Columna_Titulo">
                            <span class="Titulo_Nivel_2">Distribución</span> 
                    </div>
                </div>
                <div class="Contenedor_Fila">
                    <div class="Contenedor_Columna_Centrada" style="min-height:40px;">
                        <br />
						    <asp:GridView ID="gdvOperaciones" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="ConsecutivoOperacion, ConsecutivoGarantia, CodigoTipoGarantia"                                  
                                CssClass="gridview" BorderColor="black" >
                                                 
                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                <Columns>
                                    <asp:ButtonField DataTextField="OperacionLarga" CommandName="SelectedOperacion" HeaderText="Operaciones o Contratos Relacionados">
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="500px" />
                                        <HeaderStyle BorderColor="Black" />
                                    </asp:ButtonField>
                                    <asp:ButtonField DataTextField="SaldoActual" HeaderText="Saldo" DataTextFormatString="{0:N2}" >
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                        <HeaderStyle BorderColor="Black" />
                                    </asp:ButtonField>
                                    <asp:ButtonField DataTextField="PorcentajeResponsabilidadCalculado" HeaderText="% Responsabilidad Calculado" DataTextFormatString="{0:N2}" >
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                        <HeaderStyle BorderColor="Black" />
                                    </asp:ButtonField>
                                    <asp:ButtonField DataTextField="CuentaContable" HeaderText="Cta. Contable">
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                        <HeaderStyle BorderColor="Black" />
                                    </asp:ButtonField>
                                    <asp:ButtonField DataTextField="TipoOperacion" HeaderText="Tipo Operación">
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                        <HeaderStyle BorderColor="Black" />
                                    </asp:ButtonField>
                                    <asp:TemplateField HeaderText="Excluido">
                                        <ItemStyle BorderColor="Black" HorizontalAlign="Center" Width="100px" />
                                        <HeaderStyle BorderColor="Black" />
                                        <ItemTemplate>
                                            <input type="checkbox" disabled="disabled"/>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="CodigoTipoOperacion" Visible="False"/>
                                    <asp:BoundField DataField="ConsecutivoOperacion" Visible="False"/>
                                    <asp:BoundField DataField="ConsecutivoGarantia" Visible="False"/>
                                    <asp:BoundField DataField="CodigoTipoGarantia" Visible="False"/>
                                    <asp:BoundField DataField="IndicadorExcluido" Visible="False"/>
                                </Columns>
                                <RowStyle BackColor="#EFF3FB" />
                                <EditRowStyle BackColor="#2461BF" />
                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="White" />
    					    </asp:GridView>
					    <br />
                    </div>
                </div>
                <div id="filaAjustes" runat="server">
                <div class="Contenedor_Fila">
                    <div class="Contenedor_Columna_Titulo">
                            <span class="Titulo_Nivel_2">Ajustes</span> 
                    </div>
                </div>
                    <div runat="server" class="Contenedor_Fila">
                        <div class="Contenedor_Columna_Centrada" style="padding-bottom:5px; min-height:40px;">
                            <div id="filaDetalleAjuste" class="Contenedor_Distribuido" style="width:815px; margin-left:6px;"> 
                                <div style="float:left; height: 150px; vertical-align:middle;">
                                    <button id="Anterior" type="button" tabindex="22" style="height:100%; text-decoration:solid; font-weight:bolder; width:20px;" onclick="RegistroAnterior()"><</button>
                                </div>
                                <div style="float:left; height:150px; width:775px; text-align:center;">
                                    <div style="height:150px; width:500px; display:inline-block;">
                                        <div class="Contenedor_Separador"></div>
                                        <div class="Contenedor_Distribuido" style="text-align:left; padding-left:0px; margin-left:27px;"> 
                                            <div class="Contenedor_Agrupado">
                                                <span class="Etiqueta_Agrupada">Número Operación o Contrato:</span>
                                            </div>
                                            <div class="Contenedor_Agrupado_Derecho" style="text-align:left; float:left; margin-left:1px;">                                  
                                               <asp:Label ID="lblNumeroOperacion" CssClass="Texto" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="Contenedor_Separador"></div>
                                        <div class="Contenedor_Distribuido" style="text-align:left; padding-left:0px; margin-left:27px;"> 
                                            <div class="Contenedor_Agrupado">
                                                <span class="Etiqueta_Agrupada">Saldo Ajustado:</span>   
                                            </div>
                                            <div class="Contenedor_Agrupado_Derecho" style="text-align:left; float:left; margin-left:45px;">                                  
                                                <asp:TextBox ID="txtSaldoAjustado" CssClass="Campo_Numerico" tabIndex="23" runat="server" MaxLength="17" ValidationGroup="MKE" ToolTip="Saldo Ajustado. Utilice el punto como separador de decimales." Width="136px" />
                                            </div>
                                        </div>
                                        <div class="Contenedor_Separador"></div>
                                        <div class="Contenedor_Distribuido" style="text-align:left; padding-left:0px; margin-left:27px;"> 
                                            <div class="Contenedor_Agrupado">
                                                <span class="Etiqueta_Agrupada">% Responsabilidad Ajustado:</span>      
                                            </div>
                                            <div class="Contenedor_Agrupado_Derecho" style="text-align:left; float:left; margin-left:7px;">                                  
                                               <asp:TextBox ID="txtPorcentajeResponsabilidad" tabIndex="24" runat="server" CssClass="Campo_Numerico" MaxLength="6" ValidationGroup="MKE" ToolTip="Porcentaje de Responsabilidad Ajustado" Width="72px" />
                                            </div>
                                        </div>
                                        <div class="Contenedor_Separador"></div>
                                        <div class="Contenedor_Distribuido" style="text-align:left; padding-left:0px; margin-left:27px;"> 
                                            <div class="Contenedor_Agrupado_Derecho">
                                                <asp:button id="btnLimpiar" tabIndex="25" runat="server" ToolTip="Limpiar" Text="Limpiar" UseSubmitBehavior="false" OnClientClick="return LimpiarCampos();"></asp:button>
								                <asp:button id="btnInsertar" tabIndex="26" runat="server" ToolTip="Incluir Registro" Text="Incluir" UseSubmitBehavior="false" OnClientClick="return ConfirmarInsertar();"></asp:button>
								                <asp:button id="btnModificar" tabIndex="27" runat="server" ToolTip="Modificar Registro" Text="Modificar" UseSubmitBehavior="false" OnClientClick="return ConfirmarModificar();"></asp:button>
								                <asp:button id="btnEliminar" tabIndex="28" runat="server" ToolTip="Eliminar Registro" Text="Eliminar" UseSubmitBehavior="false" OnClientClick="return ConfirmarEliminar();"></asp:button>
                                            </div>    
                                        </div>                                                   
                                    </div>
                                </div>
                                <div style="float:left; height:150px;">
                                    <button id="Siguiente" type="button" tabindex="28" style="height:100%; text-decoration:solid; font-weight:bolder; width:20px;" onclick="RegistroSiguiente()">></button>
                                </div>
                            </div>                       
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="Contenedor_Separador"></div>
        <div class="Contenedor_Pie_Pagina">
            <span>Banco de Costa Rica © Derechos reservados 2006.</span>
        </div>
        <div class="Contenedor_Separador"></div>
        <div class="Contenedor_Separador"></div>
    </div>

    <asp:HiddenField ID="hdnIndiceAccordionGFActivo" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnHabilitarGF" runat="server" Value="0"></asp:HiddenField>
    <asp:HiddenField ID="hdnIndiceAccordionGRActivo" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnHabilitarGR" runat="server" Value="0"></asp:HiddenField>
    <asp:HiddenField ID="hdnIndiceAccordionGVActivo" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnHabilitarGV" runat="server" Value="0"></asp:HiddenField>

    <asp:HiddenField ID="hdnCatalogoGarantias" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnCatalogoTiposPersona" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnCatalogoTiposGarantiaReal" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnCatalogoClasesGarantia" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnPerfilesPermitidos" runat="server" Value="-1"></asp:HiddenField>
    <asp:HiddenField ID="hdnPermisoEdicion" runat="server"></asp:HiddenField>
    
 </asp:Content>

