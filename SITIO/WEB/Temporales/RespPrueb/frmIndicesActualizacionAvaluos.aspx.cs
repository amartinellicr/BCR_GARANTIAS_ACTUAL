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

public partial class frmIndicesActualizacionAvaluos : BCR.Web.SystemFramework.PaginaPersistente
{
    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        btnInsertar.Click += new EventHandler(btnInsertar_Click);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        txtTipoCambio.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtTipoCambio.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

        txtIndicePreciosConsumidor.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");
        txtIndicePreciosConsumidor.Attributes.Add("onblur", "javascript:FormatNumber(this,this.value,2,true,true,false)");

        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_INDICES_ACT_AVALUOS"].ToString())))
                {
                    InicializarCampos();
                    CargarGrid();
                }
                else
                {
                    //El usuario no tiene acceso a esta página
                    throw new Exception("ACCESO DENEGADO");
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("ACCESO DENEGADO"))
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Acceso Denegado" +
                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta página." +
                        "&bBotonVisible=0");
                else
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Cargando Página" +
                        "&strMensaje=" + ex.Message +
                        "&bBotonVisible=0");
            }
        }
    }

    private void btnInsertar_Click(object sender, System.EventArgs e)
    {
        clsIndiceActualizacionAvaluo entidadIndiceActualizacionAvaluo = new clsIndiceActualizacionAvaluo();
        DateTime fechaIngresada = DateTime.MinValue;
        DateTime fechaReg;
        bool seProsigue = true;

        try
        {
            if (txtFechaRegistro.Text.Length > 0)
            {
                fechaIngresada = ((DateTime.TryParse(txtFechaRegistro.Text, out fechaReg)) ? fechaReg : DateTime.MinValue);

                if ((fechaIngresada != DateTime.MinValue) && (fechaIngresada.Date == DateTime.Now.Date))
                {
                    fechaIngresada = DateTime.Now;
                }
                else if ((fechaIngresada != DateTime.MinValue) && (fechaIngresada.Date < DateTime.Now.Date))
                {
                    fechaIngresada = fechaIngresada.AddHours(DateTime.Now.Hour).AddMinutes(DateTime.Now.Minute).AddSeconds(DateTime.Now.Second);
                }
                else if ((fechaIngresada != DateTime.MinValue) && (fechaIngresada.Date > DateTime.Now.Date))
                {
                    lblMensaje.Text = "La fecha no puede ser mayor a la actual.";
                    seProsigue = false;
                }
            }

            if (seProsigue)
            {
                entidadIndiceActualizacionAvaluo.FechaHora = fechaIngresada;
                entidadIndiceActualizacionAvaluo.TipoCambio = Convert.ToDecimal((txtTipoCambio.Text.Length > 0 ? txtTipoCambio.Text : "0.00"));
                entidadIndiceActualizacionAvaluo.IndicePreciosConsumidor = Convert.ToDecimal((txtIndicePreciosConsumidor.Text.Length > 0 ? txtIndicePreciosConsumidor.Text : "0.00"));

                if (entidadIndiceActualizacionAvaluo.CamposRequeridosValidos())
                {
                    Gestor.InsertarIndiceActualizacionAvaluo(entidadIndiceActualizacionAvaluo, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    StringBuilder url = new StringBuilder(Page.ResolveUrl("frmMensaje.aspx"));
                    url.Append("?bError=0&strTitulo=Inserción Exitosa&strMensaje=El Indice de Actualización de Avalúos se insertó satisfactoriamente.");
                    url.Append("&bBotonVisible=1&strTextoBoton=Regresar&strHref=frmIndicesActualizacionAvaluos.aspx");

                    Response.Redirect(url.ToString(), false);
                }
                else
                {
                    lblMensaje.Text = entidadIndiceActualizacionAvaluo.DescripcionError;
                }
            }
        }
        catch (Exception ex)
        {
            string errorBitacora = "Error en capa de presentación. Página: frmIndicesActualizacionAvaluos.aspx, Evento: btnInsertar_Click. Error: " + ex.Message;
            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorInsertandoIndicesActAvaluosDetalle, errorBitacora, Mensajes.ASSEMBLY), EventLogEntryType.Error);

            Response.Redirect("frmMensaje.aspx?" +
                            "bError=1" +
                            "&strTitulo=" + "Problemas Insertando Registro" +
                            "&strMensaje=" + "No se pudo insertar el Indice de Actualización de Avalúos." + "\r" +
                            "&bBotonVisible=1" +
                            "&strTextoBoton=Regresar" +
                            "&strHref=frmIndicesActualizacionAvaluos.aspx");
        }
    }

    #endregion

    #region Métodos Privados

    /// <summary>
    /// Método que carga el grid con la información del último registro ingresado
    /// </summary>
    private void CargarGrid()
    {
        try
        {
            clsIndicesActualizacionAvaluos<clsIndiceActualizacionAvaluo> ultimoIndiceRegistrado = null;

            ultimoIndiceRegistrado = Gestor.ObtenerIndicesActualizacionAvaluos(0, DateTime.Now.Year, DateTime.Now.Month);

            if (ultimoIndiceRegistrado.ErrorDatos)
            {
                lblMensaje.Text = ultimoIndiceRegistrado.DescripcionError;
            }
            else
            {
                if (ultimoIndiceRegistrado.Count > 0)
                {
                    this.gdvIndicesAA.DataSource = ultimoIndiceRegistrado;
                    this.gdvIndicesAA.DataBind();
                }
                else
                {
                    DataTable dtRegistroVacio = new DataTable();

                    DataColumn dcColumnaVacia = new DataColumn("FechaHora");
                    dtRegistroVacio.Columns.Add(dcColumnaVacia);

                    dcColumnaVacia = new DataColumn("TipoCambio");
                    dtRegistroVacio.Columns.Add(dcColumnaVacia);

                    dcColumnaVacia = new DataColumn("IndicePreciosConsumidor");
                    dtRegistroVacio.Columns.Add(dcColumnaVacia);

                    dtRegistroVacio.Rows.Add(dtRegistroVacio.NewRow());

                    dtRegistroVacio.AcceptChanges();

                    this.gdvIndicesAA.DataSource = dtRegistroVacio;
                    this.gdvIndicesAA.DataBind();

                    int TotalColumns = this.gdvIndicesAA.Rows[0].Cells.Count;
                    this.gdvIndicesAA.Rows[0].Cells.Clear();
                    this.gdvIndicesAA.Rows[0].Cells.Add(new TableCell());
                    this.gdvIndicesAA.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvIndicesAA.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluos, Mensajes.ASSEMBLY);

            string errorBitacora = "Error en capa de presentación. Página: frmIndicesActualizacionAvaluos.aspx, Método: CargarGrid. Error: " + ex.Message;
            UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes._errorCargaIndicesActAvaluosDetalle, errorBitacora, Mensajes.ASSEMBLY), EventLogEntryType.Error);
        }
    }

    /// <summary>
    /// Inicializa los campos con los valores por defecto.
    /// </summary>
    private void InicializarCampos()
    {
        txtFechaRegistro.Text = DateTime.Now.ToShortDateString();
        txtTipoCambio.Text = decimal.Zero.ToString("N2");
        txtIndicePreciosConsumidor.Text = decimal.Zero.ToString("N2");
    }

    #endregion
}
