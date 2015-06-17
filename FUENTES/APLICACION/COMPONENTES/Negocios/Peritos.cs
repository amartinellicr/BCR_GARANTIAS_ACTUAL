using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Peritos.
	/// </summary>
	public class Peritos
	{
		#region Metodos Publicos
		public void Crear(string strCedula, string strNombre, int nTipoPersona, string strTelefono, 
                          string strEmail, string strDireccion, string strUsuario, string strIP)
		{
			try
			{
				string strInsertarPerito = "INSERT INTO GAR_PERITO " +
						        "(CEDULA_PERITO, DES_PERITO, COD_TIPO_PERSONA, DES_TELEFONO, DES_EMAIL, DES_DIRECCION) " +
								"VALUES ('" + strCedula + "', '" + strNombre + "'," + nTipoPersona + ", '" + strTelefono + "', '" + strEmail + "', '" + strDireccion + "');";
				
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarPerito, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.CEDULA_PERITO,
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.DES_PERITO,
						   string.Empty,
						   strNombre);

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.COD_TIPO_PERSONA,
						   string.Empty,
						   oTraductor.TraducirTipoPersona(nTipoPersona));

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.DES_TELEFONO,
						   string.Empty,
						   strTelefono);

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.DES_EMAIL,
						   string.Empty,
						   strEmail);

						oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarPerito, string.Empty, ContenedorPerito.DES_DIRECCION,
						   string.Empty,
						   strDireccion);
					}
				}
			}
			catch
			{
				throw;
			}
		}

		public void Modificar(string strCedula, string strNombre, int nTipoPersona, string strTelefono,
                              string strEmail, string strDireccion, string strUsuario, string strIP)
		{
			try
			{
				string strModificarPerito = "UPDATE GAR_PERITO " +
								"SET CEDULA_PERITO = '" + strCedula + "', DES_PERITO = '" + strNombre + "', " +
								"COD_TIPO_PERSONA = " + nTipoPersona + ", DES_TELEFONO = '" + strTelefono + "', " +
								"DES_EMAIL = '" + strEmail + "', DES_DIRECCION = '" + strDireccion + "' " + 
								"WHERE CEDULA_PERITO = '" + strCedula + "'";
				
                //AccesoBD.ejecutarConsulta(strQry);


                //Se obtienen los datos antes de ser modificados, con el fin de poder ingresarlos en la bitácora
                DataSet dsPerito = AccesoBD.ejecutarConsulta("select " + ContenedorPerito.CEDULA_PERITO + "," +
                    ContenedorPerito.DES_PERITO + "," + ContenedorPerito.COD_TIPO_PERSONA + "," +
                    ContenedorPerito.DES_TELEFONO + "," + ContenedorPerito.DES_EMAIL + "," +
                    ContenedorPerito.DES_DIRECCION + 
                    " from " + ContenedorPerito.NOMBRE_ENTIDAD +
                    " where " + ContenedorPerito.CEDULA_PERITO + " = '" + strCedula + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarPerito, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsPerito != null) && (dsPerito.Tables.Count > 0) && (dsPerito.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.CEDULA_PERITO))
							{
								string strCedulaPeritoObt = dsPerito.Tables[0].Rows[0][ContenedorPerito.CEDULA_PERITO].ToString();

								if (strCedulaPeritoObt.CompareTo(strCedula) != 0)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.CEDULA_PERITO,
									   strCedulaPeritoObt,
									   strCedula);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.CEDULA_PERITO,
									   string.Empty,
									   strCedula);
							}

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.DES_PERITO))
							{
								string strNombrePeritoObt = dsPerito.Tables[0].Rows[0][ContenedorPerito.DES_PERITO].ToString();

								if (strNombrePeritoObt.CompareTo(strNombre) != 0)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_PERITO,
									   strNombrePeritoObt,
									   strNombre);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_PERITO,
									   string.Empty,
									   strNombre);
							}

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.COD_TIPO_PERSONA))
							{
								int nCodigoTipoPersonaObt = Convert.ToInt32(dsPerito.Tables[0].Rows[0][ContenedorPerito.COD_TIPO_PERSONA].ToString());

								if (nCodigoTipoPersonaObt != nTipoPersona)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.COD_TIPO_PERSONA,
									   oTraductor.TraducirTipoPersona(nCodigoTipoPersonaObt),
									   oTraductor.TraducirTipoPersona(nTipoPersona));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.COD_TIPO_PERSONA,
									   string.Empty,
									   oTraductor.TraducirTipoPersona(nTipoPersona));
							}

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.DES_TELEFONO))
							{
								string strTelefonoObt = dsPerito.Tables[0].Rows[0][ContenedorPerito.DES_TELEFONO].ToString();

								if (strTelefonoObt.CompareTo(strTelefono) != 0)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_TELEFONO,
									   strTelefonoObt,
									   strTelefono);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_TELEFONO,
									   string.Empty,
									   strTelefono);
							}

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.DES_EMAIL))
							{
								string strEmailObt = dsPerito.Tables[0].Rows[0][ContenedorPerito.DES_EMAIL].ToString();

								if (strEmailObt.CompareTo(strEmail) != 0)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_EMAIL,
									   strEmailObt,
									   strEmail);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_EMAIL,
									   string.Empty,
									   strEmail);
							}

							if (!dsPerito.Tables[0].Rows[0].IsNull(ContenedorPerito.DES_DIRECCION))
							{
								string strDireccionObt = dsPerito.Tables[0].Rows[0][ContenedorPerito.DES_DIRECCION].ToString();

								if (strDireccionObt.CompareTo(strDireccion) != 0)
								{
									oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_DIRECCION,
									   strDireccionObt,
									   strDireccion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarPerito, string.Empty, ContenedorPerito.DES_DIRECCION,
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
				string strEliminarPerito = "DELETE GAR_PERITO WHERE CEDULA_PERITO = '" + strCedula + "'";

                string strConsultarPerito = "select " + ContenedorPerito.CEDULA_PERITO + "," +
                   ContenedorPerito.DES_PERITO + "," + ContenedorPerito.COD_TIPO_PERSONA + "," +
                   ContenedorPerito.DES_TELEFONO + "," + ContenedorPerito.DES_EMAIL + "," +
                   ContenedorPerito.DES_DIRECCION +
                   " from " + ContenedorPerito.NOMBRE_ENTIDAD +
                   " where " + ContenedorPerito.CEDULA_PERITO + " = '" + strCedula + "'";

                DataSet dsPerito = AccesoBD.ejecutarConsulta(strConsultarPerito);


                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarPerito, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						if ((dsPerito != null) && (dsPerito.Tables.Count > 0) && (dsPerito.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drPerito in dsPerito.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drPerito.Table.Columns.Count; nIndice++)
								{
									if (drPerito.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorPerito.COD_TIPO_PERSONA) == 0)
									{
										if (drPerito[nIndice, DataRowVersion.Current].ToString() != string.Empty)
										{
											oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
											   drPerito.Table.Columns[nIndice].ColumnName,
											   oTraductor.TraducirTipoPersona(Convert.ToInt32(drPerito[nIndice, DataRowVersion.Current].ToString())),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
											   drPerito.Table.Columns[nIndice].ColumnName,
											   string.Empty,
											   string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
										   3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty,
										   drPerito.Table.Columns[nIndice].ColumnName,
										   drPerito[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_PERITO", strUsuario, strIP, null,
							  3, null, string.Empty, string.Empty, strEliminarPerito, string.Empty, string.Empty,
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
