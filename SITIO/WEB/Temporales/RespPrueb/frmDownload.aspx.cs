using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
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
using System.IO;

namespace BCRGARANTIAS.Forms
{

    public partial class frmDownload : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Image Image2;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;
        protected System.Web.UI.WebControls.Label lblUsrConectado;
        protected System.Web.UI.WebControls.Label lblFecha;

        #endregion

        #region Eventos

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_ARCHIVOS_SEGUI"].ToString())))
                    {
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

        #endregion

        #region Métodos GridView

        protected void gdvArchivos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            GridView gdvArchivos = (GridView)sender;
            int rowIndex = 0;

            try
            {
                switch (e.CommandName)
                {
                    case ("SelectedFile"):
                        rowIndex = (int.Parse(e.CommandArgument.ToString()));

                        gdvArchivos.SelectedIndex = rowIndex;

                        try
                        {
                            string strNombreArchivo = gdvArchivos.SelectedDataKey[0].ToString();
                            string strTamanoArchivo = gdvArchivos.SelectedDataKey[2].ToString();
                            string strRutaArchivo = gdvArchivos.SelectedDataKey[1].ToString();

                            Response.Clear();
                            Response.AddHeader("Content-Disposition", "attachment; filename=" + strNombreArchivo);
                            Response.AddHeader("Content-Length", strTamanoArchivo);
                            Response.ContentType = "application/octet-stream";
                            Response.WriteFile(strRutaArchivo);
                            Response.End(); 



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

        protected void gdvArchivos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gdvArchivos.SelectedIndex = -1;
            this.gdvArchivos.PageIndex = e.NewPageIndex;

            CargarGrid();
        }

        #endregion

        #region Metodos Privados

        private void CargarGrid()
        {
            try
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable("Files");
                dt.Columns.Add("nombre", typeof(String));
                dt.Columns.Add("url", typeof(String));
                dt.Columns.Add("size", typeof(Int32));
                dt.Columns.Add("date", typeof(DateTime));
                dt.Columns.Add("type", typeof(String));
                ds.Tables.Add(dt);

                string strRutaArchivos = Application["DOWNLOAD"].ToString();// Application["ARCHIVOS"].ToString();

                DirectoryInfo di = new DirectoryInfo(strRutaArchivos);
                FileInfo[] rgFiles = di.GetFiles("*.zip");
                foreach (FileInfo fi in rgFiles)
                {
                    DataRow dr;
                    dr = ds.Tables[0].NewRow();
                    dr["nombre"] = fi.Name.ToString();
                    dr["url"] = fi.FullName.ToString();//Application["DOWNLOAD"].ToString() + fi.Name.ToString();
                    dr["size"] = fi.Length;
                    dr["date"] = fi.LastWriteTime;
                    dr["type"] = fi.Extension.ToString();
                    ds.Tables["Files"].Rows.Add(dr);
                }

                gdvArchivos.DataSource = null;
                gdvArchivos.DataSource = ds.Tables["Files"].DefaultView;
                gdvArchivos.DataBind();
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message.ToString();
            }
        }

        #endregion
       
}
}
