using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Configuration;
using System.Data.OleDb;
using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;
using BCRGarantias.Contenedores;
using ProcesamientoMQ2003;



namespace BCRGARANTIAS.Forms
{
    public partial class frmGarantiasporPerfil : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        //protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        //protected System.Web.UI.WebControls.DropDownList cbTipoEmpresa;
        //protected System.Web.UI.WebControls.TextBox txtEmpresa;
        //protected System.Web.UI.WebControls.DropDownList cbMoneda;
        //protected System.Web.UI.WebControls.DropDownList cbLiquidez;
        //protected System.Web.UI.WebControls.DropDownList cbRecomendacion;
        //protected System.Web.UI.WebControls.DropDownList cbInspecci�n;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnModificar.Click += new EventHandler(btnModificar_Click);
            btnLimpiar.Click += new EventHandler(btnLimpiar_Click);
            btnEliminar.Click += new EventHandler(btnEliminar_Click);
            btnValidarTarjeta.Click += new EventHandler(btnValidarTarjeta_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnModificar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea modificar la garant�a seleccionada?')";
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('�Est� seguro que desea eliminar la garant�a seleccionada?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIA_X_PERFIL"].ToString())))
                    {
                        LimpiarCampos();

                        if (Session["ValidarTarjeta"] != null)
                        {
                            txtTarjeta.Text = Session["ValidarTarjeta"].ToString().Trim();
                            this.btnValidarTarjeta_Click(this.btnValidarTarjeta, new EventArgs());
                            Session.Remove("ValidarTarjeta");
                        }

                    }
                    else
                    {
                        //El usuario no tiene acceso a esta p�gina
                        throw new Exception("ACCESO DENEGADO");
                    }

                }
                catch (Exception ex)
                {
                    if (ex.Message.StartsWith("ACCESO DENEGADO"))
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Acceso Denegado" +
                                        "&strMensaje=" + "El usuario no posee permisos de acceso a esta p�gina." +
                                        "&bBotonVisible=0");
                    else
                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=1" +
                                        "&strTitulo=" + "Problemas Cargando P�gina" +
                                        "&strMensaje=" + ex.Message +
                                        "&bBotonVisible=0");
                }


               
            }
        }

        /// <summary>
        /// Este evento permite limpiar el formulario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
                LimpiarCampos();
                ddlTipoGarantiaPorPerfil.SelectedValue = string.Empty;
        }

        /// <summary>
        /// Este evento permite modificar la informaci�n de una garant�a fiduciaria
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnModificar_Click(object sender, System.EventArgs e)
        {
            try
            {
                  if (ValidarGarantiaTarjeta())
                   {
                       if (ddlTipoGarantiaPorPerfil.SelectedValue.ToString().Equals(string.Empty))
                       {
                           lblMensaje3.Text = "Seleccione un tipo de garant�a por perfil.";
                           lblMensaje.Visible = true;
                           return;
                       }/*fin del if (ddlTipoGarantiaPorPerfil.SelectedValue.ToString().Equals(string.Empty))*/
                       else
                       {
                           Session["Accion"] = "MODIFICAR";

                           string codigoGarantia = "";// ddlTipoGarant�aPorPerfil.SelectedValue.ToString();

                           int mensaje = AsignarGarantiaTarjeta(codigoGarantia);

                           GuardarDatosSession();

                           string[] mensajes = MostrarMensaje(mensaje);

                           Response.Redirect("frmMensaje.aspx?" +
                                           "bError=" + mensajes[0] +
                                           "&strTitulo=" + mensajes[2] +
                                           "&strMensaje=" + mensajes[1] +
                                           "&bBotonVisible=1" +
                                           "&strTextoBoton=Regresar" +
                                           "&strHref=frmGarantiasporPerfil.aspx");

                       }/*fin del if/else */

                    }/*fin del if (ValidarGarantiaTarjeta())*/

                    btnModificar.Enabled = false;
                    btnLimpiar.Enabled = false;
               
            }/*fin del try*/
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la informaci�n de la garant�a por perfil. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasporPerfil.aspx");
                }
            }

        }/*fin del m�todo btnModificar_Click*/

        /// <summary>
        /// Este evento permite modificar la informaci�n a una garant�a fiduciaria
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEliminar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarGarantiaTarjeta())
                {
                    Session["Accion"] = "ELIMINAR";

                    int mensaje = AsignarGarantiaTarjeta("01");

                    GuardarDatosSession();

                    string[] mensajes = MostrarMensajeEliminar(mensaje);

                    Session["Tipo_Operacion"] = 3;
                    Session["ValidarTarjeta"] = txtTarjeta.Text;

                    Response.Redirect("frmMensaje.aspx?" +
                                        "bError=" + mensajes[0] +
                                        "&strTitulo=" + mensajes[1] +
                                        "&strMensaje=" + mensajes[2] +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=" + mensajes[3] +
                                        "&strHref=" + mensajes[4]);
                }

                btnModificar.Enabled = false;
                btnLimpiar.Enabled = false;

            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Modificando Registro" +
                                    "&strMensaje=" + "No se pudo modificar la informaci�n de la garant�a por perfil. " + "\r" + ex.Message +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmGarantiasporPerfil.aspx");
                }
            }

        }/*fin del m�todo btnModificar_Click*/

        private string[] MostrarMensajeEliminar(int numeroMensaje)
        {
            string[] mensaje = { string.Empty, string.Empty, string.Empty, string.Empty, string.Empty };

            if (numeroMensaje.Equals(0))
            {
                mensaje[0] = "1";
                mensaje[1] = "Problema Eliminando Garant�a";
                mensaje[2] = "Error al intentar eliminar la garant�a por perfil de la tarjeta";
                mensaje[3] = "Regresar";
                mensaje[4] = "frmGarantiasporPerfil.aspx";
            }
            else
            {
                mensaje[0] = "0";
                mensaje[1] = "Eliminaci�n Existosa";
                mensaje[2] = "Se ha eliminado satisfactoriamente la grant�a por perfil, favor ingrese la garant�a fiduciaria";
                mensaje[3] = "Ingresar Garant�a Fiduciaria";
                mensaje[4] = "frmGarantiasFiduciaria.aspx";
            }

            return mensaje;
        }/*fin del m�todo MostrarMensajeEliminar*/

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnValidarTarjeta_Click(object sender, System.EventArgs e)
        {
            string strTrama = string.Empty;
            string strTramaRespuesta;
            DataSet ds = new DataSet();
            string strArchivoXMLTemporal;
            lblMensaje.Text = String.Empty;

            string strCodigoEstadoTarjeta = string.Empty;

            #region Obtiene el nombre de los nodos del web.config

            string nodoSistar = ConfigurationManager.AppSettings["nodoSistar"].ToString();
            string nodoCabecera = ConfigurationManager.AppSettings["nodoCabecera"].ToString();
            string nodoRespuesta = ConfigurationManager.AppSettings["nodoRespuesta"].ToString();
            string nodoTrans = ConfigurationManager.AppSettings["nodoTransaccion"].ToString();
            string nodoTipoTarjeta = ConfigurationManager.AppSettings["nodoTipoTarjeta"].ToString();
            string nodoCedula = ConfigurationManager.AppSettings["nodoCedula"].ToString();
            string nodoCuentaAfectada = ConfigurationManager.AppSettings["nodoCuentaAfectada"].ToString();
            string nodoMoneda = ConfigurationManager.AppSettings["nodoMoneda"].ToString();
            string nodoOficinaOrigen = ConfigurationManager.AppSettings["nodoOficinaOrigen"].ToString();
            string nodoDescripcion = ConfigurationManager.AppSettings["nodoDescripcion"].ToString();
            string nodoTipoGarantia = ConfigurationManager.AppSettings["nodoTipoGarantia"].ToString();
            string nodoEstadoTarjeta = ConfigurationManager.AppSettings["nodoEstadoTarjeta"].ToString();

            #endregion

            try
            {
                Session["Tipo_Operacion"] = "3";

                LimpiarCampos();

                if (ValidarFormatoTarjeta())
                {
                    decimal nBin = Convert.ToDecimal(txtTarjeta.Text.Substring(0, 6));

                    if (Gestor.Verifica_Tarjeta_Sistar(nBin))
                    {
                        strTrama = new BCRGARANTIAS.Negocios.CreaXML().creaXMLConsultaTarjetaSISTAR(txtTarjeta.Text, string.Empty);

						ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
																										Application["Cola_Entrada"].ToString(),
																										Application["Cola_Salida"].ToString(),
																										strTrama,
																										Application["Cola_Respuesta"].ToString(),
																										Application["IP"].ToString(),
																										Application["Channel"].ToString(),
																										Application["Port"].ToString());

						strTramaRespuesta = oMQ.respuestaMQ();

                        strArchivoXMLTemporal = Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\" + txtTarjeta.Text.Trim() + ".xml";

                        if (!Directory.Exists(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\"))
                        {
                            Directory.CreateDirectory(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\");
                        }

                        CrearArchivoXMLTemporal(strArchivoXMLTemporal, strTramaRespuesta);
                        ds.ReadXml(strArchivoXMLTemporal);

                        //Valida que la respuesta de MQ fuera "TRANSACCION SATISFACTORIA"
                        if (ds.Tables[nodoCabecera].Rows[0][nodoRespuesta].ToString() == "000")
                        {
                            //Tarjeta d�bito/cr�dito VISA
                            if ((ds.Tables[nodoSistar].Rows[0][nodoTrans].ToString() == "1") ||
                                    (ds.Tables[nodoSistar].Rows[0][nodoTipoTarjeta].ToString() == "D"))
                            {
                                Session["EsOperacionValida"] = false;
                                Session["Nombre_Deudor"] = "";
                                lblMensaje.Text = "BCR-GARANTIAS solamente procesa tarjetas de cr�dito MASTERCARD";
                                lblDeudor.Text = "";
                                lblNombreDeudor.Text = "";
                            }
                            //Valida que la tarjeta fuera d�bito/cr�dito MARTERCARD
                            else if (ds.Tables[nodoSistar].Rows[0][nodoTrans].ToString() == "2")
                            {
                                lblNombreDeudor.Text = ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString();
                                string strDeudor = Gestor.ObtenerNombreDeudor(ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString());
                                lblNombreDeudor.Text = lblNombreDeudor.Text + " - " + strDeudor.Trim();
                                lblNombreDeudor.Visible = true;

                                CargarGarantiasPerfil();

                                //BloquearCampos(true);
                                Session["Tarjeta"] = txtTarjeta.Text.Trim();
                                Session["Deudor"] = ds.Tables[nodoSistar].Rows[0][nodoCedula].ToString();
                                Session["Bin"] = ds.Tables[nodoSistar].Rows[0][nodoCuentaAfectada].ToString().Substring(0, 6);
                                Session["CodigoInternoSISTAR"] = ds.Tables[nodoSistar].Rows[0][nodoCuentaAfectada].ToString().Substring(6);

                                if (ds.Tables[nodoSistar].Rows[0][nodoMoneda].ToString().Trim() == "188")
                                    Session["Moneda"] = "1";
                                else if (ds.Tables[nodoSistar].Rows[0][nodoMoneda].ToString().Trim() == "840")
                                    Session["Moneda"] = "2";

                                Session["Oficina_Registra"] = ds.Tables[nodoSistar].Rows[0][nodoOficinaOrigen].ToString().Trim();

                                if ((ds.Tables[nodoSistar].Columns.Contains(nodoTipoGarantia)) 
                                   && (!ds.Tables[nodoSistar].Rows[0].IsNull(nodoTipoGarantia)) 
                                   && (ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString() != string.Empty))
                                {
                                    Session["Plazo"] = ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString().Trim();
                                    Session["Codigo_Garantia"] = ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString().Trim();

                                    int nCodigoTipoGarantiaObt = Convert.ToInt32(ds.Tables[nodoSistar].Rows[0][nodoTipoGarantia].ToString());

									if (!Gestor.CodigoTipoTarjetaEsPerfil(nCodigoTipoGarantiaObt))
									{
										if (nCodigoTipoGarantiaObt == 1)
										{
											Session["Accion"] = "INSERTAR";
											Session["Tipo_Operacion"] = "3";
											Session["ValidarTarjeta"] = txtTarjeta.Text;
											Session["EsOperacionValida"] = "True";
											lblMensaje.Text = "Esta tarjeta posee una <a href=frmGarantiasFiduciaria.aspx>Garant�a Fiduciaria<a>";
											BloquearTodosCampos(false);
										}
										else
										{
											if (ddlTipoGarantiaPorPerfil.SelectedValue.Trim().Length == 0)
											{
												string strCodigoGar = nCodigoTipoGarantiaObt.ToString().Trim().PadLeft(2, '0');

												if(ddlTipoGarantiaPorPerfil.Items.FindByValue(strCodigoGar) != null)
												{
													ddlTipoGarantiaPorPerfil.SelectedValue = strCodigoGar;
												}
											}
										}
									}
									else
									{
										if (ddlTipoGarantiaPorPerfil.SelectedValue.Trim().Length == 0)
										{
											string strCodigoGar = nCodigoTipoGarantiaObt.ToString().Trim().PadLeft(2, '0');

											if (ddlTipoGarantiaPorPerfil.Items.FindByValue(strCodigoGar) != null)
											{
												ddlTipoGarantiaPorPerfil.SelectedValue = strCodigoGar;
											}
										}
									}
									
                                }

                                strCodigoEstadoTarjeta = ds.Tables[nodoSistar].Rows[0][nodoEstadoTarjeta].ToString().Trim();

                                if (strCodigoEstadoTarjeta != string.Empty)
                                {
                                    ActualizarEstadoTarjeta(strCodigoEstadoTarjeta);
                                }
                                
                                

                                Session["Nombre_Deudor"] = lblNombreDeudor.Text;
                                Session["EsOperacionValida"] = true;
                                GuardarDatosSession();

                                ddlTipoGarantiaPorPerfil.Enabled = true;
                                txtObservaciones.Enabled = true;
                                btnLimpiar.Enabled = true;
                                btnModificar.Enabled = true;
                                lblNombreDeudor.Visible = true;
                                lblDeudor.Visible = true;
                            }

                        }/*fin del if (ds.Tables["HEADER"].Rows[0]["CODIGORESPUESTA"].ToString() == "000")*/
                        //Transacci�n no satisfactoria
                        else
                        {
                            Session["EsOperacionValida"] = false;
                            Session["Nombre_Deudor"] = "";
                            lblMensaje.Text = ds.Tables[nodoCabecera].Rows[0][nodoDescripcion].ToString();
                            lblDeudor.Text = "";
                            lblNombreDeudor.Text = "";

                        }
                        EliminarArchivoXMLTemporal(strArchivoXMLTemporal);
                    }
                    else
                    {
                        lblMensaje.Text = "La tarjeta que se requiere validar en SISTAR no es de cr�dito o no se encuentra en SISTAR";
                    }
                }
            }
            catch (Exception ex)
            {
                if ((ex.Message.StartsWith("Referencia a objeto no establecida"))
                   || (ex.Message.StartsWith("Object reference not set to an instance of an object.")))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando P�gina" +
                                    "&strMensaje=" + "No hay comunicaci�n con el sistema SISTAR" +
                                    "&bBotonVisible=0");
                }
                else if (ex.Message.Contains("CODIGORESPUESTA")) 
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                   "bError=1" +
                                   "&strTitulo=" + "Problemas Cargando P�gina" +
                                   "&strMensaje=" + "No hay comunicaci�n con el sistema utilizado para obtener la informaci�n de la tarjeta (Sistema MQ)" +
                                   "&bBotonVisible=0");
                }
                else
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando P�gina" +
                                    "&strMensaje=" + ex.Message +
                                    "&bBotonVisible=0");
                }
            }
        }

        #endregion

        #region M�todos Privados

        private bool ValidarGarantiaTarjeta()
        {
            bool bRespuesta = true;

            try
            {
                lblMensaje.Text = "";
                lblMensaje3.Text = "";

                if (bRespuesta && txtTarjeta.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el n�mero de tarjeta";
                    bRespuesta = false;
                }
                //Valida los datos del fiador

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }

            return bRespuesta;
        }

        private bool ValidarFormatoTarjeta()
        {
            bool bRespuesta = true;

            lblMensaje.Text = "";

            if (bRespuesta && txtTarjeta.Text.Trim().Length == 0)
            {
                lblMensaje.Text = "Debe ingresar el n�mero de tarjeta que desea validar";
                bRespuesta = false;
            }

            if (bRespuesta && txtTarjeta.Text.Trim().Length != 16)
            {
                lblMensaje.Text = "Largo del n�mero de tarjeta inv�lido";
                bRespuesta = false;
            }

            return bRespuesta;
        }

        private void CrearArchivoXMLTemporal(string strArchivo, string strXML)
        {
            try
            {
                StreamWriter writer = File.CreateText(strArchivo);
                writer.WriteLine(strXML);
                writer.Close();
            }
            catch(Exception ex)
            {
                ex.ToString();
            }
        }

        private void EliminarArchivoXMLTemporal(string strArchivo)
        {
            File.Delete(strArchivo);
        }

        private void GuardarDatosSession()
        {
            try
            {
                CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

                //Campos llave
                    oGarantia.Tarjeta = txtTarjeta.Text.Trim();
                

                oGarantia.TipoOperacion = int.Parse("3");
                oGarantia.ClaseGarantia = int.Parse(Application["CLASE_GARANTIA_FIADOR"].ToString());
                //Informacion del fiador

                oGarantia.MontoMitigador = 0;
                oGarantia.PorcentajeResposabilidad = 0;
                oGarantia.MontoCobertura = 0;
                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        /// <summary>
        /// Metodo que carga la informaci�n de la garantia que se encuentra almacenada en el objeto Session.
        /// </summary>
        private void CargarDatosSession()
        {
            try
            {
                CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

                //Campos llave
                
                txtTarjeta.Text = oGarantia.Tarjeta;

                oGarantia = null;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #region Manejo de los mensajes a mostrar

        /// <summary>
        /// Maneja los mensajes que se deben mostrar de acuerdo al n�mero retornado por la transacci�n
        /// </summary>
        /// <param name="numeroMensaje">
        /// N�mero de mensaje que se debe mostrar
        /// </param>
        /// <returns>
        /// Arreglo de strings con los mensajes a mostrar
        /// </returns>
        private string[] MostrarMensaje(int numeroMensaje)
        {
            string[] mensaje = { string.Empty, string.Empty, string.Empty };

            if (numeroMensaje.Equals(0))
            {
                mensaje[0] = "1";
                mensaje[1] = "Se produjo un error al modificar la informaci�n de la garant�a,\rverifique los datos ingresados";
                mensaje[2] = "Problemas Modificando Registro";
            }
            else
                if (numeroMensaje.Equals(1))
                {
                    mensaje[0] = "0";
                    mensaje[1] = "La tarjeta no exist�a en BCR-Grant�as, se realiz� el registro satisfactoriamente";
                    mensaje[2] = "Inserci�n - Registro no exist�a";
                }
                else
                    if (numeroMensaje.Equals(2))
                    {
                        mensaje[0] = "0";
                        mensaje[1] = "La informaci�n de la garant�a por perfil se ingres� correctamente";
                        mensaje[2] = "Inserci�n Exitosa";
                    }
                    else
                        if (numeroMensaje.Equals(3))
                        {
                            mensaje[0] = "0";
                            mensaje[1] = "La informaci�n de la garant�a por perfil se modific� correctamente";
                            mensaje[2] = "Modificaci�n Exitosa";
                        }
                        else
                            if (numeroMensaje.Equals(4))
                            {
                                mensaje[0] = "0";
                                mensaje[1] = "Se modific� satisfactoriamente el tipo de garant�a a fiduciria";
                                mensaje[2] = "Modificaci�n Exitosa";
                            }

            return mensaje;

        }/*fin del m�todo MostrarMensaje*/

        #endregion Manejo de los mensajes a mostrar

        /// <summary>
        /// Este m�todo permite limpiar los campos del formulario
        /// </summary>
        private void LimpiarCampos()
        {
            try
            {
                btnEliminar.Visible = false;
                btnLimpiar.Enabled = false;
                btnModificar.Enabled = false;
                ddlTipoGarantiaPorPerfil.Enabled = false; 
                txtObservaciones.Enabled = false;
                lblDeudor.Visible = false;
                lblNombreDeudor.Visible = false;
                lblMensaje.Text = String.Empty;
                lblMensaje3.Text = String.Empty;
                txtObservaciones.Text = String.Empty;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #region M�todos de MQ

        /// <summary>
        /// Este m�todo procesa la respuesta enviada por MQ
        /// </summary>
        /// <param name="strXML">XML de respuesta</param>
        private void ProcesarRespuestaMQ(string strXML)
        {
            try
            {
                //Carga el XML en un archivo 
                StreamWriter writer = File.CreateText(Application["ARCHIVOS"].ToString() + "TMPXML.xml");
                writer.WriteLine(strXML);
                writer.Close();

                XmlDocument xDoc = new XmlDocument();
                xDoc.Load(Application["ARCHIVOS"].ToString() + "TMPXML.xml");

                XmlNodeList oEvento = xDoc.GetElementsByTagName("TRAMAXML");

                //Valida que la transacci�n se haya procesado
                if (ValidarRespuestaMQ(oEvento))
                {
                    XmlNodeList oElementos = ((XmlElement)oEvento[0]).GetElementsByTagName(Application["PRC18"].ToString());

                    int i = 0;
                    XmlNodeList ndElemento;
                    if (oElementos.Count > 0)
                    {
                        foreach (XmlElement nodo in oElementos)
                        {
                            //Obtiene el n�mero de c�dula del deudor de la operaci�n
                            XmlNodeList ndCliente = nodo.GetElementsByTagName("NUMERO");

                            if (ndCliente[i] != null)
                                Session["Deudor"] = long.Parse(ndCliente[i].InnerText).ToString();

                            
                            btnModificar.Enabled = false;
                            Session["EsOperacionValida"] = true;
                            GuardarDatosSession();

                            //Carga las garantias fiduciarias en el Grid
                            ndElemento = nodo.GetElementsByTagName("CLAGAR");
                            if (ndElemento[i] != null)
                            {
                                if (ndElemento[i].InnerText == "00")
                                {
                                }
                            }
                        }
                    }
                    else
                    {
                        Session["EsOperacionValida"] = false;
                        if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                            lblMensaje.Text = "La operaci�n crediticia no existe en el sistema.";
                        else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                            lblMensaje.Text = "El contrato no existe en el sistema.";
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Este m�todo permite validar el c�digo de respuesta enviado por MQ
        /// </summary>
        /// <param name="oEvento"></param>
        /// <returns></returns>
        private bool ValidarRespuestaMQ(XmlNodeList oEvento)
        {
            bool bRespuesta = false;
            try
            {
                XmlNodeList oElementos = ((XmlElement)oEvento[0]).GetElementsByTagName("HEADER");
                if (oElementos.Count > 0)
                {
                    foreach (XmlElement nodo in oElementos)
                    {
                        //Obtiene el c�digo de respuesta del MQ
                        XmlNodeList ndRespuesta = nodo.GetElementsByTagName("CODIGORESPUESTA");
                        XmlNodeList ndDescripcion = nodo.GetElementsByTagName("DESCRIPCION");

                        if (ndRespuesta[0] != null)
                            if (int.Parse(ndRespuesta[0].InnerText) == int.Parse(Application["TRANSACCION_PROCESADA"].ToString()))
                                bRespuesta = true;
                            else
                                lblMensaje.Text = "Error: " + ndDescripcion[0].InnerText;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            return bRespuesta;
        }

        #endregion M�todos de MQ

        #region M�todo CargarGarantiasPerfil: carga las garant�as por perfil

        /// <summary>
        /// Carga las Garant�as por perfil
        /// </summary>
        private void CargarGarantiasPerfil()
        {
            /*crea la conexi�n con la base de datos*/
            SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString());

            try
            {

                #region Consulta del tipo de garant�a en la base de datos

                SqlCommand _cmdCodigoGarantia = new SqlCommand("select t.cod_tipo_garantia, g.observaciones " +
                                                               "from dbo.TAR_TARJETA t " +
                                                               "left outer join dbo.TAR_GARANTIAS_X_PERFIL_X_TARJETA g " +
                                                               "on g.cod_tarjeta = t.cod_tarjeta " +
                                                               "where t.num_tarjeta = " + txtTarjeta.Text);

                /*se asigna la conexi�n*/
                _cmdCodigoGarantia.Connection = oConexion;

                /*indica al sqlCommand el tiempo que puede durar la ejecuci�n*/
                _cmdCodigoGarantia.CommandTimeout = 120;

                DataTable _dtInfoGarantia = new DataTable("Info_Garantia");

                #endregion Consulta del tipo de garant�a en la base de datos

                #region Consulta los tipo de garant�a por perfil

                SqlCommand oComando = null;

                oComando = new SqlCommand("pa_Consultar_Garantias_x_Perfil", oConexion);
                SqlDataAdapter oDataAdapter = new SqlDataAdapter();
                //declara las propiedades del comando
                oComando.CommandType = CommandType.StoredProcedure;
                oComando.CommandTimeout = 120;
                oComando.Parameters.AddWithValue("@codigo_catalogo", ConfigurationManager.AppSettings["CAT_TIPO_GARANTIA_TARJETA"].ToString());

                DataTable _dtDatos = new DataTable("Garantias_Perfil");

                #endregion Consulta los tipo de garant�a por perfil

                /*obtiene los tipo de garant�a pro perfil*/
                oDataAdapter.SelectCommand = _cmdCodigoGarantia;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(_dtInfoGarantia);

				string _codigoGrantia = (_dtInfoGarantia.Rows.Count <= 0) ? string.Empty : ((_dtInfoGarantia.Rows[0][0].ToString().Length == 1) ? (_dtInfoGarantia.Rows[0][0].ToString().PadLeft(2, '0')) : _dtInfoGarantia.Rows[0][0].ToString());

                /*obtiene los tipo de garant�a pro perfil*/
                oDataAdapter.SelectCommand = oComando;
                oDataAdapter.SelectCommand.Connection = oConexion;
                oDataAdapter.Fill(_dtDatos);

                ddlTipoGarantiaPorPerfil.DataSource = _dtDatos;
                ddlTipoGarantiaPorPerfil.DataTextField = "cat_descripcion";
                ddlTipoGarantiaPorPerfil.DataValueField = "cat_campo";
                ddlTipoGarantiaPorPerfil.DataBind();

                ListItem _campoVacio = new ListItem(string.Empty, string.Empty);
                ddlTipoGarantiaPorPerfil.Items.Add(_campoVacio);

                /*asigna al combo el tipo de garant�a por perfil que posee asignada la tarjeta*/
                if (!string.IsNullOrEmpty(_codigoGrantia) && _dtDatos.Select("cat_campo = '" + _codigoGrantia + "'").Length > 0)
                {
                    ddlTipoGarantiaPorPerfil.SelectedValue = _codigoGrantia;
                    txtObservaciones.Text = (_dtInfoGarantia.Rows[0][1] == null) ? string.Empty : _dtInfoGarantia.Rows[0][1].ToString();
                    //btnEliminar.Visible = true;
                }
                else
                    ddlTipoGarantiaPorPerfil.SelectedValue = string.Empty;

            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }

        }/*fin del m�todo CargarGarantiasPerfil*/

        #endregion M�todo CargarGarantiasPerfil: carga las garant�as por perfil

        #region M�todo AsignarGarantiaTarjeta: asigna la garant�a a la tarjeta

        /// <summary>
        /// Asigna el tipo de garant�a a la tarjeta
        /// </summary>
        private int AsignarGarantiaTarjeta(string _codigoGarantia)
        {
            if (string.IsNullOrEmpty(_codigoGarantia))
                _codigoGarantia = ddlTipoGarantiaPorPerfil.SelectedValue.ToString();

            #region Actualizaci�n del tipo de garant�a en SISTAR

            string strTrama = string.Empty;
            string strTramaRespuesta;
            DataSet ds = new DataSet();
            string strArchivoXMLTemporal;
            lblMensaje.Text = String.Empty;

            string strCodigoEstadoTarjeta = string.Empty;

            string nodoCabecera = ConfigurationManager.AppSettings["nodoCabecera"].ToString();
            string nodoRespuesta = ConfigurationManager.AppSettings["nodoRespuesta"].ToString();
            string nodoSistar = ConfigurationManager.AppSettings["nodoSistar"].ToString();

            try
            {
                Session["Tipo_Operacion"] = "2";

                strTrama = new BCRGARANTIAS.Negocios.CreaXML().creaXMLConsultaTarjetaSISTAR(Session["Tarjeta"].ToString(), _codigoGarantia);

                ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
                                                                                                Application["Cola_Entrada"].ToString(),
                                                                                                Application["Cola_Salida"].ToString(),
                                                                                                strTrama,
                                                                                                Application["Cola_Respuesta"].ToString(),
                                                                                                Application["IP"].ToString(),
                                                                                                Application["Channel"].ToString(),
                                                                                                Application["Port"].ToString());

                strTramaRespuesta = oMQ.respuestaMQ();

                strArchivoXMLTemporal = Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\" + Session["Tarjeta"].ToString().Trim() + ".xml";

                if (!Directory.Exists(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\"))
                {
                    Directory.CreateDirectory(Directory.GetParent(Assembly.GetExecutingAssembly().CodeBase.ToString().Replace("file:///", "")).ToString().Replace("\\bin", "") + "\\Temporales\\");
                }

                CrearArchivoXMLTemporal(strArchivoXMLTemporal, strTramaRespuesta);
                ds.ReadXml(strArchivoXMLTemporal);

            }
            catch (Exception ex)
            {
                if ((ex.Message.StartsWith("Referencia a objeto no establecida"))
                   || (ex.Message.StartsWith("Object reference not set to an instance of an object.")))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando P�gina" +
                                    "&strMensaje=" + "No hay comunicaci�n con el sistema SISTAR" +
                                    "&bBotonVisible=0");
                }
                else if (ex.Message.Contains("CODIGORESPUESTA"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                   "bError=1" +
                                   "&strTitulo=" + "Problemas Cargando P�gina" +
                                   "&strMensaje=" + "No hay comunicaci�n con el sistema utilizado para obtener la informaci�n de la tarjeta (Sistema MQ)" +
                                   "&bBotonVisible=0");
                }
                else
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Cargando P�gina" +
                                    "&strMensaje=" + ex.Message +
                                    "&bBotonVisible=0");
                }
            }


            #endregion Actualizaci�n del tipo de garant�a en SISTAR

            string strUsuario = Session["strUSER"].ToString();
            string strIP = Request.UserHostAddress.ToString();

            string[] _infoTarjeta = {Session["Deudor"].ToString(), Session["Bin"].ToString(), 
                Session["CodigoInternoSISTAR"].ToString(), Session["Moneda"].ToString(), 
                Session["Oficina_Registra"].ToString()};

            /*variable para almacenar el valor del mensaje que retorna el procedimiento almacenado*/
            int _mensaje = 0;

            _mensaje = Gestor.AsignarGarantiaTarjeta(Session["Tarjeta"].ToString(), _codigoGarantia, strUsuario, strIP, 
                txtObservaciones.Text, ds.Tables[nodoCabecera].Rows[0][nodoRespuesta].ToString(), _infoTarjeta);

            #region codigo comentado
            
            if (_mensaje.Equals(0))
            {
                #region Actualizaci�n del tipo de garant�a en SISTAR

                try
                {
                    Session["Tipo_Operacion"] = "2";

                    strTrama = new BCRGARANTIAS.Negocios.CreaXML().creaXMLConsultaTarjetaSISTAR(Session["Tarjeta"].ToString(), Session["Codigo_Garantia"].ToString());

                    ProcesamientoMQ2003.ProcesamientoMQ oMQ = new ProcesamientoMQ2003.ProcesamientoMQ(Application["Qmanager"].ToString(),
                                                                                                    Application["Cola_Entrada"].ToString(),
                                                                                                    Application["Cola_Salida"].ToString(),
                                                                                                    strTrama,
                                                                                                    Application["Cola_Respuesta"].ToString(),
                                                                                                    Application["IP"].ToString(),
                                                                                                    Application["Channel"].ToString(),
                                                                                                    Application["Port"].ToString());

                    strTramaRespuesta = oMQ.respuestaMQ();

                }
                catch (Exception ex)
                {

                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problema Asignar Garant�a" +
                                    "&strMensaje=" + "Se produjo un error en la signaci�n de la garant�a y la informaci�n pudo haber quedado inconsistente" +
                                    "&bBotonVisible=0");
                }


                #endregion Actualizaci�n del tipo de garant�a en SISTAR

            }

            #endregion codigo comentado

            return _mensaje;

        }/*fin del m�todo AsignarGarantiaTarjeta*/

        #endregion M�todo AsignarGarantiaTarjeta: asigna la garant�a a la tarjeta

        /// <summary>
        /// M�todo que permite actualizar el estado de la tarjeta
        /// </summary>
        /// <param name="strEstadoTarjeta"></param>
        private void ActualizarEstadoTarjeta(string strEstadoTarjeta)
        {
            string strEstadoActualTarjeta = Gestor.ObtenerEstadoTarjeta(txtTarjeta.Text.Trim());

            if (strEstadoActualTarjeta != string.Empty)
            {
                if (strEstadoActualTarjeta.CompareTo(strEstadoTarjeta) != 0)
                {
                    int nMensaje = Gestor.ActualizarEstadoTarjeta(txtTarjeta.Text.Trim(), strEstadoTarjeta, Convert.ToInt32(ddlTipoGarantiaPorPerfil.SelectedValue.ToString()));

                    if (nMensaje != 0)
                    {
                        string[] aMensajes = MostrarMensajeActualizarEstado(nMensaje);

                        Response.Redirect("frmMensaje.aspx?" +
                                        "bError=" + aMensajes[0] +
                                        "&strTitulo=" + aMensajes[1] +
                                        "&strMensaje=" + aMensajes[2] +
                                        "&bBotonVisible=1" +
                                        "&strTextoBoton=Regresar" +
                                        "&strHref=frmGarantiasFiduciaria.aspx");
                    }
                }
            }
        }

        /// <summary>
        /// Maneja los mensajes que se deben mostrar de acuerdo al n�mero retornado por la transacci�n
        /// </summary>
        /// <param name="numeroMensaje">
        /// N�mero de mensaje que se debe mostrar
        /// </param>
        /// <returns>
        /// Arreglo de strings con los mensajes a mostrar
        /// </returns>
        private string[] MostrarMensajeActualizarEstado(int numeroMensaje)
        {
            string[] mensaje = { string.Empty, string.Empty, string.Empty };

            if (numeroMensaje.Equals(1))
            {
                mensaje[0] = "1";
                mensaje[1] = "Problemas Modificando Registro";
                mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que la tarjeta no existe.";
            }
            else
                if (numeroMensaje.Equals(2))
                {
                    mensaje[0] = "1";
                    mensaje[1] = "Problemas Modificando Registro";
                    mensaje[2] = "El estado de la tarjeta no pudo ser modificado correctamente.";
                }
                else
                    if (numeroMensaje.Equals(3))
                    {
                        mensaje[0] = "1";
                        mensaje[1] = "Problemas Modificando Registro";
                        mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se suministr� el n�mero de tarjeta.";
                    }
                    else
                        if (numeroMensaje.Equals(4))
                        {
                            mensaje[0] = "1";
                            mensaje[1] = "Problemas Modificando Registro";
                            mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se suministr� el nuevo estado.";
                        }
                        else
                            if (numeroMensaje.Equals(5))
                            {
                                mensaje[0] = "1";
                                mensaje[1] = "Problemas Modificando Registro";
                                mensaje[2] = "El estado de la tarjeta no pudo ser modificado, ya que no se brind� dato alguno.";
                            }



            return mensaje;

        }/*fin del m�todo MostrarMensaje*/

        /// <summary>
        /// Este m�todo permite bloquear o desbloquear todos los campos del formulario
        /// </summary>
        /// <param name="bBloqueado">Indica si los controles est�n bloqueados o no</param>
        private void BloquearTodosCampos(bool bBloqueado)
        {
            try
            {
                txtObservaciones.Enabled = bBloqueado;
                ddlTipoGarantiaPorPerfil.Enabled = bBloqueado;
                lblMensaje3.Text = string.Empty;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }
        
        #endregion

    }
}
