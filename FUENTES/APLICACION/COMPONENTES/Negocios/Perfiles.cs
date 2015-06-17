using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using System.Configuration;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Perfiles.
	/// </summary>
	public class Perfiles
	{
		#region Atributos de Clase
		private int mnPerfil;
		private string mstrPerfil;
		#endregion

		#region Constructores de Clase
		public Perfiles(int nPerfil, string strPerfil)
		{
			mstrPerfil = strPerfil;
			mnPerfil = nPerfil;
		}		
		#endregion

		#region Propiedades de Clase
		public string strPerfil
		{
			get {return mstrPerfil;}
			set {mstrPerfil = value;}
		}

		public int nPerfil
		{
			get {return mnPerfil;}
			set {mnPerfil = value;}
		}
		#endregion
	}

	/// <summary>
	/// Summary description for MultiPerfiles.
	/// </summary>
	public class MultiPerfiles
	{
		#region Metodos Publicos
		public void Crear(string strPerfil, string strUsuario, string strIP)
		{
			try
			{
				string strInsertarPerfil = "INSERT INTO SEG_PERFIL (DES_PERFIL) VALUES ('" + strPerfil + "');";
				
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarPerfil, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerfil, string.Empty, ContenedorPerfil.DES_PERFIL,
						   string.Empty,
						   strPerfil);
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(int nPerfil, string strPerfil, string strUsuario, string strIP)
		{
			try
			{
				string strModificarPerfil = "UPDATE SEG_PERFIL " +
								"SET DES_PERFIL = '" + strPerfil + "' " +
								"WHERE COD_PERFIL = " + nPerfil;
				
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsPerfil = AccesoBD.ejecutarConsulta("select " + ContenedorPerfil.DES_PERFIL +
                    " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
                    " where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString());


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarPerfil, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsPerfil.Tables[0].Rows[0].IsNull(ContenedorPerfil.DES_PERFIL))
							{
								string strDescripcionPerfilObt = dsPerfil.Tables[0].Rows[0][ContenedorPerfil.DES_PERFIL].ToString();

								if (strDescripcionPerfilObt.CompareTo(strPerfil) != 0)
								{
									oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerfil, string.Empty, ContenedorPerfil.DES_PERFIL,
									   strDescripcionPerfilObt,
									   strPerfil);
								}
							}
						}
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Eliminar(int nPerfil, string strUsuario, string strIP)
		{
			try
			{
				string strEliminarPerfil = "DELETE SEG_PERFIL WHERE COD_PERFIL = " + nPerfil;

                string strConsultaPerfil = "select " + ContenedorPerfil.DES_PERFIL + 
                   " from " + ContenedorPerfil.NOMBRE_ENTIDAD +
                   " where " + ContenedorPerfil.COD_PERFIL + " = " + nPerfil.ToString();

                DataSet dsPerfil = AccesoBD.ejecutarConsulta(strConsultaPerfil);

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarPerfil, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						if ((dsPerfil != null) && (dsPerfil.Tables.Count > 0) && (dsPerfil.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drPerfil in dsPerfil.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drPerfil.Table.Columns.Count; nIndice++)
								{
									oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
									   3, null, string.Empty, string.Empty, strEliminarPerfil, string.Empty,
									   drPerfil.Table.Columns[nIndice].ColumnName,
									   drPerfil[nIndice, DataRowVersion.Current].ToString(),
									   string.Empty);
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("SEG_PERFIL", strUsuario, strIP, null,
							  3, null, string.Empty, string.Empty, strEliminarPerfil, string.Empty, string.Empty,
							  string.Empty,
							  string.Empty);
						}
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void ActualizarPerfiles(System.Data.DataSet pdsDatos)
		{
			try
			{
				SqlDataAdapter lcAdaptador = new SqlDataAdapter();
				SqlConnection lcConexionSQL = new SqlConnection();

                lcConexionSQL.ConnectionString = ConfigurationManager.ConnectionStrings["Sql_Server"].ConnectionString;
                                                 //"Password=" + BCRGARANTIAS.Datos.AccesoBD.CargarParametro("Password") + ";" +
                                                 //"Persist Security Info=True;" +
                                                 //"User ID=" + BCRGARANTIAS.Datos.AccesoBD.CargarParametro("Usuario") + ";" +
                                                 //"Initial Catalog=" + BCRGARANTIAS.Datos.AccesoBD.CargarParametro("Base_Datos") + ";" +
                                                 //"Data Source=" + BCRGARANTIAS.Datos.AccesoBD.CargarParametro("Servidor") + ";";

				lcAdaptador.UpdateCommand = ConfigurarModificacionPerfiles(lcConexionSQL);
				lcAdaptador.InsertCommand = ConfigurarInsercionPerfiles(lcConexionSQL);
				lcAdaptador.DeleteCommand = ConfigurarBorradoPerfiles(lcConexionSQL);

				lcAdaptador.Update(pdsDatos, "Perfiles");

				//Se liberan objetos
				lcAdaptador = null;
				lcConexionSQL.Close();
		
				lcConexionSQL = null;
			}
			catch (Exception ex)
			{
				throw new Exception("Error: Perfiles.ActualizarPerfiles. Se presentaron problemas al actualizar los perfiles de seguridad. " + ex.Message);
			}
		}
		#endregion

		#region Metodos Privados
		private SqlCommand ConfigurarModificacionPerfiles(SqlConnection pcnConexion)
		{
			SqlCommand lcComandoUpdate = new SqlCommand();
            SqlParameter lpParametro = new SqlParameter(); 

			try
			{
				lcComandoUpdate.Connection = pcnConexion;

				lpParametro = new SqlParameter("@cod_perfil",System.Data.SqlDbType.Int, 4, "cod_perfil");
				lpParametro.Direction = ParameterDirection.Input;
				lpParametro.SourceVersion = DataRowVersion.Original;
				lcComandoUpdate.Parameters.Add(lpParametro);
				lpParametro = null;

				lpParametro = new SqlParameter("@des_perfil", System.Data.SqlDbType.VarChar, 100, "des_perfil");
				lpParametro.Direction = ParameterDirection.Input;
				lpParametro.SourceVersion = DataRowVersion.Current;
				lcComandoUpdate.Parameters.Add(lpParametro);
				lpParametro = null;

				lcComandoUpdate.CommandText = 
					"UPDATE seg_perfil " +
					"SET cod_perfil = @cod_perfil, des_perfil = @des_perfil " +
					"WHERE (cod_perfil = @cod_perfil); " + 
					"SELECT TOP 1 cod_perfil, des_perfil FROM seg_perfil ORDER BY 1 DESC";

				return lcComandoUpdate;
			}
            catch (Exception ex)
			{
                throw new Exception("Error: Perfiles.ConfigurarModificacionPerfiles. Se presentaron problemas al configurar la actualización de los perfiles. " + ex.Message);
			}
		}

		private SqlCommand ConfigurarInsercionPerfiles(SqlConnection pcnConexion)
		{
			SqlCommand lcComandoInsert = new SqlCommand();
			SqlParameter lpParametro = new SqlParameter(); 

			try
			{
				lcComandoInsert.Connection = pcnConexion;

				lpParametro = new SqlParameter("@cod_perfil",System.Data.SqlDbType.Int, 4, "cod_perfil");
				lpParametro.Direction = ParameterDirection.Input;
				lpParametro.SourceVersion = DataRowVersion.Original;
				lcComandoInsert.Parameters.Add(lpParametro);
				lpParametro = null;

				lpParametro = new SqlParameter("@des_perfil", System.Data.SqlDbType.VarChar, 100, "des_perfil");
				lpParametro.Direction = ParameterDirection.Input;
				lpParametro.SourceVersion = DataRowVersion.Current;
				lcComandoInsert.Parameters.Add(lpParametro);
				lpParametro = null;

				lcComandoInsert.CommandText = 
						"INSERT INTO seg_perfil " +
                            "(cod_perfil, des_perfil) " +
                        " VALUES (@cod_perfil, @des_perfil); " +
                        " SELECT TOP 1 cod_perfil, des_perfil FROM seg_perfil ORDER BY 1 DESC";

				return lcComandoInsert;
			}
			catch (Exception ex)
			{
				throw new Exception("Error: Perfiles.ConfigurarInsercionPerfiles. Se presentaron problemas al configurar la inserción de los perfiles. " + ex.Message);
			}
		}

		private SqlCommand ConfigurarBorradoPerfiles(SqlConnection pcnConexion)
		{
			SqlCommand lcComandoDelete = new SqlCommand();
			SqlParameter lpParametro = new SqlParameter(); 

			try
			{
				lcComandoDelete.Connection = pcnConexion;

				lpParametro = new SqlParameter("@cod_perfil",System.Data.SqlDbType.Int, 4, "cod_perfil");
				lpParametro.Direction = ParameterDirection.Input;
				lpParametro.SourceVersion = DataRowVersion.Original;
				lcComandoDelete.Parameters.Add(lpParametro);
				lpParametro = null;

				lcComandoDelete.CommandText = "DELETE FROM seg_perfil WHERE (cod_perfil = @cod_perfil)";

				return lcComandoDelete;
			}
			catch (Exception ex)
			{
				throw new Exception("Error: Perfiles.ConfigurarBorradoPerfiles. Se presentaron problemas al configurar el borrado de los perfiles. " + ex.Message);
			}
		}
		#endregion
	}
}
