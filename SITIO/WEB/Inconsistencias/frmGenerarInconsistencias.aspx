<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmGenerarInconsistencias.aspx.cs" Inherits="BCRGARANTIAS.Forms.Inconsistencias_frmGenerarInconsistencias" Title="BCR GARANTIAS - Archivos Inconsistencias" %>
<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
 		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window" border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colspan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Generación de Archivos de Inconsistencias</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colspan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Archivos de Inconsistencias
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" colspan="2">
										    <asp:Label id="lblMensaje" runat="server" CssClass="TextoError" ForeColor="Red"></asp:Label>
										</td>
									</tr>
									<tr>
										<td class="td_TextoCenter" colspan="2">Seleccione los archivos de inconsistencias que 
											desea generar:
										</td>
									</tr>
									<tr>
										<td class="td_Texto" width="40%"></td>
										<td class="td_TextoIzq">
										    <asp:CheckBox id="chkErrorInscripcion" runat="server" Text="Error de Inscripción"/>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" width="40%"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkErrorPartidoFinca" runat="server" Text="Error del Partido y la Finca"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto" width="40%"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkErrorTipoGarantiaReal" runat="server" Text="Error del Tipo de Garantía Real"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkErrorValuaciones" runat="server" Text="Error de Valuaciones"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkClasesGarantiaReal" runat="server" Text="Error en Clase de Garantía"></asp:checkbox>
										</td>
									</tr>
<%--									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasRealesInfoCompleta" runat="server" Text="Garantas Reales de Operaciones (Informacin Completa)"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasValorInfoCompleta" runat="server" Text="Garantas de Valor de Operaciones (Informacin Completa)"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkContratos" runat="server" Text="Contratos"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGiros" runat="server" Text="Giros"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasFiduciariasContratos" runat="server" Text="Garantas Fiduciarias de Contratos"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasRealesContratos" runat="server" Text="Garantas Reales de Contratos"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasValorContratos" runat="server" Text="Garantas de Valor de Contratos"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkDeudorFCP" runat="server" onClick="ControlesTipoCambio()" Text="Archivo con Fecha de Capacidad de Pago de Deudores"></asp:checkbox>
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
											&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
											<asp:FileUpload ID="fuDeudores" runat="server" CssClass="td_Texto" />
										</td>
									</tr>
--%>						<tr>
										<td class="td_Texto" colspan="2">&nbsp;</td>
									</tr>
									<tr>
										<td align="center" colspan="2">
										    <asp:Button id="btnGenerar" tabIndex="9" runat="server" Text="Generar Archivos" ToolTip="Generar Archivos de Inconsistencias" />
										</td>
									</tr>
									<tr>
										<td colspan="2">
										    <asp:Label id="lblLeyenda" runat="server" CssClass="td_TextoLeyendaCenter" Width="701px">El proceso de generación de los archivos de inconsistencias de garantías puede tardar algunos minutos.</asp:Label>&nbsp;
										</td>
									</tr>
								</table>
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
</asp:Content>

