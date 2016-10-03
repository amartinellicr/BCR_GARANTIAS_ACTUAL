<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" CodeFile="frmArchivosSEGUI.aspx.cs" Inherits="BCRGARANTIAS.Forms.frmArchivosSEGUI" Title="BCR GARANTIAS - Archivos SEGUI"%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<script language="javascript" type="text/javascript">
function ControlesTipoCambio()
{	
	var oControlCheckD = document.all ? document.all['<%= chkDeudorFCP.ClientID %>'] : document.getElementById('<%= chkDeudorFCP.ClientID %>');
	
	if(oControlCheckD != null)
	{
		var oufDeudor = document.all ? document.all['<%= fuDeudores.ClientID %>'] : document.getElementById('<%= fuDeudores.ClientID %>');
		
		if(oControlCheckD.checked)
		{
			if(oufDeudor != null) {oufDeudor.disabled = false;}
		}
		else
		{
			if(oufDeudor != null) {oufDeudor.disabled = true;}
		}
	}
}

function CargarArchivo()
{	
	var oufDeudor = document.all ? document.all['<%= fuDeudores.ClientID %>'] : document.getElementById('<%= fuDeudores.ClientID %>');
	if(oufDeudor != null) {oufDeudor.disabled = false;}
}

function DeshabilitarTipoCambio()
{
	var oufDeudor = document.all ? document.all['<%= fuDeudores.ClientID %>'] : document.getElementById('<%= fuDeudores.ClientID %>');
	if(oufDeudor != null) {oufDeudor.disabled = true;}
}

window.onload = ControlesTipoCambio;

</script>
    <div>
 		<table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window" border="0" cellSpacing="1">
			<tr>
				<td style="HEIGHT: 43px" align="center" colSpan="3">
				    <asp:label id="lblTexto" runat="server" CssClass="TextoTitulo"> Generación de Archivos de Garantías</asp:label>
				</td>
			</tr>
			<tr>
				<td vAlign="top" colSpan="3">
					<table class="table_Default" borderColor="#005a9c" width="60%" align="center" border="2"> <!--SUBTITULO DE FORMULARIO-->
						<tr>
							<td class="TextoTitulo_2" width="100%" bgColor="#dcdcdc" colSpan="4" rowSpan="1">BCR 
								GARANTIAS&nbsp;- Archivos de Garantías
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" align="center" border="0">
									<tr>
										<td align="center" colSpan="2">
										    <asp:label id="lblMensaje" runat="server" CssClass="TextoError" ForeColor="Red"></asp:label>&nbsp;
										</td>
									</tr>
									<tr>
										<td class="td_TextoCenter" colSpan="2">Seleccione los archivos de garantías que 
											desea generar:
										</td>
									</tr>
									<tr>
										<td class="td_Texto" width="40%"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkDeudor" runat="server" Text="Deudores"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Deudor" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Deudor" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasFiduciarias" runat="server" Text="Garantías Fiduciarias de Operaciones"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Fiduciarias" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Fiduciarias" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasReales" runat="server" Text="Garantías Reales de Operaciones"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Reales" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Reales" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasValor" runat="server" Text="Garantías de Valor de Operaciones"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Valor" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Valor" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasFiduciariasInfoCompleta" runat="server" Text="Garantías Fiduciarias de Operaciones (Información Completa)"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Fiduciarias_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Fiduciarias_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasRealesInfoCompleta" runat="server" Text="Garantías Reales de Operaciones (Información Completa)"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Reales_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Reales_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasValorInfoCompleta" runat="server" Text="Garantías de Valor de Operaciones (Información Completa)"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Valor_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Valor_Completa" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkContratos" runat="server" Text="Contratos"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGiros" runat="server" Text="Giros"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Giros" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Giros" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasFiduciariasContratos" runat="server" Text="Garantías Fiduciarias de Contratos"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Fiduciarias_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Fiduciarias_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasRealesContratos" runat="server" Text="Garantías Reales de Contratos"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Reales_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Reales_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkGarantiasValorContratos" runat="server" Text="Garantías de Valor de Contratos"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Garantias_Valor_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Garantias_Valor_Contratos" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
										    <asp:checkbox id="chkDeudorFCP" runat="server" onClick="ControlesTipoCambio()" Text="Archivo con Fecha de Capacidad de Pago de Deudores"></asp:checkbox>
										    <asp:Image ID="imgGeneracion_Exitosa_Deudor_FCP" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="false" />
										    <asp:Image ID="imgGeneracion_Fallida_Deudor_FCP" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="false" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto"></td>
										<td class="td_TextoIzq">
											&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
											<asp:FileUpload ID="fuDeudores" runat="server" CssClass="td_Texto" />
										</td>
									</tr>
									<tr>
										<td class="td_Texto" colSpan="2">&nbsp;</td>
									</tr>
									<tr>
										<td align="center" colSpan="2">
										    <asp:button id="btnGenerar" tabIndex="9" runat="server" Text="Generar Archivos" ToolTip="Generar Archivos de Garantías"></asp:button>
										</td>
									</tr>
									<tr>
										<td colSpan="2">
										    <br />
										    <asp:label id="lblLeyenda" runat="server" CssClass="td_TextoLeyendaCenter" Width="701px">El proceso de generación de los archivos de garantías puede tardar algunos minutos.</asp:label>&nbsp;
										    <br />
										    <asp:Label ID="lblGeneracionExitosa" runat="server" Visible="false" CssClass="td_TextoLeyendaCenter" Width="701px"><asp:Image ID="imgProcesoExitoso" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Icono de Generación Exitosa" ImageUrl="~/Images/proceso_exitoso.jpg" Visible="true" />: Esta imagen indica que la generación del archivo solicitado fue exitosa, por lo que está listo para su descarga.</asp:Label>
										    <br />
										    <asp:Label ID="lblGeneracionFallida" runat="server" Visible="false" CssClass="td_TextoLeyendaCenter" Width="701px"><asp:Image ID="imgProcesoFallido" runat="server" Width="15px" Height="15" ImageAlign="Middle" AlternateText="Icono de Generación Fallida" ImageUrl="~/Images/proceso_fallido.jpg" Visible="true" />: Esta imagen indica que se produjo un error durante la generación del archivo solicitado, favor colocar el puntero del ratón sobre la imagen para ver el detalle del error.</asp:Label>
										    <br />
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

