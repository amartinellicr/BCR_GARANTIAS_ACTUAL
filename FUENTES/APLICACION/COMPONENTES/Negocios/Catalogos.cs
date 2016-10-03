using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;


namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Catalogos.
    /// </summary>
    public class Catalogos
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Metodos Publicos

        public void Crear(int nCatalogo, string strCampo, string strDescripcion, string strUsuario, string strIP)
		{
            try
            {
                listaCampos = new string[] { clsElemento._entidadElemento,
                                             clsElemento._codigoCatalogo, clsElemento._codigoCampo, clsElemento._descripcionElemento,
                                             nCatalogo.ToString(), strCampo, strDescripcion};

                sentenciaSql = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}) VALUES({4}, '{5}', '{6}')", listaCampos);
                string strInsertarCatalogo = sentenciaSql;

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

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty,
                           clsElemento._codigoCatalogo,
						   string.Empty,
						   oTraductor.TraducirTipoCatalogo(nCatalogo));

						//oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						//   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty, ContenedorElemento.CAT_CAMPO,
						//   string.Empty,
						//   nCampo.ToString());

						oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCatalogo, string.Empty, clsElemento._descripcionElemento,
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
                listaCampos = new string[] { clsElemento._entidadElemento,
                                             clsElemento._descripcionElemento, strDescripcion,
                                             clsElemento._codigoCampo, strCampo,
                                             clsElemento._consecutivoElemento, nElemento.ToString() };

                sentenciaSql = string.Format("UPDATE dbo.{0} SET {1} = '{2}', {3} = '{4}' WHERE {5} = {6}", listaCampos);
                string strModificarCatalogo = sentenciaSql;


                listaCampos = new string[] { clsElemento._descripcionElemento, clsElemento._codigoCampo,
                                             clsElemento._entidadElemento,
                                             clsElemento._consecutivoElemento, nElemento.ToString() };

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = {4}", listaCampos);

                DataSet dsElemento = AccesoBD.ejecutarConsulta(sentenciaSql);


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(strModificarCatalogo, oConexion))
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

						if ((dsElemento != null) && (dsElemento.Tables.Count > 0) && (dsElemento.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							if (!dsElemento.Tables[0].Rows[0].IsNull(clsElemento._descripcionElemento))
							{
								string strCatalogoDescripcionObt = dsElemento.Tables[0].Rows[0][clsElemento._descripcionElemento].ToString();

								if (strCatalogoDescripcionObt.CompareTo(strDescripcion) != 0)
								{
									oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, clsElemento._descripcionElemento,
									   strCatalogoDescripcionObt,
									   strDescripcion);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("CAT_ELEMENTO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCatalogo, string.Empty, clsElemento._descripcionElemento,
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
                string strEliminarCatalogo = string.Format("DELETE FROM dbo.{0} WHERE {1} = {2}", clsElemento._entidadElemento, clsElemento._consecutivoElemento, nElemento.ToString());

                listaCampos = new string[] { clsElemento._codigoCatalogo, clsElemento._descripcionElemento, 
                                             clsElemento._entidadElemento,
                                             clsElemento._consecutivoElemento, nElemento.ToString() };

                sentenciaSql = string.Format("SELECT {0}, {1} FROM dbo.{2} WHERE {3} = {4}", listaCampos);

                DataSet dsElemento = AccesoBD.ejecutarConsulta(sentenciaSql);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(strEliminarCatalogo, oConexion))
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

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						if ((dsElemento != null) && (dsElemento.Tables.Count > 0) && (dsElemento.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drElemento in dsElemento.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drElemento.Table.Columns.Count; nIndice++)
								{
									if (drElemento.Table.Columns[nIndice].ColumnName.CompareTo(clsElemento._codigoCatalogo) == 0)
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

        /// <summary>
        /// Obtiene la lista de catálogos utilizados por los diferentes mantenimientos
        /// </summary>
        /// <param name="listaCatalogos">Lista de los catálogos que se deben obtener. La lista debe iniciar y finalizar con el caracter "|", así mismo de requerirse más de un catálogo, los valores deben ir separados por dicho caracter.
        /// </param>
        /// <returns>Enditad del tipo catálogos</returns>
        public clsCatalogos<clsCatalogo> ObtenerCatalogos(string listaCatalogos)
        {
            clsCatalogos<clsCatalogo> entidadCatalogos = null;

            string tramaObtenida = string.Empty;
            string[] strMensajeObtenido = new string[] { string.Empty };

            if (listaCatalogos.Length > 0)
            {
                try
                {
                    SqlParameter[] parameters = new SqlParameter[] {
                        new SqlParameter("psListaCatalogos", SqlDbType.VarChar, 150),
                    };

                    parameters[0].Value = listaCatalogos;

                    SqlParameter[] parametrosSalida = new SqlParameter[] { };

                    using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
                    {
                        oConexion.Open();

                        tramaObtenida = AccesoBD.ExecuteXmlReader(oConexion, CommandType.StoredProcedure, "pa_ObtenerCatalogos", out parametrosSalida, parameters);

                        oConexion.Close();
                        oConexion.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    entidadCatalogos = new clsCatalogos<clsCatalogo>();

                    entidadCatalogos.ErrorDatos = true;
                    entidadCatalogos.DescripcionError = Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS, Mensajes.ASSEMBLY);

                    string desError = "Error al obtener la trama: " + ex.Message;
                    UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);

                    tramaObtenida = string.Empty;
                }
            }

            if (tramaObtenida.Length > 0)
            {
                entidadCatalogos = new clsCatalogos<clsCatalogo>(tramaObtenida);
            }

            return entidadCatalogos;
        }

        /// <summary>
        /// Obtiene la lista de los códigos ISIN
        /// </summary>
        /// </param>
        /// <returns>DataSet con la lista de los códigos ISIN</returns>
        public DataSet ObtenerCatalogoIsin()
        {
            DataSet catalogoIsin = new DataSet();

            try
            {
                sentenciaSql = "SELECT cod_isin FROM dbo.CAT_ISIN UNION ALL SELECT '' ORDER BY cod_isin";

                SqlParameter[] parametros = new SqlParameter[] { };

                catalogoIsin = AccesoBD.ExecuteDataSet(CommandType.Text, sentenciaSql, parametros);
            }
            catch (Exception ex)
            {
                string desError = "Error al obtener la lista de códigos ISIN: " + ex.Message;
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }
            
            return catalogoIsin;
        }

        /// <summary>
        /// Obtiene la lista de los instrumentos
        /// </summary>
        /// </param>
        /// <returns>DataSet con la información de los intrumentos</returns>
        public DataSet ObtenerCatalogoInstrumentos()
        {
            DataSet catalogoInstrumentos = new DataSet();

            try
            {
                sentenciaSql = "SELECT cod_instrumento, des_instrumento  FROM dbo.CAT_INSTRUMENTOS UNION ALL SELECT '', '' ORDER BY des_instrumento";

                SqlParameter[] parametros = new SqlParameter[] { };

                catalogoInstrumentos = AccesoBD.ExecuteDataSet(CommandType.Text, sentenciaSql, parametros);
            }
            catch (Exception ex)
            {
                string desError = "Error al obtener la lista instrumentos de las garantías de valor: " + ex.Message;
                UtilitariosComun.RegistraEventLog(Mensajes.Obtener(Mensajes.ERROR_CARGA_CATALOGOS_DETALLE, desError, Mensajes.ASSEMBLY), EventLogEntryType.Error);
            }

            return catalogoInstrumentos;
        }

        #endregion
    }
}
