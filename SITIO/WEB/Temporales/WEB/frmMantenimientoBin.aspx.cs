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
using System.Data.OleDb;
using BCRGARANTIAS.Negocios;

public partial class frmMantenimientoBin : BCR.Web.SystemFramework.PaginaPersistente
{
    #region Eventos

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        btnEliminar.Click += new EventHandler(btnEliminar_Click);
        btnInsertar.Click += new EventHandler(btnInsertar_Click);
        btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        txtNumeroBin.Attributes["onblur"] = "javascript:EsNumerico(this);";

        btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el campo seleccionado?')";

        if (!IsPostBack)
        {
            try
            {
                if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_BIN_TARJETA"].ToString())))
                {
                    lblBin.Text = "Lista de Bin de Tarjetas";

                    CargarGrid();
                    btnEliminar.Enabled = false;
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
        try
        {
            if (ValidarDatos())
            {
                int nMensaje = Gestor.InsertarBinTarjeta(Convert.ToInt32(txtNumeroBin.Text), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                string[] mensajes = MostrarMensaje(nMensaje, 1);

                Response.Redirect("frmMensaje.aspx?" +
                            "bError=" + mensajes[0] +
                            "&strTitulo=" + mensajes[1] +
                            "&strMensaje=" + mensajes[2] +
                            "&bBotonVisible=1" +
                            "&strTextoBoton=Regresar" +
                            "&strHref=frmMantenimientoBin.aspx");
            }
        }
        catch (Exception ex)
        {
            if (ex.Message.StartsWith("The statement has been terminated."))
            {
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas Insertando Registro" +
                                "&strMensaje=" + "No se pudo insertar el BIN." + "\r" +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
        }
    }

    private void btnLimpiar_Click(object sender, System.EventArgs e)
    {
        try
        {
            txtNumeroBin.Text = string.Empty;
            btnInsertar.Enabled = true;
            btnEliminar.Enabled = false;
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    private void btnEliminar_Click(object sender, System.EventArgs e)
    {
        try
        {
           int nMensaje = Gestor.EliminarBinTarjeta(Convert.ToInt32(txtNumeroBin.Text), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

            string[] mensajes = MostrarMensaje(nMensaje, 2);

            Response.Redirect("frmMensaje.aspx?" +
                            "bError=" + mensajes[0] +
                            "&strTitulo=" + mensajes[1] +
                            "&strMensaje=" + mensajes[2] +
                            "&bBotonVisible=1" +
                            "&strTextoBoton=Regresar" +
                            "&strHref=frmMantenimientoBin.aspx");
        }
        catch (Exception ex)
        {
            if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
            {
                Response.Redirect("frmMensaje.aspx?" +
                    "bError=1" +
                    "&strTitulo=" + "Problemas Eliminando Registro" +
                    "&strMensaje=" + "No se pudo eliminar el BIN." + "\r" +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmMantenimientoCatalogos.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
        }
    }

    #endregion

    #region Métodos GridView

    protected void gdvBines_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        GridView gdvBines = (GridView)sender;
        int rowIndex = 0;

        try
        {
            switch (e.CommandName)
            {
                case ("SelectedBin"):
                    rowIndex = (int.Parse(e.CommandArgument.ToString()));

                    gdvBines.SelectedIndex = rowIndex;

                    try
                    {
                        if (gdvBines.SelectedDataKey[0].ToString() != null)
                            txtNumeroBin.Text = gdvBines.SelectedDataKey[0].ToString();
                        else
                            txtNumeroBin.Text = "";

                        btnInsertar.Enabled = false;
                        btnEliminar.Enabled = true;

                    }
                    catch (Exception ex)
                    {
                        lblMensaje.Text = ex.Message;
                    }


                    break;

            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    protected void gdvBines_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        this.gdvBines.SelectedIndex = -1;
        this.gdvBines.PageIndex = e.NewPageIndex;

        CargarGrid();
    }

    #endregion

    #region Métodos Privados
    /// <summary>
    /// Metodo que carga el grid con la informacion de grupos de interes economico
    /// </summary>
    private void CargarGrid()
    {
        try
        {
            DataTable dtDatos = new DataTable();

            DataSet dsDatos = new DataSet();

            dsDatos = Gestor.ObtenerListaBin();

            if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables[0].Rows.Count > 0))
            {
                dtDatos = dsDatos.Tables[0];

                if ((!dtDatos.Rows[0].IsNull("bin")) &&
                    (!dtDatos.Rows[0].IsNull("fecingreso")))
                {
                    this.gdvBines.DataSource = dtDatos.DefaultView;
                    this.gdvBines.DataBind();
                }
                else
                {
                    dtDatos.Rows.Add(dtDatos.NewRow());
                    this.gdvBines.DataSource = dtDatos;
                    this.gdvBines.DataBind();

                    int TotalColumns = this.gdvBines.Rows[0].Cells.Count;
                    this.gdvBines.Rows[0].Cells.Clear();
                    this.gdvBines.Rows[0].Cells.Add(new TableCell());
                    this.gdvBines.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                    this.gdvBines.Rows[0].Cells[0].Text = "No existen registros";
                }
            }
            else
            {
                dsDatos.Tables[0].Rows.Add(dsDatos.Tables[0].NewRow());
                this.gdvBines.DataSource = dsDatos;
                this.gdvBines.DataBind();

                int TotalColumns = this.gdvBines.Rows[0].Cells.Count;
                this.gdvBines.Rows[0].Cells.Clear();
                this.gdvBines.Rows[0].Cells.Add(new TableCell());
                this.gdvBines.Rows[0].Cells[0].ColumnSpan = TotalColumns;
                this.gdvBines.Rows[0].Cells[0].Text = "No existen registros";
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
    }

    /// <summary>
    /// Metodo de validación de datos
    /// </summary>
    /// <returns></returns>
    private bool ValidarDatos()
    {
        bool bRespuesta = true;
        try
        {
            lblMensaje.Text = "";
            if (bRespuesta && txtNumeroBin.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el número de bin.";
                bRespuesta = false;
            }
        }
        catch (Exception ex)
        {
            lblMensaje.Text = ex.Message;
        }
        return bRespuesta;
    }

    /// <summary>
    /// Maneja los mensajes que se deben mostrar de acuerdo al número retornado por la transacción
    /// </summary>
    /// <param name="numeroMensaje">
    /// Número de mensaje que se debe mostrar
    /// </param>
    /// <returns>
    /// Arreglo de strings con los mensajes a mostrar
    /// </returns>
    private string[] MostrarMensaje(int numeroMensaje, int nAccion)
    {
        string[] mensaje = { string.Empty, string.Empty, string.Empty };

        
        if (numeroMensaje.Equals(0))
        {
            mensaje[0] = "0";

            if (nAccion == 1) //Insertar
            {
                mensaje[1] = "Inserción Exitosa";
                mensaje[2] = "El BIN se insertó satisfactoriamente.";
            }
            else if (nAccion == 2) //Eliminar
            {
                mensaje[1] = "Eliminación Exitosa";
                mensaje[2] = "El BIN se eliminó satisfactoriamente.";
            }
        }
        else
            if (numeroMensaje.Equals(1))
            {
                mensaje[0] = "1";
                if (nAccion == 1) //Insertar
                {
                    mensaje[1] = "Problemas Insertando Registro";
                    mensaje[2] = "El BIN ya existe.";
                }
                else if (nAccion == 2) //Eliminar
                {
                    mensaje[1] = "Problemas Eliminando Registro";
                    mensaje[2] = "El BIN no existe.";
                }
            }
            else
                if (numeroMensaje.Equals(2))
                {
                    mensaje[0] = "1";
                    if (nAccion == 1) //Insertar
                    {
                        mensaje[1] = "Problemas Insertando Registro";
                        mensaje[2] = "El BIN no se insertó correctamente.";
                    }
                    else if (nAccion == 2) //Eliminar
                    {
                        mensaje[1] = "Problemas Eliminando Registro";
                        mensaje[2] = "El BIN no eliminó correctamente.";
                    }
                }



        return mensaje;

    }/*fin del método MostrarMensaje*/
    #endregion
}
