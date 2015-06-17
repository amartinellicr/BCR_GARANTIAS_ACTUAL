<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmReporteGeneralForm.aspx.cs" Inherits="Reportes_frmReporteGeneralForm" Title="BCR GARANTIAS - Reportes"%>

<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
<table>            
    <tr>            
        <td align="center">
            <iframe id="IFrameReporte" runat="server" frameborder="0" src="" height="500" width="760"></iframe>
        </td>                                                      
    </tr>   
    <tr>
        <td>
            <table class="table_Default" width="60%" align="center" border="0">
			    <tr>
				    <td style="FONT-SIZE: 10px; COLOR: gray; FONT-FAMILY: Arial, Verdana, Tahoma" align="center">Banco 
					    de Costa Rica © Derechos reservados 2006.</td>
			    </tr>
		    </table>
        </td>
    </tr>             
</table> 
</asp:Content>



 