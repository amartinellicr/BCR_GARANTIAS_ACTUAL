<%@ Page Language="C#" MasterPageFile="~/Pagina Maestra/mtpMenuPrincipal.master" AutoEventWireup="true" CodeFile="frmReporteBitacora.aspx.cs" Inherits="Reportes_frmReporteBitacora" Title="Untitled Page" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="cphPrincipal" Runat="Server">
    <rsweb:ReportViewer ID="ReportViewer1" runat="server" Font-Names="Verdana" Font-Size="8pt"
        Height="418px" Width="877px">
    </rsweb:ReportViewer>
    
    
</asp:Content>

