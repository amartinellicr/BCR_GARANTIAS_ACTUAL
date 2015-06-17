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
	/// Summary description for Deudores.
	/// </summary>
	public class Deudores
	{
		#region Metodos Publicos
		public void Modificar(int nTipoPersona, string strCedula, string strNombre, int nCondicionEspecial,
							  int nTipoAsignacion, int nGeneradorDivisas, int nVinculadoEntidad, string strUsuario, string strIP,
                              int nTipoGarantia)
		{
			try
			{
                string strGarantia = "-";
                string strOperacionCrediticia = "-";
				string strQry;

				strQry = "UPDATE GAR_DEUDOR " +
						 "SET COD_TIPO_DEUDOR = " + nTipoPersona + ", " +
						 "COD_GENERADOR_DIVISAS = " + nGeneradorDivisas + ", COD_VINCULADO_ENTIDAD = " + nVinculadoEntidad + ", ";
				
				if (nCondicionEspecial != -1)
					strQry = strQry + "COD_CONDICION_ESPECIAL = " + nCondicionEspecial + ", ";
				else
					strQry = strQry + "COD_CONDICION_ESPECIAL = NULL, ";

				if (nTipoAsignacion != -1)
					strQry = strQry + "COD_TIPO_ASIGNACION = " + nTipoAsignacion + ", ";
				else
					strQry = strQry + "COD_TIPO_ASIGNACION = NULL, ";

				strQry = strQry + "NOMBRE_DEUDOR = '" + strNombre + "' " +
							 " WHERE CEDULA_DEUDOR = '" + strCedula + "'";

                DataSet dsDeudor = AccesoBD.ejecutarConsulta("select " + ContenedorDeudor.COD_TIPO_DEUDOR + "," +
                   ContenedorDeudor.COD_GENERADOR_DIVISAS + "," + ContenedorDeudor.COD_VINCULADO_ENTIDAD + "," + 
                   ContenedorDeudor.COD_CONDICION_ESPECIAL + "," + ContenedorDeudor.COD_TIPO_ASIGNACION + "," + 
                   ContenedorDeudor.NOMBRE_DEUDOR +
                   " from " + ContenedorDeudor.NOMBRE_ENTIDAD +
                   " where " + ContenedorDeudor.CEDULA_DEUDOR + " = '" + strCedula + "'");

                //AccesoBD.ejecutarConsulta(strQry);

				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand(strQry, oConexion);

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.Text;
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						if ((dsDeudor != null) && (dsDeudor.Tables.Count > 0) && (dsDeudor.Tables[0].Rows.Count > 0))
						{
							Bitacora oBitacora = new Bitacora();

							TraductordeCodigos oTraductor = new TraductordeCodigos();

							#region Obtener datos relevantes

							if (nTipoGarantia == 1)
							{
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

								if (oGarantia.CedulaFiador != string.Empty)
								{
									strGarantia = oGarantia.CedulaFiador;
								}
							}
							else if (nTipoGarantia == 2)
							{
								CGarantiaReal oGarantia = CGarantiaReal.Current;

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

								if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["HIPOTECAS"].ToString()))
								{
									if (oGarantia.Partido != -1)
										strGarantia = oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
										strGarantia += "-" + oGarantia.Finca.ToString();
								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["CEDULAS_HIPOTECARIAS"].ToString()))
								{
									if (oGarantia.Partido != -1)
										strGarantia = oGarantia.Partido.ToString();

									if (oGarantia.Finca != -1)
										strGarantia += "-" + oGarantia.Finca.ToString();
								}
								else if (oGarantia.TipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["PRENDAS"].ToString()))
								{
									if (oGarantia.ClaseBien != null)
										strGarantia = oGarantia.ClaseBien.ToString();

									if (oGarantia.NumPlaca != null)
										strGarantia += "-" + oGarantia.NumPlaca.ToString();
								}
							}
							else if (nTipoGarantia == 3)
							{
								CGarantiaValor oGarantia = CGarantiaValor.Current;

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

								if (oGarantia.Seguridad != null)
									strGarantia = oGarantia.Seguridad.ToString();
							}

							#endregion

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.COD_TIPO_DEUDOR))
							{
								int nTipoDeudorObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][ContenedorDeudor.COD_TIPO_DEUDOR].ToString());

								if (nTipoDeudorObt != nTipoPersona)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty,
									   ContenedorDeudor.COD_TIPO_DEUDOR,
									   oTraductor.TraducirTipoPersona(nTipoDeudorObt),
									   oTraductor.TraducirTipoPersona(nTipoPersona));
								}
							}
							else
							{
								if (nTipoPersona != -1)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										  2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_TIPO_DEUDOR,
										  string.Empty,
										  oTraductor.TraducirTipoPersona(nTipoPersona));
								}
							}

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.COD_GENERADOR_DIVISAS))
							{
								int nCodigoGeneradorDivisasObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][ContenedorDeudor.COD_GENERADOR_DIVISAS].ToString());

								if (nCodigoGeneradorDivisasObt != nGeneradorDivisas)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_GENERADOR_DIVISAS,
									   oTraductor.TraducirTipoGenerador(nCodigoGeneradorDivisasObt),
									   oTraductor.TraducirTipoGenerador(nGeneradorDivisas));
								}
							}
							else
							{
								if (nGeneradorDivisas != -1)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_GENERADOR_DIVISAS,
										   string.Empty,
										   oTraductor.TraducirTipoGenerador(nGeneradorDivisas));
								}
							}

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.COD_VINCULADO_ENTIDAD))
							{
								int nCodigoVinculadoEntidadObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][ContenedorDeudor.COD_VINCULADO_ENTIDAD].ToString());

								if (nCodigoVinculadoEntidadObt != nVinculadoEntidad)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_VINCULADO_ENTIDAD,
									   oTraductor.TraducirTipoVinculadoEntidad(nCodigoVinculadoEntidadObt),
									   oTraductor.TraducirTipoVinculadoEntidad(nVinculadoEntidad));
								}
							}
							else
							{
								if (nVinculadoEntidad != -1)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										  2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_VINCULADO_ENTIDAD,
										  string.Empty,
										  oTraductor.TraducirTipoVinculadoEntidad(nVinculadoEntidad));
								}
							}

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.COD_CONDICION_ESPECIAL))
							{
								int nCodigoCondicionEspecialObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][ContenedorDeudor.COD_CONDICION_ESPECIAL].ToString());

								if (nCodigoCondicionEspecialObt != nCondicionEspecial)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_CONDICION_ESPECIAL,
									   oTraductor.TraducirTipoCondicionEspecial(nCodigoCondicionEspecialObt),
									   oTraductor.TraducirTipoCondicionEspecial(nCondicionEspecial));
								}
							}
							else
							{
								if (nCondicionEspecial != -1)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_CONDICION_ESPECIAL,
										   string.Empty,
										   oTraductor.TraducirTipoCondicionEspecial(nCondicionEspecial));
								}
							}

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.COD_TIPO_ASIGNACION))
							{
								int nCodigoTipoAsignacionObt = Convert.ToInt32(dsDeudor.Tables[0].Rows[0][ContenedorDeudor.COD_TIPO_ASIGNACION].ToString());

								if (nCodigoTipoAsignacionObt != nTipoAsignacion)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_TIPO_ASIGNACION,
									   oTraductor.TraducirTipoAsignacion(nCodigoTipoAsignacionObt),
									   oTraductor.TraducirTipoAsignacion(nTipoAsignacion));
								}
							}
							else
							{
								if (nTipoAsignacion != -1)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.COD_TIPO_ASIGNACION,
										   string.Empty,
										   oTraductor.TraducirTipoAsignacion(nTipoAsignacion));
								}
							}

							if (!dsDeudor.Tables[0].Rows[0].IsNull(ContenedorDeudor.NOMBRE_DEUDOR))
							{
								string strNombreDeudorObt = dsDeudor.Tables[0].Rows[0][ContenedorDeudor.NOMBRE_DEUDOR].ToString();

								if ((strNombreDeudorObt.Trim().CompareTo(strNombre.Trim()) != 0) && (strNombre != string.Empty))
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
									   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.NOMBRE_DEUDOR,
									   strNombreDeudorObt,
									   strNombre);
								}
							}
							else
							{
								if (strNombre != string.Empty)
								{
									oBitacora.InsertarBitacora("GAR_DEUDOR", strUsuario, strIP, null,
										   2, nTipoGarantia, strGarantia, strOperacionCrediticia, strQry, string.Empty, ContenedorDeudor.NOMBRE_DEUDOR,
										   string.Empty,
										   strNombre);
								}
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

		public string ObtenerNombreDeudor(string strCedula)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_ObtenerNombreCliente", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//agrega los parametros
					oComando.Parameters.AddWithValue("@strCedula", strCedula);

					//inicializacion del objeto output
					oParam.SqlDbType = SqlDbType.VarChar;
					oParam.Size = 150;
					oParam.Direction = ParameterDirection.Output;
					oParam.ParameterName = "@strNombre";
					oComando.Parameters.Add(oParam);

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					oComando.ExecuteNonQuery();

					return oParam.Value.ToString();
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
