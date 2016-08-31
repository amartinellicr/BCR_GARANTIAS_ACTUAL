using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Data.OleDb;
using BCRGARANTIAS.Datos;
using BCRGARANTIAS.Negocios;

namespace BCRGARANTIAS.Presentacion
{
    public partial class frmGarantiasXOperacion : BCR.Web.SystemFramework.PaginaPersistente
    {
        #region Variables Globales

        protected System.Web.UI.WebControls.Label Label1;
        protected System.Data.OleDb.OleDbConnection oleDbConnection1;

        #endregion

        #region Eventos

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            btnValidarOperacion.Click +=new EventHandler(btnValidarOperacion_Click);
            cbTipoCaptacion.SelectedIndexChanged +=new EventHandler(cbTipoCaptacion_SelectedIndexChanged);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtContabilidad.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOficina.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtMoneda.Attributes["onblur"] = "javascript:EsNumerico(this);";
            txtOperacion.Attributes["onblur"] = "javascript:EsNumerico(this);";

            if (!IsPostBack)
            {
                try
                {
                    if (Gestor.IsInRol(Global.UsuarioSistema, int.Parse(Application["MNU_GARANTIAS_X_OPERACION"].ToString())))
                    {
                        Session["Tipo_Operacion"] = int.Parse(Application["OPERACION_CREDITICIA"].ToString());
                        Session["EsOperacionValida"] = false;
                        Session["EsOperacionValidaReal"] = false;
                        Session["EsOperacionValidaValor"] = false;
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

        private void btnValidarOperacion_Click(object sender, System.EventArgs e)
        {
			try
			{
				if (ValidarDatos())
				{
					#region Obsoleto AMM 09/07/2010
					//string strSQLQuery = "SELECT " +
					//                        "a.cod_operacion, " +
					//                        "b.cedula_deudor, " +
					//                        "b.nombre_deudor " +
					//                    "FROM " +
					//                        "gar_operacion a, " +
					//                        "gar_deudor b " +
					//                    "WHERE " +
					//                        " a.cod_estado = 1 " +
					//                        " and a.cedula_deudor = b.cedula_deudor " +
					//                        " and a.cod_contabilidad = " + txtContabilidad.Text +
					//                        " and a.cod_oficina = " + txtOficina.Text +
					//                        " and a.cod_moneda = " + txtMoneda.Text;

					//if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
					//{
					//    strSQLQuery = strSQLQuery + " and a.cod_producto = " + txtProducto.Text +
					//                                " and a.num_operacion = " + txtOperacion.Text;
					//}
					//else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
					//{
					//    strSQLQuery = strSQLQuery + " and a.num_operacion is null " +
					//                                " and a.num_contrato = " + txtOperacion.Text;
					//}

					//System.Data.DataSet dsDatos = new System.Data.DataSet();
					//oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
					//OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQLQuery, oleDbConnection1);
					//cmdConsulta.Fill(dsDatos, "Operacion");
					#endregion

					string strProducto = ((int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString())) ? txtProducto.Text : string.Empty);
					DataSet dsDatos = new DataSet();

					oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();
					OleDbCommand oComando = new OleDbCommand("pa_ValidarOperaciones", oleDbConnection1);
					oComando.CommandTimeout = 120;
					oComando.CommandType = CommandType.StoredProcedure;
					oComando.Parameters.AddWithValue("@Contabilidad", txtContabilidad.Text);
					oComando.Parameters.AddWithValue("@Oficina", txtOficina.Text);
					oComando.Parameters.AddWithValue("@Moneda", txtMoneda.Text);

					if (!string.IsNullOrEmpty(strProducto))
					{
						oComando.Parameters.AddWithValue("@Producto", strProducto);
					}
					else
					{
						oComando.Parameters.AddWithValue("@Producto", DBNull.Value);
					}

					oComando.Parameters.AddWithValue("@Operacion", txtOperacion.Text);
					oComando.Parameters["@Producto"].IsNullable = true;

					OleDbDataAdapter cmdConsulta = new OleDbDataAdapter();

					if ((oleDbConnection1 != null) && (oleDbConnection1.State == ConnectionState.Closed))
					{
						oleDbConnection1.Open();
					}

					cmdConsulta.SelectCommand = oComando;
					cmdConsulta.SelectCommand.Connection = oleDbConnection1;
					cmdConsulta.Fill(dsDatos, "Operacion");

					if (dsDatos.Tables["Operacion"].Rows.Count > 0)
					{
						lblDeudor.Visible = true;
						lblNombreDeudor.Visible = true;
						lblNombreDeudor.Text = dsDatos.Tables["Operacion"].Rows[0]["cedula_deudor"].ToString() + " - " +
												dsDatos.Tables["Operacion"].Rows[0]["nombre_deudor"].ToString();

						int nProducto = -1;

						if (txtProducto.Text.Length != 0)
							nProducto = int.Parse(txtProducto.Text);

						CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
									int.Parse(txtContabilidad.Text),
									int.Parse(txtOficina.Text),
									int.Parse(txtMoneda.Text),
									nProducto,
									long.Parse(txtOperacion.Text));
					}
					else
					{
						lblDeudor.Visible = false;
						lblNombreDeudor.Visible = false;
						this.gdvGarantiasOperacion.DataSource = null;
						this.gdvGarantiasOperacion.DataBind();
						if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
							lblMensaje.Text = "La operación crediticia no existe en el sistema o se encuentra cancelada. Por favor verifique.";
						else if (int.Parse(Session["Tipo_Operacion"].ToString()) == int.Parse(Application["CONTRATO"].ToString()))
							lblMensaje.Text = "El contrato no existe en el sistema o se encuentra cancelada. Por favor verifique.";
					}
				}
			}
			catch (Exception ex)
			{
				Response.Redirect("frmMensaje.aspx?" +
								"bError=1" +
								"&strTitulo=" + "Problemas Cargando Página" +
								"&strMensaje=" + ex.Message +
								"&bBotonVisible=0");
			}
			finally
			{
				oleDbConnection1.Close();
			}
        }

        private void cbTipoCaptacion_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            try
            {
                txtOficina.Text = "";
                txtMoneda.Text = "";
                txtProducto.Text = "";
                txtOperacion.Text = "";
                this.gdvGarantiasOperacion.DataSource = null;
                this.gdvGarantiasOperacion.DataBind();
                //UG1.DataSource = null;
                //UG1.DataBind();

                if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
                {
                    lblTipoCaptacion.Text = "Operación:";
                    Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                    lblProducto.Visible = true;
                    txtProducto.Visible = true;
                    lblDeudor.Visible = false;
                    lblNombreDeudor.Visible = false;
                }
                else if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["CONTRATO"].ToString()))
                {
                    lblTipoCaptacion.Text = "Contrato:";
                    Session["Tipo_Operacion"] = int.Parse(cbTipoCaptacion.SelectedValue.ToString());
                    lblProducto.Visible = false;
                    txtProducto.Visible = false;
                }
                lblDeudor.Visible = false;
                lblNombreDeudor.Visible = false;
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
        }

        #endregion

		#region Métodos GridView

		protected void gdvGarantiasOperacion_PageIndexChanging(object sender, GridViewPageEventArgs e)
		{
			this.gdvGarantiasOperacion.SelectedIndex = -1;
			this.gdvGarantiasOperacion.PageIndex = e.NewPageIndex;

			int nProducto = -1;

			if (txtProducto.Text.Length != 0)
				nProducto = int.Parse(txtProducto.Text);

			CargarGrid(int.Parse(cbTipoCaptacion.SelectedValue.ToString()),
									int.Parse(txtContabilidad.Text),
									int.Parse(txtOficina.Text),
									int.Parse(txtMoneda.Text),
									nProducto,
									long.Parse(txtOperacion.Text));
		}

		#endregion

        #region Métodos Privados
        /// <summary>
        /// Este método permite validar los campos llave del contrato
        /// </summary>
        /// <returns>True - Si los datos son correctos; False - Si los datos son incorrectos</returns>
        private bool ValidarDatos()
        {
            bool bRespuesta = true;
            try
            {
                lblMensaje.Text = "";

                if (bRespuesta && txtContabilidad.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de contabilidad";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOficina.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de oficina";
                    bRespuesta = false;
                }
                if (bRespuesta && txtMoneda.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el código de moneda";
                    bRespuesta = false;
                }
                if (bRespuesta && txtOperacion.Text.Trim().Length == 0)
                {
                    lblMensaje.Text = "Debe ingresar el número de contrato";
                    bRespuesta = false;
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = ex.Message;
            }
            return bRespuesta;
        }

        private void CargarGrid(int nTipoOperacion, int nContabilidad,
                                int nOficina, int nMoneda, int nProducto, long nOperacion)
        {
			try
			{
				#region
				//				string strSQL = "select " +
				//									"'[Fiador] ' + c.cedula_fiador + ' - ' + c.nombre_fiador as garantia " +
				//								"from " +
				//									"GAR_OPERACION a " +
				//									"inner join GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION b " +
				//									"on a.cod_operacion = b.cod_operacion " +
				//									"inner join GAR_GARANTIA_FIDUCIARIA c " +
				//									"on b.cod_garantia_fiduciaria = c.cod_garantia_fiduciaria " +
				//								"where  " +
				//									"a.cod_estado = 1  " +
				//									"and b.cod_estado = 1  " +
				//									"and a.cod_contabilidad = " + txtContabilidad.Text +
				//									"and a.cod_oficina= " + txtOficina.Text +
				//									"and a.cod_moneda= " + txtMoneda.Text;
				//
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and a.cod_producto= " + txtProducto.Text +
				//									  " and a.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and a.num_operacion is null " +
				//									  " and a.num_contrato = " + txtOperacion.Text;
				//				}
				//
				//				strSQL = strSQL + 		
				//							"UNION ALL " +
				//								"select " +
				//										"'[Fiador] ' + d.cedula_fiador + ' - ' + d.nombre_fiador as garantia " +
				//								  "from " +
				//										"gar_garantias_x_giro a, " +
				//										"gar_garantias_fiduciarias_x_operacion b, " +
				//										"gar_operacion c, " +
				//										"gar_garantia_fiduciaria d " +
				//								  "where  " +
				//										" a.cod_tipo_garantia = " + Application["GARANTIA_FIDUCIARIA"].ToString() +
				//										"and a.cod_operacion = b.cod_operacion " +
				//										"and b.cod_garantia_fiduciaria = a.cod_garantia " +
				//										"and a.cod_operacion_giro = c.cod_operacion " +
				//										"and c.cod_contabilidad= " + txtContabilidad.Text +
				//										"and c.cod_oficina= " + txtOficina.Text;
				//
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and c.cod_producto= " + txtProducto.Text +
				//									  " and c.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and c.num_operacion is null " +
				//									  " and c.num_contrato = " + txtOperacion.Text;
				//				}
				//				
				//				strSQL = strSQL + 
				//										"and b.cod_garantia_fiduciaria = d.cod_garantia_fiduciaria  " +
				//										"and b.cod_estado = 1 " +
				//										"and c.cod_estado = 1 ";
				//
				//				strSQL = strSQL + 
				//									
				//								"UNION ALL " +
				//
				//								"select  " +
				//									"case c.cod_tipo_garantia_real  " +
				//										"when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), c.cod_partido),'') + ' - Finca: ' + ISNULL(c.numero_finca,'')  " +
				//										"when 2 then '[Cédula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), c.cod_partido),'') + ' - Finca: ' + ISNULL(c.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), c.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2), c.cedula_hipotecaria),'')  " +
				//										"when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), c.cod_clase_bien),'') + ' - Placa: ' + ISNULL(c.num_placa_bien,'')  " +
				//									"end as garantia " +
				//
				//								"from  " +
				//									"GAR_OPERACION a " +
				//									"inner join GAR_GARANTIAS_REALES_X_OPERACION b " +
				//									"on a.cod_operacion = b.cod_operacion " +
				//									"inner join GAR_GARANTIA_REAL c " +
				//									"on b.cod_garantia_real = c.cod_garantia_real " +
				//
				//								"where  " +
				//									"a.cod_estado = 1  " +
				//									"and b.cod_estado = 1  " +
				//									"and a.cod_contabilidad = " + txtContabilidad.Text +
				//									"and a.cod_oficina= " + txtOficina.Text +
				//									"and a.cod_moneda= " + txtMoneda.Text;
				//									
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and a.cod_producto= " + txtProducto.Text +
				//									  " and a.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and a.num_operacion is null " +
				//									  " and a.num_contrato = " + txtOperacion.Text;
				//				}
				//
				//				strSQL = strSQL +
				//							"UNION ALL " +
				//								"select " +
				//									"case d.cod_tipo_garantia_real  " +
				//										"when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), d.cod_partido),'') + ' - Finca: ' + ISNULL(d.numero_finca,'')  " +
				//										"when 2 then '[Cédula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), d.cod_partido),'') + ' - Finca: ' + ISNULL(d.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), d.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2), d.cedula_hipotecaria),'')  " +
				//										"when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), d.cod_clase_bien),'') + ' - Placa: ' + ISNULL(d.num_placa_bien,'')  " +
				//									"end as garantia " +
				//								"from " +
				//									"gar_garantias_x_giro a, " +
				//									"GAR_GARANTIAS_REALES_X_OPERACION b, " +
				//									"gar_operacion c, " +
				//									"GAR_GARANTIA_REAL d " +
				//								"where " +
				//									"a.cod_tipo_garantia = " + Application["GARANTIA_REAL"].ToString() +
				//									" and a.cod_operacion = b.cod_operacion " +
				//									" and b.cod_garantia_real = a.cod_garantia " +
				//									" and a.cod_operacion_giro = c.cod_operacion " +
				//									" and c.cod_contabilidad= " + txtContabilidad.Text +
				//									" and c.cod_oficina= " + txtOficina.Text +
				//									" and c.cod_moneda= " + txtMoneda.Text;
				//
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and c.cod_producto= " + txtProducto.Text +
				//									  " and c.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and c.num_operacion is null " +
				//									  " and c.num_contrato = " + txtOperacion.Text;
				//				}
				//
				//				strSQL = strSQL +
				//									" and b.cod_garantia_real = d.cod_garantia_real " +
				//									" and c.cod_estado = 1 " +
				//									" and b.cod_estado = 1 ";
				//
				//				strSQL = strSQL + 
				//								"UNION ALL " +
				//
				//								"select  " +
				//									"'[Número de Seguridad] ' + c.numero_seguridad as garantia " +
				//								"from  " +
				//									"GAR_OPERACION a " +
				//									"inner join GAR_GARANTIAS_VALOR_X_OPERACION b " +
				//									"on a.cod_operacion = b.cod_operacion " +
				//									"inner join GAR_GARANTIA_VALOR c " +
				//									"on b.cod_garantia_valor = c.cod_garantia_valor " +
				//
				//								"where  " +
				//									"a.cod_estado = 1  " +
				//									"and b.cod_estado = 1  " +
				//									"and a.cod_contabilidad = " + txtContabilidad.Text +
				//									"and a.cod_oficina= " + txtOficina.Text +
				//									"and a.cod_moneda= " + txtMoneda.Text;
				//
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and a.cod_producto= " + txtProducto.Text +
				//						" and a.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and a.num_operacion is null " +
				//						" and a.num_contrato = " + txtOperacion.Text;
				//				}
				//
				//				strSQL = strSQL +
				//						"UNION ALL " +
				//							"select " +
				//								"'[Número de Seguridad] ' + d.numero_seguridad as garantia " +
				//							"from " +
				//								"gar_garantias_x_giro a, " +
				//								"GAR_GARANTIAS_VALOR_X_OPERACION b, " +
				//								"gar_operacion c, " +
				//								"GAR_GARANTIA_VALOR d " +
				//							"where " +
				//								"a.cod_tipo_garantia = " + Application["GARANTIA_VALOR"].ToString() +
				//								" and a.cod_operacion = b.cod_operacion " +
				//								" and b.cod_garantia_valor = a.cod_garantia " +
				//								" and a.cod_operacion_giro = c.cod_operacion " +
				//								" and c.cod_contabilidad= " + txtContabilidad.Text +
				//								" and c.cod_oficina= " + txtOficina.Text +
				//								" and c.cod_moneda= " + txtMoneda.Text;
				// 
				//				if (int.Parse(cbTipoCaptacion.SelectedValue.ToString()) == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//				{
				//					strSQL = strSQL + " and c.cod_producto= " + txtProducto.Text +
				//									  " and c.num_operacion= " + txtOperacion.Text;
				//				}
				//				else
				//				{
				//					strSQL = strSQL + " and c.num_operacion is null " +
				//									  " and c.num_contrato = " + txtOperacion.Text;
				//				}
				//				strSQL = strSQL + 
				//								" and b.cod_garantia_valor = d.cod_garantia_valor " +
				//								" and c.cod_estado = 1 " +
				//								" and b.cod_estado = 1 ";
				//
				//				strSQL = strSQL + 
				//								"order by " +
				//									" garantia";
				//
				//				System.Data.DataSet dsDatos = new System.Data.DataSet();
				//				oleDbConnection1 = BCRGARANTIAS.Datos.AccesoBD.ObtenerStringConexion();			
				//				OleDbDataAdapter cmdConsulta = new OleDbDataAdapter(strSQL, oleDbConnection1);
				//				cmdConsulta.Fill(dsDatos, "Datos");

				#endregion

				DataSet dsGarantiasFiduciarias = new DataSet();
				DataSet dsGarantiasReales = new DataSet();
				DataSet dsGarantiasValor = new DataSet();

				//Se determina si es una operación o un contrato
				if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				{
					SqlParameter[] parameters = new SqlParameter[] 
					{ 
						new SqlParameter("nCodOperacion", SqlDbType.BigInt),
						new SqlParameter("nContabilidad", SqlDbType.TinyInt),
						new SqlParameter("nOficina", SqlDbType.SmallInt),
						new SqlParameter("nMoneda", SqlDbType.TinyInt),
						new SqlParameter("nProducto", SqlDbType.TinyInt),
						new SqlParameter("nOperacion", SqlDbType.Decimal, 7),
						new SqlParameter("nObtenerSoloCodigo", SqlDbType.Bit),
						new SqlParameter("IDUsuario", SqlDbType.VarChar, 30),
					};

					parameters[0].Value = DBNull.Value;
					parameters[1].Value = nContabilidad;
					parameters[2].Value = nOficina;
					parameters[3].Value = nMoneda;
					parameters[4].Value = nProducto;
					parameters[5].Value = nOperacion;
					parameters[6].Value = true;
					parameters[7].Value = Global.UsuarioSistema;


					dsGarantiasFiduciarias = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasFiduciariasOperaciones", parameters);
					dsGarantiasReales = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasRealesOperaciones", parameters);
					dsGarantiasValor = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasValorOperaciones", parameters);
				}
				else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
				{
					SqlParameter[] parameters = new SqlParameter[] 
					{ 
						new SqlParameter("nCodOperacion", SqlDbType.BigInt),
						new SqlParameter("nContabilidad", SqlDbType.TinyInt),
						new SqlParameter("nOficina", SqlDbType.SmallInt),
						new SqlParameter("nMoneda", SqlDbType.TinyInt),
						new SqlParameter("nContrato", SqlDbType.Int),
						new SqlParameter("nObtenerSoloCodigo", SqlDbType.Bit),
						new SqlParameter("IDUsuario", SqlDbType.VarChar, 30),
					};

					parameters[0].Value = DBNull.Value;
					parameters[1].Value = nContabilidad;
					parameters[2].Value = nOficina;
					parameters[3].Value = nMoneda;
					parameters[4].Value = nOperacion;
					parameters[5].Value = true;
					parameters[6].Value = Global.UsuarioSistema;

					dsGarantiasFiduciarias = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasFiduciariasContratos", parameters);
					dsGarantiasReales = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasRealesContratos", parameters);
					dsGarantiasValor = AccesoBD.ExecuteDataSet(CommandType.StoredProcedure, "pa_ObtenerGarantiasValorContratos", parameters);
				}

				DataSet dsDatos = new DataSet();
				DataTable dtDatos = new DataTable();
				DataColumn dcDato = new DataColumn("garantia", typeof(String));
				dtDatos.Columns.Add(dcDato);
				dtDatos.AcceptChanges();

				if ((dsGarantiasFiduciarias != null) && (dsGarantiasFiduciarias.Tables.Count > 0) && (dsGarantiasFiduciarias.Tables[0].Rows.Count > 0))
				{
					foreach (DataRow dr in dsGarantiasFiduciarias.Tables[0].Rows)
					{
						dtDatos.ImportRow(dr);
						dtDatos.AcceptChanges();
					}
				}

				if ((dsGarantiasReales != null) && (dsGarantiasReales.Tables.Count > 0) && (dsGarantiasReales.Tables[0].Rows.Count > 0))
				{
					foreach (DataRow dr in dsGarantiasReales.Tables[0].Rows)
					{
						dtDatos.ImportRow(dr);
						dtDatos.AcceptChanges();
					}
				}

				if ((dsGarantiasValor != null) && (dsGarantiasValor.Tables.Count > 0) && (dsGarantiasValor.Tables[0].Rows.Count > 0))
				{
					foreach (DataRow dr in dsGarantiasValor.Tables[0].Rows)
					{
						dtDatos.ImportRow(dr);
						dtDatos.AcceptChanges();
					}
				}
				dtDatos.TableName = "Datos";
				dsDatos.Tables.Add(dtDatos);
				dsDatos.AcceptChanges();

				if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
				{

					if (!dsDatos.Tables["Datos"].Rows[0].IsNull("garantia"))
					{
						this.gdvGarantiasOperacion.DataSource = dsDatos.Tables["Datos"].DefaultView;
						this.gdvGarantiasOperacion.DataBind();
					}
					else
					{
						dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
						this.gdvGarantiasOperacion.DataSource = dsDatos;
						this.gdvGarantiasOperacion.DataBind();

						int TotalColumns = this.gdvGarantiasOperacion.Rows[0].Cells.Count;
						this.gdvGarantiasOperacion.Rows[0].Cells.Clear();
						this.gdvGarantiasOperacion.Rows[0].Cells.Add(new TableCell());
						this.gdvGarantiasOperacion.Rows[0].Cells[0].ColumnSpan = TotalColumns;
						this.gdvGarantiasOperacion.Rows[0].Cells[0].Text = "No existen registros";
						this.gdvGarantiasOperacion.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
					}
				}
				else
				{
					dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
					this.gdvGarantiasOperacion.DataSource = dsDatos;
					this.gdvGarantiasOperacion.DataBind();

					int TotalColumns = this.gdvGarantiasOperacion.Rows[0].Cells.Count;
					this.gdvGarantiasOperacion.Rows[0].Cells.Clear();
					this.gdvGarantiasOperacion.Rows[0].Cells.Add(new TableCell());
					this.gdvGarantiasOperacion.Rows[0].Cells[0].ColumnSpan = TotalColumns;
					this.gdvGarantiasOperacion.Rows[0].Cells[0].Text = "No existen registros";
					this.gdvGarantiasOperacion.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
				}

				#region Obsoleto

				//using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				//{
				//    SqlCommand oComando = null;

				//    if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//        oComando = new SqlCommand("pa_GarantiasXOperacion", oConexion);
				//    else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
				//        oComando = new SqlCommand("pa_GarantiasXContrato", oConexion);

				//    SqlDataAdapter oDataAdapter = new SqlDataAdapter();
				//    //declara las propiedades del comando
				//    oComando.CommandType = CommandType.StoredProcedure;
				//    oComando.CommandTimeout = 120;
				//    oComando.Parameters.AddWithValue("@nContabilidad", nContabilidad);
				//    oComando.Parameters.AddWithValue("@nOficina", nOficina);
				//    oComando.Parameters.AddWithValue("@nMoneda", nMoneda);

				//    if (nTipoOperacion == int.Parse(Application["OPERACION_CREDITICIA"].ToString()))
				//    {
				//        oComando.Parameters.AddWithValue("@nProducto", nProducto);
				//        oComando.Parameters.AddWithValue("@nOperacion", nOperacion);
				//    }
				//    else if (nTipoOperacion == int.Parse(Application["CONTRATO"].ToString()))
				//    {
				//        oComando.Parameters.AddWithValue("@nContrato", nOperacion);
				//        oComando.Parameters.AddWithValue("@nProducto", DBNull.Value);
				//        oComando.Parameters.AddWithValue("@nOperacion", DBNull.Value);
				//    }

				//    //Abre la conexion
				//    oConexion.Open();
				//    oDataAdapter.SelectCommand = oComando;
				//    oDataAdapter.SelectCommand.Connection = oConexion;
				//    oDataAdapter.Fill(dsDatos, "Datos");

				//    if ((dsDatos != null) && (dsDatos.Tables.Count > 0) && (dsDatos.Tables["Datos"].Rows.Count > 0))
				//    {

				//        if (!dsDatos.Tables["Datos"].Rows[0].IsNull("garantia"))
				//        {
				//            this.gdvGarantiasOperacion.DataSource = dsDatos.Tables["Datos"].DefaultView;
				//            this.gdvGarantiasOperacion.DataBind();
				//        }
				//        else
				//        {
				//            dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
				//            this.gdvGarantiasOperacion.DataSource = dsDatos;
				//            this.gdvGarantiasOperacion.DataBind();

				//            int TotalColumns = this.gdvGarantiasOperacion.Rows[0].Cells.Count;
				//            this.gdvGarantiasOperacion.Rows[0].Cells.Clear();
				//            this.gdvGarantiasOperacion.Rows[0].Cells.Add(new TableCell());
				//            this.gdvGarantiasOperacion.Rows[0].Cells[0].ColumnSpan = TotalColumns;
				//            this.gdvGarantiasOperacion.Rows[0].Cells[0].Text = "No existen registros";
				//            this.gdvGarantiasOperacion.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
				//        }
				//    }
				//    else
				//    {
				//        dsDatos.Tables["Datos"].Rows.Add(dsDatos.Tables["Datos"].NewRow());
				//        this.gdvGarantiasOperacion.DataSource = dsDatos;
				//        this.gdvGarantiasOperacion.DataBind();

				//        int TotalColumns = this.gdvGarantiasOperacion.Rows[0].Cells.Count;
				//        this.gdvGarantiasOperacion.Rows[0].Cells.Clear();
				//        this.gdvGarantiasOperacion.Rows[0].Cells.Add(new TableCell());
				//        this.gdvGarantiasOperacion.Rows[0].Cells[0].ColumnSpan = TotalColumns;
				//        this.gdvGarantiasOperacion.Rows[0].Cells[0].Text = "No existen registros";
				//        this.gdvGarantiasOperacion.Rows[0].Cells[0].HorizontalAlign = HorizontalAlign.Center;
				//    }
				//}
				#endregion
			}
			catch (Exception ex)
			{
				lblMensaje.Text = ex.Message;
			}
        }
        #endregion
    }
}
