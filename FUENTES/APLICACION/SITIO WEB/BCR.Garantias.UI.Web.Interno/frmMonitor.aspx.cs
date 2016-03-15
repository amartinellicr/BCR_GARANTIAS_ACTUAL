using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;


namespace BCRGARANTIAS.Presentacion
{
    public partial class frmMonitor : System.Web.UI.Page
    {
        #region Varables Globales
        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnConsultar.Click += new EventHandler(cmdConsultar_Click);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                CargarValores();

            if ((Request.QueryString["Codigo"] != null) && (Request.QueryString["Codigo"].ToString().Length > 0) && (Request.QueryString["Codigo"].ToString().CompareTo("77") == 0))
            {
                txtSentencia.Visible = true;
                btnConsultar.Visible = true;
            }
            // lblTitulo.Text = Request.QueryString["strTitulo"].ToString();

        }

        private void btnRefrescar_Click(object sender, System.EventArgs e)
        {
            CargarValores();
        }

        private void cmdConsultar_Click(object sender, System.EventArgs e)
        {
            string consultaBd = txtSentencia.Text.Trim();

            Error.Text = string.Empty;
            Error.Visible = false;

            if (consultaBd.Length > 0)
            {
                try
                {
                    SqlParameter[] parametros = new SqlParameter[] { };

                    DataSet datosObtenidos = AccesoBD.ExecuteDataSet(CommandType.Text, consultaBd, parametros);

                    if ((datosObtenidos != null) && (datosObtenidos.Tables.Count > 0) && (datosObtenidos.Tables[0].Rows.Count > 0))
                    {
                        GenerTabla(datosObtenidos.Tables[0]);
                    }
                }
                catch(SqlException ex)
                {
                    Error.Visible = true;
                    Error.Text = ex.Message;
                }
                catch(Exception ex)
                {
                    Error.Visible = true;
                    Error.Text = ex.Message;
                }
            }
            
        }

        #endregion

        #region Métodos Privados

        private void CargarValores()
        {
            Application.Lock();
            lblFechaHora.Text = DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString();
            lblSesiones.Text = Application["SessionCounter"].ToString();
            Application.UnLock();
        }

        private void GenerTabla(DataTable dt)
        {
            Table table = new Table();
            TableRow row = null;

            //Add the Headers
            row = new TableRow();
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                TableHeaderCell headerCell = new TableHeaderCell();
                headerCell.Text = dt.Columns[j].ColumnName;
                row.Cells.Add(headerCell);
            }
            table.Rows.Add(row);

            //Add the Column values
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                row = new TableRow();
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    TableCell cell = new TableCell();
                    cell.Text = dt.Rows[i][j].ToString();
                    row.Cells.Add(cell);
                }
                // Add the TableRow to the Table
                table.Rows.Add(row);
            }
            // Add the the Table in the Form
            //Form1.Controls.Add(table);

            ResultadoObtenido.Controls.Clear();
            ResultadoObtenido.Controls.Add(table);

        }

        #endregion
    }

}
