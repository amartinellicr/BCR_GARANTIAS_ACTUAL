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

namespace BCRGARANTIAS.Forms
{
    public partial class frmRolesXPerfil : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

            protected System.Data.OleDb.OleDbConnection oleDbConnection1;
            private DataSet dsDatos = new DataSet();

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnEliminar.Click +=new EventHandler(btnEliminar_Click);
            btnInsertar.Click +=new EventHandler(btnInsertar_Click);
            btnLimpiar.Click +=new EventHandler(btnLimpiar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            btnEliminar.Attributes["onclick"] = "javascript:return confirm('¿Está seguro que desea eliminar el rol del perfil seleccionado?')";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_ROLES_X_PERFIL"].ToString())))
                    {
                        CargarComboPerfil();
                        CargarComboRoles();
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

        /// <summary>
        /// Metodo que permite la inserción de grupos de interes economicos
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnInsertar_Click(object sender, System.EventArgs e)
        {
            try
            {
                if (ValidarDatos())
                {
                    Gestor.CrearRolXPerfil(int.Parse(cbPerfil.SelectedValue), int.Parse(cbRol.SelectedValue), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=0" +
                                    "&strTitulo=" + "Inserción Exitosa" +
                                    "&strMensaje=" + "El rol por perfil se insertó satisfactoriamente." +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmRolesXPerfil.aspx");
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.StartsWith("The statement has been terminated."))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Insertando Registro" +
                                    "&strMensaje=" + "No se puede insertar registros duplicados. Verifique el rol que desea insertar." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmRolesXPerfil.aspx");
                }
            }
        }

        private void btnLimpiar_Click(object sender, System.EventArgs e)
        {
            try
            {
                CargarComboPerfil();
                CargarComboRoles();
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
                Gestor.EliminarRolXPerfil(int.Parse(cbPerfil.SelectedValue), int.Parse(cbRol.SelectedValue), Session["strUSER"].ToString(), Request.UserHostAddress.ToString());

                Response.Redirect("frmMensaje.aspx?" +
                                "bError=0" +
                                "&strTitulo=" + "Eliminación Exitosa" +
                                "&strMensaje=" + "El rol del perfil de seguridad se eliminó satisfactoriamente." +
                                "&bBotonVisible=1" +
                                "&strTextoBoton=Regresar" +
                                "&strHref=frmRolesXPerfil.aspx");
            }
            catch (Exception ex)
            {
                if (!ex.Message.StartsWith("Thread was being aborted.") && !ex.Message.StartsWith("Subproceso"))
                {
                    Response.Redirect("frmMensaje.aspx?" +
                                    "bError=1" +
                                    "&strTitulo=" + "Problemas Eliminando Registro" +
                                    "&strMensaje=" + "No se pudo eliminar el rol del perfil de seguridad." + "\r" +
                                    "&bBotonVisible=1" +
                                    "&strTextoBoton=Regresar" +
                                    "&strHref=frmRolesXPerfil.aspx");
                }
            }
        }

        #endregion
                
        #region Métodos TreeView

        protected void trvRolesXPerfil_SelectedNodeChanged(object sender, EventArgs e)
        {
            TreeView trvRXP = ((TreeView) sender);

            string strNodoSeleccionado = trvRXP.SelectedNode.Text;

            if (Session["dsDatos"] != null)
            {
                dsDatos = ((DataSet)Session["dsDatos"]);
            }

            bool bEsPerfil = false;

            foreach (DataRow drPerfil in dsDatos.Tables["Perfil"].Rows)
            {
                if (drPerfil["DES_PERFIL"].ToString().CompareTo(strNodoSeleccionado) == 0)
                {
                    bEsPerfil = true;
                    break;
                }
            }

            if (bEsPerfil)
            {
                bool bExpandido = false;

                if(trvRXP.SelectedNode.Expanded != null)
                {
                    bExpandido = ((bool) trvRXP.SelectedNode.Expanded);
                }
                if (bExpandido)
                {
                    trvRXP.SelectedNode.Collapse();
                    trvRXP.SelectedNode.Selected = false;
                }
                else
                {
                    trvRXP.SelectedNode.Expand();
                    trvRXP.SelectedNode.Selected = false;
                }
            }
            else
            {
                bool bEsRol = false;

                foreach (DataRow drPerfil in dsDatos.Tables["RolesXPerfil"].Rows)
                {
                    if (drPerfil["DES_ROL"].ToString().CompareTo(strNodoSeleccionado) == 0)
                    {
                        bEsRol = true;
                        break;
                    }
                }

                if (bEsRol)
                {
                    string strPerfil = trvRXP.SelectedNode.Parent.Value;
                    string strRol = trvRXP.SelectedNode.Value;

                    CargarComboPerfil();
                    cbPerfil.Items.FindByValue(strPerfil).Selected = true;
                    CargarComboRoles();
                    cbRol.Items.FindByValue(strRol).Selected = true;
                    btnInsertar.Enabled = false;
                    btnEliminar.Enabled = true;
                }
            }
        }

        #endregion

        #region Métodos Privados
        /// <summary>
        /// Metodo que carga el grid con la informacion de grupos de interes economico
        /// </summary>
        private void CargarGrid()
        {
            
            DataTable dtDatosRelacionados = new DataTable();

            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();

            OleDbDataAdapter cmdPerfil = new OleDbDataAdapter("SELECT COD_PERFIL, DES_PERFIL FROM SEG_PERFIL ORDER BY DES_PERFIL", oleDbConnection1);
            OleDbDataAdapter cmdRol = new OleDbDataAdapter("SELECT b.COD_ROL, a.DES_ROL, b.COD_PERFIL FROM SEG_ROL a INNER JOIN SEG_ROLES_X_PERFIL b ON a.COD_ROL = b.COD_ROL ORDER BY a.DES_ROL", oleDbConnection1);

            cmdPerfil.Fill(dsDatos, "Perfil");
            cmdRol.Fill(dsDatos, "RolesXPerfil");

            try
            {
                DataColumn parentCol = dsDatos.Tables["Perfil"].Columns["COD_PERFIL"];
                DataColumn childCol = dsDatos.Tables["RolesXPerfil"].Columns["COD_PERFIL"];

                dsDatos.Relations.Add("RolesXPerfil", parentCol, childCol);

                Session["dsDatos"] = dsDatos;

                
            }
            catch (System.Exception ex)
            {
                throw new Exception(ex.Message);
            }

            CargarTreeView();
        }

        /// <summary>
        /// Metodo que carga el combo de perfiles
        /// </summary>
        private void CargarComboPerfil()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT COD_PERFIL, DES_PERFIL FROM SEG_PERFIL UNION ALL SELECT -1, '' ORDER BY DES_PERFIL", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Perfiles");
            cbPerfil.DataSource = null;
            cbPerfil.DataSource = dsDatos.Tables["Perfiles"].DefaultView;
            cbPerfil.DataValueField = "COD_PERFIL";
            cbPerfil.DataTextField = "DES_PERFIL";
            cbPerfil.DataBind();
        }

        /// <summary>
        /// Metodo que carga el combo de roles
        /// </summary>
        private void CargarComboRoles()
        {
            System.Data.DataSet dsDatos = new System.Data.DataSet();
            oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
            OleDbDataAdapter cmdConsulta = new OleDbDataAdapter("SELECT COD_ROL, DES_ROL FROM SEG_ROL UNION ALL SELECT -1, '' ORDER BY DES_ROL", oleDbConnection1);
            cmdConsulta.Fill(dsDatos, "Roles");
            cbRol.DataSource = null;
            cbRol.DataSource = dsDatos.Tables["Roles"].DefaultView;
            cbRol.DataValueField = "COD_ROL";
            cbRol.DataTextField = "DES_ROL";
            cbRol.DataBind();
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
                if (bRespuesta && int.Parse(cbPerfil.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el perfil.";
                    bRespuesta = false;
                }
                if (bRespuesta && int.Parse(cbRol.SelectedValue.ToString()) == -1)
                {
                    lblMensaje.Text = "Debe seleccionar el rol.";
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
        /// Método que se encarga de cargar el treeview que presenta los roles por perfil
        /// </summary>
        private void CargarTreeView()
        {
            if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables[0].Rows.Count > 0))
            {
                foreach (DataRow drPerfil in dsDatos.Tables["Perfil"].Rows)
                {
                    TreeNode trnPadre = new TreeNode();
                    trnPadre.Value = drPerfil["COD_PERFIL"].ToString();
                    trnPadre.Text = drPerfil["DES_PERFIL"].ToString();

                    DataRow[] drRolesXPerfil = dsDatos.Tables["RolesXPerfil"].Select("COD_PERFIL = " + drPerfil["COD_PERFIL"].ToString());

                    if (drRolesXPerfil.Length > 0)
                    {
                        foreach (DataRow drRolXPerfil in drRolesXPerfil)
                        {
                            TreeNode trnHijo = new TreeNode();
                            trnHijo.Value = drRolXPerfil["COD_ROL"].ToString();
                            trnHijo.Text = drRolXPerfil["DES_ROL"].ToString();

                            trnPadre.ChildNodes.Add(trnHijo);
                        }
                    }

                    this.trvRolesXPerfil.Nodes.Add(trnPadre);
                }

                this.pnlRolesXPerfil.Height = new Unit(400, UnitType.Pixel);
            }
        }
        #endregion


        
}
}
