<%--<%@ Page Title="" Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmMantenimientoPorcentajeAceptacion.aspx.cs" Inherits="frmMantenimientoPorcentajeAceptacion" %>
--%>
<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmMantenimientoPorcentajeAceptacion.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmMantenimientoPorcentajeAceptacion" Title="BCR GARANTIAS - Catálogos" %>


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
					<td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Catálogos</asp:label></td>
				</tr>
				<tr>
					<td vAlign="top" colSpan="3">
						<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
							<tr>
								<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
									GARANTIAS&nbsp;- Catálogos</td>
							</tr>
							<tr>
								<td>
									<table width="100%" align="center" border="0">
										<tr>
											<td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
										</tr>
										<tr>
											<td class="td_Texto" style="WIDTH: 200px" width="200"></td>
											<td width="450px"></td>
                                   
										</tr>
										<tr>
											<td class="td_Texto" style="WIDTH: 200px">Tipo de Garantía:</td>
											<td> <asp:DropDownList id="cboTipoGarantia" tabIndex="1" runat="server" Width="225px" BackColor="AliceBlue"></asp:DropDownList>
                                               
                                            </td>	
                                         </tr>
										
                                         <tr>								
											<td class="td_Texto" style="WIDTH: 200px">Tipo de Mitigador:</td>
											<td><asp:DropDownList id="cboTipoMitigador" tabIndex="2" runat="server" Width="493px" BackColor="AliceBlue"></asp:DropDownList></td>
										</tr>
                                        	<tr>
											<td class="td_Texto" colSpan="2">&nbsp;</td>
										</tr>
                                        <tr>
								            <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1"  aling="center">
								        	<asp:Label id="Label1" runat="server" TexT = "% Aceptación Según Calificación de Riesgo" aling="center"></asp:Label></td>
							             </tr>
                                         	<tr>
											<td class="td_Texto" colSpan="2">&nbsp;</td>
										</tr>

                                        <tr>
                                         <td colspan= "2">
                                                 <table style= "text-align:center">
                                                        
                                                        <tr>
                                                             <td class="td_Texto" style="WIDTH: 200px" width="200"></td>                                   
                                                             <td class="td_Texto" style="WIDTH: 50px;text-align:center">%</td>
                                                             <td class="td_Texto" style="WIDTH: 50px;text-align:center">0 a 3</td>
                                                            <td class="td_Texto" style="WIDTH: 50px;text-align:center">4</td>
                                                            <td class="td_Texto" style="WIDTH: 50px;text-align:center">5</td>
                                                            <td class="td_Texto" style="WIDTH: 50px;text-align:center">6</td>
                                                            <td class="td_Texto" style="WIDTH: 125px;text-align:right">Fecha de Cambio</td>
                                                        </tr>
                                                         <tr>
                                                                 <td> 
                                                                 <asp:RadioButtonList ID="rdbListaClasificacion" runat="server">
                                                                     <asp:ListItem ID="rdbSinCalificacion" tabIndex="3" runat="server">Sin Calificación</asp:ListItem>
                                                                     <asp:ListItem ID="rdbNoCalificacion" tabIndex="4" runat="server">N/A Calificación</asp:ListItem>
                                                                 </asp:RadioButtonList>
                                                                </td>

                                                                 <td><asp:textbox id="txtPorcentajeAceptacion" tabIndex="5" runat="server" CssClass="Txt_Style_Default" Width="63px"
													                BackColor="AliceBlue" MaxLength="5" ></asp:textbox></td>
                                                
                                                                <td><asp:textbox id="txtPorcentajeCeroTres"  runat="server" CssClass="Txt_Style_Default" Width="63px"
													                BackColor="AliceBlue" MaxLength="5"  Enabled="false"></asp:textbox></td>

                                                                <td><asp:textbox id="txtPorcentajeCuatro" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="63px"
												                BackColor="AliceBlue" MaxLength="5"  Enabled="false"></asp:textbox></td>

                                                                   <td><asp:textbox id="txtPorcentajeCinco" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="63px"
													                BackColor="AliceBlue" MaxLength="5"  Enabled="false"></asp:textbox></td>

                                                                    <td><asp:textbox id="txtPorcentajeSeis" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="63px"
													                BackColor="AliceBlue" MaxLength="5"  Enabled="false"></asp:textbox></td>

                                                                    <td><asp:textbox id="txtFechaCambio" tabIndex="3" runat="server" CssClass="Txt_Style_Default" Width="80px"
													                BackColor="AliceBlue" MaxLength="5" Enabled="false"></asp:textbox></td>

                                                        </tr>
                                                 </table>
                                         </td>
                                        
                                        </tr>                           
										

										<tr>
											<td class="td_Texto" style="WIDTH: 200px"></td>
											<td>
												<asp:Label id="lblElemento" runat="server" Visible="False"></asp:Label></td>
										</tr>
										<tr>
											<td class="td_Texto" colSpan="2">&nbsp;</td>
										</tr>
										<tr>
											<td class="td_Texto" colSpan="2">
												<asp:Button id="Button2" runat="server" BackColor="White" BorderStyle="None" BorderColor="White"></asp:Button>
												<asp:Button id="btnRegresar"  runat="server" Text="Regresar" tabIndex="6"></asp:Button>
                                                <asp:button id="btnLimpiar" runat="server" ToolTip="Limpiar" Text="Limpiar" tabIndex="7"></asp:button>
                                                <asp:button id="btnInsertar" runat="server" ToolTip="Insertar Campo" Text="Insertar" tabIndex="8"></asp:button>
                                                <asp:button id="btnModificar" runat="server" ToolTip="Modificar Campo" Text="Modificar" tabIndex="9">
                                                </asp:button><asp:button id="btnEliminar" runat="server" ToolTip="Eliminar Campo" Text="Eliminar" tabIndex="10"></asp:button></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
									<asp:Label id="lblCatalogo" runat="server"></asp:Label></td>
							</tr>
							<tr>
								<td align="center">
								    <br/>
								    <asp:GridView ID="gdvCatalogos" runat="server" CellPadding="4" 
                                        ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                         AutoGenerateColumns="False" DataKeyNames="Codigo_Porcentaje_Aceptacion,Codigo_Tipo_Garantia,Codigo_Tipo_Mitigador,Indicador_Sin_Calificacion,
                                         Porcentaje_Aceptacion,Porcentaje_Cero_Tres,Porcentaje_Cuatro,Porcentaje_Cinco,Porcentaje_Seis,Fecha_Modifico,Indicador_NA_Calificacion"
                                           OnRowCommand="gdvCatalogos_RowCommand" EmptyDataText="No existen registros"
                                         OnPageIndexChanging="gdvCatalogos_PageIndexChanging" CssClass="gridview" BorderColor="black">
                                            <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                            <Columns>
                                                <asp:ButtonField DataTextField="Codigo_Tipo_Garantia" CommandName="SelectedCatalogo" HeaderText="Tipo Garantía" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Codigo_Tipo_Mitigador" CommandName="SelectedCatalogo" HeaderText="Tipo Mitigador" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Indicador_NA_Calificacion" CommandName="SelectedCatalogo" HeaderText="N/A Calificación" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Indicador_Sin_Calificacion" CommandName="SelectedCatalogo" HeaderText="Sin Calificación" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Porcentaje_Aceptacion" CommandName="SelectedCatalogo" HeaderText="%" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Porcentaje_Cero_Tres" CommandName="SelectedCatalogo" HeaderText="0 a 3" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Porcentaje_Cuatro" CommandName="SelectedCatalogo" HeaderText="4" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Porcentaje_Cinco" CommandName="SelectedCatalogo" HeaderText="5" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                <asp:ButtonField DataTextField="Porcentaje_Seis" CommandName="SelectedCatalogo" HeaderText="6" Visible="True" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                
                                                <asp:BoundField DataField="Codigo_Porcentaje_Aceptacion" Visible="false"/>
                                                <asp:BoundField DataField="Fecha_Modifico" Visible="false"/>
                                           </Columns>
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

    <asp:HiddenField ID="hdnAplicaCalculoPA" runat="server" Value="0"></asp:HiddenField>
    
</asp:Content>

