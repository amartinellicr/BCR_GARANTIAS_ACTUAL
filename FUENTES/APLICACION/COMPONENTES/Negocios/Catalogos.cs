using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;
using BCR.GARANTIAS.Comun;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Catalogos.
	/// </summary>
	public class Catalogos
	{
		#region Metodos Publicos
		public void Crear(int nCatalogo, string strCampo, string strDescripcion, string strUsuario, string strIP)
		{
			try
			{
                string strInsertarCatalogo = "INSERT INTO CAT_ELEMENTO (CAT_CATALOGO, CAT_CAMPO, CAT_DESCRIPCION) VALUES (" + nCatalogo + ", '" + strCampo + "','" + strDescripcion + "');";
				
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarCatalogo, oConexion);

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

						oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty,
						   ContenedorElemento.CAT_CATALOGO,
						   string.Empty,
						   oTraductor.TraducirTipoCatalogo(nCatalogo));

						//oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						//   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty, ContenedorElemento.CAT_CAMPO,
						//   string.Empty,
						//   nCampo.ToString());

						oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty, ContenedorElemento.CAT_DESCRIPCION,
						   string.Empty,
						   strDescripcion);

						#endregion

					}
				}
			}
            catch(SqlException sqlEx)
			{
                switch (sqlEx.Number)
                {
                    //case 2627:
                    case 2627:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 2601:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 547:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_REGISTRO_TIENE_HIJOS, null), sqlEx);
                    case 515:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_CAMPO_NO_NULO, null), sqlEx);
                    default:
                        throw sqlEx;
                }
			}
			catch
			{
				throw;
			}
		}

        public void Modificar(int nElemento, string strCampo, string strDescripcion, string strUsuario, string strIP)
		{
			try
			{
				string strModificarCatalogo = " UPDATE CAT_ELEMENTO " +
                                " SET CAT_DESCRIPCION = '" + strDescripcion + "', CAT_CAMPO = '" + strCampo + "'" +
								" WHERE CAT_ELEMENTO = " + nElemento;
				
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsElemento = AccesoBD.ejecutarConsulta("select " + ContenedorElemento.CAT_DESCRIPCION + "," +
                    ContenedorElemento.CAT_CAMPO +
                    " from " + ContenedorElemento.NOMBRE_ENTIDAD +
                    " where " + ContenedorElemento.CAT_ELEMENTO + " = " + nElemento.ToString());


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarCatalogo, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsElemento != null) && (dsElemento.Tables.Count > 0) && (dsElemento.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsElemento.Tables[0].Rows[0].IsNull(ContenedorElemento.CAT_DESCRIPCION))
							{
								string strCatalogoDescripcionObt = dsElemento.Tables[0].Rows[0][ContenedorElemento.CAT_DESCRIPCION].ToString();

								if (strCatalogoDescripcionObt.CompareTo(strDescripcion) != 0)
								{
									oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, ContenedorElemento.CAT_DESCRIPCION,
									   strCatalogoDescripcionObt,
									   strDescripcion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, ContenedorElemento.CAT_DESCRIPCION,
									   string.Empty,
									   strDescripcion);
							}

							//    if (!dsElemento.Tables[0].Rows[0].IsNull(ContenedorElemento.CAT_CAMPO))
							//    {
							//        int nCatalogoCampoObt = Convert.ToInt32(dsElemento.Tables[0].Rows[0][ContenedorElemento.CAT_CAMPO].ToString());

							//        if (nCatalogoCampoObt != nCampo)
							//        {
							//            oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
							//               2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, ContenedorElemento.CAT_CAMPO,
							//               nCatalogoCampoObt.ToString(),
							//               nCampo.ToString());
							//        }
							//    }
							//    else
							//    {
							//        oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
							//               2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, ContenedorElemento.CAT_CAMPO,
							//               string.Empty,
							//               nCampo.ToString());
							//    }
						}

						#endregion
					}
				}
			}
    catch (SqlException sqlEx)
            {
                switch (sqlEx.Number)
                {
                    //case 2627:
                    case 2627:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 2601:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 547:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_REGISTRO_TIENE_HIJOS, null), sqlEx);
                    case 515:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_CAMPO_NO_NULO, null), sqlEx);
                    default:
                        throw sqlEx;
                }
            }
			catch
			{
				throw;
			}
		}

		public void Eliminar(int nElemento, string strUsuario, string strIP)
		{
			try
			{
				string strEliminarCatalogo = "DELETE CAT_ELEMENTO WHERE CAT_ELEMENTO = " + nElemento.ToString();

                string strConsultarCatalogo = "select " + ContenedorElemento.CAT_CATALOGO + "," +
                    ContenedorElemento.CAT_DESCRIPCION + 
                    " from " + ContenedorElemento.NOMBRE_ENTIDAD + 
                    " where " + ContenedorElemento.CAT_ELEMENTO + " = " + nElemento.ToString();

                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsElemento = AccesoBD.ejecutarConsulta(strConsultarCatalogo);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarCatalogo, oConexion);

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

						if ((dsElemento != null) && (dsElemento.Tables.Count > 0) && (dsElemento.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drElemento in dsElemento.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drElemento.Table.Columns.Count; nIndice++)
								{
									if (drElemento.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorElemento.CAT_CATALOGO) == 0)
									{
										if (drElemento[nIndice, DataRowVersion.Current].ToString() != string.Empty)
										{
											oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarCatalogo, string.Empty,
											   drElemento.Table.Columns[nIndice].ColumnName,
											   oTraductor.TraducirTipoCatalogo(Convert.ToInt32(drElemento[nIndice, DataRowVersion.Current].ToString())),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarCatalogo, string.Empty,
											   drElemento.Table.Columns[nIndice].ColumnName,
											   string.Empty,
											   string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
										   3, null, string.Empty, string.Empty, strEliminarCatalogo, string.Empty,
										   drElemento.Table.Columns[nIndice].ColumnName,
										   drElemento[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
							  3, null, string.Empty, string.Empty, strEliminarCatalogo, string.Empty, string.Empty,
							  string.Empty,
							  string.Empty);
						}

						#endregion
					}
				}
			}
      catch (SqlException sqlEx)
            {
                switch (sqlEx.Number)
                {
                    //case 2627:
                    case 2627:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 2601:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_LLAVE_REPETIDA, null), sqlEx);
                    case 547:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_REGISTRO_TIENE_HIJOS, null), sqlEx);
                    case 515:
                        throw new ExcepcionBase(Mensajes.Obtener(Mensajes.ERROR_CAMPO_NO_NULO, null), sqlEx);
                    default:
                        throw sqlEx;
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
