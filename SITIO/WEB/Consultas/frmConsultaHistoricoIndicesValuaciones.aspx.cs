using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;

using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;

public partial class Consultas_frmConsultaHistoricoIndicesValuaciones : BCR.Web.SystemFramework.PaginaPersistente
{
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
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_CONSULTA_HST_INDICES_ACT_AVALUOS"].ToString())))
                {
                    InicializarCampos();
                }
                else
                {
                    //El usuario no tiene acceso a esta página
                    throw new Exception("ACCESO DENEGADO");
                }
            }
            catch (Exception ex)
            {
                string rutaActual = HttpContext.Current.Request.Path.Substring(0, HttpContext.Current.Request.Path.LastIndexOf("/"));

                rutaActual = rutaActual.Remove(rutaActual.IndexOf("/Consultas"));

                if (ex.Message.StartsWith("ACCESO DENEGADO"))
                    Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Acceso Denegado" +
                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                        "&bBotonVisible=0");
                else
                    Response.Redirect(rutaActual + "/frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Página" +
                        "&strMensaje=" + ex.Message +
                        "&bBotonVisible=0");
            }
        }
    }

    private void btnConsultar_Click(object sender, System.EventArgs e)
    {
        CargarGrid();
    }

    #endregion

    #region Métodos Privados

    /// <summary>
    /// Método que carga el grid con la información del histórico de registros.
    /// </summary>
    private void CargarGrid()
    {
        if ((ddlAnno != null) && (ddlAnno.Items.Count > 0) && (ddlMes != null) && (ddlMes.Items.Count > 0) &&
            (ddlAnno.SelectedItem.Value.Length > 0) && (ddlMes.SelectedItem.Value.Length > 0))
        {
            try
            {
                clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> historicoIndicesRegistrados = null;

                int annoConsulta = Convert.ToInt32(ddlAnno.SelectedItem.Value);
                int mesConsulta = Convert.ToInt32(ddlMes.SelectedItem.Value);

                historicoIndicesRegistrados = Gestor.ObtenerIndicesActualizacionAvaluos(1, annoConsulta, mesConsulta);

                if (historicoIndicesRegistrados.ErrorDatos)
                {
                    lblMensaje.Text = historicoIndicesRegistrados.DescripcionError;
                }
                else
                {
                    if (historicoIndicesRegistrados.Count > 0)
                    {
                        this.gdvIndicesAA.DataSource = historicoIndicesRegistrados;
                        this.gdvIndicesAA.DataBind();
                    }
                    else
                    {
                        this.gdvIndicesAA.DataSource = null;
                        this.gdvIndicesAA.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

                string errorBitacora = "Error en capa de presentación. Página: frmConsultaHistoricoIndicesValuaciones.aspx, Método: CargarGrid. Error: " + ex.Message;
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, errorBitacora, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
        }
        else
        {
            lblMensaje.Text = Mensajes.Obtener(Mensajes.ERROR_DATO_REQUERIDO, "al año y al mes", Mensajes.ASSEMBLY);
        }
    }

    /// <summary>
    /// Inicializa los campos con los valores por defecto.
    /// </summary>
    private void InicializarCampos()
    {
        try
        {
            clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> annosIndicesRegistrados = null;

            annosIndicesRegistrados = Gestor.ObtenerIndicesActualizacionAvaluos(2, DateTime.Now.Year, DateTime.Now.Month);

            if (annosIndicesRegistrados.ErrorDatos)
            {
                lblMensaje.Text = annosIndicesRegistrados.DescripcionError;
            }
            else
            {
                if (annosIndicesRegistrados.Count > 0)
                {
                    ddlAnno.DataSource = annosIndicesRegistrados;
                    ddlAnno.DataTextField = clsIndiceActualizacionAvaluo._Anno;
                    ddlAnno.DataValueField = clsIndiceActualizacionAvaluo._Anno;
                    ddlAnno.DataBind();
                }
                else
                {
                    ddlAnno.ClearSelection();
                    ddlAnno.DataSource = null;
                    ddlAnno.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

            string errorBitacora = "Error en capa de presentación. Página: frmConsultaHistoricoIndicesValuaciones.aspx, Método: InicializarCampos. Error: " + ex.Message;
            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, errorBitacora, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        }
    }

    #endregion
}
