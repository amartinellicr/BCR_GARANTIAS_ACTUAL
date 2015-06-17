using System;
using System.Data;
using System.Configuration;
using System.Data.OleDb;
using System.Data.SqlClient;
using BCRGARANTIAS.Datos;
using BCRGarantias.Contenedores;

namespace BCRGARANTIAS.Negocios
{
	/// <summary>
	/// Summary description for Valuaciones_Fiador.
	/// </summary>
	public class Valuaciones_Fiador
    {
        #region Variables Globales

        string strGarantia = "-";
        string strOperacionCrediticia = "-";

        #endregion

        #region Metodos Publicos

        public void Crear(int nGarantiaFiduciaria, string dFecha, decimal nIngresoNeto, int nTieneCapacidad, 
                          string strUsuario, string strIP)
		{
			try
			{
				string strIngreso = nIngresoNeto.ToString();
				strIngreso = strIngreso.Replace(",",".");
				
                DateTime dFechaConvertida = Convert.ToDateTime(dFecha);

                string strFecha = dFechaConvertida.ToString("yyyyMMdd"); //new System.Data.SqlTypes.SqlDateTime(dFechaConvertida).ToString();         

                string strInsertarValuacionesFiador = "INSERT INTO GAR_VALUACIONES_FIADOR " +
                        "(COD_GARANTIA_FIDUCIARIA, FECHA_VALUACION, INGRESO_NETO, COD_TIENE_CAPACIDAD_PAGO) " +
                        "VALUES (" + nGarantiaFiduciaria + ", '" + strFecha + "', " +
                        "convert(decimal(18,2), '" + strIngreso + "')," + nTieneCapacidad + ");";

//				strQry = "INSERT INTO GAR_VALUACIONES_FIADOR " +
//					"(COD_GARANTIA_FIDUCIARIA, FECHA_VALUACION, INGRESO_NETO, COD_TIENE_CAPACIDAD_PAGO) " +
//					"VALUES (" + nGarantiaFiduciaria + ", '" + dFecha.Substring(6,4).ToString() + "/" +
//					dFecha.Substring(3,2).ToString() + "/" +
//					dFecha.Substring(0,2).ToString() + "', " + 
//					"convert(decimal(18,2), '" + strIngreso + "'), " +
//					nTieneCapacidad + ");";

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strInsertarValuacionesFiador, oConexion);

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

						CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

						if (oGarantia.TipoOperacion != int.Parse(ConfigurationManager.AppSettings["TARJETA"].ToString()))
						{
							if (oGarantia.Contabilidad != 0)
								strOperacionCrediticia = oGarantia.Contabilidad.ToString();

							if (oGarantia.Oficina != 0)
								strOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

							if (oGarantia.Moneda != 0)
								strOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

							if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
							{
								if (oGarantia.Producto != 0)
									strOperacionCrediticia += "-" + oGarantia.Producto.ToString();
							}

							if (oGarantia.Numero != 0)
								strOperacionCrediticia += "-" + oGarantia.Numero.ToString();
						}
						else
						{
							strOperacionCrediticia = oGarantia.Tarjeta;
						}

						//Informacion del fiador
						if (oGarantia.CedulaFiador != null)
							strGarantia = oGarantia.CedulaFiador;

						oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
						   1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
						   ContenedorValuaciones_fiador.COD_GARANTIA_FIDUCIARIA,
						   string.Empty,
						   strGarantia);

						oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
						   1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
						   ContenedorValuaciones_fiador.FECHA_VALUACION,
						   string.Empty,
						   dFecha);

						oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
						   1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty,
						   ContenedorValuaciones_fiador.INGRESO_NETO,
						   string.Empty,
						   strIngreso);

						//oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
						//   1, 1, strGarantia, strOperacionCrediticia, strInsertarValuacionesFiador, string.Empty, 
						//   ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO,
						//   string.Empty,
						//   oTraductor.TraducirTipoTieneCapacidad(nTieneCapacidad));

						#endregion
					}
				}
            }
			catch
			{
				throw;
			}
		
		}

		public void Modificar(int nGarantiaFiduciaria, DateTime dFecha, decimal nIngresoNeto, int nTieneCapacidad, 
                              string strUsuario, string strIP)
		{
			try
			{
				string strModificarValuacionesFiador = "UPDATE GAR_VALUACIONES_FIADOR " +
								"SET ingreso_neto = " + nIngresoNeto;

				if (nTieneCapacidad != -1)
                    strModificarValuacionesFiador += ", cod_tiene_capacidad_pago = " + nTieneCapacidad;

                string strFecha = dFecha.ToString("yyyyMMdd"); //new System.Data.SqlTypes.SqlDateTime(dFecha).ToString(); 

                strModificarValuacionesFiador +=  
								" WHERE cod_garantia_fiduciaria = " + nGarantiaFiduciaria +
                                " AND fecha_valuacion = convert(varchar(10),'" + strFecha + "',111)";
				
                //AccesoBD.ejecutarConsulta(strQry);

                DataSet dsValuacionesFiador = AccesoBD.ejecutarConsulta("select " + ContenedorValuaciones_fiador.INGRESO_NETO + "," + 
                    ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO + 
                    " from " + ContenedorValuaciones_fiador.NOMBRE_ENTIDAD +
                    " where " + ContenedorValuaciones_fiador.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString() +
                    " and " + ContenedorValuaciones_fiador.FECHA_VALUACION + " = '" + dFecha.ToShortDateString() + "'");


				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strModificarValuacionesFiador, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsValuacionesFiador != null) && (dsValuacionesFiador.Tables.Count > 0) && (dsValuacionesFiador.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

							if (oGarantia.TipoOperacion != int.Parse(ConfigurationManager.AppSettings["TARJETA"].ToString()))
							{
								if (oGarantia.Contabilidad != 0)
									strOperacionCrediticia = oGarantia.Contabilidad.ToString();

								if (oGarantia.Oficina != 0)
									strOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

								if (oGarantia.Moneda != 0)
									strOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

								if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
								{
									if (oGarantia.Producto != 0)
										strOperacionCrediticia += "-" + oGarantia.Producto.ToString();
								}

								if (oGarantia.Numero != 0)
									strOperacionCrediticia += "-" + oGarantia.Numero.ToString();
							}
							else
							{
								strOperacionCrediticia = oGarantia.Tarjeta;
							}

							//Informacion del fiador
							if (oGarantia.CedulaFiador != null)
								strGarantia = oGarantia.CedulaFiador;

							if (!dsValuacionesFiador.Tables[0].Rows[0].IsNull(ContenedorValuaciones_fiador.INGRESO_NETO))
							{
								decimal nIngresoNetoObt = Convert.ToDecimal(dsValuacionesFiador.Tables[0].Rows[0][ContenedorValuaciones_fiador.INGRESO_NETO].ToString());

								if (nIngresoNetoObt != nIngresoNeto)
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
									   2, 1, strGarantia, strOperacionCrediticia, strModificarValuacionesFiador, string.Empty,
									   ContenedorValuaciones_fiador.INGRESO_NETO,
									   nIngresoNetoObt.ToString(),
									   nIngresoNeto.ToString());
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
									   2, 1, strGarantia, strOperacionCrediticia, strModificarValuacionesFiador, string.Empty,
									   ContenedorValuaciones_fiador.INGRESO_NETO,
									   string.Empty,
									   nIngresoNeto.ToString());
							}

							if (!dsValuacionesFiador.Tables[0].Rows[0].IsNull(ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO))
							{
								int nCodigoCapacidadPagoObt = Convert.ToInt32(dsValuacionesFiador.Tables[0].Rows[0][ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO].ToString());

								if ((nTieneCapacidad != -1) && (nCodigoCapacidadPagoObt != nTieneCapacidad))
								{
									oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
									   2, 1, strGarantia, strOperacionCrediticia, strModificarValuacionesFiador, string.Empty,
									   ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO,
									   oTraductor.TraducirTipoCapacidadPago(nCodigoCapacidadPagoObt),
									   oTraductor.TraducirTipoTieneCapacidad(nTieneCapacidad));
								}
							}
							else
							{
								oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
									   2, 1, strGarantia, strOperacionCrediticia, strModificarValuacionesFiador, string.Empty,
									   ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO,
									   string.Empty,
									   oTraductor.TraducirTipoTieneCapacidad(nTieneCapacidad));
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

		public void Eliminar(int nGarantiaFiduciaria, string dFecha, string strUsuario, string strIP)
		{
			try
			{
                DateTime dFechaConvertida = Convert.ToDateTime(dFecha);

				string strEliminarValuacionFiador = "DELETE GAR_VALUACIONES_FIADOR " +
								" WHERE cod_garantia_fiduciaria = " + nGarantiaFiduciaria +
                                " AND fecha_valuacion = '" + dFechaConvertida.ToString("yyyyMMdd") + "'"; 
                //convert(varchar(10),'" + dFecha + "',111)";
                    //" AND fecha_valuacion = '" + dFechaConvertida.Year.ToString() + "/" +
                    //                             dFechaConvertida.Month.ToString() + "/" +
                    //                             dFechaConvertida.Day.ToString() + "'";

//				string strQry = "DELETE GAR_VALUACIONES_FIADOR " +
//								" WHERE cod_garantia_fiduciaria = " + nGarantiaFiduciaria +
//								" AND fecha_valuacion = convert(varchar(10),'" + dFecha.Year.ToString() + "-" 
//																				+ dFecha.Month.ToString() + "-"  
//																				+ dFecha.Day.ToString() + "',111)";
                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strEliminarValuacionFiador, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;

					//Se obtienen los datos antes de ser borrados, para poder insertarlos en la bitácora
					DataSet dsValuacionesFiador = AccesoBD.ejecutarConsulta("select " + ContenedorValuaciones_fiador.INGRESO_NETO + "," +
					   ContenedorValuaciones_fiador.FECHA_VALUACION +
					   " from " + ContenedorValuaciones_fiador.NOMBRE_ENTIDAD +
					   " where " + ContenedorValuaciones_fiador.COD_GARANTIA_FIDUCIARIA + " = " + nGarantiaFiduciaria.ToString() +
					   " and " + ContenedorValuaciones_fiador.FECHA_VALUACION + " = '" + dFechaConvertida.ToShortDateString() + "'");


					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						CGarantiaFiduciaria oGarantia = CGarantiaFiduciaria.Current;

						if (oGarantia.TipoOperacion != int.Parse(ConfigurationManager.AppSettings["TARJETA"].ToString()))
						{
							if (oGarantia.Contabilidad != 0)
								strOperacionCrediticia = oGarantia.Contabilidad.ToString();

							if (oGarantia.Oficina != 0)
								strOperacionCrediticia += "-" + oGarantia.Oficina.ToString();

							if (oGarantia.Moneda != 0)
								strOperacionCrediticia += "-" + oGarantia.Moneda.ToString();

							if (oGarantia.TipoOperacion == int.Parse(ConfigurationManager.AppSettings["OPERACION_CREDITICIA"].ToString()))
							{
								if (oGarantia.Producto != 0)
									strOperacionCrediticia += "-" + oGarantia.Producto.ToString();
							}

							if (oGarantia.Numero != 0)
								strOperacionCrediticia += "-" + oGarantia.Numero.ToString();
						}
						else
						{
							strOperacionCrediticia = oGarantia.Tarjeta;
						}

						//Informacion del fiador
						if (oGarantia.CedulaFiador != null)
							strGarantia = oGarantia.CedulaFiador;

						if ((dsValuacionesFiador != null) && (dsValuacionesFiador.Tables.Count > 0) && (dsValuacionesFiador.Tables[0].Rows.Count > 0))
						{
							foreach (DataRow drValFia in dsValuacionesFiador.Tables[0].Rows)
							{
								for (int nIndice = 0; nIndice < drValFia.Table.Columns.Count; nIndice++)
								{
									if (drValFia.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorValuaciones_fiador.COD_TIENE_CAPACIDAD_PAGO) == 0)
									{
										if (!String.IsNullOrEmpty(drValFia[nIndice, DataRowVersion.Current].ToString()))
										{
											//oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
											//   3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
											//   drValFia.Table.Columns[nIndice].ColumnName,
											//   oTraductor.TraducirTipoTieneCapacidad(Convert.ToInt32(drValFia[nIndice, DataRowVersion.Current].ToString())),
											//   string.Empty);
										}
										//else
										//{
										//    oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
										//       3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
										//       drValFia.Table.Columns[nIndice].ColumnName,
										//       string.Empty,
										//       string.Empty);
										//}
									}
									else if (drValFia.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorValuaciones_fiador.COD_GARANTIA_FIDUCIARIA) == 0)
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
										   3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
										   drValFia.Table.Columns[nIndice].ColumnName,
										   strGarantia,
										   string.Empty);
									}
									else if (drValFia.Table.Columns[nIndice].ColumnName.CompareTo(ContenedorValuaciones_fiador.FECHA_VALUACION) == 0)
									{
										DateTime dtFechaVal = Convert.ToDateTime(drValFia[ContenedorValuaciones_fiador.FECHA_VALUACION].ToString());

										oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
										   3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
										   drValFia.Table.Columns[nIndice].ColumnName,
										   dtFechaVal.ToShortDateString(),
										   string.Empty);
									}
									else
									{
										oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
										   3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
										   drValFia.Table.Columns[nIndice].ColumnName,
										   drValFia[nIndice, DataRowVersion.Current].ToString(),
										   string.Empty);
									}
								}
							}
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_VALUACIONES_FIADOR", strUsuario, strIP, null,
							  3, 1, strGarantia, strOperacionCrediticia, strEliminarValuacionFiador, string.Empty,
							  string.Empty,
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
