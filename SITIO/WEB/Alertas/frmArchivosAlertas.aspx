<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmArchivosAlertas.aspx.cs" Inherits="BCRGARANTIAS.Forms.Alertas_frmArchivosAlertas" Title="BCR GARANTIAS - Archivos Alertas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <div>
 		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window" border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colspan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Generación de Archivos de Alertas</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colspan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colspan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Archivos de Alertas
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
										<td class="td_TextoCenter" colspan="2">Seleccione los archivos de alertas que 
											desea generar y descargar:
										</td>
									</tr>
            						<tr>
										<td class="td_Texto" colspan="2">&nbsp;</td>
									</tr>
									<tr>
										<td class="td_Texto" width="40%"></td>
										<td class="td_TextoIzq">
										    <asp:CheckBox id="chkAlertaInscripcion" runat="server" Text="Indicadores de Inscripción por Cambiar"/>
										</td>
									</tr>
            						<tr>
										<td class="td_Texto" colspan="2">&nbsp;</td>
									</tr>
									<tr>
										<td align="center" colspan="2">
										    <asp:Button id="btnGenerarDescargar" tabIndex="9" runat="server" Text="Generar Archivos" ToolTip="Generar y Descargar Archivos de Alertas" />
										</td>
									</tr>
									<tr>
										<td colspan="2">
										    <asp:Label id="lblLeyenda" runat="server" CssClass="td_TextoLeyendaCenter" Width="701px">El proceso de generación de los archivos de alertas puede tardar algunos minutos.</asp:Label>&nbsp;
										</td>
									</tr>
								</table>
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
</asp:Content>

