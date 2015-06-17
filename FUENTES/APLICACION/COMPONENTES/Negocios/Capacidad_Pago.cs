using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Capacidad_Pago.
	/// </summary>
	public class Capacidad_Pago
	{	
		#region Metodos Publicos
		public void Crear(string strCedula, string dFecha, int nCapacidadPago, decimal nSensibilidad, 
                          string strUsuario, string strIP)
		{
			try
			{
				string strSensibilidad = nSensibilidad.ToString();
//				strSensibilidad = strSensibilidad.Replace(",",".");

                DateTime dFechaConv = Convert.ToDateTime(dFecha);

				string strInsertarCapacidadPago = "INSERT INTO GAR_CAPACIDAD_PAGO " +
						 "(CEDULA_DEUDOR, FECHA_CAPACIDAD_PAGO, ";
				
				if (nCapacidadPago != -1)
                    strInsertarCapacidadPago += "COD_CAPACIDAD_PAGO, ";

                DateTime dFecha1 = DateTime.Parse(dFecha);

                string strFecha = dFecha1.ToString("yyyyMMdd");

                strInsertarCapacidadPago += "SENSIBILIDAD_TIPO_CAMBIO) " +
                    "VALUES ('" + strCedula + "', '" + strFecha + "',";
                    
                                                        //dFecha.Substring(6,4).ToString() + "/" +
                                                        //dFecha.Substring(0,2).ToString() + "/" +
                                                        //dFecha.Substring(3,2).ToString() + "', ";
				
				if (nCapacidadPago != -1)
                    strInsertarCapacidadPago += nCapacidadPago + ", ";

                strInsertarCapacidadPago += " convert(decimal(5,2), '" + strSensibilidad + "'));";

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarCapacidadPago, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						Bitacora oBitacora = new Bitacora();

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, ContenedorCapacidad_pago.CEDULA_DEUDOR,
						   string.Empty,
						   strCedula);

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO,
						   string.Empty,
						   dFecha);

						if (nCapacidadPago != -1)
						{
							oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
							   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO,
							   string.Empty,
							   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
						}

						oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
						   1, null, string.Empty, string.Empty, strInsertarCapacidadPago, string.Empty, ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO,
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

                //string strFecha = new System.Data.SqlTypes.SqlDateTime(dFecha).ToString();
                string strFecha = dFecha.ToString("yyyyMMdd");

				string strModificarCapacidadPago = "UPDATE GAR_CAPACIDAD_PAGO " +
                                "SET FECHA_CAPACIDAD_PAGO = convert(varchar(10),'" + strFecha + "',111), " +
								"COD_CAPACIDAD_PAGO = " + nCapacidadPago + ", " +
								"SENSIBILIDAD_TIPO_CAMBIO = convert(decimal(5,2), '" + strSensibilidad + "') " +
								" WHERE CEDULA_DEUDOR = '" + strCedula + "' AND " +
                                " FECHA_CAPACIDAD_PAGO = '" + strFecha + "'";
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsCapacidadPago = AccesoBD.ejecutarConsulta("select " + ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO + "," +
                    ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO + "," + ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO + 
                    " from " + ContenedorCapacidad_pago.NOMBRE_ENTIDAD +
                    " where " + ContenedorCapacidad_pago.CEDULA_DEUDOR + " = '" + strCedula + "'" +
                    " and " + ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO + " = '" + strFecha + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarCapacidadPago, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsCapacidadPago != null) && (dsCapacidadPago.Tables.Count > 0) && (dsCapacidadPago.Tables[0].Rows.Count > 0))
						{
							TraductordeCodigos oTraductor = new TraductordeCodigos();

							Bitacora oBitacora = new Bitacora();

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO))
							{
								DateTime dFechaCapacidadPagoObt = Convert.ToDateTime(dsCapacidadPago.Tables[0].Rows[0][ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO].ToString());

								if (dFechaCapacidadPagoObt != dFecha)
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO,
									   dFechaCapacidadPagoObt.ToShortDateString(),
									   dFecha.ToShortDateString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO,
									   string.Empty,
									   dFecha.ToShortDateString());
							}

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO))
							{
								int nCodigoCapacidadPagoObt = Convert.ToInt32(dsCapacidadPago.Tables[0].Rows[0][ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO].ToString());

								if ((nCapacidadPago != -1) && (nCodigoCapacidadPagoObt != nCapacidadPago))
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO,
									   nCodigoCapacidadPagoObt.ToString(),
									   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO,
									   string.Empty,
									   oTraductor.TraducirTipoCapacidadPago(nCapacidadPago));
							}

							if (!dsCapacidadPago.Tables[0].Rows[0].IsNull(ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO))
							{
								decimal nSensibilidadTipoCambioObt = Convert.ToDecimal(dsCapacidadPago.Tables[0].Rows[0][ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO].ToString());

								if (nSensibilidadTipoCambioObt != (Convert.ToDecimal(strSensibilidad)))
								{
									oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO,
									   nSensibilidadTipoCambioObt.ToString(),
									   strSensibilidad);
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_CAPACIDAD_PAGO", strUsuario, strIP, null,
									   2, null, string.Empty, string.Empty, strModificarCapacidadPago, string.Empty, ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO,
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
                //string strFecha = new System.Data.SqlTypes.SqlDateTime(dFechaConv).ToString();
                string strFecha = dFechaConv.ToString("yyyyMMdd");

				string strEliminarCapacidadPago = "DELETE GAR_CAPACIDAD_PAGO WHERE CEDULA_DEUDOR = '" + strCedula + "' " +
                    "AND FECHA_CAPACIDAD_PAGO = '" + strFecha + "'";

                DataSet dsCapacidadPago = AccesoBD.ejecutarConsulta("select " + ContenedorCapacidad_pago.CEDULA_DEUDOR + "," +
                    ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO + "," + ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO + "," + 
                    ContenedorCapacidad_pago.SENSIBILIDAD_TIPO_CAMBIO +
                    " from " + ContenedorCapacidad_pago.NOMBRE_ENTIDAD +
                    " where " + ContenedorCapacidad_pago.CEDULA_DEUDOR + " = '" + strCedula + "'" +
                    " and " + ContenedorCapacidad_pago.FECHA_CAPACIDAD_PAGO + " = '" + strFecha + "'");

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarCapacidadPago, oConexion);

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

						if ((dsCapacidadPago != null) && (dsCapacidadPago.Tables.Count > 0) && (dsCapacidadPago.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drCapacidadPago in dsCapacidadPago.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drCapacidadPago.Table.Columns.Count; nIndice++)
								{
									if (drCapacidadPago.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorCapacidad_pago.COD_CAPACIDAD_PAGO) == 0)
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
