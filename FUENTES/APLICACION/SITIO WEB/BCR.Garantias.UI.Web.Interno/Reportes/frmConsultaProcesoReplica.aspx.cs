using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using BCR.GARANTIAS.Entidades;
using BCRGARANTIAS.Negocios;

public partial class Reportes_frmConsultaProcesoReplica : System.Web.UI.Page
{
    #region Variables Globales
    protected DataSet dsResultadosEjecucion = new DataSet();
    #endregion

    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        btnConsultar.Click += new EventHandler(btnConsultar_Click);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_REPORTE_EJECUCION_PROCESOS"].ToString())))
                {
                    txtFechaInicial.Focus();
                    ScriptManager1.SetFocus(this.txtFechaInicial);
                    Session.Remove("bGridCargado");

                }
                else
                {
                    //El usuario no tiene acceso a esta página
                    throw new Exception("ACCESO DENEGADO");
                }
            }
            catch (Exception ex)
            {
                string strRutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                strRutaActual = strRutaActual.Remove(strRutaActual.IndexOf("/Reportes"));

                if (ex.Message.StartsWith("ACCESO DENEGADO"))
                {
                    Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Acceso Denegado" +
                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                        "&bBotonVisible=0");
                }
                else
                {
                    Response.Redirect(strRutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Página" +
                        "&strMensaje=" + ex.Message +
                        "&bBotonVisible=0");
                }
            }
        }
    }

    void btnConsultar_Click(object sender, EventArgs e)
    {
        if ((txtFechaInicial.Text == string.Empty) || (txtFechaFinal.Text == string.Empty))
        {
            lblMensaje.Text = "Las dos fechas son requeridas, favor de proveerlas";
            dsResultadosEjecucion = new DataSet();
            dsResultadosEjecucion.Tables.Add(CrearEstructuraDataSet());
            this.gdvReporte.Visible = false;
        }
        else
        {
            this.gdvReporte.Visible = true;
            CargarGrid();
        }
    }

    #endregion

    #region Métodos GridView

    protected void gdvReporte_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
            gdvReporte.PageIndex = e.NewPageIndex;
            CargarGrid();
    }

    #endregion

    #region Métodos Privados

    /// <summary>
    /// Método que se encarga de realizar la consulta solicitada
    /// </summary>
    private void RealizarConsulta()
    {
        clsEjecucionProcesos<clsEjecucionProceso> listaResultadosEjecucion = new clsEjecucionProcesos<clsEjecucionProceso>();
        DateTime dFI = new DateTime();
        DateTime dFF = new DateTime();

        lblMensaje.Text = string.Empty;

        bool bProseguir = true;

        if ((DateTime.TryParse(txtFechaInicial.Text, out dFI)) && (DateTime.TryParse(txtFechaFinal.Text, out dFF)))
        {
            if (!ValidarFechas(dFI, dFF))
            {
                bProseguir = false;
            }
        }
        else
        {
            lblMensaje.Text = "Valor ingresado erroneo o formato de fecha incorrecto: dd/mm/aaaa";
            bProseguir = false;
        }

        if (bProseguir)
        {
            string codigoProceso = string.Empty;
            string indicadorResultado = string.Empty;

            if (cbCodigoProceso.SelectedItem.Value.CompareTo("-1") != 0)
            {
                codigoProceso = cbCodigoProceso.SelectedItem.Value;
            }

            if (cbIndicadorResultado.SelectedItem.Value.CompareTo("-1") != 0)
            {
                indicadorResultado = cbIndicadorResultado.SelectedItem.Value;
            }

            listaResultadosEjecucion = Gestor.Obtener_Resultado_Ejecucion_Proceso(dFI, dFF, codigoProceso, indicadorResultado);

            if ((listaResultadosEjecucion != null) && (listaResultadosEjecucion.Count > 0))
            {
                dsResultadosEjecucion = listaResultadosEjecucion.toDataSet();
            }
            else
            {
                dsResultadosEjecucion = new DataSet();
                dsResultadosEjecucion.Tables.Add(CrearEstructuraDataSet());
            }
        }
        else
        {
            dsResultadosEjecucion = new DataSet();
            dsResultadosEjecucion.Tables.Add(CrearEstructuraDataSet());
            this.gdvReporte.Visible = false;
        }
    }

    /// <summary>
    /// Método que se encarga de cargar el GridView con la información recopilada
    /// </summary>
    private void CargarGrid()
    {

        this.gdvReporte.DataSource = null;
        this.gdvReporte.DataBind();

        RealizarConsulta();

        if ((dsResultadosEjecucion != null) && (dsResultadosEjecucion.Tables.Count > 0) && (dsResultadosEjecucion.Tables[0].Rows.Count > 0))
        {
            if ((!dsResultadosEjecucion.Tables[0].Rows[0].IsNull("cocProceso")) &&
                (!dsResultadosEjecucion.Tables[0].Rows[0].IsNull("fecIngreso")) &&
                (!dsResultadosEjecucion.Tables[0].Rows[0].IsNull("Resultado")) &&
                (!dsResultadosEjecucion.Tables[0].Rows[0].IsNull("desObservacion")))
            {
                this.gdvReporte.DataSource = dsResultadosEjecucion.Tables[0].DefaultView;
                this.gdvReporte.DataBind();
            }
            else
            {
                dsResultadosEjecucion.Tables[0].Rows.Add(dsResultadosEjecucion.Tables[0].NewRow());
                this.gdvReporte.DataSource = dsResultadosEjecucion;
                this.gdvReporte.DataBind();

                int TotalColumns = this.gdvReporte.Rows[0].Cells.Count;
                this.gdvReporte.Rows[0].Cells.Clear();
                this.gdvReporte.Rows[0].Cells.Add(new TableCell());
                this.gdvReporte.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                this.gdvReporte.Rows[0].Cells[0].Text = "No existen registros";
            }
        }
        else
        {
            dsResultadosEjecucion.Tables[0].Rows.Add(dsResultadosEjecucion.Tables[0].NewRow());
            this.gdvReporte.DataSource = dsResultadosEjecucion;
            this.gdvReporte.DataBind();

            int TotalColumns = this.gdvReporte.Rows[0].Cells.Count;
            this.gdvReporte.Rows[0].Cells.Clear();
            this.gdvReporte.Rows[0].Cells.Add(new TableCell());
            this.gdvReporte.Rows[0].Cells[0].ColumnSpan = TotalColumns;
            this.gdvReporte.Rows[0].Cells[0].Text = "No existen registros";
        }
    }

    /// <summary>
    /// Función que crea la estructura que debería poseer el dataset, esto en caso de que no hayan
    /// registros que presentar o algún error.
    /// </summary>
    /// <returns>Tabla con la estructura que debería poeer el dataset</returns>
    private DataTable CrearEstructuraDataSet()
    {
        DataTable dtResultadoEjecucionNuevo = new DataTable("Datos");

        string[] arrDatos = { "cocProceso", "fecIngreso", "Resultado", "desObservacion" };


        foreach (string strDato in arrDatos)
        {

            DataColumn dcDato = new DataColumn(strDato);
            dcDato.DataType = System.Type.GetType("System.String");
            dcDato.AllowDBNull = true;

            dtResultadoEjecucionNuevo.Columns.Add(dcDato);
            dtResultadoEjecucionNuevo.AcceptChanges();
        }

        return dtResultadoEjecucionNuevo;
    }

    private bool ValidarFechas(DateTime dFechaI, DateTime dFechaF)
    {
        bool bFechasValidas = false;

        if (dFechaI <= dFechaF)
        {
            bFechasValidas = true;
        }
        else
        {
            lblMensaje.Text = "La fecha final debe ser mayor o igual a la fecha inicial";
        }

        return bFechasValidas;
    }

    #endregion
}
