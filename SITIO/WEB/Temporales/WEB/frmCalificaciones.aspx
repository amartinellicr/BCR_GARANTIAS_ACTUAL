<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmCalificaciones.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmCalificaciones" Title="BCR GARANTIAS - Calificaciones"%>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
        <div>
            <table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window" border="0" cellSpacing="1">
			    <tr>
				    <td style="HEIGHT: 43px" align="center" colSpan="3">
				        <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Mantenimiento de Calificaciones</asp:label>
				    </td>
			    </tr>
			    <tr>
				    <td vAlign="top" colSpan="3">
					    <table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								    GARANTIAS&nbsp;- Calificaciones
							    </td>
						    </tr>
						    <tr>
							    <td>
								    <table width="100%" align="center" border="0">
									    <tr>
										    <td align="center" width="40%" colSpan="2">
										        <asp:label id="lblMensaje" runat="server" CssClass="TextoError"></asp:label>&nbsp;
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto"></td>
										    <td width="70%"></td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Cédula del Deudor:</td>
										    <td>
										        <asp:textbox id="txtCedula" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												    Width="128px" ToolTip="Cédula del Deudor" MaxLength="80" Enabled="False"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Nombre del Deudor:</td>
										    <td>
										        <asp:textbox id="txtNombre" tabIndex="1" runat="server" CssClass="Txt_Style_Default" BackColor="AliceBlue"
												    Width="343px" ToolTip="Nombre del Deudor" MaxLength="50" Enabled="False"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Fecha de Calificación:</td>
										    <td>
										        <asp:TextBox ID="txtFechaCalificacion" tabIndex="2" runat="server" Width="130px" MaxLength="1" style="text-align:justify" ValidationGroup="MKE" ToolTip="Fecha de Calificación" />
                                                <asp:ImageButton ID="igbCalendario" runat="server" ImageUrl="~/Images/Calendario.png" CausesValidation="False" />
                                                <ajaxToolkit:MaskedEditExtender ID="meeFechaCalificacion" runat="server"
                                                    TargetControlID="txtFechaCalificacion"
                                                    Mask="99/99/9999"
                                                    MessageValidatorTip="true"
                                                    OnFocusCssClass="MaskedEditFocus"
                                                    OnInvalidCssClass="MaskedEditError"
                                                    MaskType="Date"
                                                    DisplayMoney="Left"
                                                    AcceptNegative="Left"
                                                    ErrorTooltipEnabled="True" />
                                                <ajaxToolkit:MaskedEditValidator ID="mkvFechaCalificacion" runat="server"
                                                    ControlExtender="meeFechaCalificacion"
                                                    ControlToValidate="txtFechaCalificacion"
                                                    EmptyValueMessage="Se requiere una fecha, debe ser día/mes/año"
                                                    InvalidValueMessage="La fecha es invalida, debe ser día/mes/año"
                                                    Display="Dynamic"
                                                    TooltipMessage="Ingrese una fecha: día/mes/año"
                                                    EmptyValueBlurredText="*"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="MKE" />
                                                     
                                                 <ajaxToolkit:CalendarExtender ID="cleFechaCalificacion" Format="dd/MM/yyyy" CssClass="calendario" runat="server" TargetControlID="txtFechaCalificacion" PopupButtonID="igbCalendario" />
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Tipo de Asignación:</td>
										    <td>
										        <asp:dropdownlist id="cbTipoAsignacion" tabIndex="3" runat="server" Width="451px"></asp:dropdownlist>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Categoría de Calificación:</td>
										    <td>
										        <asp:textbox id="txtCategoria" tabIndex="4" runat="server" Width="36px" ToolTip="Categoría de Calificación"
												    MaxLength="3"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto">Calificación de Riesgo:</td>
										    <td>
										        <asp:textbox id="txtCalificacion" tabIndex="5" runat="server" Width="277px" ToolTip="Calificación de Riesgo"
												    MaxLength="30"></asp:textbox>
										    </td>
									    </tr>
									    <tr>
										    <td class="td_Texto"></td>
										    <td></td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">&nbsp;</td>
									    </tr>
									    <tr>
										    <td class="td_Texto" colSpan="2">
											    <asp:Button id="btnRegresar" runat="server" ToolTip="Regresar al formulario anterior" Text="Regresar"></asp:Button><asp:button id="btnLimpiar" tabIndex="6" runat="server" ToolTip="Limpiar" Text="Limpiar"></asp:button><asp:button id="btnInsertar" tabIndex="7" runat="server" ToolTip="Insertar Calificación" Text="Insertar"></asp:button><asp:button id="btnModificar" tabIndex="8" runat="server" ToolTip="Modificar Calificación" Text="Modificar"></asp:button><asp:button id="btnEliminar" tabIndex="9" runat="server" ToolTip="Eliminar Calificación" Text="Eliminar"></asp:button>
										    </td>
									    </tr>
								    </table>
							    </td>
						    </tr>
						    <tr>
							    <td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">
							        <asp:label id="lblCatalogo" runat="server"></asp:label>
							    </td>
						    </tr>
						    <tr>
							    <td align="center">
							        <br/>
								        <asp:GridView ID="gdvCalificaciones" runat="server" CellPadding="4" ForeColor="#333333" GridLines="None" Width="730px" AllowPaging="True" AllowSorting="True"
                                             AutoGenerateColumns="False" DataKeyNames="cedula_deudor,nombre_deudor,cod_tipo_asignacion,fecha_calificacion,des_tipo_asignacion,cod_categoria_calificacion,cod_calificacion_riesgo" 
                                             OnRowCommand="gdvCalificaciones_RowCommand" 
                                             OnPageIndexChanging="gdvCalificaciones_PageIndexChanging">
                                                 <PagerSettings Mode="Numeric" Position="Bottom" PageButtonCount="10" />
                                                 
                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" Height="100%" />
                                                <Columns>
                                                    <asp:BoundField DataField="cedula_deudor" Visible="False"/>
                                                    <asp:BoundField DataField="nombre_deudor" Visible="False"/>
                                                    <asp:BoundField DataField="cod_tipo_asignacion" Visible="False"/>
                                                    <asp:ButtonField DataTextField="fecha_calificacion" CommandName="SelectedCalificacion" HeaderText="Fecha" Visible="True" ItemStyle-Width="200px" ItemStyle-HorizontalAlign="Center"/>
                                                    <asp:ButtonField DataTextField="des_tipo_asignacion" CommandName="SelectedCalificacion" HeaderText="Tipo de Asignación" Visible="True" ItemStyle-Width="250px" ItemStyle-HorizontalAlign="Center"/>
                                                    <asp:ButtonField DataTextField="cod_categoria_calificacion" CommandName="SelectedCalificacion" HeaderText="Categoría de Calificación" Visible="True" ItemStyle-Width="300px" ItemStyle-HorizontalAlign="Center"/>
                                                    <asp:ButtonField DataTextField="cod_calificacion_riesgo" CommandName="SelectedCalificacion" HeaderText="Calificación de Riesgo" Visible="True" ItemStyle-Width="330px" ItemStyle-HorizontalAlign="Center"/>
                                                </Columns>
                                                <RowStyle BackColor="#EFF3FB" />
                                                <EditRowStyle BackColor="#2461BF" />
                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" HorizontalAlign="Center" />
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
