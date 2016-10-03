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

using BCR.GARANTIAS.Comun;
using BCRGARANTIAS.Negocios;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Forms
{
    public partial class frmMantenimientoTipoPolizaSugef : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Constantes

        private const string LLAVE_CODIGO_CATALOGO = "LLAVE_CODIGO_CATALOGO";
        private const string LLAVE_CONSECUTIVO_SIGUIENTE = "LLAVE_CONSECUTIVO_SIGUIENTE";
        private const string LLAVE_REGISTRO_CONSULTADO = "LLAVE_REGISTRO_CONSULTADO";

        #endregion Constantes

        #region Variables Globales

        private int nCatalogo;
        private int codigoSiguiente;
        private clsTipoPolizaSugef tipoPolizaSugefConsultada = new clsTipoPolizaSugef();

        #endregion

        #region Propiedades

        /// <summary>
        /// Se almacena y se obtiene el código del catálogo que se está manipulando
        /// </summary>
        public int CodigoCatalogo
        {
            get
            {

                if ((ViewState[LLAVE_CODIGO_CATALOGO] != null) && (ViewState[LLAVE_CODIGO_CATALOGO].ToString().Trim().Length > 0))
                {
                    return ((int.TryParse(ViewState[LLAVE_CODIGO_CATALOGO].ToString(), out nCatalogo)) ? nCatalogo : -1);
                }
                else
                {
                    return -1;
                }
            }

            set
            {
                ViewState.Add(LLAVE_CODIGO_CATALOGO, value.ToString());
            }
        }

        /// <summary>
        /// Se almacena y se obtiene el consecutivo del registro que se desee insertar
        /// </summary>
        public int ConsecutivoSiguiente
        {
            get
            {

                if ((ViewState[LLAVE_CONSECUTIVO_SIGUIENTE] != null) && (ViewState[LLAVE_CONSECUTIVO_SIGUIENTE].ToString().Trim().Length > 0))
                {
                    return ((int.TryParse(ViewState[LLAVE_CONSECUTIVO_SIGUIENTE].ToString(), out codigoSiguiente)) ? codigoSiguiente : -1);
                }
                else
                {
                    return -1;
                }
            }

            set
            {
                ViewState.Add(LLAVE_CONSECUTIVO_SIGUIENTE, value.ToString());
            }
        }

        /// <summary>
        /// Se almacena y se obtiene la entidad del registro consultado inicialmente
        /// </summary>
        public clsTipoPolizaSugef RegistroInicialConsultado
        {
            get
            {

                if (ViewState[LLAVE_REGISTRO_CONSULTADO] != null)
                {
                    return ((clsTipoPolizaSugef)ViewState[LLAVE_REGISTRO_CONSULTADO]);
                }
                else
                {
                    return new clsTipoPolizaSugef();
                }
            }

            set
            {
                ViewState.Add(LLAVE_REGISTRO_CONSULTADO, value);
            }
        }
        #endregion Porpiedades

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnInsertar.Click += new EventHandler(btnInsertar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnRegresar.Click += new EventHandler(btnRegresar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el campo seleccionado?')";
            btnModificar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea modificar el campo seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_MANT_CATALOGOS"].ToString())))
                    {
                        CodigoCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
                        lblCatalogo.Text = "Catálogo de " + Request.QueryString["strCatalogo"].ToString();
                        
                        txtCodigo.Attributes.Add("onkeypress", "javascript:return numbersonly(event);");

                        CargarGrid();
                        btnModificar.Enabled = false;
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
                    Gestor.CrearTipoPolizaSugef(int.Parse(txtCodigo.Text), txtDescripcion.Text, txtDetalle.Text,
                                                Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El campo del catálogo se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
            catch (ExcepcionBase ex)
            {
                Response.Redirect("frmMensaje.aspx?" +
                                "bError=1" +
                                "&strTitulo=" + "Problemas Insertando Registro" +
                                "&strMensaje=" + ex.Message + "\r" +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());

            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                 { 

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Insertando Registro" +
                                        "&strMensaje=" + "No se pudo insertar el campo del catálogo." + "\r" +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
          
                }

            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                txtCodigo.Text = ((ConsecutivoSiguiente != -1) ? ConsecutivoSiguiente.ToString() : string.Empty);
                txtDescripcion.Text = string.Empty;
                txtDetalle.Text = string.Empty;
                btnInsertar.Enabled = true;
                btnModificar.Enabled = false;
                btnEliminar.Enabled = false;
                lblMensaje.Text = string.Empty;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            clsTipoPolizaSugef tipoPolizaSugef = new clsTipoPolizaSugef();

            try
            {
                if (ValidarDatos())
                {
                    tipoPolizaSugef.TipoPolizaSugef = int.Parse(txtCodigo.Text);
                    tipoPolizaSugef.NombreTipoPolizaSugef = txtDescripcion.Text;
                    tipoPolizaSugef.DescripcionTipoPolizaSugef = txtDetalle.Text;

                    Gestor.ModificarTipoPolizaSugef(tipoPolizaSugef, RegistroInicialConsultado, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=0" +
                        "&strTitulo=" + "Modificación Exitosa" +
                        "&strMensaje=" + "El campo del catálogo se modificó satisfactoriamente." +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Modificando Registro" +
                        "&strMensaje=" + "No se pudo modificar la información del campo del catálogo." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
        }

        private void btnRegresar_Click(object sender, System.EventArgs e)
        {
            Response.Redirect("frmCatalogos.aspx");
        }

        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            clsTipoPolizaSugef tipoPolizaSugef = new clsTipoPolizaSugef();

            try
            {
                tipoPolizaSugef.TipoPolizaSugef = int.Parse(txtCodigo.Text);
                tipoPolizaSugef.NombreTipoPolizaSugef = txtDescripcion.Text;
                tipoPolizaSugef.DescripcionTipoPolizaSugef = txtDetalle.Text;

                Gestor.EliminarTipoPolizaSugef(tipoPolizaSugef, Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                Response.Redirect("frmMensaje.aspx?" +
                    "bError=0" +
                    "&strTitulo=" + "Eliminación Exitosa" +
                    "&strMensaje=" + "El campo del catálogo se eliminó satisfactoriamente." +
                    "&bBotonVisible=1" +
                    "&strTextoBoton=Regresar" +
                    "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                        "bError=1" +
                        "&strTitulo=" + "Problemas Eliminando Registro" +
                        "&strMensaje=" + "No se pudo eliminar el campo del catálogo." + "\r" +
                        "&bBotonVisible=1" +
                        "&strTextoBoton=Regresar" +
                        "&strHref=frmMantenimientoTipoPolizaSugef.aspx?nCatalogo=" + int.Parse(Request.QueryString["nCatalogo"].ToString()) + "|strCatalogo=" + Request.QueryString["strCatalogo"].ToString());
                }
            }
        }

        #endregion

        #region Métodos GridView

        protected void gdvCatalogos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvCatalogos = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedCatalogo"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvCatalogos.SelectedIndex = rowIndex;

                        try
                        {
                            if (gdvCatalogos.SelectedDataKey[0].ToString() != null)
                                txtCodigo.Text = gdvCatalogos.SelectedDataKey[0].ToString();
                            else
                                txtCodigo.Text = string.Empty;

                            if (gdvCatalogos.SelectedDataKey[1].ToString() != null)
                                txtDescripcion.Text = gdvCatalogos.SelectedDataKey[1].ToString().Trim();
                            else
                                txtDescripcion.Text = string.Empty;

                            if (gdvCatalogos.SelectedDataKey[2].ToString() != null)
                                txtDetalle.Text = gdvCatalogos.SelectedDataKey[2].ToString();
                            else
                                txtDetalle.Text = string.Empty;

                            btnInsertar.Enabled = false;
                            btnModificar.Enabled = true;
                            btnEliminar.Enabled = true;

                            tipoPolizaSugefConsultada = new clsTipoPolizaSugef();

                            tipoPolizaSugefConsultada.TipoPolizaSugef = int.Parse(txtCodigo.Text);
                            tipoPolizaSugefConsultada.NombreTipoPolizaSugef = txtDescripcion.Text;
                            tipoPolizaSugefConsultada.DescripcionTipoPolizaSugef = txtDetalle.Text;

                            RegistroInicialConsultado = tipoPolizaSugefConsultada;
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

        protected void gdvCatalogos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvCatalogos.SelectedIndex = -1;
            this.gdvCatalogos.PageIndex = e.NewPageIndex;

            if (CodigoCatalogo <= 0)
            {
                CodigoCatalogo = int.Parse(Request.QueryString["nCatalogo"].ToString());
            }

            CargarGrid();
        }

        #endregion

        #region Métodos Privados
        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            clsTiposPolizasSugef<clsTipoPolizaSugef> listaTiposPolizasSugef = new clsTiposPolizasSugef<clsTipoPolizaSugef>();
            int consecutivo;

            try
            {

                listaTiposPolizasSugef = Gestor.ObtenerTiposPolizasSugef(null, false, out consecutivo);

                if (listaTiposPolizasSugef.Count > 0)
                {
                    txtCodigo.Text = ((consecutivo != -1) ? consecutivo.ToString() : string.Empty);
                    ConsecutivoSiguiente = consecutivo;

                    this.gdvCatalogos.DataSource = listaTiposPolizasSugef;
                    this.gdvCatalogos.DataBind();
                }
                else
                {
                    if (listaTiposPolizasSugef.ErrorDatos)
                    {
                        lblMensaje.Text = listaTiposPolizasSugef.DescripcionError;
                    }

                    this.gdvCatalogos.DataSource = null;
                    this.gdvCatalogos.DataBind();
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
                if (bRespuesta && txtCodigo.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código del campo.";
                    bRespuesta = false;
                }
                if (bRespuesta && txtDescripcion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar la descripción del campo.";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }
        #endregion
    }
}