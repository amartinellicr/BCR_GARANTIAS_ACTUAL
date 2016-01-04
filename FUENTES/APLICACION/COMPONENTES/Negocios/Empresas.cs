using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;

namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Empresas.
    /// </summary>
    public class Empresas
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
         int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Metodos Publicos
        public void Crear(string strCedula, string strNombre, string strTelefono, string strEmail, 
                          string strDireccion, string strUsuario, string strIP)
		{
			try
			{
                listaCampos = new string[] { clsEmpresa._entidadEmpresa,
                                             clsEmpresa._cedulaEmpresa, clsEmpresa._nombreEmpresa, clsEmpresa._telefonoEmpresa, clsEmpresa._correoEmpresa, clsEmpresa._direccionEmpresa,
                                             strCedula, strNombre, strTelefono, strEmail, strDireccion};

                sentenciaSql = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}, {5}) VALUES('{6}', '{7}', '{8}', '{9}', '{10}')", listaCampos);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(sentenciaSql, oConexion))
                    {
                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, sentenciaSql, string.Empty, clsEmpresa._cedulaEmpresa,
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, sentenciaSql, string.Empty, clsEmpresa._nombreEmpresa,
						   string.Empty,
						   strNombre);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, sentenciaSql, string.Empty, clsEmpresa._telefonoEmpresa,
						   string.Empty,
						   strTelefono);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, sentenciaSql, string.Empty, clsEmpresa._correoEmpresa,
						   string.Empty,
						   strEmail);

						oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, sentenciaSql, string.Empty, clsEmpresa._direccionEmpresa,
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
                listaCampos = new string[] { clsEmpresa._entidadEmpresa,
                                             clsEmpresa._nombreEmpresa, strNombre,
                                             clsEmpresa._telefonoEmpresa, strTelefono,
                                             clsEmpresa._correoEmpresa, strEmail,
                                             clsEmpresa._direccionEmpresa, strDireccion,
                                             clsEmpresa._cedulaEmpresa, strCedula};

                string strModificarEmpresa = string.Format("UPDATE dbo.{0} SET {1} = '{2}', {3} = '{4}', {5} = '{6}', {7} = '{8}' WHERE {9} = '{10}'", listaCampos);


                listaCampos = new string[] { clsEmpresa._nombreEmpresa, clsEmpresa._telefonoEmpresa, clsEmpresa._correoEmpresa, clsEmpresa._direccionEmpresa,
                                             clsEmpresa._entidadEmpresa,
                                             clsEmpresa._cedulaEmpresa, strCedula};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3} FROM dbo.{4} WHERE {5} = '{6}'", listaCampos);


                DataSet dsEmpresa = AccesoBD.ejecutarConsulta(sentenciaSql);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(strModificarEmpresa, oConexion))
                    {

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsEmpresa != null) && (dsEmpresa.Tables.Count > 0) && (dsEmpresa.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(clsEmpresa._nombreEmpresa))
							{
								string strDescripcionEmpresaObt = dsEmpresa.Tables[0].Rows[0][clsEmpresa._nombreEmpresa].ToString();

								if (strDescripcionEmpresaObt.CompareTo(strNombre) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._nombreEmpresa,
									   strDescripcionEmpresaObt,
									   strNombre);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._nombreEmpresa,
									   string.Empty,
									   strNombre);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(clsEmpresa._telefonoEmpresa))
							{
								string strDescripcionTelefonoObt = dsEmpresa.Tables[0].Rows[0][clsEmpresa._telefonoEmpresa].ToString();

								if (strDescripcionTelefonoObt.CompareTo(strTelefono) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._telefonoEmpresa,
									   strDescripcionTelefonoObt,
									   strTelefono);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._telefonoEmpresa,
									   string.Empty,
									   strTelefono);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(clsEmpresa._correoEmpresa))
							{
								string strDescripcionEmailObt = dsEmpresa.Tables[0].Rows[0][clsEmpresa._correoEmpresa].ToString();

								if (strDescripcionEmailObt.CompareTo(strEmail) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._correoEmpresa,
									   strDescripcionEmailObt,
									   strEmail);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									  2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._correoEmpresa,
									  string.Empty,
									  strEmail);
							}

							if (!dsEmpresa.Tables[0].Rows[0].IsNull(clsEmpresa._direccionEmpresa))
							{
								string strDescripcionDireccionObt = dsEmpresa.Tables[0].Rows[0][clsEmpresa._direccionEmpresa].ToString();

								if (strDescripcionDireccionObt.CompareTo(strDireccion) != 0)
								{
									oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._direccionEmpresa,
									   strDescripcionDireccionObt,
									   strDireccion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_EMPRESA", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarEmpresa, string.Empty, clsEmpresa._direccionEmpresa,
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
                string strEliminarEmpresa = string.Format("DELETE dbo.{0} WHERE {1} = '{2}'", clsEmpresa._entidadEmpresa, clsEmpresa._cedulaEmpresa, strCedula);

                listaCampos = new string[] { clsEmpresa._cedulaEmpresa, clsEmpresa._nombreEmpresa, clsEmpresa._telefonoEmpresa, clsEmpresa._correoEmpresa, clsEmpresa._direccionEmpresa,
                                             clsEmpresa._entidadEmpresa,
                                             clsEmpresa._cedulaEmpresa, strCedula};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3}, {4} FROM dbo.{5} WHERE {6} = '{7}'", listaCampos);

                DataSet dsEmpresa = AccesoBD.ejecutarConsulta(sentenciaSql);

                using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                {
                    using (SqlCommand oComando = new SqlCommand(strEliminarEmpresa, oConexion))
                    {

                        //Declara las propiedades del comando
                        oComando.CommandType = CommandType.Text;
                        oComando.Connection.Open();

                        //Ejecuta el comando
                        nFilasAfectadas = oComando.ExecuteNonQuery();

                        oComando.Connection.Close();
                        oComando.Connection.Dispose();
                    }

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
