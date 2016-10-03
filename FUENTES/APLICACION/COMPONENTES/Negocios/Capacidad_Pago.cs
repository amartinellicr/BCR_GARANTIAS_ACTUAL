using System;
using System.Data;
using System.Data.SqlClient;

using BCRGARANTIAS.Datos;
using BCR.GARANTIAS.Entidades;
using BCR.GARANTIAS.Comun;


namespace BCRGARANTIAS.Negocios
{
    /// <summary>
    /// Summary description for Capacidad_Pago.
    /// </summary>
    public class Capacidad_Pago
	{
        #region Variables Globales

        string sentenciaSql = string.Empty;
        string[] listaCampos = { string.Empty };
        string strInsertarCapacidadPago = string.Empty;
        int nFilasAfectadas = 0;

        #endregion Variables Globales

        #region Métodos Públicos
        public void Crear(string strCedula, string dFecha, int nCapacidadPago, decimal nSensibilidad, 
                          string strUsuario, string strIP)
		{
			try
			{
				string strSensibilidad = nSensibilidad.ToString();

                DateTime dFechaConv = Convert.ToDateTime(dFecha);
               
                string strFecha = dFechaConv.ToString("yyyyMMdd");

                listaCampos = new string[] { clsCapacidadPago._entidadCapacidadPagoDeudor,
                                             clsCapacidadPago._cedulaDeudor, clsCapacidadPago._fechaCapacidadPago, clsCapacidadPago._codCapacidadPago, clsCapacidadPago._porSensibilidadTipoCambio,
                                             strCedula, strFecha, ((nCapacidadPago != -1) ? nCapacidadPago.ToString() : UtilitariosComun.ValorNulo),
                                             strSensibilidad};

                sentenciaSql = string.Format("INSERT INTO dbo.{0} ({1}, {2}, {3}, {4}) VALUES({5}, {6}, {7}, CONVERT(DECIMAL(5,2), '{8}'))", listaCampos);

                strInsertarCapacidadPago = sentenciaSql;

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

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, clsCapacidadPago._cedulaDeudor,
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, clsCapacidadPago._fechaCapacidadPago,
						   string.Empty,
						   dFecha);

						if (nCapacidadPago != -1)
						{
							oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, clsCapacidadPago._codCapacidadPago,
							   string.Empty,
							   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
						}

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, clsCapacidadPago._porSensibilidadTipoCambio,
						   string.Empty,
						   strSensibilidad);

						#endregion
					}
				}
			}
			catch
			{
				throw;
			}
		}

        public void Modificar(string strCedula, DateTime dFecha, int nCapacidadPago, decimal nSensibilidad,
                              string strUsuario, string strIP)
		{
			try
			{
				string strSensibilidad = nSensibilidad.ToString();
				strSensibilidad = strSensibilidad.Replace(",",".");
                                
                string strFecha = dFecha.ToString("yyyyMMdd");

                listaCampos = new string[] { clsCapacidadPago._entidadCapacidadPagoDeudor,
                                             clsCapacidadPago._fechaCapacidadPago, strFecha,
                                             clsCapacidadPago._codCapacidadPago, nCapacidadPago.ToString(),
                                             clsCapacidadPago._porSensibilidadTipoCambio, strSensibilidad,
                                             clsCapacidadPago._cedulaDeudor, strCedula,
                                             clsCapacidadPago._fechaCapacidadPago, strFecha};

                string strModificarCapacidadPago = string.Format("UPDATE dbo.{0} SET {1} = {2}, {3} = {4}, {5} = CONVERT(DECIMAL(5,2), '{6}') WHERE {7} = '{8}' AND {9} = '{10}'", listaCampos);

                listaCampos = new string[] { clsCapacidadPago._fechaCapacidadPago, clsCapacidadPago._codCapacidadPago, clsCapacidadPago._porSensibilidadTipoCambio,
                                             clsCapacidadPago._entidadCapacidadPagoDeudor,
                                             clsCapacidadPago._cedulaDeudor, strCedula,
                                             clsCapacidadPago._fechaCapacidadPago, strFecha};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2} FROM dbo.{3} WHERE {4} = '{5}' AND {6} = '{7}'", listaCampos);

                DataSet dsCapacidadPago = AccesoBD.ejecutarConsulta(sentenciaSql);


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(strModificarCapacidadPago, oConexion))
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

						if ((dsCapacidadPago != null) && (dsCapacidadPago.Tables.Count > 0) && (dsCapacidadPago.Tables[0].Rows.Count > 0))
						{
							TraductordeCodigos oTraductor = new TraductordeCodigos();

							Bitacora oBitacora = new Bitacora();

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(clsCapacidadPago._fechaCapacidadPago))
							{
								DateTime dFechaCapacidadPagoObt = Convert.ToDateTime(dsCapacidadPago.Tables[0].Rows[0][clsCapacidadPago._fechaCapacidadPago].ToString());

								if (dFechaCapacidadPagoObt != dFecha)
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._fechaCapacidadPago,
									   dFechaCapacidadPagoObt.ToShortDateString(),
									   dFecha.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._fechaCapacidadPago,
									   string.Empty,
									   dFecha.ToShortDateString());
							}

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(clsCapacidadPago._codCapacidadPago))
							{
								int nCodigoCapacidadPagoObt = Convert.ToInt32(dsCapacidadPago.Tables[0].Rows[0][clsCapacidadPago._codCapacidadPago].ToString());

								if ((nCapacidadPago != -1) && (nCodigoCapacidadPagoObt != nCapacidadPago))
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._codCapacidadPago,
									   nCodigoCapacidadPagoObt.ToString(),
									   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._codCapacidadPago,
									   string.Empty,
									   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
							}

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(clsCapacidadPago._porSensibilidadTipoCambio))
							{
								decimal nSensibilidadTipoCambioObt = Convert.ToDecimal(dsCapacidadPago.Tables[0].Rows[0][clsCapacidadPago._porSensibilidadTipoCambio].ToString());

								if (nSensibilidadTipoCambioObt != (Convert.ToDecimal(strSensibilidad)))
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._porSensibilidadTipoCambio,
									   nSensibilidadTipoCambioObt.ToString(),
									   strSensibilidad);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, clsCapacidadPago._porSensibilidadTipoCambio,
									   string.Empty,
									   strSensibilidad);
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

        public void Eliminar(string strCedula, string dFecha,
                             string strUsuario, string strIP)
		{
			try
			{
                DateTime dFechaConv = DateTime.Parse(dFecha);
                
                string strFecha = dFechaConv.ToString("yyyyMMdd");

                listaCampos = new string[] { clsCapacidadPago._entidadCapacidadPagoDeudor,
                                             clsCapacidadPago._cedulaDeudor, strCedula,
                                             clsCapacidadPago._fechaCapacidadPago, strFecha};

                string strEliminarCapacidadPago = string.Format("DELETE FROM dbo.{0} WHERE {1} = '{2}' AND {3} = '{4}'", listaCampos);

                listaCampos = new string[] { clsCapacidadPago._cedulaDeudor, clsCapacidadPago._codCapacidadPago, clsCapacidadPago._fechaCapacidadPago, clsCapacidadPago._porSensibilidadTipoCambio,
                                             clsCapacidadPago._entidadCapacidadPagoDeudor,
                                             clsCapacidadPago._cedulaDeudor, strCedula,
                                             clsCapacidadPago._fechaCapacidadPago, strFecha};

                sentenciaSql = string.Format("SELECT {0}, {1}, {2}, {3} FROM dbo.{4} WHERE {5} = '{6}' AND {7} = '{8}'", listaCampos);

                DataSet dsCapacidadPago = AccesoBD.ejecutarConsulta(sentenciaSql);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
                    using (SqlCommand oComando = new SqlCommand(strEliminarCapacidadPago, oConexion))
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

						if ((dsCapacidadPago != null) && (dsCapacidadPago.Tables.Count > 0) && (dsCapacidadPago.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drCapacidadPago in dsCapacidadPago.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drCapacidadPago.Table.Columns.Count; nIndice++)
								{
									if (drCapacidadPago.Table.Columns[nIndice].ColumnName.CompareTo(clsCapacidadPago._codCapacidadPago) == 0)
									{
										if (drCapacidadPago[nIndice, DataRowVersion.Current].ToString() != string.Empty)
										{
											oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarCapacidadPago, string.Empty,
											   drCapacidadPago.Table.Columns[nIndice].ColumnName,
											   oTraductor.TraducirTipoCapacidadPago(Convert.ToInt32(drCapacidadPago[nIndice, DataRowVersion.Current].ToString())),
											   string.Empty);
										}
										else
										{
											oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
											   3, null, string.Empty, string.Empty, strEliminarCapacidadPago, string.Empty,
											   drCapacidadPago.Table.Columns[nIndice].ColumnName,
											   string.Empty,
											   string.Empty);
										}
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
										   3, null, string.Empty, string.Empty, strEliminarCapacidadPago, string.Empty,
										   drCapacidadPago.Table.Columns[nIndice].ColumnName,
										   drCapacidadPago[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
							   3, null, string.Empty, string.Empty, strEliminarCapacidadPago, string.Empty, string.Empty,
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
