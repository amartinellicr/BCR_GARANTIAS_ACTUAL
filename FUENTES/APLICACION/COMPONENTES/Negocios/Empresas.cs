using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Empresas.
	/// </summary>
	public class Empresas
	{
		#region Metodos Publicos
		public void Crear(string strCedula, string strNombre, string strTelefono, string strEmail, 
                          string strDireccion, string strUsuario, string strIP)
		{
			try
			{
				string strInsertarEmpresa = "INSERT INTO GAR_EMPRESA " +
								"(CEDULA_EMPRESA, DES_EMPRESA, DES_TELEFONO, DES_EMAIL, DES_DIRECCION) " +
								"VALUES ('" + strCedula + "', '" + strNombre + "', '" + strTelefono + "', '" + strEmail + "', '" + strDireccion + "');";
				
                
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarEmpresa, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarEmpresa, string.Empty, ContenedorEmpresa.CEDULA_EMPRESA,
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarEmpresa, string.Empty, ContenedorEmpresa.DES_EMPRESA,
						   string.Empty,
						   strNombre);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarEmpresa, string.Empty, ContenedorEmpresa.DES_TELEFONO,
						   string.Empty,
						   strTelefono);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarEmpresa, string.Empty, ContenedorEmpresa.DES_EMAIL,
						   string.Empty,
						   strEmail);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarEmpresa, string.Empty, ContenedorEmpresa.DES_DIRECCION,
						   string.Empty,
						   strDireccion);

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(string strCedula, string strNombre, string strTelefono, string strEmail,
                              string strDireccion, string strUsuario, string strIP)
		{
			try
			{
				string strModificarEmpresa = "UPDATE GAR_EMPRESA " +
								"SET CEDULA_EMPRESA = '" + strCedula + "', DES_EMPRESA = '" + strNombre + "', " +
								"DES_TELEFONO = '" + strTelefono + "', " +
								"DES_EMAIL = '" + strEmail + "', DES_DIRECCION = '" + strDireccion + "' " + 
								"WHERE CEDULA_EMPRESA = '" + strCedula + "'";
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsEmpresa = AccesoBD.ejecutarConsulta("select " + ContenedorEmpresa.DES_EMPRESA + "," +
                    ContenedorEmpresa.DES_TELEFONO + "," + ContenedorEmpresa.DES_EMAIL + "," +
                    ContenedorEmpresa.DES_DIRECCION +
                    " from " + ContenedorEmpresa.NOMBRE_ENTIDAD +
                    " where " + ContenedorEmpresa.CEDULA_EMPRESA + " = '" + strCedula + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarEmpresa, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsEmpresa != null) && (dsEmpresa.Tables.Count > 0) && (dsEmpresa.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(ContenedorEmpresa.DES_EMPRESA))
							{
								string strDescripcionEmpresaObt = dsEmpresa.Tables[0].Rows[0][ContenedorEmpresa.DES_EMPRESA].ToString();

								if (strDescripcionEmpresaObt.CompareTo(strNombre) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_EMPRESA,
									   strDescripcionEmpresaObt,
									   strNombre);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_EMPRESA,
									   string.Empty,
									   strNombre);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(ContenedorEmpresa.DES_TELEFONO))
							{
								string strDescripcionTelefonoObt = dsEmpresa.Tables[0].Rows[0][ContenedorEmpresa.DES_TELEFONO].ToString();

								if (strDescripcionTelefonoObt.CompareTo(strTelefono) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_TELEFONO,
									   strDescripcionTelefonoObt,
									   strTelefono);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_TELEFONO,
									   string.Empty,
									   strTelefono);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(ContenedorEmpresa.DES_EMAIL))
							{
								string strDescripcionEmailObt = dsEmpresa.Tables[0].Rows[0][ContenedorEmpresa.DES_EMAIL].ToString();

								if (strDescripcionEmailObt.CompareTo(strEmail) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_EMAIL,
									   strDescripcionEmailObt,
									   strEmail);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									  2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_EMAIL,
									  string.Empty,
									  strEmail);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(ContenedorEmpresa.DES_DIRECCION))
							{
								string strDescripcionDireccionObt = dsEmpresa.Tables[0].Rows[0][ContenedorEmpresa.DES_DIRECCION].ToString();

								if (strDescripcionDireccionObt.CompareTo(strDireccion) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_DIRECCION,
									   strDescripcionDireccionObt,
									   strDireccion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, ContenedorEmpresa.DES_DIRECCION,
									   string.Empty,
									   strDireccion);
							}
						}

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Eliminar(string strCedula, string strUsuario, string strIP)
		{
			try
			{
				string strEliminarEmpresa = "DELETE GAR_EMPRESA WHERE CEDULA_EMPRESA = '" + strCedula + "'";

                string strConsultaEmpresa = "select " + ContenedorEmpresa.DES_EMPRESA + "," +
                    ContenedorEmpresa.DES_TELEFONO + "," + ContenedorEmpresa.DES_EMAIL + "," +
                    ContenedorEmpresa.DES_DIRECCION + "," + ContenedorEmpresa.CEDULA_EMPRESA +
                    " from " + ContenedorEmpresa.NOMBRE_ENTIDAD +
                    " where " + ContenedorEmpresa.CEDULA_EMPRESA + " = '" + strCedula + "'";


                 DataSet dsEmpresa = AccesoBD.ejecutarConsulta(strConsultaEmpresa); 
                //AccesoBD.ejecutarConsulta(strQry);

				 using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				 {
					 SqlCommand oComando = new SqlCommand(strEliminarEmpresa, oConexion);

					 //Declara las propiedades del comando
					 oComando.CommandType = CommandType.Text;
					 oConexion.Open();

					 //Ejecuta el comando
					 int nFilasAfectadas = oComando.ExecuteNonQuery();

					 if (nFilasAfectadas > 0)
					 {
						 #region Inserción en Bitácora

						 Bitacora oBitacora = new Bitacora();

						 if ((dsEmpresa != null) && (dsEmpresa.Tables.Count > 0) && (dsEmpresa.Tables[0].Rows.Count > 0))
						 {
							 foreach (DataRow drEmpresa in dsEmpresa.Tables[0].Rows)
							 {
								 for (int nIndice = 0; nIndice < drEmpresa.Table.Columns.Count; nIndice++)
								 {
									 oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
										3, null, string.Empty, string.Empty, strEliminarEmpresa, string.Empty,
										drEmpresa.Table.Columns[nIndice].ColumnName,
										drEmpresa[nIndice, DataRowVersion.Current].ToString(),
										string.Empty);
								 }
							 }
						 }
						 else
						 {
							 oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
								3, null, string.Empty, string.Empty, strEliminarEmpresa, string.Empty, string.Empty,
								string.Empty,
								string.Empty);
						 }

						 #endregion
					 }
				 }
			}
			catch
			{
				throw;
			}
		}
		#endregion
	}
}
