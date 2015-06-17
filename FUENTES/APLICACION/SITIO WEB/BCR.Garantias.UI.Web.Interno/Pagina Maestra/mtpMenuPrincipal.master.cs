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
using System.Xml;
using System.IO;
using System.Globalization;
using System.Reflection;
using System.Text;

using BCRGARANTIAS.Negocios;


namespace BCRGARANTIAS.Presentacion
{
    public partial class mtpMenuPrincipal : System.Web.UI.MasterPage
    {
        #region Variables Globales

        Menu mnuPrincipal1;


        #endregion

        #region Eventos

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                Page.Header.DataBind();

                if (!IsPostBack)
                {
                    string dFechaActual = DateTime.Now.ToLongDateString();

                    char[] strFechaActual = dFechaActual.ToCharArray();

                    if (strFechaActual.Length > 0)
                    {
                        char Caracter = strFechaActual[0];

                        if (char.IsLower(Caracter))
                        {
                            strFechaActual[0] = char.ToUpper(Caracter);

                            dFechaActual = string.Empty;

                            foreach (char CaracterFecha in strFechaActual)
                            {
                                dFechaActual += CaracterFecha;
                            }
                        }
                    }


                    lblFecha.Text = dFechaActual;
                    string strNombreUsuario = Gestor.ObtenerNombreUsuario(Global.UsuarioSistema);
                    lblUsrConectado.Text = "Usuario: " + Global.UsuarioSistema + " - " + strNombreUsuario;
                    BCR.ActiveDirectory.Objects.User oUser = new BCR.ActiveDirectory.Objects.User();
                    oUser.GetUserInformation(Global.UsuarioSistema);
                    lblUsrConectado.Text = "Usuario: " + oUser.UserName.ToString() + " - " + oUser.DisplayName.ToString();
                    //Session["strUSER"] = "401640970";
                    //lblUsrConectado.Text = "Usuario: 401640970 - Arnoldo Martinelli Marín";
               
                    /*llama al método que crea el menú*/
                    GenerarMenu();

                    #region Nuevo Leo

                    //lblUsrModifico.Text = "Usuario Modifico: 206950433 - Leonardo Cortes Mora";
                    //lblFechaModificacion.Text = "Fecha Modificacion: 99-99-9999";
                    //lblFechaReplica.Text = "Fecha Replica:99-99-9999";

                    #endregion
                }
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Object reference not set to an instance of an object."))
                    lblUsrConectado.Text = ex.Message;
                else
                    lblUsrConectado.Text = "Usuario no válido";
            }
            finally
            {
                /*llama al método que crea el menú*/
                //GenerarMenu();
            }
        }

        #endregion

        #region Método que genera el menú
        /// <summary>
        /// Crea el menu de la aplicación con base el archivo siteMap
        /// </summary>
        private void GenerarMenu()
        {
            /*crea el documento XML para almacenar el archivo sitemap*/
            XmlDocument menu = new XmlDocument();

            /*lee el archivo siteMap*/
            menu.Load(Request.PhysicalApplicationPath + @"\ArchivosXML\MenuPrincipal.sitemap");

            /*obtiene los nodos hijos con el nombre siteMap*/
            XmlNodeList siteMap = menu.GetElementsByTagName("siteMap");

            /*obtiene el nodo principal que contiene todos los elementos del menú*/
            XmlNodeList hijos = siteMap[0].ChildNodes;

            /*crea el menu item para agregarlo al menú*/
            MenuItem itemMenu = new MenuItem(hijos[0].Attributes["title"].Value);
            menuPrincipal.Items.Add(itemMenu);

            /*obtiene los nodos hijos del nodo principal para agregarlos al menú principal*/
            XmlNodeList subhijos = hijos[0].ChildNodes;

            /*recorre cada uno de los nodos hijos y los agrega al menú principal, a su vez
              obtiene sus nodos hijos para agregarlos al submenu*/
            foreach (XmlNode nodo in subhijos)
            {
                /*obtiene la información para el item del menú y lo agrega al menú*/
                itemMenu = new MenuItem(nodo.Attributes["title"].Value);
                menuPrincipal.Items.Add(itemMenu);

                /*obtiene los submenus*/
                Submenus(nodo, itemMenu);

            }/*fin del foreach (XmlNode nodo in subhijos)*/

        }/*fin del método GenerarMenu*/
        #endregion Método que genera el menú

        #region Método que genera los sub items del menu
        /// <summary>
        /// Genera los sub menus para cada uno de los items del menú
        /// </summary>
        /// <param name="nodo">
        /// XMLNode que posee los items y la información de cada item para el menú
        /// </param>
        /// <param name="itemMenu">
        /// MenuItem padre que contendrá los sub items a agregar al menú
        /// </param>
        private void Submenus(XmlNode nodo, MenuItem itemMenu)
        {
            /*valida que el nodo posea hijos para el submenu*/
            if (nodo.HasChildNodes)
                /*recorrido de los nodos hijos para agregarlos al menú*/
                foreach (XmlNode nodoHijo in nodo.ChildNodes)
                {
                    /*valida que el nodo hijo posea atributos*/
                    if (nodoHijo.Attributes != null)
                    {
                        /*crea un item con la descripcion del nodo y lo agrega al menú*/
                        MenuItem submenu = new MenuItem(nodoHijo.Attributes["title"].Value);
                        itemMenu.ChildItems.Add(submenu);

                        /*ejecuta el método para el nodo hijo para obtener los posibles nodos hijos de este
                          y agregarlos al menú*/
                        Submenus(nodoHijo, submenu);

                    }/*fin del if (nodoHijo.Attributes != null)*/

                }/*fin del  foreach (XmlNode nodoHijo in nodo.ChildNodes)*/

        }/*fin del método Submenus*/
        #endregion Método que genera los sub items del menu

        #region Acción del menú
        /// <summary>
        /// Acción del menú item al ser seleccionado
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void NavigationMenu_MenuItemClick(Object sender, MenuEventArgs e)
        {
            /*crea el documento XML para almacenar el archivo sitemap*/
            XmlDocument menu = new XmlDocument();

            /*lee el archivo siteMap*/
            menu.Load(Request.PhysicalApplicationPath + @"\ArchivosXML\MenuPrincipal.sitemap");

            /*obtiene los nodos hijos con el nombre siteMap*/
            XmlNodeList siteMap = menu.GetElementsByTagName("siteMap");

            /*obtiene todos los nodo cuyo tagname es siteMapNode*/
            XmlNodeList lista = ((XmlElement)siteMap[0]).GetElementsByTagName("siteMapNode");

            /*recorre cada nodo para evaluar que corresponda al seleccionado en el menú*/
            foreach (XmlNode nodoHijo in lista)
            {
                /*evalua que posea atributos que el item seleccionado concuerde con el atributo title del nodo*/
                if (nodoHijo.Attributes != null && nodoHijo.Attributes["title"].Value.Equals(e.Item.Text))
                {
                    /*Se asigna "false" a esta variables de sesión, con el fin de cargar las opciones por defecto*/
                    Session["EsOperacionValida"] = false;

                    /*evalua que posee url donde redirigir la pagina*/
                    if (!string.IsNullOrEmpty(nodoHijo.Attributes["url"].Value))
                        /*redirecciona a la url almacenada en el atributo "url" del nodo*/
                        Response.Redirect("~/" + nodoHijo.Attributes["url"].Value);
                }

            }/*fin del foreach (XmlNode nodoHijo in lista)*/

        }/*fin del método NavigationMenu_MenuItemClick*/
        #endregion Acción del menú


        /// <summary>
        /// Returns the contents of the embedded script as
        /// a stringwrapped with the start / end script tags.
        /// </summary>
        /// <param name="scriptName">FileName of the script.</param>
        /// <returns>Contents of the script.</returns>
        public static string UnpackScript(string scriptName)
        {
            string language = "javascript";
            string extension = Path.GetExtension(scriptName);

            if (0 == string.Compare(extension, ".vbs", true
              , CultureInfo.InvariantCulture))
            {
                language = "vbscript";
            }

            return UnpackScript(scriptName, language);
        }

        public static string UnpackScript(string scriptName, string scriptLanguage)
        {
            return "<script language=\"Javascript\">"
              + Environment.NewLine
              + UnpackEmbeddedResourceToString(scriptName)
              + Environment.NewLine
              + "</script>";
        }

        // Unpacks the embedded resource to string.
        static string UnpackEmbeddedResourceToString(string resourceName)
        {
            Assembly executingAssembly = Assembly.GetExecutingAssembly();
            Stream resourceStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName);
                //executingAssembly.GetManifestResourceStream(typeof(BCR.GARANTIAS.JavaScriptLibrary.clsJavaScriptHelper), (executingAssembly.GetName().Name + resourceName));
            using (StreamReader reader = new StreamReader(resourceStream, Encoding.ASCII))
            {
                return reader.ReadToEnd();
            }
        }
    }
}
