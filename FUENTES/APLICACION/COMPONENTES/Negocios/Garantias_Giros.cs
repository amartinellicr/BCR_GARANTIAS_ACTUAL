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
	/// Summary description for Garantias_Giros.
	/// </summary>
	public class Garantias_Giros
	{
		#region Metodos Publicos
        public void AsignarGarantias(long nGiro, long nContrato, string strUsuario, string strIP, string strOperacionCrediticia)
		{
			try
			{
				using (SqlConnection oConexion = new SqlConnection(AccesoBD.ObtenerConnectionString()))
				{
					SqlCommand oComando = new SqlCommand("pa_AsignarGarantiaGiro", oConexion);
					DataSet dsData = new DataSet();
					SqlParameter oParam = new SqlParameter();

					//Declara las propiedades del comando
					oComando.CommandType = CommandType.StoredProcedure;

					//Agrega los parametros
					oComando.Parameters.AddWithValue("@nGiro", nGiro);
					oComando.Parameters.AddWithValue("@nContrato", nContrato);
					oComando.Parameters.AddWithValue("@strUsuario", strUsuario);
					oComando.Parameters.AddWithValue("@strIP", strIP);
					//oComando.Parameters.AddWithValue("@nOficina",nOficina);	

					//Abre la conexion
					oConexion.Open();

					//Ejecuta el comando
					int nFilasAfectadas = oComando.ExecuteNonQuery();

					if (nFilasAfectadas > 0)
					{
						#region Inserción en Bitácora

						Bitacora oBitacora = new Bitacora();

						TraductordeCodigos oTraductor = new TraductordeCodigos();

						string strGarantia = "-";
						string strCodigoGarantia = string.Empty;
						string strCodigoTipoGarantia = string.Empty;

						string strInsertarGarantiaGiro = "INSERT INTO GAR_GARANTIAS_X_GIRO" +
								"(" +
								"   cod_operacion_giro," +
								"   cod_operacion," +
								"   cod_garantia," +
								"   cod_tipo_garantia" +
								") ";


						//Aquí se determina a que tipo de garantía pertenece el número de contrato 

						#region Garantía Fiduciaria

						string strConsultaGarantiaFiduciaria = "select " + nGiro.ToString() + "," +
							nContrato.ToString() + "," + "b." + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA + "," +
							"b." + ContenedorGarantia_fiduciaria.COD_TIPO_GARANTIA + "," + "b." + ContenedorGarantia_fiduciaria.CEDULA_FIADOR +
							" from " + ContenedorGarantias_fiduciarias_x_operacion.NOMBRE_ENTIDAD + " a," +
									   " GAR_GARANTIA_FIDUCIARIA b" +
							" where " + "a." + ContenedorGarantias_fiduciarias_x_operacion.COD_OPERACION + " = " + nContrato.ToString() +
									  " and " + "a." + ContenedorGarantias_fiduciarias_x_operacion.COD_GARANTIA_FIDUCIARIA + " = " + "b." + ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA;


						DataSet dsGarantiaFiduciaria = AccesoBD.ejecutarConsulta(strConsultaGarantiaFiduciaria);

						if ((dsGarantiaFiduciaria != null) && (dsGarantiaFiduciaria.Tables.Count > 0) && (dsGarantiaFiduciaria.Tables[0].Rows.Count > 0))
						{
							if ((!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA))
							  && (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.COD_TIPO_GARANTIA))
							  && (!dsGarantiaFiduciaria.Tables[0].Rows[0].IsNull(ContenedorGarantia_fiduciaria.CEDULA_FIADOR)))
							{
								strCodigoGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_GARANTIA_FIDUCIARIA].ToString();
								strCodigoTipoGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.COD_TIPO_GARANTIA].ToString();

								strGarantia = dsGarantiaFiduciaria.Tables[0].Rows[0][ContenedorGarantia_fiduciaria.CEDULA_FIADOR].ToString();

								strInsertarGarantiaGiro += strConsultaGarantiaFiduciaria;
							}
						}
						#endregion

						#region Garantía Real

						string strConsultaGarantiaReal = "select " + nGiro.ToString() + "," +
							nContrato.ToString() + ", b." + ContenedorGarantia_real.COD_GARANTIA_REAL +
							",b." + ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL +
							", b." + ContenedorGarantia_real.COD_TIPO_GARANTIA + ", b." + ContenedorGarantia_real.NUMERO_FINCA +
							", b." + ContenedorGarantia_real.NUM_PLACA_BIEN + ", b." + ContenedorGarantia_real.COD_CLASE_BIEN +
							", b." + ContenedorGarantia_real.COD_PARTIDO +
							" from " + ContenedorGarantias_reales_x_operacion.NOMBRE_ENTIDAD + " a," +
									   ContenedorGarantia_real.NOMBRE_ENTIDAD + " b" +
							" where " + "a." + ContenedorGarantias_reales_x_operacion.COD_OPERACION + " = " + nContrato.ToString() +
									  " and " + "a." + ContenedorGarantias_reales_x_operacion.COD_GARANTIA_REAL + " = " + "b." + ContenedorGarantia_real.COD_GARANTIA_REAL;


						DataSet dsGarantiaReal = AccesoBD.ejecutarConsulta(strConsultaGarantiaReal);

						if ((dsGarantiaReal != null) && (dsGarantiaReal.Tables.Count > 0) && (dsGarantiaReal.Tables[0].Rows.Count > 0))
						{
							if ((!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_GARANTIA_REAL))
							   && (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_TIPO_GARANTIA)))
							{
								strCodigoGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_GARANTIA_REAL].ToString();
								strCodigoTipoGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_TIPO_GARANTIA].ToString();

								if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL))
								{
									string strCodigoTipoGarantiaReal = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_TIPO_GARANTIA_REAL].ToString();

									int nCodigoTipoGarantiaReal = -1;

									if (strCodigoTipoGarantiaReal != string.Empty)
									{
										nCodigoTipoGarantiaReal = Convert.ToInt32(strCodigoTipoGarantiaReal);
									}

									//Se genera el dato correspondiente a la garantía
									if (nCodigoTipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["HIPOTECAS"].ToString()))
									{
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_PARTIDO))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString() != string.Empty)
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString();
											}

										}
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.NUMERO_FINCA))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString() != string.Empty)
											{
												strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString();
											}

											if ((dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO] == null)
											   || (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString() == string.Empty))
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString();
											}
										}
									}
									else if (nCodigoTipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["CEDULAS_HIPOTECARIAS"].ToString()))
									{
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_PARTIDO))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString() != string.Empty)
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString();
											}

										}
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.NUMERO_FINCA))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString() != string.Empty)
											{
												strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString();
											}

											if ((dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO] == null)
											   || (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_PARTIDO].ToString() == string.Empty))
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUMERO_FINCA].ToString();
											}
										}

									}
									else if (nCodigoTipoGarantiaReal == int.Parse(ConfigurationManager.AppSettings["PRENDAS"].ToString()))
									{
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.COD_CLASE_BIEN))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_CLASE_BIEN].ToString() != string.Empty)
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_CLASE_BIEN].ToString();
											}

										}
										if (!dsGarantiaReal.Tables[0].Rows[0].IsNull(ContenedorGarantia_real.NUM_PLACA_BIEN))
										{
											if (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUM_PLACA_BIEN].ToString() != string.Empty)
											{
												strGarantia += "-" + dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUM_PLACA_BIEN].ToString();
											}

											if ((dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_CLASE_BIEN] == null)
											   || (dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.COD_CLASE_BIEN].ToString() == string.Empty))
											{
												strGarantia = dsGarantiaReal.Tables[0].Rows[0][ContenedorGarantia_real.NUM_PLACA_BIEN].ToString();
											}
										}
									}
								}

								strInsertarGarantiaGiro += strConsultaGarantiaReal;
							}
						}
						#endregion

						#region Garantía Valor

						string strConsultaGarantiaValor = "select " + nGiro.ToString() + "," +
						   nContrato.ToString() + ", b." + ContenedorGarantia_valor.COD_GARANTIA_VALOR +
						   ", b." + ContenedorGarantia_valor.COD_TIPO_GARANTIA + ", b." + ContenedorGarantia_valor.NUMERO_SEGURIDAD +
						   " from " + ContenedorGarantias_valor_x_operacion.NOMBRE_ENTIDAD + " a," +
									  ContenedorGarantia_valor.NOMBRE_ENTIDAD + " b" +
						   " where " + "a." + ContenedorGarantias_valor_x_operacion.COD_OPERACION + " = " + nContrato.ToString() +
									 " and " + "a." + ContenedorGarantias_valor_x_operacion.COD_GARANTIA_VALOR + " = " + "b." + ContenedorGarantia_valor.COD_GARANTIA_VALOR;


						DataSet dsGarantiaValor = AccesoBD.ejecutarConsulta(strConsultaGarantiaValor);

						if ((dsGarantiaValor != null) && (dsGarantiaValor.Tables.Count > 0) && (dsGarantiaValor.Tables[0].Rows.Count > 0))
						{
							if ((!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_GARANTIA_VALOR))
							  && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.COD_TIPO_GARANTIA))
							  && (!dsGarantiaValor.Tables[0].Rows[0].IsNull(ContenedorGarantia_valor.NUMERO_SEGURIDAD)))
							{
								strCodigoGarantia = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_GARANTIA_VALOR].ToString();
								strCodigoTipoGarantia = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.COD_TIPO_GARANTIA].ToString();

								strGarantia = dsGarantiaValor.Tables[0].Rows[0][ContenedorGarantia_valor.NUMERO_SEGURIDAD].ToString();

								strInsertarGarantiaGiro += strConsultaGarantiaValor;
							}
						}
						#endregion

						if ((strCodigoTipoGarantia != string.Empty) && (strCodigoGarantia != string.Empty))
						{
							#region Garantía por Giro

							//if (strCodigoTipoGarantia.CompareTo("1") == 0)
							//{
							//    strCedulaFiador = oTraductor.ObtenerCedulaFiadorGarFidu(strCodigoGarantia);
							//    strCedulaDeudor = oTraductor.ObtenerCedulaDeudor(nContrato.ToString());
							//}
							//else if (strCodigoTipoGarantia.CompareTo("2") == 0)
							//{
							//    strCedulaFiador = "[" + strCodigoGarantia + "]";
							//    strCedulaDeudor = oTraductor.ObtenerCedulaDeudor(nContrato.ToString());
							//}
							//else if (strCodigoTipoGarantia.CompareTo("3") == 0)
							//{
							//    strCedulaFiador = "[" + strCodigoGarantia + "]";
							//    strCedulaDeudor = oTraductor.ObtenerCedulaDeudor(nContrato.ToString());
							//}



							//oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
							//    1, Convert.ToInt32(strCodigoTipoGarantia),strCedulaFiador, strCedulaDeudor, 
							//    strInsertarGarantiaGiro, string.Empty, 
							//    ContenedorGarantias_x_giro.COD_OPERACION_GIRO, 
							//    "-1", 
							//    nGiro.ToString());

							oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
								1, Convert.ToInt32(strCodigoTipoGarantia), strGarantia, strOperacionCrediticia,
								strInsertarGarantiaGiro, string.Empty,
								ContenedorGarantias_x_giro.COD_TIPO_GARANTIA,
								string.Empty,
								oTraductor.TraducirTipoGarantia(Convert.ToInt32(strCodigoTipoGarantia)));

							oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
								1, Convert.ToInt32(strCodigoTipoGarantia), strGarantia, strOperacionCrediticia,
								strInsertarGarantiaGiro, string.Empty,
								ContenedorGarantias_x_giro.COD_GARANTIA,
								string.Empty,
								strGarantia);

							oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
								1, Convert.ToInt32(strCodigoTipoGarantia), strGarantia, strOperacionCrediticia,
								strInsertarGarantiaGiro, string.Empty,
								ContenedorGarantias_x_giro.COD_OPERACION,
								string.Empty,
								strOperacionCrediticia);

							#endregion
						}
						else
						{
							oBitacora.InsertarBitacora("GAR_GARANTIAS_X_GIRO", strUsuario, strIP, null,
								1, null, strGarantia, strOperacionCrediticia, strInsertarGarantiaGiro, string.Empty,
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
