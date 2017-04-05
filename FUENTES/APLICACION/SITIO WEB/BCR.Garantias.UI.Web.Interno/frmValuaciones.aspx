<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmValuaciones.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmValuaciones" Title="BCR GARANTIAS - Valuaciones" %>

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
				    <td style="HEIGHT: 43px" align="center" colSpan="3"><asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Histórico de Ingresos</asp:label></td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" style="HEIGHT: 20px" width="100%" bgColor="#dcdcdc" colSpan="4"
								    rowSpan="1">BCR GARANTIAS - Fiadores&nbsp;- Ingresos</td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" width="40%" colSpan="2"><asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">
											    <table id="table2" width="100%" align="center" border="0">
												    <tr>
													    <td class="td_Texto" width="35%">Cédula del Fiador:</td>
													    <td class="td_TextoIzq" width="65%"><asp:textbox id="txtCedula" tabIndex="1" runat="server" CssClass="Txt_Style_Default" font-size="100%" Enabled="False"
															    BackColor="AntiqueWhite" Width="128px" MaxLength="80" ToolTip="Cédula del Fiador"></asp:textbox></td>
												    </tr>
												    <tr>
													    <td class="td_Texto">Nombre del Fiador:</td>
													    <td class="td_TextoIzq"><asp:textbox id="txtNombre" tabIndex="2" runat="server" CssClass="Txt_Style_Default" font-size="100%" Enabled="False"
															    BackColor="AntiqueWhite" Width="343px" MaxLength="50" ToolTip="Nombre del Fiador"></asp:textbox></td>
												    </tr>
												    <tr>
													    <td class="td_Texto">Fecha de Verificación Asalariado:</td>
													    <td class="td_TextoIzq">
													        <asp:TextBox ID="txtFechaActualizacion" BackColor="AliceBlue" tabIndex="3" runat="server" Width="80px" 
										                         MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Verificación Asalariado" />
                                                            <asp:ImageButton ID="igbCalendarioActualizacion" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                            <ajaxToolkit:MaskedEditExtender ID="meeFechaActualizacion" runat="server"
                                                                TargetControlID="txtFechaActualizacion"
                                                                Mask="99/99/9999"
                                                                MessageValidatorTip="true"
                                                                OnFocusCssClass="MaskedEditFocus"
                                                                OnInvalidCssClass="MaskedEditError"
                                                                MaskType="Date"
                                                                DisplayMoney="Left"
                                                                AcceptNegative="Left"
                                                                ErrorTooltipEnabled="True" />
                                                            <ajaxToolkit:MaskedEditValidator ID="mevFechaActualizacion" runat="server"
                                                                ControlExtender="meeFechaActualizacion"
                                                                ControlToValidate="txtFechaActualizacion"
                                                                EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                                InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                                Display="Dynamic"
                                                                TooltipMessage="Ingrese una fecha: día/mes/año"
                                                                EmptyValueBlurredText="*"
                                                                InvalidValueBlurredMessage="*"
                                                                ValidationGroup="MKE" />
                                                                 
                                                            <ajaxToolkit:CalendarExtender ID="cleFechaActualizacion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaActualizacion" PopupButtonID="igbCalendarioActualizacion" />
													    </td>
												    </tr>
												    <tr>
													    <td class="td_Texto">Salario&nbsp;Neto del Fiador:</td>
													    <td class="td_TextoIzq">
													        <asp:TextBox ID="txtSalario" tabIndex="4" runat="server" MaxLength="17" ValidationGroup="MKE" CssClass="id-tabla-texto"  
										                     ToolTip="Ingreso Neto" BackColor="AliceBlue" Width="100px" />
														</td>
												    </tr>
												    <tr>
													    <td></td>
													    <td class="td_TextoLeyenda"><asp:label id="lblLeyenda" runat="server" ForeColor="DimGray">(Utilice el punto como separador de decimales)</asp:label></td>
												    </tr>
												    <tr>
													    <td class="td_Texto">Tiene Capacidad de Pago:</td>
													    <td class="td_TextoIzq"><asp:dropdownlist id="cbCapacidad" tabIndex="5" runat="server" BackColor="AliceBlue" Width="72px" Enabled="false"></asp:dropdownlist></td>
												    </tr>
											    </table>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">
										            <asp:button id="Button2" runat="server" BackColor="White" BorderColor="White" BorderStyle="None"></asp:button>
										            <asp:button id="btnRegresar" tabIndex="6" runat="server" ToolTip="Regresa al formulario anterior" Text="Regresar"></asp:button>
												    <asp:button id="btnLimpiar" tabIndex="7" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button>
                                                    <asp:button id="btnInsertar" tabIndex="8" runat="server" ToolTip="Insertar Valuación" Text="Insertar"></asp:button>
												    <asp:button id="btnEliminar" tabIndex="9" runat="server" ToolTip="Eliminar Valuación" Text="Eliminar"></asp:button>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1"><asp:label id="lblCatalogo" runat="server"></asp:label></td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
								        <asp:GridView ID="gdvValuacionesFiador" runat="server" CellPadding="4" ForeColor="#333333" GridLines="Both" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="fecha_valuacion,ingreso_neto" 
                                             OnRowCommand="gdvValuacionesFiador_RowCommand" 
                                             OnPageIndexChanging="gdvValuacionesFiador_PageIndexChanging" CssClass="gridview" BorderColor="black" >
                                                 <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <%--<asp:BoundField DataField="cod_tiene_capacidad_pago" Visible="False"/>--%>
                                                    <asp:ButtonField DataTextField="fecha_valuacion" CommandName="SelectedValuacionFiador" HeaderText="Fecha" Visible="True" ItemStyle-Width="365px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                    <asp:ButtonField DataTextField="ingreso_neto" CommandName="SelectedValuacionFiador" HeaderText="Ingreso Neto" Visible="True" ItemStyle-Width="365px" ItemStyle-HorizontalAlign="Center" DataTextFormatString="{0:N2}" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>
                                                   <%-- <asp:ButtonField DataTextField="tiene_capacidad_pago" CommandName="SelectedValuacionFiador" HeaderText="Tiene Capacidad de Pago" Visible="True" ItemStyle-Width="300px" ItemStyle-HorizontalAlign="Center" ItemStyle-BorderColor="black" HeaderStyle-BorderColor="black"/>--%>
                                                </Columns>
                                                <RowStyle BackColor="#EFF3FB" ForeColor="black" />
                                                <EditRowStyle BackColor="#2461BF" />
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" HorizontalAlign="Center" />
                                                <AlternatingRowStyle BackColor="White" />
					                    </asp:GridView>  
								    <br/>
							    </td>
						    </tr>
					    </table>
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

