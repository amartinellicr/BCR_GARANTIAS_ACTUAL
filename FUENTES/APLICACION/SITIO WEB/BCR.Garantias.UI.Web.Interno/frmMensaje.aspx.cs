using System;


namespace BCRGARANTIAS.Presentacion
{
    public partial class frmMensaje : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;
        private string _strEvento = "";

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            cmdAccion.Click +=new EventHandler(cmdAccion_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string rutaImagen = ObtenerImagen();
                string textoMostrar = Request.QueryString["strMensaje"].ToString();

               // string contenidoLabel = string.Format("<img src=\"{0}\"> {1}", rutaImagen, textoMostrar);

                // <img src = "<%=ObtenerImagen()%>">
                lblTitulo.Text = Request.QueryString["strTitulo"].ToString();
                lblMensajeMostrar.Text = textoMostrar;//  Request.QueryString["strMensaje"].ToString();
                //valida si se hace uso del boton o no
                if (Request.QueryString["bBotonVisible"].ToString() == "1")
                {
                    cmdAccion.Visible = true;
                    cmdAccion.Text = Request.QueryString["strTextoBoton"].ToString();
                    _strEvento = "if(window.event.keyCode==13){document.frmMensaje.cmdAccion.click();return false}";
                }
                else
                {
                    _strEvento = "";
                    cmdAccion.Visible = false;
                }
            }
        }

        /// <summary>
        /// evento programado para determinar la accion del boton
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmdAccion_Click(object sender, System.EventArgs e)
        {
            string strDireccion = Request.QueryString["strHref"].ToString().Replace("|", "&");
            strDireccion += ((Request.QueryString["nOperacion"] != null) ? ("&nOperacion=" + Request.QueryString["nOperacion"].ToString()) : string.Empty);
            strDireccion += ((Request.QueryString["DatosGenerales"] != null) ? ("&DatosGenerales=" + Request.QueryString["DatosGenerales"].ToString()) : string.Empty);

            Response.Redirect(strDireccion, true);
        }//cmdAccion_Click

        #endregion

        #region Métodos Privados

        /// <summary>
        /// funcion que se encarga de obtner la imagen que se cargará en la pantalla
        /// </summary>
        /// <returns>string con la direccion de la imagen</returns>
        public string ObtenerImagen()
        {
            if (Request.QueryString["bError"].ToString() == "1")
                //es un caso de error
                return "Images/Error.ICO";
            else
                //es un caso de exito
                return "Images/CheckOK.ICO";
        }//ObtenerImagen

        public string ObtenerMensaje()
        {
            if (Request.QueryString["strMensaje"].ToString().Length > 0)
                //es un caso de error
                return Request.QueryString["strMensaje"].ToString();
            else
                //es un caso de exito
                return string.Empty;
        }//ObtenerImagen

        /// <summary>
        /// Función que indica si se debe ejecutar el evento del
        /// formulario en el momento que se presiona la tecla enter
        /// </summary>
        /// <returns>String con el código del evento</returns>
        public int EjecutaEvento()
        {
            if (_strEvento.Length > 0)
                return 1;
            else
                return 0;

        }//ObtenerEvento

        #endregion
    }
}
