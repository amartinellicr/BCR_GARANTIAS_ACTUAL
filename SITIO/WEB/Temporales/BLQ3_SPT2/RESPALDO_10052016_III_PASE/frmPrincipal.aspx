<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" CodeFile="frmPrincipal.aspx.cs" Inherits="BCRGARANTIAS.Presentacion.frmPrincipal" Title="BCR GARANTIAS - Página Principal"%>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<asp:ScriptManager id="ScriptManager1" runat="server" ScriptMode="Auto">
</asp:ScriptManager>
 <asp:UpdatePanel id="UpdatePanel1" runat="server">
    <contenttemplate>
    <div id="master_content">
	    <table style="WIDTH: 775px" cellPadding="1" width="775" align="center" bgColor="window"
		    border="0" cellSpacing="1">
		    <tr>
			    <td>
				    <table id="table3" width="100%" border="0" style="vertical-align:top">
					    <tr>
						    <td align="left" width="20%" valign="top">
                                <ajaxToolkit:Accordion ID="acdInfoIzquierda" runat="server" SelectedIndex="0"
                                    HeaderCssClass="accordionHeader" HeaderSelectedCssClass="accordionHeaderSelected"
                                    ContentCssClass="accordionContent" FadeTransitions="false" FramesPerSecond="40" Width="168px" 
                                    TransitionDuration="250" AutoSize="Limit" RequireOpenedPane="true" SuppressHeaderPostbacks="true">
                                       <Panes>
                                        <ajaxToolkit:AccordionPane ID="adpGarantiasFiduciarias" HeaderCssClass="accordionHeader" ContentCssClass="accordionContent" runat="server" >
                                            <Header> <a href="" class="accordionLink">Garantías Fiduciarias </a> </Header>
                                            <Content>
                                                En este tipo de garantías se encuentra la fianza de personas físicas o jurídicas que responden solidariamente por una obligación contraída por un tercero en el Banco, quedando comprometidas a cumplirla en parte o en su totalidad, en caso de incumplimiento por parte del deudor.
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <ajaxToolkit:AccordionPane ID="adpGarantiasReales" HeaderCssClass="accordionHeader" ContentCssClass="accordionContent" runat="server" >
                                            <Header> <a href="" class="accordionLink"> Garantías Reales </a> </Header>
                                            <Content>
                                                Contempla: hipoteca común, cédulas hipotecarias y prenda.
                                                La hipoteca común es un derecho real constituido sobre un bien inmueble, (fincas, terrenos, o lotes), para asegurar el cumplimiento de una obligación, dándose el gravamen del inmueble en forma directa mediante escritura pública.
                                                La cédula hipotecaria es un título valor que corresponde a un gravamen impuesto por el propietario sobre una finca, este documento se puede tomar como garantía de un crédito que ha sido constituido en la cédula misma. Al tomarse en garantía permanecen en custodia del Banco durante la vigencia del crédito garantizado con las mismas.
                                                La prenda es  un derecho real establecido sobre un bien mueble,  para asegurar el cumplimiento de una obligación.  Toda especie de bienes muebles corporales e incorporales, susceptibles de enajenación, pueden ser dados en garantía mediante escritura pública.
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <ajaxToolkit:AccordionPane ID="adpGarantiasValor" HeaderCssClass="accordionHeader" ContentCssClass="accordionContent" runat="server" >
                                            <Header> <a href="" class="accordionLink"> Garantías de Valor </a> </Header>
                                            <Content>
                                               Derecho de contenido económico o patrimonial, incorporado en un documento, que por su configuración jurídica propia y régimen de transmisión pueda ser objeto de negociación en un mercado financiero o bursátil.
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                       </Panes>
                                </ajaxToolkit:Accordion>
						    </td>
						    <td width="60%" valign="top">
							    <table border="0">
								    <tr>
									    <td>
										    <img alt="" src="Images/Banner7.jpg">
									    </td>
								    </tr>
							    </table>
						    </td>
						    
						    <td align="right" width="20%" valign="top">
						        <table>
						            <tr>
						                <td>
							                <asp:Panel ID="pnlEncabezadoGarantias" runat="server" CssClass="collapsePanelHeader" Height="23px" Width="150px"> 
                                            <div style="padding:5px; cursor: pointer; vertical-align: middle;">
                                                <div style="float: left; color:Black">&nbsp;&nbsp;Garantías</div>
                                                <div style="float: left; margin-left: 20px;">
                                                </div>
                                                <div style="float: right; vertical-align: middle;">
                                                    <asp:ImageButton ID="imgExpande" runat="server" ImageUrl="Images/downarrows_white.gif" AlternateText="(Detalle...)"/>
                                                </div>
                                            </div>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlDetalleGarantias" runat="server" CssClass="collapsePanel" Height="0" Width="150px">
                                                <asp:HyperLink ID="cmdGarantiasOPeracion" runat="server" NavigateUrl="~/frmGarantiasXOperacion.aspx" CssClass="hyperlink" Text="">&#149; Garant&#237;as por Operaci&#243;n</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdGarantiasFiduciaria" runat="server" NavigateUrl="~/frmGarantiasFiduciaria.aspx" CssClass="hyperlink" Text="">&#149; Garant&#237;as Fiduciarias</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdGarantiasPorPerfil" runat="server" NavigateUrl="~/frmGarantiasporPerfil.aspx" CssClass="hyperlink" Text="">&#149; Garant&#237;as por Perfil</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdGarantiasReal" runat="server" NavigateUrl="~/frmGarantiasReales.aspx" CssClass="hyperlink" Text="">&#149; Garant&#237;as Reales</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdGarantiasValor" runat="server" NavigateUrl="~/frmGarantiasValor.aspx" CssClass="hyperlink" Text="">&#149; Garant&#237;as de Valor</asp:HyperLink>    
                                            </asp:Panel>

                                            <ajaxToolkit:CollapsiblePanelExtender ID="cpeGarantias" runat="Server"
                                            TargetControlID="pnlDetalleGarantias"
                                            ExpandControlID="pnlEncabezadoGarantias"
                                            CollapseControlID="pnlEncabezadoGarantias" 
                                            Collapsed="False"
                                            ImageControlID="imgExpande"    
                                            ExpandedText=""
                                            CollapsedText=""
                                            ExpandedImage="Images/uparrows_white.gif"
                                            CollapsedImage="Images/downarrows_white.gif"
                                            SuppressPostBack="true" /> 
						                </td>
					                </tr>
					                <tr>
                                        <td align="right" width="20%" valign="top">
                                            <asp:Panel ID="pnlEncabezadoMantenimientos" runat="server" CssClass="collapsePanelHeader" Height="23px" Width="150px"> 
                                                <div style="padding:5px; cursor: pointer; vertical-align: middle;">
                                                    <div style="float: left; color:Black">&nbsp;&nbsp;Mantenimientos</div>
                                                    <div style="float: left; margin-left: 20px;">
                                                    </div>
                                                    <div style="float: right; vertical-align: middle;">
                                                        <asp:ImageButton ID="imgExpendeMant" runat="server" ImageUrl="Images/downarrows_white.gif" AlternateText="(Detalle...)"/>
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlDetalleMantenimientos" runat="server" CssClass="collapsePanel" Height="0" Width="150px">
                                                <asp:HyperLink ID="cmdEmpresa" runat="server" NavigateUrl="~/frmEmpresas.aspx" CssClass="hyperlink" Text="">&#149; Empresas</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdPerito" runat="server" NavigateUrl="~/frmPeritos.aspx" CssClass="hyperlink" Text="">&#149; Peritos</asp:HyperLink>    
                                            </asp:Panel>

                                            <ajaxToolkit:CollapsiblePanelExtender ID="cpeDemo" runat="Server"
                                            TargetControlID="pnlDetalleMantenimientos"
                                            ExpandControlID="pnlEncabezadoMantenimientos"
                                            CollapseControlID="pnlEncabezadoMantenimientos" 
                                            Collapsed="False"
                                            ImageControlID="imgExpendeMant"    
                                            ExpandedText=""
                                            CollapsedText=""
                                            ExpandedImage="Images/uparrows_white.gif"
                                            CollapsedImage="Images/downarrows_white.gif"
                                            SuppressPostBack="true" /> 
                                    </td>
                                </tr>
                                <tr>
                                        <td align="right" width="20%" valign="top">
                                            <asp:Panel ID="pnlEncabezadoReportes" runat="server" CssClass="collapsePanelHeader" Height="23px" Width="150px"> 
                                                <div style="padding:5px; cursor: pointer; vertical-align: middle;">
                                                    <div style="float: left; color:Black">&nbsp;&nbsp;Reportes</div>
                                                    <div style="float: left; margin-left: 20px;">
                                                    </div>
                                                    <div style="float: right; vertical-align: middle;">
                                                        <asp:ImageButton ID="imgExpendeReportes" runat="server" ImageUrl="Images/downarrows_white.gif" AlternateText="(Detalle...)"/>
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlDetalleReportes" runat="server" CssClass="collapsePanel" Height="0" Width="150px">
                                                <asp:HyperLink ID="cmdAvanceOficina" runat="server" NavigateUrl="~/frmConsultaAvanceXGarantia.aspx" CssClass="hyperlink" Text="">&#149; Avance por Oficina</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdTransaccionesRealizadas" runat="server" NavigateUrl="~/Reportes/frmRptFiltroBitacora.aspx" CssClass="hyperlink" Text="">&#149; Transacciones de &nbsp;&nbsp;&nbsp;Bitácora</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdGenerarArchivos" runat="server" NavigateUrl="~/frmArchivosSEGUI.aspx" CssClass="hyperlink" Text="">&#149; Generar Archivos de &nbsp;&nbsp;&nbsp;Garant&#237;as</asp:HyperLink>    
                                                <br />
                                                <asp:HyperLink ID="cmdBajarArchivos" runat="server" NavigateUrl="~/frmDownload.aspx" CssClass="hyperlink" Text="">&#149; Descargar Archivos de &nbsp;&nbsp;&nbsp;Garant&#237;as</asp:HyperLink>    
                                            </asp:Panel>

                                            <ajaxToolkit:CollapsiblePanelExtender ID="CollapsiblePanelExtender1" runat="Server"
                                            TargetControlID="pnlDetalleReportes"
                                            ExpandControlID="pnlEncabezadoReportes"
                                            CollapseControlID="pnlEncabezadoReportes" 
                                            Collapsed="False"
                                            ImageControlID="imgExpendeReportes"    
                                            ExpandedText=""
                                            CollapsedText=""
                                            ExpandedImage="Images/uparrows_white.gif"
                                            CollapsedImage="Images/downarrows_white.gif"
                                            SuppressPostBack="true" /> 
                                    </td>
                                </tr>
                            </table>
					    </tr>
				    </table>
			    </td>
		    </tr>
		    <tr>
			    <td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">
				    Banco de Costa Rica © Derechos reservados&nbsp;2006.</td>
		    </tr>
	    </table>
    </div>
</contenttemplate>
</asp:UpdatePanel>
</asp:Content>
